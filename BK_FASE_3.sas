/*libname para erro*/
libname workbck 'C:\Users\Di Giunta\Documents\My SAS Files\9.0\Bck';

/* INFORMAÇÃO:
MÊS DE REFERÊNCIA É O MÊS ATULA
ANO + MÊS DE REFERÊNCIA - ANOMES
ANO + (MÊS DE REFERÊNCIA-1) - ANOMES_M1
*/


%MACRO OpCobrancaFASE3(ANOMES,ANOMES_M1,ANOMES_M2,ANOMES_M3);

/* SOLUÇÃO PARA O PROBLEMA DA DATE10. NO SAS 9.1.X */

proc sql;
/*
   create table work.BDESCOB_&anomes as
      select * from BDESCOBs.BDESCOB_&anomes;


   alter table work.BDESCOB_&anomes
      modify DATA_ARQUIVO format=date9.,
			 MISDATE format=date9.,
			 VENC_TITULO format=date9.;*/

   create table work.BDESCOB_&ANOMES_M1 as
      select * from BDESCOBs.BDESCOB_&ANOMES_M1;


   alter table work.BDESCOB_&ANOMES_M1
      modify DATA_ARQUIVO format=date9.,
			 MISDATE format=date9.,
			 VENC_TITULO format=date9.;


proc sql;
   create table work.BDESCOB_&ANOMES_M2 as
    select *
	from BDESCOBs.BDESCOB_&ANOMES_M2;


   alter table work.BDESCOB_&ANOMES_M2
      modify DATA_ARQUIVO format=date9.,
			 MISDATE format=date9.,
			 VENC_TITULO format=date9.;


   create table work.BDESCOB_&ANOMES_M3 as
      select *
 	  from BDESCOBs.BDESCOB_&ANOMES_M3;


   alter table work.BDESCOB_&ANOMES_M3
      modify DATA_ARQUIVO format=date9.,
			 MISDATE format=date9.,
			 VENC_TITULO format=date9.;

quit;


/*CRIANDO BASE REMESSA COM PAGAMENTO */

/* REMESSA SEM EXTRAS */

/* CRIANDO BASE COM 2 MESES (m & m-1) */

DATA workbck.REMESSA_F3_00;/* 1.1 CAPTURANDO INFO DE REMESSA */
	SET
		work.BDESCOB_&ANOMES_M3
		work.BDESCOB_&ANOMES_M2
		work.BDESCOB_&ANOMES_M1;
	WHERE BASE IN ('REMESSA COMP' 'REMESSA' 'REMESSA UI' 'REMESSA XB') 
		AND STATUS = "REMESSA";
RUN;

DATA workbck.BAIXA_F3_0;/* 1.2 CAPTURANDO INFO DE BAIXA */
	SET
		work.BDESCOB_&ANOMES_M3 
		work.BDESCOB_&ANOMES_M2
		work.BDESCOB_&ANOMES_M1
		;
	WHERE BASE IN ('BAIXA')
		AND STATUS = "PAGAMENTO";
RUN;

/* CRUZANDO */


PROC SQL;/*1 CRUZANDO INFO PART_02 - BAIXA */
    CREATE TABLE workbck.REMESSA_F3_02 AS SELECT
        A.*,
		B.DATA_ARQUIVO AS DATE_BX
    FROM workbck.REMESSA_F3_00 as A LEFT JOIN workbck.BAIXA_F3_0 as B ON A.C_ID_EMP = B.C_ID_EMP
;
QUIT;


/* REMESSA EXTRAS */

/* CRIANDO BASE COM 2 MESES (m & m-1) */

DATA workbck.REMESSA_F3_EX_00;/* 2.1 CAPTURANDO INFO DE REMESSA EX */
	SET
		work.BDESCOB_&ANOMES_M3
		work.BDESCOB_&ANOMES_M2
		work.BDESCOB_&ANOMES_M1;
	WHERE BASE = 'REMESSA EX' 
		AND STATUS = "REMESSA";
RUN;


DATA workbck.BAIXA_F3_EX;/* 2.2 CAPTURANDO INFO DE BAIXA EX */
	SET 
		work.BDESCOB_&ANOMES_M3 
		work.BDESCOB_&ANOMES_M2
		work.BDESCOB_&ANOMES_M1
		;
	WHERE BASE IN ('BAIXA_EX' 'BAIXA EX')
		AND STATUS = "PAGAMENTO";
RUN;

/* CRUZANDO EX*/

PROC SQL;/* 2 CRUZANDO INFO PART_1 */
	CREATE TABLE workbck.REMESSA_F3_EX_01 AS SELECT
		A.*,
		.  as DATE_BX,
		B.DATA_ARQUIVO AS DATE_BX_EX
	FROM workbck.REMESSA_F3_EX_00 AS A LEFT JOIN  workbck.BAIXA_F3_EX AS B ON A.C_CODI = B.C_CODI AND A.VENC_TITULO = B.VENC_TITULO
		AND A.P_TITULO = B.P_TITULO
;
RUN;

/*** UNINDO REMESSA E REMESSA EX ***/

DATA workbck.REMESSA_FASE3_00;
	SET 
		workbck.REMESSA_F3_EX_01
		workbck.REMESSA_F3_02;
RUN;



PROC SQL;
    CREATE TABLE workbck.REMESSA_FASE3 AS 
    select *
	from workbck.REMESSA_FASE3_00
	where P_COBR<>'00035' AND P_COBR<>'00032' AND P_COBR<>'00031' AND P_COBR<>'00041';
QUIT;

/* FIM CRIA BASE DE REMESSA */

/***********************************************************************************/

/* CRIANDO INFORMAÇÕES DE CONTRATOS */

/*ACHA CONTRATOS DESATIVADOS*/

PROC SQL;  
    CREATE TABLE workbck.BD_1 AS SELECT
        A.*,
        B.MIS_DATE AS DT_DEACTS       
    FROM workcont.bdcontract AS A LEFT JOIN Safrag.deacts_&ANOMES_M1 AS B ON (A.CONTRATO=B.CONTRACT);
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

/* SELECIONA CONTRATOS DO PRE CHURN (COM DATA SUSPENSÃO) E REMOVE DESATIVADOS */

PROC SQL;
    CREATE TABLE workbck.BD_3 AS 
        SELECT 
			*
		FROM workbck.BD_2  
            WHERE DT_DEACTS = . and dtsuspension <> .
;
QUIT;

/* FIM CRIA INFORMAÇÕES DE CONTRATO */

/***********************************************************************************/

/* TRAZENDO INFORMAÇÕES PARA A BASE DE REMESSA */

/*TRAZENDO INFORMAÇÃO DO CONTRATO - DATA DE SUSPENSAO E CONTRATOS */

PROC SQL; 
CREATE TABLE workbck.goon1 AS
SELECT
	t1.idcliente,
	t1.DATA_ARQUIVO ,
	t1.ESCOB ,
	t1.BASE ,
	t1.Titulo,
	1 as contador,
	t1.DATA_REMESSA,
	t1.VENC_TITULO format=date9.,
	t1.DATE_BX,
	t1.DATE_BX_EX,
	t2.dtsuspension,
	t1.P_titulo,
	t1.VENC_TITULO,
	t2.DATA_EMISSAO,
	t2.CONTRATO
from workbck.REMESSA_FASE3 as t1
LEFT JOIN workbck.BD_3 as t2 ON (t1.P_titulo =(t2.titulo*10+t2.parcela)) AND (t1.VENC_TITULO = t2.DATA_VENC)
AND (t1.idcliente = t2.idcliente) /* REDUÇÃO DOS CONTRATOS DE 69.460 PARA 64.278 */
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
LEFT JOIN Basegoon.Aging_&ANOMES_M1 as t2 ON (t1.P_titulo = input(COMPRESS(t2.Titulo,'-.'),best12.)) AND (t1.idcliente = t2.CPF_CNPJ)
 AND (t1.VENC_TITULO = t2.Vencimento_Original) AND (t1.DATA_EMISSAO = t2.Emissao)
WHERE t1.dtsuspension <> .
;
QUIT;

PROC SQL; 
CREATE TABLE workbck.OpFase3_00 AS
SELECT
	t1.*,
	(case
		when (missing(t1.DATE_BX)) AND (missing(t1.DATE_BX_EX))  then 0
		else contador
	END) as contadorPgt,
	max(t1.DATE_BX, t1.DATE_BX_EX) as Data_Baixa format date9.,
	(case 
		when Regiao = 'EX' THEN ''
		else Regiao
	END) as RegiaoRecode
from workbck.goon2 as t1
;
QUIT;

/* FIM TRAZENDO INFORMAÇÕES PARA A BASE DE REMESSA */


/***********************************************************************************/

/* CRIANDO AS FASES & SALVA EM .TXT */

/*Fase 3*/

PROC SQL; 
CREATE TABLE workbck.OpFase3_01 AS /* SLECIONA AS INFORMAÇÕES DO ULTIMA ARQUIVO (DATA_ARQUIVO) */  
SELECT
	t1.idcliente, 
	t1.ESCOB ,
	t1.contrato,
	DATA_ARQUIVO,
	(max(data_arquivo)) as Ult_Arquivo,
	(sum(t1.contador)) as Qtd_Titulo,
	(sum(t1.contadorPgt)) as Qtd_Titulo_Pgt,
	(max(t1.Data_Baixa)) as Data_Baixa,
	t1.DTSUSPENSION, 
	(max(Grp_Especie)) as Grp_Especie,
	(max(TipoPessoa)) as TipoPessoa,
	(max(RegiaoRecode)) as Regiao
from workbck.OpFase3_00 as t1
GROUP by t1.idcliente, t1.CONTRATO, DTSUSPENSION
having (max(data_arquivo)) = DATA_ARQUIVO;
QUIT;


PROC SQL; 
CREATE TABLE workbck.OpFase3 AS 
SELECT
	t1.*,
	(case
		when Qtd_Titulo = Qtd_Titulo_Pgt  then 1
		else 0
	END) as QtdContratoPgt,
	1 as QtdContrato
from workbck.OpFase3_01 as t1
;
quit;

proc sort data =workbck.OpFase3 /* REMOVE REGISTROS DUPLICADOS */
 nodup ;
 by CONTRATO IDCLIENTE ;
run ;


proc sort data =workbck.OpFase3 /* REMOVE REGISTROS DUPLICADOS MAS COM escob DIFERENTE (57 PARA 201507) - SELECIONA 1 REGISTRO */
 nodupKEY ;
 by CONTRATO IDCLIENTE DATA_ARQUIVO Qtd_Titulo Qtd_Titulo_Pgt QtdContratoPgt;
run ;



PROC SQL; 
CREATE TABLE workbck.OpFase3_&ANOMES AS 
SELECT
	t1.ESCOB ,
	(sum(t1.QtdContrato)) as QtdContrato,
	(sum(t1.QtdContratoPgt)) as QtdContratoPgt,
	(sum(t1.Qtd_Titulo)) as Qtd_Titulo,
	(sum(t1.Qtd_Titulo_Pgt)) as Qtd_Titulo_Pgt,
	t1.Data_Baixa format ddmmyy10.,  
	t1.Grp_Especie,
	t1.TipoPessoa,
	t1.Regiao
from workbck.OpFase3 as t1
GROUP by  t1.ESCOB, Data_Baixa, Grp_Especie,TipoPessoa,Regiao
;
QUIT;


PROC EXPORT DATA=workbck.OpFase3_&ANOMES
   OUTFILE="C:\Users\Di Giunta\Documents\GoOn\Nextel\01 Planilha\02 Operacional Cobrança\Operacional Fase3_&ANOMES..txt"
   DBMS=TAB REPLACE;
RUN;


%mend OpCobrancaFASE3;

%OpCobrancaFASE3 (201507,201506,201505,201504);








