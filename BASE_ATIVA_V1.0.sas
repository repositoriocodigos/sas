PROC SQL; /*BASE AGENCIAS*/
    CREATE TABLE REPORT.BOOK_GERAL AS
        SELECT

            status_contrato AS STATUS,
            COUNT(CPF_CNPJ) AS QUANT_CPF,
            NATUREZA AS TIPO,
            tenure_clientes_meses AS TENURE, 
            technology_type AS TECHNOLOGY,
            mercado AS ESTADO,
            credit_score_entrada AS CREDIT,
            credit_score_atual AS BEHAVIOR,
            segmentacao AS SEGMENTO,
            bill_cycle AS BILLING_CICLO


        FROM ESCOBS.BASE_ATIVA_201410 AS A
            WHERE status_contrato  <> 'Desativado'
                AND status_contrato IS NOT NULL
            GROUP BY 1,3,4,5,6,7,8,9,10;
RUN;

PROC SQL; /*BASE AGENCIAS*/
    CREATE TABLE REPORT.BOOK_PLANO AS
        SELECT

            plano,
            COUNT(CPF_CNPJ) AS QUANT_CPF

        FROM ESCOBS.BASE_ATIVA_201409 AS A
            WHERE status_contrato  <> 'Desativado'
                AND status_contrato IS NOT NULL
            GROUP BY 1;
RUN;

PROC EXPORT DATA= REPORT.BOOK_GERAL /*EXPORT DA BASE FINAL PARA CARREGAR O REPORT DAS AGENCIAS*/
    OUTFILE= "\\BRSLP1W8PFS03\GRUPOS\AFINIDADE\PLANEJAMENTO_CREDITO_COBRANCA\008_M.I.S\18- BOOK_COBRANÇA\10_BOOK_GERAL.XLS"
        DBMS=DLM 
        REPLACE;
RUN;

PROC EXPORT DATA= REPORT.BOOK_PLANO /*EXPORT DA BASE FINAL PARA CARREGAR O REPORT DAS AGENCIAS*/
    OUTFILE= "\\BRSLP1W8PFS03\GRUPOS\AFINIDADE\PLANEJAMENTO_CREDITO_COBRANCA\008_M.I.S\18- BOOK_COBRANÇA\10_BOOK_PLANO.XLS"
        DBMS=DLM 
        REPLACE;
RUN;