-- 1.	Определите размеры областей памяти SGA.
SELECT * FROM V$SGA_DYNAMIC_COMPONENTS;

select EMPL_NUM, NAME
    from SALESREPS S1
        where S1.EMPL_NUM not in (select REP from ORDERS where ORDER_DATE > '01-03-2008' and ORDER_DATE < '01-01-2010');

SELECT COMPONENT, CURRENT_SIZE, MIN_SIZE, MAX_SIZE
    FROM V$SGA_DYNAMIC_COMPONENTS;



select  NAME from SALESREPS
     join   ORDERS O on SALESREPS.EMPL_NUM = O.REP
        where ORDER_DATE not  between  '01-03-2008' and '01-01-2010'
            group by NAME;

-- 2.	Получите список всех параметров экземпляра.
SELECT * FROM V$PARAMETER;

-- 3.	Получите список управляющих файлов.
SELECT STATUS, NAME, IS_RECOVERY_DEST_FILE FROM V$CONTROLFILE;

-- 4.	Сформируйте PFILE (будет создана в папке dbhome/database)
CREATE PFILE = 'NEW_PFILE.ORA' FROM SPFILE;

-- 5.	СОЗДАЙТЕ ТАБЛИЦУ ИЗ ДВУХ СТОЛБЦОВ, ОДИН ИЗ КОТОРЫХ ПЕРВИЧНЫЙ КЛЮЧ. ПОЛУЧИТЕ ПЕРЕЧЕНЬ ВСЕХ СЕГМЕНТОВ. ВСТАВЬТЕ ДАННЫЕ В ТАБЛИЦУ. ОПРЕДЕЛИТЕ, СКОЛЬКО В СЕГМЕНТЕ ТАБЛИЦЫ ЭКСТЕНТОВ, ИХ РАЗМЕР В БЛОКАХ И БАЙТАХ.
CREATE TABLE PERSON (
    ID NUMBER  PRIMARY KEY,
    NAME VARCHAR2(20)
);
-- все сегменты (нет данных нет и сегментов)
SELECT * FROM USER_SEGMENTS WHERE SEGMENT_NAME = 'PERSON';
-- вставить данные
INSERT  INTO PERSON(ID, NAME) VALUES (1,'PERSON1');
INSERT  INTO PERSON(ID, NAME) VALUES (2, 'PERSON2');
INSERT  INTO PERSON(ID, NAME) VALUES (3, 'PERSON3');
SELECT * FROM USER_SEGMENTS WHERE SEGMENT_NAME ='PERSON';
-- сколько экстентов и размер в блоках и байтах байтах
SELECT  SUM(EXTENTS) AS EXTENTS_COUNT ,SUM(BLOCKS) BLOKS_COUNT, SUM(BYTES) AS MEMORY_SIZE
        FROM USER_SEGMENTS WHERE SEGMENT_NAME = 'PERSON';

--6 Получите перечень всех процессов СУБД Oracle. Для серверных процессов укажите режим подключения. Для фоновых укажите работающие в настоящий момент.
-- все процессы
SELECT * FROM V$PROCESS;
-- серверные ??? тут хз что хочет
SELECT SERVICE_NAME, SERVER FROM V$SESSION;
-- активные фоновые процессы (указатель которых не равен NULL)
SELECT * FROM V_$BGPROCESS  WHERE PADDR != hextoraw('00');

-- 7.	Получите перечень всех табличных пространств и их файлов.
SELECT *  FROM USER_TABLESPACES;
SELECT TABLESPACE_NAME, FILE_NAME FROM DBA_DATA_FILES;

-- 8.	Получите перечень всех ролей.
SELECT * FROM DBA_ROLES;

-- 9.	Получите перечень привилегий для определенной роли.
SELECT * FROM DBA_SYS_PRIVS WHERE GRANTEE = 'SYS';

-- 10.	Получите перечень всех пользователей.
SELECT * FROM SYS.ALL_USERS;

-- 11.	Создайте роль.
CREATE ROLE NEW_ROLE;
-- выдаем права этой роле (по заданию нет, но это не логично)
GRANT   CREATE SESSION,
        CREATE TABLE, DROP ANY TABLE,
        CREATE VIEW, DROP ANY VIEW,
        CREATE PROCEDURE, DROP ANY PROCEDURE
TO NEW_ROLE;

-- 12.	Создайте пользователя.
CREATE USER NEW_USER IDENTIFIED BY PA$$WORD
    -- default tablespace NEW_TABLESPACE
    -- quota unlimited on NEW_TABLESPACE
    -- profile NEW_PROFILE
    ACCOUNT UNLOCK
    PASSWORD EXPIRE;

-- 13.	Получите перечень всех профилей безопасности.
SELECT * FROM DBA_PROFILES;

-- 14.	Получите перечень всех параметров профиля безопасности.
-- в списке будет столбик RESOURCE_NAME это и есть параметр, каждая строка это описание параметра
SELECT * FROM DBA_PROFILES  WHERE PROFILE='DEFAULT';

-- 15.	Создайте профиль безопасности.
CREATE PROFILE NEW_PF LIMIT
    PASSWORD_LIFE_TIME UNLIMITED -- ВРЕМЯ ЖИЗНИ ПАРОЛЯ
    SESSIONS_PER_USER 3          -- ОГРАНИЧЕНИЕ КОЛИЧСТВА ПОДКЛЮЧЕНИЙ
    FAILED_LOGIN_ATTEMPTS 3      -- НЕВЕРНЫХ ПОПЫТОК ВХОДА
    PASSWORD_LOCK_TIME 1         -- ПРИ ЕНВЕРНОМ ВВОДЕ БЛОК НА N ДНЕЙ
    PASSWORD_REUSE_TIME 10       -- СКОЛЬКО ДНЕЙ НЕ МОЖЕТ БЫТЬ ИЗМЕНЕН ПАРОЛЬ
    CONNECT_TIME 180             -- ВРЕМЯ НЕПРЕРЫВНОГО СОЕДИНЕНИЯ
    IDLE_TIME 30;                -- РАЗРЕШЕННАЯ НЕАКТИВНОСТЬ

-- 16.	Создайте последовательность S1, со следующими характеристиками: начальное значение 1000; приращение 10; минимальное значение 0; максимальное значение 10000; циклическую; кэширующую 30 значений в памяти; гарантирующую хронологию значений. Создайте таблицу T1 с тремя столбцами и введите (INSERT) 10 строк, со значениями из S1.
CREATE SEQUENCE S1
    START WITH 1000
    INCREMENT BY 10
    MAXVALUE 10000
    MINVALUE 0
    CYCLE                       -- ПРИ МАКСИМУМЕ НАЧНЕТ С 0
    CACHE 30                    -- ЗАРАНЕЕ ГОТОВИТ ЗНАЧЕНИЯ
    ORDER;                      -- ГАРАНТИРУЕТ ПОСЛЕДОВАТЕЛЬНЫЕ ЗНАЧЕНИЯ

CREATE TABLE USERS(
    ID INT GENERATED ALWAYS AS IDENTITY (START WITH  1 INCREMENT BY 1),
    NAME VARCHAR2(50),
    SEQ_VAL NUMBER
);

insert into users(name, seq_val) values('name_1', s1.nextval);
insert into users(name, seq_val) values('name_2', s1.nextval);
insert into users(name, seq_val) values('name_3', s1.nextval);
-- до 10
SELECT * FROM USERS;

-- 17.	Создайте частный и публичный синоним для одной из таблиц и продемонстрируйте его область видимости. Найдите созданные синонимы в представлениях словаря Oracle.
CREATE PUBLIC SYNONYM PUBLIC_SYNONYM FOR USERS; -- ДОСТУПЕН ВСЕМ
CREATE  SYNONYM PRIVATE_EMPTY_S FOR USERS;      -- ТОЛЬКО ТЕКУЩЕМУ USER
SELECT * FROM ALL_SYNONYMS;  -- ВСЕЙ БД
SELECT * FROM USER_SYNONYMS; -- ТЕКУЩЕГО ПОЛЬЗОВАТЕЛЯ

-- 18.	Разработайте анонимный блок, демонстрирующий возникновение и обработку исключений WHEN TO_MANY_ROWS и NO_DATA_FOUND.
-- создать таблицу, сделаю на примере талицы которая в 16 задании
DECLARE
    R_USER USERS % ROWTYPE;
BEGIN
    -- SELECT * INTO  R_USER FROM USERS WHERE NAME ='JEKA'; -- NO DATA FOUND
    SELECT * INTO  R_USER FROM USERS; -- TOO MANY ROWS
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        SYS.DBMS_OUTPUT.PUT_LINE('NO_DATA_FOUND');
      WHEN TOO_MANY_ROWS THEN
        SYS.DBMS_OUTPUT.PUT_LINE('TOO_MANY_ROWS');
END;

-- 19.	Получите перечень всех групп журналов повтора.
SELECT * FROM V$LOG;

-- 20.	Определите текущую группу журналов повтора.
SELECT * FROM V$LOG WHERE STATUS = 'CURRENT';

-- 21.	Получите перечень файлов всех журналов повтора.
SELECT * FROM V$LOGFILE;

-- 22.	Создайте таблицу и вставьте в нее 100 записей. Найдите таблицу и ее свойства в представлениях словаря.
-- создать таблицу, сделаю на примере таблицы которая в 5 задании
DECLARE
	I NUMBER := 0;
BEGIN
	LOOP
	I := I + 1;
	INSERT  INTO PERSON(ID, NAME) VALUES (I, 'PERSON' || I);
	IF (I >= 100) THEN
		I := 0;
		EXIT;
	END IF;
	END LOOP;
END;
SELECT * FROM PERSON;
-- один из вариантов, это все почти одно и тоже, если ищем таблицу
SELECT * FROM DBA_TABLES WHERE TABLE_NAME = 'PERSON';
SELECT * FROM ALL_TABLES WHERE TABLE_NAME = 'PERSON';
SELECT * FROM USER_TABLES WHERE TABLE_NAME = 'PERSON';
-- 23.	Получите список сегментов табличного пространства.
-- указываем какое нужно хз, какое имеется в виду
SELECT * FROM DBA_SEGMENTS WHERE TABLESPACE_NAME = 'SYSTEM';

-- 24.	Подсчитайте размер данных в таблице.
SELECT BYTES/1024/1024 SIZE_PERSON_MB FROM USER_SEGMENTS WHERE SEGMENT_NAME='PERSON';

-- 25.	Вычислите количество блоков, занятых таблицей.
select COUNT(BLOCKS) QUANTITY_BLOCKS from user_segments where segment_name='PERSON'

-- 26.	Выведите список сессий.
select ses.paddr, ses.username, ses.status, ses.server  from v$session ses
    join v$process pr on ses.paddr = pr.addr where ses.username is not null and pr.background is null;

-- 27.	Выведите, производится ли архивирование журналов повтора.
select ARCHIVER from V_$INSTANCE; -- во всем экземпляре
SELECT LOG_MODE FROM V_$DATABASE; -- текущей БД

-- 28.	Создайте представление с определенными параметрами.
-- сделаю на примере таблицы которая в 5 задании
CREATE OR REPLACE VIEW NEW_VIEW
    AS
    SELECT * FROM PERSON WHERE NAME IN
    (SELECT NAME FROM PERSON
        WHERE NAME != 'person3'
        )
WITH CHECK OPTION constraint only_person3;
-- ошибка если попобовать измениь любого кроме person3
UPDATE NEW_VIEW SET NAME = 'john' WHERE NAME = 'person3';

-- 29.	Создайте database link с определенными параметрами.
CREATE DATABASE LINK NAME_LINK
    CONNECT TO NAME_USER
    IDENTIFIED BY "pa$$word"
    USING 'cdb_or_pdb';

-- 30.	Продемонстрируйте эскалацию исключения.
-- что-то про поднятие исключений)
