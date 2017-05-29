/****************************************************
/* ENSAMBLADO DE MODELOS 

TÉCNICAS CON SAS

Cada procedimiento tiene un tipo de archivo de salida
y nombra la variable predicha a su manera.

Nos centraremos en ensamblado de las predicciones test para variable 
dependiente binaria que está codificada en 0-1.

Las predicciones representarán la probabilidad de 1.

Supongamos que tenemos divididos los datos en train y valida mediante por
ejemplo un proc surveyselect:

proc surveyselect data=uno out=muestra method=srs n=800 outall seed=12345;
data train valida;set muestra; if selected=1 then output train;else output valida;run;

********************************************************************
ARCHIVOS DE SALIDA DE PREDICCIONES DE LOS DIFERENTES PROCEDIMIENTOS
********************************************************************

PROC NEURAL data=train...;
...
score data=valida role=test out=sal ;

La variable predicha se llama p_nombrevar1, donde nombrevar es el nombre original de 
la variable a predecir.

PROC LOGISTIC data=train...;
...
score data=valida out=sal ;
La variable predicha se llama p_1

PROC HPFOREST (EN ESTE DEFINIR LEVEL=BINARY EN LA DEPENDIENTE )

	En este procedimiento solo se puede utilizar un archivo:
	Es necesario utilizar una variable dependiente de paso que es missing en los datos test.
	Después se predice todo el archivo y nos quedamos solo con los datos test.

	Por ejemplo si la variable dependiente se llama bad:

	data muestra;set muestra;if selected=1 then vardep=bad;else vardep=.;run;

	PROC HPFOREST data=muestra
	...
	score out=sal ;
	run;

	data predicciones;set sal;if vardep=.;run;

	La variable predicha se llama p_vardep

PROC TREEBOOST data=train...;
...
score data=valida out=sal ;

La variable predicha se llama p_vardep1

PARA K-NN se utiliza el mismo truco que para HPFOREST:

PROC DISCRI data=muestra noprint method=npar k=5 out=sal;
...
run;

La variable predicha se llama _1

PROC SVM data=train ... testdata=valida ... testout=sal;
...
run;

El problema con SVM es que no da probabilidades. La variable de predicción es _i_ (0,1)

/**********************************************/



/*******************************************************************
PARA ENSAMBLAR DOS MODELOS Y PROBARLOS CON DATOS train, valida HAY QUE:

1) Obtener las predicciones de cada uno de ellos para los datos valida
2) Unir los dos archivos de predicciones con un merge y en ese mismo paso 
data, promediar ambas predicciones (ponderado o no) .
3) Obtener matriz confusión y medidas de diagnóstico para esa predicción obtenida.
/*******************************************************************/


/* EJEMPLO 1:Ensamblo red y logística 

Para todos los ejemplos creo train valida (para evitar errores pongo bad como numérica):

data uno;set discoc.germanmod;bad2=bad*1;drop bad;run;
data uno;Set uno;bad=bad2;drop bad2;run;

proc surveyselect data=uno out=muestra method=srs n=800 outall seed=2000;
data train valida;set muestra; if selected=1 then output train;else output valida;run; 

*/

proc printto print='c:\ko.txt';run;
PROC DMDB DATA=train dmdbcat=catatres;
target bad;
var age amount checking duration installp savings;
class foreign history marital other purpose bad;
run;
proc neural data=train dmdbcat=catatres random=789 ;
input age amount checking duration installp savings;
input foreign history marital other purpose/level=nominal;
target bad /level=nominal;
hidden 10 /act=tanh;
netoptions randist=normal ranscale=0.15 random=15459;
prelim 15 preiter=10 pretech=bprop mom=0.2 learn=0.7;
train maxiter=100 technique=bprop mom=0.2 learn=0.7;
score data=valida role=test out=sal1;
run;


proc logistic data=train ;
class foreign history marital other purpose;
model bad=foreign history marital other purpose age amount checking duration installp savings;
score data=valida out=sal2;
run;

data union;merge sal1 sal2;pensemble=(p_bad1+p_1)/2;run;

data salfin;set union;
if p_bad1>0.5 then prered=1; else prered=0;
if p_1>0.5 then prelog=1; else prelog=0;
if pensemble>0.5 then prensemble=1; else prensemble=0;
run;

proc freq data=salfin;tables prered*bad/out=s1;run;
proc freq data=salfin;tables prelog*bad/out=s2;run;
proc freq data=salfin;tables prensemble*bad/out=s3;run;

data estadisticos1(drop=count percent prered ); 
		retain vp vn fp fn suma 0; 
		set s1 nobs=nume; 
		suma=suma+count; 
		if prered=0 and bad=0 then vn=count; 
		if prered=0 and bad=1 then fn=count; 
		if prered=1 and bad=0 then fp=count; 
		if prered=1 and bad=1 then vp=count; 
		if _n_=nume then do; 
		tasafallos=1-(vp+vn)/suma; 
		modelo='RED';
		output; 
		end; 
run; 
data estadisticos2(drop=count percent prered ); 
		retain vp vn fp fn suma 0; 
		set s2 nobs=nume; 
		suma=suma+count; 
		if prelog=0 and bad=0 then vn=count; 
		if prelog=0 and bad=1 then fn=count; 
		if prelog=1 and bad=0 then fp=count; 
		if prelog=1 and bad=1 then vp=count; 
		if _n_=nume then do; 
		tasafallos=1-(vp+vn)/suma; 
		modelo='LOG';
		output; 
		end; 
run; 
data estadisticos3(drop=count percent prered ); 
		retain vp vn fp fn suma 0; 
		set s3 nobs=nume; 
		suma=suma+count; 
		if prensemble=0 and bad=0 then vn=count; 
		if prensemble=0 and bad=1 then fn=count; 
		if prensemble=1 and bad=0 then fp=count; 
		if prensemble=1 and bad=1 then vp=count; 
		if _n_=nume then do; 
		tasafallos=1-(vp+vn)/suma; 
		modelo='ENSEMBLE';
		output; 
		end; 
run; 

data u;set estadisticos1 estadisticos2 estadisticos3;run;
title 'ENSEMBLE RED-LOG';
proc print data=u;run;

/* EJEMPLO 2:Ensamblo red logística y Random forest 

Se aprovecha lo anterior y se añade a union y salfin la prediccion de random forest,
haciendo después el proc freq y calculo de tasafallos.

Desgraciadamente hay que poner interval en la dependiente para evitar que 
considere los missing como categoría

*/
options notes;
proc printto;run;
options mprint=0;

data muestra;set muestra;if selected=1 then vardep=bad*1;else vardep=.;run;

proc hpforest data=muestra
maxtrees=100 
vars_to_try=5
trainfraction=0.7
leafsize=8
maxdepth=10
exhaustive=5000 
missing=useinsearch ;
target vardep/level=interval;
input age amount checking duration installp savings/level=interval;   
input foreign history marital other purpose/level=nominal;
score out=salo;
run;

data salo;set salo;if vardep=.;keep p_vardep;run;

data union;merge sal1 sal2 salo;pensemble=(p_bad1+p_1+p_vardep)/3;run;

data salfin;set union;
if p_bad1>0.5 then prered=1; else prered=0;
if p_1>0.5 then prelog=1; else prelog=0;
if p_vardep>0.5 then preforest=1; else preforest=0;
if pensemble>0.5 then prensemble=1; else prensemble=0;
run;

proc print data=salfin;run;

proc freq data=salfin;tables preforest*bad/out=s4;run;
proc freq data=salfin;tables prensemble*bad/out=s3;run;

data estadisticos4; 
		retain vp vn fp fn suma 0; 
		set s4 nobs=nume; 
		suma=suma+count; 
		if preforest=0 and bad=0 then vn=count; 
		if preforest=0 and bad=1 then fn=count; 
		if preforest=1 and bad=0 then fp=count; 
		if preforest=1 and bad=1 then vp=count; 
		if _n_=nume then do; 
		tasafallos=1-(vp+vn)/suma; 
		modelo='FOREST';
		output; 
		end; 
run; 
data estadisticos3(drop=count percent prered ); 
		retain vp vn fp fn suma 0; 
		set s3 nobs=nume; 
		suma=suma+count; 
		if prensemble=0 and bad=0 then vn=count; 
		if prensemble=0 and bad=1 then fn=count; 
		if prensemble=1 and bad=0 then fp=count; 
		if prensemble=1 and bad=1 then vp=count; 
		if _n_=nume then do; 
		tasafallos=1-(vp+vn)/suma; 
		modelo='ENSEMBLE';
		output; 
		end; 
run; 
title 'ENSEMBLE RED-LOG-FOREST';
data u;set estadisticos1 estadisticos2 estadisticos3 estadisticos4;run;

proc print data=u;run;


/* EJEMPLO 3: MACRO

Ensamblo red logística y Random forest con diferentes semillas y guardo la información
para un diagrama de cajas
*/
ods trace off;

%macro repetir(sinicio=,sfinal=);

data uno;set discoc.germanmod;bad2=bad*1;drop bad;run;
data uno;Set uno;bad=bad2;drop bad2;run;
data todos;run;

%do sem=&sinicio %to &sfinal;

proc surveyselect data=uno out=muestra method=srs n=800 outall seed=&sem;
data train valida;set muestra; if selected=1 then output train;else output valida;run; 

PROC DMDB DATA=train dmdbcat=catatres;
target bad;
var age amount checking duration installp savings;
class foreign history marital other purpose bad;
run;
proc neural data=train dmdbcat=catatres random=789 ;
input age amount checking duration installp savings;
input foreign history marital other purpose/level=nominal;
target bad /level=nominal;
hidden 10 /act=tanh;
netoptions randist=normal ranscale=0.15 random=15459;
prelim 15 preiter=10 pretech=bprop mom=0.2 learn=0.7;
train maxiter=100 technique=bprop mom=0.2 learn=0.7;
score data=valida role=test out=sal1;
run;


proc logistic data=train ;
class foreign history marital other purpose;
model bad=foreign history marital other purpose age amount checking duration installp savings;
score data=valida out=sal2;
run;

data muestra;set muestra;if selected=1 then vardep=bad*1;else vardep=.;run;

proc hpforest data=muestra
maxtrees=100 
vars_to_try=5
trainfraction=0.7
leafsize=8
maxdepth=10
exhaustive=5000 
missing=useinsearch ;
target vardep/level=interval;
input age amount checking duration installp savings/level=interval;   
input foreign history marital other purpose/level=nominal;
score out=salo;
run;

data salo;set salo;if vardep=.;keep p_vardep;run;

data union;merge sal1 sal2 salo;pensemble=(p_bad1+p_1+p_vardep)/3;run;

data salfin;set union;
if p_bad1>0.5 then prered=1; else prered=0;
if p_1>0.5 then prelog=1; else prelog=0;
if p_vardep>0.5 then preforest=1; else preforest=0;
if pensemble>0.5 then prensemble=1; else prensemble=0;
run;

proc freq data=salfin;tables preforest*bad/out=s4;run;
proc freq data=salfin;tables prensemble*bad/out=s3;run;
proc freq data=salfin;tables prered*bad/out=s1;run;
proc freq data=salfin;tables prelog*bad/out=s2;run;

data estadisticos1(drop=count percent prered ); 
length modelo $ 20;
		retain vp vn fp fn suma 0; 
		set s1 nobs=nume; 
		suma=suma+count; 
		if prered=0 and bad=0 then vn=count; 
		if prered=0 and bad=1 then fn=count; 
		if prered=1 and bad=0 then fp=count; 
		if prered=1 and bad=1 then vp=count; 
		if _n_=nume then do; 
		tasafallos=1-(vp+vn)/suma; 
		modelo='RED';
		output; 
		end; 
run; 
data estadisticos2(drop=count percent prered ); length modelo $ 20;
		retain vp vn fp fn suma 0; 
		set s2 nobs=nume; 
		suma=suma+count; 
		if prelog=0 and bad=0 then vn=count; 
		if prelog=0 and bad=1 then fn=count; 
		if prelog=1 and bad=0 then fp=count; 
		if prelog=1 and bad=1 then vp=count; 
		if _n_=nume then do; 
		tasafallos=1-(vp+vn)/suma; 
		modelo='LOG';
		output; 
		end; 
run; 

data estadisticos4; length modelo $ 20;
		retain vp vn fp fn suma 0; 
		set s4 nobs=nume; 
		suma=suma+count; 
		if preforest=0 and bad=0 then vn=count; 
		if preforest=0 and bad=1 then fn=count; 
		if preforest=1 and bad=0 then fp=count; 
		if preforest=1 and bad=1 then vp=count; 
		if _n_=nume then do; 
		tasafallos=1-(vp+vn)/suma; 
		modelo='FOREST';
		output; 
		end; 
run; 
data estadisticos3(drop=count percent prered ); length modelo $ 20;
		retain vp vn fp fn suma 0; 
		set s3 nobs=nume; 
		suma=suma+count; 
		if prensemble=0 and bad=0 then vn=count; 
		if prensemble=0 and bad=1 then fn=count; 
		if prensemble=1 and bad=0 then fp=count; 
		if prensemble=1 and bad=1 then vp=count; 
		if _n_=nume then do; 
		tasafallos=1-(vp+vn)/suma; 
		modelo='ENSEMBLE';
		output; 
		end; 
run; 
title 'ENSEMBLE RED-LOG-FOREST';

data union2;merge sal1 sal2 salo;pensembleredforest=(p_bad1+p_vardep)/2;run;

data salfin;set union2;
if pensembleredforest>0.5 then prensembleredforest=1; else prensembleredforest=0;
run;

proc freq data=salfin;tables prensembleredforest*bad/out=s5;run;
data estadisticos5(drop=count percent prered ); length modelo $ 20;
		retain vp vn fp fn suma 0; 
		set s5 nobs=nume; 
		suma=suma+count; 
		if prensembleredforest=0 and bad=0 then vn=count; 
		if prensembleredforest=0 and bad=1 then fn=count; 
		if prensembleredforest=1 and bad=0 then fp=count; 
		if prensembleredforest=1 and bad=1 then vp=count; 
		if _n_=nume then do; 
		tasafallos=1-(vp+vn)/suma; 
		modelo='RFOR';
		output; 
		end; 
run; 

data u;set estadisticos1 estadisticos2 estadisticos3 estadisticos4 estadisticos5;run;
data todos;set todos u;run;

%end;
ods listing;
proc print data=todos;run;
proc sort data=todos;by modelo;
proc boxplot data=todos;plot tasafallos*modelo;run;
%mend;


options mprint=0;
options notes;
proc printto print='c:\ko2.txt';run;
proc printto;run;

%repetir(sinicio=2000,sfinal=2010);



