
data uno;
do i=1 to 10;
e=ranuni(123)*2;
x=ranuni(123)*5;
y=abs((30-x**2+5*x+e));
y=int(y);
output;
end;
run;
proc print data=uno;run;
proc sort data=uno;by x;run;
symbol i=none v=circle;
proc gplot data=uno;plot y*x;run;

proc means data=uno;var y;output out=salii mean=media;run;
data uno;set uno;if _n_=1 then set salii;resi1=y-media;run;
proc print data=uno noobs;var y ;run;

proc sort data=uno;by resi;
symbol i=none v=circle;
proc gplot data=uno;plot resi1*x;run;

proc arboretum data=uno leafsize=1;
input x;
target resi1;
save model=tree1;
run;
proc arboretum inmodel=tree1;
subtree nleaves=5;
score data=uno out=sal1;
run;
data sal1;set sal1;resi1_est=p_resi1;y1=media+0.250*resi1_est;resi2=y-y1;run;
proc print data=sal1;var y x media resi1 resi1_est y1 resi2;run;

proc arboretum data=sal1 leafsize=1;
input x;
target resi2;
save model=tree1;
run;
proc arboretum inmodel=tree1;
subtree nleaves=5;
score data=sal1 out=sal2;
run;

data sal1;set sal2;resi2_est=p_resi2;y2=y1+0.25*resi2_est;resi3=y-y2;run;
proc print data=sal1;var y x media resi1 y1 resi2 resi2_est y2;run;

proc arboretum data=sal1 leafsize=1;
input x;
target resi3;
save model=tree1;
run;
proc arboretum inmodel=tree1;
subtree nleaves=5;
score data=sal1 out=sal2;
run;

data sal1;set sal2;resi3_est=p_resi3;y3=y2+0.25*resi3_est;resi4=y-y3;run;
proc print data=sal1;var y x media resi1 y1 resi2 resi2_est y2 resi3 resi3_est y3 ;run;


proc arboretum data=sal1 leafsize=1;
input x;
target resi4;
save model=tree1;
run;
proc arboretum inmodel=tree1;
subtree nleaves=5;
score data=sal1 out=sal2;
run;

data sal1;set sal2;resi4_est=p_resi4;y4=y3+0.25*resi4_est;run;
proc print data=sal1 noobs;var y x media resi1 y1 resi2 resi2_est y2 resi3 resi3_est y3 resi4 resi4_est y4 ;run;

proc sort data=sal1;by x;
symbol1 i=none v=dot c=blue h=2;
symbol2 i=none v=dot c=red h=1;
symbol3 i=none v=dot c=green;
symbol4 i=none v=dot c=brown;
symbol5 i=none v=dot c=black;
symbol6 i=none v=dot c=magenta;

title 'iteración 1';
proc gplot data=sal1;plot y*x=1 media*x=2 /overlay;run;
title 'iteración 2';
proc gplot data=sal1;plot y*x=1 media*x=2 y1*x=3 /overlay;run;
title 'iteración 3';
proc gplot data=sal1;plot y*x=1 media*x=2 y1*x=3 y2*x=4 /overlay;run;
title 'iteración 4';
proc gplot data=sal1;plot y*x=1 media*x=2 y1*x=3 y2*x=4 y3*x=5 /overlay;run;
title 'iteración 5';
proc gplot data=sal1;plot y*x=1 media*x=2 y1*x=3 y2*x=4 y3*x=5 y4*x=6 /overlay;run;

