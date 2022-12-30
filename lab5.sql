--1. Получите список всех файлов табличных пространств (перманентных  и временных).
select tablespace_name, contents from DBA_TABLESPACES;

--2. Создайте табличное пространство с именем XXX_QDATA (10m). При создании установите его в состояние offline. 
-- Затем переведите табличное пространство в состояние online. Выделите пользователю XXX квоту 2m в пространстве XXX_QDATA. 
--От имени XXX в  пространстве XXX_T1создайте таблицу из двух столбцов, один из которых будет являться первичным ключом. В таблицу добавьте 3 строки.
create tablespace BKA_QDATA
  datafile '/home/oracle/.sqldeveloper/labs/BKA_QDATA.dbf'
  size 10 M
  offline;
  
 --переведите пр-во в сост online 
alter tablespace BKA_QDATA online;


--созд роль (чтобы дать юзеру, к-му надо выдел квоту)
create role myrole;
grant create session,
      create table, 
      create view, 
      create procedure,
      drop any table,
      drop any view,
      drop any procedure to myrole;    
grant create session to myrole;
commit;


--созд профиль
create profile myprofile limit
    password_life_time 180      --кол-во дней жизни пароля
    sessions_per_user 3         --кол-во сессий для юзера
    failed_login_attempts 7     --кол-во попыток ввода
    password_lock_time 1        --кол-во дней блока после ошибок
    password_reuse_time 10      --через скок дней можно повторить пароль
    password_grace_time default --кол-во дней предупрежд.о смене пароля
    connect_time 180            --время соед (мин)
    idle_time 30 ;              --кол-во мин простоя 


--созд юзера
create user BUK identified by 12345
default tablespace BKA_QDATA quota unlimited on BKA_QDATA
profile myprofile
account unlock;


--выдел юзеру квоту 2м в CJA_QDATA
alter user BUK quota 2 m on BKA_QDATA;
grant myrole to BUK;


--от имени юзера BUK(12345) в BKA_QDATA созд таблицу BUK_T1

create table BUK_T1(
id number(15) PRIMARY KEY,
name varchar2(10))
tablespace BKA_QDATA;

insert into BUK_T1 values(1, 'BAZ');
insert into BUK_T1 values(2, 'IBS');
insert into BUK_T1 values(3, 'SRG');



--3. Получите список сегментов табличного пространства  XXX_QDATA. Определите сегмент таблицы XXX_T1. Определите остальные сегменты.
--cja
select segment_name, segment_type from DBA_SEGMENTS where tablespace_name='BKA_QDATA';

--4. Удалите (DROP) таблицу XXX_T1. Получите список сегментов табличного пространства  XXX_QDATA. Определите сегмент таблицы XXX_T1. Выполните SELECT-запрос к представлению USER_RECYCLEBIN, поясните результат.

drop table BUK_T1;

--cja (список сегментов)
select segment_name from DBA_SEGMENTS where tablespace_name='BKA_QDATA';

--lr5 (запрос к предст)
select * from user_recyclebin;


--lr5

--5. Восстановите (FLASHBACK) удаленную таблицу. 
flashback table BUK_T1 to before drop;

--6. Выполните PL/SQL-скрипт, заполняющий таблицу XXX_T1 данными (10000 строк). 
BEGIN
  FOR k IN 4..10004
  LOOP
    insert into BUK_T1 values(k, 'A');
  END LOOP;
  COMMIT;
END;


--7. Определите сколько в сегменте таблицы XXX_T1 экстентов, их размер в блоках и байтах. Получите перечень всех экстентов. 
select extent_id, blocks, bytes from DBA_EXTENTS where SEGMENT_NAME='BUK_T1';

--8. Удалите табличное пространство XXX_QDATA и его файл. 
drop tablespace BKA_QDATA including contents and datafiles;

--9. Получите перечень всех групп журналов повтора. Определите текущую группу журналов повтора.
SELECT group#, sequence#, bytes, members, status, first_change# FROM V$LOG;

--10. Получите перечень файлов всех журналов повтора инстанса.
SELECT * FROM V$LOGFILE;


--12. EX. Создайте дополнительную группу журналов повтора с тремя файлами журнала. 
-- Убедитесь в наличии группы и файлов, а также в работоспособности группы (переключением). Проследите последовательность SCN. 
alter database add logfile group 4 '/home/oracle/.sqldeveloper/labs/REDO04.LOG' 
                                                size 50 m blocksize 512;
alter database add logfile member '/home/oracle/.sqldeveloper/labs/REDO041.LOG'  to group 4;
alter database add logfile member '/home/oracle/.sqldeveloper/labs/REDO042.LOG'  to group 4;

SELECT group#, sequence#, bytes, members, status, first_change# FROM V$LOG;


--11. EX. С помощью переключения журналов повтора пройдите полный цикл переключений. Запишите серверное время в момент вашего первого переключения (оно понадобится для выполнения следующих заданий).
ALTER SYSTEM SWITCH LOGFILE;
SELECT group#, sequence#, bytes, members, status, first_change# FROM V$LOG;


--13. EX. Удалите созданную группу журналов повтора. Удалите созданные вами файлы журналов на сервере.
alter database clear logfile group 4;
alter database drop logfile group 4;
SELECT group#, sequence#, bytes, members, status, first_change# FROM V$LOG;


--14. Определите, выполняется или нет архивирование журналов повтора (архивирование должно быть отключено, иначе дождитесь, пока другой студент выполнит задание и отключит).
SELECT NAME, LOG_MODE FROM V$DATABASE;
SELECT INSTANCE_NAME, ARCHIVER, ACTIVE_STATE FROM V$INSTANCE;

--15. Определите номер последнего архива.  

--16. EX.  Включите архивирование. 
--sql plus
--connect /as sysdba
--shutdown immediate;
--startup mount;
--alter database archivelog;
--alter database open;

--
SELECT NAME, LOG_MODE FROM V$DATABASE;
SELECT INSTANCE_NAME, ARCHIVER, ACTIVE_STATE FROM V$INSTANCE;
--select * from V$LOG;

--17. EX. Принудительно создайте архивный файл. Определите его номер. Определите его местоположение и убедитесь в его наличии. Проследите последовательность SCN в архивах и журналах повтора. 
ALTER SYSTEM SET LOG_ARCHIVE_DEST_1 ='LOCATION=/home/oracle/.sqldeveloper/labs/archive'

ALTER SYSTEM SWITCH LOGFILE;
SELECT NAME, FIRST_CHANGE#, NEXT_CHANGE# FROM V$ARCHIVED_LOG;

--18. EX. Отключите архивирование. Убедитесь, что архивирование отключено.  
--shutdown immediate;
--startup mount;
--alter database noarchivelog;
--select name, log_mode from v$database;
--alter database open;


--19. Получите список управляющих файлов.
select name from v$controlfile;

--20. Получите и исследуйте содержимое управляющего файла. Поясните известные вам параметры в файле.
show parameter control;

--21. Определите местоположение файла параметров инстанса. Убедитесь в наличии этого файла. 
ALTER DATABASE BACKUP CONTROLFILE TO TRACE;
show parameter spfile ;

--22. Сформируйте PFILE с именем XXX_PFILE.ORA. Исследуйте его содержимое. Поясните известные вам параметры в файле.
--CREATE PFILE='BKA_PFILE.ora' FROM SPFILE;
--показать в папке /u01/app/oracle/product/12.2.0.1/dbhome_1/dbs


--23. Определите местоположение файла паролей инстанса. Убедитесь в наличии этого файла. 
SELECT * FROM V$PWFILE_USERS;
SELECT * FROM V$DIAG_INFO;
show parameter remote_login_passwordfile;
