set serveroutput on  for SQLPlus
alter session set NLS_LANGUAGE='AMERICAN';

-- 1. Разработайте простейший анонимный блок PL/SQL (АБ), не содержащий операторов. 
begin 
    null;
end;

-- 2. Разработайте АБ, выводящий «Hello World!». Выполните его в SQLDev и SQL+.
begin
        dbms_output.put_line('Hello, world');
end;
    
-- 3. Продемонстрируйте работу исключения и встроенных функций sqlerrm, sqlcode.
declare
        x number(3) := 3;
        y number(3) := 0;
        z number (10,2);
    begin
        z:=x/y;
        DBMS_OUTPUT.put_line(z);
        exception when others
           then dbms_output.put_line(sqlcode||': error = '||sqlerrm);
    end;
    
-- 4. Разработайте вложенный блок. Продемонстрируйте принцип обработки исключений во вложенных блоках.
declare
        x number(3) := 3;
    begin
        begin
            declare x number(3) :=1;
            begin dbms_output.put_line('x = '||x); end;
        end;
        dbms_output.put_line('x = '||x);
    end;
    
-- 5. Выясните, какие типы предупреждения компилятора поддерживаются в данный момент.
SHOW PARAMETERS plsql_warnings; --by system in sql developer
SELECT name, value FROM v$parameter WHERE name = 'plsql_warnings'; --by system

-- 6. Разработайте скрипт, позволяющий просмотреть все спецсимволы PL/SQL.
select keyword from v$reserved_words
        where length = 1 and keyword != 'A';
        
-- 7. Разработайте скрипт, позволяющий просмотреть все ключевые слова  PL/SQL.
select keyword from v$reserved_words
        where length > 1 and keyword!='A' order by keyword;
        
-- 8. Разработайте скрипт, позволяющий просмотреть все параметры Oracle Server, связанные с PL/SQL. Просмотрите эти же параметры с помощью SQL+-команды show.
select name,value from v$parameter
        where name like 'plsql%';
show parameter plsql;

--9. Разработайте анонимный блок, демонстрирующий (выводящий в выходной серверный поток результаты):
--10. объявление и инициализацию целых number-переменных;
-- 11. арифметические действия над двумя целыми number-переменных, включая деление с остатком;
-- 12. объявление и инициализацию number-переменных с фиксированной точкой;
-- 13. объявление и инициализацию number-переменных с фиксированной точкой и отрицательным масштабом (округление);
-- 14. объявление и инициализацию BINARY_FLOAT-переменной;
-- 15. объявление и инициализацию BINARY_DOUBLE-переменной;
-- 16. объявление number-переменных с точкой и применением символа E (степень 10) при инициализации/присвоении;
-- 17. объявление и инициализацию BOOLEAN-переменных. 

declare
        t10 number(3):= 50;
        t11 number(3):=15;
        suma number(10,2);
        dwo number(10,2);
        t12 number(10,2):= 2.11;
        t13 number(10, -3):= 222999.45;
        t14 binary_float:= 123456789.123456789;
        t15 binary_double:= 123456789.123456789;
        t16 number(38,10):=12345E+10;
        t17 boolean:= true;
begin
    suma:=t10+t11;
    dwo:=mod(t10,t11);
    
         dbms_output.put_line('t10 = '||t10);
        dbms_output.put_line('t11 = '||t11);
        dbms_output.put_line('ostatok = '||dwo);
        dbms_output.put_line('suma = '||suma);
        dbms_output.put_line('fix = '||t12);
        dbms_output.put_line('okr = '||t13);
        dbms_output.put_line('binfl = '||t14);
        dbms_output.put_line('bindobuble = '||t15);
        dbms_output.put_line('E+10 = '||t16);
        if t17 then dbms_output.put_line('bool = '||'true'); end if;
        end;
        
-- 18. Разработайте анонимный блок PL/SQL содержащий объявление констант (VARCHAR2, CHAR, NUMBER). Продемонстрируйте  возможные операции константами.  
DECLARE
curr_year CONSTANT NUMBER := TO_NUMBER (TO_CHAR (SYSDATE, 'YYYY'));
vc CONSTANT VARCHAR2(10) := 'Varchar2';
c CHAR(5) := 'Char';
BEGIN
c := 'Nchar';
DBMS_OUTPUT.PUT_LINE(curr_year); 
DBMS_OUTPUT.PUT_LINE(vc); 
DBMS_OUTPUT.PUT_LINE(c); 
EXCEPTION
  WHEN OTHERS
  THEN DBMS_OUTPUT.PUT_LINE('error = ' || sqlerrm);
END;
    
-- 19. Разработайте АБ, содержащий объявления с опцией %TYPE. Продемонстрируйте действие опции.
DECLARE
pulp pulpit.pulpit%TYPE;
BEGIN 
pulp := 'ПОИТ';
DBMS_OUTPUT.PUT_LINE(pulp);
END;

-- 20.	Разработайте АБ, содержащий объявления с опцией %ROWTYPE. Продемонстрируйте действие опции.
DECLARE
faculty_res faculty%ROWTYPE;
BEGIN 
faculty_res.faculty := 'ФИТ';
faculty_res.faculty_name := 'Факультет информационных технологий';
DBMS_OUTPUT.PUT_LINE(faculty_res.faculty);
END;

--Task 21 & 22
-- 21. Разработайте АБ, демонстрирующий все возможные конструкции оператора IF .
DECLARE 
x PLS_INTEGER := 16;
BEGIN
IF 5 > x THEN
DBMS_OUTPUT.PUT_LINE('5 > '|| x);
ELSIF 5 < x THEN
DBMS_OUTPUT.PUT_LINE('5 < '|| x);
ELSE
DBMS_OUTPUT.PUT_LINE('5 = '|| x);
END IF;
END;

-- 23. Разработайте АБ, демонстрирующий работу оператора CASE.
DECLARE 
x PLS_INTEGER := 21;
BEGIN
CASE
WHEN x BETWEEN 10 AND 20 THEN
DBMS_OUTPUT.PUT_LINE('10 <= ' || x || ' <= 20');
WHEN x BETWEEN 21 AND 40 THEN
DBMS_OUTPUT.PUT_LINE('BETWEEN 21 AND 40');
ELSE
DBMS_OUTPUT.PUT_LINE('ELSE');
END CASE;
END;

--TASK 24-26
-- 24. Разработайте АБ, демонстрирующий работу оператора LOOP.
-- 25. Разработайте АБ, демонстрирующий работу оператора WHILE.
-- 26. Разработайте АБ, демонстрирующий работу оператора FOR.

DECLARE 
x PLS_INTEGER := 0;
BEGIN
DBMS_OUTPUT.PUT_LINE('LOOP: ');
LOOP
x := x + 1;
DBMS_OUTPUT.PUT_LINE(x);
EXIT WHEN x >= 3;
END LOOP;

DBMS_OUTPUT.PUT_LINE('FOR: ');
FOR k IN 1..3
LOOP
DBMS_OUTPUT.PUT_LINE(k);
END LOOP;

DBMS_OUTPUT.PUT_LINE('WHILE: ');
WHILE (x > 0)
LOOP
x := x - 1;
DBMS_OUTPUT.PUT_LINE(x);
END LOOP;
END;

declare
x number(2) := 2;
begin
    loop
        x := x + 1;

    end loop;
end;


declare
    n number := 2;
    y n%type := 0;
begin
    begin
        n := n/y;
        exception when no_data_found
        then DBMS_OUTPUT.PUT_LINE('x');
    end;

    exception when others
        then DBMS_OUTPUT.PUT_LINE('x');
end;