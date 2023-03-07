





select date(${startDate}) as 'Transaction Date', 'Opening Balance' as Transaction Type, coalesce(null,'-') as Office,
	coalesce(Null,'-') as 'Loan Officer', coalesce(null,'-') as Loan Account No, coalesce(null,'-') as Loan Product, coalesce(null,'-') as Currency, 
	coalesce(null,'-') as Client Account No, coalesce(null,'-') as Client, 
	coalesce(null,0) as Amount, coalesce(null,0) as Principal, coalesce(null,0) as Interest,
@totalOutstandingPrincipal := 		  
coalesce(round(sum(
	if (txn.transaction_type_enum = 1 /* disbursement */,
		coalesce(txn.amount,0.00), 
		coalesce(txn.principal_portion_derived,0.00) * -1)) 
			,2),0.00)  as 'Outstanding Principal',

@totalInterestIncome := 
coalesce(round(sum(
	if (txn.transaction_type_enum in (2,5,8) /* repayment, repayment at disbursal, recovery repayment */,
		coalesce(txn.interest_portion_derived,0.00), 
		0))
			,2),0.00) as 'Interest Income',

@totalWriteOff :=
coalesce(round(sum(
	if (txn.transaction_type_enum = 6 /* write-off */,
		coalesce(txn.principal_portion_derived,0.00), 
		0)) 
			,2),0.00) as 'Principal Write Off'
from m_office o
join m_office ounder on ounder.hierarchy like concat(o.hierarchy, '%')
                          and ounder.hierarchy like concat(${userhierarchy}, '%')
join m_client c on c.office_id = ounder.id
join m_loan l on l.client_id = c.id
join m_product_loan lp on lp.id = l.product_id
join m_loan_transaction txn on txn.loan_id = l.id
left join m_currency cur on cur.code = l.currency_code
where txn.is_reversed = false  
and txn.transaction_type_enum not in (10,11)
and o.id = ${Branch}
and txn.transaction_date < date(${startDate})

union all

select x.Transaction Date, x.Transaction Type, coalesce(x.Office,'-')as"Office", coalesce(x.Loan Officer,'-')as"Loan Officer", coalesce(x.Loan Account No,'-')as "Loan Account No", coalesce(x.Loan Product,'-')as"Loan Product" , coalesce(x.Currency,'-')as"Currency", 
	coalesce(x.Client Account No,'-')as "Client Account No", x.Client, coalesce(x.Amount,0)as "Amount", coalesce(x.Principal,0)as "Principal", coalesce(x.Interest,0)as"Interest",
cast(round( 
	if (x.transaction_type_enum = 1 /* disbursement */,
		@totalOutstandingPrincipal := @totalOutstandingPrincipal + x.Amount, 
		@totalOutstandingPrincipal := @totalOutstandingPrincipal - x.Principal) 
			,2) as decimal(19,2)) as 'Outstanding Principal',
cast(round(
	if (x.transaction_type_enum in (2,5,8) /* repayment, repayment at disbursal, recovery repayment */,
		@totalInterestIncome := @totalInterestIncome + x.Interest, 
		@totalInterestIncome) 
			,2) as decimal(19,2)) as 'Interest Income',
cast(round(
	if (x.transaction_type_enum = 6 /* write-off */,
		@totalWriteOff := @totalWriteOff + x.Principal, 
		@totalWriteOff) 
			,2) as decimal(19,2)) as 'Principal Write Off'
from
(select txn.transaction_type_enum, txn.id as txn_id, txn.transaction_date as 'Transaction Date', 
cast(
	coalesce(re.enum_message_property, concat('Unknown Transaction Type Value: ' , txn.transaction_type_enum)) 
	as char) as 'Transaction Type',
ounder.name as Office, lo.display_name as 'Loan Officer',
l.account_no  as 'Loan Account No', lp.name as 'Loan Product', 
coalesce(cur.display_symbol, l.currency_code) as Currency,
c.account_no as 'Client Account No', c.display_name as 'Client',
coalesce(txn.amount,0.00) as Amount,
coalesce(txn.principal_portion_derived,0.00) as Principal,
coalesce(txn.interest_portion_derived,0.00) as Interest
from m_office o
join m_office ounder on ounder.hierarchy like concat(o.hierarchy, '%')
                          and ounder.hierarchy like concat(${userhierarchy}, '%')
join m_client c on c.office_id = ounder.id
join m_loan l on l.client_id = c.id
left join m_staff lo on lo.id = l.loan_officer_id
join m_product_loan lp on lp.id = l.product_id
join m_loan_transaction txn on txn.loan_id = l.id
left join m_currency cur on cur.code = l.currency_code
left join r_enum_value re on re.enum_name = 'transaction_type_enum'
						and re.enum_id = txn.transaction_type_enum
where txn.is_reversed = false  
and txn.transaction_type_enum not in (10,11)
and o.id = ${Branch}
and (coalesce(l.loan_officer_id, -10) = ${Loan Officer} or "-1" = ${Loan Officer})
and txn.transaction_date >= date(${startDate})
and txn.transaction_date <= date(${endDate})
order by txn.transaction_date, txn.id) x
                              