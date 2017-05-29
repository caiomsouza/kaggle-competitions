/* Load the dataset to ucm library */
libname ucm '\\vmware-host\Shared Folders\git\Bitbucket\santander-kaggle\dataset\'; 
run; 


data ucm.santander; set ucm.santander; id=_n_; run;

/* Show the number of missing values */
ods output nlevels=niveles; proc freq data=ucm.santander nlevels; tables _all_/ noprint; run;
proc means data=ucm.santander n nmiss; run;

/*
76020*0.7 = 53.214 rows
70% of the dataset is equal 53.214 rows

data ucm.santander; set ucm.santander; Run; 
data uno;set ucm.santander; u=(ranuni(12355));
proc sort data=uno; by u; 
data train test;
set uno; if _n_<=53214 then output train;else output test;run;


*/

/* para pruebas 

999*0.7 = 699 rows
70% of the dataset is equal 699 rows

*/

data ucm.santander;
set ucm.santander; 
if _n_>=10000 then delete;
run;



data ucm.santander; set ucm.santander; Run; 
data uno;set ucm.santander; u=(ranuni(12355));
proc sort data=uno; by u; 
data train test;
set uno; if _n_<=7000 then output train;
else output test;
run;


proc surveyselect data=uno out=muestra method=srs n=3000 outall seed=12345;
data train valida;set muestra; if selected=1 then output train;else output valida;run;

/*Ensamblo red y logística */

proc printto print='Z:\git\Bitbucket\santander-kaggle\logs\logs.txt';run;
PROC DMDB DATA=train dmdbcat=catatres;
target TARGET;
var VAR2 VAR3 delta_imp_amort_var18_1y3 delta_imp_amort_var34_1y3 delta_imp_aport_var13_1y3
saldo_var8 saldo_var12 saldo_var13 saldo_var14 saldo_var17 saldo_var18 saldo_var20 saldo_var24
saldo_var25 saldo_var26 saldo_var27 saldo_var28 saldo_var29 saldo_var30 saldo_var31 saldo_var32
saldo_var33 saldo_var34 saldo_var37 saldo_var40 saldo_var41 saldo_var42 saldo_var44 saldo_var46
saldo_var13_corto saldo_var13_largo saldo_var13_medio saldo_var2_ult1 var21 var36 var38;
class TARGET;
run;

proc neural data=train dmdbcat=catatres random=9999;
input VAR2 VAR3 delta_imp_amort_var18_1y3 delta_imp_amort_var34_1y3 delta_imp_aport_var13_1y3
saldo_var8 saldo_var12 saldo_var13 saldo_var14 saldo_var17 saldo_var18 saldo_var20 saldo_var24
saldo_var25 saldo_var26 saldo_var27 saldo_var28 saldo_var29 saldo_var30 saldo_var31 saldo_var32
saldo_var33 saldo_var34 saldo_var37 saldo_var40 saldo_var41 saldo_var42 saldo_var44 saldo_var46
saldo_var13_corto saldo_var13_largo saldo_var13_medio saldo_var2_ult1 var21 var36 var38;
input;
target TARGET /level=nominal;
hidden 9 /act=arc;
netoptions randist=normal ranscale=0.15 random=15459;
prelim 15 preiter=10 pretech=levmar;
train maxiter=100 technique=levmar;
score data=valida role=test out=sal1;
run;


proc logistic data=train ;
class;
model TARGET=VAR2 VAR3 delta_imp_amort_var18_1y3 delta_imp_amort_var34_1y3 delta_imp_aport_var13_1y3
saldo_var8 saldo_var12 saldo_var13 saldo_var14 saldo_var17 saldo_var18 saldo_var20 saldo_var24
saldo_var25 saldo_var26 saldo_var27 saldo_var28 saldo_var29 saldo_var30 saldo_var31 saldo_var32
saldo_var33 saldo_var34 saldo_var37 saldo_var40 saldo_var41 saldo_var42 saldo_var44 saldo_var46
saldo_var13_corto saldo_var13_largo saldo_var13_medio saldo_var2_ult1 var21 var36 var38;
score data=valida out=sal2;
run;

data union;merge sal1 sal2;pensemble=(p_TARGET1+p_1)/2;run;

data salfin;set union;
if p_TARGET1>0.5 then prered=1; else prered=0;
if p_1>0.5 then prelog=1; else prelog=0;
if pensemble>0.5 then prensemble=1; else prensemble=0;
run;

proc freq data=salfin;tables prered*TARGET/out=s1;run;
proc freq data=salfin;tables prelog*TARGET/out=s2;run;
proc freq data=salfin;tables prensemble*TARGET/out=s3;run;

data estadisticos1(drop=count percent prered ); 
		retain vp vn fp fn suma 0; 
		set s1 nobs=nume; 
		suma=suma+count; 
		if prered=0 and TARGET=0 then vn=count; 
		if prered=0 and TARGET=1 then fn=count; 
		if prered=1 and TARGET=0 then fp=count; 
		if prered=1 and TARGET=1 then vp=count; 
		if _n_=nume then do; 
		tasafallos=1-(vp+vn)/suma; 
		modelo='RED';
		output; 
		end; 
run; 
data estadisticos2(drop=count percent prered ); 
		retain vp vn fp fn suma 0; 
		set s2 nobs=nume; 
		suma=suma+count; 
		if prelog=0 and TARGET=0 then vn=count; 
		if prelog=0 and TARGET=1 then fn=count; 
		if prelog=1 and TARGET=0 then fp=count; 
		if prelog=1 and TARGET=1 then vp=count; 
		if _n_=nume then do; 
		tasafallos=1-(vp+vn)/suma; 
		modelo='LOG';
		output; 
		end; 
run; 
data estadisticos3(drop=count percent prered ); 
		retain vp vn fp fn suma 0; 
		set s3 nobs=nume; 
		suma=suma+count; 
		if prensemble=0 and TARGET=0 then vn=count; 
		if prensemble=0 and TARGET=1 then fn=count; 
		if prensemble=1 and TARGET=0 then fp=count; 
		if prensemble=1 and TARGET=1 then vp=count; 
		if _n_=nume then do; 
		tasafallos=1-(vp+vn)/suma; 
		modelo='ENSEMBLE';
		output; 
		end; 
run; 

data u;set estadisticos1 estadisticos2 estadisticos3;run;
title 'ENSEMBLE RED-LOG';
proc print data=u;run;

