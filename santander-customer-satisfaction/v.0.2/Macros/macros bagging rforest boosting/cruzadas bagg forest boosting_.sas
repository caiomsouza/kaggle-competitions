
/*validación cruzada de gradient boosting*/

%macro cruzadatreeboost(archivo=,vardepen=,conti=,categor=,ngrupos=,sinicio=,sfinal=,leafsize=5,
iteraciones=100,shrink=0.01,maxbranch=2,maxdepth=4,mincatsize=15,minobs=20);
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

	proc treeboost data=tres
	exhaustive=1000 intervaldecimals=max
	leafsize=&leafsize iterations=&iteraciones maxbranch=&maxbranch 
	maxdepth=&maxdepth mincatsize=&mincatsize missing=useinsearch shrinkage=&shrink 
	splitsize=&minobs; 
	%if (&categor ne) %then %do;
	input &categor/level=nominal;
	%end;
	input &conti/level=interval;
	target vardep /level=interval;
	save fit=iteraciones importance=impor model=modelo rules=reglas;
	subseries largest;
	score out=sal;

data sal;set sal;resi2=(&vardepen-p_vardep)**2;if grupo=&exclu then output;run;
		data fantasma;set fantasma sal;run;
	%end;
	proc means data=fantasma sum noprint;var resi2;
	output out=sumaresi sum=suma mean=media;
	run;
	data sumaresi;set sumaresi;semilla=&semilla;
	data final (keep=suma media semilla);set final sumaresi;if suma=. then delete;run;
%end;
proc print data=final;run;
%mend;


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
		data tres;set dos;if grupo ne &exclu then vardep=&vardepen;

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

options mprint=0;

/* Ejemplos binaria 

data saheart;set discoc.saheart;run;

%cruzadatreeboostbin(archivo=saheart,vardepen=chd,
conti=tobacco ldl ,categor=famhist,ngrupos=4,sinicio=12345,sfinal=12365,leafsize=5,
iteraciones=100,shrink=0.03,maxbranch=2,maxdepth=4,mincatsize=15,minobs=20,objetivo=tasafallos);
data final1;set final;modelo=1;

%cruzadatreeboostbin(archivo=saheart,vardepen=chd,
conti=tobacco ldl ,categor=famhist,ngrupos=4,sinicio=12345,sfinal=12365,leafsize=5,
iteraciones=300,shrink=0.01,maxbranch=2,maxdepth=4,mincatsize=15,minobs=20,objetivo=tasafallos);
data final2;set final;modelo=2;

%cruzadalogistica(archivo=saheart,
vardepen=chd,conti=tobacco ldl age typea,
categor=famhist,ngrupos=4,sinicio=12345,sfinal=12365,objetivo=tasafallos);
data final3;set final;modelo=3;

data union;set final1 final2 final3 ;
ods graphics off;
proc boxplot data=union;plot media*modelo;run;

*/

/* Ejemplo regresión

data fev;set discoc.fev;run;

%cruzadatreeboost
(archivo=fev,vardepen=fev,
conti=height age,categor=sex smoker,ngrupos=4,sinicio=12345,sfinal=12365,leafsize=5,
iteraciones=100,shrink=0.03,maxbranch=2,maxdepth=4,mincatsize=15,minobs=20);
data final1;set final;modelo=1;

%cruzadatreeboost
(archivo=fev,vardepen=fev,
conti=height age,categor=sex smoker,ngrupos=4,sinicio=12345,sfinal=12365,leafsize=5,
iteraciones=1000,shrink=0.01,maxbranch=2,maxdepth=4,mincatsize=15,minobs=20);
data final2;set final;modelo=2;

data uni;set final1 final2 ;
ods graphics off;
proc boxplot data=uni;plot media*modelo;run;

*/


%macro cruzadarandomforestbin(archivo=,vardep=,listconti=,listcategor=,
maxtrees=100,variables=3,porcenbag=0.80,maxbranch=2,tamhoja=5,maxdepth=10,pvalor=0.1,
ngrupos=4,sinicio=12345,sfinal=12355,objetivo=tasafallos);

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
data tres;set dos;if grupo ne &exclu then vardep=&vardep;


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

/* EJEMPLO CRUZADA RANDOM FOREST 

%cruzadarandomforestbin(archivo=uno,vardep=bad,listconti=age amount checking duration installp savings,
listcategor=foreign history marital other purpose,
maxtrees=100,variables=3,porcenbag=0.80,maxbranch=2,tamhoja=5,maxdepth=10,pvalor=0.1,
ngrupos=4,sinicio=12345,sfinal=12355,objetivo=tasafallos);


*/


%macro cruzadabaggingbin(archivo=,vardepen=,listconti=,listcategor=,
ngrupos=4,
sinicio=12345,sfinal=12355,
siniciobag=12345,sfinalbag=12355,
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
data tres;set dos;if grupo ne &exclu then vardep=&vardepen;

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

/* Ejemplo cruzada bagging bin 

%cruzadabaggingbin(archivo=uno,
vardepen=bad,
listconti=age amount checking duration installp savings,
listcategor=foreign history marital other purpose,
ngrupos=4,sinicio=12345,sfinal=12355,
siniciobag=12345,sfinalbag=12355,
porcenbag=0.7,maxbranch=2,
nleaves=30,tamhoja=10,
reemplazo=1,objetivo=tasafallos);

*/


/* EJEMPLO COMPARANDO BAGGING LOGISTICA RANDOM FOREST Y GRADIENT BOOSTING CON EL ARCHIVO GERMAN

data uno;set discoc.germanmod;Run;

%cruzadabaggingbin(archivo=uno,
vardepen=bad,
listconti=age amount checking duration installp savings,
listcategor=foreign history marital other purpose,
ngrupos=4,sinicio=13345,sfinal=13355,
siniciobag=12345,sfinalbag=12355,
porcenbag=0.7,maxbranch=2,
nleaves=30,tamhoja=10,
reemplazo=1,objetivo=tasafallos);
data final1;set final;modelo=1;
proc print data=final1;run;

%cruzadalogistica(archivo=uno,
vardepen=bad,
conti=age amount checking duration installp savings,
categor=foreign history marital other purpose,
ngrupos=4,sinicio=13345,sfinal=13355,
objetivo=tasafallos);
data final2;set final;modelo=2;

%cruzadatreeboostbin(archivo=uno,
vardepen=bad,
conti=age amount checking duration installp savings,
categor=foreign history marital other purpose,leafsize=5,
iteraciones=100,shrink=0.1,maxbranch=2,maxdepth=4,mincatsize=15,minobs=20,
ngrupos=4,sinicio=13345,sfinal=13355,objetivo=tasafallos);
data final3;set final;modelo=3;

%cruzadarandomforestbin(archivo=uno,vardep=bad,listconti=age amount checking duration installp savings,
listcategor=foreign history marital other purpose,
maxtrees=100,variables=3,porcenbag=0.80,maxbranch=2,tamhoja=5,maxdepth=10,pvalor=0.1,
ngrupos=4,sinicio=13345,sfinal=13355,objetivo=tasafallos);
data final4;set final;modelo=4;

data union;set final1 final2 final3 final4;
proc boxplot data=union;plot media*modelo;run;


   
*/
