--1.	Найдите на компьютере конфигурационные файлы SQLNET.ORA и TNSNAMES.ORA и ознакомьтесь с их содержимым.
--/u01/app/oracle/product/12.2.0.1/dbhome_1/network/admin/tnsnames.ora
--/u01/app/oracle/product/12.2.0.1/dbhome_1/network/admin/sqlnet.ora

--2.	Соединитесь при помощи sqlplus с Oracle как пользователь SYSTEM, получите перечень параметров экземпляра Oracle.
select name, description from v$parameter;

--3.	Соединитесь при помощи sqlplus с подключаемой базой данных как пользователь SYSTEM, получите список табличных пространств, файлов табличных пространств, ролей и пользователей.
-- sqlplus
-- oracle
-- connect system/oracle@localhost:1521/orcl
select * from dba_tablespaces;
select * from dba_data_files;
select * from dba_roles;
select * from dba_users;

--4.	Ознакомьтесь с параметрами в HKEY_LOCAL_MACHINE/SOFTWARE/ORACLE на вашем компьютере.
--regedit

--5.	Запустите утилиту Oracle Net Manager и подготовьте строку подключения с именем имя_вашего_пользователя_SID, где SID – идентификатор подключаемой базы данных. 

--6.	Подключитесь с помощью sqlplus под собственным пользователем и с применением подготовленной строки подключения. 
   
-- connect U1_BKA_PDB/12345@localhost:1521/orcl1

--7.	Выполните select к любой таблице, которой владеет ваш пользователь. 
--8.	Ознакомьтесь с командой HELP.Получите справку по команде TIMING. Подсчитайте, сколько времени длится select к любой таблице.

-- select * from lab8_table;

create table lab8_table
( 
  idkey int primary key,
  someText varchar(50)
);

insert into lab8_table values (1, 'frst');
insert into lab8_table values (3, 'thrd');
commit;

set timing on
select * from lab8_table;
--time: 0.117 sec
set timing off

--9.	Ознакомьтесь с командой DESCRIBE.Получите описание столбцов любой таблицы.
describe la8_table

--10.	Получите перечень всех сегментов, владельцем которых является ваш пользователь.
select * from user_segments;

--11.	Создайте представление, в котором получите количество всех сегментов, количество экстентов, блоков памяти и размер в килобайтах, которые они занимают.

create view lab8_view as 
select count(*)  segments_count, sum(extents) extents_count,sum(blocks) bloks_count, sum(bytes) memory_size from user_segments;

SELECT * FROM lab8_view;
