ALTER SESSION SET "_ORACLE_SCRIPT"=TRUE;

--1.	Получите полный список фоновых процессов. 
SELECT name, description FROM v$bgprocess;

--2.	Определите фоновые процессы, которые запущены и работают в настоящий момент.
SELECT * FROM v$bgprocess where paddr != hextoraw('00');

--3.	Определите, сколько процессов DBWn работает в настоящий момент.
  show parameter db_writer_processes; 

--4.	Получите перечень текущих соединений с экземпляром.
--5.	Определите режимы этих соединений.
--9.	Получите перечень текущих соединений с инстансом. (dedicated, shared). 

select paddr, username, status, server  from v$session where username is not null;

select addr, spid, pname from v$process where background is null;

--6.	Определите сервисы (точки подключения экземпляра).

select * from V$SERVICES;  

--7.	Получите известные вам параметры диспетчера и их значений.
SELECT * FROM V$DISPATCHER;
show parameter DISPATCHERS;

--8.	Укажите в списке Windows-сервисов сервис, реализующий процесс LISTENER.
--OracleOraDB12Home4TNSListener

--10.	LISTENER.ORA
--C:\app\User\product\12.2.0\dbhome_1\network\admin\listener.ora
--11-12. lsnrctl main commands and list of instance services
--lsnrctl status, start, stop

--server processes
select ses.paddr, ses.username, ses.status, ses.server  from v$session ses
join v$process pr on ses.paddr = pr.addr where ses.username is not null and pr.background is null;

--shared connection

create tablespace HDV_DATA
DataFile 'C:\OracleTrash\HDV_DATA.dbf'
Size 10 m 
AutoExtend on next 500k
MAXSIZE 30 m

create user c##oracle_hdv identified by 1111
default tablespace HDV_DATA
Account unlock;
grant all privileges to c##oracle_hdv;

--system
alter system set dispatchers='(protocol=tcp)(dispatchers=3)(service=shared_conn)';
select * from v$process where background is null order by pname;
select * from v$services;

select paddr, username, service_name, server, osuser, machine  from v$session ses where username is not null;
--

--oracle_hdv
declare 
x int:=1;
BEGIN
while x<100000000
  LOOP
  x:=x+1;
  end loop;
END;
--







