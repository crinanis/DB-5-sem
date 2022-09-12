CREATE TABLE BKA_T( x number(3), s varchar2(50));

INSERT ALL
    INTO BKA_T (x, s) VALUES (1, 'a')
    INTO BKA_T (x, s) VALUES (2, 'b')
    INTO BKA_T (x, s) VALUES (3, 'c')
SELECT * FROM dual;
COMMIT;
    
UPDATE BKA_T SET x = 99, s = 'someone' WHERE x = 1;
UPDATE BKA_T SET x = 999, s = 'help' WHERE x = 2;
COMMIT;

SELECT * FROM BKA_T WHERE s = 'help';
SELECT max(x) FROM BKA_T;

DELETE FROM BKA_t WHERE x = 3;
COMMIT;

DELETE FROM BKA_T;
ALTER TABLE BKA_T ADD p_id int primary key;

CREATE TABLE BKA_T1 
(
    a number(3), 
    b varchar2(50),
    constraint id_pk foreign key (a) REFERENCES BKA_T(p_id)
);

INSERT ALL
    INTO BKA_T (p_id, x, s) VALUES (1, 66, 'help me')
    INTO BKA_T (p_id, x, s) VALUES (2, 666, 'save me')
SELECT * FROM dual;
COMMIT;

INSERT ALL
    INTO BKA_T (p_id, x, s) VALUES (1, 66, 'help me')
    INTO BKA_T (p_id, x, s) VALUES (2, 666, 'save me')
SELECT * FROM dual;
COMMIT;
.
INSERT ALL
    INTO BKA_T1 (a,b) VALUES (1, 'so')
    INTO BKA_T1 (a,b) VALUES (2, 'sad')
SELECT * FROM dual;
COMMIT;

SELECT * FROM BKA_T t LEFT OUTER JOIN BKA_T1 t1 ON t.p_id = t1.a;
SELECT * FROM BKA_T t RIGHT JOIN BKA_T1 t1 ON t.p_id = t1.a;
SELECT * FROM BKA_T t INNER JOIN BKA_T1 t1 ON t.p_id = t1.a;

DROP TABLE BKA_T;
DROP TABLE BKA_T1;
