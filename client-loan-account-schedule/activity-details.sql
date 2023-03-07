























SELECT 
det.dates 'Date',
coalesce(comments.Note,'-') Note,
det.Principle,
det.Interest,
det.Fees,
det.Penalty,
det.Total_Paid,
det.Outstanding_Amount
FROM (
SELECT mtx.id id,
mtx.loan_id,
mtx.transaction_date 'dates', 
coalesce(mtx.amount,0) Principle, 
coalesce(mtx.interest_portion_derived,0) Interest, 
coalesce(mtx.fee_charges_portion_derived,0) Fees, 
coalesce(mtx.penalty_charges_portion_derived,0) Penalty,
0.000000 Total_Paid,
(ml.principal_amount + ml.interest_charged_derived + ml.fee_charges_charged_derived + ml.penalty_charges_charged_derived) Outstanding_Amount
FROM
m_loan_transaction mtx
INNER JOIN m_loan ml on ml.id=mtx.loan_id
WHERE mtx.transaction_type_enum=1
AND ml.id=(select ml.id from m_loan ml where ml.account_no=${selectLoan}) 

UNION

SELECT mtx.id,
mtx.loan_id,
mtx.transaction_date 'dates', 
coalesce(mtx.principal_portion_derived,0) Principal, 
coalesce(mtx.interest_portion_derived,0) Interest, 
coalesce(mtx.fee_charges_portion_derived,0) Fees, 
coalesce(mtx.penalty_charges_portion_derived,0) Penalty,
mtx.amount Total_Paid,
Outs.outs Outstanding_Amount

FROM
m_loan_transaction mtx
INNER JOIN m_loan ml on ml.id=mtx.loan_id
INNER JOIN (select m.id outId,
(ml.principal_amount + ml.interest_charged_derived + ml.fee_charges_charged_derived + ml.penalty_charges_charged_derived - ml.interest_waived_derived - ml.fee_charges_waived_derived - ml.penalty_charges_waived_derived)-(m.amount + coalesce((select sum(amount)
from m_loan_transaction mt
where mt.id < m.id and mt.loan_id=(select ml.id from m_loan ml where ml.account_no=${selectLoan}) and mt.transaction_type_enum =2 and is_reversed=0),0) ) outs
from m_loan_transaction m
inner join m_loan ml on ml.id=m.loan_id
where m.transaction_type_enum =2
and m.loan_id=(select ml.id from m_loan ml where ml.account_no=${selectLoan})) Outs on Outs.outId=mtx.id

WHERE mtx.transaction_type_enum=2
and mtx.is_reversed=0
and ml.id=(select ml.id from m_loan ml where ml.account_no=${selectLoan})) det

LEFT JOIN 
 (SELECT a.id comment_id, coalesce(a.tid,(
SELECT MIN(mtx.id)
FROM m_loan_transaction mtx
WHERE mtx.loan_id=(select ml.id from m_loan ml where ml.account_no=${selectLoan}))) trx_id,
a.note note
FROM (
SELECT mn.id id,
 mn.loan_transaction_id tid,
		mn.loan_id lid,
		mn.note Note
FROM m_note mn
WHERE mn.id IN (
SELECT MAX(mn.id)
FROM m_note mn
WHERE mn.note_type_enum=200
GROUP BY mn.loan_id) UNION
SELECT mn2.id,
 mn2.loan_transaction_id,
 mn2.loan_id,
 mn2.note
FROM m_note mn2
WHERE mn2.note_type_enum=300) a
WHERE a.lid=(select ml.id from m_loan ml where ml.account_no=${selectLoan})
ORDER BY a.lid,a.id) 
comments ON comments.trx_id=det.id
WHERE det.dates between ${startDate} and ${endDate}                                                                                                                              