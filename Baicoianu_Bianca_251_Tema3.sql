--Baicoianu Alexandra-Bianca 
-- grupa 251 
-- Tema 3 Laborator 

--1. Mentineti intr-o colectie codurile celor mai prost platiti 5 angajati care nu căstiga comision. Folosind aceasta
--colectie mariti cu 5% salariul acestor angajati. Afisati valoarea veche a salariului, respectiv valoarea noua a
--salariului.

DECLARE
    TYPE t_codes IS TABLE OF emp_abb.employee_id%TYPE  
    INDEX BY PLS_INTEGER;
    TYPE t_salaries IS TABLE OF emp_abb.salary%TYPE;
    v_codes t_codes;
    v_salaries t_salaries;
BEGIN
    SELECT employee_id, salary BULK COLLECT INTO v_codes, v_salaries
    FROM (SELECT * FROM emp_abb
               ORDER BY SALARY)
    WHERE ROWNUM <= 5;

    FOR i IN 1..5 LOOP
        UPDATE emp_abb
        SET salary = salary * 1.05
        WHERE employee_id = v_codes(i);
        DBMS_OUTPUT.PUT(v_codes(i) || ' ' || v_salaries(i) || ' ' || v_salaries(i)*1.05);
        DBMS_OUTPUT.NEW_LINE;
    END LOOP;
END;
/
ROLLBACK;


--2. Definiti un tip colectie denumit tip_orase_***

-- folosim ca tip colectie vectorul(varray)

CREATE type tip_orase_abb is varray (20) of varchar2(20);
/

--Creati tabelul excursie_***

CREATE table excursie_abb
    (cod_excursie number(4), 
        denumire varchar2(20), 
        orase tip_orase_abb,
        status varchar2(20)
    );
/
--a. Inserati 5 inregistrari in tabel.

INSERT into excursie_abb
VALUES (1, 'Romania frumoasa', tip_orase_abb('Bucuresti', 'Iasi', 'Cluj','Oradea'), 'disponibila');

INSERT into excursie_abb
VALUES (2, 'Traditii', tip_orase_abb('Sapanta','Maramures', 'Satu Mare'), 'anulata');

INSERT into excursie_abb
VALUES (3, 'Castelele Romaniei', tip_orase_abb('Sinaia', 'Brasov','Sighisoara'), 'disponibila');

INSERT into excursie_abb
VALUES (4, 'Delta Dunarii',tip_orase_abb('Tulcea', 'Constanta'), 'anulata');

INSERT into excursie_abb
VALUES (5, 'Litoral pentru toti',tip_orase_abb('Mamaia', 'Eforie', 'Mangalia','Vama Veche'), 'disponibila');

COMMIT;

--b Actualizati coloana orase pentru o excursie specificata: 
-- adaugati un oras nou in lista, ce va fi ultimul vizitat in excursia respectiva;

/
DECLARE
    nume_ex excursie_abb.denumire%type := lower( '&denumire');
    oras_nou varchar(20):='&nume';
    o excursie_abb.orase%type;
    
BEGIN
   SELECT orase INTO o   -- in o vom avea orasele din excursia introdusa
   FROM excursie_abb
   WHERE lower(denumire)=nume_ex;
   
   o.extend;        -- adaugam la final orasul introdus de la tastatura
   o(o.last):=oras_nou;
   
   UPDATE excursie_abb
   SET orase=o
   WHERE lower(denumire)=nume_ex;
  
END;
/
COMMIT;
/

--- adaugati un oras nou in lista, ce va fi al doilea oras vizitat in excursia respectiva;

/
DECLARE
    nume_ex excursie_abb.denumire%type := lower( '&denumire');
    oras_nou varchar(20):='&nume';
    o excursie_abb.orase%type;
    
BEGIN
   SELECT orase INTO o      -- in o vom avea orasele din excursia introdusa
   FROM excursie_abb
   WHERE lower(denumire)=nume_ex;
   
   o.extend;
   for i in reverse 2..o.last-1 LOOP
    o(i+1):=o(i);
    END LOOP;
    
    -- adaugam orasul introdus de la tastatura pe pozitia 2
    o(2):=oras_nou;
   
   UPDATE excursie_abb
   SET orase=o
   WHERE lower(denumire)=nume_ex;
    
END;
/
COMMIT;
/

--inversati ordinea de vizitare a doua dintre orase al caror nume este specificat;
/
DECLARE
    nume_ex excursie_abb.denumire%type := lower( '&denumire');
    oras_nou1 varchar(20):=lower('&nume1');
    oras_nou2 varchar(20):=lower('&nume2');
    aux varchar(20);
    poz1 binary_integer;
    poz2 binary_integer;
    o excursie_abb.orase%type;
    
BEGIN
   SELECT orase INTO o      -- in o vom avea orasele din excursia introdusa
   FROM excursie_abb
   WHERE lower(denumire)=nume_ex;
   
   for i in o.first..o.last LOOP
    if lower(o(i))=oras_nou1 then poz1:=i;      -- retinem pozitiile celor 2 orase introduse
    elsif lower(o(i))=oras_nou2 then poz2:=i;
    end if;
   end loop;
    
    --interschimbam
    aux:=o(poz1);
    o(poz1):=o(poz2);
    o(poz2):=aux;
    
   
   UPDATE excursie_abb
   SET orase=o
   WHERE lower(denumire)=nume_ex;
    
END;
/
COMMIT;
/


--eliminati din lista un oras al carui nume este specificat

/
DECLARE
    nume_ex excursie_abb.denumire%type := lower( '&denumire');
    oras_nou varchar(20):='&nume';
    o excursie_abb.orase%type;
    type tablou_indexat is table of varchar2(20) index by binary_integer;
    t tablou_indexat;
    
BEGIN
   SELECT orase INTO o      -- in o vom avea orasele din excursia introdusa
   FROM excursie_abb
   WHERE lower(denumire)=nume_ex;
   
    --!!!delete nu merge pe varray
   for i in o.last..o.first loop
    if lower(o(i))<>oras_nou then t(t.count+1):=o(i);
    end if;
   end loop;
    
   
   for i in 1..t.count loop
   o(i):=t(i);
   dbms_output.put_line(o(i));
   end loop;
   
   UPDATE excursie_abb
   SET orase=o
   WHERE lower(denumire)=nume_ex;
    
END;
/
COMMIT;
/


--c. Pentru o excursie al carui cod este dat, 
--afisati numarul de orase vizitate, respectiv numele oraselor.

DECLARE  
    o tip_orase_abb := tip_orase_abb();
    cod number(4) := &cod;
BEGIN 
    SELECT orase INTO o     -- in o vom avea orasele din excursia introdusa
    FROM excursie_abb 
    WHERE cod_excursie = cod;

    DBMS_OUTPUT.PUT_LINE(o.count || ' orase: ');

    FOR i IN 1..o.count LOOP 
        DBMS_OUTPUT.PUT_LINE(o(i) || ' ');
    END LOOP;
END;
/


--d. Pentru fiecare excursie afisati lista oraselor vizitate.

DECLARE
    TYPE tip_coduri_excursii IS TABLE OF excursie_abb.cod_excursie%TYPE;
    v_coduri_excursii tip_coduri_excursii;
    v_orase tip_orase_abb;
BEGIN
    FOR e IN (SELECT cod_excursie, orase FROM excursie_abb) LOOP
        DBMS_OUTPUT.PUT_LINE('Excursie ' || e.cod_excursie);

        FOR j IN 1..(e.orase.COUNT) LOOP
            DBMS_OUTPUT.PUT_LINE(j || ': ' || e.orase(j));
        END LOOP;
    END LOOP;
END;
/


-- e. Anulali excursiile cu cele mai puline orase vizitate.

DECLARE
    v_nr_min NUMBER := 99999;
BEGIN
    --gasim nr min de orase din excursii, in v_nr_min
    FOR e IN (SELECT orase FROM excursie_abb) LOOP
        IF e.orase.COUNT < v_nr_min THEN
            v_nr_min := e.orase.COUNT;
        END IF;
    END LOOP;

    FOR e IN (SELECT cod_excursie, orase FROM excursie_abb) LOOP
        -- Daca are numar minim de orase
        IF e.orase.COUNT = v_nr_min THEN
            -- Atunci anulez excursia
            UPDATE excursie_abb
            SET status = 'anulata'
            WHERE cod_excursie = e.cod_excursie;
        END IF;
    END LOOP;
END;
/


--ex 3. Rezolvati problema anterioara folosind un alt tip de colectie studiat.

--colectie de tip TABLE, tablouri imbricate

CREATE type tip_abb is table of varchar2(20);
/

--Creati tabelul excursie_***

CREATE table excursie2_abb
    (cod_excursie number(4), 
        denumire varchar2(20),
        orase tip_abb,
        status varchar2(20)
    )
    --tablouri imbricate
    nested table orase store as tip_o_abb;
/


--a. Inserati 5 inregistrari in tabel.

INSERT into excursie2_abb
VALUES (1, 'Romania frumoasa', tip_abb('Bucuresti', 'Iasi', 'Cluj','Oradea'), 'disponibila');

INSERT into excursie2_abb
VALUES (2, 'Traditii', tip_abb('Sapanta','Maramures', 'Satu Mare'), 'anulata');

INSERT into excursie2_abb
VALUES (3, 'Castelele Romaniei', tip_abb('Sinaia', 'Brasov','Sighisoara'), 'disponibila');

INSERT into excursie2_abb
VALUES (4, 'Delta Dunarii',tip_abb('Tulcea', 'Constanta'), 'anulata');

INSERT into excursie2_abb
VALUES (5, 'Litoral pentru toti',tip_abb('Mamaia', 'Eforie', 'Mangalia','Vama Veche'), 'disponibila');

COMMIT;

--b Actualizati coloana orase pentru o excursie specificata: 
-- adaugati un oras nou in lista, ce va fi ultimul vizitat in excursia respectiva;
/
DECLARE
    nume_ex excursie2_abb.denumire%type := lower( '&denumire');
    oras_nou varchar(20):='&nume';
    o excursie2_abb.orase%type;
    
BEGIN
   SELECT orase INTO o      -- in o vom avea orasele din excursia introdusa
   FROM excursie2_abb
   WHERE lower(denumire)=nume_ex;
   
   --orasul va fi ultimul vizitat, adaugam la final
   o.extend;
   o(o.last):=oras_nou;
   
   UPDATE excursie2_abb
   SET orase=o
   WHERE lower(denumire)=nume_ex;
    
END;
/
COMMIT;
/

-- adaugati un oras nou in lista, ce va fi al doilea oras vizitat in excursia respectiva;
/
DECLARE
    nume_ex excursie2_abb.denumire%type := lower( '&denumire');
    oras_nou varchar(20):='&nume';
    o excursie2_abb.orase%type;
    
BEGIN
   SELECT orase INTO o      -- in o vom avea orasele din excursia introdusa
   FROM excursie2_abb
   WHERE lower(denumire)=nume_ex;
   
   o.extend;
   for i in reverse 2..o.last-1 LOOP
    o(i+1):=o(i);
    END LOOP;
    -- adaugam orasul pe pozitia 2
    o(2):=oras_nou;
   
   UPDATE excursie2_abb
   SET orase=o
   WHERE lower(denumire)=nume_ex;
    
END;
/
COMMIT;
/

--inversati ordinea de vizitare a doua dintre orase al caror nume este specificat;
/
DECLARE
    nume_ex excursie2_abb.denumire%type := lower( '&denumire');
    oras_nou1 varchar(20):=lower('&nume1');
    oras_nou2 varchar(20):=lower('&nume2');
    aux varchar(20);
    poz1 binary_integer;
    poz2 binary_integer;
    o excursie2_abb.orase%type;
    
BEGIN
   SELECT orase INTO o      -- in o vom avea orasele din excursia introdusa
   FROM excursie2_abb
   WHERE lower(denumire)=nume_ex;
   
   for i in o.first..o.last LOOP
    if lower(o(i))=oras_nou1 then poz1:=i;      --gasim pozitiile celor 2 orase introduse de la tastatura
    elsif lower(o(i))=oras_nou2 then poz2:=i;
    end if;
   END LOOP;
    
    --interschimbam
    aux:=o(poz1);
    o(poz1):=o(poz2);
    o(poz2):=aux;
    
   
   UPDATE excursie2_abb
   SET orase=o
   WHERE lower(denumire)=nume_ex;
    
END;
/
COMMIT;
/

--eliminati din lista un oras al carui nume este specificat
/
DECLARE
    nume_ex excursie2_abb.denumire%type := lower( '&denumire');
    oras_nou varchar(20):='&nume';
    o excursie2_abb.orase%type;
    poz binary_integer;
    
BEGIN
    -- in o vom avea orasele excursie introduse de la tastatura
   SELECT orase INTO o
   FROM excursie2_abb
   WHERE lower(denumire)=nume_ex;
   
   for i in o.first..o.last LOOP
    if lower(o(i))=oras_nou then poz:=i;   --gasim pozitia pe care se afla orasul pe care dorim sa-l stergem 
    end if;
    END LOOP;
    
   o.delete(poz);   --stergem orasul
  
   UPDATE excursie2_abb
   SET orase=o
   WHERE lower(denumire)=nume_ex;
    
END;
/
select * from excursie2_abb;
rollback;
commit;
/

--c. Pentru o excursie al carui cod este dat, afisati numarul de orase vizitate, respectiv numele oraselor.

DECLARE
    v_cod_excursie CONSTANT NUMBER NOT NULL := &cod;
    v_orase tip_abb;
BEGIN
    SELECT orase INTO v_orase
    FROM excursie2_abb
    WHERE cod_excursie = v_cod_excursie;

    DBMS_OUTPUT.PUT_LINE('Nr. orase: ' || v_orase.COUNT);

    FOR i IN 1..v_orase.COUNT LOOP
        DBMS_OUTPUT.PUT_LINE(v_orase(i));
    END LOOP;
END;
/


-- d. Pentru fiecare excursie afisati lista oraselor vizitate.
DECLARE
    TYPE tip_coduri_excursii IS TABLE OF excursie2_abb.cod_excursie%TYPE;
    v_coduri_excursii tip_coduri_excursii;
    v_orase tip_abb;
BEGIN
    FOR e IN (SELECT cod_excursie, orase FROM excursie2_abb) LOOP
        DBMS_OUTPUT.PUT_LINE('Excursie ' || e.cod_excursie);

        FOR j IN 1..(e.orase.COUNT) LOOP
            DBMS_OUTPUT.PUT_LINE(j || ': ' || e.orase(j));
        END LOOP;
    END LOOP;
END;
/


--e. Anulati excursiile cu cele mai putine orase vizitate.

DECLARE
    v_nr_min NUMBER := 99999;
BEGIN
    FOR e IN (SELECT orase FROM excursie2_abb) LOOP
        IF e.orase.COUNT < v_nr_min THEN
            v_nr_min := e.orase.COUNT;
        END IF;
    END LOOP;

    FOR e IN (SELECT cod_excursie, orase FROM excursie2_abb) LOOP
        -- Daca are numar minim de orase
        IF e.orase.COUNT = v_nr_min THEN
            -- Atunci anulez excursia
            UPDATE excursie2_abb
            SET status = 'anulata'
            WHERE cod_excursie = e.cod_excursie;
        END IF;
    END LOOP;
END;
/
SELECT * FROM excursie2_abb;
ROLLBACK;
SELECT * FROM excursie2_abb;
/