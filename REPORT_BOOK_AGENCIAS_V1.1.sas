/*****************************************/
/*****************RELATORIO***************/
/*****************************************/
/*****************************************/

/* 1.1 CAPTURANDO INFO DE REMESSA */
DATA REMESSA;
SET
ESCOBS.BDESCOB_201403
ESCOBS.BDESCOB_201402;	 /* ALTERAR DATA */
WHERE BASE IN ('REMESSA' 'REMESSA COMP');
RUN; 
/* 1.2 CAPTURANDO INFO DE BAIXA */
DATA BAIXA;
SET 
ESCOBS.BDESCOB_201403
ESCOBS.BDESCOB_201402;	 /* ALTERAR DATA */
WHERE BASE IN ('BAIXA');
RUN; 
/* 1.3 CAPTURANDO INFO DE BAIXA */
DATA PC;
SET 
ESCOBS.BDPRESTACAO_201403    /* ALTERAR DATA */
ESCOBS.BDPRESTACAO_201402;	 /* ALTERAR DATA */
WHERE P_DLETRA <> '';
RUN; 
/* ORDENANDO BASE */
PROC SORT DATA= REMESSA;
BY C_ID_EMP DATA_ARQUIVO;
RUN;
/* VERIFICANDO DUPLICIDADE */
PROC SORT DATA= REMESSA NODUPKEY;
BY C_ID_EMP;
RUN;
/* ORDENANDO BASE */	
PROC SORT DATA= BAIXA;
BY C_ID_EMP C_MOTIVO_BXA DATA_ARQUIVO;
RUN;
/* VERIFICANDO DUPLICIDADE */
PROC SORT DATA= BAIXA NODUPKEY;
BY C_ID_EMP C_MOTIVO_BXA;
RUN;
/* ORDENANDO BASE*/	
PROC SORT DATA= PC;	
BY P_ID_EMP DATA_ARQUIVO;
RUN;
/* VERIFICANDO DUPLICIDADE */
PROC SORT DATA= PC NODUPKEY;
BY P_ID_EMP;
RUN;

PROC TRANSPOSE
DATA 	= BAIXA				/* LIB.NOME_BASE - LEITURA */
OUT  	= BAIXA_1( DROP= _NAME_)
PREFIX = BAIXA_;				/* LIB.NOME_TABELA - CRIAR */
BY		C_ID_EMP;				/* VARIAVEIS QUE SERAO MANTIDAS NA LINHA */
ID		C_MOTIVO_BXA;				/* VARIAVEL A SER COLUNADA */
VAR		DATA_ARQUIVO;				/* VARIAVEL CARREGADA NOS VALORES DAS COLUNAS TABULADAS */
RUN;
/* CRUZANDO INFO PART_1*/
PROC SQL;
CREATE TABLE BASE_1 AS SELECT
*
FROM REMESSA A LEFT JOIN  BAIXA_1 B ON A.C_ID_EMP = B.C_ID_EMP ;
RUN;
/* CRUZANDO INFO PART_2*/
PROC SQL;
CREATE TABLE BASE_2 AS SELECT
A.*,
B.DATA_ARQUIVO AS DATE_PC
FROM BASE_1 A LEFT JOIN  PC B ON A.C_ID_EMP = B.P_ID_EMP ;
RUN;
/* FORMATAÇAO E PRIORIZAÇAO */
DATA BASE_3;
SET  BASE_2;
FORMAT DAT_PRIOR DATA_ARQUIVO DDMMYY10.;


IF DATE_PC <> . THEN DAT_PRIOR = DATE_PC;
ELSE IF BAIXA_PG <> . THEN DAT_PRIOR = BAIXA_PG;
ELSE IF BAIXA_OT <> . THEN DAT_PRIOR = BAIXA_OT;
ELSE IF BAIXA_DP <> . THEN DAT_PRIOR = BAIXA_DP;

IF DATE_PC <> . THEN PRIOR = 'PC       ';
ELSE IF BAIXA_PG <> . THEN PRIOR = 'PG';
ELSE IF BAIXA_OT <> . THEN PRIOR = 'OT';
ELSE IF BAIXA_DP <> . THEN PRIOR = 'DP';
																  
DATE_NEW = COMPRESS(YEAR(DATA_ARQUIVO)*10000+ MONTH(DATA_ARQUIVO)*100+ DAY(DATA_ARQUIVO));

VALOR = C_VPAR*1;
RUN;
/*REPORT BOOK ESCOB'S*/
ODS HTML BODY = '\\BRSLP1W8PFS03\GRUPOS\AFINIDADE\PLANEJAMENTO_CREDITO_COBRANCA\008_M.I.S\03_BOOK_ESCOBS\BASE_SAS.XLS';	/* ABERTURA DE HTML - NOME DE ARQUIVO */			

PROC TABULATE/*REPORT - BILLING #*/
DATA = 	BASE_3				MISSING FORMAT = COMMAX15.	ORDER = FORMATTED;
TITLE	QUANTIDADE - BILLING #;															
CLASS	DATE_NEW BILLING PRIOR TIPO ESCOB;															
TABLE	ESCOB=''*DATE_NEW=''*BILLING='' ALL,	PRIOR=''*TIPO=''*N=''	ALL*TIPO=''*N='';						
KEYLABEL ALL = 'TOTAL';
WHERE BASE = 'REMESSA';
RUN;

PROC TABULATE/*REPORT - BILLING $*/ 
DATA = 	BASE_3				MISSING FORMAT = COMMAX15.	ORDER = FORMATTED;
TITLE	VALOR - BILLING $;	
VAR VALOR;
CLASS	DATE_NEW BILLING PRIOR TIPO ESCOB;																
TABLE	ESCOB=''*DATE_NEW=''*BILLING='' ALL,	PRIOR=''*TIPO=''*VALOR=''*SUM=''	ALL*TIPO*VALOR=''*SUM='';					
KEYLABEL ALL = 'TOTAL';
WHERE BASE = 'REMESSA';
RUN;

PROC TABULATE/*REPORT - COMPLEMENTAR #*/
DATA = 	BASE_3				MISSING FORMAT = COMMAX15.	ORDER = FORMATTED;
TITLE	QUANTIDADE - COMPLEMENTAR #;															
CLASS	DATE_NEW PRIOR TIPO ESCOB;															
TABLE	ESCOB=''*DATE_NEW='',	PRIOR=''*TIPO=''*N=''	ALL*TIPO=''*N='';						
KEYLABEL ALL = 'TOTAL';
WHERE BASE = 'REMESSA COMP';
RUN;

PROC TABULATE/*REPORT - COMPLEMENTAR $*/ 
DATA = 	BASE_3				MISSING FORMAT = COMMAX15.	ORDER = FORMATTED;
TITLE	VALOR - COMPLEMENTAR $;	
VAR VALOR;/* TITULO DA QUERY */
CLASS	DATE_NEW BILLING PRIOR TIPO ESCOB;																
TABLE	ESCOB=''*DATE_NEW='',	PRIOR=''*TIPO=''*VALOR=''*SUM=''	ALL*TIPO*VALOR=''*SUM='';					
KEYLABEL ALL = 'TOTAL';
WHERE BASE = 'REMESSA COMP';
RUN;	
ODS HTML CLOSE;	







