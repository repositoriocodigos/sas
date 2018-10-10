PROC SQL;/*GERA A BASE FINAL*/
    CREATE TABLE REPORT.NOTBX AS 
        SELECT

        COMPRESS(C_CODI||"/"||C_CENTRO_CUSTO) AS CHAVE ,
        ESCOB,
        TIPO,
        DAT_PRIOR,
        PRIOR,
        C_CENTRO_CUSTO,
        TITULO,
        SUM(VALOR) AS VALUE
         

    FROM REPORT.BASE_3 AS A
    WHERE PRIOR = "DP"
    /*AND DAT_PRIOR BETWEEN '19SEP2014'D AND '30SEP2014'D*/
    AND BASE IN ('REMESSA' 'REMESSA COMP')
    AND DAT_PRIOR >= '19SEP2014'D

    GROUP BY 1,2,3,4,5,6,7;        

RUN;
PROC SQL;
    CREATE TABLE REPORT.FOLLPAG AS
        SELECT

            CNPJ AS CPF,
            'CENTRO DE CUSTO'N AS CENTRO,
            'DT.GL'N AS DT_BAIXA,
            'NF'N AS TITULO,
            'VL.BAIXA'N AS BAIXA

        FROM ESCOBS.FOLLPAG_201409 AS A;
RUN;

PROC SQL;
    CREATE TABLE REPORT.FINAL_FOLLPAG AS
        SELECT

            COMPRESS(CPF||"/"||CENTRO) AS CHAVE,
            DT_BAIXA,
            TITULO,
            BAIXA

        FROM REPORT.FOLLPAG AS A;
RUN;

PROC SQL;
    CREATE TABLE FOLL_FINAL AS 
        SELECT 

            B.DT_BAIXA, 
            B.TITULO, 
            B.BAIXA, 
            B.CHAVE AS CHAVE_FOLL,
            A.ESCOB,
            A.CHAVE AS CHAVE_REM
        FROM REPORT.NOTBX AS A LEFT JOIN REPORT.FINAL_FOLLPAG AS B ON A.CHAVE = B.CHAVE
            WHERE CHAVE_FOLL IS NOOT NULL
                ORDER BY CHAVE_FOLL DESC;
RUN;


DATA REPORT.FOLLPGTO;
    SET REPORT.FOLLPAG;
    FORMAT NEW_DATE DDMMYY10.; 
    NEW_DATE = MDY(MONTH(INPUT(COMPRESS('01'||SUBSTR(DT_BAIXA,4,3)||'01'),DATE7.)),SUBSTR(DT_BAIXA,1,2),SUBSTR(DT_BAIXA,8,2));
   
RUN;
DATA TESTE;
SET REPORT.FOLLPAG;

IF DT_BAIXA IN( "01-AGO-14" "02-AGO-14" "03-AGO-14" "04-AGO-14" "05-AGO-14" "06-AGO-14" "07-AGO-14" "08-AGO-14" "09-AGO-14" 
"10-AGO-14" "11-AGO-14" "12-AGO-14" "13-AGO-14" "14-AGO-14" "15-AGO-14" "16-AGO-14" "17-AGO-14" "18-AGO-14" "19-AGO-14" 
"20-AGO-14" "21-AGO-14" "22-AGO-14" "23-AGO-14" "24-AGO-14" "25-AGO-14" "26-AGO-14" "27-AGO-14" "28-AGO-14" "29-AGO-14" 
"30-AGO-14" "01-SET-14" "02-SET-14" "03-SET-14" "04-SET-14" "05-SET-14" "06-SET-14" "07-SET-14" "08-SET-14" "09-SET-14" 
"10-SET-14" "11-SET-14" "12-SET-14" "13-SET-14" "14-SET-14" "15-SET-14" "16-SET-14" "17-SET-14" "18-SET-14" "19-SET-14" 
"20-SET-14" "21-SET-14" "22-SET-14" "23-SET-14" "24-SET-14" "25-SET-14" "26-SET-14" "27-SET-14" "28-SET-14" "29-SET-14" 
"30-SET-14" ) 

THEN DT_BAIXA IN( "01-AUG-14" "02-AUG-14" "03-AUG-14" "04-AUG-14" "05-AUG-14" "06-AUG-14" "07-AUG-14" 
"08-AUG-14" "09-AUG-14" "10-AUG-14" "11-AUG-14" "12-AUG-14" "13-AUG-14" "14-AUG-14" "15-AUG-14" "16-AUG-14" "17-AUG-14" 
"18-AUG-14" "19-AUG-14" "20-AUG-14" "21-AUG-14" "22-AUG-14" "23-AUG-14" "24-AUG-14" "25-AUG-14" "26-AUG-14" "27-AUG-14" 
"28-AUG-14" "29-AUG-14" "30-AUG-14" "01-SEP-14" "02-SEP-14" "03-SEP-14" "04-SEP-14" "05-SEP-14" "06-SEP-14" "07-SEP-14" 
"08-SEP-14" "09-SEP-14" "10-SEP-14" "11-SEP-14" "12-SEP-14" "13-SEP-14" "14-SEP-14" "15-SEP-14" "16-SEP-14" "17-SEP-14" 
"18-SEP-14" "19-SEP-14" "20-SEP-14" "21-SEP-14" "22-SEP-14" "23-SEP-14" "24-SEP-14" "25-SEP-14" "26-SEP-14" "27-SEP-14" 
"28-SEP-14" "29-SEP-14" "30-SEP-14") ;


RUN;









