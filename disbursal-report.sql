


select l.loan_type_enum
,ounder.id branch
,0 as cid
,0 as gid
,l.account_no accountNo
,coalesce(mpd.receipt_number,'NA') receiptNo
,coalesce(c.mobile_no,'NA') mobileNo
,c.display_name clientName
,l.principal_disbursed_derived disbAmount
,coalesce(t2.amount,0) fees
,mp.name product
,l.disbursedon_date disbDate
,date(t.created_date) createdDate
,case l.loan_type_enum
	when 1 then 'Individual'
	when 2 then 'Group'
	when 3 then 'JLG'
	end as loanType
,coalesce(s.display_name,'NA') loanOfficer
,concat(u.firstname,' ',u.lastname) mifosUser
,ounder.name branchName
,'NA' as groupName
,'NA' as centerName
from m_office o 
join m_office ounder on ounder.hierarchy like concat(o.hierarchy, '%') 
and ounder.hierarchy like concat(${userhierarchy}, '%')
inner join m_client c on c.office_id=ounder.id
inner join m_loan l on l.client_id=c.id and l.loan_type_enum=1 and l.loan_status_id in (300,600,601,700)
inner join r_enum_value ev on ev.enum_id=l.loan_status_id and ev.enum_name='loan_status_id'
left join m_code_value gn on gn.id=c.gender_cv_id
left join m_staff s on s.id=l.loan_officer_id
left join m_fund f on f.id=l.fund_id
inner join m_product_loan mp on mp.id=l.product_id
inner join m_loan_transaction t on t.loan_id=l.id and t.transaction_type_enum=1 and t.is_reversed=0
left join m_loan_transaction t2 on t2.loan_id=l.id and t2.transaction_type_enum=5 and t.is_reversed=0
left join m_appuser u on u.id=t.appuser_id
left join m_payment_detail mpd on mpd.id=t.payment_detail_id
where o.id=${branch}
and l.disbursedon_date between ${fromDate} and ${toDate}

union

select l.loan_type_enum
,ounder.id branch
,coalesce(cn.id,0) as cid
,gr.id as gid
,l.account_no accountNo
,coalesce(mpd.receipt_number,'NA') receiptNo
,coalesce(c.mobile_no,'NA') mobileNo
,c.display_name name
,l.principal_disbursed_derived disbAmount
,coalesce(t2.amount,0) fees
,mp.name product
,l.disbursedon_date disbDate
,date(t.created_date) createdDate
,case l.loan_type_enum
	when 1 then 'Individual'
	when 2 then 'Group'
	when 3 then 'JLG'
	end as loanType
,coalesce(s.display_name,'NA') loanOfficer
,concat(u.firstname,' ',u.lastname) mifosUser
,ounder.name branchName
,gr.display_name as groupName
,coalesce(cn.display_name,'NA') as centerName
from m_office o 
join m_office ounder on ounder.hierarchy like concat(o.hierarchy, '%') 
and ounder.hierarchy like concat(${userhierarchy}, '%')
inner join m_client c on c.office_id=ounder.id
inner join m_group_client mgc on mgc.client_id=c.id
inner join m_group gr on gr.id=mgc.group_id
left join m_group cn on cn.id=gr.parent_id
inner join m_loan l on l.client_id=c.id and l.group_id=gr.id and l.loan_type_enum=3 and l.loan_status_id in (300,600,601,700)
inner join r_enum_value ev on ev.enum_id=l.loan_status_id and ev.enum_name='loan_status_id'
left join m_code_value gn on gn.id=c.gender_cv_id
left join m_staff s on s.id=l.loan_officer_id
left join m_fund f on f.id=l.fund_id
inner join m_product_loan mp on mp.id=l.product_id
inner join m_loan_transaction t on t.loan_id=l.id and t.transaction_type_enum=1 and t.is_reversed=0
left join m_loan_transaction t2 on t2.loan_id=l.id and t2.transaction_type_enum=5 and t.is_reversed=0
left join m_appuser u on u.id=t.appuser_id
left join m_payment_detail mpd on mpd.id=t.payment_detail_id
where o.id=${branch}
and l.disbursedon_date between ${fromDate} and ${toDate}

union

select l.loan_type_enum
,ounder.id branch
,coalesce(cn.id,0) as cid
,gr.id as gid
,l.account_no accountNo
,coalesce(mpd.receipt_number,'NA') receiptNo
,'NA' mobileNo
,'NA' as clientName
,l.principal_disbursed_derived  disbAmount
,coalesce(t2.amount,0) fees
,mp.name product
,l.disbursedon_date disbDate
,date(t.created_date) createdDate
,case l.loan_type_enum
	when 1 then 'Individual'
	when 2 then 'Group'
	when 3 then 'JLG'
	end as loanType
,coalesce(s.display_name,'NA') loanOfficer
,concat(u.firstname,' ',u.lastname) mifosUser
,ounder.name branchName
,gr.display_name as groupName
,coalesce(cn.display_name,'NA') as centerName
from m_office o 
join m_office ounder on ounder.hierarchy like concat(o.hierarchy, '%') 
and ounder.hierarchy like concat(${userhierarchy}, '%')
inner join m_group gr on gr.office_id=ounder.id
left join m_group cn on cn.id=gr.parent_id
inner join m_loan l on l.group_id=gr.id and l.loan_type_enum=2 and l.loan_status_id in (300,600,601,700)
inner join r_enum_value ev on ev.enum_id=l.loan_status_id and ev.enum_name='loan_status_id'
left join m_staff s on s.id=l.loan_officer_id
left join m_fund f on f.id=l.fund_id
inner join m_product_loan mp on mp.id=l.product_id
inner join m_loan_transaction t on t.loan_id=l.id and t.transaction_type_enum=1 and t.is_reversed=0
left join m_loan_transaction t2 on t2.loan_id=l.id and t2.transaction_type_enum=5 and t.is_reversed=0
left join m_appuser u on u.id=t.appuser_id
left join m_payment_detail mpd on mpd.id=t.payment_detail_id
where o.id=${branch}
and l.disbursedon_date between ${fromDate} and ${toDate}

order by 1,2,3,4,12                                    