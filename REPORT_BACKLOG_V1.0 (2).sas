/*GERAC�O DE BASE BACKLOG*/
%LET BD_INCIAL = '30SEP2014'D;
%LET BD_FINAL  = '01NOV2014'D;
%LET BE_INICIAL ='17OCT2014'D;
%LET BE_FINAL =  '14NOV2014'D;
%LET DT_BACKLOG_INICIAL = '30NOV2014'D;
%LET DT_BACKLOG_ATUAL   = '21DEC2014'D;

PROC SQL;
    /*BACKLOG INICIAL 318 = IN-SUSPENSAO PARCIAL 230 = IN-NAO PAGAMENTO*/
    CREATE TABLE REPORT.BCKL_INICIAL AS
        SELECT

            INPUT(CUSTOMER_TAX_NUMBER,BEST14.) AS IDCLIENTE,
            INPUT(CONTRACT,8.) AS IDCONTRACT,
            DTSUSPENSION,
            TECHNOLOGY_TYPE 
        FROM ESCOBS.BACKLOG_201411
            WHERE TECHNOLOGY_TYPE = 'IDEN' AND  DTSUSPENSION BETWEEN  &BD_FINAL AND &BD_INCIAL
                AND CONTRACT_REASON_STATUS = '318'  
                /*AND DTSUSPENSION = &DT_BACKLOG_INICIAL*/
                UNION ALL


            SELECT

                INPUT(CUSTOMER_TAX_NUMBER,BEST14.) AS IDCLIENTE,
                INPUT(CONTRACT,8.) AS IDCONTRACT,
                DTSUSPENSION,
                TECHNOLOGY_TYPE 
            FROM ESCOBS.BACKLOG_201411
                WHERE TECHNOLOGY_TYPE = '3G' AND  DTSUSPENSION BETWEEN &BE_INICIAL AND &BE_FINAL
                /*AND DTSUSPENSION = &DT_BACKLOG_INICIAL*/
                    AND CONTRACT_REASON_STATUS = '230';
RUN;

PROC SQL;
    /*BACKLOG ATUAL 318 = IN-SUSPENSAO PARCIAL 230 = IN-NAO PAGAMENTO*/
    CREATE TABLE REPORT.BCKL_ATUAL AS
        SELECT

            INPUT(CUSTOMER_TAX_NUMBER,BEST14.) AS IDCLIENTE,
            INPUT(CONTRACT,8.) AS IDCONTRACT,
            DTSUSPENSION,
            TECHNOLOGY_TYPE 
        FROM ESCOBS.BACKLOG_201412
            WHERE TECHNOLOGY_TYPE = 'IDEN' AND  DTSUSPENSION BETWEEN &BD_FINAL AND &BD_INCIAL
                AND CONTRACT_REASON_STATUS = '318'  
                /*AND DTSUSPENSION = &DT_BACKLOG*/
                UNION ALL


            SELECT

                INPUT(CUSTOMER_TAX_NUMBER,BEST14.) AS IDCLIENTE,
                INPUT(CONTRACT,8.) AS IDCONTRACT,
                DTSUSPENSION,
                TECHNOLOGY_TYPE 
            FROM ESCOBS.BACKLOG_201412
                WHERE TECHNOLOGY_TYPE = '3G' AND  DTSUSPENSION BETWEEN  &BE_INICIAL AND &BE_FINAL
                /*AND DTSUSPENSION = &DT_BACKLOG*/
                    AND CONTRACT_REASON_STATUS = '230';
RUN;

PROC SORT/*IDENTIFICANDO OS CLIENTES QUE SAIRAM DO BACKLOG, ISTO E, CRUZAR QUEM INICIOU CONTRA QUEM SAIU*/
    DATA=REPORT.BCKL_INICIAL;
    BY IDCONTRACT;
RUN;

PROC SORT/*IDENTIFICANDO OS CLIENTES QUE SAIRAM DO BACKLOG, ISTO E, CRUZAR QUEM INICIOU CONTRA QUEM SAIU*/
    DATA=REPORT.BCKL_ATUAL;
    BY IDCONTRACT;
RUN;

DATA RECOVERY_1;
    MERGE REPORT.BCKL_INICIAL (IN=A) REPORT.BCKL_ATUAL (IN=B);
    BY IDCONTRACT;
    IF B=0;
RUN;

PROC SQL;
    CREATE TABLE RECOVERY_2 AS
        SELECT 

            A.*, 
            B.CLASS_TIPO

        FROM RECOVERY_1 AS A LEFT JOIN ESCOBS.DEACTS_201412 AS B ON A.IDCONTRACT = INPUT(B.CONTRACT,BEST12.);
QUIT;

PROC FREQ 
    DATA=RECOVERY_2;
    TABLE CLASS_TIPO / NOCOL NOROW NOCUM MISSING;
RUN;

DATA REATIVACAO;
    SET ESCOBS.SUSPENSION_201412;
    IF DATA_REATIVACAO_ANTERIOR NE . OR DATA_REATIVACAO_NO_MES NE .;
    FLGREATIV = 1;
    KEEP CLIENTE CONTRATO DATA_BASE DATA_REATIVACAO_ANTERIOR DATA_REATIVACAO_NO_MES  TYPE_TECHNOLOGY;
RUN;

PROC SORT 
    DATA  = REATIVACAO;
    BY CLIENTE CONTRATO
    DESCENDING DATA_BASE;
RUN;

PROC SORT 
    DATA  = REATIVACAO 
    NODUPKEY;
    BY CLIENTE CONTRATO;
RUN;

PROC SQL;/*IDENTIFICANDO OS CLIENTES QUE SAIRAM DO BACKLOG, ISTO E, CRUZAR QUEM INICIOU CONTRA QUEM SAIU*/;
    CREATE TABLE RECOVERY_3 AS
        SELECT 

            A.*, 
            B.DATA_BASE AS DTREATIVACAO 

        FROM RECOVERY_2 AS A LEFT JOIN REATIVACAO AS B ON A.IDCONTRACT = B.CONTRATO;
RUN;

PROC FREQ/*REPORT FINAL*/ 
    DATA=RECOVERY_3;
    WHERE CLASS_TIPO = '';
    TABLE DTREATIVACAO TECHNOLOGY_TYPE / NOCOL NOROW NOCUM MISSING;

RUN;

/*DATA REPORT.BCKL_ATUAL;
    SET REPORT.BCKL_ATUAL;
    LENGTH IDCLIENTE 8;
    FORMAT IDCLIENTE z14.;
RUN;

PROC FREQ 

    DATA=REPORT.BCKL_ATUAL;
    TABLE TECHNOLOGY_TYPE;
RUN; */
