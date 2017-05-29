
/* Bagging básico para variable dependiente continua

Algoritmo bagging
1) Seleccionar con reemplazo tamaño N (también vale sin reemplazo otro tamaño pequeño quizá)
2) Ajustar un árbol (débil, 6 hojas finales por ejemplo)
3) Promediar todos los árboles 

La macro bagging además subdivide el archivo en datos de entrenamiento y test. 


El archivo de salida final contiene el ASE para los datos test.

-----------------------------------------------------------------------------
Parámetros:

	DATOS

	archivo
	vardep
	listconti
	listcategor

	TRAINING-TEST

	semilla1=semilla para dividir en datos training-test
	porcen1=porcentaje de datos training (se puede poner 1 para no usar datos test)

	ÁRBOL
	maxbranch=divisiones máximas en cada nodo (por defecto 2=arboles binarios)
	nleaves=número de hojas finales del árbol
	tamhoja=número de observaciones mínimas por nodo final

	PARÁMETROS ESPECÍFICOS DEL BAGGING (el número de iteraciones es semfinal-seminicial)

	sinicial=semilla inicial
	sfinal=semilla final
	porcenbag=porcentaje de datos a utilizar en cada iteración (con reemplazo puede ser igual a 1)
	reemplazo=1 si se utiliza con reemplazamiento (bagging clásico), 0 sin reemplazamiento.

	OTROS
	LISTALOG=1 si se quiere el error y semilla en el LOG; ADEMÁS PONE GRÁFICO DE ITERACIONES
	COMPARA=1 si se quiere comparar con regresión

-----------------------------------------------------------------------------

*/


%macro bagging(archivo=,vardep=,listconti=,listcategor=,semilla1=12345,porcen1=0.80,
sinicial=12345,sfinal=12355,porcenbag=0.80,maxbranch=2,nleaves=6,tamhoja=5,reemplazo=1,listalog=1,compara=1);
data acumula;run;
%if &listalog=1 %then %do;options nonotes;dm 'log; ' continue;%end;
/* división train test */
proc surveyselect data=&archivo out=muestra1 outall method=srs seed=&semilla1 samprate=&porcen1 noprint;run;
data entreno testeo;set muestra1;if selected=1 then output entreno;else output testeo;run;
%if &porcen1=1 %then %do;data testeo;set entreno;run;%end;

/* bagging: */
%do semilla=&sinicial %to &sfinal;
data;
numero=&semilla-&sinicial+1;call symput('numero',left(numero));
total=&sfinal-&sinicial+1;call symput('total',left(total));
run;
%if &reemplazo=0 %then %do;
proc surveyselect data=entreno out=muestra2 outall method=srs seed=&semilla samprate=&porcenbag noprint;run;
%end;
%else %do;
proc surveyselect data=&archivo out=muestra2 outall method=urs seed=&semilla samprate=&porcenbag noprint;run;
%end;
data entreno1 ;set muestra2;if selected=1 then output entreno1;run;

proc arbor data=entreno1 criterion=Probf; 
input &listconti/level=interval;
%if (&listcategor ne) %then %do;
	input &listcategor/level=nominal;
	%end;
target &vardep /level=interval;
interact largest;
train maxbranch=&maxbranch leafsize=&tamhoja;
subtree nleaves=&nleaves;/* número máximo de hojas finales del subárbol elegido: BEST, LARGEST, nleaves=nhojas */
score data=muestra1 out=sal;/* archivo de salida con predicciones y variables de pertenencia a nodos */
run;
data sal;set sal;vardepen&numero=p_&vardep;run;
/*
%if &numero=1 %then %do;data uni;set sal;keep vardepen1-vardepen&numero &vardep;run;%end;
%else %do;data uni; merge uni sal;keep vardepen1-vardepen&numero &vardep;run;%end;

%end;
data uni;merge uni muestra1;ypredi=mean(of vardepen1-vardepen&total);run;
*/
%if &numero=1 %then %do;data uni;set sal;ypredi=vardepen&numero;keep ypredi;run;%end;
%else %do;data uni; merge uni sal;ypredi=vardepen&numero+ypredi;keep ypredi;run;%end;


%if &listalog=1 %then %do;
data VER;merge uni muestra1;ypredi=ypredi/&numero;error=(&vardep-ypredi)**2;if selected=0;run;
proc means data=ver noprint;var error;output out=salerror mean=media;run;
data salerror;set salerror;call symput('error',left(media));semilla=&semilla;run;
data acumula;set acumula salerror;run;
	/* esto es un truco para escribir en rojo en el LOG */
	%put ER%str(ROR-) &semilla &error;
%end;


%end;
data uni ;merge uni muestra1;ypredi=ypredi/&total;error=(&vardep-ypredi)**2;run;
title "BAGGING &sinicial - &sfinal . Iteraciones=&total ";
proc sort data=uni;by selected;
proc means data=uni;var error;output out=final mean=media;by selected;run;
data final;set final;if selected=0;run;
%if &compara=1 %then %do;

title 'RESULTADOS REGRESIÓN'; 

proc glmselect data=entreno noprint;
%if (&listcategor ne) %then %do;class &listcategor;
model &vardep=&listcategor &listconti/selection=none;%end;
%else %do;model &vardep=&listconti /selection=none;%end;
score data=muestra1 out=saltesteo predicted=P_&vardep;
run;
data saltesteo;set saltesteo;error=(P_&vardep-&vardep)**2;run;
proc sort data=saltesteo;by selected;
proc means data=saltesteo;var error;by selected;run;

%end;

%if &listalog=1 %then %do;
title "BAGGING iteraciones=&total porcenbag=&porcenbag maxbranch=&maxbranch nleaves=&nleaves tamhoja=&tamhoja";
symbol v=circle i=join;
proc gplot data=acumula;plot media*semilla;run;
%end;

%mend;

/* Ejemplo regresión

data fev;set discoc.fev;run;

options notes;
proc printto;run;
options mprint=0;
%bagging(archivo=fev,vardep=FEV,listconti=age height,listcategor=sex smoker,semilla1=12345,porcen1=0.80,
sinicial=12345,sfinal=12400,porcenbag=0.60,maxbranch=8,nleaves=12,tamhoja=2,reemplazo=1,listalog=1,compara=1);
proc printto;run;

symbol i=none;
axis1  length=7.3in order=(0 to 7);
proc gplot data=uni;plot ypredi*fev fev*fev /overlay haxis=axis1 vaxis=axis1;where selected=1;run;
proc gplot data=uni;plot ypredi*fev fev*fev /overlay haxis=axis1 vaxis=axis1;where selected=0;run;

*/

 

/* Bagging básico para variable dependiente BINARIA

LA VARIABLE BINARIA CODIFICADA EN 0-1

Algoritmo bagging
1) Seleccionar con reemplazo tamaño N (también vale sin reemplazo otro tamaño pequeño quizá)
2) Ajustar un árbol (débil, 6 hojas finales por ejemplo)
3) Promediar todos los árboles 

La macro bagging además subdivide el archivo en datos de entrenamiento y test. 

El archivo de salida final contiene la tasa de fallos para los datos test.

-----------------------------------------------------------------------------
Parámetros:

	DATOS

	archivo
	vardep
	listconti
	listcategor

	TRAINING-TEST

	semilla1=semilla para dividir en datos training-test
	porcen1=porcentaje de datos training (se puede poner 1 para no usar datos test)

	ÁRBOL
	maxbranch=divisiones máximas en cada nodo (por defecto 2=arboles binarios)
	nleaves=número de hojas finales del árbol
	tamhoja=número de observaciones mínimas por nodo final

	PARÁMETROS ESPECÍFICOS DEL BAGGING (el número de iteraciones es semfinal-seminicial)

	sinicial=semilla inicial
	sfinal=semilla final
	porcenbag=porcentaje de datos a utilizar en cada iteración (con reemplazo puede ser igual a 1)
	reemplazo=1 si se utiliza con reemplazamiento (bagging clásico), 0 sin reemplazamiento.

	OTROS

	LISTALOG=1 si se quiere el error y semilla en el LOG
	COMPARA=1 si se quiere comparar con logística
-----------------------------------------------------------------------------

*/

%macro baggingbin(archivo=,vardep=,listconti=,listcategor=,semilla1=12345,porcen1=0.80,
sinicial=12345,sfinal=12355,porcenbag=0.80,maxbranch=2,nleaves=6,tamhoja=5,reemplazo=1,listalog=1,compara=1);
data acumula;run;
%if &listalog=1 %then %do;dm 'log; ' continue;options nonotes;%end;
/* división train test */
proc surveyselect data=&archivo out=muestra1 outall method=srs seed=&semilla1 samprate=&porcen1 noprint;run;
data entreno testeo;set muestra1;if selected=1 then output entreno;else output testeo;drop selected;run;
%if &porcen1=1 %then %do;data testeo;set entreno;run;%end;

/* bagging: */
%do semilla=&sinicial %to &sfinal;
data;
numero=&semilla-&sinicial+1;call symput('numero',left(numero));
total=&sfinal-&sinicial+1;call symput('total',left(total));run;

	%if &reemplazo=0 %then %do;
	proc surveyselect data=entreno out=muestra2 outall method=srs seed=&semilla samprate=&porcenbag noprint;run;
	%end;
	%else %do;
	proc surveyselect data=entreno out=muestra2 outall method=urs seed=&semilla samprate=&porcenbag noprint;run;
	%end;
data entreno1 ;set muestra2;if selected=1 then output entreno1;drop selected;run;

proc arbor data=entreno1 ; 
input &listconti/level=interval;
%if (&listcategor ne) %then %do;
	input &listcategor/level=nominal;
	%end;
target &vardep /level=nominal;
interact largest;
train maxbranch=&maxbranch leafsize=&tamhoja;
subtree nleaves=&nleaves;/* número máximo de hojas finales del subárbol elegido: BEST, LARGEST, nleaves=nhojas */
score data=muestra1 out=sal;/* archivo de salida con predicciones y variables de pertenencia a nodos */
run;
data sal;set sal;vardepen&numero=p_&vardep.1;run;
/*
%if &numero=1 %then %do;data uni;set sal;keep vardepen1-vardepen&numero &vardep;run;%end;
%else %do;data uni; merge uni sal;keep vardepen1-vardepen&numero &vardep;run;%end;
%end;
data uni;merge uni muestra1;ypredi=mean(of vardepen1-vardepen&total);run;
*/
%if &numero=1 %then %do;data uni;set sal;ypredi=vardepen&numero;keep ypredi;run;%end;
%else %do;data uni; merge uni sal;ypredi=vardepen&numero+ypredi;keep ypredi;run;%end;

%if &listalog=1 %then %do;
	data VER;merge uni muestra1;ypredi=ypredi/&numero;
	if ypredi>0.5 then ypredi=1;else ypredi=0;
	newvar2=&vardep*1;
	if ypredi=newvar2 then error=0;else error=1;if selected=0;
	run;
	proc means data=ver noprint;var error;output out=salerror mean=media;run;
	data salerror;set salerror;call symput('error',left(media));semilla=&semilla;run;
	data acumula;set acumula salerror;run;
	/* esto es un truco para escribir en rojo en el LOG */
	%put ER%str(ROR-) &semilla &error;
%end;

%end;
data uni ;merge uni muestra1;ypredi=ypredi/&total;
if ypredi>0.5 then ypredi=1;else ypredi=0;error=abs(&vardep-ypredi);run;
proc sort data=uni;by selected;
title "BAGGING &sinicial - &sfinal . Iteraciones=&total ";
proc means data=uni;var error;output out=final mean=media;by selected;run;
data final;set final;if selected=0;run;

%if &compara=1 %then %do;

title 'RESULTADOS LOGISTICA'; 
proc logistic data=entreno descending noprint;
%if (&listcategor ne) %then %do;class &listcategor;
model &vardep=&listcategor &listconti;%end;
%else %do;model &vardep=&listconti;%end;
score data=muestra1 out=saltesteo;
run;
data saltesteo;set saltesteo;error=abs(I_&vardep-&vardep);run;
proc sort data=saltesteo;by selected;
proc means data=saltesteo;var error;by selected;output out=final2 mean=media;run;
data final2;set final2;if selected=0;run;
%end;

%if &listalog=1 %then %do;
title "BAGGING iteraciones=&total porcenbag=&porcenbag maxbranch=&maxbranch nleaves=&nleaves tamhoja=&tamhoja";
symbol v=circle i=join;
proc gplot data=acumula;plot media*semilla;run;
%end;


%mend;


/* ejemplo bagging binaria 

data uno;set discoc.germanmod;run;

options spool ;
proc printto ;run;
options mprint=0;

options notes;


%baggingbin(archivo=uno,
vardep=bad,
listconti=age amount checking duration installp savings,
listcategor=foreign history marital other purpose,
semilla1=12345,porcen1=0.80,
sinicial=12000,sfinal=12020,
porcenbag=1,maxbranch=2,
nleaves=30,tamhoja=10,
reemplazo=1,listalog=1,compara=1);

*/


/* MACRO RANDOM FOREST PARA VARIABLES DEPENDIENTES BINARIAS */


%macro randomforestbin(archivo=,vardep=,listconti=,listcategor=,
semilla1=12345,porcen1=0.80,
maxtrees=100,variables=3,porcenbag=0.80,maxbranch=2,tamhoja=5,maxdepth=10,pvalor=0.1,compara=1);

/* división train test */
proc surveyselect data=&archivo out=muestra1 outall method=srs seed=&semilla1 samprate=&porcen1 noprint;run;
data muestra1;set muestra1;if selected=1 then vardep=&vardep;else vardep=.;run;
data entreno testeo;set muestra1;if selected=1 then output entreno;else output testeo;drop selected;run;

ods listing close;
proc hpforest data=muestra1
maxtrees=&maxtrees 
vars_to_try=&variables 
trainfraction=&porcenbag 
leafsize=&tamhoja
maxdepth=&maxdepth
alpha=&pvalor 
exhaustive=5000 
missing=useinsearch ;
target vardep/level=nominal;
input &listconti/level=interval; 
%if (&listcategor ne) %then %do;
	input &listcategor/level=nominal;
%end; 
score out=salo;
run;
ods listing ;

data salo;merge salo muestra1(keep=selected &vardep);
if p_vardep1>0.5 then newvar1=1;else newvar1=0; 
newvar2=&vardep*1; 
error=abs(newvar1-newvar2);
run;

title "RANDOM FOREST Iteraciones=&maxtrees";
proc sort data=salo;by selected;
proc means data=salo;var error;output out=final mean=media;by selected;run;
data final;set final;if selected=0;run;

%if &compara=1 %then %do;

title 'RESULTADOS LOGISTICA'; 
proc logistic data=entreno descending noprint;
%if (&listcategor ne) %then %do;class &listcategor;
model &vardep=&listcategor &listconti;%end;
%else %do;model &vardep=&listconti;%end;
score data=muestra1 out=saltesteo;
run;
data saltesteo;set saltesteo;error=abs(I_&vardep-&vardep);run;
proc sort data=saltesteo;by selected;
proc means data=saltesteo;var error;by selected;output out=final2 mean=media;run;
data final2;set final2;if selected=0;run;
%end;

%mend;


/* EJEMPLO RANDOM FOREST BINARIA 
options mprint=0;options notes;

%randomforestbin(archivo=uno,
vardep=bad,
listconti=age amount checking duration installp savings,
listcategor=foreign history marital other purpose,
semilla1=12348,porcen1=0.80,
maxtrees=30,variables=8,porcenbag=0.5,maxbranch=2,tamhoja=5,maxdepth=15,pvalor=0.2,compara=1);

*/


/* MACRO GRADIENT BOOSTING BINARIA */ 

%macro boostingbin(archivo=,vardep=,listconti=,listcategor=,
semilla1=12345,porcen1=0.80,
iterations=100,shrink=0.1,maxbranch=2,tamhoja=5,maxdepth=10,compara=1);

/* división train test */
proc surveyselect data=&archivo out=muestra1 outall method=srs seed=&semilla1 samprate=&porcen1 noprint;run;
data muestra1;set muestra1;if selected=1 then vardep=&vardep;else vardep=.;run;
data entreno testeo;set muestra1;if selected=1 then output entreno;else output testeo;drop selected;run;

ods listing close;

proc treeboost data=entreno shrinkage=&shrink maxbranch=&maxbranch maxdepth=&maxdepth iterations=&iterations leafsize=&tamhoja;
	%if (&listcategor ne) %then %do;
	input &listcategor/level=nominal;
	%end;
	input &listconti/level=interval;
	target vardep /level=nominal;
	score data=muestra1 out=salo;
run;


ods listing ;

data salo;merge salo muestra1(keep=selected &vardep);
if p_vardep1>0.5 then newvar1=1;else newvar1=0; 
newvar2=&vardep*1; 
error=abs(newvar1-newvar2);
run;

proc sort data=salo;by selected;
proc means data=salo;var error;output out=final mean=media;by selected;run;
data final;set final;if selected=0;run;

%if &compara=1 %then %do;

title 'RESULTADOS LOGISTICA'; 
proc logistic data=entreno descending noprint;
%if (&listcategor ne) %then %do;class &listcategor;
model &vardep=&listcategor &listconti;%end;
%else %do;model &vardep=&listconti;%end;
score data=muestra1 out=saltesteo;
run;
data saltesteo;set saltesteo;error=abs(I_&vardep-&vardep);run;
proc sort data=saltesteo;by selected;
proc means data=saltesteo;var error;by selected;output out=final2 mean=media;run;
data final2;set final2;if selected=0;run;
%end;

%mend;

/* Ejemplo boosting bin 

%boostingbin(archivo=uno,vardep=bad,listconti=age amount checking duration installp savings,
listcategor=foreign history marital other purpose,
semilla1=12345,porcen1=0.80,
iterations=300,shrink=0.02,maxbranch=2,tamhoja=5,maxdepth=4,compara=1);


*/
