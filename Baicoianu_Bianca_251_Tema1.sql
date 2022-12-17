--TEMA 1 LABORATOR
--BAICOIANU BIANCA
--GRUPA 251
--LABORATOR SQL RECAPITULARE 2

--!!!OBS!!!
-- Am rezolvat exercițiile pe serverul altei grupe(232), deoarece tabelele nu erau la acel moment create pe serverul grupei 251
-- Pe serverul nostru am vazut ca sunt diferente de denumiri, precum title_id este titleid
-- Daca este nevoie, modific aceste denumire pentru a rula codul pe serverul grupei 251

--MEMBER(member_id, last_name, first_name, address, city, phone, join_date)
--TITLE(title_id, title, description, rating, category, release_date)
--TITLE_COPY(copy_id, title_id, status)
--RENTAL(book_date, copy_id, member_id, title_id, act_ret_date, exp_ret_date)
--RESERVATION(res_date, member_id, title_id)


--1. Identificati coloanele care compun cheia primara a fiecarei tabele știind că:
--a.exemplarele fiecarui titlu sunt numerotate incepand cu valoarea 1;
--b.un membru poate imprumuta acelasi exemplaral unui filmde mai multe ori, dar nu in aceeasi zi.
--c.un membru poate rezerva acelasi filmde mai multe ori, dar nu in aceeasi zi.

--MEMBER -> (member_id)
--TITLE -> (title_id)
--TITLE_COPY -> (copy_id,title_id)
--RENTAL -> (book_date, copy_id, member_id, title_id)
--RESERVATION -> (res_date, member_id, title_id)

--Identificati  constrangerile  referentiale ce  trebuie definite pentru  fiecare  tabela. 
--Schitati  schema conceptuala corespunzatoare.

--MEMBER: 
--- PK:member_id
---last_name NOT NULL, 
---join_date NOT NULL

--TITLE:
---PK:title_id
---TITLE_RATING in ("G", "PG","R","NK17","NR")
---TITLE NOT NULL
---DESCRIPTION NOT NUL
---CATEGORY in ("DRAMA","COMEDY","ACTION", "CHILD", "SCIFI","DOCUMENTARY")

--TITLE_COPY
---PK(copy_id, title_id)
---FK: title_id
---STATUS NOT NULL
---STATUS in ("AVAILABLE","DESTROYED", "RENTED","RESERVED")

--RENTAL
---PK: book_date, copy_id, title_id, member_id
---FK:
--	1)(member_id)
--	2)(copy_id, title_id)

--RESERVATION
---PK: res_date, member_id, title_id
---FK:
--	1)title_id
--	2)member_id

-- SCHEMA RELATIONARA
--MEMBER(#member_id,last_name,first_name,address, city, phone, join_date)
--TITLE(#title_id,title,description,rating,category, release_date)
--TITLE_COPY(#copy_id, #title_id, status)
--RENTAL(#book_date,#copy_id, #member_id, #title_id, act_ret_date, exp_ret_date)
--RESERVATION(#res_date, #member_id, #title_id)


--4.Cate filme (titluri, respectiv exemplare) au fost imprumutate din cea mai ceruta categorie?

SELECT category, count(distinct r.title_id), count(r.copy_id)
FROM title t, rental r
WHERE t.title_id = r.title_id
GROUP BY category
HAVING count(r.copy_id) = ( SELECT max(count(category))
                            FROM title t, rental r
                            WHERE t.title_id = r.title_id
                            GROUP BY category);

--5.Cate exemplare din fiecare film sunt disponibile in prezent(considerati ca statusul unui exemplar nu este setat, deci nu poate fi utilizat)?

SELECT title, count(copy_id)
FROM title t1,
( SELECT title_id, copy_id
  FROM title_copy
  WHERE (title_id, copy_id) NOT IN (SELECT title_id, copy_id --aici facem exemplarele care in prezent au fost imprumutate
                                    FROM rental
                                    WHERE act_ret_date IS NULL)) t2
WHERE t1.title_id = t2.title_id(+)  --outer join
GROUP BY title;


--6.Afiaati urmatoarele informatii: titlul filmului,numarul exemplarului, statusul setat si statusul corect.

SELECT title, copy_id, status,
       CASE WHEN (tc.title_id, copy_id) NOT IN (SELECT title_id, copy_id 
                                                FROM rental
                                                WHERE ACT_RET_DATE is null) THEN 'AVAILABLE'
            WHEN (tc.title_id, copy_id) IN (SELECT title_id, copy_id
                                            FROM rental
                                            WHERE ACT_RET_DATE IS NULL) THEN 'RENTED'
            ELSE 'DESTROYED or RESERVED'
       END status_corect
FROM title_copy tc, title t
WHERE tc.title_id = t.title_id;

--7.a.Cate exemplare au statusul eronat?

WITH aux as
(SELECT title, copy_id, status,
        CASE WHEN (tc.title_id, copy_id) not in (SELECT title_id, copy_id
                                                FROM rental
                                                WHERE ACT_RET_DATE IS NULL) THEN 'AVAILABLE'
             ELSE 'RENTED'
        END status_corect
FROM title_copy tc, title t
WHERE tc.title_id = t.title_id)


SELECT count(*) 
FROM  aux
WHERE aux.status_corect != aux.status;


--b.Setati statusul corect pentru toate exemplarele care au statusul eronat.Salvati actualizarile realizate.
--Obs.Pentru rezolvare crea?i tabela title_copy_***, preluand structura si datele din tabela title_copy.

CREATE TABLE title_copy_bb as SELECT * FROM title_copy;

UPDATE title_copy_bb
SET status = CASE WHEN (title_id, copy_id) NOT IN (SELECT title_id, copy_id
                                                   FROM rental
                                                   WHERE ACT_RET_DATE is null) THEN 'AVAILABLE'
                  else 'RENTED'
             END
WHERE status <> CASE WHEN (title_id, copy_id) NOT IN (SELECT title_id, copy_id
                                                      FROM rental
                                                      WHERE ACT_RET_DATE is null) THEN 'AVAILABLE'
                     else 'RENTED'
                END;
                
COMMIT;

--8.Toate filmele rezervate au fost imprumutate la data rezervarii?
--Afisati textul "Da" sau "Nu" in functie de situatie.

SELECT distinct
CASE WHEN (SELECT count(distinct r.title_id) 
            FROM rental R
            JOIN reservation rs on r.title_id = rs.title_id 
            AND r.member_id = rs.member_id 
            AND r.book_date = rs.res_date) = (SELECT count(*) 
                                              		FROM reservation) THEN 'Da'
ELSE 'Nu' 
END as Imprumutat_tot
FROM reservation


--9.De cate ori a imprumutat un membru(nume si prenume)fiecare film(titlu)? 

SELECT m.last_name, m.first_name, t.title, count(t.title_id) 
FROM member m
JOIN rental r on (r.member_id = m.member_id)
JOIN title_copy c on (c.copy_id=r.copy_id and c.title_id=r.title_id)
JOIN title t on (t.title_id=c.title_id)
GROUP BY t.title_id, t.title, m.last_name, m.first_name
ORDER BY m.last_name, m.first_name;


--10.De cate ori a imprumutat un membru(nume si prenume)fiecare exemplar(cod)al unui film(titlu)? 

with aux as (SELECT member_id, title_id, copy_id
		FROM member, title_copy) --product
SELECT m.last_name Nume, m.first_name Prenume, t.title Titlu, a.copy_id Cod, count(r.copy_id) Numar --ignora null =>
FROM aux a, member m, rental r, title t 	--0 unde nu a imprumutat
WHERE a.member_id = r.member_id(+) 	--join
	AND a.title_id = r.title_id(+)
	AND m.member_id = a.member_id
	AND t.title_id = a.title_id
GROUP BY m.last_name, m.first_name, t.title, a.copy_id
ORDER BY 1

--11.Obtineti statusul celui mai des imprumutat exemplar al fiecarui film(titlu)

SELECT distinct status, title
FROM title_copy tc JOIN title t on (tc.title_id = t.title_id)
WHERE (tc.title_id, tc.copy_id) in (SELECT title_id, copy_id
					--retinem titlurile cu nr max imprumutari
                                			FROM rental
                                			GROUP BY title_id, copy_id
                                			HAVING count(*) = (SELECT max(count(*)) 
                                                                --nr max imprumutari
                                                        		FROM rental
                                                        		GROUP BY title_id, copy_id ) );

--12. Pentru anumite zile specificate din luna curenta, obtineti numarul de imprumuturi efectuate.
--a. Se iau in considerare doar primele 2 zile din luna.

SELECT aux, (
    SELECT count(*) 
    FROM rental 
    WHERE extract(day from book_date) = extract(day from aux)
        and extract(month from book_date) = extract(month from aux))  as "Nr_�mprumuturi"
FROM(SELECT TRUNC (last_day(add_months(SYSDATE, -1)) + ROWNUM) aux
    --add_months(SYSDATE, -1)   -> returneaza practic luna precedenta celei curente
    --last_day(add_months(SYSDATE, -1))  -> ultima zi a lunii precedente
    -- [...] + ROWNUM  pentru a lua zilele cerute, aici vom avea rownum < 3 ( avem nevoie de primele 2 zile
     FROM DUAL CONNECT BY ROWNUM < 3) 
ORDER BY aux;

--b. Se iau in considerare doar zilele din luni in care au fost efectuate imprumuturi.

SELECT book_date, count(*) as "Imprumuturi"	--nr imprumuturi
FROM rental 
WHERE extract(month from book_date) = extract(month from sysdate) 	--verificam luna
GROUP BY book_date 
ORDER BY book_date asc;


--c. Se iau in considerare toate zilele din luna, incluzand in rezultat si zilele in care nu au fost
--efectuate imprumuturi.

SELECT aux, (
    SELECT count(*) 
    FROM rental 
    WHERE extract(day from book_date) = extract(day from aux)
    and extract(month from book_date) = extract(month from aux)) as "Nr_�mprumuturi"
FROM (SELECT TRUNC (last_day(SYSDATE) - ROWNUM) aux
--last_day(sysdate) -> ultima zi din luna curenta 
--[...]-rownum ->ia toate zilele din luna
    	 FROM DUAL CONNECT BY ROWNUM < extract(day from last_day(sysdate))
    	 -- gasim ultima zi din luna si apoi luam toate zilele pana la aceea
         )
ORDER BY aux;



