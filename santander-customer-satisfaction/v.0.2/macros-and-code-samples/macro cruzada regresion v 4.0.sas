

/*******************************************************************
/* MACRO VALIDACIÓN CRUZADA PARA REGRESIÓN NORMAL

%macro cruzada(archivo=,vardepen=,listconti=,listclass=,ngrupos=,sinicio=,sfinal=);

archivo=archivo de datos
vardepen=nombre de la variable dependiente 
listconti=variables independientes continuas
listclass=variables independientes categóricas
ngrupos=número de grupos a dividir por validación cruzada
inicio=semilla de inicio
sfinal=semilla final

*******
SALIDA
*******
La macro obtiene la suma y media de errores al cuadrado por CV para cada semilla.
Esta información está contenida en el archivo final.
Variables:
media=media de errores de validación cruzada por cada ejecución-semilla
suma=suma de errores de validación cruzada por cada ejecución-semilla

NOTAS

1) Se puede poner antes de ejecuciones largas la sentencia
	options nonotes;
para no llenar la ventana log y que no nos pida borrarla.
Para volver a ver comentarios-errores en log:
	options notes;

2) Para comparar modelos, añadir la variable modelo despues de ejecutada la macro con
cada uno de los modelos:
%cruzada...
data final1;set final;modelo=1;run;
...
%cruzada...
data final5;set final;modelo=5;run;

y finalmente union y un boxplot:

data union;set final1 final2...final5;
proc boxplot data=final;plot media*modelo;run;
*************************************************************************/

%macro cruzada(archivo=,vardepen=,listconti=,listclass=,ngrupos=,sinicio=,sfinal=);
data final;run;
/* Bucle semillas */
%do semilla=&sinicio %to &sfinal;
	data dos;set &archivo;u=ranuni(&semilla);
	proc sort data=dos;by u;run;
	data dos;
	retain grupo 1;
	set dos nobs=nume;
	if _n_>grupo*nume/&ngrupos then grupo=grupo+1;
	run;
	data fantasma;run;
	%do exclu=1 %to &ngrupos;
		data tres;set dos;if grupo ne &exclu then vardep=&vardepen;
		proc glm data=tres noprint;/*<<<<<******SE PUEDE QUITAR EL NOPRINT */
		%if &listclass ne %then %do;class &listclass;model vardep=&listconti &listclass;%end;
		%else %do;model vardep=&listconti;%end;
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

