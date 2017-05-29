
/*
http://www.sasanalysis.com/2013/11/kernel-selection-in-proc-svm.html*/

/*

KERNELS POSIBLES: 

ERBF, FOURIER, LINEAR, POLYNOM, RBF, RBFREC, SIGMOID and TANH */


/*
				ABSFCONV, ABSGCONV, ABSXCONV, C,
              CGITER, CGTOL, CV, DATA, DMDBCAT, EPS, EPSILON, FCONV, FOLD, GCONV, INEST,
              KERNEL, KMATTEST, K_PAR, K_PAR2, MAXFUNC, MAXITER, MEMSIZ, METHOD, MONITOR,
              NOLIS, NOMISS, NOMONITOR, NOPRINT, NOSCALE, NOSHRINK, NU, NVARMIN, OUT, OUTCLASS,
              OUTEST, OUTFIT, OUTITER, OUTKERN, OUTL, PALL, PINITIAL, PKERNEL, PMATRIX,
              POPTHIS, PPARM, PPLAN, PPRED, QPSIZE, RANDOM, RIDGE, SAMPSIZE, SEED, SINGULAR,
              START, TASK, TESTDATA, TESTOUT, TUN, TUNFTOL, TUNITR, TUNSEL, TUNXTOL, VARDROP,
              VERS, VERSION, XCONV, XSCALE. 


BLOCK, LOO, RANDOM, SPLIT,TESTSET.


*/


/* EJEMPLO SIMPLE */

data german;set discoc.germanbien;run;

/* DIVISION TRAINING VALIDA 

*/

%let porcen=0.80;
%let semilla=12345;
%let vardep=bad;

data german;
set german nobs=nume;ene=int(&porcen*nume);
call symput('ene',left(ene));
run;

proc sort data=german;by &vardep;run;

proc surveyselect data=german out=muestra outall N=&ene seed=&semilla;
strata &vardep / alloc=proportional;run;/* HAGO PARTICIONES ESTRATIFICADAS */

data train;set muestra;
if selected=1 then vardepen=&vardep;/*AQUÍ PONGO A MISSING LA VAR DEPENDIENTE EN LAS OBSERVACIONES TEST */
else vardepen=.;
run;

PROC DMDB DATA=train dmdbcat=cataprueba out=train2;
target &vardep;
var amount checking coapp duration employed history savings ;
class &vardep;
run;

proc svm data=train2 dmdbcat=cataprueba testdata=valida kernel=polynom k_par=4 seed=12345 out=sal testout=sal2;
ods output restab=linear;
    var amount checking coapp duration employed history savings ;
   target &vardep;
run;
proc freq data=sal2;tables _I_*bad;run;
data sal2;set sal2;pdepen=_i_;run;
proc freq data=sal2;tables pdepen*bad /out=sal3;run;
data estadisticos (drop=count percent pdepen bad); 
retain vp vn fp fn suma 0; 
set sal3 nobs=nume; 
suma=suma+count; 
if pdepen=0 and bad=0 then vn=count; put vn=;
if pdepen=0 and bad=1 then fn=count; 
if pdepen=1 and bad=0 then fp=count; 
if pdepen=1 and bad=1 then vp=count; 
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
proc print data=estadisticos;run;


/* EJEMPLO VALIDACIÓN CRUZADA */

PROC DMDB DATA=german dmdbcat=cataprueba out=german2;
target bad;
var amount checking coapp duration employed history savings ;
class bad;
run;

proc svm data=german2 dmdbcat=cataprueba kernel=linear c=50 cv=split fold=4 seed=12345 out=sal;
ods output restab=linear;
    var amount checking coapp duration employed history savings ;
   target bad;
run;
proc print data=linear;run;


/* EJEMPLO KERNEL RBF */

proc svm data=german2 dmdbcat=cataprueba kernel=RBF K_PAR=1 c=1 cv=loo;
ods output restab=RBF;
    var amount checking coapp duration employed history savings ;
   target bad;
run;
proc print data=RBF;run;

