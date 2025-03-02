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
加入以name为分组
```sql
select p.id, p.name, p.age, o.order_id, o.order_date, o.amount
from people p
left join orders o
on p.id = o.person_id
group by p.name;
```

后面会把所有p.name相等的行组合成一个集合，这里的第一行和第二行属于一个集合
注意查询的时候，只会显示集合第一行，实际上是集合

| id  | name    | age | order_id | order_date | amount |
| --- | ------- | --- | -------- | ---------- | ------ |
| 1   | Alice   | 25  | 1        | 2023-01-10 | 100.00 |
| 1   |         | 25  | 2        | 2023-02-15 | 200.00 |
| 2   | Bob     | 30  | 3        | 2023-03-20 | 150.00 |
| 3   | Charlie | 35  | 4        | 2023-04-25 | 300.00 |
| 4   | David   | 28  | NULL     | NULL       | NULL   |
| 5   | Eve     | 22  | 5        | 2023-05-30 | 250.00 |

假如我们没有应用分组，使用聚合函数
```sql
select p.id, p.name, p.age, o.order_id, o.order_date, o.amount, max(p.order_date) as max_order_date
from people p
left join orders o
on p.id = o.person_id;
```

| id  | name    | age | order_id | order_date | amount | max_order_date |
| --- | ------- | --- | -------- | ---------- | ------ | -------------- |
| 1   | Alice   | 25  | 1        | 2023-01-10 | 100.00 | 2023-05-30     |
| 1   | Alice   | 25  | 2        | 2023-02-15 | 200.00 | 2023-05-30     |
| 2   | Bob     | 30  | 3        | 2023-03-20 | 150.00 | 2023-05-30     |
| 3   | Charlie | 35  | 4        | 2023-04-25 | 300.00 | 2023-05-30     |
| 4   | David   | 28  | NULL     | NULL       | NULL   | 2023-05-30     |
| 5   | Eve     | 22  | 5        | 2023-05-30 | 250.00 | 2023-05-30     |
可以看到max_order_date为所有人的最大order_date

但是分组后，再应用
```sql
select p.id, p.name, p.age, o.order_id, o.order_date, o.amount, max(p.order_date) as max_order_date
from people p
left join orders o
on p.id = o.person_id
group by p.name;
```

| id  | name    | age | order_id | order_date | amount | max_order_date |
| --- | ------- | --- | -------- | ---------- | ------ | -------------- |
| 1   | Alice   | 25  | 1        | 2023-01-10 | 100.00 | 2023-02-15     |
| 2   | Bob     | 30  | 3        | 2023-03-20 | 150.00 | 2023-03-20     |
| 3   | Charlie | 35  | 4        | 2023-04-25 | 300.00 | 2023-04-25     |
| 4   | David   | 28  | NULL     | NULL       | NULL   | NULL           |
| 5   | Eve     | 22  | 5        | 2023-05-30 | 250.00 | 2023-05-30     |
可以看到，max_order_date只包含了每个集合的结果
可以说，分组前的聚合将所有数据视为一个大集合