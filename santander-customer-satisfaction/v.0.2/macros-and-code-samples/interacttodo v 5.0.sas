
/* *****************************************************************************
MACRO INTERACTTODO
*****************************************************************************

%macro interacttodo(archivo=,vardep=,listclass=,listconti=,interac=1,directorio=c:);

La macro INTERACTTODO calcula un listado de interacciones entre: 

* variables categóricas hasta orden 2
* variables continuas y categóricas (hasta orden 2)

Y además presenta un listado de las variables e interacciones por orden de pvalor
consideradas individualmente en un proc GLM.


archivo=
depen=variable dependiente
listclass=lista de variables de clase
listconti=lista de variables continuas
interac= 1 si se quieren interacciones(puede tardar mucho dependiendo de la complejidad)
		(interac=0 si no se quieren interacciones)
directorio= poner el directorio para archivos temporales basura

********
SALIDA
********

EL ARCHIVO CONSTRUIDO POR LA MACRO SE LLAMA UNION. CONTIENE LOS EFECTOS ORDENADOS 
POR ORDEN ASCENDENTE DE AIC (CUANTO MÁS PEQUEÑO MEJOR). 
TAMBIÉN SE PUEDE REORDENAR POR ORDEN DESCENDENTE DEL VALOR DEL ESTADÍSTICO F (CUANTO MAYOR MEJOR)
O POR PVALOR DEL CONTRASTE (MÁS PEQUEÑO MEJOR).

UNA VEZ EJECUTADA LA MACRO SE PUEDE OBTENER UN LISTADO DE LOS EFECTOS
EN EL LOG POR ORDEN DE MEJOR AIC A PEOR, CON:

data _null_;set union;put variable @@;run;

******************************************************************************

NOTAS Y TRUCOS PARA SU APROVECHAMIENTO

1) ANTE ARCHIVOS CON MUCHAS VARIABLES CATEGÓRICAS SE PUEDE EJECUTAR POR PARTES,
POR EJEMPLO:
a)SOLO CONTINUAS
b)SOLO CATEGÓRICAS, CON O SIN INTERACCIONES
c)ELEGIR LAS K MEJORES CATEGÓRICAS y/o CONTINUAS Y VOLVER A EJECUTAR CON INTERACCIONES

2) EN GENERAL ANTE MUCHAS VARIABLES CATEGÓRICAS Y VARIABLES CATEGÓRICAS
CON MUCHAS CATEGORÍAS ES MEJOR REFINAR LOS DATOS UTILIZANDO LA MACRO
NOMBRESMOD ANTES. PERO PARA ELLO SE NECESITA A MENUDO UNA PRESELECCIÓN
CON EL APARTADO b ANTERIOR

3) EL ORDEN OBTENIDO NO ES DETERMINANTE PARA EL MODELO (SERÁ NECESARIO UTILIZAR
TÉCNICAS TIPO STEPWISE TAMBIÉN) PERO SÍ PARA UNA PRESELECCIÓN Y RECHAZO DE EFECTOS
QUE NO SIRVEN.

4) PUEDE PROBARSE ANTES CON AGRUPARCATEGORIAS

5) EL SIGUIENTE PROGRAMA ES ÚTIL PARA OBTENER UN LISTADO PREVIO
DE LAS VARIABLES EN UN ARCHIVO Y PEGARLO ANTES DE PROCEDER
A LA MACRO (HAY QUE TENER EN CUENTA QUE MUCHAS VECES 
HAY VARIABLES CATEGÓRICAS QUE ESTÁN EN EL ARCHIVO BASE 
CODIFICADAS COMO NUMÉRICAS, EN ESTE CASO NO VALE, HAY QUE SABER DEFINIRLAS DESPUÉS 
EN LA LISTCLASS)

proc contents data=uno out=nombres;
run;
proc sort data=nombres;by type;
data _null_;
set nombres;by type;
if first.type=1 and type=1 then put  'VARIABLES CONTINUAS';
if first.type=1 and type=2 then put // 'VARIABLES CATEGÓRICAS';
put name @@;
run;

*/

%macro interacttodo(archivo=,vardep=,listclass=,listconti=,interac=1,directorio=c:);
proc printto print="&directorio\kaka.txt";run;
data _null_;file "&directorio\inteconti.txt";put ' ';file "&directorio\intecategor.txt";put ' ';run;

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

%if &interac=1 %then %do;
cruce2=' ';
do i=1 to ncate;
	do j=1 to nconti;
   	ca=scan(clase,i);
		con=scan(conti,j);
		cruce1=cats(ca,'*',con);
		file "&directorio\inteconti.txt" mod;
		put cruce1;
	end;
end;

cruce2=' ';
do i=1 to ncate-1;
	do j=i+1 to ncate;
   	ca=scan(clase,i);
		con=scan(clase,j);
		if i ne j then cruce1=cats(ca,'*',con);else cruce1=' ';
		file "&directorio\intecategor.txt" mod;
		put cruce1;
	end;
end;
run;
%end;
data union;run;

/* variables de clase solitas */
%if &listclass ne %then %do i=1 %to &ncate;
data _null_;cosa="&listclass";va=scanq(cosa,&i);
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
data c;length variable $ 1000;merge a b;variable="&vari";run;
data union;set union c;run;

%end;

/* interacciones de variables de clase */

%if &interac=1 %then %do;

%if &ncate>1 %then %do;

data pr234;
length vari $ 1000;
infile "&directorio\intecategor.txt";
input vari;
run;
data _null_;set pr234 nobs=nume;ko=nume;
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
data c;length variable $ 1000;merge a b;variable="&vari";run;
data union;set union c;run;


%end;
data _null_;if _n_=1 then put 'LISTA CLASE E INTERACCIONES';set union;put variable @@;run;
%end;

%end;

/* variables continuas solitas */
%if &listconti ne %then %do i=1 %to &nconti;
data _null_;cosa="&listconti";va=scanq(cosa,&i);
call symput ('vari',va);
run;

ods output FitStatistics=ajuste anova=tanova;
proc glmselect data=&archivo ;
model &vardep=&vari /selection=none;
run;

data a;set ajuste (where=(Label1='AIC'));AIC=cvalue1;keep AIC;run;
data b(keep=Fvalue probf);set tanova;if _n_=1 then output;stop;run;
data c;length variable $ 1000;merge a b;variable="&vari";run;
data union;set union c;run;
%end;

/* interacciones de variables de clase con variables continuas */
%if &interac=1 %then %do;
data pr235;
length vari $ 1000;
infile "&directorio\inteconti.txt";
input vari;
run;

data _null_;set pr235 nobs=nume;ko=nume;
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

data a;set ajuste (where=(Label1='AIC'));AIC=cvalue1;keep AIC;
data b(keep=Fvalue probf);set tanova;if _n_=1 then output;stop;run;
data c;length variable $ 1000;merge a b;variable="&varicon";run;
data union;set union c;run;
%end;
%end;
proc printto;run;
data union;set union;if _n_=1 then delete;run;
proc sort data=union;by AIC;
proc print data=union;run;
data _null_;set union;put variable @@;run;
%mend;



/*
%interacttodo(archivo=boston,vardep=medv,listclass=chas,listconti=CRIM ZN INDUS NOX RM AGE DIS RAD TAX PTRATIO B LSTAT,
interac=1,directorio=c:);


*/
