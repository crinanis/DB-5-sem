alter session set "_ORACLE_SCRIPT"=true;
alter session set container=pdb1;
alter pluggable database pdb1 open;

select name, open_mode from v$pdbs;

-- 1. Прочитайте задание полностью и выдайте своему пользователю необходимые права.-----------------------------
grant create any sequence to U1_BKA_PDB;
grant select any sequence to U1_BKA_PDB;
grant create cluster to U1_BKA_PDB;
grant create public synonym to U1_BKA_PDB;
grant create synonym to U1_BKA_PDB;
grant create materialized view to U1_BKA_PDB;
grant drop public synonym to U1_BKA_PDB;
alter user U1_BKA_PDB quota unlimited on users;

-- 2. Создайте последовательность S1 (SEQUENCE), со следующими характеристиками: начальное значение 1000; приращение 10; нет минимального значения; нет максимального значения; не циклическая; значения не кэшируются в памяти; 
-- хронология значений не гарантируется. Получите несколько значений последовательности. Получите текущее значение последовательности.
create sequence S1_U1_BKA_PDB
increment by 10
start with 1000
nomaxvalue
nominvalue
nocycle
nocache
noorder;
select S1_U1_BKA_PDB.nextval from dual;
select S1_U1_BKA_PDB.currval from dual;
--drop sequence S4_U1_BKA_PDB

-- 3. Создайте последовательность S2 (SEQUENCE), со следующими характеристиками: начальное значение 10; приращение 10; максимальное значение 100; 
-- 4. не циклическую. Получите все значения последовательности. Попытайтесь получить значение, выходящее за максимальное значение.

create sequence S2_U1_BKA_PDB
increment by 10
start with 10
maxvalue 100
nocycle;
select S2_U1_BKA_PDB.nextval from dual;
select S2_U1_BKA_PDB.currval from dual;

-- 5. Создайте последовательность S3 (SEQUENCE), со следующими характеристиками: начальное значение 10; приращение -10; минимальное значение -100; не циклическую; гарантирующую хронологию значений. 
-- Получите все значения последовательности. Попытайтесь получить значение, меньше минимального значения.
create sequence S3_U1_BKA_PDB
increment by -10
start with 10
maxvalue 11
minvalue -100
nocycle
order;
select S3_U1_BKA_PDB.nextval from dual;
select S3_U1_BKA_PDB.currval from dual;

-- 6. Создайте последовательность S4 (SEQUENCE), со следующими характеристиками: начальное значение 1; приращение 1; минимальное значение 10; циклическая; кэшируется в памяти 5 значений; хронология значений не гарантируется. Продемонстрируйте цикличность генерации значений последовательностью S4.
create sequence S4_U1_BKA_PDB
increment by 1
start with 1
maxvalue 10
cycle
cache 5
noorder;
select S4_U1_BKA_PDB.nextval from dual;
select S4_U1_BKA_PDB.currval from dual;

-- 7. Получите список всех последовательностей в словаре базы данных, владельцем которых является пользователь XXX.
select * from sys.all_sequences where sequence_owner='U1_BKA_PDB';

-- 8. Создайте таблицу T1, имеющую столбцы N1, N2, N3, N4, типа NUMBER (20), кэшируемую и расположенную в буферном пуле KEEP. С помощью оператора INSERT добавьте 7 строк, вводимое значение для столбцов должно формироваться с помощью последовательностей S1, S2, S3, S4.
 create table T1 (
    N1 number(20),
    N2 number(20),
    N3 number(20),
    N4 number(20)
    ) storage(buffer_pool keep) ;
   
    BEGIN
        FOR i IN 1..7 LOOP
        insert into T1(N1,N2,N3,N4) values (S1_U1_BKA_PDB.currval, S2_U1_BKA_PDB.currval, S3_U1_BKA_PDB.currval, S4_U1_BKA_PDB.currval);
        END LOOP;
    END;
    select * from T1;
    
-- 9. Создайте кластер ABC, имеющий hash-тип (размер 200) и содержащий 2 поля: X (NUMBER (10)), V (VARCHAR2(12)).
    create cluster U1_BKA_PDB.ABC
    (
        x number(10),
        v varchar2(12)
    )
    hashkeys 200;
    
    
-- 10. Создайте таблицу A, имеющую столбцы XA (NUMBER (10)) и VA (VARCHAR2(12)), принадлежащие кластеру ABC, а также еще один произвольный столбец.
create table A(XA number(10), VA varchar(12), CA char(10)) cluster U1_BKA_PDB.ABC(XA,VA);

-- 11. Создайте таблицу B, имеющую столбцы XB (NUMBER (10)) и VB (VARCHAR2(12)), принадлежащие кластеру ABC, а также еще один произвольный столбец.
create table B(XB number(10), VB varchar(12), CB char(10)) cluster U1_BKA_PDB.ABC(XB,VB);

-- 12. Создайте таблицу С, имеющую столбцы XС (NUMBER (10)) и VС (VARCHAR2(12)), принадлежащие кластеру ABC, а также еще один произвольный столбец. 
create table C(XC number(10), VC varchar(12), CC char(10)) cluster U1_BKA_PDB.ABC(XC,VC);

-- 13. Найдите созданные таблицы и кластер в представлениях словаря Oracle.
select cluster_name, owner from DBA_CLUSTERS;
select * from dba_tables where cluster_name='ABC';   

-- 14. Создайте частный синоним для таблицы XXX.С и продемонстрируйте его применение.
create synonym U1_BKA_PDB_Syn1 for U1_BKA_PDB.C;
select * from U1_BKA_PDB.C;
select *from U1_BKA_PDB_Syn1;

-- 15. Создайте публичный синоним для таблицы XXX.B и продемонстрируйте его применение.
create public synonym U1_BKA_PDB_Syn2 for U1_BKA_PDB.B;
select * from U1_BKA_PDB.B;
select *from U1_BKA_PDB_Syn2;

-- 16. Создайте две произвольные таблицы A и B (с первичным и внешним ключами), заполните их данными, создайте представление V1, основанное на SELECT... FOR A inner join B. Продемонстрируйте его работоспособность.
 create table Task16_1 (
        X number(20) primary key
        );
    create table Task16_2  (
        Y number(20),
        constraint fk_column
        foreign key (Y) references Task16_1(X)
        );
    insert into Task16_1(X) values (1);
    insert into Task16_1(X) values (2);
    insert into Task16_2(Y) values (1);
    insert into Task16_2(Y) values (2);
    create view V1
    as select X, Y from Task16_1 inner join Task16_2 on Task16_1.X=Task16_2.Y;
   
    select * from V1;
    
-- 17. На основе таблиц A и B создайте материализованное представление MV, которое имеет периодичность обновления 2 минуты. Продемонстрируйте его работоспособность.
    create materialized view MV
    build immediate
    refresh complete
    start with sysdate
    -- sysdate + Interval '1' minute
    next  sysdate + numtodsinterval(1, 'minute')
    as
    select Task16_1.X, Task16_2.Y
    from (select count(*) X from Task16_1) Task16_1,
         (select count(*) Y from Task16_2) Task16_2
    
    select * from MV;
    select * from Task16_1
    insert into Task16_1(X) values (5);
    commit

    drop materialized view MV;







 