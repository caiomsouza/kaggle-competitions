
/* VALIDACIÓN CRUZADA LOGÍSTICA PARA VARIABLES DEPENDIENTES BINARIAS 

*********************************************************************************
								PARÁMETROS
*********************************************************************************

BÁSICOS

archivo=		archivo de datos
vardepen=		variable dependiente binaria 
categor=		lista de variables independientes categóricas
conti=			lista de variables independientes continuas Y TODAS LAS INTERACCIONES
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
	data dos (drop=nume);
	retain grupo 1;
	set dos nobs=nume;
	if _n_>grupo*nume/&ngrupos then grupo=grupo+1;
	run;
	data fantasma;run;
	%do exclu=1 %to &ngrupos;
		data tres;set dos;if grupo ne &exclu then vardep=&vardepen;
		proc logistic data=tres noprint;/*<<<<<******SE PUEDE QUITAR EL NOPRINT */
		%if (&categor ne) %then %do;class &categor;model vardep=&conti &categor ;%end;
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


/* LA MACRO CRUZADABINARIANEURAL GENERA RESULTADOS POR CLASIFICACIÓN BINARIA 
CON RED NEURONAL CON VARIAS SEMILLAS

PARÁMETROS:

archivo
vardepen 	debe de ser variable con dos categorías excluyentes
conti 		lista de variables continuas en el modelo	
categor		lista de variables categóricas en el modelo	
ngrupos		grupos de validación cruzada
sinicio		semilla inicial de aleatorización
sifinal		semilla final de aleatorización
nodos		número de nodos red
meto		algoritmo
objetivo	función objetivo para resumir en archivos y boxplot. Palabras clave:
			
		tasafallos (habitualmente se utilizará esta)
		porcenVN
		porcenFN
		porcenVP
		porcenFP
		sensi
		especif
		tasaciertos
		precision
		F_M

El archivo llamado final contiene la media y suma de la función objetivo por validación cruzada

NOTA: A VECES EL PROCESO DE OPTIMIZACIÓN ES DEFECTUOSO (EL EARLY STOPPING NO SIEMPRE FUNCIONA BIEN).
SUELE TAMBIÉN HABER CIERTA DEPENDENCIA DE LA SEMILLA INICIAL UTILIZADA PARA LOS PESOS.
EN ESTOS CASOS HABRÁ QUE 

1) UTILIZAR PRELIM
2)CAMBIAR  EL NÚMERO DE ITERACIONES Y/O CAMBIAR EL ALGORITMO
(o sus parámetros, aumentar por ejemplo mom en BPROP)
	
*/


%macro cruzadabinarianeural(archivo=,vardepen=,
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
		hidden &nodos /act=tanh;/*<<<<<******PARA DATOS LINEALES ACT=LIN (funciónde activación lineal) 
		NORMALMENTE PARA DATOS NO LINEALES MEJOR ACT=TANH */
		/* A PARTIR DE AQUI SON ESPECIFICACIONES DE LA RED, SE PUEDEN CAMBIAR O AÑADIR COMO PARÁMETROS */

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



/*

Example:


%cruzadalogistica
(archivo=uno,vardepen=bad,
conti=checking duration employed foreign ,
categor=purpose,
ngrupos=4,sinicio=12345,sfinal=12348);
data final1;set final;modelo=1;

%cruzadabinarianeural(archivo=uno,vardepen=bad,
conti=checking duration employed foreign ,
categor=purpose,
ngrupos=4,sinicio=12345,sfinal=12348,
nodos=30,meto=levmar);

data final2;set final;modelo=2;

data union;set final1 final2 ;
ods graphics off;
proc boxplot data=union;plot media*modelo;run;

%macro early1;
data union;run;
%do early=10 %to 200 %by 30;
%cruzadabinarianeural(archivo=uno,vardepen=bad,
conti=checking duration employed foreign ,
categor=purpose,
ngrupos=4,sinicio=12345,sfinal=12345,
nodos=5,meto=levmar,early=&early,directorio=c:);
data final;set final;early=&early;run;
data union;set union final;run;
%end;
proc gplot data=union;plot media*early;run;
%mend;
%early1;


*/
