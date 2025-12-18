-- 窗口函数  行数不变，每一行返回一个值
--函数名() over ([PARTITON BY 分区字段][ORDER BY 排序字段][rows/range 窗口范围])

-- 常用窗口函数
create table sales (
       salesperson varchar2(20),
       amount number(4),
       sale_date date);
       
select * from sales ;

insert into sales values ('张三',100,date '2024-01-01');
insert into sales values ('张三',200,date '2024-01-02');
insert into sales values ('李四',150,date '2024-01-01');
insert into sales values ('李四',300,date '2024-01-02');
insert into sales values ('王五',150,date '2024-01-01');

update sales set amount = 250 where salesperson = '王五';
-- row_number():连续排名 1，2，3
-- rank()：跳跃排名 113，允许并列
-- dense_rank (): 密集排名 112 ，允许并列

select s.salesperson 
      ,s.amount
      ,s.sale_date
      ,row_number() over (order by s.amount desc) as rank_num
from sales s;

select s.salesperson 
      ,s.amount
      ,s.sale_date
      ,rank() over (order by s.amount desc) as rank_num
from sales s;

select s.salesperson 
      ,s.amount
      ,s.sale_date
      ,dense_rank() over (order by s.amount desc) as rank_num
from sales s;


-- 聚合函数+窗口
select s.salesperson 
      ,s.amount
      ,s.sale_date
      ,sum(amount) over (partition by s.salesperson) as person_total
      ,sum(amount) over () as all_total
from sales s;

--前后行比较
select s.salesperson 
      ,s.amount
      ,s.sale_date
      ,lag(s.amount,1,0) over (partition by s.salesperson order by s.sale_date) as pre_amount
      ,lead(s.amount,1,0) over (partition by s.salesperson order by s.sale_date) as next_amount
from sales s;

-- 每个人近两天的平均金额
select s.*
      ,AVG(s.amount) OVER (
           PARTITION BY s.salesperson 
           ORDER BY sale_date 
           ROWS BETWEEN 1 PRECEDING AND CURRENT ROW
       ) as avg_amount
from sales s;

-- 每个人金额排名第一的信息
select a.*
from (
    select s.*,
           DENSE_RANK() OVER (PARTITION BY s.salesperson ORDER BY s.sale_date desc) as amount_rank
    from sales s
) a
where a.amount_rank = 1;

-- 计算每个销售员的累计销售额
select salesperson, sale_date, amount,
       SUM(amount) OVER (
           PARTITION BY salesperson 
           ORDER BY sale_date 
           rows BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
       ) as cumulative_amount
from sales;

-- 不同窗口范围示例
ROWS BETWEEN 2 PRECEDING AND CURRENT ROW  -- 当前行及前2行
ROWS BETWEEN 1 PRECEDING AND 1 FOLLOWING  -- 前1行、当前行、后1行
RANGE BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW  -- 从开始到当前行
ROWS BETWEEN CURRENT ROW AND UNBOUNDED FOLLOWING  -- 当前行到最后


-- GROUP BY: 聚合，减少行数
select salesperson, sum(amount)
from sales
group by salesperson;  -- 返回3行

-- 窗口函数: 保持原行数
select salesperson, amount, 
       sum(amount) OVER (PARTITION BY salesperson) as total
from sales;  -- 返回5行

select max(amount) over (partition by s.salesperson) as max_amount,s.* 
from sales s;


--索引

--视图，虚拟表

--存储过程

--触发器

--事务控制

--性能优化技巧

--分区表

--实用函数与特性
