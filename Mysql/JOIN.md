配合[[ON]]进行使用

left join: 保留左表所有行，即使on条件与右表无匹配的行也保存

现在有两个表，people和order表

`people` 表数据

|id|name|age|
|---|---|---|
|1|Alice|25|
|2|Bob|30|
|3|Charlie|35|
|4|David|28|
|5|Eve|22|

`orders` 表数据

|order_id|person_id|order_date|amount|
|---|---|---|---|
|1|1|2023-01-10|100.00|
|2|1|2023-02-15|200.00|
|3|2|2023-03-20|150.00|
|4|3|2023-04-25|300.00|
|5|5|2023-05-30|250.00|
```sql
select p.id, p.name, p.age, o.order_id, o.order_date, o.amount
from people p
left join orders o
on p.id = o.person_id;
```

首先，会从左表 (`people`) 中逐行取出数据，然后尝试与右表 (`orders`) 进行匹配
若符合on里面的要求，则组合成一行，注意左表的一行可以匹配右表多行

|id|name|age|order_id|order_date|amount|
|---|---|---|---|---|---|
|1|Alice|25|1|2023-01-10|100.00|
|1|Alice|25|2|2023-02-15|200.00|
|2|Bob|30|3|2023-03-20|150.00|
|3|Charlie|35|4|2023-04-25|300.00|
|4|David|28|NULL|NULL|NULL|
|5|Eve|22|5|2023-05-30|250.00|