SET serveroutput ON;

--1.Процедура должна выводить список преподавателей из таблицы TEACHER (в стандартный серверный вывод), работающих на кафедре заданной кодом в параметре. Разработайте анонимный блок и продемонстрируйте выполнение процедуры.
CREATE OR REPLACE PROCEDURE PGET_TEACHERS (PCODE TEACHER.PULPIT%TYPE) IS
  CURSOR my_curs IS SELECT TEACHER_NAME, TEACHER FROM TEACHER WHERE PULPIT = PCODE;
  t_name TEACHER.TEACHER_NAME%type;
  t_code TEACHER.TEACHER%type;
BEGIN
  OPEN my_curs;
  LOOP
    DBMS_OUTPUT.PUT_LINE(t_code||' '||t_name);
    FETCH my_curs INTO t_name, t_code;
    EXIT WHEN my_curs%notfound;
  END LOOP;
  CLOSE my_curs;
END;

BEGIN
    PGET_TEACHERS('ИСиТ');
END;

--2. Функция должна выводить количество преподавателей из таблицы TEACHER, работающих на кафедре заданной кодом в параметре. Разработайте анонимный блок и продемонстрируйте выполнение процедуры.
CREATE OR REPLACE FUNCTION FGET_NUM_TEACHERS(PCODE TEACHER.PULPIT%TYPE)
  RETURN NUMBER IS
    tCount NUMBER;
BEGIN
  SELECT COUNT(*) INTO tCount FROM TEACHER WHERE PULPIT = PCODE;
  RETURN tCount;
END;

BEGIN
  DBMS_OUTPUT.PUT_LINE(FGET_NUM_TEACHERS('ИСиТ'));
END;

-- 3. Процедура должна выводить список преподавателей из таблицы TEACHER (в стандартный серверный вывод), работающих на факультете, заданным кодом в параметре. Разработайте анонимный блок и продемонстрируйте выполнение процедуры.
CREATE OR REPLACE PROCEDURE PGET_TEACHERS(FCODE FACULTY.FACULTY%TYPE) IS
  CURSOR my_curs IS
    SELECT T.TEACHER_NAME, T.TEACHER, P.FACULTY
    FROM TEACHER T
    INNER JOIN PULPIT P
    ON T.PULPIT = P.PULPIT
    WHERE P.FACULTY = FCODE;
  t_name TEACHER.TEACHER_NAME%type;
  t_code TEACHER.TEACHER%type;
  t_faculty PULPIT.FACULTY%type;
BEGIN
  OPEN my_curs;
  LOOP
    DBMS_OUTPUT.PUT_LINE(t_name||' '||t_code||' '||t_faculty);
    FETCH my_curs INTO t_name, t_code, t_faculty;
    EXIT WHEN my_curs%notfound;
  END LOOP;
  CLOSE my_curs;
END;

BEGIN
    PGET_TEACHERS('ИДиП');
END;

-- Процедура должна выводить список дисциплин из таблицы SUBJECT, закрепленных за кафедрой, заданной кодом кафедры в параметре. Разработайте анонимный блок и продемонстрируйте выполнение процедуры.
CREATE OR REPLACE PROCEDURE PGET_SUBJECTS (PCODE SUBJECT.PULPIT%TYPE) IS
  CURSOR my_curs IS
      SELECT SUBJECT, SUBJECT_NAME, S.PULPIT
        FROM SUBJECT S
        WHERE S.PULPIT = PCODE;
  s_subject SUBJECT.SUBJECT%TYPE;
  s_subject_name SUBJECT.SUBJECT_NAME%TYPE;
  s_pulpit SUBJECT.PULPIT%TYPE;
BEGIN
  OPEN my_curs;
  LOOP
    DBMS_OUTPUT.PUT_LINE(s_subject||' '||s_subject_name||' '||s_pulpit);
    FETCH my_curs INTO s_subject, s_subject_name, s_pulpit;
    EXIT WHEN my_curs%notfound;
  END LOOP;
  CLOSE my_curs;
END;

BEGIN
  PGET_SUBJECTS('ИСиТ');
END;

--5. Функция должна выводить количество преподавателей из таблицы TEACHER, работающих на факультете, заданным кодом в параметре. Разработайте анонимный блок и продемонстрируйте выполнение процедуры.
CREATE OR REPLACE FUNCTION FGET_NUM_TEACHERS(FCODE FACULTY.FACULTY%TYPE)
  RETURN NUMBER IS
    tCount NUMBER;
BEGIN
  SELECT COUNT(*) INTO tCount FROM TEACHER T
  INNER JOIN PULPIT P
  ON T.PULPIT = P.PULPIT
  WHERE P.FACULTY = FCODE;
    RETURN tCount;
END;

BEGIN
  DBMS_OUTPUT.PUT_LINE(FGET_NUM_TEACHERS('ИДиП'));
END;

-- GET_NUM_SUBJECTS (PCODE SUBJECT.PULPIT%TYPE) RETURN NUMBER Функция должна выводить количество дисциплин из таблицы SUBJECT, 
-- закрепленных за кафедрой, заданной кодом кафедры параметре. Разработайте анонимный блок и продемонстрируйте выполнение процедуры. 
CREATE OR REPLACE FUNCTION FGET_NUM_SUBJECTS (PCODE SUBJECT.PULPIT%TYPE)
  RETURN NUMBER IS
    tCount NUMBER:=0;
BEGIN
    SELECT COUNT(*) INTO tCount
      FROM SUBJECT
      WHERE SUBJECT.PULPIT = PCODE;
    RETURN tCount;
END;

BEGIN
  DBMS_OUTPUT.PUT_LINE(FGET_NUM_SUBJECTS('ИСиТ'));
END;

--6. Пакет, сод. процедуры и ф-ции
CREATE OR REPLACE PACKAGE TEACHERS AS
    FCODE FACULTY.FACULTY%TYPE;
    PCODE SUBJECT.PULPIT%TYPE;
    PROCEDURE PGET_TEACHERS(FCODE FACULTY.FACULTY%TYPE);
    PROCEDURE PGET_SUBJECTS (PCODE SUBJECT.PULPIT%TYPE);
    FUNCTION FGET_NUM_TEACHERS(FCODE FACULTY.FACULTY%TYPE) RETURN NUMBER;
    FUNCTION FGET_NUM_SUBJECTS(PCODE SUBJECT.PULPIT%TYPE) RETURN NUMBER;
END TEACHERS;


CREATE OR REPLACE PACKAGE BODY TEACHERS AS
  FUNCTION FGET_NUM_TEACHERS(FCODE FACULTY.FACULTY%TYPE) RETURN NUMBER
    IS tCount NUMBER;
        BEGIN
      SELECT COUNT(*) INTO tCount FROM TEACHER T
      INNER JOIN PULPIT P
      ON T.PULPIT = P.PULPIT
      WHERE P.FACULTY = FCODE;
        RETURN tCount;
      END FGET_NUM_TEACHERS;
  FUNCTION FGET_NUM_SUBJECTS (PCODE SUBJECT.PULPIT%TYPE)
      RETURN NUMBER IS
        tCount NUMBER:=0;
    BEGIN
        SELECT COUNT(*) INTO tCount
          FROM SUBJECT
          WHERE SUBJECT.PULPIT = PCODE;
        RETURN tCount;
    END FGET_NUM_SUBJECTS;
    
    
  PROCEDURE PGET_SUBJECTS (PCODE SUBJECT.PULPIT%TYPE) IS
      CURSOR my_curs IS
          SELECT SUBJECT, SUBJECT_NAME, S.PULPIT
            FROM SUBJECT S
            WHERE S.PULPIT = PCODE;
      s_subject SUBJECT.SUBJECT%TYPE;
      s_subject_name SUBJECT.SUBJECT_NAME%TYPE;
      s_pulpit SUBJECT.PULPIT%TYPE;
    BEGIN
      OPEN my_curs;
      LOOP
        DBMS_OUTPUT.PUT_LINE(s_subject||' '||s_subject_name||' '||s_pulpit);
        FETCH my_curs INTO s_subject, s_subject_name, s_pulpit;
        EXIT WHEN my_curs%notfound;
      END LOOP;
      CLOSE my_curs;
    END PGET_SUBJECTS;
    
    
  PROCEDURE PGET_TEACHERS(FCODE FACULTY.FACULTY%TYPE) IS
      CURSOR my_curs IS
        SELECT T.TEACHER_NAME, T.TEACHER, P.FACULTY
        FROM TEACHER T
        INNER JOIN PULPIT P
        ON T.PULPIT = P.PULPIT
        WHERE P.FACULTY = FCODE;
      t_name TEACHER.TEACHER_NAME%type;
      t_code TEACHER.TEACHER%type;
      t_faculty PULPIT.FACULTY%type;
    BEGIN
      OPEN my_curs;
      LOOP
        DBMS_OUTPUT.PUT_LINE(t_name||' '||t_code||' '||t_faculty);
        FETCH my_curs INTO t_name, t_code, t_faculty;
        EXIT WHEN my_curs%notfound;
      END LOOP;
      CLOSE my_curs;
    END PGET_TEACHERS;
END TEACHERS;
  
-- 7. Разработайте анонимный блок и продемонстрируйте выполнение процедур и функций пакета TEACHERS.
BEGIN
  DBMS_OUTPUT.PUT_LINE(TEACHERS.FGET_NUM_TEACHERS('ИДиП'));
  DBMS_OUTPUT.PUT_LINE(TEACHERS.FGET_NUM_SUBJECTS('ИСиТ'));
  TEACHERS.PGET_TEACHERS('ИДиП');
  TEACHERS.PGET_SUBJECTS('ИСиТ');
END;











