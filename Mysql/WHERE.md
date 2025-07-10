我们利用[[JOIN]]的结果进行讲解
```sql
select p.id, p.name, p.age, o.order_id, o.order_date, o.amount
from people p
left join orders o
on p.id = o.person_id;
```

| id  | name    | age | order_id | order_date | amount |
| --- | ------- | --- | -------- | ---------- | ------ |
| 1   | Alice   | 25  | 1        | 2023-01-10 | 100.00 |
| 1   | Alice   | 25  | 2        | 2023-02-15 | 200.00 |
| 2   | Bob     | 30  | 3        | 2023-03-20 | 150.00 |
| 3   | Charlie | 35  | 4        | 2023-04-25 | 300.00 |
| 4   | David   | 28  | NULL     | NULL       | NULL   |
| 5   | Eve     | 22  | 5        | 2023-05-30 | 250.00 |

然后加上where
```sql
select p.id, p.name, p.age, o.order_id, o.order_date, o.amount
from people p
left join orders o
on p.id = o.person_id
where name = 'Alice';
```

|id|name|age|order_id|order_date|amount|
|---|---|---|---|---|---|
|1|Alice|25|1|2023-01-10|100.00|
|1|Alice|25|2|2023-02-15|200.00|