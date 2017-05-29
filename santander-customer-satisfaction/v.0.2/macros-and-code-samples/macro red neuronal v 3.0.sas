/*************************************************************************************
 MACRO redneuronal(archivo=,listclass=,listconti=,vardep=,porcen=,semilla=,ocultos=,algo=,acti=);

archivo= archivo de datos
listclass= lista de variables de clase
listconti= lista de variables continuas
vardep=variable dependiente
porcen= porcentaje de training
semilla=semilla para hacer la partición
ocultos=número de nodos ocultos
*************************************************************************************/

%macro redneuronal(archivo=,listclass=,listconti=,vardep=,porcen=,semilla=,ocultos=,algo=,acti=);

%if &listclass eq %then %do;

PROC DMDB DATA=&archivo dmdbcat=catauno;
target &vardep;
var &listconti &vardep;
run;
%end;
%else %do;
PROC DMDB DATA=&archivo dmdbcat=catauno;
target &vardep;
var &listconti &vardep;
class &listclass;
run;
%end;

data ooo;set &archivo;run;
data datos;set ooo nobs=nume;tr=int(&porcen*nume);call symput('tr',left(tr));u=ranuni(&semilla);run;
proc sort data=datos;by u;run;
data datos valida;set datos;if _n_>tr then output valida;else output datos;run;

proc neural data=datos dmdbcat=catauno validata=valida graph;
input &listconti / id=i;
input &listclass / level=nominal;
target &vardep / id=o;
hidden &ocultos / id=h act=&acti;
nloptions maxiter=10000;
netoptions randist=normal ranscale=0.1 random=15115;
train maxiter=10000 outest=mlpest estiter=1 technique=&algo;
score data=datos out=mlpout outfit=mlpfit;
score data=valida out=mlpout2 outfit=mlpfit2 role=valid;
run;

data mlpest2 ;
k=3;
retain iterepocas 0;
set mlpest;
eval=_VOBJERR_;
x3=lag3(eval);
x6=lag6(eval);
if _n_>6 and eval>x3 and eval>x6 then iterepocas=_n_;
run;

data;
set mlpest2;
if iterepocas ne 0 then do;
call symput('earlystop',left(iterepocas));
stop;
end;
run;

data fin;j=&earlystop;set mlpest point=j;output;stop;run;

data mlpest;set mlpest nobs=nume; if _n_=&earlystop then do;
cosa1=put(_OBJERR_,20.6) ;
cosa2=put(_VOBJERR_,20.6) ;
end;
else do;cosa1=' ';cosa2=' ';end;
run;

title1 
h=2 box=1 j=c c=red 'TRAIN' c=blue '  VALIDA' 
h=1.5 j=c c=black "EARLY STOPPING=&earlystop " "semilla=&semilla" 
h=1 j=c c=green "NODOS OCULTOS: &ocultos  " " METODO: &algo "  "ACTIVACIÓN: &acti";
;

symbol1 c=red v=circle i=join pointlabel=("#cosa1" h=1 c=red position=bottom  j=c);
symbol2 c=blue v=circle i=join pointlabel=("#cosa2" h=1 c=blue position=top j=c);

axis1 label=none;
proc gplot data=mlpest;plot _OBJERR_ *_iter_=1 _VOBJERR_*_iter_=2 
/overlay href=&earlystop vaxis=axis1 haxis=axis1 ;run;

proc print data=fin;
var  _iter_ _OBJERR_  _AVERR_  _VNOBJ_   _VOBJ_  _VOBJERR_  _VAVERR_
;run;

%mend;


/*

data uno;set sampsio.baseball;run;
data uno;set uno;logsalary=log(salary);

%redneuronal(archivo=uno,listclass=,listconti=NO_ASSTS NO_HITS NO_OUTS YR_MAJOR CR_HITS,
vardep=logsalary,porcen=0.80,semilla=442711,ocultos=15,algo=LEVMAR,acti=TANH);
*/

/* Ejemplo de uso de la macro variando el número de nodos */

/*
proc catalog cat=gseg kill;run;
%macro pr;
%do ocul=1 %to 20 ;
%redneuronal(archivo=uno,listclass=,listconti=NO_ASSTS NO_HITS NO_OUTS YR_MAJOR CR_HITS,vardep=logsalary,porcen=0.80,semilla=123,ocultos=&ocul,
algo=LEVMAR,acti=TANH);
%end;
%mend;

%pr;
*/

/* Ejemplo de uso de la macro variando el método*/

/*
%let lista='LEVMAR QUANEW CONGRA BPROP DBLDOG TRUREG';
%let nume=6;
%macro pr;
%do  i=1 %to &nume;
data _null_;metodo=scanq(&lista,&i);call symput('metodo',left(metodo));run;
%redneuronal(archivo=uno,listclass=,listconti=NO_ASSTS NO_HITS NO_OUTS YR_MAJOR CR_HITS,vardep=logsalary,porcen=0.80,semilla=123,ocultos=5,
algo=&metodo,acti=tanh);
%end;
%mend;

%pr;

*/


/* Ejemplo de uso de la macro variando la función de activación*/

/*

%let lista2='TANH LOG ARC LIN SIN SOF GAU';
%let nume=7;
%macro pr;
%do  i=1 %to &nume;
data _null_;activa=scanq(&lista2,&i);call symput('activa',left(activa));run;
%redneuronal(archivo=uno,listclass=,listconti=NO_ASSTS NO_HITS NO_OUTS YR_MAJOR CR_HITS,vardep=logsalary,porcen=0.80,semilla=123456,ocultos=15,
algo=LEVMAR,acti=&activa);
%end;
%mend;

%pr;
*/
