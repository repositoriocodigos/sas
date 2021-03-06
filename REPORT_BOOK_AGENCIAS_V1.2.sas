﻿/*****************************************/
/*****************RELATORIO***************/
/*****************************************/
/*****************************************/

DATA REPORT.REMESSA;/* 1.1 CAPTURANDO INFO DE REMESSA */

    SET
      
        ESCOBS.BDESCOB_201407
        ESCOBS.BDESCOB_201408;     
    WHERE BASE IN ('REMESSA COMP' 'REMESSA' 'REMESSA UI');
RUN;

DATA REPORT.BAIXA;/* 1.2 CAPTURANDO INFO DE BAIXA */

    SET 
   
        ESCOBS.BDESCOB_201407
        ESCOBS.BDESCOB_201408;   
    WHERE BASE IN ('BAIXA');
RUN;


DATA REPORT.PC;/* 1.3 CAPTURANDO INFO DE BAIXA */
    SET 
  
    ESCOBS.BDPRESTACAO_201407
    ESCOBS.BDPRESTACAO_201408;     
    WHERE P_DLETRA <> '';
RUN;


PROC SORT DATA = REPORT.REMESSA;/* ORDENANDO BASE */
    BY C_ID_EMP DATA_ARQUIVO;
RUN;


PROC SORT DATA= REPORT.REMESSA NODUPKEY;/* VERIFICANDO DUPLICIDADE */
    BY C_ID_EMP;
RUN;


PROC SORT DATA= REPORT.BAIXA;/* ORDENANDO BASE */
    BY C_ID_EMP C_MOTIVO_BXA DATA_ARQUIVO;
RUN;


PROC SORT DATA= REPORT.BAIXA NODUPKEY;/* VERIFICANDO DUPLICIDADE */
    BY C_ID_EMP C_MOTIVO_BXA;
RUN;


PROC SORT DATA= REPORT.PC;/* ORDENANDO BASE*/
    BY P_ID_EMP DATA_ARQUIVO;
RUN;


PROC SORT DATA= REPORT.PC NODUPKEY;/* VERIFICANDO DUPLICIDADE */
    BY P_ID_EMP;
RUN;

PROC TRANSPOSE /* TRANSPOR DE LINHA PARA COLUNA */
    DATA     = REPORT.BAIXA                 /* LIB.NOME_BASE - LEITURA */
    OUT      = REPORT.BAIXA_1( DROP= _NAME_)
    PREFIX = BAIXA_;                        /* LIB.NOME_TABELA - CRIAR */
    BY        C_ID_EMP;                     /* VARIAVEIS QUE SERAO MANTIDAS NA LINHA */
    ID        C_MOTIVO_BXA;                 /* VARIAVEL A SER COLUNADA */
    VAR        DATA_ARQUIVO;                /* VARIAVEL CARREGADA NOS VALORES DAS COLUNAS TABULADAS */
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


DATA REPORT.BASE_3;/* FORMATACAO E PRIORIZACAO */
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

ODS HTML BODY = '\\BRSLP1W8PFS03\GRUPOS\AFINIDADE\PLANEJAMENTO_CREDITO_COBRANCA\008_M.I.S\03_BOOK_ESCOBS\REPORT\BASE_SAS.XLS';/* ABERTURA DE HTML - NOME DE ARQUIVO */

PROC TABULATE/*REPORT - BILLING #*/

    DATA =   REPORT.BASE_3                MISSING FORMAT = COMMAX15.    ORDER = FORMATTED;
    TITLE    QUANTIDADE - BILLING #;
    CLASS    DATE_NEW BILLING PRIOR TIPO ESCOB;

    TABLE    ESCOB=''*DATE_NEW=''*BILLING='' ALL,    PRIOR=''*TIPO=''*N=''    ALL*TIPO=''*N='';
        KEYLABEL ALL = 'TOTAL';
        WHERE BASE = 'REMESSA';
RUN;

PROC TABULATE/*REPORT - BILLING $*/

    DATA =   REPORT.BASE_3                MISSING FORMAT = COMMAX15.    ORDER = FORMATTED;
    TITLE    VALOR - BILLING $;
    VAR VALOR;
    CLASS    DATE_NEW BILLING PRIOR TIPO ESCOB;

    TABLE    ESCOB=''*DATE_NEW=''*BILLING='' ALL,    PRIOR=''*TIPO=''*VALOR=''*SUM=''    ALL*TIPO*VALOR=''*SUM='';
        KEYLABEL ALL = 'TOTAL';
        WHERE BASE = 'REMESSA';
RUN;

PROC TABULATE/*REPORT - COMPLEMENTAR #*/

    DATA =   REPORT.BASE_3                MISSING FORMAT = COMMAX15.    ORDER = FORMATTED;
    TITLE    QUANTIDADE - COMPLEMENTAR #;
    CLASS    DATE_NEW PRIOR TIPO ESCOB;

    TABLE    ESCOB=''*DATE_NEW='',    PRIOR=''*TIPO=''*N=''    ALL*TIPO=''*N='';
        KEYLABEL ALL = 'TOTAL';
        WHERE BASE = 'REMESSA COMP';
RUN;

PROC TABULATE/*REPORT - COMPLEMENTAR $*/

    DATA =   REPORT.BASE_3                MISSING FORMAT = COMMAX15.    ORDER = FORMATTED;
    TITLE    VALOR - COMPLEMENTAR $;
    VAR VALOR;/* TITULO DA QUERY */
    CLASS    DATE_NEW BILLING PRIOR TIPO ESCOB;

    TABLE    ESCOB=''*DATE_NEW='',    PRIOR=''*TIPO=''*VALOR=''*SUM=''    ALL*TIPO*VALOR=''*SUM='';
        KEYLABEL ALL = 'TOTAL';
        WHERE BASE = 'REMESSA COMP';
RUN;

ODS HTML CLOSE;
