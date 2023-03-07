





select 
concat(repeat("..",   
   ((LENGTH(ounder.hierarchy) - LENGTH(REPLACE(ounder.hierarchy, '.', '')) - 1))), ounder.name) 
	as "Office/Branch",ounder.name, ounder.id, c.account_no as "Client Account No.", 
c.display_name as "Name",
r.enum_message_property as "Client Status",
coalesce(lo.display_name,"-") as "Loan Officer", coalesce(l.account_no,"-") as "Loan Account No.",coalesce(l.external_id,'-') as
 "External Id", p.name as Loan, st.enum_message_property as "Status",  
coalesce(f.name,'-') as Fund, coalesce(purp.code_value,'-') as "Loan Purpose",
coalesce(cur.display_symbol, l.currency_code) as Currency,  
l.principal_amount, coalesce(l.arrearstolerance_amount,0) as "Arrears Tolerance Amount",
coalesce(l.number_of_repayments,0) as "Expected No. Repayments", 
coalesce(l.annual_nominal_interest_rate,0) as "Annual_Nominal_Interest_Rate", 
coalesce(l.nominal_interest_rate_per_period,0) as "Nominal Interest Rate Per Period",
coalesce(ipf.enum_message_property,'-') as "Interest Rate Frequency",
coalesce(im.enum_message_property,'-') as "Interest Method",
coalesce(icp.enum_message_property,'-') as "Interest Calculated in Period",
coalesce(l.term_frequency,0) as "Term Frequency",
coalesce(tf.enum_message_property,'-') as "Term Frequency Period",
coalesce(l.repay_every,'-') as "Repayment Frequency",
coalesce(rf.enum_message_property,'-') as "Repayment Frequency Period",
coalesce(am.enum_message_property,'-') as "Amortization",
coalesce(l.total_charges_due_at_disbursement_derived,0) as "Total Charges Due At Disbursement",
coalesce(date(l.submittedon_date),'-') as Submitted, date(l.approvedon_date) Approved, 
l.expected_disbursedon_date As "Expected Disbursal",
date(l.expected_firstrepaymenton_date) as "Expected First Repayment", 
date(l.interest_calculated_from_date) as "Interest Calculated From" ,
date(l.disbursedon_date) as Disbursed, 
date(l.expected_maturedon_date) "Expected Maturity",
date(l.maturedon_date) as "Matured On", date(l.closedon_date) as Closed,
date(l.rejectedon_date) as Rejected, date(l.rescheduledon_date) as Rescheduled, 
date(l.withdrawnon_date) as Withdrawn, date(l.writtenoffon_date) "Written Off"
from m_office o 
join m_office ounder on ounder.hierarchy like concat(o.hierarchy, '%')
and ounder.hierarchy like concat(${userhierarchy}, '%')
join m_client c on c.office_id = ounder.id
left join r_enum_value r on r.enum_name = 'status_enum' 
 and r.enum_id = c.status_enum
left join m_loan l on l.client_id = c.id
left join m_staff lo on lo.id = l.loan_officer_id
left join m_product_loan p on p.id = l.product_id
left join m_fund f on f.id = l.fund_id
left join r_enum_value st on st.enum_name = "loan_status_id" and st.enum_id = l.loan_status_id
left join r_enum_value ipf on ipf.enum_name = "interest_period_frequency_enum" 
 and ipf.enum_id = l.interest_period_frequency_enum
left join r_enum_value im on im.enum_name = "interest_method_enum" 
 and im.enum_id = l.interest_method_enum
left join r_enum_value tf on tf.enum_name = "term_period_frequency_enum" 
 and tf.enum_id = l.term_period_frequency_enum
left join r_enum_value icp on icp.enum_name = "interest_calculated_in_period_enum" 
 and icp.enum_id = l.interest_calculated_in_period_enum
left join r_enum_value rf on rf.enum_name = "repayment_period_frequency_enum" 
 and rf.enum_id = l.repayment_period_frequency_enum
left join r_enum_value am on am.enum_id = l.amortization_method_enum and am.enum_name = "amortization_method_enum"  
left join m_code_value purp on purp.id = l.loanpurpose_cv_id
left join m_currency cur on cur.code = l.currency_code
where o.id = ${Branch}
and (coalesce(l.loan_officer_id, -10) = ${Loan Officer} or "-1" = ${Loan Officer})
and (l.currency_code = ${CurrencyId} or "-1" = ${CurrencyId})
and (coalesce(l.fund_id, -10) = ${fundId} or -1 = ${fundId})
and (l.product_id = ${loanProductId} or "-1" = ${loanProductId})
and (coalesce(l.loanpurpose_cv_id, -10) = ${loanPurposeId} or "-1" = ${loanPurposeId})


order by ounder.hierarchy, 2 , l.id, lo.id                                                                                          