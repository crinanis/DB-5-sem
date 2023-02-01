create type TypeTestObject as object
(
    object_name varchar2(500),
    object_id number,
    object_type varchar2(10)
);

-- ������� ��������� ���� nested table
/*������� �-�, ������� ����� ��� � ������ �������*/
create type TypeTestList as table of TypeTestObject;

/*� nested tables ����� �������� � ������� �������
  �� pipelined ������. �������� ���� ��������������*/
create or replace function testFunction(obj_type in varchar2)
    return TypeTestList pipelined as
    begin
        for i in (select tao.OBJECT_NAME, tao.OBJECT_ID, tao.OBJECT_TYPE
                    from all_objects tao
                    where tao.OBJECT_TYPE=obj_type)
        loop
            pipe row (TypeTestObject(i.OBJECT_NAME, i.OBJECT_ID, i.OBJECT_TYPE));
        end loop;
        return;
    end;  
/*����������� ������� ������, ����������� ������, �� ��� ��������� 
������� ���� TypeTestObject � ���������� � ���������.*/  

select * from table(testFunction('TABLE')) t where t.object_id=20;
  
    
    -------------------------
 -- A S K   T O M    
    
create table Emplyees
(   empno number(4),
    ename varchar2(10)
);
insert into Emplyees values (7499, 'ALLEN');
insert into Emplyees values (7521, 'WARD');
insert into Emplyees values (7654, 'MARTIN');
    
create or replace type emp_type as object
(    empno number(4),
     ename varchar2(10)
);
create or replace type emp_table_type as table of emp_type;

--����� ����� ����� ��� ��� �������� ��� �������
create or replace function emp_etl(cur in sys_refcursor)
    return emp_table_type
    PIPELINED as
    rec Emplyees%rowtype;
    begin
        loop
        fetch cur into rec;
        exit when (cur%notfound);
        pipe row (emp_type(rec.empno, rec.ename));
        end loop;
        return;
    end;
select empno, ename from TABLE(emp_etl(cursor( select * from Emplyees)));
   

---- ORACLE.DOCS
/*��������� �-��� - �., ���. ���������� ����� �������� (nested table) 
    � ���. � ������ ������� ��� � ���. �������
    �. ��������� ����� �������� ��� �������� (��� �������� ��� ref cursor)
    �������, ���. �����. ����.�. ����� ��� pipelined - ���������� �����-���
    ����. ����. �-�� �����. ������� ������� � ������. �����. ������ ��� ������������ ����������� ����. �-�
*/


 create table Students
    (   s_id        integer,
        first_name  varchar2(50),
        last_name   varchar2(50)
    );
  insert into students values (1, '����', '���������');
  insert into students values (1, '����', '��������');
  insert into students values (1, '�������', '�����');

create or replace type st_type as object
(   s_id        integer,
    first_name  varchar2(50),
    last_name   varchar2(50)
);

create or replace type st_table_type as table of st_type;


/*� ������� �� �������� ����� �� ��������, ������ ������� ����� ������ �����������
�� ������� ����, ��� ��� ���������� �� �, �� ������� ������������� �������,
������ ������ ������� �� ��������� ��������� ���������� ���� ���������, �������� � ���������� ��������� 

�.�., � ���. ����������� ����. �-� �� �������� ����������� ������� �������,
����������� ������� ������ ������� ������� �� ���� ���. pl/sql ���� � �� �������� � ����� ������-���,
� � ���� ������� ���� �� ���������*/

create or replace function st_fun(cur in sys_refcursor)
    return st_table_type
    PIPELINED
    as
    rec Students%rowtype;
    begin
        loop
        fetch cur into rec;
        exit when (cur%notfound);
        if (rec.first_name like '�%')
            then rec.last_name := '�������';
            end if;
        pipe row (st_type(rec.s_id, rec.first_name, rec.last_name));
        end loop;
        return;
    end;   
select * from TABLE(st_fun(cursor( select * from Students)));
select * from Students;   
    
    
    
    
    
    
    
    
    
    
    
    
    
    