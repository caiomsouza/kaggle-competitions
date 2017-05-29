/*******************************************************************
/* MACRO VALIDACIÓN CRUZADA PARA REGRESIÓN NORMAL CON 
LA VARIABLE DEPENDIENTE TRANSFORMADA LOGARÍTMICAENTE

%macro cruzadabis(archivo=,vardepen=,conti=,categor=,ngrupos=,sinicio=,sfinal=);

archivo=archivo de datos
vardepen=nombre de la variable dependiente 
conti=variables independientes continuas
categor=variables independientes categóricas
ngrupos=número de grupos a dividir por validación cruzada
sinicio=semilla de inicio
sfinal=semilla final

La macro obtiene la suma y media de errores al cuadrado por CV para cada semilla.
La variable que se indica como dependiente es la variable dependiente transformada logarítmicamente

La información está contenida en el archivo final

Se puede poner antes de ejecuciones largas la sentencia

options nonotes;

para no llenar la ventana log y que no nos pida borrarla

Para volver a ver comentarios-errores en log:

options notes;
*************************************************************************/

%macro cruzadabis(archivo=,vardepen=,listconti=,listclass=,ngrupos=,sinicio=,sfinal=);
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
		data sal;set sal;resi2=(exp(&vardepen)-exp(predi))**2;if grupo=&exclu then output;run;
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


