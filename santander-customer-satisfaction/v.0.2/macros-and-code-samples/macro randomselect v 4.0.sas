
/* LA MACRO RANDOMSELECT REALIZA UN MÉTODO STEPWISE 
REPETIDAS VECES CON DIFERENTES ARCHIVOS TRAIN.

LA SALIDA INCLUYE UNA TABLA DE FRECUENCIAS 
DE LOS MODELOS QUE APARECEN SELECCIONADOS EN LOS DIFERENTES 
ARCHIVOS TRAIN

LOS MODELOS QUE SALEN MÁS VECES SON POSIBLES CANDIDATOS A PROBAR 
CON VALIDACIÓN CRUZADA

listclass=lista de variables de clase
vardepen=variable dependiente
modelo=modelo
criterio= criterio del glmselect : AIC, SBC, BIC, SL , etc.
sinicio=semilla inicio
sfinal=semilla final
fracciontrain=fracción de datos train
directorio=directorio de trabajo para archivos de texto de apoyo

EL ARCHIVO QUE CONTIENE LOS EFECTOS SE LLAMA SALEFEC. 
SE INCLUYE EN EL LOG EL LISTADO PARA PODER COPIAR Y PEGAR 
(A VECES LA VENTANA OUTPUT ESTÁ LIMITADA)

*/

%macro randomselect(data=,listclass=,vardepen=,modelo=,criterio=,sinicio=,sfinal=,fracciontrain=,directorio=&directorio); 
options nocenter linesize=256;
proc printto print="&directorio\kk.txt";run;
data _null_;file "&directorio\cosa.txt" linesize=2000;run;
%do semilla=&sinicio %to &sfinal;
proc surveyselect data=&data rate=&fracciontrain out=sal1234 seed=&semilla;run;
ods output   SelectionSummary=modelos;
ods output    SelectedEffects=efectos;
ods output    Glmselect.SelectedModel.FitStatistics=ajuste;
proc glmselect data=sal1234  plots=all seed=&semilla;
  class &listclass; 
  model &vardepen= &modelo/ selection=stepwise(select=&criterio choose=&criterio) details=all stats=all;
run;   
ods graphics off;   
ods html close;   
data union;i=5;set efectos;set ajuste point=i;run;
data _null_;semilla=&semilla;file "&directorio\cosa.txt" mod linesize=2000;set union;put effects ;run;
%end;
proc printto ;run;
data todos;
infile "&directorio\cosa.txt" linesize=2000;
length efecto $ 1000;
input efecto @@;
if efecto ne 'Intercept' then output;
run;
proc freq data=todos;tables efecto /out=sal;run;
proc sort data=sal;by descending count;
proc print data=sal;run;

data todos;
infile "&directorio\cosa.txt" linesize=2000;
length efecto $ 1000;
input efecto $ &&;
run;
proc freq data=todos;tables efecto /out=salefec;run;
proc sort data=salefec;by descending count;
proc print data=salefec;run;
data _null_;set salefec;put efecto;run;
%mend;


/* 
%randomselect(data=ames,listclass=Alley Bldg_Type BsmtFin_Type_1 BsmtFin_Type_2 ,
vardepen=saleprice,modelo=Bedroom_AbvGr BsmtFin_SF_1 BsmtFin_SF_2 Bsmt_Full_Bath Bsmt_Half_Bath Bsmt_Unf_SF Enclosed_Porch Fireplaces Full_Bath Garage_Area Garage_Cars Garage_Yr_Blt
Gr_Liv_Area Half_Bath Kitchen_AbvGr Lot_Area Lot_Frontage Low_Qual_Fin_SF Mas_Vnr_Area Misc_Val Mo_Sold Open_Porch_SF Order Overall_Cond Overall_Qual Pool_Area
Screen_Porch TotRms_AbvGrd Total_Bsmt_SF Wood_Deck_SF Year_Built Year_Remod_Add Yr_Sold _Ssn_Porch _nd_Flr_SF _st_Flr_SF
Alley Bldg_Type BsmtFin_Type_1 BsmtFin_Type_2 ,
criterio=AIC,sinicio=12345,sfinal=12500,fracciontrain=0.70,directorio=c:); 
proc glm data=ames;
class Alley Bldg_Type BsmtFin_Type_1 BsmtFin_Type_2 ;
model saleprice=Bedroom_AbvGr BsmtFin_SF_1 BsmtFin_SF_2 Bsmt_Full_Bath Fireplaces 
Garage_Area Garage_Cars Gr_Liv_Area Kitchen_AbvGr Lot_Area Lot_Frontage Mas_Vnr_Area Misc_Val Open_Porch_SF Overall_Cond Overall_Qual Pool_Area Screen_Porch 
TotRms_AbvGrd Total_Bsmt_SF Wood_Deck_SF Year_Built Year_Remod_Add Bldg_Type BsmtFin_Type_1;
run;
*/
