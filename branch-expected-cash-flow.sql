




SELECT 
office,
action_date, 
SUM(principal) AS prin, 
SUM(interest) AS intr, 
SUM(fees) AS fee, 
SUM(penalty) AS pen, 
SUM(loan_disb) AS dis,
curr AS curr
FROM
(

/*Repayments and Fees/penalties*/
(SELECT mr.duedate action_date,
ounder.name office, 
SUM(coalesce(mr.principal_amount,0)) principal, 
SUM(coalesce(mr.interest_amount,0))- SUM(coalesce(mr.interest_waived_derived,0)) interest, 
SUM(coalesce(mr.fee_charges_amount,0))- SUM(coalesce(mr.fee_charges_waived_derived,0)) fees, 
SUM(coalesce(mr.penalty_charges_amount,0))- SUM(coalesce(mr.penalty_charges_waived_derived,0)) penalty,
0.0 AS loan_disb,
ml.currency_code curr
FROM 
m_office mo
JOIN m_office ounder ON ounder.hierarchy LIKE CONCAT(mo.hierarchy, '%')
  AND ounder.hierarchy like CONCAT(${userhierarchy}, '%')
LEFT JOIN m_client mc ON mc.office_id=ounder.id
JOIN m_loan ml ON ml.client_id=mc.id
JOIN m_loan_repayment_schedule mr ON mr.loan_id=ml.id
WHERE mo.id=${selectOffice}
AND mr.duedate BETWEEN ${fromDate} AND ${toDate}
AND mr.completed_derived=0
AND ml.loan_status_id in (100, 200, 300)
GROUP BY ounder.id,ml.currency_code,mr.duedate
ORDER BY ounder.name,ml.currency_code,mr.duedate) 

UNION ALL

/*Disbursals And Fees at disbursals*/
(SELECT ml.expected_disbursedon_date action_date,
ounder.name office,
0.0 principal,
0.0 interest, 
SUM(coalesce(ml.total_charges_due_at_disbursement_derived,0)) fees,
0.0 penalty, 
SUM(ml.principal_amount) AS loan_disb,
ml.currency_code curr
FROM 
m_office mo
JOIN m_office ounder ON ounder.hierarchy LIKE CONCAT(mo.hierarchy, '%')
  AND ounder.hierarchy like CONCAT(${userhierarchy}, '%')
LEFT JOIN m_client mc ON mc.office_id=ounder.id
JOIN m_loan ml ON ml.client_id=mc.id
WHERE mo.id=${selectOffice} 
AND ml.expected_disbursedon_date BETWEEN ${fromDate} AND ${toDate} 
AND ml.loan_status_id IN (100,200)
GROUP BY ounder.id,ml.currency_code,ml.expected_disbursedon_date
ORDER BY ounder.name,ml.expected_disbursedon_date,ml.expected_disbursedon_date)
) results
GROUP BY office,curr,action_date                                                                                    