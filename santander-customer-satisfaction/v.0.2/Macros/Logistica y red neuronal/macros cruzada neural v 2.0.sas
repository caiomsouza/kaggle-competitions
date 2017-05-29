/*******************************************************************
/* MACRO VALIDACIÓN CRUZADA PARA REGRESIÓN NORMAL

%macro cruzada(archivo=,vardepen=,conti=,categor=,ngrupos=,sinicio=,sfinal=);

archivo=archivo de datos
vardepen=nombre de la variable dependiente 
conti=variables independientes continuas
categor=variables independientes categóricas
ngrupos=número de grupos a dividir por validación cruzada
sinicio=semilla de inicio
sfinal=semilla final

La macro obtiene la suma y media de errores al cuadrado por CV para cada semilla.
Esta información está contenida en el archivo final
*************************************************************************/

%macro cruzada(archivo=,vardepen=,conti=,categor=,ngrupos=,sinicio=,sfinal=);
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
		proc glm data=tres noprint;/*<<<<<******SE PUEDE QUITAR EL NOPRINT */
		%if &categor ne %then %do;class &categor;model vardep=&conti &categor;%end;
		%else %do;model vardep=&conti;%end;
		output out=sal p=predi;run;
		data sal;set sal;resi2=(&vardepen-predi)**2;if grupo=&exclu then output;run;
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


/* EJEMPLO */

/*
data uno (drop=i);
do i=1 to 100;
x=ranuni(1234);
y=rannor(1234)+2*x;
z=rannor(34344);
clase=ranbin(0,1,0.5);
output;
end;
run;
proc print;run;

%cruzada(archivo=uno,vardepen=y,conti=x z,categor=clase,ngrupos=4,sinicio=12345,sfinal=12355);
*/

/* MACRO VALIDACIÓN CRUZADA PARA REDES NEURONALES

%macro cruzadaneural(archivo=,vardepen=,conti=,categor=,ngrupos=,sinicio=,sfinal=,ocultos=,meto=,acti=,early=);

archivo=archivo de datos
vardepen=nombre de la variable dependiente 
conti=variables independientes continuas
categor=variables independientes categóricas
ngrupos=número de grupos a dividir por validación cruzada
sinicio=semilla de inicio
sfinal=semilla final
nodos= número de nodos
early=iteraciones early stopping (dejar como early=, si no se desea)
algo=algoritmo (poner bprop mom=0.2 learn=0.1 si es bprop)

La macro obtiene la suma y media de errores al cuadrado por CV para cada semilla.
Esta información está contenida en el archivo llamado final

*/

%macro cruzadaneural(archivo=,vardepen=,conti=,categor=,ngrupos=,sinicio=,sfinal=,ocultos=3,meto=levmar,acti=tanh,early=);
/*Si no se quiere información en output usar esto (cambiar el archivo de destino):
proc printto print='c:\basura.txt'; 
*/
proc printto print='c:\basura.txt'; 
data final;run;
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
		var &vardepen &conti;
		%if &categor ne %then %do;class &categor;%end;
		run;
		proc neural data=trestr dmdbcat=catatres random=789 ;
		input &conti;
		%if &categor ne %then %do;input &categor /level=nominal;%end;
		target &vardepen;
		hidden &ocultos /act=&acti;/*<<<<<******PARA DATOS LINEALES ACT=LIN (funciónde activación lineal) 
		NORMALMENTE PARA DATOS NO LINEALES MEJOR ACT=TANH */
		/* A PARTIR DE AQUI SON ESPECIFICACIONES DE LA RED, SE PUEDEN CAMBIAR O AÑADIR COMO PARÁMETROS */

/* ESTO ES PARA EARLY STOPPING (maxiter=numero de iteraciones limitado)*/
		
	%if &early ne %then %do;
		nloptions maxiter=&early;
		netoptions randist=normal ranscale=0.1 random=15115;%end;
		/* %else %do;prelim 10;%end;*/
	%if &early ne %then %do;
		train maxiter=&early /* early stopping cambiar maxiter=25 por ejemplo */ outest=mlpest technique=&meto;%end;
		%else %do;train maxiter=100 /* early stopping cambiar maxiter=25 por ejemplo */ outest=mlpest technique=&meto/* bprop mom=0.2 learn=0.1*/;%end;
		score data=tresval role=valid out=sal ;
		run;
		data sal;set sal;resi2=(p_&vardepen-&vardepen)**2;run;
		data fantasma;set fantasma sal;run;
	%end;
	proc means data=fantasma sum noprint;var resi2;
	output out=sumaresi sum=suma mean=media;
	run;
	data sumaresi;set sumaresi;semilla=&semilla;
	data final (keep=suma media semilla);set final sumaresi;if suma=. then delete;run;
%end;
proc printto;run;
proc print data=final;run;
%mend;

/*
%cruzadaneural(archivo=uno,vardepen=y,conti=x z,categor=clase,ngrupos=4,sinicio=12345,sfinal=12355,ocultos=5); */

/* SI SE QUIERE HACER UN BOXPLOT DE COMPARACIÓN ENTRE LOS ERRORES CV OBTENIDOS CON DIFERENTES SEMILLAS EN VARIOS MODELOS*/

/*
data uno (drop=i);
do i=1 to 100;
x=ranuni(1234);
y=rannor(1234)+2*x+4*(z**2)+7*exp(x*z);
z=rannor(34344)*5;
clase=ranbin(0,1,0.5);
output;
end;
run;

%cruzada(archivo=uno,vardepen=y,conti=x z,categor=clase,ngrupos=4,sinicio=12345,sfinal=12355);
data final1;set final;modelo=1;
%cruzadaneural(archivo=uno,vardepen=y,conti=x z,categor=clase,ngrupos=4,sinicio=12345,sfinal=12355,ocultos=5);
data final2;set final;modelo=2;
%cruzadaneural(archivo=uno,vardepen=y,conti=x z,categor=clase,ngrupos=4,sinicio=12345,sfinal=12355,ocultos=15);
data final3;set final;modelo=3;

data union;set final1 final2 final3;
proc boxplot data=union;plot media*modelo;run;


*/
/*************************************************************************
/* SI SE QUIERE COMPARAR POR EJEMPLO NÚMERO DE NODOS POR VALIDACIÓN CRUZADA Y BOXPLOT			
/************************************************************************/

/*
%macro nodosvalcruza(ini=,fin=,increme=);
%do nod=&ini %to &fin %by &increme;
 %cruzadaneural(archivo=uno,vardepen=y,conti=x z,categor=clase,ngrupos=3,sinicio=12345,sfinal=12347,ocultos=&nod);
 data final&nod;set final;modelo=&nod;run;
%end;
data union;set %do i=&ini %to &fin %by &increme; final&i %end;;;;
%mend;
%nodosvalcruza(ini=2,fin=8,increme=2);
proc print data=union;run;
proc boxplot data=union;plot media*modelo;run;

*/


/*************************************************************************
/* SI SE QUIERE COMPARAR POR EJEMPLO ACTIVACIÓN CON BOXPLOT	
/************************************************************************/

%macro activalcruza;
%let lista='TANH LOG ARC LIN SIN SOF GAU';
%let nume=7;
%do  i=1 %to &nume;
data _null_;activa=scanq(&lista,&i);call symput('activa',left(activa));run;
 %cruzadaneural(archivo=uno,vardepen=y,conti=x z,categor=clase,ngrupos=3,sinicio=12345,sfinal=12347,ocultos=10,acti=&activa);
 data final&i;set final;modelo="&activa";put modelo=;run;
%end;
data union;set %do i=1 %to &nume; final&i %end;
%mend;

%activalcruza;

proc print data=union;run;
proc boxplot data=union;plot media*modelo;run;

/*************************************************************************
/* SI SE QUIERE COMPARAR POR EJEMPLO METODO CON BOXPLOT	
/************************************************************************/

%macro algovalcruza;
%let lista='BPROP LEVMAR QUANEW TRUREG';
%let nume=4;
%do  i=1 %to &nume;
data _null_;meto=scanq(&lista,&i);call symput('meto',left(meto));run;
 %cruzadaneural(archivo=uno,vardepen=y,conti=x z,categor=clase,ngrupos=3,sinicio=12345,sfinal=12347,ocultos=10,meto=&meto);
 data final&i;set final;modelo="&meto";put modelo=;run;
%end;
data union;set %do i=1 %to &nume; final&i %end;
%mend;

%algovalcruza;

proc print data=union;run;
proc boxplot data=union;plot media*modelo;run;

/*************************************************************************
/* SI SE QUIEREN COMBINAR DOS BUCLES (ACTIVACIÓN Y ALGORITMO)
Desgraciadamente no siempre funcionan pues pueden fallar ocasionalmente los
algoritmos con determinadas funciones de activación
/************************************************************************/

%macro algoactivalcruza;
%let lista1='LEVMAR QUANEW ';
%let lista2='TANH LOG ARC LIN SIN';
%let nume1=2;
%let nume2=5;
data _null_;pro1=&nume1*&nume2;call symput('pro1',left(pro1));run;
data contador;conta=0;run;
%do  i=1 %to &nume1;
%do j=1 %to &nume2;
data contador;if _n_=1 then do;set contador;conta=conta+1;output;call symput('conta',left(conta));end;run;
data _null_;meto=scanq(&lista1,&i);call symput('meto',left(meto));run;
data _null_;activa=scanq(&lista2,&j);call symput('activa',left(activa));run;
 %cruzadaneural(archivo=uno,vardepen=y,conti=x z,categor=clase,ngrupos=3,sinicio=12345,sfinal=12347,ocultos=10,meto=&meto,acti=&activa);
 data final&conta;set final;modelo=compress("&meto"||"&activa");put modelo=;run;
%end;
%end;
data union;set %do i=1 %to &pro1; final&i %end;run;
%mend;

%algoactivalcruza;

proc print data=union;run;
proc boxplot data=union;plot media*modelo;run;

proc print data=final1;run;
proc print data=final2;run;
proc print data=final17;run;

data union;set final1 final2 final3 final4;run;
proc print data=union;run;
