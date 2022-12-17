-- TEMA 4 SGBD
-- BAICOIANU BIANCA
-- GRUPA 251

select * from emp_abb;

--1.Obțineți  pentru  fiecare  departament  numele  acestuia și numărul  de  angajați, într-una  din următoarele forme:
--“ În departamentul <nume departament> nu lucrează angajati”.
--“ În departamentul <nume departament> lucrează un angajat”.
--“ În departamentul <nume departament> lucrează<numar>angajati”.
--TEMĂ: Rezolvați problema în SQL.

WITH aux as (
    SELECT department_name as nume, count(employee_id) as nr
    FROM departments d, emp_abb e
    WHERE d.department_id = e.department_id(+)
    GROUP BY department_name)
SELECT CASE WHEN aux.nr = 0 THEN 'Departamentul ' || aux.nume || ' are 0 angajati'
            WHEN aux.nr = 1 THEN 'Departamentul ' || aux.nume || ' are 1 angajat'
            ELSE 'Departamentul ' || aux.nume || ' are ' || aux.nr || ' angajat' END
FROM aux;

select case when v_nr=0 then 'In departamentul '|| v_nume || ' nu lucreaza angajati'
            when v_nr=1 then 'In departamentul '|| v_nume || ' lucreaza un angajat'
            else 'In departamentul '|| v_nume || ' lucreaza '|| v_nr ||' angajati'
       end
from (select department_name v_nume, count(employee_id) v_nr
      from departments d, emp_abb e
      where d.department_id=e.department_id (+)
      group by department_name);

--2.Rezolvați  exercițiul 1 menținând  informațiile  dincursor în colecții.
--Procesați  toate liniile din cursor, încărcând la fiecare pas câte5 linii.
--Temă:Rezolvați problema folosind cursorul și o singură colecție.

DECLARE
    CURSOR c IS
        SELECT department_name, count(employee_id) as nr
        FROM departments d, emp_abb e
        WHERE d.department_id = e.department_id(+)
        GROUP BY department_name;
    TYPE tab_nume IS TABLE OF c%ROWTYPE;
    t_nume tab_nume;
BEGIN
    OPEN c;
    LOOP
        FETCH c BULK COLLECT INTO t_nume LIMIT 5;
        EXIT WHEN c%NOTFOUND;
        FOR i IN t_nume.FIRST..t_nume.LAST LOOP
            IF t_nume(i).nr = 0 THEN
                dbms_output.put_line('In departamentul ' || t_nume(i).department_name || ' nu lucreaza angajati');
            ELSIF t_nume(i).nr = 1 THEN
                dbms_output.put_line('In departamentul ' || t_nume(i).department_name || ' lucreaza 1 angajat');
            ELSE
                dbms_output.put_line('In departamentul ' || t_nume(i).department_name || ' lucreaza ' || t_nume(i).nr || ' angajati');
            END IF;
        END LOOP;
    END LOOP;
    IF c%ROWCOUNT = 0 THEN
        dbms_output.put_line('Nicio linie');
    END IF;
    CLOSE c;
END;
/


--Rezolvați problema folosind doar colecții. 

DECLARE
    TYPE tab_nume IS TABLE OF departments.department_name%TYPE;
    TYPE tab_nr IS TABLE OF NUMBER;
    t_nume tab_nume;
    t_nr tab_nr;
BEGIN
    SELECT department_name, count(employee_id) BULK COLLECT INTO t_nume, t_nr
    FROM departments d, emp_abb e
    WHERE d.department_id = e.department_id(+)
    GROUP BY department_name;
     
    FOR i IN t_nume.FIRST..t_nume.LAST LOOP
        IF t_nr(i) = 0 THEN
            dbms_output.put_line('In departamentul ' || t_nume(i) || ' nu lucreaza angajati');
        ELSIF t_nr(i) = 1 THEN                
            dbms_output.put_line('In departamentul ' || t_nume(i) || ' lucreaza 1 angajat');
        ELSE
            dbms_output.put_line('In departamentul ' || t_nume(i) || ' lucreaza ' || t_nr(i) || ' angajati');
        END IF;
    END LOOP;
    IF SQL%ROWCOUNT = 0 THEN
        dbms_output.put_line('Nicio linie');
    END IF;
END;
/


--5.Obțineți primii3manageri care  au  cei  mai  mulți  subordonați. 
--Afișați  numele  managerului, respectiv numărul de angajați.
--a.Rezolvați problema folosind un cursor explicit.
--b.Modificați rezolvarea anterioară astfel încât să obțineți  primii  4  manageri  
--care  îndeplinesc condiția. 
--Observați  rezultatul  obținut și  specificați  dacă  la  punctul  a  s-a obținut
--top  3 manageri? 
--TEMĂ: Rezolvați problema în SQL.

WITH aux AS
    (SELECT sef.last_name nume, count(e.employee_id) nr
    FROM emp_abb sef, emp_abb e
    WHERE e.manager_id = sef.employee_id
    GROUP BY sef.last_name)
SELECT 'Manager ' || nume || ' conduce ' || nr || ' angajati'
FROM aux a
WHERE 2 >= (SELECT COUNT(DISTINCT nr)
            FROM aux
            WHERE nr > a.nr)
ORDER BY nr DESC;



-------------------------------------------------------------------------------------------------------------

-- 1. Pentru  fiecare  job  (titlu –care  va  fi  afișat  o  singură dată) obțineți  lista  angajaților  (nume și salariu) 
-- care lucrează în prezent pe jobul respectiv. 
-- Tratați cazul în care nu există angajați care să lucreze în prezent pe un anumit job. Rezolvați problema folosind:

--a. cursoare clasice
DECLARE
 titlu jobs.job_title%TYPE;
 nume emp_abb.last_name%type;
 salariu emp_abb.salary%type;
 id_job jobs.job_id%type;
 id_emp emp_abb.job_id%type;
 numar  number;
 
 CURSOR c_job IS
    SELECT j.job_id , job_title  , count (employee_id) 
    FROM emp_abb e right join jobs j on (e.job_id=j.job_id)
    group by j.job_id, job_title;

 cursor c_emp is
    SELECT last_name , salary , job_id 
    FROM emp_abb ;
  
BEGIN
 open c_job;
 

 loop 
    fetch c_job into id_job, titlu, numar;
    exit when c_job%notfound;
    
    DBMS_OUTPUT.PUT_LINE('-------------------------------------');
    DBMS_OUTPUT.PUT_LINE ('-> Jobul: '||titlu);
  
    if numar=0 then DBMS_OUTPUT.PUT_LINE ('Job fara angajati!');
    else
        open c_emp;
        loop
            fetch c_emp into nume, salariu, id_emp;
            exit when c_emp%notfound;
            if id_job=id_emp then 
            DBMS_OUTPUT.PUT_LINE (nume||' are salariul :' || salariu);
            end if;
        end loop;
        close c_emp;
    end if;
   
 END LOOP;
 
 close c_job;

END;
/
        

--b. ciclu cursoare
DECLARE
 
 CURSOR c_job IS
    SELECT j.job_id id_job, job_title titlu , count (employee_id) numar
    FROM emp_abb e right join jobs j on (e.job_id=j.job_id)
    group by j.job_id, job_title;

 cursor c_emp is
    SELECT last_name nume, salary salariu, job_id id_job
    FROM emp_abb ;
    
  
BEGIN
 for j in c_job loop
    DBMS_OUTPUT.PUT_LINE('-------------------------------------');
    DBMS_OUTPUT.PUT_LINE ('->Jobul: '||j.titlu);
  
    if j.numar=0 then DBMS_OUTPUT.PUT_LINE ('Job fara angajati!');      -- tratare caz
    else
        
        for e in c_emp loop
            if e.id_job=j.id_job then
            DBMS_OUTPUT.PUT_LINE (e.nume||' are salariul :' || e.salariu);
            end if;
        end loop;
       
    end if;
   
 END LOOP;
 
END;
/

--c. ciclu cursoare cu subcereri
BEGIN
 FOR v_jobs IN (SELECT j.job_id, job_title, count (employee_id) nr
                FROM emp_abb e right join jobs j on (e.job_id=j.job_id)
                group by j.job_id, job_title) LOOP
        DBMS_OUTPUT.PUT_LINE('-------------------------------------');
        DBMS_OUTPUT.PUT_LINE ('->Jobul: '||v_jobs.job_title);
        
        -- tratare caz
        if v_jobs.nr=0 then
            DBMS_OUTPUT.PUT_LINE ('Job fara angajati!');
        
        else
            FOR v_emp IN (SELECT last_name, salary
                          FROM emp_abb
                          WHERE job_id = v_jobs.job_id) LOOP
                DBMS_OUTPUT.PUT_LINE (v_emp.last_name ||' are salariul :' || v_emp.salary);
            END LOOP;
        END if;
        
 END LOOP;
END;
/

--d. expresii cursor

DECLARE
 TYPE refcursor IS REF CURSOR;

 CURSOR c_jobs IS
    SELECT j.job_id, job_title, count (employee_id) ,CURSOR (SELECT last_name, salary
                                                                FROM emp_abb e2
                                                                WHERE e2.job_id=j.job_id)
    FROM emp_abb e1 right join jobs j on (e1.job_id=j.job_id)
    group by j.job_id, job_title;
    
 job_titlu jobs.job_title%TYPE;
 nume emp_abb.last_name%type;
 salariu emp_abb.salary%type;
 id_job jobs.job_id%type;
 numar  number;
 
 v_cursor refcursor;
 
BEGIN
 OPEN c_jobs;
 
 LOOP
    FETCH c_jobs INTO id_job, job_titlu, numar,  v_cursor;
 EXIT WHEN c_jobs%NOTFOUND;
    DBMS_OUTPUT.PUT_LINE('-------------------------------------');
    DBMS_OUTPUT.PUT_LINE ('->Jobul: '||job_titlu);
    
    LOOP
        FETCH v_cursor INTO nume, salariu;
    EXIT WHEN v_cursor%NOTFOUND;
        DBMS_OUTPUT.PUT_LINE (nume||' are salariul :' || salariu);
    END LOOP;
    if numar=0 then DBMS_OUTPUT.PUT_LINE ('Job fara angajati!');        -- tratare caz cerinta
    end if;
 END LOOP;
 
 CLOSE c_jobs;
END;
/


-- 2.Modificați exercițiul anterior astfel încât să obțineți și următoarele informații:
-- -un număr de ordine pentru fiecare angajat care va fi resetat pentru fiecare job
-- -pentru fiecare job
--     o numărul de angajați 
--     o valoarea lunară aveniturilor angajaților 
--     o valoarea medie a veniturilor angajaților   
-- -indiferent job
--     o numărul total de angajați
--     o valoarea totală lunară a veniturilor angajaților
--     o valoarea medie a veniturilor angajaților

DECLARE
 
 CURSOR c_job IS
    SELECT j.job_id id_job, job_title titlu , count (employee_id) numar
    FROM emp_abb e right join jobs j on (e.job_id=j.job_id)
    group by j.job_id, job_title;
    
 cursor c_emp is
    SELECT last_name nume, salary salariu, job_id id_job, nvl(commission_pct,0) comision
    FROM emp_abb ;
    
    ord number:=0;
    total_salariu employees.salary%type:=0;
   
    nr number:=0;
    total_s employees.salary%type:=0;
    
  
BEGIN
 for j in c_job loop            -- pentru fiecare job
    
    DBMS_OUTPUT.PUT_LINE('-------------------------------------');
    DBMS_OUTPUT.PUT_LINE ('->Jobul: '||j.titlu);
  
    if j.numar=0 then DBMS_OUTPUT.PUT_LINE ('Job fara angajati!');
    else
        DBMS_OUTPUT.PUT_LINE ('Numarul de angajati este: '|| j.numar);      -- numarul de anagajti
        total_salariu:=0;
        ord:=0;
        for e in c_emp loop
            if e.id_job=j.id_job then
            ord:=ord+1;
            total_salariu :=total_salariu+ e.salariu+e.comision*e.salariu;
            DBMS_OUTPUT.PUT_LINE (ord||'. ' || e.nume||' are salariul :' || e.salariu);
            end if;
        end loop;
        DBMS_OUTPUT.PUT_LINE ('Valoarea lunara a veniturilor angajatilor: '||total_salariu);        --valoarea lunara a veniturilor
        DBMS_OUTPUT.PUT_LINE ('Valoarea medie a veniturilor angajatilor : '||round(total_salariu / j.numar,2) );    -- valoarea medie
        nr:= nr+j.numar;
        total_s:=total_s+total_salariu;
        
       
    end if;
   
 END LOOP;
 --indiferent de job
 DBMS_OUTPUT.PUT_LINE ('---------------------');
 DBMS_OUTPUT.PUT_LINE ('Nr total angajati : '||nr);
 DBMS_OUTPUT.PUT_LINE ('Valoarea totala lunara a veniturilor angajatilor: '||total_s);
 DBMS_OUTPUT.PUT_LINE ('Valoarea medie a veniturilor angajatilor: '||round(total_s/nr,2));
 
END;
/

-- 3.Modificați  exercițiul  anterior  astfel  încât  să  obțineți  suma  totală  alocată  lunar  pentru  plata salariilor 
-- și a comisioanelor tuturor angajaților, 
-- iar pentru fiecare angajat cât la sută din această sumă câștigă lunar. 

DECLARE
 
CURSOR c_job IS
    SELECT j.job_id id_job, job_title titlu , count (employee_id) numar
    FROM emp_abb e right join jobs j on (e.job_id=j.job_id)
    group by j.job_id, job_title;
    
CURSOR c_emp is
    SELECT last_name nume, salary salariu, job_id id_job, nvl(commission_pct,0) comision
    FROM emp_abb ;
    
    ord number;
    total_salariu emp_abb.salary%type:=0;
    nr number:=0;
    total_s emp_abb.salary%type:=0;
    procent number;
   
  
BEGIN
 select sum(salary+ nvl(commission_pct,0)) 
    into total_s
    from emp_abb;
    
 for j in c_job loop
    
    DBMS_OUTPUT.PUT_LINE('-------------------------------------');
    DBMS_OUTPUT.PUT_LINE ('->Jobul: '||j.titlu);
  
    if j.numar=0 then DBMS_OUTPUT.PUT_LINE ('Job fara angajati!');
    else
        DBMS_OUTPUT.PUT_LINE ('Numarul de angajati este: '|| j.numar);
        total_salariu:=0;
        ord:=0;
        for e in c_emp loop
            if e.id_job=j.id_job then
            ord:=ord+1;
            total_salariu :=total_salariu+ e.salariu+e.comision*e.salariu;
            DBMS_OUTPUT.PUT(ord||'. ' || e.nume||' are salariul :' || e.salariu);
            procent:= (e.salariu+e.comision*e.salariu)*100/total_s;
            DBMS_OUTPUT.PUT_LINE (' '|| 'si castiga ' || round(procent,2) || '% din salariul total');
            end if;
        end loop;
        DBMS_OUTPUT.PUT_LINE ('Valoarea lunara a veniturilor angajatilor: '||total_salariu);
        DBMS_OUTPUT.PUT_LINE ('Valoarea medie a veniturilor angajatilor: '||round(total_salariu / j.numar,2) );
        nr:= nr+j.numar;
        
    end if;
   
 END LOOP;
 DBMS_OUTPUT.PUT_LINE ('---------------------');
 DBMS_OUTPUT.PUT_LINE ('Nr total angajati : '||nr);
 DBMS_OUTPUT.PUT_LINE ('Valoarea totala lunara a veniturilor angajatilor: '||total_s);
 DBMS_OUTPUT.PUT_LINE ('Valoarea medie a veniturilor angajatilor: '||round(total_s/nr,2));
 
END;
/

-- 4.Modificați  exercițiul anterior astfel încât să obțineți  pentru  fiecare  job primii 5  angajați care câștigă cel mai mare salariu lunar.
--  Specificați dacă pentru un job sunt mai puțin de 5 angajați. 

DECLARE
 
 CURSOR c_job IS
    SELECT j.job_id id_job, job_title titlu , count (employee_id) numar
    FROM emp_abb e right join jobs j on (e.job_id=j.job_id)
    group by j.job_id, job_title;
    
 CURSOR c_emp is
    SELECT last_name nume, salary salariu, job_id id_job, nvl(commission_pct,0) comision
    FROM emp_abb
    order by salary desc;
    
   
    total_salariu emp_abb.salary%type:=0;
    nr number:=0;
    total_s emp_abb.salary%type:=0;
    procent number;
    i number:=0;
   
  
BEGIN
 select sum(salary+ nvl(commission_pct,0)) 
    into total_s
    from emp_abb;
    
 for j in c_job loop
    
    DBMS_OUTPUT.PUT_LINE('-------------------------------------');
    DBMS_OUTPUT.PUT_LINE ('->Jobul: '||j.titlu);
  
    if j.numar=0 then DBMS_OUTPUT.PUT_LINE ('Job fara angajati!');      --tratare caz
    else
        DBMS_OUTPUT.PUT_LINE ('Numarul de angajati este: '|| j.numar);
        if j.numar<5 then
        DBMS_OUTPUT.PUT_LINE ('Numarul de angajati este mai mic ca 5');
        end if;
        
        total_salariu:=0;
        i:=0;
        
        for e in c_emp loop
            if e.id_job=j.id_job then
            i:=i+1;
            total_salariu :=total_salariu+ e.salariu+e.comision*e.salariu;
                if i<=5 then
                DBMS_OUTPUT.PUT(i||' ' || e.nume||' are salariul :' || e.salariu);
                procent:= (e.salariu+e.comision*e.salariu)*100/total_S;
                DBMS_OUTPUT.PUT_LINE (' '|| 'si castiga ' || round(procent,2) || '% din salariul total');
                end if;
            end if;
           
        end loop;
        DBMS_OUTPUT.PUT_LINE ('Valoarea lunara a veniturilor angajatilor: '||total_salariu);
        DBMS_OUTPUT.PUT_LINE ('Valoarea medie a veniturilor angajatilor : '||round(total_salariu / j.numar,2) );
        nr:= nr+j.numar;
        
    end if;
   
 END LOOP;
 DBMS_OUTPUT.PUT_LINE ('---------------------');
 DBMS_OUTPUT.PUT_LINE ('Nr total angajati : '||nr);
 DBMS_OUTPUT.PUT_LINE ('Valoarea totala lunara a veniturilor angajatilor: '||total_s);
 DBMS_OUTPUT.PUT_LINE ('Valoarea medie a veniturilor angajatilor: '||round(total_s/nr,2));
 
END;
/

-- 5.Modificați  exercițiul anterior astfel încât să obținețipentru  fiecare  jobtop  5  angajați.  
-- Dacă există mai mulți angajați care respectă criteriul de selecție care au același salariu,
-- atunci aceștia vor ocupa aceeași poziție în top 5.


DECLARE
 
CURSOR c_job IS
    SELECT j.job_id id_job, job_title titlu , count (employee_id) numar
    FROM emp_abb e right join jobs j on (e.job_id=j.job_id)
    group by j.job_id, job_title;
    
CURSOR c_emp is 
    SELECT last_name nume, salary salariu, job_id id_job, nvl(commission_pct,0) comision
    FROM emp_abb;
    
    n number;
    type t is table of emp_abb.salary%type ;
    tabel t;
    ord number;
    total_salariu emp_abb.salary%type:=0;
    nr number:=0;
    total_s emp_abb.salary%type:=0;
    procent number;
   
  
BEGIN
 select sum(salary+ nvl(commission_pct,0)) 
    into total_s
    from emp_abb;
    
 for j in c_job loop
    
    DBMS_OUTPUT.PUT_LINE('-------------------------------------');
    DBMS_OUTPUT.PUT_LINE ('->Jobul: '||j.titlu);
  
    if j.numar=0 then DBMS_OUTPUT.PUT_LINE ('Job fara angajati!');
    else
        DBMS_OUTPUT.PUT_LINE ('Numarul de angajati este: '|| j.numar);
        if j.numar<5 then
            n:=j.numar;
         else
            n:=5;
        end if;
        total_salariu:=0;
        ord:=0;
        select salary bulk collect 
        into tabel 
        from (select distinct salary
                from emp_abb emp 
                where emp.job_id=j.id_job
                order by salary desc
                ) e1
        where n > (select count(distinct salary)
                    from emp_abb emp 
                    where emp.job_id=j.id_job and  salary > e1.salary)
        and rownum <= n;
        
        for e in c_emp loop
            if e.id_job=j.id_job then
            
                total_salariu :=total_salariu+ e.salariu+e.comision*e.salariu;
            
                for i in tabel.first..tabel.last loop
                    if tabel(i)=e.salariu then
                        ord:=ord+1;
                        DBMS_OUTPUT.PUT(ord||' ' || e.nume||' are salariul :' || e.salariu);
                        procent:= (e.salariu+e.comision*e.salariu)*100/total_S;
                        DBMS_OUTPUT.PUT_LINE (' '|| 'si castiga ' || round(procent,2) || '% din salariul total');
                    end if;
                end loop;  
            end if;
            
        end loop;
        
        tabel.delete; 
        DBMS_OUTPUT.PUT_LINE ('Valoarea lunara a veniturilor angajatilor: '||total_salariu);
        DBMS_OUTPUT.PUT_LINE ('Valoarea medie a veniturilor angajatilor: '||round(total_salariu / j.numar,2) );
        nr:= nr+j.numar;
       
end if;
   
 END LOOP;
 DBMS_OUTPUT.PUT_LINE ('---------------------');
 DBMS_OUTPUT.PUT_LINE ('Nr total angajati : '||nr);
 DBMS_OUTPUT.PUT_LINE ('Valoarea totala lunara a veniturilor angajatilor: '||total_s);
 DBMS_OUTPUT.PUT_LINE ('Valoarea medie a veniturilor angajatilor: '||round(total_s/nr,2));
 
END;
/
--ca sa luam primele 5 salarii folosim :

-- select salary
-- from (select distinct salary
--       from emp_abb
--       order by salary desc
--       ) e
-- where 5 > (select count(distinct salary)
--            from emp_abb
--            where  salary > e.salary)
--       and rownum <= 5;