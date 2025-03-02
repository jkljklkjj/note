我们用``employee``表作为案例

| id  | name    | department | salary  | hire_date  | manager_id |
| --- | ------- | ---------- | ------- | ---------- | ---------- |
| 1   | Alice   | HR         | 6000.00 | 2020-01-15 | NULL       |
| 2   | Bob     | IT         | 7500.00 | 2019-05-10 | 1          |
| 3   | Charlie | Finance    | 8000.00 | 2018-11-20 | 1          |
| 4   | David   | IT         | 7000.00 | 2021-03-25 | 2          |
| 5   | Eve     | HR         | 6500.00 | 2022-07-30 | 1          |

从employee表中获取所有数据
```sql
select * from employee
```

|id|name|department|salary|hire_date|manager_id|
|---|---|---|---|---|---|
|1|Alice|HR|6000.00|2020-01-15|NULL|
|2|Bob|IT|7500.00|2019-05-10|1|
|3|Charlie|Finance|8000.00|2018-11-20|1|
|4|David|IT|7000.00|2021-03-25|2|
|5|Eve|HR|6500.00|2022-07-30|1|

以某查询结果为临时表，获取表中的所有数据
注意临时表后面要加上别名
```sql
select * from
(
select name from employee
limit 3
) as tmp
```

子查询 `SELECT name FROM employees LIMIT 3` 的结果是：

| name    |
| ------- |
| Alice   |
| Bob     |
| Charlie |

外部查询 `SELECT * FROM (子查询) AS temp_table` 的结果是：

| name    |
| ------- |
| Alice   |
| Bob     |
| Charlie |
