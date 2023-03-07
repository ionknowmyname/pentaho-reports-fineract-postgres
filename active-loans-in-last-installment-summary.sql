







select concat(repeat('..',   
   ((LENGTH(mo.hierarchy) - LENGTH(REPLACE(mo.hierarchy, '.', '')) - 1))), mo.name) as "Office/Branch",x.bname as name , x.currency as Currency,
 x.client_count as "No. of Clients", x.active_loan_count as "No. Active Loans", x. arrears_loan_count as "No. of Loans in Arrears",
x.principal as "Total Loans Disbursed", x.principal_repaid as "Principal Repaid", x.principal_outstanding as "Principal Outstanding", x.principal_overdue as "Principal Overdue",
x.interest as "Total Interest", x.interest_repaid as "Interest Repaid", x.interest_outstanding as "Interest Outstanding", x.interest_overdue as "Interest Overdue",
x.fees as "Total Fees", x.fees_repaid as "Fees Repaid", x.fees_outstanding as "Fees Outstanding", x.fees_overdue as "Fees Overdue",
x.penalties as "Total Penalties", x.penalties_repaid as "Penalties Repaid", x.penalties_outstanding as "Penalties Outstanding", x.penalties_overdue as "Penalties Overdue",

	(case
	when ${parType} = 1 then
    cast(round((x.principal_overdue * 100) / x.principal_outstanding, 2) as char)
	when ${parType} = 2 then
    cast(round(((x.principal_overdue + x.interest_overdue) * 100) / (x.principal_outstanding + x.interest_outstanding), 2) as char)
	when ${parType} = 3 then
    cast(round(((x.principal_overdue + x.interest_overdue + x.fees_overdue) * 100) / (x.principal_outstanding + x.interest_outstanding + x.fees_outstanding), 2) as char)
	when ${parType} = 4 then
    cast(round(((x.principal_overdue + x.interest_overdue + x.fees_overdue + x.penalties_overdue) * 100) / (x.principal_outstanding + x.interest_outstanding + x.fees_outstanding + x.penalties_overdue), 2) as char)
	else "invalid PAR Type"
	end) as "Portfolio at Risk %"
 from m_office mo
join 
(select lastInstallment.branchId as branchId,lastInstallment.branch as bname,
lastInstallment.Currency,
count(distinct(lastInstallment.clientId)) as client_count, 
count(distinct(lastInstallment.loanId)) as  active_loan_count,
count(distinct(laa.loan_id)  ) as arrears_loan_count,

sum(l.principal_disbursed_derived) as principal,
sum(l.principal_repaid_derived) as principal_repaid,
sum(l.principal_outstanding_derived) as principal_outstanding,
sum(coalesce(laa.principal_overdue_derived,0)) as principal_overdue,

sum(l.interest_charged_derived) as interest,
sum(l.interest_repaid_derived) as interest_repaid,
sum(l.interest_outstanding_derived) as interest_outstanding,
sum(coalesce(laa.interest_overdue_derived,0)) as interest_overdue,

sum(l.fee_charges_charged_derived) as fees,
sum(l.fee_charges_repaid_derived) as fees_repaid,
sum(l.fee_charges_outstanding_derived)  as fees_outstanding,
sum(coalesce(laa.fee_charges_overdue_derived,0)) as fees_overdue,

sum(l.penalty_charges_charged_derived) as penalties,
sum(l.penalty_charges_repaid_derived) as penalties_repaid,
sum(l.penalty_charges_outstanding_derived) as penalties_outstanding,
sum(coalesce(laa.penalty_charges_overdue_derived,0)) as penalties_overdue

from 
(select l.id as loanId, l.number_of_repayments, min(r.installment), 
ounder.id as branchId, ounder.hierarchy, ounder.name as branch, 
coalesce(cur.display_symbol, l.currency_code) as Currency,
lo.display_name as "Loan Officer", c.id as clientId, c.account_no as "Client Account No",
c.display_name as "Client", l.account_no as "Loan Account No", pl.name as "Product", 
f.name as Fund,  l.principal_amount as "Loan Amount", 
l.annual_nominal_interest_rate as "Annual Nominal Interest Rate", 
date(l.disbursedon_date) as "Disbursed", date(l.expected_maturedon_date) as "Expected Matured On"
from m_office o 
join m_office ounder on ounder.hierarchy like concat(o.hierarchy, '%')
and ounder.hierarchy like concat(${userhierarchy}, '%')
join m_client c on c.office_id = ounder.id
join m_loan l on l.client_id = c.id
join m_product_loan pl on pl.id = l.product_id
left join m_staff lo on lo.id = l.loan_officer_id
left join m_currency cur on cur.code = l.currency_code
left join m_fund f on f.id = l.fund_id
left join m_loan_repayment_schedule r on r.loan_id = l.id
where o.id = ${Branch} 
and (coalesce(l.loan_officer_id, -10) = ${Loan Officer} or "-1" = ${Loan Officer})
and (l.currency_code = ${CurrencyId} or "-1" = ${CurrencyId})
and (l.product_id = ${loanProductId} or "-1" = ${loanProductId})
and (coalesce(l.fund_id, -10) = ${fundId} or -1 = ${fundId})
and (coalesce(l.loanpurpose_cv_id, -10) = ${loanPurposeId} or "-1" = ${loanPurposeId})
and l.loan_status_id = 300
and r.completed_derived is false
and r.duedate >= curdate()
group by l.id
having l.number_of_repayments = min(r.installment)) lastInstallment
join m_loan l on l.id = lastInstallment.loanId
left join m_loan_arrears_aging laa on laa.loan_id = l.id
group by lastInstallment.branchId) x on x.branchId = mo.id
order by mo.hierarchy, x.Currency                                                