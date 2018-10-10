PROC SQL;
CREATE TABLE ATIVO_DADOS AS
SELECT

CPF_CGC AS CLIENTE,
CUSTOMER_COSTCENTER AS CUSTOMER,
TELEFONE_CONTRATO AS TELEFONE,
CONTRATO AS CONTRACT,
PLANO AS INTERNET


FROM ATIVA.BASE_ATIVA_201404 AS A
WHERE STATUS_CONTRATO = 'Ativo'
AND PLANO IN ("004/Internet Modem P"
"004/Internet Modem P PROMO"
"004/POS/SMP - Internet Modem"
"005/Internet Modem M"
"005/Internet Modem M PROMO"
"007/Internet Modem GG"
"Internet Modem GG -016/P�S/SMP"
"Internet Modem Teste"
"003/POS/SMP - Internet Modem"
"Intern Modem G PJ 017/P�S/SMP"
"Intern Modem GG PJ 016/P�S/SMP"
"Intern Modem M PJ 018/P�S/SMP"
"Intern Modem P PJ 019/P�S/SMP"
"Intern Tablet PJ 015/P�S/SMP"
"Internet Modem FF 005/P�S/SMP"
"Internet Modem G - 006/P�S/SMP"
"Internet Modem GG -007/P�S/SMP"
"Internet Modem M - 005/P�S/SMP"
"Internet Modem P - 004/P�S/SMP"
"Internet Tablet - 008/P�S/SMP"
"Internet Modem P PROMO**"
"Internet Modem P"
"Internet Modem M PROMO**"
"Internet Modem M"
"Internet Modem G PROMO**"
"Internet Modem G"
"Internet Modem GG PROMO**
"Internet Modem GG"
"3G Modem 1 GB"
"3G + Int Modem 3GB"
"3G + Int Modem 5GB"
"3G +Int Modem 8GB"
"3G + Int Modem 10GB"
"4G Int Modem 3GB"
"4G Int Modem 5GB"
"4G Int Modem 8GB"
"4G Int Modem 10GB")
;
RUN;

PROC SQL;
CREATE TABLE SASUSER.ENVIO_MODEM AS 
SELECT 	DISTINCT

A.C_DLETRA,
A.C_CODI,
A.FILLER,
A.C_TIPO,
A.C_NUMT,
A.C_FILIAL,
A.C_TOTPAR,
A.C_PARCI,
A.C_PARCF,
A.C_VENCIM,
A.C_VPAR,
A.C_VTPAR,
A.C_OPERESP,
A.C_OBSE,
A.C_ID_EMP,
A.C_DATRET,
A.C_DATEMI,
A.P_SITUAC,
A.FILLER2,
A.C_CREDOR,
A.C_DT_DESATIV,
A.C_DT_SUSPENSAO,
A.C_NEGATIVADO,
A.C_DT_NEGATIVACAO,
A.C_CENTRO_CUSTO,
A.C_SOCIO1,
A.C_PER_SOCIO1,
A.C_SOCIO2,
A.C_PER_SOCIO2,
A.C_SOCIO3,
A.C_PER_SOCIO3,
A.C_RENDA,
A.C_CAP_SOCIAL,
A.C_DT_FUND,
A.C_CONTATO_1,
A.C_FONE_1_1,
A.C_FONE_2_1,
A.C_FONE_3_1,
A.C_CONTATO_2,
A.C_FONE_1_2,
A.C_FONE_2_2,
A.C_FONE_3_2,
A.C_CONTATO_3,
A.C_FONE_1_3,
A.C_FONE_2_3,
A.C_FONE_3_3,
A.C_CONTATO_1_1,
A.C_FONE_NEXTEL_1,
A.C_CONTATO_2_2,
A.C_FONE_NEXTEL_2,
A.C_CONTATO_3_3,
A.C_FONE_NEXTEL_3,
A.C_MOTIVO_BXA,
A.FILLER3,
A.ESCOB,
A.BILLING,
B.TELEFONE,
B.INTERNET

FROM WORK.SCORE AS A LEFT JOIN WORK.ATIVO_DADOS AS B ON A.C_CODI = B.CLIENTE	
WHERE ESCOB = 'ULTRACENTER'
AND TELEFONE IS NOOT NULL;
RUN;