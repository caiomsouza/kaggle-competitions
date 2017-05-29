
%macro repito;
data union;run;
%do nodos=3 %to 30 %by 2;
proc neural data=uno dmdbcat=cataprueba ;
input  Age Height;
input sex smoker /level=nominal;
target  fev;
hidden &nodos;
prelim 2 preiter=3;
train tech=levmar;
score data=uno out=salpredi outfit=salfit;
run;
data salfit;set salfit;nodos=&nodos;if _n_=2 then output;
data union;set union salfit;run;
%end;
data union;set union;if _n_=1 then delete;run;
proc print data=union;run;
%mend;

%repito;

symbol i=join v=circle;
proc gplot data=union;plot _ASE_*nodos;run;

data uno;set uno;u=ranuni(12345);
proc sort data=uno;by u;
data train valida;set uno;if _n_<=500 then output train;else output valida;run;

proc neural data=train dmdbcat=cataprueba validata=valida;
input  Age Height;
input sex smoker /level=nominal;
target  fev;
hidden 15;
nloptions maxiter=10000;
netoptions randist=normal ranscale=0.01 random=12345;
train maxiter=30 tech=levmar outest=cosa estiter=1;
score data=train out=salpredi outfit=salfit;
score data=valida out=salpredival outfit=salfitval;
run;

proc print data=salfit;run;
proc print data=salfitval;run;
proc print data=cosa;var  _AVERR_ _VAVERR_ _iter_; run;

symbol1 i=join v=circle c=blue;
symbol2 i=join v=circle c=red;
proc gplot data=cosa;plot _AVERR_*_iter_=1 _VAVERR_*_iter_=2 /overlay;run;


