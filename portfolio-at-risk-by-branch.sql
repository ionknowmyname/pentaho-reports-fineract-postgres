




select concat(repeat("..",   
   ((LENGTH(mo.hierarchy) - LENGTH(REPLACE(mo.hierarchy, '.', '')) - 1))), mo.name) as "Office/Branch",x.branchn as name,
x.Currency, x.Principal Outstanding, coalesce(x.Principal Overdue,0)as "Principal Overdue", coalesce(x.Interest Outstanding,0) as "Interest Outstanding", coalesce(x.Interest Overdue,0)as "Interest Overdue", 
coalesce(x.Fees Outstanding,0)as "Fees Outstanding",coalesce(x.Fees Overdue,0)as "Fees Overdue", coalesce(x.Penalties Outstanding,0)as "Penalties Outstanding", coalesce(x.Penalties Overdue,0) as"Penalties Overdue",(case
	when ${parType} = 1 then
    cast(round((x.Principal Overdue * 100) / x.Principal Outstanding, 2) as char)
	when ${parType} = 2 then
    cast(round(((x.Principal Overdue + x.Interest Overdue) * 100) / (x.Principal Outstanding + x.Interest Outstanding), 2) as char)
	when ${parType} = 3 then
    cast(round(((x.Principal Overdue + x.Interest Overdue + x.Fees Overdue) * 100) / (x.Principal Outstanding + x.Interest Outstanding + x.Fees Outstanding), 2) as char)
	when ${parType} = 4 then
    cast(round(((x.Principal Overdue + x.Interest Overdue + x.Fees Overdue + x.Penalties Overdue) * 100) / (x.Principal Outstanding + x.Interest Outstanding + x.Fees Outstanding + x.Penalties Overdue), 2) as char)
	else "invalid PAR Type"
	end) as "Portfolio at Risk %"
from m_office mo
join 
(select  ounder.id as "branch",ounder.name as "branchn", coalesce(cur.display_symbol, l.currency_code) as Currency,  

sum(l.principal_outstanding_derived) as "Principal Outstanding",
sum(laa.principal_overdue_derived) as "Principal Overdue",

sum(l.interest_outstanding_derived) as "Interest Outstanding",
sum(laa.interest_overdue_derived) as "Interest Overdue",

sum(l.fee_charges_outstanding_derived)  as "Fees Outstanding",
sum(laa.fee_charges_overdue_derived) as "Fees Overdue",

sum(penalty_charges_outstanding_derived) as "Penalties Outstanding",
sum(laa.penalty_charges_overdue_derived) as "Penalties Overdue"

from m_office o 
join m_office ounder on ounder.hierarchy like concat(o.hierarchy, '%')
and ounder.hierarchy like concat(${userhierarchy}, '%')
join m_client c on c.office_id = ounder.id
join  m_loan l on l.client_id = c.id
left join m_staff lo on lo.id = l.loan_officer_id
left join m_currency cur on cur.code = l.currency_code
left join m_fund f on f.id = l.fund_id
left join m_code_value purp on purp.id = l.loanpurpose_cv_id
left join m_product_loan p on p.id = l.product_id
left join m_loan_arrears_aging laa on laa.loan_id = l.id
where o.id = ${Branch}  
and (coalesce(l.loan_officer_id, -10) = ${Loan Officer} or "-1" = ${Loan Officer})
and (l.currency_code = ${CurrencyId} or "-1" = ${CurrencyId})
and (coalesce(l.fund_id, -10) = ${fundId} or -1 = ${fundId})
and (l.product_id = ${loanProductId} or "-1" = ${loanProductId})
and (coalesce(l.loanpurpose_cv_id, -10) = ${loanPurposeId} or "-1" = ${loanPurposeId})


and l.loan_status_id = 300
group by ounder.id, l.currency_code) x on x.branch = mo.id
order by mo.hierarchy, x.Currency



                                                