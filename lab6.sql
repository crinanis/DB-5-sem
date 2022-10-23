--1. Определите общий размер области SGA.
show sga;
select * from v$sga;

--2-3. Определите текущие размеры основных пулов SGA. Определите размеры гранулы для каждого пула.
show parameter pool
select component,
      current_size,
      max_size,
      granule_size from v$sga_dynamic_components where current_size>0;
      
--4. Определите объем доступной свободной памяти в SGA.
select current_size from v$sga_dynamic_free_memory;

--5. Определите размеры пулов КЕЕP, DEFAULT и RECYCLE буферного кэша.
select component, current_size 
from v$sga_dynamic_components 
where component like '%DEFAULT%'
  or  component like '%KEEP%'
  or  component like '%RECYCLE%';

--6. Создайте таблицу, которая будут помещаться в пул КЕЕP. Продемонстрируйте сегмент таблицы.
alter system set db_cache_size=400m scope=spfile;
alter system set db_keep_cache_size=100m scope=spfile;

select component, max_size, min_size, current_size 
from v$sga_dynamic_components 
where component like '%DEFAULT%'
  or  component like '%KEEP%'
  or  component like '%RECYCLE%';

create table TestTable6 (k int, s varchar(50)) storage(buffer_pool keep);

declare 
x int:=1;
BEGIN
while x<10000
  LOOP
  insert into TestTable6 values (x, 'orcl the best');
  x:=x+1;
  end loop;
END;

commit;

select * from TestTable6;

drop table TestTable;

--7. Создайте таблицу, которая будут кэшироваться в пуле default. Продемонстрируйте сегмент таблицы. 

create table TestTable7 (k int, s varchar(50)) storage(buffer_pool default);

declare 
x int:=1;
BEGIN
while x<10000
  LOOP
  insert into TestTable7 values (x, 'orcl the best');
  x:=x+1;
  end loop;
END;

commit;

select * from TestTable7;

select segment_name, segment_type, tablespace_name, buffer_pool 
from user_segments 
where segment_name in('TESTTABLE6', 'TESTTABLE7');

--8. Найдите размер буфера журналов повтора.
show parameter log_buffer;

--9. Найдите 10 самых больших объектов в разделяемом пуле.
select component, min_size, current_size, max_size 
from v$sga_dynamic_components 
where component = 'shared pool';

--select only 10 rows the max result in shared pool
select pool, name, bytes 
from v$sgastat 
where pool = 'shared pool'
order by bytes desc fetch first 10 rows only;

--10. Найдите размер свободной памяти в большом пуле.
select sum(decode(name,'free memory',bytes)) 
from v$sgastat 
where pool = 'large pool';


--11-12. Получите перечень текущих соединений с инстансом. Определите режимы текущих соединений с инстансом (dedicated, shared).
select username, service_name, server, osuser, machine, program 
from v$session 
where username is not null;
