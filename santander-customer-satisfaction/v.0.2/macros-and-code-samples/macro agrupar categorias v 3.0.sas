/* - LA MACRO AGRUPAR CONSTRUYE VARIABLES DE AGRUPACIÓN PARA VARIABLES CATEGÓRICAS DE BASE, 
		PARA UN MODELO CON VARIABLE DEPENDIENTE CONTINUA O DISCRETA, BASÁNDOSE EN CONTRASTES DE HIPÓTESIS BÁSICOS ENTRE NIVELES.

archivo=, 		 Archivo de datos que contiene a las variables Nominales 
vardep=, 		 Variable Dependiente (Intervalo o Nominal ) 
vardeptipo=, 	 Tipo de la variable dependiente: I=Intervalo o N=Nominal 
listclass=, 	 Lista separada por espacios de las variables a agrupar 
criterio= 		 Criterio usado para la división de las ramas en el proc arboretum 

* Criteria for Interval Targets
	VARIANCE 	-> reduction in square error from node means
	PROBF 		-> p-value of F test associated with node variances (default)
* Criteria for Nominal Targets
	ENTROPY 	-> Reduction in entropy
	GINI 		-> Reduction in Gini index
	PROBCHISQ 	-> p-value of Pearson chi-square for target vs. branches (default)
Criteria for Ordinal Targets
	ENTROPY 	-> Reduction in entropy, adjusted with ordinal distances
	GINI 		-> Reduction in Gini index, adjusted with ordinal distances (default)

directorio=		 directorio de trabajo para archivos de apoyo 

*******
SALIDA
*******

	*EL ARCHIVOFINAL CONTIENE LAS VARIABLES ORIGINALES Y LAS TRANSFORMADAS CON LOS NOMBRES ORIGINALES Y EL SUBINDICE _G 
	SI HAY GRUPOS CREADOS

	* SI NO SE HACEN AGRUPACIONES POR DIFERENCIAS SIGNIFICATIVAS ENTRE TODOS LOS NIVELES, SALE UN MENSAJE EN LOG
	* SI SE UNEN TODAS LAS CATEGORÍAS (LOS NIVELES SON SIMILARES RESPECTO A LA VARIABLE DEPENDIENTE) SALE UN MENSAJE EN LOG
	
	* EN LA VENTANA OUTPUT SALE EL LISTADO DE LOS GRUPOS CREADOS RELACIONADO CON LA VARIABLE ORIGINAL

*****
NOTAS
*****
		- TRAS EJECUTAR LA MACRO, ES CONVENIENTE:

A) OBSERVAR EN EL LOG LAS VARIABLES CREADAS
B) PROC CONTENTS DEL ARCHIVO ARCHIVOFINAL (Y GUARDARLO EN PERMANENTE SI SE QUIERE)
*/

%macro AgruparCategorias(
archivo=, 		/* Archivo de datos que contiene a las variables Nominales */
vardep=, 		/* Variable Dependiente (Intervalo o Nominal ) */
vardeptipo=, 	/* Tipo de la variable dependiente: I=Intervalo o N=Nominal */
listclass=, 	/* Lista separada por espacios de las variables a agrupar */
criterio=, 		/* Criterio usado para la división de las ramas en el proc arboretum */
directorio=c:		/* directorio de trabajo para archivos de apoyo */
);
%if &criterio eq %then %do;
 %if &vardeptipo=I %then %let criterio=PROBF;
 %if &vardeptipo=N %then %let criterio=PROBCHISQ;
%end;

	/* Solo con la información relevante */
	data archivosa;
		set &archivo (KEEP = &vardep &listclass);
	run;
	data _null_;
		file "&directorio\tempAgrupacionClasesVariableNominal.txt";
		put ' ';
	run;
	/* data temporal;
		retain variable ' ';
	run;
	*/
	data _null_;
		length clase $ 10000 ;
	/* Cuento el número de variables */
	clase="&listclass";
		ncate= 1;
		do while (scanq(clase, ncate) ^= '');
			ncate+1;
		end;
		ncate+(-1);put;
		put // ncate= /;
		call symput('ncate',left(ncate));
	run;
	/* Bucle arboretum */
	%do i=1 %to &ncate;
		%let vari=%qscan(&listclass,&i);
		%if %upcase(&vardeptipo)=I %then %do;
			proc arboretum data=archivosa criterion=&criterio; /* CRITERIO PROBF HACE CONTRASTES TIPO PARES */
				input &vari / level=nominal; 
				target &vardep / level=interval; 
				save model=tree1; 
			run;
		%end;
		%else %do; 
			proc arboretum data=archivosa criterion=&criterio; 
				input &vari / level=nominal; 
				target &vardep / level=nominal; 
				save model=tree1; 
			run;
		%end;
		proc arboretum inmodel=tree1;
			score data=archivosa out=archivosa2 ;
			subtree best;
		run;
		data archivosa;
			set archivosa2;
		run;
		/* comprobar si no se hacen agrupaciones */
		proc freq data=archivosa noprint;
			tables &vari /out=sal1;
		proc freq data=archivosa noprint;
			tables _leaf_ /out=sal2;
		data _null_;
			if _n_=1 then set sal1 nobs=nume1;
			if _n_=1 then set sal2 nobs=nume2;
			if _n_=1 then do;
				if nume1=nume2 then noagrupa=1;
				else noagrupa=0;
				call symput ('noagrupa',left(noagrupa));
			end;
			if noagrupa=1 then do;
				put 'NOAGRUPA  ' "&vari";
				file "&directorio\tempAgrupacionClasesVariableNominal.txt" mod;
				put "&vari";
			end;
			stop;
		run;
		/* comprobar si se unen todas las categorías */
		proc freq data=archivosa noprint;
			tables _leaf_ /out=sal1;
		run;
		data _null_;
			set sal1 nobs=nume;
			call symput ('seunentodas',left(nume));
			if nume=1 then do;
				put 'SE UNEN TODAS   ' "&vari";
				file "&directorio\tempAgrupacionClasesVariableNominal.txt" mod;
				put "&vari";
			end;
		run;
		%if &noagrupa eq 0 and &seunentodas ne 1 %then %do;
			data _null_;koko2=cats("&vari",'_G');call symput('koko',left(koko2));run;
			data archivosa (drop=_node_ );
				set archivosa;
				rename _leaf_=&koko;
			run;
			data _null_;
				file "&directorio\tempAgrupacionClasesVariableNominal.txt" mod;
				h="&koko";h=left(h);
				put h;
			run;
		%end;
		%else %do;
			data archivosa(drop=_leaf_ _node_);
				set archivosa;
			run;
		%end;
	%end;
	data archivofinal (drop=P_&vardep R_&vardep);
		merge &archivo archivosa;
	run;
	data _null_;
		length c $ 300;
		if _n_=1 then put ' '//'LISTA DE GRUPOS CREADOS Y NO CREADOS'//'*******************************************' ;
			infile "&directorio\tempAgrupacionClasesVariableNominal.txt" ;
			input c $;
			put c @@;
	run;
	data _null_;put //'*******************************************' ;run;

/* COMPROBAR GRUPOS CREADOS */

%do i=1 %to &ncate;
	%let vari=%qscan(&listclass,&i);
 	data _null_;retain control 0;length c $ 300;infile "&directorio\tempAgrupacionClasesVariableNominal.txt" ;input c $;
		c3=cats("&vari",'_G');
		if c=c3 then control=1;
		call symput('control',left(control));
		call symput('grupo',left(c3));
	run;
	%if &control=1 %then %do;
	 proc freq data=archivofinal noprint;tables &vari*&grupo /out=sal;run;
	proc sort data=sal;by &grupo;
	proc print data=sal;run;
	%end;
%end;	

%mend;

/* ESTE TRUCO ES IMPORTANTE 
proc contents data=archivofinal out=nombres;
run;

proc sort data=nombres;by type;
data _null_;
set nombres;by type;
if first.type=1 and type=1 then put  'VARIABLES CONTINUAS';
if first.type=1 and type=2 then put // 'VARIABLES CATEGÓRICAS';
put name @@;
run;*/


/*

options mprint nonotes;
%AgruparCategorias(archivo=ames,vardep=saleprice,vardeptipo=I,listclass=
Alley Bldg_Type BsmtFin_Type_1 BsmtFin_Type_2 Bsmt_Cond Bsmt_Exposure Bsmt_Qual Central_Air Condition_1 Condition_2 Electrical Exter_Cond Exter_Qual
Exterior_1st Exterior_2nd Fence Fireplace_Qu Foundation Functional Garage_Cond Garage_Finish Garage_Qual Garage_Type Heating Heating_QC House_Style Kitchen_Qual
Land_Contour Land_Slope Lot_Config Lot_Shape MS_SubClass MS_Zoning Mas_Vnr_Type Misc_Feature Neighborhood PID Paved_Drive Pool_QC Roof_Matl Roof_Style
Sale_Condition Sale_Type Street Utilities,
criterio=,directorio=c:);

*/
