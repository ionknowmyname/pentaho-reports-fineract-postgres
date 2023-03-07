





SELECT 
concat(repeat('..',   
   ((LENGTH(ounder.hierarchy) - LENGTH(REPLACE(ounder.hierarchy, '.', '')) - 1))), ounder.name) as "Office/Branch",ounder.name, ounder.id,
c.account_no as "Client Account No", c.display_name as "Name", l.account_no as "Loan Account No.", pl.name as "Product", 
f.name as Fund, coalesce(cur.display_symbol, l.currency_code) as Currency,  
l.principal_amount as Principal,  
l.term_frequency as "Term Frequency",


tf.enum_message_property as "Term Frequency Period",
l.annual_nominal_interest_rate as "Annual Nominal Interest Rate",
date(l.approvedon_date) "Approved",
datediff(l.expected_disbursedon_date, curdate()) as "Days to Disbursal",
date(l.expected_disbursedon_date) "Expected Disbursal",
coalesce(purp.code_value,'-') as "Loan Purpose",
 coalesce(lo.display_name,'-') as "Loan Officer"
from m_office o 
join m_office ounder on ounder.hierarchy like concat(o.hierarchy, '%')
and ounder.hierarchy like concat(${userhierarchy}, '%')
join m_client c on c.office_id = ounder.id
join m_loan l on l.client_id = c.id
join m_product_loan pl on pl.id = l.product_id
left join m_staff lo on lo.id = l.loan_officer_id
left join m_currency cur on cur.code = l.currency_code
left join m_fund f on f.id = l.fund_id
left join m_code_value purp on purp.id = l.loanpurpose_cv_id
left join r_enum_value tf on tf.enum_id = l.term_period_frequency_enum and tf.enum_name = "term_period_frequency_enum"
where o.id = ${Branch}
and (coalesce(l.loan_officer_id, -10) = ${Loan Officer} or "-1" = ${Loan Officer})
and (l.currency_code = ${CurrencyId} or "-1" = ${CurrencyId})
and (coalesce(l.fund_id, -10) = ${fundId} or -1 = ${fundId})
and (l.product_id = ${loanProductId} or "-1" = ${loanProductId})
and (coalesce(l.loanpurpose_cv_id, -10) = ${loanPurposeId} or "-1" = ${loanPurposeId})
and l.loan_status_id = 200
order by ounder.hierarchy, datediff(l.expected_disbursedon_date, curdate()),  c.account_no  
                                                                                                    