ALTER SESSION SET "_ORACLE_SCRIPT"=TRUE;

--1.	Получите полный список фоновых процессов. 
SELECT name, description FROM v$bgprocess;

--2.	Определите фоновые процессы, которые запущены и работают в настоящий момент.
SELECT * FROM v$bgprocess where paddr != hextoraw('00');

--3.	Определите, сколько процессов DBWn работает в настоящий момент.
  show parameter db_writer_processes; 
  select *from v$process where pname like 'DBW%';

--4.	Получите перечень текущих соединений с экземпляром.
select * from v$session;

--5.	Определите режимы этих соединений.
select username, server from v$session;

--6.	Определите сервисы (точки подключения экземпляра).
select * from V$SERVICES;  

--7.	Получите известные вам параметры диспетчера и их значений.
SELECT * FROM V$DISPATCHER;
show parameter DISPATCHERS;

--8.	Укажите в списке Windows-сервисов сервис, реализующий процесс LISTENER.
--OracleOraDB12Home4TNSListener

--9.	Получите перечень текущих соединений с инстансом. (dedicated, shared). 
select username, server from v$session;

--10.	Продемонстрируйте и поясните содержимое файла LISTENER.ORA. 
--C:\app\oracle\product\12.2.0.1\dbhome_1\network\admin\listener.ora

--11.	Запустите утилиту lsnrctl и поясните ее основные команды. 
--12.	Получите список служб инстанса, обслуживаемых процессом LISTENER. 
--lsnrctl
--help --> start, stop,status - ready, blocked, unknown
--services, version
--servacls - get access control lists
--reload - reload the parameter files and SIDs
--save_config - saves configuration changes to parameter file










