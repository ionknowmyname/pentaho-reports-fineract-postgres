






SELECT 
concat(repeat('..',   
   ((LENGTH(ounder.hierarchy) - LENGTH(REPLACE(ounder.hierarchy, '.', '')) - 1))), ounder.name) as "Office/Branch",ounder.name as Name,
coalesce(cur.display_symbol, ml.currency_code) as Currency,
c.account_no as "Client Account No.",
c.display_name AS 'Client Name',
ml.account_no AS 'Loan Account No.',
coalesce(mpl.name,'-') AS 'Product Name',
ml.disbursedon_date AS 'Disbursed Date',
lt.transaction_date AS 'Written Off date',
ml.principal_amount as "Loan Amount",
coalesce(lt.principal_portion_derived, 0) AS 'Rescheduled Principal',
coalesce(lt.interest_portion_derived, 0) AS 'Rescheduled Interest',
coalesce(lt.fee_charges_portion_derived,0) AS 'Rescheduled Fees',
coalesce(lt.penalty_charges_portion_derived,0) AS 'Rescheduled Penalties',
n.note AS 'Reason For Rescheduling',
coalesce(ms.display_name,'-') AS 'Loan Officer Name'
FROM m_office o
JOIN m_office ounder ON ounder.hierarchy like concat(o.hierarchy, '%')
AND ounder.hierarchy like CONCAT(${userhierarchy}, '%')
JOIN m_client c ON c.office_id = ounder.id
JOIN m_loan ml ON ml.client_id = c.id
JOIN m_product_loan mpl ON mpl.id=ml.product_id
LEFT JOIN m_staff ms ON ms.id=ml.loan_officer_id
JOIN m_loan_transaction lt ON lt.loan_id = ml.id
LEFT JOIN m_note n ON n.loan_transaction_id = lt.id
LEFT JOIN m_currency cur on cur.code = ml.currency_code
WHERE /*lt.transaction_type_enum = 7 marked for rescheduling 
AND */ lt.is_reversed=0
AND ml.loan_status_id=602
AND o.id=${Branch}
AND (mpl.id=${loanProductId} OR ${loanProductId}=-1)
AND lt.transaction_date BETWEEN ${startDate} AND ${endDate}
AND (ml.currency_code = ${CurrencyId} or "-1" = ${CurrencyId})
ORDER BY ounder.hierarchy, coalesce(cur.display_symbol, ml.currency_code), ml.account_no                                          