
/*************************************************************************************
macros para comprobar early stopping en clasificación binaria

1) macro redneuronalbinaria  
	Ventajas saca el gráfico
	Desventaja:se calcula y grafica para la función de error (entropía, Bernoulli) 
				que no coincide con la tasa de fallos (aunque normalmente a menor error menor tasa de fallos).

2) macro comprueboearly
	Ventajas: saca gráfico
	Desventajas:usa train valida, es muy lenta pues calcula la red cada vez con un valor de early
				
3) macro  early1 
	Ventajas usa validación cruzada (una sola semilla)
	Desventajas:es muy lenta pues calcula la red cada vez con un valor de early 

*************************************************************************************/

/*************************************************************************************

MACRO REDNEURONALBINARIA

PARA OBSERVAR EARLY STOPPING USAR ESTA MACRO, 
PARA OTRAS COSAS MEJOR LAS MACROS BINARIAS BÁSICAS
(ESTA MACRO NO TIENE COMO FUNCIÓN DE ERROR LA TASA DE FALLOS)

MACRO redneuronalbinaria(archivo=,listclass=,listconti=,vardep=,porcen=,semilla=,ocultos=,meto=,acti=);

archivo= archivo de datos
listclass= lista de variables de clase
listconti= lista de variables continuas
vardep=variable dependiente
porcen= porcentaje de training
semilla=semilla para hacer la partición
ocultos=número de nodos ocultos

LA MACRO SE PUEDE CAMBIAR A CONVENIENCIA INTERNAMENTE PARA LAS OPCIONES DE LA RED
PARA CAMBIAR OTROS PARÁMETROS VER LAS MACROS AL FINAL DEL DOCUMENTO

		*************************************************************************************
		NOTA IMPORTANTE:
		*************************************************************************************
		LA FUNCIÓN DE ERROR EN EARLY STOPPING NO ES LA TASA DE FALLOS, 
		ES ENTROPÍA O FUNCIÓN DE ERROR DE BERNOULLI

		suma de 	-[y*log(ygorro)+(1-y)*log(1-ygorro)]

		*************************************************************************************
*************************************************************************************/

%macro redneuronalbinaria(archivo=,listclass=,listconti=,vardep=,porcen=,semilla=,ocultos=,meto=,acti=);

PROC DMDB DATA=&archivo dmdbcat=catauno;
target &vardep;
var &listconti ;
class &vardep &listclass;
run;

data ooo;set &archivo;run;
data datos;set ooo nobs=nume;tr=int(&porcen*nume);call symput('tr',left(tr));u=ranuni(&semilla);run;
proc sort data=datos;by u;run;
data datos valida;set datos;if _n_>tr then output valida;else output datos;run;

proc neural data=datos dmdbcat=catauno validata=valida graph;
input &listconti / id=i;
input &listclass / level=nominal;
target &vardep / level=nominal id=o error=ENT;
hidden &ocultos / id=h act=&acti;
nloptions maxiter=10000;
netoptions randist=normal ranscale=0.1 random=15115;
train maxiter=10000 outest=mlpest estiter=1 technique=&meto;
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
h=1 j=c c=green "NODOS OCULTOS: &ocultos  " " METODO: &meto "  "ACTIVACIÓN: &acti";
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

/* EJEMPLO REDNEURONALBINARIA

data uno;set 'c:\german.sas7bdat';
if good_bad='bad' then bad=1;if good_bad='good' then bad=0;
run; 

%redneuronalbinaria(archivo=uno,listclass=,
listconti=amount checking coapp duration employed history installp marital other savings,
vardep=bad,porcen=0.80,semilla=442711,ocultos=7,meto=LEVMAR,acti=TANH);

*/

/* Ejemplo de uso de la macro variando el número de nodos 

proc catalog cat=gseg kill;run;
%macro pr;
%do ocul=3 %to 30 %by 5;
%redneuronalbinaria(archivo=uno,listclass=,listconti=amount checking coapp duration employed history installp marital other savings,
vardep=bad,porcen=0.80,semilla=442711,ocultos=&ocul,meto=bprop mom=0.8 learn=0.2,acti=TANH);
%end;
%mend;

%pr;

*/

%macro cruzadabinarianeuralearly(archivo=,vardepen=,
conti=,categor=,ngrupos=,sinicio=,sfinal=,
nodos=,meto=,objetivo=,directorio=,early=);
data final;run;
proc printto print="directorio\basura.txt"; 

/* Bucle semillas */
%do semilla=&sinicio %to &sfinal;
	data dos;set &archivo;u=ranuni(&semilla);
	proc sort data=dos;by u;run;
	data dos (drop=nume);
	retain grupo 1;
	set dos nobs=nume;
	if _n_>grupo*nume/&ngrupos then grupo=grupo+1;
	run;
	data fantasma;run;
	%do exclu=1 %to &ngrupos;
		
	data trestr tresval;
		set dos;if grupo ne &exclu then output trestr;else output tresval;
		PROC DMDB DATA=trestr dmdbcat=catatres;
		target &vardepen;
		var &conti;
		class &vardepen;
		%if &categor ne %then %do;class &categor &vardepen;%end;
		run;
		proc neural data=trestr dmdbcat=catatres random=789 ;
		input &conti;
		%if &categor ne %then %do;input &categor /level=nominal;%end;
		target &vardepen /level=nominal;
		hidden &nodos /act=tanh;/*<<<<<******PARA DATOS LINEALES ACT=LIN (funci?nde activaci?n lineal) 
		NORMALMENTE PARA DATOS NO LINEALES MEJOR ACT=TANH */
		/* A PARTIR DE AQUI SON ESPECIFICACIONES DE LA RED, SE PUEDEN CAMBIAR O A?ADIR COMO PAR?METROS */

 		/*nloptions maxiter=500*/;
		netoptions randist=normal ranscale=0.15 random=15459;
		train maxiter=&early outest=mlpest technique=&meto;
		score data=tresval role=valid out=sal ;
		run;
		data sal2;set sal;pro=1-%str(p_&vardepen)0;if pro>0.5 then pre11=1; else pre11=0;run;
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
proc printto ; 
proc print data=final;run;
%mend;


%macro early1(archivo=,vardepen=,
conti=,categor=,ngrupos=,sinicio=,sfinal=,
nodos=,meto=,objetivo=,directorio=,inicio=,final=,incremento=);
data union;run;
%do early=&inicio %to &final %by &incremento;
%cruzadabinarianeuralearly(archivo=&archivo,vardepen=&vardepen,
conti=&conti,categor=&categor,ngrupos=&ngrupos,sinicio=&sinicio,sfinal=
&sfinal,nodos=&nodos,meto=&meto,objetivo=&objetivo,directorio=&directorio,early=&early);
data final;set final;early=&early;run;
data union;set union final;run;
%end;
title1 
h=1.5 j=c c=black "semilla=&sinicio" 
h=1 j=c c=green "NODOS OCULTOS: &nodos " " METODO: &meto "  ;
;
symbol1 c=red v=circle i=join pointlabel=("#tasafallos" h=1 c=red position=bottom  j=c);

proc gplot data=union;plot media*early;run;
%mend;


/* EJEMPLO EARLY1 */
/* PONER LA MISMA SEMILLA INICIO QUE FINAL */

/*

%early1(archivo=uno,vardepen=bad,
conti=checking duration employed foreign ,
categor=purpose,ngrupos=4,sinicio=12345,sfinal=12345,
nodos=5,meto=levmar,directorio=c:,inicio=10,final=20,incremento=5);

*/


%macro neuralbinariabasicaearly
(archivo=,listconti=,listclass=,vardep=,
nodos=,meto=,corte=,early=200,semilla=,porcen=);

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
train maxiter=&early tech=&meto;
score data=valida out=salpredi outfit=salfit ;
score data=train out=salpreditrain outfit=salfit2 ;
run;
%end;

%else %do;
proc neural data=train dmdbcat=cataprueba;
input  &listconti;
target  &vardep /level=nominal;
hidden &nodos;
prelim 0;
train maxiter=&early tech=&meto;
score data=valida out=salpredi outfit=salfit ;
score data=train out=salpreditrain outfit=salfit2 ;
run;
%end;

data salpredi;set salpredi;if p_&vardep.1>&corte/100 then predi1=1;else predi1=0;run;
proc freq data=salpredi;tables predi1*&vardep/out=sal1;run;

data salpreditrain;set salpreditrain;if p_&vardep.1>&corte/100 then predi1=1;else predi1=0;run;
proc freq data=salpreditrain;tables predi1*&vardep/out=sal1train;run;

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

data estadisticos2 (drop=count percent predi1 &vardep);
retain vp vn fp fn suma 0;
set sal1train nobs=nume;
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
proc print data=estadisticos2;run;

%mend;

/* ejemplo

options notes;
data uno;set 'c:\german.sas7bdat';
if good_bad='bad' then bad=1;if good_bad='good' then bad=0;
run;

%neuralbinariabasicaearly(archivo=uno,
listconti=age amount checking coapp depends duration employed existcr foreign ,
listclass=purpose,meto=levmar,early=200,vardep=bad,nodos=10,corte=50,semilla=12345,porcen=0.80);
*/

%macro comprueboearly
(archivo=,listconti=,listclass=,vardep=,
nodos=,meto=,corte=,semilla=,porcen=,inicio=,fin=,incremento=);
data union;run;
data union2;run;
%do early=&inicio %to &fin %by &incremento;
%neuralbinariabasicaearly
(archivo=&archivo,listconti=&listconti,listclass=&listclass,vardep=&vardep,
nodos=&nodos,meto=&meto,corte=&corte,early=&early,semilla=&semilla,porcen=&porcen);
data estadisticos;set estadisticos;early=&early;datos='valida';run;
data estadisticos2;set estadisticos2;early=&early;datos='train';run;
data union;set union estadisticos;run;
data union2;set union2 estadisticos2;run;
%end;
data unionfin;set union union2;if early=. then delete;run;
title1 
h=2 box=1 j=c c=red 'TRAIN' c=blue '  VALIDA' 
h=1.5 j=c c=black "semilla=&sinicio" 
h=1 j=c c=green "NODOS OCULTOS: &nodos " " METODO: &meto "  ;
;
symbol1 c=red v=circle i=join pointlabel=("#tasafallos" h=1 c=red position=bottom  j=c);
symbol2 c=blue v=circle i=join pointlabel=("#tasafallos" h=1 c=blue position=top j=c);
proc gplot data=unionfin;plot tasafallos*early=datos;run;
%mend;
/* ejemplo comprueboearly 

%comprueboearly(archivo=uno,
listconti=age amount checking coapp depends duration employed existcr foreign ,
listclass=purpose,meto=levmar,vardep=bad,nodos=10,corte=50,semilla=12345,porcen=0.80,
inicio=2,fin=50,incremento=4);

*/




