SET serveroutput ON;
alter session set nls_date_format = 'DD-MM-YYYY';

-- 1. Добавьте в таблицу TEACHERS два столбца BIRTHDAYи SALARY, заполните их значениями.
alter table TEACHER add BIRTHDAY Date;
alter table TEACHER add SALARY number(4,0);
select * from teacher;

UPDATE TEACHER SET BIRTHDAY='10.11.1956', SALARY=50 WHERE TEACHER='СМЛВ'
UPDATE TEACHER SET BIRTHDAY='14.11.2022', SALARY=78 WHERE TEACHER='ГРН'
UPDATE TEACHER SET BIRTHDAY='23.05.1978', SALARY=5 WHERE TEACHER='ЖЛК'
UPDATE TEACHER SET BIRTHDAY='10.11.1959', SALARY=12 WHERE TEACHER='БРТШВЧ'
UPDATE TEACHER SET BIRTHDAY='03.06.1983', SALARY=34 WHERE TEACHER='ЮДНКВ'
UPDATE TEACHER SET BIRTHDAY='30.08.1987', SALARY=45 WHERE TEACHER='БРНВСК'
UPDATE TEACHER SET BIRTHDAY='15.01.1995', SALARY=33 WHERE TEACHER='НВРВ'
UPDATE TEACHER SET BIRTHDAY='17.03.1999', SALARY=80 WHERE TEACHER='РВКЧ'
UPDATE TEACHER SET BIRTHDAY='02.12.1932', SALARY=120 WHERE TEACHER='ДМДК'


-- 2. Получите список преподавателей в виде Фамилия И.О.
select teacher_name from TEACHER;
      select regexp_substr(teacher_name,'(\S+)',1, 1)||' '||
      substr(regexp_substr(teacher_name,'(\S+)',1, 2),1, 1)||'. '||
      substr(regexp_substr(teacher_name,'(\S+)',1, 3),1, 1)||'. '
    from teacher;

-- 3. Получите список преподавателей, родившихся в понедельник.
select * from teacher
    where TO_CHAR((birthday), 'd') = 2;

-- 4. Создайте представление, в котором поместите список преподавателей, которые родились в следующем месяце.
create view NextMonthBirth as
    select * from teacher
    where TO_CHAR(sysdate,'mm') + 1 = TO_CHAR(birthday, 'mm');
    
    select * from NextMonthBirth;
    --drop view NextMonthBirth;

-- 6. Создать курсор и вывести список преподавателей, у которых в следующем году юбилей.
    cursor TeacherBirtday(teacher%rowtype) 
        return teacher%rowtype is
        select * from teacher
        where MOD((TO_CHAR(sysdate,'yyyy') - TO_CHAR(birthday, 'yyyy') + 1), 10) = 0; 

-- 7. Создать курсор и вывести среднюю заработную плату по кафедрам с округлением вниз до целых, вывести средние итоговые значения для каждого факультета и для всех факультетов в целом.
cursor tAvgSalary(teacher.salary%type,teacher.pulpit%type) 
      return teacher.salary%type,teacher.pulpit%type  is
        select floor(avg(salary)), pulpit
        from teacher
        group by pulpit;

--итог значение для к. факультета 
    select round(AVG(T.salary),3),P.faculty
    from teacher T
    inner join pulpit P
    on T.pulpit = P.pulpit
    group by P.faculty
    union
      select floor(avg(salary)), teacher.pulpit
        from teacher
        group by teacher.pulpit
    order by faculty;

-- для всех факультетов в целом
    select round(avg(salary),3) from teacher;
    
-- 8. Создайте собственный тип PL/SQL-записи (record) и продемонстрируйте работу с ним. Продемонстрируйте работу с вложенными записями. Продемонстрируйте и объясните операцию присвоения. 
    declare
        type ADDRESS is record
        (
          town nvarchar2(20),
          country nvarchar2(20)
        );
        type PERSON is record
        (
          name teacher.teacher_name%type,
          pulp teacher.pulpit%type,
          homeAddress ADDRESS
        );
      per1 PERSON;
      per2 PERSON;
    begin
      select teacher_name, pulpit into per1.name, per1.PULP
      from teacher
      where teacher='ЖЛК';
      per1.homeAddress.town := 'Минск';
      per1.homeAddress.country := 'Беларусь';
      per2 := per1;
      dbms_output.put_line( per2.name||' '|| per2.pulp||' из '||
                            per2.homeAddress.town||', '|| per2.homeAddress.country);
    end;
    
    
    