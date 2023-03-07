




SELECT sa.account_no AS 'Acc No', IF(sa.client_id is NULL,(
SELECT mg.display_name
FROM m_group mg
WHERE mg.id=sa.group_id),(
SELECT mc.display_name
FROM m_client mc
WHERE mc.id=sa.client_id)) AS 'client/Group Name',coalesce((
SELECT sat1.running_balance_derived
FROM m_savings_account_transaction sat1
WHERE sat1.savings_account_id=sa.id AND sat1.transaction_date < ${fromDate}
ORDER BY sat1.transaction_date DESC,sat1.created_date DESC,sat1.id DESC
LIMIT 1),0) AS 'Balance B/F', SUM(IF(ev.enum_type = 0,sat.amount,0)) AS Deposit, SUM(IF(ev.enum_type = 1,sat.amount,0)) AS Withdrawal,(
SELECT sat1.running_balance_derived
FROM m_savings_account_transaction sat1
WHERE sat1.savings_account_id=sa.id AND sat1.transaction_date <= ${toDate}
ORDER BY sat1.transaction_date DESC,sat1.created_date DESC,sat1.id DESC
LIMIT 1) AS 'Balance',
msp.name AS 'Product'
FROM m_office mo
 JOIN m_office ounder ON ounder.hierarchy LIKE CONCAT(mo.hierarchy, '%') AND ounder.hierarchy like CONCAT(${userhierarchy}, '%')
 inner join (select sav.id said,sav.client_id cid,sav.group_id gid,of.id oid from m_savings_account sav
left join m_client mc on mc.id=sav.client_id
left join m_group gr on gr.id=sav.group_id
inner join m_office of on of.id=if(mc.id is null,gr.office_id,mc.office_id)) ofid on ofid.oid=ounder.id
INNER JOIN m_savings_account sa on sa.id=ofid.said
INNER JOIN m_savings_account_transaction sat ON sat.savings_account_id = sa.id
INNER JOIN r_enum_value ev ON ev.enum_name = 'savings_transaction_type_enum' AND ev.enum_id = sat.transaction_type_enum
INNER JOIN m_savings_product msp on msp.id=sa.product_id
WHERE #sa.client_id=27 AND 
mo.id=${selectOffice}
AND (msp.id=${selectProduct} or ${selectProduct}=-1)
AND sat.is_reversed=0 AND sat.transaction_date BETWEEN ${fromDate} AND ${toDate}
GROUP BY sa.account_no
ORDER BY sa.product_id,sa.account_no                             