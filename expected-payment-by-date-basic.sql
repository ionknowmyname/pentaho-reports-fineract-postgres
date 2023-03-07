



SELECT 
      ounder.name 'Office', 
      coalesce(ms.display_name,'-') 'Loan Officer',
	  mc.account_no 'Client Account Number',
	  mc.display_name 'Name',
	  mp.name 'Product',
	  ml.account_no 'Loan Account Number',
	  mr.duedate 'Due Date',
	  mr.installment 'Installment',
	  cu.display_symbol 'Currency',
	  mr.principal_amount- coalesce(mr.principal_completed_derived,0) 'Principal Due',
	  mr.interest_amount- coalesce(coalesce(mr.interest_completed_derived,mr.interest_waived_derived),0) 'Interest Due', 
	  coalesce(mr.fee_charges_amount,0)- coalesce(coalesce(mr.fee_charges_completed_derived,mr.fee_charges_waived_derived),0) 'Fees Due', 
	  coalesce(mr.penalty_charges_amount,0)- coalesce(coalesce(mr.penalty_charges_completed_derived,mr.penalty_charges_waived_derived),0) 'Penalty Due',
      (mr.principal_amount- coalesce(mr.principal_completed_derived,0)) +
       (mr.interest_amount- coalesce(coalesce(mr.interest_completed_derived,mr.interest_waived_derived),0)) + 
       (coalesce(mr.fee_charges_amount,0)- coalesce(coalesce(mr.fee_charges_completed_derived,mr.fee_charges_waived_derived),0)) + 
       (coalesce(mr.penalty_charges_amount,0)- coalesce(coalesce(mr.penalty_charges_completed_derived,mr.penalty_charges_waived_derived),0)) 'Total Due', 
     mlaa.total_overdue_derived 'Total Overdue'
										 
 FROM m_office mo
  JOIN m_office ounder ON ounder.hierarchy LIKE CONCAT(mo.hierarchy, '%')
  
  AND ounder.hierarchy like CONCAT(${userhierarchy}, '%')
	
  LEFT JOIN m_client mc ON mc.office_id=ounder.id
  LEFT JOIN m_loan ml ON ml.client_id=mc.id AND ml.loan_status_id=300
  LEFT JOIN m_loan_arrears_aging mlaa ON mlaa.loan_id=ml.id
  LEFT JOIN m_loan_repayment_schedule mr ON mr.loan_id=ml.id AND mr.completed_derived=0
  LEFT JOIN m_product_loan mp ON mp.id=ml.product_id
  LEFT JOIN m_staff ms ON ms.id=ml.loan_officer_id
  LEFT JOIN m_currency cu ON cu.code=ml.currency_code
  where mo.id = ${Branch} 
  and (coalesce(ml.loan_officer_id, -10) = ${Loan Officer} or "-1" = ${Loan Officer})
   AND mr.duedate BETWEEN ${startDate} AND ${endDate}


 ORDER BY ounder.id,mr.duedate,ml.account_no                        