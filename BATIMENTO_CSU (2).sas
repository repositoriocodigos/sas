
PROC SQL;
    CREATE TABLE BD_1 AS
        SELECT

            C_CODI AS CPF,
            PRIOR,
            ESCOB,
            DAT_PRIOR,
            BILLING,
            COMPRESS(C_CODI||"/"||C_CENTRO_CUSTO||"/"||TITULO) AS CHAVE_REMESSA,
            COMPRESS(C_CODI||"/"||C_CENTRO_CUSTO) AS CHAVE_CPF_R
        FROM REPORT.BASE_3 AS A 
            WHERE ESCOB = 'CSU'
                AND  PRIOR IN ('DP' 'OT');
RUN;

PROC SORT 
    DATA= WORK.BD_1;
    BY  CPF  PRIOR;
RUN;

DATA BD_2;
    SET 

        ESCOBS.FOLLPAG_201408
        ESCOBS.FOLLPAG_201409;
RUN;

DATA WORK.BD_2;
    SET WORK.BD_2;
    NOTAFISCAL = COMPRESS(TRANWRD(NF,'-',''));
RUN;

PROC SQL;
    CREATE TABLE BD_3 AS
        SELECT

            CNPJ AS CPF,
            'CENTRO DE CUSTO'N AS CENTRO,
            'DT.GL'N AS DT_BAIXA,
            'VL.BAIXA'N AS BAIXA,
            NOTAFISCAL
        FROM WORK.BD_2 AS A;
RUN;

DATA BD_3;
    SET BD_3;
    FORMAT DATE_PG DDMMYY10.;
    MES = SUBSTR(DT_BAIXA,4,3);
    DIA = SUBSTR(DT_BAIXA,1,3);
    ANO = SUBSTR(DT_BAIXA,7,3);

    IF MES = 'FEV' THEN
        MES = 'FEB';

    IF MES = 'ABR' THEN
        MES = 'APR';

    IF MES = 'MAI' THEN
        MES = 'MAY';

    IF MES = 'AGO' THEN
        MES = 'AUG';

    IF MES = 'SET' THEN
        MES = 'SEP';

    IF MES = 'OUT' THEN
        MES = 'OCT';

    IF MES = 'DEZ' THEN
        MES = 'DEC';
    DT_FINAL = COMPRESS(DIA||MES||ANO);
    DATE_PG = MDY(MONTH(INPUT(COMPRESS('01'||SUBSTR(DT_FINAL,4,3)||'01'),DATE7.)),SUBSTR(DT_FINAL,1,2),SUBSTR(DT_FINAL,8,2));
    DROP MES;
    DROP DIA;
    DROP ANO;
    DROP DT_FINAL;
    DROP DT_BAIXA;
RUN;

PROC SQL;
    CREATE TABLE BD_4 AS
        SELECT

            CPF,
            DATE_PG,
            NOTAFISCAL,
            BAIXA,
            COMPRESS(CPF||"/"||CENTRO||"/"||NOTAFISCAL) AS CHAVE_FOLLPAG,
            COMPRESS(CPF||"/"||CENTRO) AS CHAVE_CPF_P
        FROM BD_3 AS A;
RUN;

PROC SORT 
    DATA= BD_4;
    BY  DATE_PG CHAVE_FOLLPAG;
RUN;

PROC SQL;
    CREATE TABLE FOLL_FINAL AS 
        SELECT 

            B.DATE_PG, 
            B.BAIXA, 
            B.CHAVE_FOLLPAG,
            A.ESCOB,
            A.CHAVE_REMESSA,
            A.BILLING,
            A.DAT_PRIOR
        FROM WORK.BD_1 AS A LEFT JOIN WORK.BD_4 AS B ON A.CHAVE_REMESSA = B.CHAVE_FOLLPAG
            ORDER BY DAT_PRIOR DESC;
RUN;

PROC SQL;
    CREATE TABLE BASE_SUSP AS 
        SELECT 

            *


        FROM  FOLL_FINAL AS A
            WHERE DATE_PG = .;
RUN;

PROC SQL;
    CREATE TABLE BASE_PG AS 
        SELECT 

            *


        FROM  FOLL_FINAL AS A
            WHERE DATE_PG <> .;
RUN;

DATA  BASE_PG;
    SET BASE_PG;
    FORMAT STATUS $15.;

    IF  DAT_PRIOR <  DATE_PG THEN
        STATUS = 'OK';
    ELSE STATUS = 'VERIFICAR';
RUN;

