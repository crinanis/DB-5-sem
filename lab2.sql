create tablespace TS_BKA
  datafile '/home/oracle/.sqldeveloper/TS_BKA.dbf'
  size 7M
  autoextend on next 5M
  maxsize 20M;
  

create temporary tablespace TS_BKA_TEMP
  tempfile '/home/oracle/.sqldeveloper/TS_BKA_TEMP.dbf'
  size 5M
  autoextend on next 3M
  maxsize 30M;

-- Задание 3. Получите список всех табличных пространств, списки всех файлов с помощью select-запроса к словарю.

select tablespace_name, status, contents logging from dba_tablespaces;
select file_name, tablespace_name, status from  dba_data_files
union
select file_name, tablespace_name, status from dba_temp_files;

-- Задание 4. Создайте роль с именем RL_XXXCORE. Назначьте ей следующие системные привилегии:
-- разрешение на соединение с сервером;
-- разрешение создавать и удалять таблицы, представления, процедуры и функции.

alter session set "_ORACLE_SCRIPT"=true;

create role RL_BKACORE;
grant create session,
      create table, drop any table, 
      create view, drop any view,
      create procedure, drop any procedure
      to RL_BKACORE;
      

-- Задание 5. Найдите с помощью select-запроса роль в словаре. 
-- Найдите с помощью select-запроса все системные привилегии, назначенные роли.

select * from dba_roles where role like 'RL%';
select * from dba_sys_privs where grantee = 'RL_BKACORE';
      
-- Задание 6. Создайте профиль безопасности с именем PF_XXXCORE, имеющий опции, аналогичные примеру из лекции.

create profile PF_BKACORE limit
  password_life_time 180
  sessions_per_user 3
  failed_login_attempts 7
  password_lock_time 1
  password_reuse_time 10
  password_grace_time default
  connect_time 180
  idle_time 30;
  
-- Задание 7. Получите список всех профилей БД. Получите значения всех параметров профиля PF_XXXCORE. 
-- Получите значения всех параметров профиля DEFAULT

select * from dba_profiles where profile = 'PF_BKACORE';
select * from dba_profiles where profile = 'DEFAULT';
  
-- Задание 8. Создайте пользователя с именем XXXCORE со следующими параметрами:
-- табличное пространство по умолчанию: TS_XXX;
-- табличное пространство для временных данных: TS_XXX_TEMP;
-- профиль безопасности PF_XXXCORE;
-- учетная запись разблокирована;
-- срок действия пароля истек. 

create user U_BKACORE identified by 12345
  default tablespace TS_BKA quota unlimited on TS_BKA
  temporary tablespace TS_BKA_TEMP
  profile PF_BKACORE
  account unlock 
  password expire;
  
grant RL_BKACORE to U_BKACORE;

-- Задание 9. Соединитесь с сервером Oracle с помощью sqlplus и введите новый пароль для пользователя XXXCORE.  

-- Задание 10. Создайте соединение с помощью SQL Developer для пользователя XXXCORE. Создайте любую таблицу и любое представление.

CREATE TABLE BKA_U2( x number(3), s varchar2(50));

INSERT ALL
    INTO BKA_U2 (x, s) VALUES (1, 'a')
    INTO BKA_U2 (x, s) VALUES (2, 'b')
    INTO BKA_U2 (x, s) VALUES (3, 'c')
SELECT * FROM dual;
COMMIT;
SELECT * FROM BKA_U2;

-- Задание 11. Создайте табличное пространство с именем XXX_QDATA (10m). 
-- При создании установите его в состояние offline. Затем переведите табличное пространство в состояние online. 
-- Выделите пользователю XXX квоту 2m в пространстве XXX_QDATA. От имени пользователя XXX создайте таблицу в пространстве XXX_T1. 
-- В таблицу добавьте 3 строки.


create tablespace BKA_QDATA
  datafile '/home/oracle/.sqldeveloper/BKA_QDATA.dbf'
  size 10M
  autoextend on next 5M
  maxsize 20M
  offline;
  
alter tablespace BKA_QDATA online;

create user BKA identified by 12345
  default tablespace BKA_QDATA quota 2M on BKA_QDATA
  temporary tablespace TS_BKA_TEMP
  profile PF_BKACORE
  account unlock 
  password expire;
  
grant RL_BKACORE to BKA;

create tablespace BKA_T1
  datafile '/home/oracle/.sqldeveloper/BKA_T1.dbf'
  size 10M
  autoextend on next 5M
  maxsize 20M;

create table BKA_T2
( 
  x number(3), 
  s varchar2(50)
) tablespace BKA_T1;

INSERT ALL
    INTO BKA_T2 (x, s) VALUES (1, 'a')
    INTO BKA_T2 (x, s) VALUES (2, 'b')
    INTO BKA_T2 (x, s) VALUES (3, 'c')
SELECT * FROM dual;
COMMIT;

select * from dba_tablespaces;
select * from bka_t2;
      
      