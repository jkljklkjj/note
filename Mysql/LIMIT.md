```sql
select p.id, p.name, p.age, o.order_id, o.order_date, o.amount, max(p.order_date) as max_order_date
from people p
left join orders o
on p.id = o.person_id
group by p.name
order by p.age;
```

| id  | name    | age | order_id | order_date | amount | max_order_date |
| --- | ------- | --- | -------- | ---------- | ------ | -------------- |
| 5   | Eve     | 22  | 5        | 2023-05-30 | 250.00 | 2023-05-30     |
| 1   | Alice   | 25  | 1        | 2023-01-10 | 100.00 | 2023-02-15     |
| 4   | David   | 28  | NULL     | NULL       | NULL   | NULL           |
| 2   | Bob     | 30  | 3        | 2023-03-20 | 150.00 | 2023-03-20     |
| 3   | Charlie | 35  | 4        | 2023-04-25 | 300.00 | 2023-04-25     |
通过limit限制得到的结果
```sql
select p.id, p.name, p.age, o.order_id, o.order_date, o.amount, max(p.order_date) as max_order_date
from people p
left join orders o
on p.id = o.person_id
group by p.name
order by p.age
limit 3;
```

| id  | name    | age | order_id | order_date | amount | max_order_date |
| --- | ------- | --- | -------- | ---------- | ------ | -------------- |
| 5   | Eve     | 22  | 5        | 2023-05-30 | 250.00 | 2023-05-30     |
| 1   | Alice   | 25  | 1        | 2023-01-10 | 100.00 | 2023-02-15     |
| 4   | David   | 28  | NULL     | NULL       | NULL   | NULL           |