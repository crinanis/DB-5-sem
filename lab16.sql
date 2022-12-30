ALTER SESSION SET nls_date_format='dd-mm-yyyy hh24:mi:ss';

--1.	Создайте таблицу T_RANGE c диапазонным секционированием. Используйте ключ секционирования типа NUMBER. 
create table T_Range
(
  id number,
  time_id date
)
partition by range(id)
(
  partition p1 values less than (100),
  partition p2 values less than (200),
  partition p3 values less than (300),
  partition pmax values less than (maxvalue)
);

insert into T_Range(id, time_id) values(50,'01-02-2018');
insert into T_range(id, time_id) values(105,'01-02-2017');
insert into T_range(id, time_id) values(205,'01-02-2016');
insert into T_range(id, time_id) values(305,'01-02-2015');
insert into T_range(id, time_id) values(405,'01-02-2015');
commit;
select * from T_range partition(p1);
select * from T_range partition(p2);
select * from T_range partition(p3);
select * from T_range partition(pmax);

--2.	Создайте таблицу T_INTERVAL c интервальным секционированием. Используйте ключ секционирования типа DATE.
create table T_Interval
(
  id number,
  time_id date
)
partition by range(time_id) interval (numtoyminterval(1,'month'))
(
  partition p0 values less than  (to_date ('1-12-2009', 'dd-mm-yyyy')),
  partition p1 values less than  (to_date ('1-12-2015', 'dd-mm-yyyy')),
  partition p2 values less than  (to_date ('1-12-2018', 'dd-mm-yyyy'))
);

insert into T_Interval(id, time_id) values(50,'01-02-2008');
insert into T_Interval(id, time_id) values(105,'01-01-2009');
insert into T_Interval(id, time_id) values(105,'01-01-2014');
insert into T_Interval(id, time_id) values(205,'01-01-2015');
insert into T_Interval(id, time_id) values(305,'01-01-2016');
insert into T_Interval(id, time_id) values(405,'01-01-2018');
insert into T_Interval(id, time_id) values(505,'01-01-2019');
commit;

select * from T_Interval partition(p0);
select * from T_Interval partition(p1);
select * from T_Interval partition(p2);


--3.	Создайте таблицу T_HASH c хэш-секционированием. Используйте ключ секционирования типа VARCHAR2.
create table T_hash
(
  str varchar2 (50),
  id number
)
partition by hash (str)
(
  partition k1,
  partition k2,
  partition k3,
  partition k4
);

insert into T_hash (str,id) values('string1', 1);
insert into T_hash (str,id) values('string2', 2);
insert into T_hash (str,id) values('string3', 3);
insert into T_hash (str,id) values('string4', 4);
insert into T_hash (str,id) values('string5', 7);
commit;
select * from T_hash partition(k1);
select * from T_hash partition(k2);
select * from T_hash partition(k3);
select * from T_hash partition(k4);

--4.	Создайте таблицу T_LIST со списочным секционированием. Используйте ключ секционирования типа CHAR.
create table T_list
(
  obj char(3)
)
partition by list (obj)
(
  partition p1 values ('a'),
  partition p2 values ('b'),
  partition p3 values ('c'),
  partition p4 values (default)
);

--5.	Введите с помощью операторов INSERT данные в таблицы T_RANGE, T_INTERVAL, T_HASH, T_LIST. Данные должны быть такими, чтобы они разместились по всем секциям. Продемонстрируйте это с помощью SELECT запроса. 
insert into  T_list(obj) values('a');
insert into  T_list(obj) values('b');
insert into  T_list(obj) values('c');
insert into  T_list(obj) values('d');
insert into  T_list(obj) values('e');
commit;
select * from T_list partition (p1);
select * from T_list partition (p2);
select * from T_list partition (p3);
select * from T_list partition (p4);

--6.	Продемонстрируйте для всех таблиц процесс перемещения строк между секциями, при изменении (оператор UPDATE) ключа секционирования.
alter table T_list enable row movement;
update T_list partition(p1) set obj='b' where obj = 'a';
select * from T_list partition(p3);
select * from T_list;

--7.	Для одной из таблиц продемонстрируйте действие оператора ALTER TABLE MERGE.
alter table T_Range merge partitions p1,p2 into partition p5;
select * from T_Range partition(p5);

--8.	Для одной из таблиц продемонстрируйте действие оператора ALTER TABLE SPLIT.
alter table T_Interval split partition p2 at (to_date ('1-06-2018', 'dd-mm-yyyy'))
  into (partition p6, partition p5);
drop table T_Interval;
select * from t_interval partition (p5);
select * from t_interval partition (p6);

--9.	Для одной из таблиц продемонстрируйте действие оператора ALTER TABLE EXCHANGE.
create table T_list1(obj char(3));
alter table T_list exchange partition  p2 with table T_list1 without validation;

select * from T_list partition (p2);
select * from T_list1;

select * from USER_PART_TABLES;
select * from user_segments;
select * from user_objects;