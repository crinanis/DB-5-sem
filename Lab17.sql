ALTER SESSION SET nls_date_format='dd-mm-yyyy hh24:mi:ss';

ALTER SYSTEM SET JOB_QUEUE_PROCESSES = 5;

--1.	Разработайте пакет выполнения заданий, в котором:
--2.	Раз в неделю в определенное время выполняется копирование части данных по условию из одной таблицы в другую, после чего эти данные из первой таблицы удаляются. 
--3.	Необходимо проверять, было ли выполнено задание, и в какой-либо таблице сохранять сведения о попытках выполнения, как успешных, так и неуспешных.
--4.	Необходимо проверять, выполняется ли сейчас это задание.
--5.	Необходимо дать возможность выполнять задание в другое время, приостановить или отменить вообще.

create table teacher_for_job
(
  teacher varchar(200),
  teacher_name varchar(200),
  pulpit varchar(100),
  birthday date,
  salary int
);

create table job_status
(
  status   nvarchar2(50),
  error_message nvarchar2(500),
  datetime date default sysdate
);

declare
  cursor tcursor is select * from teacher_for_job;
  begin
    for n in tcursor
    loop
      insert into teacher (teacher, teacher_name, pulpit, birthday, salary) values (n.teacher, n.teacher_name, n.pulpit, n.birthday, n.salary);
    end loop;
    delete from teacher_for_job;
    commit;
end;

create or replace procedure teacherpdocedure is
  err_message varchar2(500);
  cursor teachercursor is select * from teacher where pulpit = 'ИСиТ';
  begin
    for n in teachercursor
      loop
        insert into teacher_for_job (teacher, teacher_name, pulpit, birthday, salary) values (n.teacher, n.teacher_name, n.pulpit, n.birthday, n.salary);
      end loop;
    delete from teacher where pulpit = 'ИСиТ';
    insert into job_status (status) values ('SUCCESS');
    commit;
    exception
      when others then
          err_message := sqlerrm;
          insert into job_status (status, error_message) values ('FAILURE', err_message);
          commit;
end teacherpdocedure;

select * from teacher_for_job;
select * from teacher where pulpit = 'ИСиТ';
select * from job_status;

delete from job_status;

begin
  teacherpdocedure();
end;

--------------JOB------------------
declare job_number user_jobs.job%type;
begin
  dbms_job.submit(job_number, 'BEGIN teacherpdocedure(); END;', sysdate, 'sysdate + 10/24');
  commit;
  dbms_output.put_line(job_number);
end;

select job, what, last_date, last_sec, next_date, next_sec, broken from user_jobs;
delete user_jobs where job = 1;
begin
  dbms_job.run(2);
end;

begin
  dbms_job.broken(2, true, null);
end;

begin
  dbms_job.remove(4);
end;

begin
  dbms_job.isubmit(8, 'BEGIN teacherpdocedure(); END;', sysdate, 'sysdate + 10/24');
end;

-------------SCHEDULE------------------
begin
dbms_scheduler.create_schedule(
  schedule_name => 'Sch_1',
  start_date => sysdate,
  repeat_interval => 'FREQ=DAILY',
  comments => 'Sch_1 DAILY start now'
);
end;

select * from user_scheduler_schedules;

begin
dbms_scheduler.create_program(
  program_name => 'Pr_1',
  program_type => 'STORED_PROCEDURE',
  program_action => 'teacherpdocedure',
  number_of_arguments => 0,
  enabled => true,
  comments => 'teacherpdocedure'
);
end;

select * from  user_scheduler_programs;

begin
dbms_scheduler.create_job(
  job_name => 'J_1',
  program_name => 'Pr_1',
  schedule_name => 'Sch_1',
  enabled => true
);
end;

select * from user_scheduler_jobs;

select * from teacher_for_job;
select * from teacher where PULPIT = 'ИСиТ';
select * from job_status;

delete from job_status;

begin
  DBMS_SCHEDULER.DISABLE('J_1');
end;

begin
  DBMS_SCHEDULER.RUN_JOB('J_1');
end;

begin
  DBMS_SCHEDULER.STOP_JOB('J_1');
end;

begin
  DBMS_SCHEDULER.DROP_JOB( JOB_NAME => 'J_1');
end;