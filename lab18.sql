ALTER SESSION SET nls_date_format='dd-mm-yyyy hh24:mi:ss';

drop table lab18;
create table lab18(
    id number(10) primary key, 
    text varchar2(20), 
    date_value date
    );
update lab18 set date_value = trunc(date_value)
    
delete from lab18;
select * from lab18;
commit;

-- For import from file:
--sqlldr system/oracle control=control.ctl

-- For export:
spool '/home/oracle/.sqldeveloper/labs/export.txt'
select * from lab18;
spool off;

select /*xml*/ * from lab18;