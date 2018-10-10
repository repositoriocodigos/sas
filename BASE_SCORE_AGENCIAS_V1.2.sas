%LET ESCOB = 'ULTRACENTER';
%LET DTA = '11SEP2014'D;

PROC SQL;/*CRIAR A BASE SCORE*/
    CREATE TABLE WORK.SCORE_ULTRACENTER AS 
        SELECT  DISTINCT


            A.ESCOB,
            A.BILLING,
            A.C_CODI AS CPF,
            A.TIPO,
            B.SCORE


        FROM REPORT.BASE_3 AS A LEFT JOIN REPORT.BASE_SCMD AS B ON A.C_CODI = B.CLIENTE
            WHERE ESCOB = &ESCOB
                AND BASE ='REMESSA'
                AND DATA_ARQUIVO >= &DTA 
                AND BILLING IN('BILLING_02' 'BILLING_03' 'BILLING_05' 'BILLING_10' 'BILLING_13' 'BILLING_15' 'BILLING_17' 'BILLING_20' 'BILLING_25')
            GROUP BY 1,2,3,4,5;
RUN;

PROC SQL;/*CRIAR A BASE MODEM 3G*/
    CREATE TABLE WORK.MODEM_ULTRACENTER AS 
        SELECT  DISTINCT

            A.ESCOB,
            A.C_CODI AS CPF,
            A.TIPO,
            B.PLANO,
            B.TELEFONE


        FROM REPORT.BASE_3 AS A LEFT JOIN REPORT.BASE_SCMD AS B ON A.C_CODI = B.CLIENTE
            WHERE ESCOB = &ESCOB
                AND PLANO IN ("004/INTERNET MODEM P"
                "004/INTERNET MODEM P PROMO"
                "004/POS/SMP - INTERNET MODEM"
                "005/INTERNET MODEM M"
                "005/INTERNET MODEM M PROMO"
                "007/INTERNET MODEM GG"
                "INTERNET MODEM GG -016/PÓS/SMP"
                "INTERNET MODEM TESTE"
                "003/POS/SMP - INTERNET MODEM"
                "INTERN MODEM G PJ 017/PÓS/SMP"
                "INTERN MODEM GG PJ 016/PÓS/SMP"
                "INTERN MODEM M PJ 018/PÓS/SMP"
                "INTERN MODEM P PJ 019/PÓS/SMP"
                "INTERN TABLET PJ 015/PÓS/SMP"
                "INTERNET MODEM FF 005/PÓS/SMP"
                "INTERNET MODEM G - 006/PÓS/SMP"
                "INTERNET MODEM GG -007/PÓS/SMP"
                "INTERNET MODEM M - 005/PÓS/SMP"
                "INTERNET MODEM P - 004/PÓS/SMP"
                "INTERNET TABLET - 008/PÓS/SMP"
                "INTERNET MODEM P PROMO**"
                "INTERNET MODEM P"
                "INTERNET MODEM M PROMO**"
                "INTERNET MODEM M"
                "INTERNET MODEM G PROMO**"
                "INTERNET MODEM G"
                "INTERNET MODEM GG PROMO**"
                "INTERNET MODEM GG"
                "3G MODEM 1 GB"
                "3G + INT MODEM 3GB"
                "3G + INT MODEM 5GB"
                "3G +INT MODEM 8GB"
                "3G + INT MODEM 10GB"
                "4G INT MODEM 3GB"
                "4G INT MODEM 5GB"
                "4G INT MODEM 8GB"
                "4G INT MODEM 10GB")
            GROUP BY 1,2,3,4,5;
RUN;

PROC SQL; /*CRIAR A BASE SCORE E MODEM 3G*/
    CREATE TABLE REPORT.BASE_SCMD AS
        SELECT

            CPF_CGC AS CLIENTE,
            CUSTOMER_COSTCENTER AS CUSTOMER,
            CONTRATO AS CONTRACT,
            TELEFONE_CONTRATO AS TELEFONE,
            PLANO AS PLANO,
            TECHNOLOGY_TYPE AS TECNOLOGIA,
            CREDIT_SCORE_ATUAL AS SCORE  
        FROM ESCOBS.BASE_ATIVA_201407 AS A
            WHERE STATUS_CONTRATO <> 'Desativado';
RUN;

DATA REPORT.BASE_SCMD;
    SET REPORT.BASE_SCMD;
    PLANO = UPCASE(PLANO);

    IF  TECNOLOGIA = 'IDEN' THEN
        TECNOLOGIA = '2G';

    IF SUBSTR(PLANO,1,2) = '4G' THEN             
        TECNOLOGIA = '4G';
RUN;
