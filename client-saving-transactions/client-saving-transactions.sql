





select st.id as 'Transaction ID',
       st.transaction_date as 'Transaction Date',
       concat(': ',msp.name,'  (#',msa.account_no,')')as name_no ,
       concat(': ',IF(msa.client_id is NULL,(SELECT mg.display_name FROM m_group mg WHERE mg.id=msa.group_id),(SELECT mc.display_name FROM m_client mc WHERE mc.id=msa.client_id))) as client_name,
       re.enum_value as 'Transaction Type',
       coalesce(case st.transaction_type_enum
                  when 2 then st.amount
                  end ,0) as 'Debit',
       coalesce(case st.transaction_type_enum
                  when 1 then st.amount
                  when 3 then st.amount
                  end,0) as 'Credit',
       coalesce(st.running_balance_derived,0) as 'Balance',
       case st.is_reversed
           when 0 then 'No'
           else 'Yes'
           end as 'Reversed'
      from m_savings_account_transaction st
      inner join m_savings_account msa on msa.account_no=st.savings_account_id
      inner join m_savings_product msp on msp.id=msa.product_id
      inner join r_enum_value re
           on re.enum_id=st.transaction_type_enum and re.enum_name='savings_transaction_type_enum'
where msa.account_no=${savingsAccountId}
and (st.transaction_date between ${startDate} and ${endDate})
order by 2 desc,is_reversed                                                            