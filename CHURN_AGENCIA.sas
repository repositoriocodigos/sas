PROC SQL;  *INICIAL POR ESCOBS;
    CREATE TABLE REPORT.TB_AGENCIA_1 AS SELECT DISTINCT

        IDCLIENTE,
        ESCOB

    FROM ESCOBS.BDESCOB_201504 AS A
        WHERE FAIXA = "FASE_2"
            AND IDCLIENTE <> .
        GROUP BY 1;
RUN;

PROC SQL;
    *PRECHURN INICIAL POR ESCOBS;
    CREATE TABLE REPORT.TB_AGENCIA_2 AS  SELECT DISTINCT 

        A.*,
        MAX(B.ESCOB) AS ESCOBS

    FROM ESCOBS.PRECHURN_201504_AT AS A  LEFT JOIN  REPORT.TB_AGENCIA_1 AS B ON A.IDCLIENTE = B.IDCLIENTE
        GROUP BY 1;

    /*WHERE B.ESCOB IS NOT NULL*/;
RUN;

PROC SQL;
    *PRECHURN INICIAL SEPARADO POR PLANO ESCOBS;
    CREATE TABLE REPORT.TB_AGENCIA_3 AS SELECT  DISTINCT

        A.IDCONTRACT,
        A.IDCLIENTE,
        A.DTSUSPENSION,
        A.ESCOBS,
        MAX(B.TECNOLOGIA) AS TECNOLOGIA,
        MAX(B.PLANO) AS NEXTEL_PLANO

    FROM REPORT.TB_AGENCIA_2 AS A LEFT JOIN ESCOBS.SUSPENSION_MONTH AS B ON A.IDCONTRACT=B.CONTRATO AND A.IDCLIENTE=B.CLIENTE
        WHERE  B.CLIENTE  IS  NOT NULL
            GROUP BY  1,2,3,4;
RUN;

PROC SQL;
    *CRUZA COM A TABELA PLANO PARA TRAZER O GRUPO ESCOBS;
    CREATE TABLE REPORT.TB_AGENCIA_4 AS 
        SELECT  DISTINCT

            A.IDCONTRACT,
            A.IDCLIENTE,
            A.NEXTEL_PLANO,
            A.TECNOLOGIA,
            A.DTSUSPENSION,
            A.ESCOBS,
            B.PLANO,
            B.TECNOLOGIA

        FROM REPORT.TB_AGENCIA_3 AS A LEFT JOIN ESCOBS.PLANO_201503 AS B ON A.NEXTEL_PLANO=B.DESC_PLANO;
RUN;

PROC SQL;
    *RESULTADO FINAL COM O PRECHURN INCIAL POR ESCOBS;
    CREATE TABLE REPORT.TB_AGENCIA_5 AS SELECT  

        PLANO ,
        TECNOLOGIA ,
        ESCOBS,
        COUNT(PLANO) AS QUANT

    FROM REPORT.TB_AGENCIA_4 AS A
        GROUP BY 1,2,3;
RUN;

PROC SQL;
    *CRUZANDO COM O RECUPERADO;
    CREATE TABLE REPORT.TB_AGENCIA_6  AS 
        SELECT  

            A.IDCONTRACT,
            A.IDCLIENTE,
            A.PLANO,
            A.TECNOLOGIA,
            A.ESCOBS,
            B.DT_REAT

        FROM REPORT.TB_AGENCIA_4 AS A  LEFT JOIN REPORT.TB02 AS B ON A.IDCONTRACT=B.IDCONTRACT AND A.IDCLIENTE = B.IDCLIENTE
            WHERE  B.DT_REAT IS NOT NULL;
RUN;

PROC SQL;
    *RESULTADO FINAL / ESCOBS;
    CREATE TABLE REPORT.TB_AGENCIA_7 AS 
        SELECT  

            DT_REAT,
            PLANO ,
            TECNOLOGIA  ,
            ESCOBS,
            COUNT(PLANO) AS QUANT

        FROM REPORT.TB_AGENCIA_6 AS A
            GROUP BY 1,2,3,4;
RUN;