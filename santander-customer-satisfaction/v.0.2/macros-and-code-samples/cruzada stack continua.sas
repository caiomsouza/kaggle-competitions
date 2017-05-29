/* 
MACRO CRUZADASTACK PARA CONTINUA

HACE VALIDACIÓN CRUZADA CON LOS SIGUIENTES MÉTODOS:

RED NEURONAL (parámetro nodos de la macro; cualquier otra especificación 
				de la red como algoritmo, iteraciones, activación, etc. se cambia dentro del código)
REGRESIÓN

RANDOM FOREST

GRADIENT BOOSTING (párámetros itera y v)

LA MACRO SE PUEDE CAMBIAR A CONVENIENCIA INTERNAMENTE, SOBRE TODO LOS PARÁMETROS DE LA RED NEURONAL

PARA UTILIZAR VARIABLES CATEGÓRICAS ELIMINAR LOS ASTERISCOS EN *CLASS...

*/

%macro cruzadastack
(archivo=,vardepen=,listcategor=,listconti=,ngrupos=,seminicio=,semifinal=,nodos=10);
data final;run;
proc printto print='c:\ca.txt' log='c:\loga.txt';run;
%do semilla=&seminicio %to &semifinal;/*<<<<<******AQUI SE PUEDEN CAMBIAR LAS SEMILLAS */
data dos;set &archivo;u=ranuni(&semilla);
proc sort data=dos;by u;run;
data dos (drop=nume);
retain grupo 1;
set dos nobs=nume;
if _n_>grupo*nume/&ngrupos then grupo=grupo+1;
run;

data fantasma;run;

%do exclu=1 %to &ngrupos;

data tres;set dos;if grupo ne &exclu then vardep=&vardepen*1;run;


/*************************************************************/
/* REGRESIÓN */
proc glm data=tres noprint;/*<<<<<******SE PUEDE QUITAR EL NOPRINT */
*class &listcategor;
model vardep=&listconti &listcategor;
output out=saco p=predi;
;run;
/*************************************************************/

data sal1 ;set saco;predi1=predi;run;
 
/*************************************************************/
/*RED */
PROC DMDB DATA=tres dmdbcat=catatres;
target vardep ;
var vardep &listconti;
*class &listcategor;
;run;
proc neural data=tres dmdbcat=catatres ;
input &listconti/ id=i;
*input &listcategor /level=nominal;
target vardep/ id=o level=interval;
hidden &nodos/ id=h act=tanh;
netoptions randist=normal ranscale=0.15 random=15459;
prelim 15 preiter=10 pretech=bprop mom=0.2 learn=0.7;
train maxiter=100 technique=bprop mom=0.2 learn=0.7;
score data=tres out=salred;
run;

data sal2 (keep=&vardepen predi2 grupo vardep);set salred;predi2=p_vardep;run;

/*************************************************************/
/*RANDOM FOREST*/
/*************************************************************/

proc hpforest data=tres
maxtrees=100 
vars_to_try=5
trainfraction=0.7
leafsize=3
maxdepth=20
exhaustive=5000 
missing=useinsearch ;
target vardep/level=interval;
input &listconti/level=interval;   
*input &listcategor/level=nominal;
score out=salo;
run;

data sal3 (keep=&vardepen predi3 grupo vardep);set salo;predi3=p_vardep;run;

/*************************************************************/
/*GRADIENT BOOSTING */
/*************************************************************/

	proc treeboost data=tres
	exhaustive=1000 intervaldecimals=max
	leafsize=5 iterations=100 maxbranch=2
	maxdepth=10 mincatsize=10 missing=useinsearch shrinkage=0.05
	splitsize=10; 
	*input &listcategor/level=nominal;
	input &listconti/level=interval;
	target vardep /level=interval;
	subseries largest;
	score out=salboost;
run;
data sal4 (keep=&vardepen predi4 grupo vardep);set salboost;predi4=p_vardep;run;


/* PRUEBAS CON STACKING */

data unionsal (drop=ygorro);merge sal1 sal2 sal3 sal4;
predi5=(predi1+predi2)/2; /* RED -LOG */
predi6=(predi1+predi3)/2;/* RED -RFOR */
predi7=(predi1+predi4)/2;/* RED -BOOST*/
predi8=(predi2+predi3)/2;/* LOG-RFOR */
predi9=(predi2+predi4)/2;/* LOG-BOOST */
predi10=(predi3+predi4)/2;/* RFOR-BOOST */
predi11=(predi1+predi2+predi3)/3;/* RED -LOG-RFOR */
predi12=(predi1+predi2+predi4)/3;/* RED -LOG-BOOST*/
predi13=(predi1+predi3+predi4)/3;/* RED -RFOR-BOOST*/
predi14=(predi2+predi3+predi4)/3;/* LOG-RFOR-BOOST*/
predi15=(predi1+predi2+predi3+predi4)/4;/* RED-LOG-RFOR-BOOST*/
run;

data salfin (keep=&vardepen vardep predi1-predi15 grupo);set unionsal;if grupo=&exclu then output;run;

data salbos (drop=i);
array predi{15};
array ase{15};
set salfin;
do i=1 to 15;
ase{i}=(predi{i}-&vardepen)**2;
end;
run;

data fantasma;set fantasma salbos;run;

%end;  
/* FIN GRUPOS */
proc means data=fantasma noprint;var ase1-ase15;
output out=mediaresi mean=ase1-ase15;
run;
data mediaresi;set mediaresi;semilla=&semilla;run;
data final (keep=ase1-ase15 semilla);set final mediaresi;if ASE1=. then delete;run;
%end;
proc printto; run;
proc print data=final;run;
%mend;


%cruzadastack
(archivo=cali,vardepen=Median_House_value,
listcategor=,
listconti=households housing_median_age latitude longitude median_income population total_bedrooms total_rooms,ngrupos=4,seminicio=12345,semifinal=12350,nodos=10);


data cajas;
array ase{15};
set final;
do i=1 to 15;
modelo=i;
error=ase{i};
output;
end;
run;

/* EN ESTAS OPCIONES SE CAMBIA LA LETRA Y LA ALTURA DEL TEXTO EN LOS EJES CON HTEXT.
options font="Courier New" bold 8;
run;goptions htext=8pt;
*/

proc sort data=cajas;by modelo;
data eti;length eti $ 25;
input modelo eti $;
cards;
1 RED
2 REG
3 RFOR
4 BOOST
5 RREG
6 REDFOR
7 REDBOO
8 REGRFOR
9 REGBOOST
10 RFORBOO
11 R-REG-RFOR
12 R-REG-BOO
13 R-RF-BOO
14 REG-RF-BOO
15 R-REG-RF-BOO
;
data cajas2;merge cajas eti;by modelo;
title1 
h=2 box=1 j=c c=red 'GERMAN CREDIT' j=c ; 

options font="Courier New" bold 8;
run;goptions htext=5pt;

proc boxplot data=cajas2;plot error*ETI /
cboxes        = dagr
cboxfill      = ywh;
/* vaxis=0.20 to 0.35 by 0.01 */
;run;

proc boxplot data=cajas2;plot error*ETI /
cboxes        = dagr
cboxfill      = ywh;
/* vaxis=0.20 to 0.35 by 0.01 */
where (modelo not in (2,3,5,6,8,9,10,11,12,14,15));
;run;

/*data discoc.final1;set final;run;
data discoc.stack1;set cajas2;run;*/

proc print data=cajas2;run;

