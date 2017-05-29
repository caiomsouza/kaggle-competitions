/* 
MACRO CRUZADASTACK PARA BINARIA

HACE VALIDACIÓN CRUZADA CON LOS SIGUIENTES MÉTODOS:

RED NEURONAL (parámetro nodos de la macro; cualquier otra especificación 
				de la red como algoritmo, iteraciones, activación, etc. se cambia dentro del código)
LOGÍSTICA

RANDOM FOREST

GRADIENT BOOSTING (párámetros itera y v)

1) LA MACRO SE PUEDE CAMBIAR A CONVENIENCIA INTERNAMENTE, SOBRE TODO LOS PARÁMETROS DE LA RED NEURONAL, boosting, etc.

2) SI NO HAY VARIABLES DE CLASE EN EL ARCHIVO:

	A) QUITAR TODOS LOS APARTADOS CLASS O PONER * AL PRINCIPIO PARA QUE APAREZCA COMO COMENTARIO
	B) BORRAR &LISTCATEGOR DE TODA LA MACRO

*/

%macro cruzadastack
(archivo=,vardepen=,listcategor=,listconti=,ngrupos=,seminicio=,semifinal=,nodos=10);
data final;run;
*proc printto print='c:\ca.txt' log='c:\loga.txt';run;
%do semilla=&seminicio %to &semifinal;/*<<<<<******AQUI SE PUEDEN CAMBIAR LAS SEMILLAS */
data dos;set &archivo;u=ranuni(&semilla);
proc sort data=dos;by u;run;

data dos (drop=nume);
retain grupo 1;
set dos nobs=nume;
if _n_>grupo*nume/&ngrupos then grupo=grupo+1;
run;

data fantasma;run;
data unionsalfin;run;
data unifin;run;

%do exclu=1 %to &ngrupos;

data tres;set dos;if grupo ne &exclu then vardep=&vardepen*1;run;


/*************************************************************/
/* LOGISTICA */
proc logistic data=tres noprint;/*<<<<<******SE PUEDE QUITAR EL NOPRINT */
class &listcategor;
model vardep=&listconti &listcategor;
score out=saco;
;run;
/*************************************************************/

data sal1 (drop=p_1);set saco;predi1=p_1;run;
 
/*************************************************************/
/*RED */
PROC DMDB DATA=tres dmdbcat=catatres;
target vardep ;
var &listconti;
class vardep &listcategor;
;run;
proc neural data=tres dmdbcat=catatres ;
input &listconti/ id=i;
input &listcategor /level=nominal;
target vardep/ id=o level=nominal;
hidden &nodos/ id=h act=tanh;
netoptions randist=normal ranscale=0.15 random=15459;
prelim 15 preiter=10 pretech=bprop mom=0.2 learn=0.7;
train maxiter=100 technique=bprop mom=0.2 learn=0.7;
score data=tres out=salred;
run;

data sal2 (keep=&vardepen predi2 grupo vardep);set salred;predi2=p_vardep1;run;

/*************************************************************/
/*RANDOM FOREST*/
/*************************************************************/

proc hpforest data=tres
maxtrees=100 
vars_to_try=13
trainfraction=0.7
leafsize=3
maxdepth=20
exhaustive=5000 
missing=useinsearch ;
target vardep/level=nominal;
input &listconti/level=interval;   
input &listcategor/level=nominal;
score out=salo;
run;

data sal3 (keep=&vardepen predi3 grupo vardep);set salo;predi3=p_vardep1;run;

/*************************************************************/
/*GRADIENT BOOSTING */
/*************************************************************/

	proc treeboost data=tres
	exhaustive=1000 intervaldecimals=max
	leafsize=5 iterations=1000 maxbranch=2
	maxdepth=10 mincatsize=10 missing=useinsearch shrinkage=0.05
	splitsize=10; 
	input &listcategor/level=nominal;
	input &listconti/level=interval;
	target vardep /level=binary;
	subseries largest;
	score out=salboost;
run;
data sal4 (keep=&vardepen predi4 grupo vardep);set salboost;predi4=p_vardep1;run;


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
predi17=(predi1*0.2+predi2*0.1+predi3*0.5+predi4*0.2);/* RED-LOG-RFOR-BOOST ponderado*/
run;

proc logistic data=unionsal;
class &listcategor;
model vardep=predi1 predi3 predi4 &listconti &listcategor/stepwise;
score out=saco;
run;

data salfin (keep=&vardepen vardep predi1-predi17 grupo);set saco;predi16=p_1;if grupo=&exclu then output;run;

data unionsalfin;set unionsalfin salfin;run;

data salbis;
array predi{17};
array pre{17};
set salfin;
do i=1 to 17;
if predi{i}>0.5 then pre{i}=1;
if predi{i}<=0.5 then pre{i}=0;
end;
run;
data salbos;run;
%do j=1 %to 17;
proc freq data=salbis noprint;tables pre&j*&vardepen /out=salconfu;run;
data confu&j (keep=tasa&j);retain buenos 0 malos 0;set salconfu nobs=nume;
if &vardepen=pre&j then buenos=buenos+count;
if &vardepen ne pre&j then malos=malos+count;
if _n_=nume then do;tasa&j=malos/(malos+buenos);output;end;
run;
data salbos;merge salbos confu&j;run;
;
%end;

data fantasma;set fantasma salbos;run;

%end;  
/* FIN GRUPOS */
proc means data=fantasma noprint;var tasa1-tasa17;
output out=mediaresi mean=ase1-ase17 ;
run;
data mediaresi;set mediaresi;semilla=&semilla;run;
data final (keep=ase1-ase17 semilla);set final mediaresi;if ASE1=. then delete;run;

data unifin;set unifin unionsalfin;run;
%end;
proc printto; run;
proc print data=final;run;
%mend;

libname discoc 'c:\';
data uno;set discoc.germanmod;bad2=bad*1;drop bad;run;
data uno;Set uno;bad=bad2;drop bad2;run;

%cruzadastack(archivo=uno,
vardepen=bad,listcategor= telephon history other job property ,
listconti=age amount checking duration employed installp resident savings ,
ngrupos=4,seminicio=22345,semifinal=22360);

/* SOLO PARA COMPROBAR CORRELACIONES PRINCIPALES ALGORITMOS */


/* CORRELACIONES ENTRE PREDICCIONES PUNTUALES ULTIMA SEMILLA Y GRUPO*/
proc corr data=salfin;var predi1-predi4;run;

/* CORRELACIONES ENTRE ERRORES POR SEMILLA */
proc corr data=final;var ase1-ase4;run;

/*PREPARACION GRAFICO Y ETIQUETAS */

data cajas;
array ase{17};
set final;
do i=1 to 17;
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
data eti;length eti $ 13;
input modelo eti $;
cards;
1 RED
2 LOG
3 RFOR
4 BOOST
5 RLOG
6 REDFOR
7 REDBOO
8 LRFOR
9 LBOOST
10 RFORBOO
11 R-L-RFOR
12 R-L-BOO
13 R-RF-BOO
14 L-RF-BOO
15 R-L-RF-BOO
16 L(RRFBOO)
17 15ponde
;
data cajas2;merge cajas eti;by modelo;
title1 
h=2 box=1 j=c c=red 'GERMAN CREDIT' j=c ; 

options font="Courier New" bold 8;
run;goptions htext=5pt;

ods graphics off;

proc boxplot data=cajas2;plot error*ETI /
cboxes        = dagr
cboxfill      = ywh;
/* vaxis=0.20 to 0.35 by 0.01 */
;run;

proc boxplot data=cajas2;plot error*ETI /
cboxes        = dagr
cboxfill      = ywh;
/* vaxis=0.20 to 0.35 by 0.01 */
where (modelo ne 16);
;run;

/*data discoc.final1;set final;run;
data discoc.stack1;set cajas2;run;*/

data unifin;set unifin;if bad=. then delete;
RED=predi1;
LOG=predi2;
RFOR=predi3;
BOOST=predi4;
ENSAMBLADO=predi15;
run;

symbol v=dot;
axis1 order=0 to 1;
proc gplot data=unifin;
plot RED*LOG=bad RED*RFOR=bad RED*BOOST=bad LOG*RFOR=bad LOG*BOOST=bad RFOR*BOOST=bad
RED*ENSAMBLADO=bad
LOG*ENSAMBLADO=bad
RFOR*ENSAMBLADO=bad
BOOST*ENSAMBLADO=bad
/
vaxis=axis1 haxis=axis1 href=0.5 vref=0.5;
run;

