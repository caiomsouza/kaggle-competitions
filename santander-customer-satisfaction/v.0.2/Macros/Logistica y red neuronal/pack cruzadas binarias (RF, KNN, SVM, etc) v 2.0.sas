/********************************************************************
********************************************************************
						CRUZADAbinarianeural
********************************************************************
********************************************************************/
%macro cruzadabinarianeural(archivo=,vardepen=,conti=,categor=,ngrupos=,sinicio=,sfinal=,nodos=,meto=,objetivo=);
data final;run;
proc printto print='c:\basura.txt'; 

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
		hidden &nodos /act=tanh;/*<<<<<******PARA DATOS LINEALES ACT=LIN (funciónde activación lineal) 
		NORMALMENTE PARA DATOS NO LINEALES MEJOR ACT=TANH */
		/* A PARTIR DE AQUI SON ESPECIFICACIONES DE LA RED, SE PUEDEN CAMBIAR O AÑADIR COMO PARÁMETROS */

 		/*nloptions maxiter=500*/;
		netoptions randist=normal ranscale=0.15 random=15459;
		prelim 15 preiter=10 pretech=&meto;
		train maxiter=100 outest=mlpest technique=&meto;
		score data=tresval role=test out=sal ;
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

/********************************************************************
********************************************************************
						CRUZADAlogistica
********************************************************************
********************************************************************/


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
		data tres;set dos;if grupo ne &exclu then vardep=&vardepen*1;
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

/********************************************************************
********************************************************************
						CRUZADAbaggingbin
********************************************************************
********************************************************************/

%macro cruzadabaggingbin(archivo=,vardepen=,listconti=,listcategor=,
ngrupos=4,
sinicio=12345,sfinal=12385,
siniciobag=12345,sfinalbag=12385,
porcenbag=0.80,maxbranch=2,nleaves=6,tamhoja=5,reemplazo=1,objetivo=tasafallos);

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
data tres;set dos;if grupo ne &exclu then vardep=&vardepen*1;

data tresbis trespred;set tres;if grupo ne &exclu then output tresbis;else output trespred;run;

/* bagging: */
%do sem=&siniciobag %to &sfinalbag;
data;
numero=&sem-&siniciobag+1;call symput('numero',left(numero));
total=&sfinalbag-&siniciobag+1;call symput('total',left(total));run;

	%if &reemplazo=0 %then %do;
	proc surveyselect data=tresbis out=muestra2 outall method=srs seed=&sem samprate=&porcenbag noprint;run;
	%end;
	%else %do;
	proc surveyselect data=tresbis out=muestra2 outall method=urs seed=&sem samprate=&porcenbag noprint;run;
	%end;
data entreno1 ;set muestra2;if selected=1 then output entreno1;drop selected;run;

proc arbor data=entreno1 ; 
input &listconti/level=interval;
%if (&listcategor ne) %then %do;
	input &listcategor/level=nominal;
	%end;
target vardep /level=nominal;
interact largest;
train maxbranch=&maxbranch leafsize=&tamhoja;
subtree nleaves=&nleaves;/* número máximo de hojas finales del subárbol elegido: BEST, LARGEST, nleaves=nhojas */
score data=trespred out=sal;/* archivo de salida con predicciones y variables de pertenencia a nodos */
run;
data sal;set sal;vardepen&numero=p_vardep1;run;
/*
%if &numero=1 %then %do;data uni;set sal;keep vardepen1-vardepen&numero &vardep;run;%end;
%else %do;data uni; merge uni sal;keep vardepen1-vardepen&numero &vardep;run;%end;
%end;
data uni;merge uni muestra1;ypredi=mean(of vardepen1-vardepen&total);run;
*/
%if &numero=1 %then %do;data uni;set sal;ypredi=vardepen&numero;keep ypredi &vardepen;run;%end;
%else %do;data uni; merge uni sal;ypredi=vardepen&numero+ypredi;keep ypredi &vardepen;run;%end;


%end;/* fin bagging */

data sal2 ;set uni ;ypredi=ypredi/&total;
if ypredi>0.5 then pre11=1;else pre11=0;run;

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

%end;/* fin grupos */
	proc means data=fantasma sum noprint;var &objetivo;
	output out=sumaresi sum=suma mean=media;
	run;
	data sumaresi;set sumaresi;semilla=&semilla;
	data final (keep=suma media semilla);set final sumaresi;if suma=. then delete;run;
%end;/* fin semillas validación cruzada repetida*/

proc print data=final;run;

%mend;

/********************************************************************
********************************************************************
						CRUZADArandomforestbin
********************************************************************
********************************************************************/


%macro cruzadarandomforestbin(archivo=,vardep=,listconti=,listcategor=,
maxtrees=100,variables=3,porcenbag=0.80,maxbranch=2,tamhoja=5,maxdepth=10,pvalor=0.1,
ngrupos=4,sinicio=12345,sfinal=12385,objetivo=tasafallos);

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
data tres;set dos;if grupo ne &exclu then vardep=&vardep*1;


ods listing close;
proc hpforest data=tres
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

data salo;merge salo tres;
if p_vardep1>0.5 then pre11=1;else pre11=0; 
if grupo=&exclu;
run;

	proc freq data=salo;tables pre11*&vardep/out=sal3;run;
		data estadisticos (drop=count percent pre11 &vardep); 
		retain vp vn fp fn suma 0; 
		set sal3 nobs=nume; 
		suma=suma+count; 
		if pre11=0 and &vardep=0 then vn=count; 
		if pre11=0 and &vardep=1 then fn=count; 
		if pre11=1 and &vardep=0 then fp=count; 
		if pre11=1 and &vardep=1 then vp=count; 
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

%end;/* fin grupos */
	proc means data=fantasma sum noprint;var &objetivo;
	output out=sumaresi sum=suma mean=media;
	run;
	data sumaresi;set sumaresi;semilla=&semilla;
	data final (keep=suma media semilla);set final sumaresi;if suma=. then delete;run;
%end;/* fin semillas validación cruzada repetida*/


proc print data=final;run;


%mend;

/********************************************************************
********************************************************************
						CRUZADAtreeboostbin
********************************************************************
********************************************************************/

%macro cruzadatreeboostbin(archivo=,vardepen=,conti=,categor=,ngrupos=,sinicio=,sfinal=,criterion=ProbF,leafsize=5,
iteraciones=100,shrink=0.01,maxbranch=2,maxdepth=4,mincatsize=15,minobs=20,objetivo=tasafallos);
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
		data tres;set dos;if grupo ne &exclu then vardep=&vardepen*1;

	proc treeboost data=tres
	exhaustive=1000 intervaldecimals=max
	leafsize=&leafsize iterations=&iteraciones maxbranch=&maxbranch 
	maxdepth=&maxdepth mincatsize=&mincatsize missing=useinsearch shrinkage=&shrink 
	splitsize=&minobs; 
	%if (&categor ne) %then %do;
	input &categor/level=nominal;
	%end;
	input &conti/level=interval;
	target vardep /level=binary;
	save fit=iteraciones importance=impor model=modelo rules=reglas;
	subseries largest;
	score out=sal;

	data sal2;set sal;pro=1-p_vardep0;if pro>0.5 then pre11=1; else pre11=0;
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

/********************************************************************
********************************************************************
						CRUZADAkNN

Nota: no permite variables categóricas pero se pueden construir 
dummys y meterlas como cntinuas 
 
********************************************************************
********************************************************************/
%macro cruzadakNNbin(archivo=,vardepen=,listconti=,ngrupos=,seminicio=,semifinal=,k=);
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

data tres;set dos;if grupo ne &exclu then vardep=&vardepen*1;else vardep=.;run;

/*************************************************************/
/* kNN */
	proc discrim data=tres noprint method=npar k=&k out=saco;/*<<<<<******SE PUEDE QUITAR EL NOPRINT */
	class vardep;
	var &listconti;
	;run;
/*************************************************************/

data sal1(drop=_1);set saco;predi1=_1;run;
 
data salbis;
set sal1;if grupo=&exclu;
if predi1>0.5 then pre1=1;
if predi1<=0.5 then pre1=0;
run;

data salbos;run;
proc freq data=salbis noprint;tables pre1*&vardepen /out=salconfu;run;
data confu1 (keep=tasa1);retain buenos 0 malos 0;set salconfu nobs=nume;
if &vardepen=pre1 then buenos=buenos+count;
if &vardepen ne pre1 then malos=malos+count;
if _n_=nume then do;tasa1=malos/(malos+buenos);output;end;
run;
data salbos;merge salbos confu1;run;
;

data fantasma;set fantasma salbos;run;

%end;  
/* FIN GRUPOS */
proc means data=fantasma noprint;var tasa1;
output out=mediaresi mean=media;
run;
data mediaresi;set mediaresi;semilla=&semilla;run;
data final (keep=media semilla);set final mediaresi;if media=. then delete;run;
%end;
proc printto; run;
proc print data=final;run;
%mend;


/********************************************************************
********************************************************************
						CRUZADASVM

El parámetro C controla el soft margin 
(C más grande, modelo más ajustado, menos sesgo más varianza; C más pequeño, modelo más simple, 
más sesgo menos varianza)

Nota: El parámetro kernel puede ser de las siguientes formas:

kernel=linear
kernel=polynom k_par=2 (2 o 3 grado del polinomio; más alto más complejo)
kernel=RBF k_par=gamma (más bajo, más suavizado, más alto, más agresivo en cuanto a las zonas) 

Para un ejemplo de la interdependencia entre C y gamma 
http://scikit-learn.org/stable/auto_examples/svm/plot_rbf_parameters.html

El procedimiento SVM es experimental y falla a menudo con kernel RBF

********************************************************************
********************************************************************/

%macro cruzadaSVMbin(archivo=,vardepen=,listclass=,listconti=,ngrupos=,seminicio=,semifinal=,kernel=linear,c=10);
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

data tres valida;set dos;if grupo ne &exclu then do;vardep=&vardepen;output tres;end;else output valida;run;

/*************************************************************/
/* SVM */
/*************************************************************/

PROC DMDB DATA=tres dmdbcat=catatres out=cua;
target vardep ;
var &listconti;
class vardep &listclass;
;run;

proc svm data=cua dmdbcat=catatres testdata=valida kernel=&kernel testout=sal6 c=&c;
   var &listconti &listclass;
   target vardep;
run;
data sal1(keep=&vardepen predi1 grupo vardep);set sal6;predi1=_i_;run;

data salbis;
set sal1;if grupo=&exclu;
if predi1>0.5 then pre1=1;
if predi1<=0.5 then pre1=0;
run;

data salbos;run;
proc freq data=salbis noprint;tables pre1*&vardepen /out=salconfu;run;
data confu1 (keep=tasa1);retain buenos 0 malos 0;set salconfu nobs=nume;
if &vardepen=pre1 then buenos=buenos+count;
if &vardepen ne pre1 then malos=malos+count;
if _n_=nume then do;tasa1=malos/(malos+buenos);output;end;
run;
data salbos;merge salbos confu1;run;
;

data fantasma;set fantasma salbos;run;

%end;  
/* FIN GRUPOS */
proc means data=fantasma noprint;var tasa1;
output out=mediaresi mean=media;
run;
data mediaresi;set mediaresi;semilla=&semilla;run;
data final (keep=media semilla);set final mediaresi;if media=. then delete;run;
%end;
proc printto; run;
proc print data=final;run;
%mend;


/********************************************************************
********************************************************************
/* EJEMPLO GERMAN DATA VALIDACIÓN CRUZADA */
/********************************************************************
********************************************************************
options nonotes;
options mprint=0;

data uno;set discoc.germanmod;run;
proc print data=uno;run;

%cruzadabinarianeural
(archivo=uno,
vardepen=bad,
conti=age amount checking duration installp savings,
categor=foreign history marital other purpose,
ngrupos=4,sinicio=12345,sfinal=12385,
nodos=10,meto=bprop mom=0.2 learn=0.7,objetivo=tasafallos);
data final1;set final;modelo='RED';

%cruzadalogistica
(archivo=uno,
vardepen=bad,
conti=age amount checking duration installp savings,
categor=foreign history marital other purpose,ngrupos=4,sinicio=12345,sfinal=12385,objetivo=tasafallos);
data final2;set final;modelo='LOG';

%cruzadabaggingbin
(archivo=uno,
vardepen=bad,
listconti=age amount checking duration installp savings,
listcategor=foreign history marital other purpose,ngrupos=4,
sinicio=12345,sfinal=12385,
siniciobag=22345,sfinalbag=22355,
porcenbag=0.80,maxbranch=2,nleaves=6,tamhoja=5,reemplazo=1,objetivo=tasafallos);
data final3;set final;modelo='BAG';

%cruzadarandomforestbin(archivo=uno,
vardep=bad,
listconti=age amount checking duration installp savings,
listcategor=foreign history marital other purpose,
maxtrees=100,variables=3,porcenbag=0.80,maxbranch=2,tamhoja=5,maxdepth=10,pvalor=0.1,
ngrupos=4,sinicio=12345,sfinal=12385,objetivo=tasafallos);
data final4;set final;modelo='RFOREST';

%cruzadatreeboostbin
(archivo=uno,
vardepen=bad,
conti=age amount checking duration installp savings,
categor=foreign history marital other purpose,
ngrupos=4,sinicio=12345,sfinal=12385,leafsize=5,
iteraciones=200,shrink=0.01,maxbranch=2,maxdepth=4,mincatsize=15,minobs=15,objetivo=tasafallos);
data final5;set final;modelo='BOOST';


data unobis;set uno;bad2=bad*1;run;
proc glmmod data=unobis outdesign=unodummy;
class foreign history marital other purpose ;
model bad2=age amount checking duration installp savings foreign history marital other purpose;
run;
proc contents data=unodummy;run;

%cruzadakNNbin(archivo=unodummy,vardepen=bad2,
listconti=col1-col31,
ngrupos=4,seminicio=12345,semifinal=12385,k=7);
data final6;set final;modelo='kNN';

%cruzadaSVMbin
(archivo=uno,
vardepen=bad,
listconti=age amount checking duration installp savings,
listclass=foreign history marital other purpose,
ngrupos=4,seminicio=12345,semifinal=12385,kernel=polynom k_par=2,c=10);
data final7;set final;modelo='SVM';


data union;set final1 final2 final3 final4 final5 final6 final7;
ods graphics off;
proc boxplot data=union;plot media*modelo;run;



*/
