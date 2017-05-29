
/* PARA EL ALGORITMO KNN SE UTILIZA EL PROC DISCRIM (procedimiento de análisis discriminante)
EN SU VERSIÓN NPAR (NO PARAMÉTRICO)

El problema de este procedimiento es que no admite variables categóricas.

Para ello se pasan a dummys con el proc glmmod.

*/

data german;set discoc.germanbien;run;


data germanbis;set german;bad2=bad*1;run;
proc glmmod data=germanbis outdesign=germandummy;
class telephon history other job property ;
model bad2=age amount checking duration employed installp resident savings
telephon history other job property /noint;
run;

/* se observan cuantas columnas se crean: */
proc contents data=germandummy;run;

proc surveyselect data=germandummy out=muestra outall N=800 seed=12345;
strata bad2 / alloc=proportional;run;/* HAGO PARTICIONES ESTRATIFICADAS */

data train valida;set muestra;
if selected=1 then output train;/*AQUÍ PONGO A MISSING LA VAR DEPENDIENTE EN LAS OBSERVACIONES TEST */
else output valida;
run;

proc discrim data=train noprint method=npar k=4 out=saco testdata=valida testout=sal;
class bad2;
var col1-col26;
;run;

proc print data=sal;run;

/* si hay empate los pone a missing */
data sal;set sal;if _into_=. then _into_=0;run;

proc freq data=sal;tables bad2*_into_;run;
