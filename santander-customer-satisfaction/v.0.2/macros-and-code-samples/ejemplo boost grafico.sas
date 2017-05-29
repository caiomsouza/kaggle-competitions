
data uno;
do i=1 to 10;
e=ranuni(123)*2;
x=ranuni(123)*5;
y=abs((30-x**2+5*x+e));
output;
end;
run;
symbol i=none;
proc gplot data=uno;plot y*x;run;

/* EJEMPLO PARÁMETRO SHRINK, ITERACIONES

* EL PARÁMETRO DE REGULARIZACIÓN SHRINK (v va de 0 a 1) VARÍA LAS PREDICCIONES PARA LAS OBSERVACIONES DE UNA ITERACIÓN 
A OTRA: 

	v pequeño (0.01) = variaciones pequeñas de una iteración a otra
	v grande  (0.50) = variaciones grandes de una iteración a otra

* EL NÚMERO DE ITERACIONES VA AJUSTANDO EL MODELO A LOS DATOS.

	1* v pequeño , número de iteraciones pequeño---> poco ajuste
	2* v grande, número de iteraciones grande---> mal ajuste, a veces sobreajuste (varianza alta)
	3* v pequeño, número de iteraciones grande---> lo recomendable, pero a veces hay que controlar el sobreajuste

Dependiendo de los datos, puede ser necesario 1 o 3. También depende de otros parámetros del modelo:

maxbranch=número máximo de ramas en que se puede abrir un nodo. 2 está bien en general.
leafsize=número de observaciones mínimo para abrir una rama (importante para evitar sobreajuste)
maxdepth=número de niveles del árbol

*/

%macro varios(shrink=0.50);
proc means data=uno;var y;output out=sal1 mean=mediay;run;
data uni;set uno;if _n_=1 then set sal1;P_y=mediay;itera=0;run;
%do iterations=1 %to 5;
proc treeboost data=uno shrinkage=&shrink maxbranch=2 maxdepth=4 iterations=&iterations leafsize=1;
	input x/level=interval;
	target y /level=interval;
	save fit=iter importance=impor model=modelo1;
	score data=uno out=sal;
run;
data sal;set sal;itera=&iterations;run;
data uni;set uni sal;run;
%end;
data uni;set uni;resi=y-p_y;keep itera y P_y resi x;
proc print data=uni;run;

data real;set uno;p_y=y;itera=6;keep itera P_y x;run;
data uni;set uni real;

data unifin;
array ygorro{7};
set uni;
do i=0 to 6;
if itera=i then ygorro{i+1}=p_y;
end;
run;

title "SHRINKAGE=&shrink " ;

proc sort data=unifin;by itera x;
symbol7 c=red v=dot i=none h=1.5;
symbol1 c=green v=circle i=join h=0.5;
symbol2 c=blue v=circle i=join h=0.5;
symbol3 c=magenta v=circle i=join h=0.5;
symbol4 c=brown v=circle i=join h=0.5;
symbol5 c=black v=circle i=join h=0.5;
symbol6 c=orange v=circle i=join h=0.5;
proc gplot data=unifin;
plot 
ygorro1*x=1
ygorro2*x=2
ygorro3*x=3
ygorro4*x=4
ygorro5*x=5
ygorro6*x=6
ygorro7*x=7
/overlay;run;
%mend;

%varios(shrink=0.05);
%varios(shrink=0.20);
%varios(shrink=0.50);
%varios(shrink=0.75);
%varios(shrink=0.90);
%varios(shrink=0.95);


/* EJEMPLO CON 100 ITERACIONES */

proc means data=uno;var y;output out=sal1 mean=mediay;run;
data uni;set uno;if _n_=1 then set sal1;P_y=mediay;itera=0;run;
proc treeboost data=uno shrinkage=0.05 maxbranch=2 maxdepth=4 iterations=100 leafsize=1;
	input x/level=interval;
	target y /level=interval;
	save fit=iter importance=impor model=modelo1;
	score data=uno out=sal;
run;
data sal;set sal;itera=100;run;
data uni;set uni sal;run;
%end;
data uni;set uni;resi=y-p_y;keep itera y P_y resi x;
proc print data=uni;run;
data real;set uno;p_y=y;itera=6;keep itera P_y x;run;
data uni;set uni real;

data unifin;
set uni;
if itera=0 then ygorro1=p_y;
if itera=6 then ygorro7=p_y;
if itera=100 then ygorro2=p_y;
run;

title "SHRINKAGE=0.05, 100 iteraciones " ;

proc sort data=unifin;by itera x;
symbol7 c=red v=dot i=none h=1.5;
symbol1 c=green v=circle i=join h=0.5;
symbol2 c=blue v=circle i=join h=0.5;
symbol3 c=magenta v=circle i=join h=0.5;
symbol4 c=brown v=circle i=join h=0.5;
symbol5 c=black v=circle i=join h=0.5;
symbol6 c=orange v=circle i=join h=0.5;
proc gplot data=unifin;
plot 
ygorro1*x=1
ygorro2*x=2
ygorro7*x=7
/overlay;run;
proc print data=unifin;run;
