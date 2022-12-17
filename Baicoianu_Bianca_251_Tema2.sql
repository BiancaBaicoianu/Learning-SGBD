--BAICOIANU BIANCA, grupa 251
--tema 2, terminat laborator 1

--6. Numele departamentului si nr_anagajati din departamentul cu cei mai multi angajati 
variable rezultat varchar2(35)  
variable nr_angajati number
BEGIN
select department_name , count(*)
into :rezultat , :nr_angajati
from employees e, departments d 
where e.department_id= d.department_id 
group by department_name 
having count(*)= (select max(count(*))
                    from employees 
                    group by department_id);
dbms_output.put_line('Departamentul: ' || :rezultat ||'; Numarul de angajati: '|| :nr_angajati); 
end;

--1.Se dã urmãtorul bloc:
DECLARE 
numar number(3):=100;
mesaj1 varchar2(255):='text 1';
mesaj2 varchar2(255):='text 2';
BEGIN
    DECLARE 
    numar number(3):=1;
    mesaj1 varchar2(255):='text 2';
    mesaj2 varchar2(255):='text 3';
    BEGIN
    numar:=numar+1;
    mesaj2:=mesaj2||' adaugat in sub-bloc';
    END;
    
    numar:=numar+1;
    mesaj1:=mesaj1||' adaugat un blocul principal';
    mesaj2:=mesaj2||' adaugat in blocul principal'; 
END;

--a)Valoarea variabilei numar în subbloc este:  
--2     
--Explicatie: 1+1

--b)Valoarea variabilei mesaj1 în subbloc este: 
--text 2

--c)Valoarea variabilei mesaj2 în subbloc este: 
--text 3 adaugat in sub-bloc
--Explicatie: la sirul "text 3" concatenam "adaugat in subbloc"( conform instructiunii din subbloc)

--d)Valoarea variabilei numar în bloc este: 
--101
--Explicatie: 100+1

--e)Valoarea variabilei mesaj1 în bloc este:    
--text 1 adaugat un blocul principal

--f)Valoarea variabilei mesaj2 în bloc este:     
--text 2 adaugat in blocul principal


--2.Se dã urmãtorul enun?: 
--Pentru fiecare zi a lunii octombrie(se vor lua în considerare ?i zilele din lunã în care nu au fost realizate
--împrumuturi) ob?ine?i numãrul de împrumuturi efectuate.
--a.Încerca?i sã rezolva?i problema în SQL fãrã a folosi structuri ajutãtoare.
--b.Defini?i  tabelul octombrie_*** (id,  data).  Folosind  PL/SQL  popula?i  cu  date  acest  tabel. 
--Rezolva?i în SQL problema datã.

-- a)
SELECT aux, (
    select count(*) 
    from rental 
    where extract(day from book_date) = extract(day from aux)
        and extract(month from book_date) = extract(month from aux))  as "Imprumuturi"
FROM(SELECT TRUNC (last_day(SYSDATE) - ROWNUM) aux
     FROM DUAL CONNECT BY ROWNUM < extract(day from last_day(sysdate))
     )
ORDER BY aux;


-- b)
create table octombrie_abb(zi number(10), book_date date);

DECLARE
    imprumuturi NUMBER(3) := 0;
    zi NUMBER(3) := extract(day from last_day(sysdate));
BEGIN

    FOR i IN 1..zi LOOP
        select count(*) into imprumuturi from rental 
        where extract(day from book_date) = i
            and extract(month from book_date) = extract(month from sysdate);
        INSERT INTO octombrie_abb VALUES (i, TO_DATE(i ||' 10'||' 2022', 'DD MM YYYY'));
    END LOOP;
    
END;

select * from octombrie_abb;

--3.Defini?iun  bloc  anonim  în  care sã se determine numãrul de filme  (titluri)  împrumutate  de  un membru
--al cãrui nume este introdus de la tastaturã. Trata?i urmãtoarele douã situa?ii: 
--nu existã nici un membru cu nume dat;
--existã mai mul?i membrii cu acela?i nume.

DECLARE
    nume  member.last_name%type := '&nume' ; 
    id_membru member.memberid%type;
    nr number(3);
    numar number;
    total number;
    procent number;
    type rec is record ( titl_id rental.titleid%type,
                        memb_id rental.memberid%type); 
    type tabel_rec is table of rec INDEX BY BINARY_INTEGER; 
    tabel tabel_rec;
    v_rec rec;
    exceptie1 exception; 
    exceptie2 exception;
BEGIN 
    select count(*)
    into nr
    from(select distinct memberid 
        from member 
        where lower(last_name) = lower(nume));
    
   select distinct a.titleid , a.memberid
            bulk collect into tabel
            from rental a 
            join member b on b.memberid= a.memberid
             where lower(b.last_name)= lower(nume);
             

    if nr =0 then raise no_data_found;
        elsif nr> 1 then raise exceptie2;
            else  dbms_output.put_line(to_char(tabel.count));

    end if;

exception 
    when exceptie2 then dbms_output.put_line('Mai multi clienti cu acelasi nume');
    when no_data_found then DBMS_OUTPUT.PUT_LINE('Nu exista acest client');
END;

--4.Modifica?i problema anterioarã astfel încât sã afi?a?i ?i urmãtorul text:
---Categoria 1 (a împrumutat mai mult de 75% din titlurile existente)
---Categoria 2 (a împrumutat mai mult de 50% din titlurile existente)
---Categoria 3 (a împrumutat mai mult de 25% din titlurile existente)
---Categoria 4 (altfel)

DECLARE 
  nume member.last_name%type := '&nume';
  numar number;
  id_membru member.memberid%type;
  total number;
  procent number;
BEGIN
     select memberid
     into id_membru
     from member
     where upper(last_name) = upper(nume);
 
     select count(distinct titleid)
     into numar
     from rental r join member m on(r.memberid = m.memberid)
     where upper(m.last_name) = upper(nume);
     
     select count(*)
     into total
     from title;
     
     procent:=numar *100 / total;
     
     if procent >75 then
        DBMS_OUTPUT.PUT_LINE('Membrul ' || Initcap(nume) || ' face parte din categoria 1 cu ' || round(procent,1) || '% imprumutat din titlurile existente');
     elsif procent >50 then
            DBMS_OUTPUT.PUT_LINE('Membrul ' || Initcap(nume) || ' face parte din categoria 2 cu ' || round(procent,1) || '% imprumutat din titlurile existente');
     elsif procent>25 then
     DBMS_OUTPUT.PUT_LINE('Membrul ' || Initcap(nume) || ' face parte din categoria 3 cu ' || round(procent,1) || '% imprumutat din titlurile existente');
     elsif procent =0 then
     DBMS_OUTPUT.PUT_LINE('Membrul ' || Initcap(nume) || ' face parte din categoria 4 si nu a imprumutat nimic ');
     else
     DBMS_OUTPUT.PUT_LINE('Membrul ' || Initcap(nume) || ' face parte din catgoria 4 cu ' || round(procent,1) || '% imprumutat din titlurile existente');
     end if;
 
exception
    when no_data_found then DBMS_OUTPUT.PUT_LINE('Nu exista acest membru.');
    when too_many_rows then DBMS_OUTPUT.PUT_LINE('Exista mai multi membrii cu numele '||nume ||'.');
END; 

--5.Crea?i  tabelul member_***  (o  copie  a  tabelului member).  
--Adãuga?i  în  acest  tabel  coloana discount,  care  va  reprezenta  procentul  de  reducere  
--aplicat  pentru  membrii,  în  func?ie  de  categoria din care fac parte ace?tia:
---10% pentru membrii din Categoria 1 
---5% pentru membrii din Categoria 2
---3% pentru membrii din Categoria 3
---nimic 
--Actualiza?i  coloana discount pentru un membru al cãrui cod este dat de la tastaturã.
--Afi?a?i  un mesaj din care sã reiasã dacã actualizarea s-a produs sau nu.

create table member_abb as select * from member;
select * from member_abb;
alter table member_abb
add (discount number);

DECLARE 
  numar number;
  id_membru member.memberid%type := '&id';
  total number;
  procent number;
BEGIN
 
     select count(distinct titleid)
     into numar
     from rental r 
     where memberid=id_membru;
     
     select count(*)
     into total
     from title;
     
     procent:=numar *100 / total;
     
     if procent >75 then
            DBMS_OUTPUT.PUT_LINE('Actulizarea s-a produs cu succes');
            update member_abb
                set discount =10
                where memberid=id_membru;
         elsif procent >50 then
         DBMS_OUTPUT.PUT_LINE('Actulizarea s-a produs cu succes');
                update member_abb
                set discount =5
                where memberid=id_membru;
         elsif procent>25 then
         DBMS_OUTPUT.PUT_LINE('Actulizarea s-a produs cu succes');
                 update member_abb
                set discount =3
               where memberid=id_membru;
         else
         DBMS_OUTPUT.PUT_LINE('Actulizarea nu s-a produs');
         end if;
exception
    when no_data_found then DBMS_OUTPUT.PUT_LINE('Nu exista acest id. Actualizarea nu s-a produs');    
end;

