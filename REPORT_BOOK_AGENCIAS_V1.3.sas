﻿/*****************************************************************************
 ******************************************************************************
 ***********                                                     **************
 ********         GERACAO DA BASE FINAL - REPORT AGENCIAS           ***********
 ***********                                                      *************
 ******************************************************************************
 ******************************************************************************/
DATA REPORT.REMESSA;/* 1.1 CAPTURANDO INFO DE REMESSA */
    SET

		ESCOBS.BDESCOB_201412
        ESCOBS.BDESCOB_201501;
    WHERE BASE IN ('REMESSA COMP' 'REMESSA' 'REMESSA UI');
RUN;

DATA REPORT.BAIXA;/* 1.2 CAPTURANDO INFO DE BAIXA */
    SET      
		ESCOBS.BDESCOB_201412
        ESCOBS.BDESCOB_201501;
    WHERE BASE IN ('BAIXA');
RUN;

DATA REPORT.PC;/* 1.3 CAPTURANDO INFO DE BAIXA */
    SET 
		ESCOBS.BDPRESTACAO_201412
        ESCOBS.BDPRESTACAO_201501;
    WHERE P_DLETRA <> '';
RUN;

PROC SORT DATA = REPORT.REMESSA;/* ORDENANDO BASE */
    BY C_ID_EMP DATA_ARQUIVO;
RUN;

PROC SORT DATA= REPORT.REMESSA NODUPKEY;/* VERIFICANDO DUPLICIDADE*/
    BY C_ID_EMP;
RUN;

PROC SORT DATA= REPORT.BAIXA;/*ORDENANDO BASE*/
    BY C_ID_EMP C_MOTIVO_BXA DATA_ARQUIVO;
RUN;

PROC SORT DATA= REPORT.BAIXA NODUPKEY;/*VERIFICANDO DUPLICIDADE*/
    BY C_ID_EMP C_MOTIVO_BXA;
RUN;

PROC SORT DATA= REPORT.PC;/* ORDENANDO BASE*/
    BY P_ID_EMP DATA_ARQUIVO;
RUN;

PROC SORT DATA= REPORT.PC NODUPKEY;/* VERIFICANDO DUPLICIDADE*/
    BY P_ID_EMP;
RUN;

PROC TRANSPOSE /* TRANSPOR DE LINHA PARA COLUNA*/

    DATA     = REPORT.BAIXA                     /* LIB.NOME_BASE - LEITURA */
    OUT      = REPORT.BAIXA_1( DROP= _NAME_)
        PREFIX = BAIXA_;                        /* LIB.NOME_TABELA - CRIAR */
    BY        C_ID_EMP;                         /* VARIAVEIS QUE SERAO MANTIDAS NA LINHA */
    ID        C_MOTIVO_BXA;                     /* VARIAVEL A SER COLUNADA */
    VAR        DATA_ARQUIVO;                    /* VARIAVEL CARREGADA NOS VALORES DAS COLUNAS TABULADAS */
RUN;

PROC SQL;/* CRUZANDO INFO PART_1*/
    CREATE TABLE REPORT.BASE_1 AS SELECT
        *
    FROM REPORT.REMESSA A LEFT JOIN  REPORT.BAIXA_1 B ON A.C_ID_EMP = B.C_ID_EMP;
RUN;

PROC SQL;/* CRUZANDO INFO PART_2*/
    CREATE TABLE REPORT.BASE_2 AS SELECT
        A.*,
        B.DATA_ARQUIVO AS DATE_PC
    FROM REPORT.BASE_1 A LEFT JOIN  REPORT.PC B ON A.C_ID_EMP = B.P_ID_EMP;
RUN;

DATA REPORT.BASE_3;/* FORMATACAO E PRIORIZACAO*/
    SET  REPORT.BASE_2;
    FORMAT DAT_PRIOR DATA_ARQUIVO DDMMYY10.;

    IF DATE_PC <> . THEN
        DAT_PRIOR = DATE_PC;
    ELSE IF BAIXA_PG <> . THEN
        DAT_PRIOR = BAIXA_PG;
    ELSE IF BAIXA_OT <> . THEN
        DAT_PRIOR = BAIXA_OT;
    ELSE IF BAIXA_DP <> . THEN
        DAT_PRIOR = BAIXA_DP;

    IF DATE_PC <> . THEN
        PRIOR = 'PC       ';
    ELSE IF BAIXA_PG <> . THEN
        PRIOR = 'PG';
    ELSE IF BAIXA_OT <> . THEN
        PRIOR = 'OT';
    ELSE IF BAIXA_DP <> . THEN
        PRIOR = 'DP';
    DATE_NEW = COMPRESS(YEAR(DATA_ARQUIVO)*10000+ MONTH(DATA_ARQUIVO)*100+ DAY(DATA_ARQUIVO));
    VALOR = C_VPAR*1;
RUN;

DATA REPORT.BASE_6;
    SET REPORT.BASE_3;
    FORMAT MOTIVO_BAIXA $4.;
    FORMAT SAFRA_BASE $10.;
    FORMAT SAFRA_ARQ $6.;
    FORMAT SAFRA_PGTO $6.;

    IF PRIOR = "PG" THEN
        MOTIVO_BAIXA = "PGTO";
    ELSE IF PRIOR = "PC" THEN
        MOTIVO_BAIXA = "PGTO";
    ELSE IF PRIOR = "OT" THEN
        MOTIVO_BAIXA = "OT";
    ELSE IF PRIOR = "DP" THEN
        MOTIVO_BAIXA = "DP";
    ELSE IF PRIOR = "" THEN
        MOTIVO_BAIXA = "NULL";
    SAFRA_ARQ = YEAR(DATA_ARQUIVO)*100 + MONTH(DATA_ARQUIVO);
    SAFRA_PGTO = YEAR(DAT_PRIOR)*100 + MONTH(DAT_PRIOR);

    IF  BASE = "REMESSA UI" THEN
        SAFRA_BASE = "REMESSA UI";
    ELSE IF BASE = "REMESSA" THEN
        SAFRA_BASE = "REMESSA";
    ELSE IF BASE = "REMESSA COMP" THEN
        SAFRA_BASE = "REMESSA";
RUN;

PROC SQL;/*GERA A BASE FINAL*/
    CREATE TABLE REPORT.BASE_ESCOBS AS 
        SELECT

            A.DATE_NEW AS DATE_ARQ,
            A.PRIOR AS STATUS,
            A.TIPO,
            A.BASE,
            A.ESCOB,
            COUNT(A.ESCOB)AS QUANT_TITULO,
            SUM(A.VALOR) AS REC FORMAT COMMAX9.2,
            A.DAT_PRIOR,
            A.DATA_ARQUIVO,
            SAFRA_ARQ,
            SAFRA_PGTO,
            SAFRA_BASE,
            MOTIVO_BAIXA,
            SUBSTR(C_NUMT,7,2)AS ESPECIE FORMAT $3.
        FROM REPORT.BASE_6 AS A

        GROUP BY 1,2,3,4,5,8,9,10,11,12,13,14;
RUN;

PROC EXPORT DATA= REPORT.BASE_ESCOBS /*EXPORT DA BASE FINAL PARA CARREGAR O REPORT DAS AGENCIAS*/
    OUTFILE= "C:\Base_Arquivo_SAS\ARQUIVO_FINAL\BASE_ESCOBS.TXT"
        DBMS=TAB 
        REPLACE;
RUN;

