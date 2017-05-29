PROC IMPORT OUT= UCM.santander 
            DATAFILE= "\\vmware-host\Shared Folders\git\Bitbucket\santan
der-kaggle\dataset\train.csv" 
            DBMS=CSV REPLACE;
     GETNAMES=YES;
     DATAROW=2; 
RUN;
