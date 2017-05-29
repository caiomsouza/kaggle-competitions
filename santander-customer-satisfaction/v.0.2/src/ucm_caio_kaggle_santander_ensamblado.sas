/* Load the dataset to ucm library */
libname ucm '\\vmware-host\Shared Folders\git\Bitbucket\santander-kaggle\dataset\'; 
run; 

PROC IMPORT OUT= UCM.ensamblado
            DATAFILE= "\\vmware-host\Shared Folders\git\Bitbucket\santan
der-kaggle\dataset\train.csv" 
            DBMS=CSV REPLACE;
     GETNAMES=YES;
     DATAROW=2; 
RUN;



data UCM.ensamblado; set UCM.ensamblado; id=_n_; run;

/* Show the number of missing values */
ods output nlevels=niveles; proc freq data=ucm.ensamblado nlevels; tables _all_/ noprint; run;
proc means data=ucm.ensamblado n nmiss; run;

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


data ucm.ensamblado;
set ucm.ensamblado (drop = ID);
run;


data ucm.ensamblado;
set ucm.ensamblado (drop = ind_var29_0
ind_var29
ind_var13_medio
ind_var18
ind_var26
ind_var25
ind_var32
ind_var34
ind_var37
ind_var39
num_var29_0
num_var29
num_var13_medio
num_var18
num_var26
num_var25
num_var32
num_var34
num_var37
num_var39
saldo_var29
saldo_medio_var13_medio_ult1
delta_num_reemb_var13_1y3
delta_num_reemb_var17_1y3
delta_num_reemb_var33_1y3
delta_num_trasp_var17_in_1y3
delta_num_trasp_var17_out_1y3
delta_num_trasp_var33_in_1y3
delta_num_trasp_var33_out_1y3 
ind_var2_0
ind_var2
ind_var27_0
ind_var28_0
ind_var28
ind_var27
ind_var41
ind_var46_0
ind_var46
num_var27_0
num_var28_0
num_var28
num_var27
num_var41
num_var46_0
num_var46
saldo_var28
saldo_var27
saldo_var41
saldo_var46
imp_amort_var18_hace3
imp_amort_var34_hace3
imp_reemb_var13_hace3
imp_reemb_var33_hace3
imp_trasp_var17_out_hace3
imp_trasp_var33_out_hace3
num_var2_0_ult1
num_var2_ult1
num_reemb_var13_hace3
num_reemb_var33_hace3
num_trasp_var17_out_hace3
num_trasp_var33_out_hace3
saldo_var2_ult1
saldo_medio_var13_medio_hace3);
run;


data ucm.ensamblado;
set ucm.ensamblado; 
if _n_>=10000 then delete;
run;

/* Describe the dataset variables */
proc contents data=ucm.santander out=sal;
data; set sal; put name @@; run;



data ucm.ensamblado; set ucm.ensamblado; Run; 
data uno;set ucm.ensamblado; u=(ranuni(12355));
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
var VAR3
ind_var13
ind_var24
ind_var30
ind_var30_0
ind_var31_0
num_meses_var5_ult3
num_meses_var8_ult3
num_reemb_var17_ult1
num_var22_ult1
num_var22_ult3
saldo_var24
saldo_var42
var38
saldo_var30
saldo_var5
saldo_medio_var5_ult1
saldo_medio_var5_hace2
num_var30
num_var35
num_var4
ind_var5
num_var5
num_var42
var36
saldo_medio_var5_hace3
imp_op_var39_efect_ult1
num_var45_hace3
imp_op_var39_efect_ult3
saldo_medio_var8_ult1;
class TARGET;
run;

proc neural data=train dmdbcat=catatres random=9999;
input VAR3
ind_var13
ind_var24
ind_var30
ind_var30_0
ind_var31_0
num_meses_var5_ult3
num_meses_var8_ult3
num_reemb_var17_ult1
num_var22_ult1
num_var22_ult3
saldo_var24
saldo_var42
var38
saldo_var30
saldo_var5
saldo_medio_var5_ult1
saldo_medio_var5_hace2
num_var30
num_var35
num_var4
ind_var5
num_var5
num_var42
var36
saldo_medio_var5_hace3
imp_op_var39_efect_ult1
num_var45_hace3
imp_op_var39_efect_ult3
saldo_medio_var8_ult1;
input;
target TARGET /level=nominal;
hidden 9 /act=arc;
netoptions randist=normal ranscale=0.15 random=15459;
prelim 15 preiter=10 pretech=levmar;
train maxiter=100 technique=levmar;
score data=valida role=test out=sal1;
run;


proc logistic data=train ;
class ;
model TARGET=VAR3
ind_var13
ind_var24
ind_var30
ind_var30_0
ind_var31_0
num_meses_var5_ult3
num_meses_var8_ult3
num_reemb_var17_ult1
num_var22_ult1
num_var22_ult3
saldo_var24
saldo_var42
var38
saldo_var30
saldo_var5
saldo_medio_var5_ult1
saldo_medio_var5_hace2
num_var30
num_var35
num_var4
ind_var5
num_var5
num_var42
var36
saldo_medio_var5_hace3
imp_op_var39_efect_ult1
num_var45_hace3
imp_op_var39_efect_ult3
saldo_medio_var8_ult1;
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
ods graphics off;

proc print data=u;run;

