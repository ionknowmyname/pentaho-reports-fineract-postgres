






select coalesce(f.name, '-') as Fund,  coalesce(cur.display_symbol, l.currency_code) as Currency, 
round(sum(l.principal_amount), 4) as disbursed_amount
from m_office ounder 
join m_client c on c.office_id = ounder.id
join m_loan l on l.client_id = c.id
join m_currency cur on cur.code = l.currency_code
left join m_fund f on f.id = l.fund_id
where disbursedon_date between ${startDate} and ${endDate}
and (coalesce(l.fund_id, -10) = ${fundId} or -1 = ${fundId})
  and ounder.hierarchy like concat(${userhierarchy}, '%')
  and (l.currency_code = ${CurrencyId} or '-1' = ${CurrencyId})

group by coalesce(f.name, '-') , coalesce(cur.display_symbol, l.currency_code)
order by coalesce(f.name, '-') , coalesce(cur.display_symbol, l.currency_code)                                          