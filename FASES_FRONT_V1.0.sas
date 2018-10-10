/*libname para erro*/
libname workbck 'C:\Users\Di Giunta\Documents\My SAS Files\9.0\Bck';

/* INFORMAÇÃO:
MÊS DE REFERÊNCIA É O MÊS ATULA
ANO + MÊS DE REFERÊNCIA - ANOMES
ANO + (MÊS DE REFERÊNCIA-1) - ANOMES_M1
ANO + (MÊS DE REFERÊNCIA+1) - ANOMES_1M
*/


%MACRO OpCobrancaM1(ANOMES,ANOMES_M1,ANOMES_1M);

/***********************************************************************************/

/*CRIANDO BASE REMESSA COM PAGAMENTO */

/* REMESSA SEM EXTRAS */

/* CRIANDO BASE COM 2 MESES (m & m-1) */

DATA workbck.REMESSAM1_00;/* 1.1 CAPTURANDO INFO DE REMESSA */
	SET
		work.BDESCOB_&ANOMES_M1
		work.BDESCOB_&anomes;
	WHERE BASE IN ('REMESSA COMP' 'REMESSA' 'REMESSA UI' 'REMESSA XB') 
		AND STATUS = "REMESSA";
RUN;

DATA workbck.BAIXAM1_0;/* 1.2 CAPTURANDO INFO DE BAIXA */
	SET      
		work.BDESCOB_&ANOMES_1M
		work.BDESCOB_&ANOMES_M1
		work.BDESCOB_&anomes;
	WHERE BASE IN ('BAIXA')
		AND STATUS = "PAGAMENTO";
RUN;

DATA workbck.PCM1_0;/* 1.3 CAPTURANDO INFO DE BAIXA */
	SET 
		work.BDPRESTACAO_&ANOMES_1M
		work.BDPRESTACAO_&ANOMES_M1
		work.BDPRESTACAO_&anomes;
WHERE P_DLETRA <> '';
RUN;

/* CRUZANDO */

PROC SQL;/*1 CRUZANDO INFO PART_01 - PRESTACAO */
    CREATE TABLE workbck.REMESSAM1_01 AS SELECT
        A.*,
        B.DATA_ARQUIVO AS DATE_PC,
		.  as DATE_BX_EX
    FROM workbck.REMESSAM1_00 as A LEFT JOIN workbck.PCM1_0 as B ON A.C_ID_EMP = B.P_ID_EMP;
RUN;

PROC SQL;/*1 CRUZANDO INFO PART_02 - BAIXA */
    CREATE TABLE workbck.REMESSAM1_02 AS SELECT
        A.*,
		B.DATA_ARQUIVO AS DATE_BX
    FROM workbck.REMESSAM1_01 as A LEFT JOIN workbck.BAIXAM1_0 as B ON A.C_ID_EMP = B.C_ID_EMP;
QUIT;

/* REMESSA EXTRAS */

/* CRIANDO BASE COM 2 MESES (m & m-1) */

DATA workbck.REMESSAM1_EX_000;/* 2.1 CAPTURANDO INFO DE REMESSA EX */
	SET
		work.BDESCOB_&ANOMES_M1
		work.BDESCOB_&anomes;
	WHERE BASE = 'REMESSA EX' 
		AND STATUS = "REMESSA";
RUN;

CREATE TABLE workbck.REMESSAM1_EX_00 AS /* SELECIONA AS INFORMAÇÕES DO ULTIMA ARQUIVO (DATA_ARQUIVO) */  
SELECT
	t1.*,
	(max(data_arquivo)) as Ult_Arquivo
from workbck.REMESSAM1_EX_000 as t1
GROUP by C_CODI , P_TITULO
having (max(data_arquivo)) = DATA_ARQUIVO;
QUIT;



DATA workbck.BAIXAM1_EX0;/* 2.2 CAPTURANDO INFO DE BAIXA EX */
	SET 
		work.BDESCOB_&ANOMES_1M 
		work.BDESCOB_&ANOMES_M1
		work.BDESCOB_&anomes;
	WHERE BASE IN ('BAIXA_EX' 'BAIXA EX')
		AND STATUS = "PAGAMENTO";
RUN;

CREATE TABLE workbck.BAIXAM1_EX AS /* SLECIONA AS INFORMAÇÕES DO ULTIMA ARQUIVO (DATA_ARQUIVO) */  
SELECT
	t1.*,
	(max(data_arquivo)) as Ult_Arquivo
from workbck.BAIXAM1_EX0 as t1
GROUP by C_CODI , P_TITULO
having (max(data_arquivo)) = DATA_ARQUIVO;
QUIT;

/* CRUZANDO EX*/

PROC SQL;/* 2 CRUZANDO INFO PART_1 */
	CREATE TABLE workbck.REMESSAM1_EX_01 AS SELECT
		A.*,
		.  as DATE_PC,
		.  as DATE_BX,
		B.DATA_ARQUIVO AS DATE_BX_EX
	FROM workbck.REMESSAM1_EX_00 AS A LEFT JOIN  workbck.BAIXAM1_EX AS B ON A.C_CODI = B.C_CODI 
		AND A.P_TITULO = B.P_TITULO;
RUN;

/*** UNINDO REMESSA E REMESSA EX ***/

DATA workbck.REMESSAM1;
	SET 
		workbck.REMESSAM1_02
		workbck.REMESSAM1_EX_01;
RUN;

/* FIM CRIA BASE DE REMESSA */

/***********************************************************************************/

/* CRIANDO INFORMAÇÕES DE CONTRATOS */

/*ACHA CONTRATOS DESATIVADOS*/

PROC SQL;  
    CREATE TABLE workbck.BD_1 AS SELECT
        A.*,
        B.MIS_DATE AS DT_DEACTS       
    FROM workcont.bdcontract AS A LEFT JOIN safrag.Deacts_201506 AS B ON (A.CONTRATO=B.CONTRACT); /*FIX*/
QUIT;

/*ACHA CONTRATOS EM PRE CHURN*/

PROC SQL;  
    CREATE TABLE workbck.BD_2 AS SELECT
        A.*,
        B.dtsuspension       
    FROM workbck.BD_1 AS A 
	LEFT JOIN Workcont.Prechurn&ANOMES AS B ON (A.CONTRATO=B.IDCONTRACT) AND (A.idcliente = B.idcliente)
	;
QUIT;

/* CONTA A QTD DE CONTRATOS POR TIT. VENC. E ID. & DATA SUSPENSÃO - REMOVENDO DESATIVADOS */

PROC SQL;
    CREATE TABLE workbck.BD_3 AS 
        SELECT 
			idcliente,
			TITULO,
			PARCELA,
            DATA_VENC FORMAT DATE9.,
			(Min(DATA_EMISSAO)) as DATA_EMISSAO FORMAT DATE9.,
			(Min(dtsuspension)) as dtsuspension,
            COUNT(CONTRATO) AS CTR
        FROM workbck.BD_2  
            WHERE DT_DEACTS = . 
                GROUP BY TITULO, PARCELA, DATA_VENC, idcliente
				;
QUIT;


/* FIM CRIA INFORMAÇÕES DE CONTRATO */

/***********************************************************************************/

/* TRAZENDO INFORMAÇÕES PARA A BASE DE REMESSA */

/*TRAZENDO INFORMAÇÃO DO CONTRATO - DATA DE SUSPENSAO E # CONTRATOS */

PROC SQL; 
CREATE TABLE workbck.goon1 AS
SELECT
	t1.idcliente,
	t1.aging,
	t1.P_COBR,
	t1.C_ID_EMP ,
	t1.C_MOTIVO_BXA ,
	t1.DATA_ARQUIVO ,
	t1.ESCOB ,
	t1.BASE ,
	t1.STATUS ,
	t1.P_Titulo,
	t1.C_VPAR ,
	t1.C_VTPAR ,
	1 as contador,
	t1.DATA_REMESSA,
	t1.VENC_TITULO format=date9.,
	t1.DATE_BX,
	t1.DATE_PC,
	t1.DATE_BX_EX,
	t2.*
from workbck.REMESSA as t1
LEFT JOIN workbck.BD_3 as t2 ON (t1.P_titulo =(t2.titulo*10+t2.parcela)) AND (t1.VENC_TITULO = t2.DATA_VENC)
AND (t1.idcliente = t2.idcliente) 
;
QUIT;

/* TRAZENDO INFORMAÇÕES DE FILTRO PARA A BASE DE REMESSA - REGIAO, TIPO PESSOA & ESPECIE */

PROC SQL; 
CREATE TABLE workbck.goon2 AS
SELECT
	t1.*,
		/* Especie */
		(case	
			when (t2.especie = '12') then 'OUTRAS OPERADORAS'
			when (t2.especie = '14') then 'OUTRAS OPERADORAS'
			when (t2.especie = '15') then 'OUTRAS OPERADORAS'
			when (t2.especie = '21') then 'OUTRAS OPERADORAS'
			when (t2.especie = '25') then 'OUTRAS OPERADORAS'
			when (t2.especie = '31') then 'OUTRAS OPERADORAS'
			when (t2.especie = '41') then 'OUTRAS OPERADORAS'
			when (t2.especie = 'AE') then 'OUTROS'
			when (t2.especie = 'AN') then 'OUTROS'
			when (t2.especie = 'AT') then 'OUTROS'
			when (t2.especie = 'BD') then 'IDEN'
			when (t2.especie = 'BE') then '3G'
			when (t2.especie = 'CC') then 'OUTROS'
			when (t2.especie = 'CD') then 'OUTROS'
			when (t2.especie = 'FN') then 'OUTROS'
			when (t2.especie = 'HC') then 'OUTROS'
			when (t2.especie = 'HD') then 'OUTROS'
			when (t2.especie = 'HE') then 'OUTROS'
			when (t2.especie = 'HK') then 'OUTROS'
			when (t2.especie = 'LB') then 'OUTROS'
			when (t2.especie = 'MC') then 'OUTROS'
			when (t2.especie = 'ND') then 'OUTROS'
			when (t2.especie = 'NA') then 'OUTROS'
			when (t2.especie = 'PA') then 'OUTROS'
			when (t2.especie = 'PI') then 'OUTROS'
			when (t2.especie = 'RC') then 'OUTROS'
			when (t2.especie = 'UD') then 'OUTROS'
			when (t2.especie = 'UI') then 'EQUIPAMENTOS E ACESSÓRIOS'
			when (t2.especie = 'UH') then 'OUTROS'
			when (t2.especie = 'UX') then 'OUTROS'
			when (t2.especie = 'VC') then 'OUTROS'
			when (t2.especie = 'WL') then 'OUTROS'
			when (t2.especie = 'XB') then 'RENEGOCIAÇÕES'
			when (t2.especie = 'XC') then 'RENEGOCIAÇÕES'
			when (t2.especie = 'XD') then 'RENEGOCIAÇÕES'
			when (t2.especie = 'XH') then 'RENEGOCIAÇÕES'
			when (t2.especie = 'XI') then 'RENEGOCIAÇÕES'
			when (t2.especie = 'XJ') then 'OUTROS'
			when (t2.especie = 'XK') then 'RENEGOCIAÇÕES'
			when (t2.especie = 'ZC') then 'OUTROS'
			when (t2.especie = 'ZD') then 'OUTROS'
			else t2.especie
		END) as Grp_Especie,
		/* Tipo Pessoa */
		/* Tipo Pessoa *
		(case
			when (t2.Tipo_Pessoa contains 'Ju') then 'PJ'
			when (t2.Tipo_Pessoa contains 'F') then 'PF'
			else  'Outras'
		END) as TipoPessoa,*/
		'Outras' as TipoPessoa,
		/* Estado */
		(CASE
            WHEN (t2.Estado='DF') THEN 'Centro-Oeste'
            WHEN (t2.Estado='GO') THEN 'Centro-Oeste'
            WHEN (t2.Estado='MT') THEN 'Centro-Oeste'
            WHEN (t2.Estado='MS') THEN 'Centro-Oeste'
            WHEN (t2.Estado='AL') THEN 'Nordeste'
            WHEN (t2.Estado='BA') THEN 'Nordeste'
            WHEN (t2.Estado='CE') THEN 'Nordeste'
            WHEN (t2.Estado='MA') THEN 'Nordeste'
            WHEN (t2.Estado='PB') THEN 'Nordeste'
            WHEN (t2.Estado='PE') THEN 'Nordeste'
            WHEN (t2.Estado='PI') THEN 'Nordeste'
            WHEN (t2.Estado='RN') THEN 'Nordeste'
            WHEN (t2.Estado='SE') THEN 'Nordeste'
            WHEN (t2.Estado='AC') THEN 'Norte'
            WHEN (t2.Estado='AP') THEN 'Norte'
            WHEN (t2.Estado='AM') THEN 'Norte'
            WHEN (t2.Estado='PA') THEN 'Norte'
            WHEN (t2.Estado='RO') THEN 'Norte'
            WHEN (t2.Estado='RR') THEN 'Norte'
            WHEN (t2.Estado='TO') THEN 'Norte'
            WHEN (t2.Estado='ES') THEN 'Sudeste'
            WHEN (t2.Estado='MG') THEN 'Sudeste'
            WHEN (t2.Estado='RJ') THEN 'Sudeste'
            WHEN (t2.Estado='SP') THEN 'Sudeste'
            WHEN (t2.Estado='PR') THEN 'Sul'
            WHEN (t2.Estado='RS') THEN 'Sul'
            WHEN (t2.Estado='SC') THEN 'Sul'
			else 'EX'
		END) as Regiao
from workbck.goon1 as t1
LEFT JOIN Basegoon.Aging_&anomes as t2 ON (t1.P_titulo = input(COMPRESS(t2.Titulo,'-.'),best12.)) AND (t1.idcliente = t2.CPF_CNPJ) 
 AND (t1.VENC_TITULO = t2.Vencimento_Original) AND (t1.DATA_EMISSAO = t2.Emissao)
;
QUIT;

/*CRIANDO FAIXA DE COBRANÇA*/

PROC SQL; 
CREATE TABLE workbck.goon3 AS 
SELECT
	t1.*,
	(t1.DATA_ARQUIVO  - t1.VENC_TITULO ) as atraso,
	(case		/* VERSÃO COM BASE PRECHURN */
		when (P_COBR='00035') then 'Fase 1'
		when (P_COBR='00032') then 'Fase 1'
		when (P_COBR='00031') then 'Fase 1'
		when (P_COBR='00041') then 'Fase 1'
		when (t1.dtsuspension <> .) then 'Fase 3'
		ELSE 'Fase 2'
	END) as FaseChurn 	
from workbck.goon2 as t1
;
QUIT;



PROC SQL; 
CREATE TABLE workbck.Operacional AS
SELECT
	t1.*,
	(case
		when (missing(t1.DATE_BX)) AND (missing(t1.DATE_PC)) AND (missing(t1.DATE_BX_EX))  then 0
		else contador
	END) as contadorPgt, 
	(case
		when (missing(t1.DATE_BX)) AND (missing(t1.DATE_PC)) AND (missing(t1.DATE_BX_EX))  then 0
		else 1
	END) as Flag_Pgt,
	(case
		when (missing(t1.CTR)) then 1
		else t1.CTR
	END) as Ncontrato,/* colocando como 1 contrato para titulos não encontrados */
	(case  /* RECODE atraso <9 & > 30 para 9990 & 9999 */
		when (t1.atraso < 9) then 9990
		when (t1.atraso > 30) then 9999
		else t1.atraso
	END) as Recode_Atr
from workbck.goon3 as t1
;
QUIT;

/* FIM TRAZENDO INFORMAÇÕES PARA A BASE DE REMESSA */

/***********************************************************************************/

/* CRIANDO AS FASES & SALVA EM .TXT */

/*Fase 1*/

PROC SQL; 
CREATE TABLE workbck.OpFase1_&ANOMES AS 
SELECT
	t1.DATA_ARQUIVO format ddmmyy10.,
	t1.ESCOB ,
	t1.FaseChurn,
	t1.Flag_Pgt,
	(sum(input(t1.C_VPAR,10.2))) as TotValorParcela,
	(sum(input(t1.C_VTPAR,10.2))) as TotValorTotParcela,
	(sum(t1.contador)) as Qtd_Titulo,
	(sum(t1.Ncontrato)) as Qtd_Contrato,	
	(sum(t1.contadorPgt)) as Qtd_Titulo_Pgt,
	Grp_Especie,
	TipoPessoa,
	Regiao,
	Recode_Atr
from workbck.Operacional as t1
where t1.FaseChurn ='Fase 1'
GROUP by t1.DATA_ARQUIVO, t1.ESCOB, t1.FaseChurn, Flag_Pgt, Recode_Atr, Grp_Especie,TipoPessoa,Regiao
;
QUIT;



PROC EXPORT DATA=workbck.OpFase1_&ANOMES
   OUTFILE="C:\Users\Di Giunta\Documents\GoOn\Nextel\01 Planilha\02 Operacional Cobrança\Operacional Fase1_&ANOMES. M-1.txt"
   DBMS=TAB REPLACE;
RUN;

/*Fase 2 */

PROC SQL; 
CREATE TABLE workbck.OpFase2_&ANOMES AS 
SELECT
	t1.DATA_ARQUIVO format ddmmyy10.,
	t1.ESCOB ,
	t1.FaseChurn,
	t1.Flag_Pgt,
	(sum(input(t1.C_VPAR,10.2))) as TotValorParcela,
	(sum(input(t1.C_VTPAR,10.2))) as TotValorTotParcela,
	(sum(t1.contador)) as Qtd_Titulo,
	(sum(t1.Ncontrato)) as Qtd_Contrato,	
	(sum(t1.contadorPgt)) as Qtd_Titulo_Pgt,
	Grp_Especie,
	TipoPessoa,
	Regiao
from workbck.Operacional as t1
where t1.FaseChurn ='Fase 2'
GROUP by t1.DATA_ARQUIVO, t1.ESCOB, t1.FaseChurn, Flag_Pgt, FaseChurn,Grp_Especie,TipoPessoa,Regiao
;
QUIT;



PROC EXPORT DATA=workbck.OpFase2_&ANOMES
   OUTFILE="C:\Users\Di Giunta\Documents\GoOn\Nextel\01 Planilha\02 Operacional Cobrança\Operacional Fase2_&ANOMES. M-1.txt"
   DBMS=TAB REPLACE;
RUN;


%mend OpCobrancaM1;

%OpCobrancaM1 (201505,201504,201506);
