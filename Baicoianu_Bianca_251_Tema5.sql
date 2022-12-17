-- Baicoianu Alexandra-Bianca
-- Grupa 251
-- Tema 5
-- din Laborator PLSQL 4 

--1.Creati tabelul info_*** cu urmatoarele coloane:
-- - utilizator (numele utilizatorului care a initiat o comanda)
-- - data (data si timpul la care utilizatorul a initiat comanda)
-- - comanda (comanda care a fost initiata de utilizatorul respectiv)
-- - nr_linii (numarul de linii selectate/modificate de comanda)
-- - eroare (un mesaj pentru exceptii).


CREATE TABLE info_abb (
    utilizator NVARCHAR2(30),
    data DATE,
    comanda NVARCHAR2(50),
    nr_linii NUMBER,
    eroare NVARCHAR2(100)
);

COMMIT;

SELECT *
FROM info_abb;

/


--2. Modificati functia definita la exercitiul 2, respectiv procedura definita la exercitiul 4 astfel incat
--sa determine inserarea in tabelul info_*** a informatiilor corespunzatoare fiecarui caz
--determinat de valoarea data pentru parametru:
-- - exista un singur angajat cu numele specificat;
-- - exista mai multi angajati cu numele specificat;
-- - nu exista angajati cu numele specificat.

-- functia de la ex2 din lab 4 
CREATE OR REPLACE FUNCTION f2_abb (
    v_nume emp_abb.last_name%TYPE DEFAULT 'Bell'
) RETURN NUMBER IS
    salariu emp_abb.salary%TYPE;
BEGIN
    -- determinam salariul angajatului primit ca parametru
    SELECT salary INTO salariu
    FROM emp_abb
    WHERE last_name = v_nume;
        
    INSERT INTO info_abb VALUES (USER, SYSDATE, 'f2_abb', 1, NULL);
    COMMIT;

    RETURN salariu;
EXCEPTION
    WHEN no_data_found THEN
        INSERT INTO info_abb VALUES (USER, SYSDATE, 'f2_abb', 0, 'Nu exista angajatul');
        COMMIT;

        raise_application_error(-20000, 'Nu exista angajati cu numele dat');
    WHEN too_many_rows THEN
        INSERT INTO info_abb VALUES (USER, SYSDATE, 'f2_abb', 0, 'Exista mai multi angajati cu numele dat');
        COMMIT;
  
        raise_application_error(-20001, 'Exista mai multi angajati cu numele dat');
    WHEN OTHERS THEN
        INSERT INTO info_abb VALUES (USER, SYSDATE, 'f2_abb', 0, 'Alta eroare');
        COMMIT;
        
        raise_application_error(-20002, 'Alta eroare!');
END f2_abb;
/

-- apelare
DECLARE
    v_salary NUMBER;
BEGIN
    v_salary := f2_abb('King');
END;
/

select * from info_abb;

-- procedura de la ex4 din lab 4
CREATE OR REPLACE PROCEDURE p4_abb (
    v_nume emp_abb.last_name%TYPE) 
    IS
    salariu emp_abb.salary%TYPE;
BEGIN
    -- determinam salariul angajatului primit ca parametru
    SELECT salary INTO salariu
    FROM emp_abb
    WHERE last_name = v_nume;

    dbms_output.put_line('Salariul este ' || salariu);
    
    INSERT INTO info_abb VALUES (USER, SYSDATE, 'f2_abb', 1, NULL);
    COMMIT;
EXCEPTION
    WHEN no_data_found THEN
        INSERT INTO info_abb VALUES (USER, SYSDATE, 'f2_abb', 0, 'Nu exista angajatul');
        COMMIT;
        
        raise_application_error(-20000, 'Nu exista angajati cu numele dat');
    WHEN too_many_rows THEN
        INSERT INTO info_abb VALUES (USER, SYSDATE, 'f2_abb', 0, 'Exista mai multi angajati cu numele dat');
        COMMIT;
        
        raise_application_error(-20001, 'Exista mai multi angajati cu numele dat');
    WHEN OTHERS THEN
        INSERT INTO info_abb VALUES (USER, SYSDATE, 'f2_abb', 0, 'Alta eroare');
        COMMIT;
        
        raise_application_error(-20002, 'Alta eroare!');
END p4_abb;
/

-- apelare bloc PLSQL
BEGIN
    p4_abb('Bell');
END;
/


--3. Definiti o functie stocata care determina numarul de angajati care au avut cel putin 2 joburi
--diferite si care in prezent lucreaza intr-un oras dat ca parametru. Tratati cazul in care orasul dat
--ca parametru nu exista, respectiv cazul in care in orasul dat nu lucreaza niciun angajat. Inserati
--in tabelul info_*** informatiile corespunzatoare fiecarui caz determinat de valoarea data pentru parametru.

select * from locations;

CREATE OR REPLACE FUNCTION f3_abb(oras locations.city%TYPE)
RETURN NUMBER
IS
    v_nr NUMBER;
    v_eroare VARCHAR2(100);
BEGIN
    -- tratare caz 'orasul nu exista'
    IF oras IS NULL THEN
        INSERT INTO info_abb VALUES( user, sysdate, 'f3_abb', 0, 'Orasul nu exista!');
        RETURN 0;
    END IF;
    
    SELECT COUNT(*) INTO v_nr
    FROM emp_abb e JOIN departments d ON (e.department_id = d.department_id)
    JOIN locations l ON (l.location_id = d.location_id)
    WHERE (SELECT COUNT(*)              -- numarul de joburi ale unui angajat
           FROM job_history
           WHERE employee_id = e.employee_id) >= 2;
    
    -- tratare caz 'nu exista angajati in orasul dat'
    IF v_nr = 0 THEN v_eroare := 'Nu sunt angajati!';
    END IF;

    INSERT INTO info_abb VALUES( user, sysdate, 'f3_abb', 0, v_eroare);
            
    RETURN v_nr;
END;
/

BEGIN
    DBMS_OUTPUT.PUT_LINE('Nr angajati: ' || f3_abb('Roma'));    -- exemplu apelare pentru oras = 'Roma'
END;
/

--4. Definiti o procedura stocata care mareste cu 10% salariile tuturor angajatilor condusi direct sau
--indirect de catre un manager al carui cod este dat ca parametru. Tratati cazul in care nu exista
--niciun manager cu codul dat. Inserati in tabelul info_*** informatiile corespunzatoare fiecarui
--caz determinat de valoarea data pentru parametru.


CREATE OR REPLACE PROCEDURE p4_abb (
    v_manager_id emp_abb.manager_id%TYPE
) IS
    TYPE t_id IS TABLE OF emp_abb.employee_id%TYPE;
    v_id t_id;

BEGIN
    -- determin angajatii condusi de managerul cu codul dat(v_manager_id)
    SELECT employee_id
    BULK COLLECT INTO v_id
    FROM emp_abb
    START WITH employee_id = v_manager_id
    CONNECT BY manager_id = PRIOR employee_id;
    
    -- tratez caz cod manager inexistent
    IF v_id.COUNT = 0 THEN
        DBMS_OUTPUT.PUT_LINE('Nu exista un manager cu codul dat');
        RETURN;
    END IF;
    
    -- maresc salariile cu 10%
    FOR i IN v_id.FIRST..v_id.LAST
    LOOP
        UPDATE emp_abb
        SET salary = salary * 1.1
        WHERE employee_id = v_id(i);
    END LOOP;
END;
/


BEGIN
    p4_abb(101);	-- apelez pentru managerul cu codul 101
END;
/

SELECT salary
FROM emp_abb;

ROLLBACK;



--5. Definiti un subprogram care obtine pentru fiecare nume de departament ziua din saptamana in
--care au fost angajate cele mai multe persoane, lista cu numele acestora, vechimea si venitul lor
--lunar. Afisati mesaje corespunzatoare urmatoarelor cazuri:
--- intr-un departament nu lucreaza niciun angajat;
--- intr-o zi din saptamana nu a fost nimeni angajat.
--Observatii:
--a. Numele departamentului si ziua apar o singura data in rezultat.
--b. Rezolvati problema in doua variante, dupa cum se tine cont sau nu de istoricul joburilor
--angajatilor.

CREATE OR REPLACE PROCEDURE p5_abb
IS
    nr_linii NUMBER;
    v_zi NUMBER;
BEGIN
    
    FOR d IN (SELECT * FROM departments) LOOP
        DBMS_OUTPUT.PUT_LINE('Departmentul ' || d.department_name || ':');
        
        SELECT COUNT(*) INTO nr_linii 
        FROM emp_abb 
        WHERE department_id = d.department_id;
        
        -- tratare caz niciun angajat in departament
        IF nr_linii = 0 THEN
            DBMS_OUTPUT.PUT_LINE('Nu sunt angajati in departament');
            CONTINUE;
        END IF;
        
        SELECT zi INTO v_zi
        FROM (SELECT EXTRACT (DAY FROM hire_date) zi, COUNT(*) FROM emp_abb e
              WHERE e.department_id = d.department_id
              GROUP BY EXTRACT(DAY FROM hire_date) ORDER BY COUNT(*) DESC)
        WHERE rownum = 1;
        
        DBMS_OUTPUT.PUT_LINE('Zi maxima: ' || v_zi);
        
        FOR e IN (SELECT * FROM emp_abb WHERE department_id = d.department_id) LOOP
            DBMS_OUTPUT.PUT_LINE('Nume: ' || e.first_name || ', salariu: ' || e.salary);
        END LOOP;
    END LOOP;
END;
/

-- apelare
BEGIN
    p5_abb();
END;
/

