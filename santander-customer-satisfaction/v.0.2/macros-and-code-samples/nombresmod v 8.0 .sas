/****************************************************************************************
/* LA MACRO NOMBRESMODBIEN CREA UN ARCHIVO DE DISEÑO DE DUMMYS CON EFECTOS E INTERACCIONES 
SEGÚN EL MODELO DADO USANDO PROC GLMMOD Y LAS NOMBRA ADECUADAMENTE
PARA PODER ENTENDERLAS (CAMBIANDO LOS NOMBRES COL1---COLN)

SOLO VALE DE MOMENTO PARA DATOS NO MISSING, EN TODAS LAS VARIABLES TRATADAS
**************************************************************************

%macro nombresmodbien (archivo=,depen=,modelo=,listclass=,listconti=,corte=,directorio=c:);

archivo=
depen=variable dependiente
modelo=se deben poner los efectos principles e interacciones que se desee
(solo hasta orden dos)
listclass=lista de variables de clase
listconti=lista de variables continuas
corte=No se crearán en el archivo de salida dummys para categorías 
que tengan un número de observaciones menor del corte 
directorio= poner el directorio para archivos temporales basura

********
SALIDA Y NOTAS
********

1) EL ARCHIVO DE SALIDA SE LLAMA PRETEST. TIENE LOS DATOS ORIGINALES CON LAS INTERACCIONES CREADAS Y BIEN NOMBRADAS. 
CADA VARIABLE CUALITATIVA E INTERACCIONES ENTRE 2 CUALITATIVAS O ENTRE 1 CUALITATIVA Y 1 CONTINUA ESTÁ EXPANDIDO EN DUMMYS 

2) EN EL LOG HAY UN LISTADO DE LAS VARIABLES/EFECTOS CREADOS EN EL ARCHIVO

3) NOTA: SE PUEDE FINALMENTE, SI SE DESEA, HACER UN MERGE CON EL ARCHIVO ORIGINAL PARA TENER 
TODAS LAS VARIABLES CREADAS Y ADEMÁS LAS ORIGINALES:

data final;merge pretest archivooriginal;run;

4) DE CARA A CONSTRUIR MODELOS LAS VARIABLES CREADAS CON ESTA MACRO EN PRETEST
SE TRATARÁN COMO CONTINUAS EN CADA PROCEDIMIENTO POSTERIOR.

****************************************************************************************/
options mprint=0;
%macro nombresmodbien(archivo=,depen=,modelo=,listclass=,listconti=,corte=0,directorio=c:);
options NOQUOTELENMAX; 
%let haycont=1;
proc glmmod data=&archivo outdesign=outdise outparm=nomcol noprint namelen=200;
class &listclass;
model &depen=&modelo;
run;
/* borro intercept */
data outdise2;set outdise;drop col1 &depen;run;
data nomcol;set nomcol;if _colnum_=1 then delete;run;
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
data _null_;
clase="&modelo";
  nmodelo= 1;
  do while (scanq(clase, nmodelo) ^= '');
    nmodelo+1;
  end;
  nmodelo+(-1);
  call symput('nmodelo',left(nmodelo));
run;

/* capturo nombres de interacciones */
data _null_;
length modelo2 $2000.;
modelo2=tranwrd("&modelo",'*','AAAA');
call symput('modelo2',left(modelo2));
run;

data uninombres;run;
data listacont;run;
%do j=1 %to &nmodelo;

%let efee=%qscan(&modelo2,&j);
%let positia=0;%let conta1=0;%let conta2=0;%let conta=0;%let suma=0;
%let varinombre1=' ';%let varinombre2=' ';
data _null_;length efee $2000.;efee="&efee";put efee=;
     positia=index(efee,'AAAA');
 if positia>0 then do;
	varinombre1=tranwrd(substr(efee,1,positia+3),'AAAA','');
	varinombre2=left(compress(substr(efee,positia+3,length(efee)),'AAAA'));
	call symput('varinombre1',left(varinombre1));
	call symput('varinombre2',left(varinombre2));
	call symput('positia',left(positia));
end;
else call symput('positia',left(positia));
run;

%if &positia ne 0 %then %do;

									/* todo esto si es una interacción */
data _null_;conta1=0;conta2=0;
		%do i=1 %to &ncate;
 			%let vari=%qscan(&listclass,&i);
 			if trim("&varinombre1")="&vari" then conta1=1;
 			if trim("&varinombre2")="&vari" then conta2=1;
		%end;
		suma=conta1+conta2;
	call symput('suma',left(suma));
	call symput('conta1',left(conta1));
	call symput('conta2',left(conta2));
run;
	
/* dos cualitativas */

%if &suma eq 2 %then %do;
title 'FRECU';
proc freq data=&archivo ;tables &varinombre1*&varinombre2 /out=salcruce;run;
data salcruce;set salcruce;
    if percent=. then delete;
	ko1=put(&varinombre1,30.);
	ko2=put(&varinombre2,30.);
drop &varinombre1;
drop &varinombre2;
ko1=left(ko1);
ko2=left(ko2);
rename ko1=&varinombre1;rename ko2=&varinombre2;
run;
proc sort data=nomcol;by &varinombre1 &varinombre2;run;
data nomcol2;set nomcol;if &varinombre1=' ' or &varinombre2=' ' then delete;
data nomcol2;merge nomcol2 salcruce(keep=count &varinombre1 &varinombre2) ;by &varinombre1 &varinombre2 ;
run;
data nomu;merge nomcol nomcol2 ;by &varinombre1 &varinombre2;
cosa1=cats("&varinombre1","*","&varinombre2");
cosa2=cats("&varinombre2","*","&varinombre1");if (effname=cosa1 and effname ne '') or (effname=cosa2 and effname ne '');
run;
data uninombres;set uninombres nomu;run;

%end;

/* continua y cualitativa */
%else %do;
	%if &conta1 eq 1 %then %do;%let efee=&varinombre1;%let efee=%trim(&efee);%end;
	%else %do;%let efee=&varinombre2;%let efee=%trim(&efee);%end;
	proc freq data=&archivo noprint;tables &efee /out=sal;run; 
	data sal;set sal;if percent=. then delete;run;
	data sal;set sal;
	ko=put(&efee,30.);
	drop &efee;ko=left(ko);
	rename ko=&efee;
	run;
	data nomu;set nomcol;
	cosa1=cats("&varinombre1","*","&varinombre2");
	cosa2=cats("&varinombre2","*","&varinombre1");
	if (effname=cosa1 and effname ne '') or (effname=cosa2 and effname ne '');run;
	data nomu;merge nomu sal;run;
	data uninombres;set uninombres nomu;run;
%end;


%end;
									/* FIN si es una interacción */

%else %do;

/* PRIMERO VER SI ES UNA CATEGÓRICA PARA AÑADIR COUNT*/

data _null_;
conta=0;
%do i=1 %to &ncate;
 %let vari=%qscan(&listclass,&i);
 if "&efee"="&vari" then conta=1;
%end;
call symput('conta',left(conta));
run;
%if &conta>0 %then %do;
	proc freq data=&archivo noprint;tables &efee /out=sal;run; 
	data sal;set sal;
	ko=put(&efee,30.);
	drop &efee;ko=left(ko);
	rename ko=&efee;
	run;
	data sal;set sal;if percent=. then delete;run;
 	data nomu;set nomcol;if effname="&efee" and &efee ne ' ' then output;run;
	data nomu;merge nomu sal;run;
	data uninombres;set uninombres nomu;run;
 	
%end;

%else %do; /*ES UNA VARIABLE CONTINUA SUELTA */
data nomu (drop=haycont);set nomcol;if effname="&efee" then output;
haycont=1;
call symput('haycont',left(haycont));
run;
data listacont;set listacont nomu;run;
%end;


%end;/* fin no es una interacción */


%end; /* fin efectos en el modelo */
data uninombres;set uninombres;drop percent cosa1 cosa2;run;
title 'TODOS LOS EFECTOS SALVO CONTINUAS';
proc print data=uninombres;run;
data nomcol;set uninombres;
 if effname='Intercept' then delete;
 if _colnum_=. then delete;
 if count=. or count>&corte then output;
run;
%if &haycont=1 %then %do;
data listacont;set listacont;if _n_=1 then delete;run;
data nomcol;set nomcol listacont;run;
%end;
title 'SOLO EFECTOS INCLUIDOS';
proc print data=nomcol;run;
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
if conta=0 then do; %do i=1 %to &ncate;
                 %let vari=%qscan(&listclass,&i);
				 efecto=compress(cats(efecto,&vari),,"p");
				%end;end;
run;

proc sort data=efectos;by _colnum_;run;
proc contents data=outdise2 out=salcon noprint;run;

data salcon(keep=name _colnum_ colu);set salcon;
 colu=compress(name,'Col');
 _colnum_=input(colu, 5.); 
run;
proc sort data=salcon;by _colnum_;run;

data unisalefec malos;merge salcon efectos(in=ef);by _colnum_;if ef=1 then output unisalefec;else output malos;run;
filename renomb "&directorio\reno.txt";
filename malos "&directorio\listamalos.txt";
data _null_;
 file "&directorio\listamalos.txt";
 set malos end=eof;
 if _n_=1 then put 'data outdise2;set outdise2;drop ';put name @@;
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
proc contents data=pretest out=salnom noprint;run;
data _null_;set salnom;if _n_=1 then put //;put name @@;run;
data pretest;merge &archivo(keep=&depen) pretest;run;
%mend; 




/* AMESHOUSING
CONTINUAS

Bedroom_AbvGr BsmtFin_SF_1 BsmtFin_SF_2 Bsmt_Full_Bath Bsmt_Half_Bath Bsmt_Unf_SF Enclosed_Porch Fireplaces Full_Bath Garage_Area Garage_Cars Garage_Yr_Blt
Gr_Liv_Area Half_Bath Kitchen_AbvGr Lot_Area Lot_Frontage Low_Qual_Fin_SF Mas_Vnr_Area Misc_Val Mo_Sold Open_Porch_SF Order Overall_Cond Overall_Qual Pool_Area
SalePrice Screen_Porch TotRms_AbvGrd Total_Bsmt_SF Wood_Deck_SF Year_Built Year_Remod_Add Yr_Sold _Ssn_Porch _nd_Flr_SF _st_Flr_SF

NOMINALES

Alley Bldg_Type BsmtFin_Type_1 BsmtFin_Type_2 Bsmt_Cond Bsmt_Exposure Bsmt_Qual Central_Air Condition_1 Condition_2 Electrical Exter_Cond Exter_Qual
Exterior_1st Exterior_2nd Fence Fireplace_Qu Foundation Functional Garage_Cond Garage_Finish Garage_Qual Garage_Type Heating Heating_QC House_Style Kitchen_Qual
Land_Contour Land_Slope Lot_Config Lot_Shape MS_SubClass MS_Zoning Mas_Vnr_Type Misc_Feature Neighborhood PID Paved_Drive Pool_QC Roof_Matl Roof_Style
Sale_Condition Sale_Type Street Utilities

*/


/* Ejemplos

%nombresmodbien(archivo=ames,depen=Saleprice,
modelo=Alley*Bldg_Type Bedroom_AbvGr*BsmtFin_Type_1  BsmtFin_SF_1*BsmtFin_Type_2 BsmtFin_SF_1 Total_Bsmt_SF ,
listclass=Alley Bldg_Type BsmtFin_Type_1 BsmtFin_Type_2 ,
listconti=Bedroom_AbvGr BsmtFin_SF_1 Total_Bsmt_SF ,
corte=90,directorio=c:);

proc contents data=pretest;run;
proc print data=pretest(obs=10);run;

%nombresmodbien(archivo=ames,depen=Saleprice,
modelo=BsmtFin_Type_1 Alley*Bldg_Type Alley*BsmtFin_SF_1 ,listclass=Alley Bldg_Type BsmtFin_Type_1 ,listconti=BsmtFin_SF_1 ,corte=90
,directorio=c:);
 
proc contents data=pretest;run;
proc print data=pretest(obs=10);run;

%nombresmodbien(archivo=ames,depen=Saleprice,
modelo=
Alley*Bldg_Type
,listclass=Alley Bldg_Type ,listconti=,corte=50,directorio=c:);

proc contents data=pretest;run;

options mprint;

 

