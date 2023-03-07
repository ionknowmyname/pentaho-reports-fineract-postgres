


select c.id, s.display_name from m_cashiers as c left join m_staff as s on c.staff_id = s.id where c.teller_id = ${tellerId}                  