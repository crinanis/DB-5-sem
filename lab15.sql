SET SERVEROUTPUT ON;
ALTER SESSION SET nls_date_format='dd-mm-yyyy hh24:mi:ss';
grant create  trigger to CJACORE;

--1.	Создайте таблицу, имеющую несколько атрибутов, один из которых первичный ключ.
    CREATE TABLE tabl(
        a int primary key,
        b varchar(30)
    );


--2.	Заполните таблицу строками (10 шт.).
    DECLARE 
        i int :=0;
    BEGIN
        WHILE i<10
        LOOP
            INSERT INTO tabl(a,b)
            values (i,'a');
            i:= i+1;
        END LOOP;
    END;

    SELECT * FROM tabl;
    

--3.	Создайте BEFORE – триггер уровня оператора на события INSERT, DELETE и UPDATE. 
--4.	Этот и все последующие триггеры должны выдавать сообщение на серверную консоль (DMS_OUTPUT) со своим собственным именем. 
    CREATE OR REPLACE TRIGGER Input_trigger_before
    before insert on tabl
    BEGIN dbms_output.put_line('Insert trigger before activate'); END;
    insert into tabl values (25,'Zaka');
    
    
    CREATE OR REPLACE TRIGGER Delete_trigger_before
    before delete on tabl
    BEGIN dbms_output.put_line('Delete trigger before  activate'); END;
    delete tabl where a=23;
    
    
    CREATE OR REPLACE TRIGGER Update_trigger_before
    before update on tabl
    BEGIN dbms_output.put_line('Update trigger before  activate'); END;
    update tabl set a=101 where a=3;
    
       
--5.	Создайте BEFORE-триггер уровня строки на события INSERT, DELETE и UPDATE.
    CREATE OR REPLACE TRIGGER Input_for_each_trigger_before
    before insert on tabl
    for each row
    BEGIN dbms_output.put_line('Input_for_each_trigger before activate'); END;

    CREATE OR REPLACE TRIGGER Update_for_each_trigger_before
    before update on tabl
    for each row
    BEGIN dbms_output.put_line('Update_for_each_trigger before activate'); END;

    CREATE OR REPLACE TRIGGER Delete_for_each_trigger_before
    before delete on tabl
    for each row
    BEGIN dbms_output.put_line('Delete_for_each_trigger before activate'); END;
    
    
--6.	Примените предикаты INSERTING, UPDATING и DELETING.
    CREATE OR REPLACE TRIGGER Trigger_ing
    after insert or update or delete on tabl
    BEGIN
    IF INSERTING then
        dbms_output.put_line('Inserting after');
    ELSIF UPDATING then
        dbms_output.put_line('Updating after');
    ELSIF DELETING then
        dbms_output.put_line('Deleting after');
    END IF;
    END;    
    
    
--7.	Разработайте AFTER-триггеры уровня оператора на события INSERT, DELETE и UPDATE.
    CREATE OR REPLACE TRIGGER Input_trigger
    after insert on tabl
    BEGIN dbms_output.put_line('Insert trigger after activate'); END;

    CREATE OR REPLACE TRIGGER Delete_trigger
    after delete on tabl
    BEGIN dbms_output.put_line('Delete trigger after  activate'); END;

    CREATE OR REPLACE TRIGGER Update_trigger
    after update on tabl
    BEGIN dbms_output.put_line('Update trigger after  activate'); END;


--8.	Разработайте AFTER-триггеры уровня строки на события INSERT, DELETE и UPDATE.
    CREATE OR REPLACE TRIGGER Input_for_each_trigger
    after insert on tabl
    for each row
    BEGIN dbms_output.put_line('Input_for_each_trigger after activate'); END;
    
    CREATE OR REPLACE TRIGGER Update_for_each_trigger
    after update on tabl
    for each row
    BEGIN dbms_output.put_line('Update_for_each_trigger after activate'); END;

    CREATE OR REPLACE TRIGGER Delete_for_each_trigger
    after delete on tabl
    for each row
    BEGIN dbms_output.put_line('Delete_for_each_trigger after activate'); END;
    

--9.	Создайте таблицу с именем AUDIT. Таблица должна содержать поля: OperationDate, 
--OperationType (операция вставки, обновления и удаления),
--TriggerName(имя триггера),
--Data (строка с значениями полей до и после операции).

    create table AUDITS(
        OperationDate date,         --('DD-MM-YYYY  HH24:MI:SS'),
        OperationType varchar2(40), --i.d.u.
        TriggerName varchar2(40),
        Data varchar2(40)           --знач полей до и после операции
        );
        

--10.	Измените триггеры таким образом, чтобы они регистрировали все операции с исходной таблицей в таблице AUDIT.
    CREATE OR REPLACE TRIGGER AUDITS_trigger_before
    before insert or update  or delete on tabl
    BEGIN
        if inserting then
            dbms_output.put_line('before_insert_AUDITS');
            INSERT INTO AUDITS(OperationDate, OperationType, TriggerName, Data)
            SELECT sysdate,'Insert', 'AUDITS_trigger_before',concat(tabl.a ,tabl.b)
            FROM tabl;
        elsif updating then
            dbms_output.put_line('before_update_AUDITS');
            INSERT INTO AUDITS(OperationDate, OperationType, TriggerName, Data)
            SELECT sysdate,'Update', 'AUDITS_trigger_before',concat(tabl.a ,tabl.b)
            FROM tabl;
        elsif deleting then
            dbms_output.put_line('before_delete_AUDITS');
            INSERT INTO AUDITS(OperationDate, OperationType, TriggerName, Data)
            SELECT sysdate,'Delete', 'AUDITS_trigger_before',concat(a ,b)
            FROM tabl;
        END if;
    END;
    -------------------------------
    CREATE OR REPLACE TRIGGER AUDITS_trigger_after
    after insert or update  or delete on tabl
    BEGIN
        if inserting then
            dbms_output.put_line('after_insert_AUDITS');
            INSERT INTO AUDITS(OperationDate, OperationType, TriggerName, Data)
            SELECT sysdate,'Insert', 'AUDITS_trigger_after',concat(tabl.a ,tabl.b)
            FROM tabl;
        elsif updating then
            dbms_output.put_line('after_update_AUDITS');
            INSERT INTO AUDITS(OperationDate, OperationType, TriggerName, Data)
            SELECT sysdate,'Update', 'AUDITS_trigger_after',concat(tabl.a ,tabl.b)
            FROM tabl;
        elsif deleting then
            dbms_output.put_line('after_delete_AUDITS');
            INSERT INTO AUDITS(OperationDate, OperationType, TriggerName, Data)
            SELECT sysdate,'Delete', 'AUDITS_trigger_after',concat(a ,b)
            FROM tabl;
        END if;
    END;

--11.	Выполните операцию, нарушающую целостность таблицы по первичному ключу. Выясните, зарегистрировал ли триггер это событие. Объясните результат.
------------------------------------------------
SELECT * from tabl;
SELECT * from audits;
UPDATE tabl SET b = 'B';
DELETE tabl;
delete AUDITS;
    
select object_name, status from user_objects where object_type='TRIGGER';
---------------------------------------------

--12.	Удалите (drop) исходную таблицу. Объясните результат. Добавьте триггер, запрещающий удаление исходной таблицы.
    drop table tabl;
    FLASHBACK table tabl TO BEFORE DROP;
    
--13.	Удалите (drop) таблицу AUDIT. Просмотрите состояние триггеров с помощью SQL-DEVELOPER. Объясните результат. Измените триггеры.
    drop table audits;
    FLASHBACK table audits TO BEFORE DROP;

--.. доб триггер, запрещ. удал tabl
    CREATE OR REPLACE TRIGGER no_drop_trg
    BEFORE DROP ON CJACORE.SCHEMA
    BEGIN
        IF DICTIONARY_OBJ_NAME = 'TABL'
        THEN
        RAISE_APPLICATION_ERROR (-20905, 'Нельзя удалить TABL!!!');
        END IF;
    END; 
---------------------------------------------

--14.	Создайте представление над исходной таблицей. Разработайте INSTEADOF INSERT-триггер. Триггер должен добавлять строку в таблицу.
    create view tablview as SELECT * FROM tabl;
    
    CREATE OR REPLACE TRIGGER tabl_trigg
    instead of insert on tablview
    BEGIN
        if inserting then
            dbms_output.put_line('insert');
            insert into tabl VALUES (102, 'bye');
        end if;
    END tabl_trigg;
    
    INSERT INTO tablview (a,b) values(12,'c');
    SELECT * FROM tablview;



