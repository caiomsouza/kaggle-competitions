

proc contents data=uno out=sal;run;
data;set sal;put name @@;run;



libname discoc 'c:\';
data uno;set discoc.fev;run;

PROC DMDB DATA=uno dmdbcat=cataprueba;
target FEV;
var Age FEV Height;
class sex smoker;
run;

proc neural data=uno dmdbcat=cataprueba;
input  Age Height;
input sex smoker /level=nominal;
target  fev;
hidden 3 /id=K;
hidden 4 /id=H;
prelim 3;
train tech=levmar;
score data=uno out=salpredi outfit=salfit ;
run;
proc print data=salpredi;run;
proc print data=salfit;run;
proc print data=esti;run;
