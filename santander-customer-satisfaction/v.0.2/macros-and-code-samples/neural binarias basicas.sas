/*
options nocenter;
options mprint=0;


data uno;set 'c:\german.sas7bdat';
if good_bad='bad' then bad=1;if good_bad='good' then bad=0;
run;

*/

/* ***************MACRO neuralbinariabasica*************************

El objetivo de esta macro es obtener un resultado básico de la red
con una sola partición training test. 

Si se quiere estratificacion en el muestreo quitar los comentarios en strata en el interior
de la macro.

NOTA: LA VARIABLE DEPENDIENTE DEBE ESTAR CODIFICADA COMO 0 y 1, SIENDO 1 LA CATEGORÍA DE INTERÉS 

SE FIJAN LOS NODOS, PUNTO DE CORTE, SEMILLA, PORCENTAJE
OBVIAMENTE SE PUEDEN CAMBIAR LAS OPCIONES INTERNAS DEL PROC NEURAL:
PRELIM, TRAIN, ETC.

El archivo que contiene la performance se llama estadisticos.

*/

%macro neuralbinariabasica(archivo=,listconti=,listclass=,vardep=,nodos=,corte=,semilla=,porcen=);

data archivobase;set &archivo nobs=nume;ene=int(&porcen*nume);
call symput('ene',left(ene));
run;

proc sort data=archivobase;by &vardep;run;

proc surveyselect data=archivobase out=muestra outall N=&ene seed=&semilla;
/*si se quiere estratificacion en el muestreo quitar los comentarios en strata*/
/* strata &vardep /alloc=proportional;*/run;
data train valida;set muestra;if selected=1 then output train;else output valida;run;

PROC DMDB DATA=train dmdbcat=cataprueba;
target &vardep;
var &listconti;
class &listclass &vardep;
run;

%if &listclass ne %then %do;
proc neural data=train dmdbcat=cataprueba;
input  &listconti;
input &listclass /level=nominal;
target  &vardep /level=nominal;
hidden &nodos;
prelim 5;
train tech=levmar;
score data=valida out=salpredi outfit=salfit ;
run;
%end;

%else %do;
proc neural data=train dmdbcat=cataprueba;
input  &listconti;
target  &vardep /level=nominal;
hidden &nodos;
prelim 5;
train tech=levmar;
score data=valida out=salpredi outfit=salfit ;
run;
%end;

data salpredi;set salpredi;if p_&vardep.1>&corte/100 then predi1=1;else predi1=0;run;
proc freq data=salpredi;tables predi1*&vardep/out=sal1;run;

/* Cálculo de estadísticos */

data estadisticos (drop=count percent predi1 &vardep);
retain vp vn fp fn suma 0;
set sal1 nobs=nume;
suma=suma+count;
if predi1=0 and &vardep=0 then vn=count;
if predi1=0 and &vardep=1 then fn=count;
if predi1=1 and &vardep=0 then fp=count;
if predi1=1 and &vardep=1 then vp=count;
if _n_=nume then do;
if vn=. then vn=0;if fn=. then fn=0;if vp=. then vp=0;if fp=. then fp=0;
porcenVN=vn/suma;
porcenFN=FN/suma;
porcenVP=VP/suma;
porcenFP=FP/suma;
sensi=vp/(vp+fn);
especif=vn/(vn+fp);
tasafallos=1-(vp+vn)/suma;
tasaciertos=1-tasafallos;
precision=vp/(vp+fp);
if vp=0 then precision=0;
if vp=0 then sensi=0;
if vn=0 then especif=0;
F_M=2*Sensi*Precision/(Sensi+Precision);
output;
end;
run;
proc print data=estadisticos;run;

%mend;


/* EJEMPLO MACRO BINARIABÁSICA 
%neuralbinariabasica(archivo=uno,
listconti=age amount checking coapp depends duration employed existcr foreign ,
listclass=purpose,vardep=bad,nodos=10,corte=50,semilla=12345,porcen=0.80);
*/


/* MACRO NUMERONODOS

UNA MACRO PARA GRAFICAR LAS MEDIDAS DE INTERÉS POR NÚMERO DE NODOS 

DENTRO HE PEGADO LA neuralbinariabasica CON SUS OPCIONES YA ESTABLECIDAS: 
CAMBIAR LO NECESARIO PARA APLICAR LA MISMA IDEA

*/

%macro numeronodos(inicionodos=,finalnodos=,increnodos=);
data union;run;
%do nodos=&inicionodos %to &finalnodos %by &increnodos;
   %neuralbinariabasica(archivo=uno,
   listconti=age amount checking coapp depends duration employed existcr foreign ,
   listclass=purpose,vardep=bad,nodos=&nodos,corte=50,semilla=12345,porcen=0.80);
   data estadisticos;set estadisticos;nodos=&nodos;run;
   data union;set union estadisticos;run;
%end;
data union;set union ;if _n_=1 then delete;run;
symbol v=circle i=join;
proc gplot data=union;plot (porcenVN porcenFN porcenVP porcenFP sensi especif tasafallos tasaciertos precision F_M)*nodos;run;
%mend;


/* EJEMPLO NUMERONODOS 

%numeronodos(inicionodos=3,finalnodos=30,increnodos=3); */


/* MACRO VARIAR: SE VARIA LA SEMILLA PARA OBTENER UN BOXPLOT POR NÚMERO DE NODOS  */

%macro variar(seminicio=,semifin=,inicionodos=,finalnodos=,increnodos=);
data union;run;
%do semilla=&seminicio %to &semifin;
%do nodos=&inicionodos %to &finalnodos %by &increnodos;
   %neuralbinariabasica(archivo=uno,
   listconti=age amount checking coapp depends duration employed existcr foreign ,
   listclass=purpose,vardep=bad,nodos=&nodos,corte=50,semilla=&semilla,porcen=0.80);
   data estadisticos;set estadisticos;nodos=&nodos;semilla=&semilla;run;
   data union;set union estadisticos;run;
%end;
%end;
proc sort data=union;by nodos;run;
proc boxplot data=union;plot (porcenVN porcenFN porcenVP porcenFP 
sensi especif tasafallos tasaciertos precision F_M)*nodos;run;
%mend;

/* EJEMPLO VARIAR 

%variar(seminicio=12345,semifin=12365,inicionodos=2,finalnodos=15,increnodos=3);*/


/* MACRO VARIARBIS

UTILIZO LA MISMA MACRO PERO VARIANDO LA SEMILLA Y EL PUNTO DE CORTE, Y 
CONSERVANDO LA INFORMACIÓN PARA UN BOXPLOT */

%macro variarbis(vardep=,seminicio=,semifin=,inicionodos=,finalnodos=,increnodos=);

data union;run;

%do semilla=&seminicio %to &semifin;
%do nodos=&inicionodos %to &finalnodos %by &increnodos;

%neuralbinariabasica(archivo=uno,
   listconti=age amount checking coapp depends duration employed existcr foreign ,
   listclass=purpose,vardep=bad,nodos=&nodos,corte=50,semilla=&semilla,porcen=0.80);
%do corti=40 %to 70 %by 10;
data salpredi;set salpredi;if p_&vardep.1>&corti/100 then predi1=1;else predi1=0;run;
proc freq data=salpredi;tables predi1*&vardep/out=sal1;run;

/* Cálculo de estadísticos */

data estadisticos (drop=count percent predi1 &vardep);
retain vp vn fp fn suma 0;
set sal1 nobs=nume;
suma=suma+count;
if predi1=0 and &vardep=0 then vn=count;
if predi1=0 and &vardep=1 then fn=count;
if predi1=1 and &vardep=0 then fp=count;
if predi1=1 and &vardep=1 then vp=count;
if _n_=nume then do;
if vn=. then vn=0;if fn=. then fn=0;if vp=. then vp=0;if fp=. then fp=0;
porcenVN=vn/suma;
porcenFN=FN/suma;
porcenVP=VP/suma;
porcenFP=FP/suma;
sensi=vp/(vp+fn);
especif=vn/(vn+fp);
tasafallos=1-(vp+vn)/suma;
tasaciertos=1-tasafallos;
precision=vp/(vp+fp);
if vp=0 then precision=0;
if vp=0 then sensi=0;
if vn=0 then especif=0;
F_M=2*Sensi*Precision/(Sensi+Precision);
output;
end;
run;
   data estadisticos;set estadisticos;nodos=&nodos;semilla=&semilla;corte=&corti;run;
   data union;set union estadisticos;run;

%end;

%end;
%end;

data union;set union;if _n_=1 then delete;
proc sort data=union;by nodos corte;
proc print data=union;run;
data unionfin;retain nivel 0;set union;
by nodos corte;
if first.corte=1 then nivel=nivel+1;
output;
run;
proc print data=unionfin;var nodos corte nivel;run;
proc boxplot data=unionfin;
plot (porcenVN porcenFN porcenVP porcenFP especif tasafallos F_M tasaciertos sensi precision )*nivel;run;

%mend;

/* EJEMPLO VARIARBIS  

%variarbis(vardep=bad,seminicio=12345,
semifin=12348,inicionodos=1,finalnodos=11,increnodos=8); */


/******************************************************************
 MISMAS IDEAS CON PROC LOGISTIC 
/******************************************************************/

%macro binarialogistic(archivo=,listconti=,listclass=,vardep=,corte=,semilla=,porcen=);
/*estratificacion*/
data archivobase;set &archivo nobs=nume;ene=int(&porcen*nume);
call symput('ene',left(ene));
run;

proc sort data=archivobase;by &vardep;run;

proc surveyselect data=archivobase out=muestra outall N=&ene seed=&semilla;
/*strata &vardep / alloc=proportional;*/run;
data train valida;set muestra;if selected=1 then output train;else output valida;run;

data train;set train;control=1;
data valida;set valida;control=0;
data uni;set train valida;
if control=1 then vardepen=&vardep;
else vardepen=.;
run;

%if &listclass ne %then %do;
proc logistic data=uni;
class &listclass;
model vardepen=&listclass &listconti;
output out=sal2 p=proba;
run;
%end;

%else %do;
proc logistic data=uni;
model vardepen=&listconti;
output out=sal2 p=proba;
run;
%end;

data sal2;set sal2;pro=1-proba;if pro>0.5 then pdepen=1; else pdepen=0;run;

proc freq data=sal2;tables pdepen*&vardep /out=sal3;run;

data estadisticos (drop=count percent pdepen &vardep); 
retain vp vn fp fn suma 0; 
set sal3 nobs=nume; 
suma=suma+count; 
if pdepen=0 and &vardep=0 then vn=count; 
if pdepen=0 and &vardep=1 then fn=count; 
if pdepen=1 and &vardep=0 then fp=count; 
if pdepen=1 and &vardep=1 then vp=count; 
if _n_=nume then do; 
porcenVN=vn/suma; 
porcenFN=FN/suma; 
porcenVP=VP/suma; 
porcenFP=FP/suma; 
sensi=vp/(vp+fn); 
especif=vn/(vn+fp); 
tasafallos=1-(vp+vn)/suma; 
tasaciertos=1-tasafallos; 
precision=vp/(vp+fp); 
F_M=2*Sensi*Precision/(Sensi+Precision); 
output; 
end; 
run; 
proc print data=estadisticos;run;

%mend;

/* EJEMPLO 

%binarialogistic(archivo=uno,listconti=age amount checking coapp depends duration employed existcr foreign ,
listclass=purpose,vardep=bad,corte=50,semilla=12345,porcen=0.80); */


/******************************************************************
REPETIR CON DIFERENTES SEMILLAS Y PONER BOXPLOT COMPARATIVO
/******************************************************************/

%macro repbinarialogistic(archivo=,listconti=,listclass=,vardep=,corte=,sinicio=,sfinal=,porcen=);
data union;run;
%do semi=&sinicio %to &sfinal;
 %binarialogistic(archivo=&archivo,listconti=&listconti,listclass=&listclass,vardep=&vardep,corte=&corte,semilla=&semi,porcen=&porcen);
 data estadisticos;set estadisticos;semilla=&semi;run;
 data union;set union estadisticos;run;
%end;
data union;set union;if _n_=1 then delete;run;
proc print data=union;run;
%mend;


/* EJEMPLO 

%repbinarialogistic(archivo=uno,listconti=age amount checking coapp depends duration employed existcr foreign ,
listclass=purpose,vardep=bad,corte=50,sinicio=12345,sfinal=12355,porcen=0.80);
data uni1;set union;modelo=1;
%repbinarialogistic(archivo=uno,listconti=age amount checking coapp depends duration,
vardep=bad,corte=50,sinicio=12345,sfinal=12355,porcen=0.80);
data uni2;set union;modelo=2;

data unitodos;set uni1 uni2;
proc boxplot data=unitodos;plot tasafallos*modelo;run; */

/* MISMO EJEMPLO AÑADIENDO RED */

%macro repneuralbinariabasica(archivo=,listconti=,listclass=,vardep=,nodos=,corte=,sinicio=,sfinal=,porcen=);
data union;run;
%do semi=&sinicio %to &sfinal;
 %neuralbinariabasica(archivo=&archivo,listconti=&listconti,listclass=&listclass,vardep=&vardep,nodos=&nodos,corte=&corte,semilla=&semi,porcen=&porcen);
 data estadisticos;set estadisticos;semilla=&semi;run;
 data union;set union estadisticos;run;
%end;
data union;set union;if _n_=1 then delete;run;
proc print data=union;run;
%mend;

/* EJEMPLO 

%repneuralbinariabasica(archivo=uno,listconti=age amount checking coapp depends duration,
vardep=bad,nodos=5,corte=50,sinicio=12345,sfinal=12355,porcen=0.80);
data uni3;set union;modelo=3;

data unitodos;set uni1 uni2 uni3;
proc boxplot data=unitodos;plot tasafallos*modelo;run;

*/






















