data machines;infile cards dlm=',';
input
MCYT   $ MMIN $  MMAX  CACH   CHMIN CHMAX   PRP   ERP;
cards;
adviser,32/60,125,256,6000,256,16,128,198,199
amdahl,470v/7,29,8000,32000,32,8,32,269,253
amdahl,470v/7a,29,8000,32000,32,8,32,220,253
amdahl,470v/7b,29,8000,32000,32,8,32,172,253
amdahl,470v/7c,29,8000,16000,32,8,16,132,132
amdahl,470v/b,26,8000,32000,64,8,32,318,290
amdahl,580-5840,23,16000,32000,64,16,32,367,381
amdahl,580-5850,23,16000,32000,64,16,32,489,381
amdahl,580-5860,23,16000,64000,64,16,32,636,749
amdahl,580-5880,23,32000,64000,128,32,64,1144,1238
apollo,dn320,400,1000,3000,0,1,2,38,23
apollo,dn420,400,512,3500,4,1,6,40,24
basf,7/65,60,2000,8000,65,1,8,92,70
basf,7/68,50,4000,16000,65,1,8,138,117
bti,5000,350,64,64,0,1,4,10,15
bti,8000,200,512,16000,0,4,32,35,64
burroughs,b1955,167,524,2000,8,4,15,19,23
burroughs,b2900,143,512,5000,0,7,32,28,29
burroughs,b2925,143,1000,2000,0,5,16,31,22
burroughs,b4955,110,5000,5000,142,8,64,120,124
burroughs,b5900,143,1500,6300,0,5,32,30,35
burroughs,b5920,143,3100,6200,0,5,20,33,39
burroughs,b6900,143,2300,6200,0,6,64,61,40
burroughs,b6925,110,3100,6200,0,6,64,76,45
c.r.d,68/10-80,320,128,6000,0,1,12,23,28
c.r.d,universe:2203t,320,512,2000,4,1,3,69,21
c.r.d,universe:68,320,256,6000,0,1,6,33,28
c.r.d,universe:68/05,320,256,3000,4,1,3,27,22
c.r.d,universe:68/137,320,512,5000,4,1,5,77,28
c.r.d,universe:68/37,320,256,5000,4,1,6,27,27
cdc,cyber:170/750,25,1310,2620,131,12,24,274,102
cdc,cyber:170/760,25,1310,2620,131,12,24,368,102
cdc,cyber:170/815,50,2620,10480,30,12,24,32,74
cdc,cyber:170/825,50,2620,10480,30,12,24,63,74
cdc,cyber:170/835,56,5240,20970,30,12,24,106,138
cdc,cyber:170/845,64,5240,20970,30,12,24,208,136
cdc,omega:480-i,50,500,2000,8,1,4,20,23
cdc,omega:480-ii,50,1000,4000,8,1,5,29,29
cdc,omega:480-iii,50,2000,8000,8,1,5,71,44
cambex,1636-1,50,1000,4000,8,3,5,26,30
cambex,1636-10,50,1000,8000,8,3,5,36,41
cambex,1641-1,50,2000,16000,8,3,5,40,74
cambex,1641-11,50,2000,16000,8,3,6,52,74
cambex,1651-1,50,2000,16000,8,3,6,60,74
dec,decsys:10:1091,133,1000,12000,9,3,12,72,54
dec,decsys:20:2060,133,1000,8000,9,3,12,72,41
dec,microvax-1,810,512,512,8,1,1,18,18
dec,vax:11/730,810,1000,5000,0,1,1,20,28
dec,vax:11/750,320,512,8000,4,1,5,40,36
dec,vax:11/780,200,512,8000,8,1,8,62,38
dg,eclipse:c/350,700,384,8000,0,1,1,24,34
dg,eclipse:m/600,700,256,2000,0,1,1,24,19
dg,eclipse:mv/10000,140,1000,16000,16,1,3,138,72
dg,eclipse:mv/4000,200,1000,8000,0,1,2,36,36
dg,eclipse:mv/6000,110,1000,4000,16,1,2,26,30
dg,eclipse:mv/8000,110,1000,12000,16,1,2,60,56
dg,eclipse:mv/8000-ii,220,1000,8000,16,1,2,71,42
formation,f4000/100,800,256,8000,0,1,4,12,34
formation,f4000/200,800,256,8000,0,1,4,14,34
formation,f4000/200ap,800,256,8000,0,1,4,20,34
formation,f4000/300,800,256,8000,0,1,4,16,34
formation,f4000/300ap,800,256,8000,0,1,4,22,34
four-phase,2000/260,125,512,1000,0,8,20,36,19
gould,concept:32/8705,75,2000,8000,64,1,38,144,75
gould,concept:32/8750,75,2000,16000,64,1,38,144,113
gould,concept:32/8780,75,2000,16000,128,1,38,259,157
hp,3000/30,90,256,1000,0,3,10,17,18
hp,3000/40,105,256,2000,0,3,10,26,20
hp,3000/44,105,1000,4000,0,3,24,32,28
hp,3000/48,105,2000,4000,8,3,19,32,33
hp,3000/64,75,2000,8000,8,3,24,62,47
hp,3000/88,75,3000,8000,8,3,48,64,54
hp,3000/iii,175,256,2000,0,3,24,22,20
harris,100,300,768,3000,0,6,24,36,23
harris,300,300,768,3000,6,6,24,44,25
harris,500,300,768,12000,6,6,24,50,52
harris,600,300,768,4500,0,1,24,45,27
harris,700,300,384,12000,6,1,24,53,50
harris,80,300,192,768,6,6,24,36,18
harris,800,180,768,12000,6,1,31,84,53
honeywell,dps:6/35,330,1000,3000,0,2,4,16,23
honeywell,dps:6/92,300,1000,4000,8,3,64,38,30
honeywell,dps:6/96,300,1000,16000,8,2,112,38,73
honeywell,dps:7/35,330,1000,2000,0,1,2,16,20
honeywell,dps:7/45,330,1000,4000,0,3,6,22,25
honeywell,dps:7/55,140,2000,4000,0,3,6,29,28
honeywell,dps:7/65,140,2000,4000,0,4,8,40,29
honeywell,dps:8/44,140,2000,4000,8,1,20,35,32
honeywell,dps:8/49,140,2000,32000,32,1,20,134,175
honeywell,dps:8/50,140,2000,8000,32,1,54,66,57
honeywell,dps:8/52,140,2000,32000,32,1,54,141,181
honeywell,dps:8/62,140,2000,32000,32,1,54,189,181
honeywell,dps:8/20,140,2000,4000,8,1,20,22,32
ibm,3033:s,57,4000,16000,1,6,12,132,82
ibm,3033:u,57,4000,24000,64,12,16,237,171
ibm,3081,26,16000,32000,64,16,24,465,361
ibm,3081:d,26,16000,32000,64,8,24,465,350
ibm,3083:b,26,8000,32000,0,8,24,277,220
ibm,3083:e,26,8000,16000,0,8,16,185,113
ibm,370/125-2,480,96,512,0,1,1,6,15
ibm,370/148,203,1000,2000,0,1,5,24,21
ibm,370/158-3,115,512,6000,16,1,6,45,35
ibm,38/3,1100,512,1500,0,1,1,7,18
ibm,38/4,1100,768,2000,0,1,1,13,20
ibm,38/5,600,768,2000,0,1,1,16,20
ibm,38/7,400,2000,4000,0,1,1,32,28
ibm,38/8,400,4000,8000,0,1,1,32,45
ibm,4321,900,1000,1000,0,1,2,11,18
ibm,4331-1,900,512,1000,0,1,2,11,17
ibm,4331-11,900,1000,4000,4,1,2,18,26
ibm,4331-2,900,1000,4000,8,1,2,22,28
ibm,4341,900,2000,4000,0,3,6,37,28
ibm,4341-1,225,2000,4000,8,3,6,40,31
ibm,4341-10,225,2000,4000,8,3,6,34,31
ibm,4341-11,180,2000,8000,8,1,6,50,42
ibm,4341-12,185,2000,16000,16,1,6,76,76
ibm,4341-2,180,2000,16000,16,1,6,66,76
ibm,4341-9,225,1000,4000,2,3,6,24,26
ibm,4361-4,25,2000,12000,8,1,4,49,59
ibm,4361-5,25,2000,12000,16,3,5,66,65
ibm,4381-1,17,4000,16000,8,6,12,100,101
ibm,4381-2,17,4000,16000,32,6,12,133,116
ibm,8130-a,1500,768,1000,0,0,0,12,18
ibm,8130-b,1500,768,2000,0,0,0,18,20
ibm,8140,800,768,2000,0,0,0,20,20
ipl,4436,50,2000,4000,0,3,6,27,30
ipl,4443,50,2000,8000,8,3,6,45,44
ipl,4445,50,2000,8000,8,1,6,56,44
ipl,4446,50,2000,16000,24,1,6,70,82
ipl,4460,50,2000,16000,24,1,6,80,82
ipl,4480,50,8000,16000,48,1,10,136,128
magnuson,m80/30,100,1000,8000,0,2,6,16,37
magnuson,m80/31,100,1000,8000,24,2,6,26,46
magnuson,m80/32,100,1000,8000,24,3,6,32,46
magnuson,m80/42,50,2000,16000,12,3,16,45,80
magnuson,m80/43,50,2000,16000,24,6,16,54,88
magnuson,m80/44,50,2000,16000,24,6,16,65,88
microdata,seq.ms/3200,150,512,4000,0,8,128,30,33
nas,as/3000,115,2000,8000,16,1,3,50,46
nas,as/3000-n,115,2000,4000,2,1,5,40,29
nas,as/5000,92,2000,8000,32,1,6,62,53
nas,as/5000-e,92,2000,8000,32,1,6,60,53
nas,as/5000-n,92,2000,8000,4,1,6,50,41
nas,as/6130,75,4000,16000,16,1,6,66,86
nas,as/6150,60,4000,16000,32,1,6,86,95
nas,as/6620,60,2000,16000,64,5,8,74,107
nas,as/6630,60,4000,16000,64,5,8,93,117
nas,as/6650,50,4000,16000,64,5,10,111,119
nas,as/7000,72,4000,16000,64,8,16,143,120
nas,as/7000-n,72,2000,8000,16,6,8,105,48
nas,as/8040,40,8000,16000,32,8,16,214,126
nas,as/8050,40,8000,32000,64,8,24,277,266
nas,as/8060,35,8000,32000,64,8,24,370,270
nas,as/9000-dpc,38,16000,32000,128,16,32,510,426
nas,as/9000-n,48,4000,24000,32,8,24,214,151
nas,as/9040,38,8000,32000,64,8,24,326,267
nas,as/9060,30,16000,32000,256,16,24,510,603
ncr,v8535:ii,112,1000,1000,0,1,4,8,19
ncr,v8545:ii,84,1000,2000,0,1,6,12,21
ncr,v8555:ii,56,1000,4000,0,1,6,17,26
ncr,v8565:ii,56,2000,6000,0,1,8,21,35
ncr,v8565:ii-e,56,2000,8000,0,1,8,24,41
ncr,v8575:ii,56,4000,8000,0,1,8,34,47
ncr,v8585:ii,56,4000,12000,0,1,8,42,62
ncr,v8595:ii,56,4000,16000,0,1,8,46,78
ncr,v8635,38,4000,8000,32,16,32,51,80
ncr,v8650,38,4000,8000,32,16,32,116,80
ncr,v8655,38,8000,16000,64,4,8,100,142
ncr,v8665,38,8000,24000,160,4,8,140,281
ncr,v8670,38,4000,16000,128,16,32,212,190
nixdorf,8890/30,200,1000,2000,0,1,2,25,21
nixdorf,8890/50,200,1000,4000,0,1,4,30,25
nixdorf,8890/70,200,2000,8000,64,1,5,41,67
perkin-elmer,3205,250,512,4000,0,1,7,25,24
perkin-elmer,3210,250,512,4000,0,4,7,50,24
perkin-elmer,3230,250,1000,16000,1,1,8,50,64
prime,50-2250,160,512,4000,2,1,5,30,25
prime,50-250-ii,160,512,2000,2,3,8,32,20
prime,50-550-ii,160,1000,4000,8,1,14,38,29
prime,50-750-ii,160,1000,8000,16,1,14,60,43
prime,50-850-ii,160,2000,8000,32,1,13,109,53
siemens,7.521,240,512,1000,8,1,3,6,19
siemens,7.531,240,512,2000,8,1,5,11,22
siemens,7.536,105,2000,4000,8,3,8,22,31
siemens,7.541,105,2000,6000,16,6,16,33,41
siemens,7.551,105,2000,8000,16,4,14,58,47
siemens,7.561,52,4000,16000,32,4,12,130,99
siemens,7.865-2,70,4000,12000,8,6,8,75,67
siemens,7.870-2,59,4000,12000,32,6,12,113,81
siemens,7.872-2,59,8000,16000,64,12,24,188,149
siemens,7.875-2,26,8000,24000,32,8,16,173,183
siemens,7.880-2,26,8000,32000,64,12,16,248,275
siemens,7.881-2,26,8000,32000,128,24,32,405,382
sperry,1100/61-h1,116,2000,8000,32,5,28,70,56
sperry,1100/81,50,2000,32000,24,6,26,114,182
sperry,1100/82,50,2000,32000,48,26,52,208,227
sperry,1100/83,50,2000,32000,112,52,104,307,341
sperry,1100/84,50,4000,32000,112,52,104,397,360
sperry,1100/93,30,8000,64000,96,12,176,915,919
sperry,1100/94,30,8000,64000,128,12,176,1150,978
sperry,80/3,180,262,4000,0,1,3,12,24
sperry,80/4,180,512,4000,0,1,3,14,24
sperry,80/5,180,262,4000,0,1,3,18,24
sperry,80/6,180,512,4000,0,1,3,21,24
sperry,80/8,124,1000,8000,0,1,8,42,37
sperry,90/80-model-3,98,1000,8000,32,2,8,46,50
sratus,32,125,2000,8000,0,2,14,52,41
wang,vs-100,480,512,8000,32,0,0,67,47
wang,vs-90,480,1000,4000,0,0,0,45,25
;
proc print;run;
symbol v=circle;
proc gplot data=machines;plot prp*CHMIN prp*CHMAX;run;
symbol v=circle;
proc g3d;scatter chmin*chmax=prp;run;

ods output  SelectedEffects=efectos;
proc glmselect data=machines;
class mcyt;
    model prp=MCYT   MMAX  CACH   CHMIN CHMAX   
   / selection=stepwise(select=AIC choose=AIC);
;
proc print data=efectos;run;
data;set efectos;put effects ;run;

ods output  SelectedEffects=efectos;
proc glmselect data=machines;
class mcyt;
    model prp=MCYT   MMAX  CACH   CHMIN CHMAX   
   / selection=stepwise(select=bIC choose=bIC);
;
proc print data=efectos;run;
data;set efectos;put effects ;run;

%randomselect(data=machines,
listclass=mcyt,
vardepen=prp,
modelo=MCYT   MMAX  CACH   CHMIN CHMAX   ,
criterio=AIC,
sinicio=12345,
sfinal=12400,
fracciontrain=0.8);


/* nos quedamos con
Intercept CHMIN CHMAX
Intercept CACH CHMIN CHMAX
*/
%cruzada(archivo=machines,vardepen=prp,
conti= CHMIN CHMAX,
categor=,
ngrupos=4,sinicio=12345,sfinal=12355);
data final1;set final;modelo=1;
%cruzada(archivo=machines,vardepen=prp,
conti= CACH CHMIN CHMAX,
categor=,
ngrupos=4,sinicio=12345,sfinal=12355);
data final2;set final;modelo=2;
data union;set final1 final2 ;
proc boxplot data=union;plot media*modelo;run;

/* EN ESTE CASO TAMBI�N FUNCIONA BIEN BPROP (!) MEJORANDO LA REGRESI�N
(LEVMAR NO LA MEJORA)
EL EARLY STOPPING PARECE REDUCIR LA VARIABILIDAD DE LA RED
*/
title '3: red con levmar, 4: red con bprop, 5 red con bprop+early';
%cruzadaneural(archivo=MACHINES,vardepen=PRP,
conti= CHMIN CHMAX,
categor=,
ngrupos=4,sinicio=12345,sfinal=12355,ocultos=5,early=,algo=levmar);
data final3;set final;modelo=3;

%cruzadaneural(archivo=MACHINES,vardepen=PRP,
conti= CHMIN CHMAX,
categor=,
ngrupos=4,sinicio=12345,sfinal=12355,ocultos=5,early=,algo=bprop mom=0.2 learn=0.1);
data final4;set final;modelo=4;

%cruzadaneural(archivo=MACHINES,vardepen=PRP,
conti= CHMIN CHMAX,
categor=,
ngrupos=4,sinicio=12345,sfinal=12355,ocultos=5,early=40,algo=bprop mom=0.2 learn=0.1);
data final5;set final;modelo=5;

data union;set final1 final2 final3 final4 final5;
proc boxplot data=union;plot media*modelo;run;

/* se ve mejor que el modelo 5 (bprop+early) parece ir bien, si quitamos la red levmar del gr�fico */

data union;set final1 final2 final4 final5;
proc boxplot data=union;plot media*modelo;run;


/* esto es para early stopping */
%redneuronal(archivo=machines,listclass=,listconti=CHMIN CHMAX,
vardep=prp,porcen=0.80,semilla=476175,ocultos=5,algo=BPROP mom=0.2 learn=0.1,acti=TANH);

