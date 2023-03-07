


SELECT * FROM (
select
Y.Processor
,Y.Branch
,Y.Product
,Y.Currency
,Y.Client Name
,Y.Svgs_Act
,Y.Txn Id
,Y.Txn Type
,concat(
coalesce(trim(Y.CheqNo),' ')
,coalesce(trim(Y.Description),' ') ) as 'Descriptions'
,Y.Value Date
,Y.Debit
,Y.Credit
,Y.Running Total

from (
select Y.*
,Case
when (if(@prevGLCodeDd != Svgs_Act,  (@totalCr := Credit)- (@totalDb := Debit) ,(@totalCr := @totalCr + Credit)-(@totalDb := @totalDb + Debit))) is null then null
when (@prevGLCodeDb := Svgs_Act) is null then null
when Description ='Balance Brought Forward' then (@totalCr := 0 + Credit)-(@totalDb := 0 + Debit)
else cast((@totalCr - @totalDb ) as decimal(19,6)) end as 'Running Total'

from (
SELECT
@rownum := @rownum + 1 AS Rank
,Y.*
FROM (

select 
sa.id
,o.name as 'Branch'
,null as 'Txn Id'
,null  as appuserId
,null as 'Processor'
,sa.client_id as 'clientId'
,c.display_name as 'Client Name'
,sp.name as 'Product'
,oc.name as 'Currency'
,sa.account_no as 'Svgs_Act'
,null as 'Value Date'
,null as 'txnTypeId'
,null as 'txn Type' 
,null as payment_detail_id 
,null as 'CheqNo'
,'Previous Balances' as 'Description'
,(SELECT coalesce(SUM(sat.amount),0) FROM m_savings_account_transaction sat WHERE sat.savings_account_id = sa.id AND sat.transaction_type_enum in (2,4,5,7,17,19) AND sat.is_reversed = 0 AND sat.transaction_date < ${startDate} ) as 'Debit'
,(SELECT coalesce(SUM(sat.amount),0) FROM m_savings_account_transaction sat WHERE sat.savings_account_id = sa.id AND sat.transaction_type_enum in (1,3,8,16) AND sat.is_reversed = 0 AND sat.transaction_date < ${startDate}) as 'Credit'


from m_savings_account sa
join m_client c on c.id = sa.client_id
join m_office o on o.id = c.office_id
join m_savings_product sp on sp.id = sa.product_id
join m_organisation_currency oc on oc.code = sp.currency_code
where sa.account_no = ${savingsAccountNo} 
UNION ALL
select 
sa.id 
,o.name as 'Branch'
,sat.id as 'Txn Id'
,case when sat.appuser_id is null then 1 else sat.appuser_id end  as appuserId
,case when sat.appuser_id is null then 'System' else s.display_name end as 'Processor'
,sa.client_id as 'clientId'
,c.display_name as 'Client Name'
,sp.name as 'Product'
,oc.name as 'Currency'
,sa.account_no as 'Svgs_Act'
,sat.transaction_date as 'Value Date'
,sat.transaction_type_enum as 'txnTypeId'
,ev.enum_value as 'txn Type' 
,sat.payment_detail_id 
,case when pd.check_number = '' or pd.check_number is null then null else concat('ChqNo:- ', trim(pd.check_number),'  ') end as 'CheqNo'
,concat(
coalesce(trim(att.description),'') 
,coalesce(concat(' from SvgsAct - ',atd.from_savings_account_id),'') 
,coalesce(concat(' from LoanAct - ',att.from_loan_transaction_id),'')
,coalesce(concat(' to SvgsAct - ',atd.to_savings_account_id),'') 
,coalesce(concat(' to LoanAct - ',atd.to_loan_account_id),'')
,coalesce(ch.name,'')
) as 'Description'
,case when sat.transaction_type_enum in (2,4,5,7,17,19) then sat.amount else 0 end as 'Debit'
,case when sat.transaction_type_enum in (1,3,8,16) then sat.amount else 0 end as 'Credit'


from m_savings_account sa
join m_client c on c.id = sa.client_id
join m_office o on o.id = c.office_id
join m_savings_account_transaction sat on sat.savings_account_id = sa.id
join m_savings_product sp on sp.id = sa.product_id
join m_organisation_currency oc on oc.code = sp.currency_code
join r_enum_value ev on ev.enum_name ='savings_transaction_type_enum' and ev.enum_id = transaction_type_enum
left join m_appuser au on au.id = sat.appuser_id
left join m_staff s on s.id = au.staff_id
left join m_payment_detail pd on pd.id = sat.payment_detail_id
left join m_account_transfer_transaction att on (att.from_savings_transaction_id = sat.id or att.to_savings_transaction_id = sat.id)
left join m_account_transfer_details atd on atd.id = att.account_transfer_details_id
left join m_savings_account_charge_paid_by sacpb on sacpb.savings_account_transaction_id = sat.id 
left join m_savings_account_charge sac on sac.id = sacpb.savings_account_charge_id
left join m_charge ch on ch.id = sac.charge_id

where sa.account_no = ${savingsAccountNo} 
and sat.is_reversed = 0
AND sat.transaction_date >= ${startDate}
AND sat.transaction_date < DATE_ADD(${endDate}, INTERVAL 1 DAY)

order BY Value Date, Txn Id

)Y ,(SELECT @rownum := 0 as rowId) r
)Y
Join (select @totalDb:= 0, @prevGLCodeDr:=null) v
Join (select @totalCr:= 0, @prevGLCodeCr:=null) w )Y  order by Y.Rank
)X                                                       