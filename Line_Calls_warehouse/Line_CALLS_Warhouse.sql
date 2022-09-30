
1)========================================

----------création d'utilésateur------------------

create user MSETR identified by ENDO default tablespace system;

-----------autoriser tous les privilèges-------------------

grant all privileges to MSETR;

2)===========================================

----------Le Modèle relationnel---------

wilaya ( #codewilaya , nomwilaya )
ville ( #codeville , nomville , #codewilaya)
client (#numclient , nomclient , sexeclient , #codeville)
ligne(#numeroligne , #nomclient , #codetypeligne)
Typeligne (#codetypeligne , typeligne)
appel( #codeappel , dureeappel , dateappel , #numeroligne , #codetypeappel , #codeopdes)
typeappel (#codetypeappel , typeappel)
destinatair(#codeopdes, nomopdes)

3)========================================

------------------création des tables ------------------

create table wilaya (
    codwil int,
    nomwilaya varchar(30),
    constraint pk_wilaya PRIMARY KEY(codwil)
);

create table ville(
    codeville int,
    nomville varchar(30),
    codewilaya int,
    constraint pk_ville PRIMARY KEY (codeville),
    constraint fk_wilaya foreign key(codewilaya) references wilaya(codwil) on delete cascade
);

create table client(
    numclient int,
    nomclient varchar(30),
    sexe varchar(1),
    codeville int,
    constraint fk_ville foreign key(codeville) references ville(codeville) on delete cascade,
    constraint nk_sexe check(sexe in ('M','F')),
    constraint pk_client PRIMARY KEY(numclient)
);


create table typeligne (
     codetp int,
     Tligne varchar(30),
     constraint pk_typeligne PRIMARY KEY(codetp)
);

create table ligne (
    numligne int,
    numclient int,
    codetp int,
    constraint pk_ligne PRIMARY KEY(numligne),
    constraint ck_client foreign key(numclient) references client(numclient) on delete cascade,
    constraint fk_ligne foreign key(codetp) references typeligne(codetp) on delete cascade
);

create table typeappel(
   codeta int,
   typeap varchar(30),
   constraint pk_typeappel PRIMARY KEY (codeta)
);

create table destinataire(
   codedo int,
   nomop varchar(30),
   constraint pk_destinataire PRIMARY KEY (codedo)
);

create table appel(
   CodeAppel  number,
   Duree     number,
   DateApp date,
   codeta int,
   numligne int,
   codedo int,
   constraint pk_appel PRIMARY KEY (CodeAppel),
   constraint hk_typeappel foreign key(codeta) references typeappel(codeta) on delete cascade,
   constraint sk_ligne foreign key(numligne) references ligne(numligne) on delete cascade,
   constraint mk_destinataire foreign key(codedo) references destinataire(codedo) on delete cascade
);
   
4/=====================================
 
-----------Remplissage les tables aléatoirement utilisant PL/SQL-----------

1/ table wilaya

DECLARE
 codeW number; 
 wilaya char(10);
begin
   for codeW in 1..58 loop
   Select dbms_random.string('U',8) into wilaya from dual;
   insert into wilaya values(codeW,wilaya);
  end loop;
  commit;
  end;
  / 

**************

2/ table ville

DECLARE
 codeW number; 
 ville char(10);
 codeV number;
begin
   for codeV in 1..547 loop
   Select dbms_random.string('U',8) into ville from dual;
   Select floor(dbms_random.value(1 , 58.9)) into codeW from dual;
   insert into ville values(codeV,ville,codeW);
  end loop;
  commit;
  end;
  / 


*****************

3/ table client

DECLARE
 client char(10);
 sexe varchar(1);
 NumClient number ;
 CODEVILLE number;
 a int;
 b varchar(1);
 begin
   for NumClient in 1..1065566 loop
   Select dbms_random.string('U',8) into client from dual;
   Select floor(dbms_random.value(1 , 2.9)) into a from dual;
   Select DECODE(mod(a,2),0,'F','M') into sexe from dual;
   Select floor(dbms_random.value(1 , 547.9)) into CODEVILLE from dual;   
   insert into client values(NumClient,client,sexe,CODEVILLE);
  end loop;
  commit;
  end;
  / 

***************************Partie 2*********************

1/=================================

-----------remplir table typeappel---------------------

INSERT INTO typeappel (codeta , typeap) VALUES (1 , 'Nationale');
INSERT INTO typeappel (codeta , typeap) VALUES (2 , 'internationale');

2/=================================

-----------Remplissage les tables aléatoirement utilisant PL/SQL-----------

1-table ligne

DECLARE
   nbr number;
   nb number;
   a int;
   b int;
   begin
   for nbr in 1..1500255 loop
  Select DECODE(mod(a,2),0,1,2) into b from dual; 
  Select floor (dbms_random.value(1 , 1065566.9)) into nb from dual;
  insert into ligne values(nbr, nb, b);
  end loop;
  commit;
  end;
  / 

********************

2- table typeligne

DECLARE
   Tligne varchar(10);
   nbr int;
   begin
   for nbr in 1..10 loop
  Select dbms_random.string('U',8) INTO Tligne from dual;
  insert into typeligne values(nbr, Tligne);
  end loop;
  commit;
  end;
  / 

3/=============================

-remplissage du table destinataire

DECLARE 
     nbr number;
     des varchar(10);
     begin
     for nbr in 1..522 loop
     Select dbms_random.string('U',8) INTO des from dual;
     insert into destinataire values(nbr, des);
  end loop;
 commit;
end;
  / 

**************

- remplissage du table appel 




DECLARE 
CodeAppel number; Duree number ; DateApp date ; codeta number ; numligne number; codedo int;
begin
  for CodeAppel in 1.. 3500220 loop
  Select floor(dbms_random.value(1,60.9)) into Duree from dual;
  Select TO_DATE( TRUNC(DBMS_RANDOM.VALUE(TO_CHAR(DATE'2020-01-01','J'), TO_CHAR(DATE'2021-12-31','J'))), 'J') into DateApp FROM DUAL;
  Select floor (dbms_random.value(1,2.9)) into codeta from dual;
  Select floor (dbms_random.value(1,1500255.9)) into numligne FROM DUAL;
  Select floor (dbms_random.value(1,522.9)) into codedo from dual;
  insert into Appel VALUES(CodeAppel,Duree,DateApp,codeta,numligne,codedo);
  end loop;

 commit;
end;
/ 



4/========================================

-----------Queries-------------

/*
a)nombre d'appel de chaque wilaya entre 01/01/21 et 30/01/21

set timing on
set autotrace on

select count(CodeAppel) as Nombre_Appel , nomwilaya as Wilaya
from appel a ,  wilaya w , ville v ,client c, ligne l 
where l.numligne = a.numligne 
and l.numclient = c.numclient 
and c.codeville = v.codeville 
and v.codewilaya = w.codwil 
and a.DateApp between '01/01/21' and '30/01/21'
group by nomwilaya;
*/


b) nombre d'appel effectuer par typeappel chaque année

set t*iming on    
set autotrace on

select t.typeap,count(CodeAppel) as nombre_appel,extract(year from DateApp) as year 	
from appel a 		
inner join typeappel t on t.codeta = a.codeta
group by t.typeap, extract(year from dateapp);

c)la wilaya dont le nombre d'appel est maximale en 2021

set timing on
set autotrace on

select codwil, nomwilaya, nombre_appel as maximum 
from (select w.codwil , w.nomwilaya,count(a.CodeAppel) as nombre_appel from wilaya w
inner join ville v on w.codwil = v.codewilaya
inner join client c on v.codeville = c.codeville 
inner join ligne l on c.numclient = l.numclient
inner join appel a on l.numligne = a.numligne 
where extract (year from DateApp) = 2021
group by w.codwil, w.nomwilaya) where nombre_appel = (select max(nombre_appel) from (select w.codwil, count(a.CodeAppel) as nombre_appel from wilaya w
inner join ville v on w.codwil = v.codewilaya
inner join client c on v.codeville = c.codeville 
inner join ligne l on c.numclient = l.numclient
inner join appel a on l.numligne = a.numligne 
where extract(year from DateApp) = 2021
group by w.codwil, w.nomwilaya));





#############################################################################################################


-----------Création nouvelle utilisateur nomé DATA--------------

CREATE USER DATA Identified by ENG;

GRANT ALL PRIVILEGES TO DATA;

-------Création des tables avec leur remplissage----------------

-------DPCClient--------

CREATE TABLE DPCClient (
  CodeClient int, 
  NomClient VARCHAR(50),
  SexeClient VARCHAR(1), 
  CodeVille int, 
  NomVille VARCHAR(50), 
  CodeWilaya int,
  NomWilaya VARCHAR(30),
  constraint nk_SexeClient check(SexeClient in ('M','F')),
  CONSTRAINT sk_client PRIMARY KEY (CodeClient)
);


BEGIN
FOR i IN
(SELECT NUMCLIENT, NOMCLIENT, SEXE, V.CODEVILLE, V.NOMVILLE,                W.CODWIL, W.NOMWILAYA
FROM MSETR.Client C, MSETR.Ville V, MSETR.Wilaya W
WHERE W.CODWIL = V. CODEWILAYA 
AND V.CODEVILLE = C.CODEVILLE) 
LOOP
INSERT INTO DPCClient VALUES (i.NUMCLIENT , i.NOMCLIENT, i.SEXE, i.CODEVILLE, i.NOMVILLE, i.CODWIL, i.NOMWILAYA);
END LOOP;
COMMIT;
END;
/


SELECT COUNT(*) FROM DPCClient;

------DTypeLigne--------

CREATE TABLE DTypeLigne(
 CodeTypeLigne int,
 TypeLigne varchar(30),
 constraint pk_DTypeLigne PRIMARY KEY(CodeTypeLigne)
);

BEGIN
FOR i IN
(SELECT codetp, Tligne    
 FROM MSETR.typeligne ) 
LOOP
INSERT INTO DTypeLigne VALUES (i.codetp , i.Tligne);
END LOOP;
COMMIT;
END;
/

SELECT COUNT(*) FROM DTypeLigne;

---------DTypeAppel------------

CREATE TABLE DTypeAppel(
    CodeTypeAppel int, 
    TypeAppel varchar(30),
    constraint pk_DTypeAppel PRIMARY KEY (CodeTypeAppel)     
);

BEGIN
FOR i IN
(SELECT codeta, typeap    
 FROM MSETR.typeappel ) 
LOOP
INSERT INTO DTypeAppel VALUES (i.codeta , i.typeap);
END LOOP;
COMMIT;
END;
/

SELECT COUNT(*) FROM DTypeAppel;


------------DDestinataire------------

CREATE TABLE DDestinataire (
   CodeOperateurDestinataire int, 
   NomOperateurDestinataire varchar(30),
   constraint pk_DDestinataire PRIMARY KEY (CodeOperateurDestinataire)
);

BEGIN
FOR i IN
(SELECT codedo, nomop    
 FROM MSETR.destinataire ) 
LOOP
INSERT INTO DDestinataire VALUES (i.codedo , i.nomop);
END LOOP;
COMMIT;
END;
/


SELECT COUNT(*) FROM DDestinataire;


-------- DTemps----------



CREATE TABLE DTemps (
   CodeTemps NUMBER(6), 
   Jour VARCHAR(12), 
   LibJour VARCHAR(15), 
   Mois VARCHAR(8), 
   Libmois VARCHAR(12), 
   Annee VARCHAR(4),
   CONSTRAINT pk_DTemps PRIMARY KEY (CodeTemps)
);

CREATE SEQUENCE seq
MINVALUE 1
MAXVALUE 10000
START WITH 1
INCREMENT BY 1;

BEGIN
FOR i IN
(SELECT DISTINCT TO_CHAR(DATEAPP,'DD/MM/YYYY') AS Jour,
TO_CHAR( DATEAPP,'DAY') AS LibJour,
TO_CHAR( DATEAPP,'MM/YYYY') AS Mois,
TO_CHAR( DATEAPP,'MONTH') AS Libmois,
TO_CHAR( DATEAPP,'YYYY') AS Annee
FROM MSETR.Appel) LOOP
INSERT INTO DTemps VALUES (seq.NEXTVAL, i.Jour, i.LibJour, i.Mois, i.Libmois, i.Annee);
END LOOP;
COMMIT;
END;
/


SELECT COUNT(*) FROM DTemps;


----------FAppel-----------


CREATE TABLE FAppel (
   CodeClient int, 
   CodeTypeLigne int, 
   CodeTypeAppel int, 
   CodeOperateurDestinataire int,
   CodeTemps NUMBER(6), 
   NBAppels int, 
   Duree  int,
   CONSTRAINT uK_FAppel PRIMARY KEY (CodeClient, CodeTypeLigne, CodeTypeAppel, CodeTemps),
   CONSTRAINT FK_FH_DC FOREIGN KEY (CodeClient) REFERENCES DPCClient,
   CONSTRAINT FK_FH_DL FOREIGN KEY (CodeTypeLigne) REFERENCES DTypeLigne ,
   CONSTRAINT FK_FH_DT FOREIGN KEY (CodeTypeAppel) REFERENCES DTypeAppel,
   CONSTRAINT FK_FH_DCT FOREIGN KEY ( CodeTemps) REFERENCES DTemps
);

BEGIN
FOR i IN
(SELECT L.numclient, L.codetp, A.codeta , A.codedo , D.CodeTemps, count(A.CodeAppel) as NBAppel, sum(A.Duree) as Dure
FROM MSETR.ligne L, DTemps D , MSETR.Appel A
WHERE D.Jour = A.DateApp
AND L.numligne = A.numligne 
GROUP BY numclient, codetp, codeta , codedo, CodeTemps
)
LOOP
INSERT INTO FAppel VALUES (i.numclient, i.codetp, i.codeta,i.codedo, i.CodeTemps, i.NBAppel , i.Dure) log errors into err$_FAppel reject limit unlimited;
END LOOP;
COMMIT;
END;
/

SELECT COUNT(*) FROM FAppel;








######################################################################################################################








***************************** TP ENDO : Requetes analytic **********************************


set timing on;
set autotrace on explain;
set linesize 120;


1/-------

select sum(a.NBAppels) as nombre_appel , T.Mois , c.NomWilaya 
from DPCClient c , FAppel a , DTemps T
where  a.CodeClient = c.CodeClient
and    T.CodeTemps = a.CodeTemps
group by T.Mois , c.NomWilaya
order by T.Mois , c.NomWilaya;

2/----------------

select sum(a.NBAppels) as nombre_appel , T.Mois , c.NomWilaya 
from DPCClient c , FAppel a , DTemps T
where  a.CodeClient = c.CodeClient
and    T.CodeTemps = a.CodeTemps
group by rollup  (T.Mois , c.NomWilaya);

3/---------------------

select sum(a.NBAppels) as nombre_appel , T.Mois , c.NomWilaya 
from DPCClient c , FAppel a , DTemps T
where  a.CodeClient = c.CodeClient
and    T.CodeTemps = a.CodeTemps
group by cube  (T.Mois , c.NomWilaya);


4/------------------

select sum(a.NBAppels) as nombre_appel , T.Mois , C.NomWilaya,
GROUPING_ID(C.NomWilaya , T.Mois) as GRP_ID
from DPCClient C , FAppel a , DTemps T
where  a.CodeClient = C.CodeClient
and    T.CodeTemps = a.CodeTemps
group by rollup (T.Mois , C.NomWilaya);


5/------------------


select sum(a.NBAppels) as nombre_appel , T.Annee , c.NomWilaya ,
DENSE_RANK() OVER (PARTITION BY T.Annee ORDER BY SUM(a.NBAppels) DESC) AS Classement_Dense,
RANK() OVER (PARTITION BY T.Annee ORDER BY SUM(a.NBAppels) DESC) AS Classement_NonDense
from DPCClient c , FAppel a , DTemps T
where  a.CodeClient = C.CodeClient
and    T.CodeTemps = a.CodeTemps
GROUP BY(T.Annee , c.NomWilaya );


6/---------------


SELECT sum(a.NBAppels) as nombre_appel , T.Annee , c.NomWilaya ,
CUME_DIST()  OVER (PARTITION BY T.Annee ORDER BY SUM(a.NBAppels) desc) AS CUM_DIST_NBAPPEL
from DPCClient c , FAppel a , DTemps T
where  a.CodeClient = C.CodeClient
and    T.CodeTemps = a.CodeTemps
GROUP BY(T.Annee , c.NomWilaya );


7/------------------------

SELECT c.NomWilaya, sum(a.NBAppels) as nombre_appel,  
NTILE(4) OVER(ORDER BY SUM(a.NBAppels)) AS NTILE
from DPCClient c , FAppel a
WHERE a.CodeClient = C.CodeClient
GROUP BY(c.NomWilaya);

8/---------------------------
SELECT T.Annee as Annee, T.mois , sum(a.NBAppels) ,
avg(sum(a.NBAppels)) OVER (ORDER BY T.Annee , T.mois rows 2 preceding) AS MOIS3
from  FAppel a , DTemps T
group by (T.Annee , T.mois);

9/--------------------


SELECT T.Annee as Annee, c.NomWilaya AS NomWilaya, sum(a.NBAppels) as nombre_appel,
SUM(SUM(a.NBAppels)) OVER (PARTITION BY (T.Annee)) AS NBAppels_Annuel,
RATIO_TO_REPORT (SUM(a.NBAppels)) OVER (PARTITION BY (T.Annee)) AS Ratio
from DPCClient c , FAppel a , DTemps T
where a.CodeClient = C.CodeClient
and   T.CodeTemps = a.CodeTemps
GROUP BY(T.Annee , c.NomWilaya)
ORDER BY T.Annee , c.NomWilaya;


10/----------------Pour chaque Annee donner le OPérateur dest qui réalise un  NBappel maximal ----------

SELECT Annee, codOperateur, MAX_NBappel_A
FROM  (SELECT DS.ANNEE AS Annee, a.CODEOPERATEURDESTINATAIRE  AS        codOperateur, SUM(a.NBAppels) AS SUM_NBappel_A ,
       MAX(SUM(a.NBAppels)) OVER (PARTITION BY DS.ANNEE) AS MAX_NBappel_A
       FROM FAppel a , DTEMPS DS
       WHERE a.CODETEMPS = DS.CODETEMPS 
       GROUP BY (DS.ANNEE , a.CODEOPERATEURDESTINATAIRE ))
WHERE SUM_NBappel_A = MAX_NBappel_A;


11/----------------------

La requete qui consommé plus de temps est la requete du question : 8
avec : 20 min et 33 s
//pour l'optimisation on utilise un INDEX pour cette requete comme suit :

CREATE BITMAP INDEX IBM_Fapp_DTps_libj
ON FAppel(T.mois)
FROM FAppel A , DTEMPS T
WHERE T.CODETEMPS = A.CODETEMPS
LOCAL;


le temps d'éxecution devient : 19 min et 37 s












