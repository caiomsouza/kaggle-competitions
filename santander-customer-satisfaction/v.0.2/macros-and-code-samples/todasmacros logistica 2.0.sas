/****************************************************************************************
/* LA MACRO NOMBRESMODBIEN CREA UN ARCHIVO DE DISEÑO CON EFECTOS E INTERACCIONES 
SEGÚN EL MODELO DADO USANDO PROC GLMMOD Y LAS NOMBRA ADECUADAMENTE
PARA PODER ENTENDERLAS (CAMBIANDO LOS NOMBRES COL1---COLN)

/*%macro nombresmod (archivo=,depen=,modelo=,listclass=,listconti=,corte=);*/

/* EL ARCHIVO FINAL PRETEST TIENE LOS DATOS CON LAS INTERACCIONES CREADAS Y BIEN NOMBRADAS 
CADA EFECTO DISCRETO Y VARIABLE CUALITATIVA ESTÁ EXPANDIDO EN DUMMYS 

EN ESTA VERSIÓN	NOMBRESMODBIEN SE AÑADE RESPECTO DE LA ANTERIOR NOMBRESMOD:

1) SE REDUCEN LOS NOMBRES DE LOS EFECTOS PARA QUE NO HAYA PROBLEMAS CON LA LONGITUD
DE NOMBRES DE VARIABLES

2) SE AÑADE EL PARÁMETRO corte= (por defecto corte=0). 

ESTE PARÁMETRO INDICA QUE LAS DUMMYS E INTERACCIONES QUE CORRESPONDEN A CATEGORÍAS
DE CUALQUIER VARIABLE DE CLASE INDICADA QUE TENGAN MENOS DE corte OBSERVACIONES
NO ESTARÁN EN EL ARCHIVO. 

EL ARCHIVO DE SALIDA SE LLAMA PRETEST

****************************************************************************************/

%macro nombresmodbien(archivo=,depen=,modelo=,listclass=,listconti=,corte=0);
proc glmmod data=&archivo outdesign=outdise outparm=nomcol;
class &listclass;
model &depen=&modelo;
run;

data _null_;
clase="&listconti";
  nconti= 1;
  do while (scanq(clase, nconti) ^= '');
    nconti+1;
  end;
  nconti+(-1);
  call symput('nconti',left(nconti));
run;

data _null_;
clase="&listclass";
  ncate= 1;
  do while (scanq(clase, ncate) ^= '');
    ncate+1;
  end;
  ncate+(-1);
  call symput('ncate',left(ncate));
run;

%do i=1 %to &ncate;
 %let vari=%qscan(&listclass,&i);
 proc freq data=&archivo noprint;tables &vari /out=sal;run;
 proc sort data=nomcol;by &vari;
 data nomcol;merge nomcol sal(keep=count &vari);by &vari;
 run;
%end;

data nomcol;set nomcol;
 if effname='Intercept' then delete;
 if _colnum_=. then delete;
 if count=. or count>&corte then output;
run;

data efectos (keep=efecto _colnum_);
length efecto $ 31;
set nomcol;
/* aqui hay que verificar si el efecto es una variable continua */
conta=0;
%do i=1 %to &nconti;
 %let vari=%qscan(&listconti,&i);
 if effname="&vari" then conta=1;
%end;
efecto=effname;
if conta=0 then %do i=1 %to &ncate;
                 %let vari=%qscan(&listclass,&i);
				 efecto=compress(cats(efecto,&vari),,"p");
				%end;
run;
proc sort data=efectos;by _colnum_;run;
proc print data=efectos;run;
proc contents data=outdise out=salcon;run;
data salcon (keep=name _colnum_);
 set salcon;if name="&depen" then delete;
 colu=compress(name,'Col');
 _colnum_=input(colu, 5.); 
run;
proc sort data=salcon;by _colnum_;run;
data unisalefec malos;merge salcon efectos(in=ef);by _colnum_;if ef=1 then output unisalefec;else output malos;run;
proc print data=unisalefec;run;
proc print data=malos;run;
filename renomb 'c:\reno.txt';
filename malos 'c:\listamalos.txt';
data _null_;
 file 'c:\listamalos.txt';
 set malos end=eof;
 if _n_=1 then put 'data outdise2;set outdise;drop ';put name @@;
 if eof=1 then put ';run;';
run;
%include malos;
data _null_;
length efecto efecto2 $ 20000;
file renomb; 
set unisalefec end=eof;
if length(efecto)>14 then efecto2=trim(substr(efecto,1,4)||SUBSTR(efecto,12,length(efecto)));
else efecto2=efecto;
if _n_=1 then put "rename ";
put name '= ' efecto2;
if eof then put ';';
run;
data pretest;
set outdise2;
%include renomb; 
run;
proc contents data=pretest out=salnom noprint;
data _null_;set salnom;if _n_=1 then put //;put name @@;run;
%mend;

/* EJEMPLO
data baseball;set discoc.baseballbien;run;

%nombresmodbien(archivo=baseball,depen=salary,
modelo=position league position*league cratbat*position nhits cratbat
,listclass=position league 
,listconti=cratbat nhits,corte=29); */

/* VALIDACIÓN CRUZADA LOGÍSTICA PARA VARIABLES DEPENDIENTES BINARIAS 

*********************************************************************************
								PARÁMETROS
*********************************************************************************

BÁSICOS

archivo=		archivo de datos
vardepen=		variable dependiente binaria 
categor=		lista de variables independientes categóricas
conti=			TODO EL MODELO: lista de variables independientes continuas Y TODAS LAS INTERACCIONES 	y categóricas
ngrupos=		número de grupos validación cruzada
sinicio=		semilla inicial para repetición
sfinal=			semilla final para repetición
objetivo=		tasafallos,sensi,especif,porcenVN,porcenFN,porcenVP,porcenFP,precision,tasaciertos


El archivo final se llama final. La variable media es la media del obejtivo en todas las pruebas de validación cruzada
(habitualmente tasa de fallos).

*/


%macro cruzadalogistica(archivo=,vardepen=,conti=,categor=,ngrupos=,sinicio=,sfinal=,objetivo=);
data final;run;
/* Bucle semillas */
%do semilla=&sinicio %to &sfinal;
	data dos;set &archivo;u=ranuni(&semilla);
	proc sort data=dos;by u;run;
	data dos ;
	retain grupo 1;
	set dos nobs=nume;
	if _n_>grupo*nume/&ngrupos then grupo=grupo+1;
	run;
	data fantasma;run;
	%do exclu=1 %to &ngrupos;
		data tres;set dos;if grupo ne &exclu then vardep=&vardepen;
		proc logistic data=tres noprint;/*<<<<<******SE PUEDE QUITAR EL NOPRINT */
		%if (&categor ne) %then %do;class &categor;model vardep=&conti;%end;
		%else %do;model vardep=&conti;%end;
		output out=sal p=predi;run;
		data sal2;set sal;pro=1-predi;if pro>0.5 then pre11=1; else pre11=0;
		if grupo=&exclu then output;run;
		proc freq data=sal2;tables pre11*&vardepen/out=sal3;run;
		data estadisticos (drop=count percent pre11 &vardepen); 
		retain vp vn fp fn suma 0; 
		set sal3 nobs=nume; 
		suma=suma+count; 
		if pre11=0 and &vardepen=0 then vn=count; 
		if pre11=0 and &vardepen=1 then fn=count; 
		if pre11=1 and &vardepen=0 then fp=count; 
		if pre11=1 and &vardepen=1 then vp=count; 
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
		
		data fantasma;set fantasma estadisticos;run;
	%end;
	proc means data=fantasma sum noprint;var &objetivo;
	output out=sumaresi sum=suma mean=media;
	run;
	data sumaresi;set sumaresi;semilla=&semilla;
	data final (keep=suma media semilla);set final sumaresi;if suma=. then delete;run;
%end;
proc print data=final;run;
%mend;

options mprint;

/* EJEMPLO 

%cruzadalogistica(archivo=uno,
vardepen=chd,
conti=tobacco tobacco*famhist,
categor=famhist,
ngrupos=4,sinicio=12345,sfinal=12347,objetivo=tasafallos);

*/
/* LA MACRO RANDOMSELECTlog REALIZA UN MÉTODO STEPWISE 
REPETIDAS VECES CON DIFERENTES ARCHIVOS TRAIN.

LA SALIDA INCLUYE UNA TABLA DE FRECUENCIAS 
DE LOS MODELOS QUE APARECEN SELECCIONADOS EN LOS DIFERENTES 
ARCHIVOS TRAIN

LOS MODELOS QUE SALEN MÁS VECES SON POSIBLES CANDIDATOS A PROBAR 
CON VALIDACIÓN CRUZADA

listclass=lista de variables de clase ATENCIÓN, EN ESTA LISTA SOLO PONER VARIABLES 
			QUE SE VAYAN A USAR (BIEN COMO EFECTOS PRINCIPALES O INTERACCIONES)
vardepen=variable dependiente
modelo=modelo
sinicio=semilla inicio
sfinal=semilla final
fracciontrain=fracción de datos train

EL ARCHIVO QUE CONTIENE LOS EFECTOS SE LLAMA SALEFEC. 
SE INCLUYE EN EL LOG EL LISTADO PARA PODER COPIAR Y PEGAR 
(A VECES LA VENTANA OUTPUT ESTÁ LIMITADA)

*/

%macro randomselectlog(data=,listclass=,vardepen=,modelo=,sinicio=,sfinal=,fracciontrain=);
options nocenter linesize=256;
proc printto print='e:\kk.txt';run;
data;file 'e:\cosa2.txt' ;run;
%do semilla=&sinicio %to &sfinal;
proc surveyselect data=&data rate=&fracciontrain out=sal1234 seed=&semilla;run;

%if &listclass ne %then %do;
ods output type3=parametros;
proc logistic data=sal1234;
	class &listclass;
    model &vardepen= &modelo/ selection=stepwise;
run;   
data parametros;length effect $20. modelo $ 20000;retain modelo " ";set parametros end=fin;effect=cat(' ',effect);
if _n_ ne 1 then modelo=catt(modelo,' ',effect);if fin then do;variable=modelo;output;end;
run;
%end;
%else %do;
ods output  Logistic.ParameterEstimates=parametros;
proc logistic data=sal1234;
	  model &vardepen= &modelo/ selection=stepwise;
run;   
%end;
ods graphics off;   
ods html close;   
data;file 'e:\cosa2.txt' mod;set parametros;
%if &listclass ne %then %do; put variable @@;%end;
%else %do; if _n_ ne 1 then put variable @@;%end;
run;
%end;
proc printto ;run;
data todos;
infile 'e:\cosa2.txt' ;
length efecto $ 400;
input efecto @@;
if efecto ne 'Intercept' then output;
run;
proc freq data=todos;tables efecto /out=sal;run;
proc sort data=sal;by descending count;
proc print data=sal;run;

data todos;
infile 'e:\cosa2.txt' ;
length efecto $ 200;
input efecto $ &&;
run;
proc freq data=todos;tables efecto /out=sal;run;
proc sort data=sal;by descending count;
proc print data=sal;run;
data;set sal;put efecto;run;
%mend;

/* Ejemplos 

%randomselectlog(data=german,listclass=foreign marital telephon depends history purpose other housing job property ,
vardepen=bad,
modelo=age amount checking coapp duration employed existcr installp resident savings 
foreign marital telephon depends history purpose other housing job property ,
sinicio=12345,sfinal=12380,fracciontrain=0.8);


%randomselectlog(data=german,listclass=,
vardepen=bad,
modelo=age amount checking coapp duration employed existcr installp resident savings,
sinicio=12345,sfinal=12380,fracciontrain=0.8);


%randomselectlog(data=german,listclass=marital history,
vardepen=bad,
modelo=age amount checking coapp duration employed marital*history existcr installp resident savings,
sinicio=12345,sfinal=12380,fracciontrain=0.8);

*/
/* *****************************************************************************
MACRO INTERACTTODO
*****************************************************************************
La macro INTERACTTODO calcula un listado de interacciones entre: 

* variables categóricas hasta orden 2
* variables continuas y categóricas (hasta orden 2)

Y además presenta un listado de las variables e interacciones por orden de pvalor
consideradas individualmente en un proc GLM

EL ARCHIVO CONSTRUIDO POR LA MACRO SE LLAMA UNION.
UNA VEZ EJECUTADA LA MACRO SE PUEDE OBTENER UN LISTADO 
EN EL LOG POR ORDEN DE MEJOR AIC A PEOR, CON:

data;set union;put variable @@;run;


**********************************************************
NOTA: EN LA MACRO SE UTILIZAN ARCHIVOS DE TEXTO DE APOYO.
ESTOS ARCHIVOS SE GRABAN POR DEFECTO EN C:\
SE PUEDE BUSCAR Y REEMPLAZAR C:\ POR LA DIRECCIÓN QUE SEA
*********************************************************


******************************************************************************/

/* EL SIGUIENTE PROGRAMA ES ÚTIL PARA OBTENER UN LISTADO PREVIO
DE LAS VARIABLES EN UN ARCHIVO Y PEGARLO ANTES DE PROCEDER
A LA MACRO 

(HAY QUE TENER EN CUENTA QUE MUCHAS VECES 
HAY VARIABLES CATEGÓRICAS QUE ESTÁN EN EL ARCHIVO BASE 
CODIFICADAS COMO NUMÉRICAS, EN ESTE CASO NO VALE)

proc contents data=uno out=nombres;
run;
proc sort data=nombres;by type;
data;
set nombres;by type;
if first.type=1 and type=1 then put  'VARIABLES CONTINUAS';
if first.type=1 and type=2 then put // 'VARIABLES CATEGÓRICAS';
put name @@;
run;
*/


%macro interacttodo(archivo=,vardep=,listclass=,listconti=);
proc printto print='c:\kaka.txt';run;
data;file 'c:\inteconti.txt';put ' ';file 'c:\intecategor.txt';put ' ';run;

data _null_;
length clase conti con cruce1 $ 32000 cruce2 $ 32000;
clase="&listclass";
conti="&listconti";
  ncate= 1;
  do while (scan(clase, ncate) ^= '');
    ncate+1;
  end;
  ncate+(-1);
  put ncate=;
  nconti= 1;
  do while (scan(conti, nconti) ^= '');
    nconti+1;
  end;
  nconti+(-1);
  put nconti=;

call symput('ncate',left(ncate));
call symput('nconti',left(nconti));

cruce2=' ';
do i=1 to ncate;
	do j=1 to nconti;
   	ca=scan(clase,i);
		con=scan(conti,j);
		cruce1=cats(ca,'*',con);
		file 'c:\inteconti.txt' mod;
		put cruce1;
	end;
end;

cruce2=' ';
do i=1 to ncate-1;
	do j=i+1 to ncate;
   	ca=scan(clase,i);
		con=scan(clase,j);
		if i ne j then cruce1=cats(ca,'*',con);else cruce1=' ';
		file 'c:\intecategor.txt' mod;
		put cruce1;
	end;
end;
run;
data union;run;

/* variables de clase solitas */
%if &listclass ne %then %do i=1 %to &ncate;
data;cosa="&listclass";va=scanq(cosa,&i);
call symput ('vari',va);
run;

ods output FitStatistics=ajuste anova=tanova;
proc glmselect data=&archivo ;
class &vari;
model &vardep=&vari /selection=none;
run;

proc print data=tanova;run;

data a;set ajuste (where=(Label1='AIC'));AIC=cvalue1;keep AIC;run;
data b(keep=Fvalue probf);set tanova;if _n_=1 then output;stop;run;
data c;merge a b;variable="&vari";run;
data union;set union c;run;

%end;

/* interacciones de variables de clase */

%if &ncate>1 %then %do;

data pr234;
length vari $ 1000;
infile 'c:\intecategor.txt';
input vari;
run;
data;set pr234 nobs=nume;ko=nume;
call symput('nintecat',left(ko));stop;
run;

%if &listclass ne %then %do i=1 %to &nintecat;
data _null_;ko=&i;
set pr234 point=ko;
var1=scan(vari,1);
var2=scan(vari,2);
lista1=compbl(var1||'  '||var2);
call symput('lista1',left(lista1));
call symput('vari',left(vari));
stop;
run;

ods output FitStatistics=ajuste anova=tanova;
proc glmselect data=&archivo ;
class &lista1;
model &vardep=&vari / selection=none;
run;

data a;set ajuste (where=(Label1='AIC'));
AIC=cvalue1;keep AIC;
data b(keep=Fvalue probf);set tanova;if _n_=1 then output;stop;run;
data c;merge a b;variable="&vari";run;
data union;set union c;run;


%end;
data;if _n_=1 then put 'LISTA CLASE E INTERACCIONES';set union;put variable @@;run;
%end;

/* variables continuas solitas */
%if &listconti ne %then %do i=1 %to &nconti;
data;cosa="&listconti";va=scanq(cosa,&i);
call symput ('vari',va);
run;

ods output FitStatistics=ajuste anova=tanova;
proc glmselect data=&archivo ;
model &vardep=&vari /selection=none;
run;

data a;set ajuste (where=(Label1='AIC'));AIC=cvalue1;keep AIC;run;
data b(keep=Fvalue probf);set tanova;if _n_=1 then output;stop;run;
data c;merge a b;variable="&vari";run;
data union;set union c;run;
%end;

/* interacciones de variables de clase con variables continuas */
data pr235;
length vari $ 1000;
infile 'c:\inteconti.txt';
input vari;
run;

data;set pr235 nobs=nume;ko=nume;
call symput('ninteconti',left(ko));stop;
run;

%if (&listclass ne) and (&listconti ne) %then %do i=1 %to &ninteconti;
data _null_;ko=&i;
set pr235 point=ko;
var1=scan(vari,1);
var2=scan(vari,2);
call symput('lista1con',left(var1));
call symput('varicon',left(vari));
stop;
run;

ods output FitStatistics=ajuste anova=tanova;
proc glmselect data=&archivo ;
class &lista1con;
model &vardep=&varicon / selection=none;
run;

data a;set ajuste (where=(Label1='AIC'));
AIC=cvalue1;keep AIC;
data b(keep=Fvalue probf);set tanova;if _n_=1 then output;stop;run;
data c;merge a b;variable="&varicon";run;
data union;set union c;run;
%end;
proc printto;run;
data union;set union;if _n_=1 then delete;run;
proc sort data=union;by AIC;
proc print data=union;run;
data;set union;put variable @@;run;
%mend;

/**************************************************************************
LA MACRO REDUZCOVALORES TRADUCE LOS VALORES DE LAS VARIABLES CATEGÓRICAS 
A NÚMEROS ORDINALES PARA PODER APLICAR OTRAS MACROS COMO LA %NOMBRESMOD, 
DONDE LA COMPLEJIDAD DE LOS VALORES ALFANUMÉRICOS (CARACTERES RAROS, ESPACIOS,
ETC.)PUEDE AFECTAR. 

Parámetros:

archivo= 
listclass=lista de variables categóricas a recategorizar


EL ARCHIVO DE SALIDA SE LLAMA CAMBIOS. EN ESTE
ARCHIVO DE SALIDA LAS VARIABLES TRANSFORMADAS TOMAN EL 
MISMO NOMBRE ORIGINAL CON UN 2 DETRÁS.

EXISTE OTRO ARCHIVO DE SALIDA LLAMADO DICCIONARIO, DONDE 
SE PRESENTAN LAS CATEGORÍAS DE CADA VARIABLE Y SU TRADUCCIÓN.

***************************************************************************/

%macro reduzcovalores(archivo=,listclass=);

data _null_;
clase="&listclass";
  ncate= 1;
  do while (scanq(clase, ncate) ^= '');
    ncate+1;
  end;
  ncate+(-1);
  call symput('ncate',left(ncate));
run;
data diccionario;run;
data _null;;
file 'c:\diccionario.txt' ;
put 'data cambios(drop=' "&listclass" ');set ' "&archivo" ';';
run;
%do i=1 %to &ncate;
	 %let vari=%qscan(&listclass,&i);
	proc freq data=&archivo noprint;tables &vari/ out=salifrec;
	data u1 (keep=nombrevariable original nuevacategoria );
	length nombrevariable $ 200;
	nombrevariable="&vari";
	set salifrec nobs=nume;
	original=&vari;variable="&vari"; 
	nuevacategoria=_n_;
		file 'c:\diccionario.txt' mod;
	put "if &vari='" &vari "' then &vari.2=" nuevacategoria ";";
run;
data diccionario;set diccionario u1;run;
%end;
data _null;file 'c:\diccionario.txt' mod;put 'run;';
%include 'c:\diccionario.txt';
proc print data=cambios;run;
data diccionario;set diccionario;if _n_=1 then delete;
proc print data=diccionario;run;
%mend;

/*EJEMPLO REDUZCOVALORES
%reduzcovalores(archivo=baseball,listclass=league division position);*/

/* LA MACRO RENOMBRAR RENOMBRA LISTAS DE VARIABLES A 
LISTAS CON PREFIJO (X1,X2...)

archivo=,
listaclass=, LISTA DE VARIABLES CODIFICADAS COMO CHARACTER
listaconti=, LISTA DE VARIABLES CODIFICADAS COMO NUMÉRICAS (PUEDEN SER CATEGÓRICAS)
prefijoclass=,PREFIJO A PONER EN LA LISTA DE VARIABLES CHARACTER
prefijoconti=PREFIJO A PONER EN LA LISTA DE VARIABLES NUMÉRICAS

EL ARCHIVO DE SALIDA SE LLAMA IGUAL QUE EL DE ENTRADA CON EL SUFIJO 2

*/

%macro renombrar(archivo=,listaclass=,listaconti=,prefijoclass=,prefijoconti=);
data _null_;
clase="&listaconti";
  nconti= 1;
  do while (scanq(clase, nconti) ^= '');
    nconti+1;
  end;
  nconti+(-1);
  call symput('nconti',left(nconti));
run;

data _null_;
clase="&listaclass";
  ncate= 1;
  do while (scanq(clase, ncate) ^= '');
    ncate+1;
  end;
  ncate+(-1);
  call symput('ncate',left(ncate));
run;

data &archivo.2 (drop=&listaclass &listaconti i);
array &prefijoclass{&ncate} $;
array &prefijoconti{&nconti};
array variclass{&ncate} $ &listaclass;
array variconti{&nconti} &listaconti;
set &archivo;
do i=1 to &nconti; 
	&prefijoconti{i}=variconti{i};
end;
do i=1 to &ncate; 
	&prefijoclass{i}=variclass{i};
end;
run;
%mend;

/* EJEMPLO RENOMBRAR 

%renombrar(archivo=baseball,
listaclass=league division position,
listaconti=crAtBat nHits,
prefijoclass=cates,prefijoconti=contin);

proc contents data=baseball2;run;

*/


/* *****************************************************************************
MACRO INTERACTTODOlog
*****************************************************************************
La macro INTERACTTODOLOG calcula un listado de interacciones entre: 

* variables categóricas hasta orden 2
* variables continuas y categóricas (hasta orden 2)

Y además presenta un listado de las variables e interacciones por orden de pvalor
consideradas individualmente en un proc GLM

EL ARCHIVO CONSTRUIDO POR LA MACRO SE LLAMA UNION.
UNA VEZ EJECUTADA LA MACRO SE PUEDE OBTENER UN LISTADO 
EN EL LOG POR ORDEN DE MEJOR AIC A PEOR, CON:

data;set union;put variable @@;run;


**********************************************************
NOTA: EN LA MACRO SE UTILIZAN ARCHIVOS DE TEXTO DE APOYO.
ESTOS ARCHIVOS SE GRABAN POR DEFECTO EN C:\
SE PUEDE BUSCAR Y REEMPLAZAR C:\ POR LA DIRECCIÓN QUE SEA
*********************************************************

******************************************************************************/

/* EL SIGUIENTE PROGRAMA ES ÚTIL PARA OBTENER UN LISTADO 
DE LAS VARIABLES EN UN ARCHIVO Y PEGARLO ANTES DE PROCEDER
A LA MACRO 

(HAY QUE TENER EN CUENTA QUE MUCHAS VECES 
HAY VARIABLES CATEGÓRICAS QUE ESTÁN EN EL ARCHIVO BASE 
CODIFICADAS COMO NUMÉRICAS)

proc contents data=uno out=nombres;
run;
proc sort data=nombres;by type;
data;
set nombres;by type;
if first.type=1 and type=1 then put  'VARIABLES CONTINUAS';
if first.type=1 and type=2 then put // 'VARIABLES CATEGÓRICAS';
put name @@;
run;
*/

%macro interacttodolog(archivo=,vardep=,listclass=,listconti=);
proc printto print='c:\kaka.txt';run;
data;file 'c:\inteconti.txt';put ' ';file 'c:\intecategor.txt';put ' ';run;
data _null_;
length clase conti con cruce1 $ 32000 cruce2 $ 32000;
clase="&listclass";
conti="&listconti";
  ncate= 1;
  do while (scan(clase, ncate) ^= '');
    ncate+1;
  end;
  ncate+(-1);
  put ncate=;
  nconti= 1;
  do while (scan(conti, nconti) ^= '');
    nconti+1;
  end;
  nconti+(-1);
  put nconti=;

call symput('ncate',left(ncate));
call symput('nconti',left(nconti));

cruce2=' ';
do i=1 to ncate;
	do j=1 to nconti;
   	ca=scan(clase,i);
		con=scan(conti,j);
		cruce1=cats(ca,'*',con);
		file 'c:\inteconti.txt' mod;
		put cruce1;
	end;
end;

cruce2=' ';
do i=1 to ncate-1;
	do j=i+1 to ncate;
   	ca=scan(clase,i);
		con=scan(clase,j);
		if i ne j then cruce1=cats(ca,'*',con);else cruce1=' ';
		file 'c:\intecategor.txt' mod;
		put cruce1;
	end;
end;
run;
data union;run;

/* variables de clase solitas */
%if &listclass ne %then %do i=1 %to &ncate;
data;cosa="&listclass";va=scanq(cosa,&i);
call symput ('vari',va);
run;

ods output Globaltests=global association=asoc;
ods output Fitstatistics=Fitstatistics;
proc logistic data=&archivo;
class &vari;
model &vardep=&vari;
run;

data c (keep=variable percentconcord AIC Chisq ProbChisq);
set global;set asoc;set fitstatistics;
AIC=InterceptandCovariates;percentconcord=cvalue1;
variable="&vari";
if _n_=1 then output;
run;

data union;set union c;run;

%end;

/* interacciones de variables de clase */

%if &ncate>1 %then %do;

data pr234;
length vari $ 1000;
infile 'c:\intecategor.txt';
input vari;
run;
data;set pr234 nobs=nume;ko=nume;
call symput('nintecat',left(ko));stop;
run;

%if &listclass ne %then %do i=1 %to &nintecat;
data _null_;ko=&i;
set pr234 point=ko;
var1=scan(vari,1);
var2=scan(vari,2);
lista1=compbl(var1||'  '||var2);
call symput('lista1',left(lista1));
call symput('vari',left(vari));
stop;
run;

ods output Globaltests=global association=asoc;
ods output Fitstatistics=Fitstatistics;
proc logistic data=&archivo;
class &lista1;
model &vardep=&vari;
run;

data c (keep=variable percentconcord AIC Chisq ProbChisq);
set global;set asoc;set fitstatistics;
AIC=InterceptandCovariates;percentconcord=cvalue1;
variable="&vari";
if _n_=1 then output;
run;

data union;set union c;run;

%end;
data;if _n_=1 then put 'LISTA CLASE E INTERACCIONES';set union;put variable @@;run;
%end;

/* variables continuas solitas */
%if &listconti ne %then %do i=1 %to &nconti;
data;cosa="&listconti";va=scanq(cosa,&i);
call symput ('vari',va);
run;

ods output Globaltests=global association=asoc;
ods output Fitstatistics=Fitstatistics;
proc logistic data=&archivo;
model &vardep=&vari;
run;

data c (keep=variable percentconcord AIC Chisq ProbChisq);
set global;set asoc;set fitstatistics;
AIC=InterceptandCovariates;percentconcord=cvalue1;
variable="&vari";
if _n_=1 then output;
run;

data union;set union c;run;

%end;

/* interacciones de variables de clase con variables continuas */
data pr235;
length vari $ 1000;
infile 'c:\inteconti.txt';
input vari;
run;

data;set pr235 nobs=nume;ko=nume;
call symput('ninteconti',left(ko));stop;
run;

%if (&listclass ne) and (&listconti ne) %then %do i=1 %to &ninteconti;
data _null_;ko=&i;
set pr235 point=ko;
var1=scan(vari,1);
var2=scan(vari,2);
call symput('lista1con',left(var1));
call symput('varicon',left(vari));
stop;
run;

ods output Globaltests=global association=asoc;
ods output Fitstatistics=Fitstatistics;
proc logistic data=&archivo;
class &lista1con;
model &vardep=&varicon;
run;

data c (keep=variable percentconcord AIC Chisq ProbChisq);
set global;set asoc;set fitstatistics;
AIC=InterceptandCovariates;percentconcord=cvalue1;
variable="&varicon";
if _n_=1 then output;
run;

data union;set union c;run;

%end;
proc printto;run;
data union;retain variable percentconcord aic chisq probchisq;
set union;if _n_=1 then delete;run;
proc sort data=union;by descending chisq;
proc print data=union;run;
%mend;

/*
proc contents data=uno out=nombres;
run;
proc sort data=nombres;by type;
data;
set nombres;by type;
if first.type=1 and type=1 then put  'VARIABLES CONTINUAS';
if first.type=1 and type=2 then put // 'VARIABLES CATEGÓRICAS';
put name @@;
run;
*/

options notes;

