/*libname para erro*/
libname workbck 'C:\Users\Di Giunta\Documents\My SAS Files\9.0\Bck';
/* INFORMAÇÃO:
MÊS DE REFERÊNCIA É O MÊS ATULA
ULTIMO DIA DO MÊS DE REFERÊNCIA - DTFIMMES
PRIMEIRO DIA DO MÊS DE REFERÊNCIA- DTINMES
ANO + MÊS DE REFERÊNCIA - ANOMES
ANO + (MÊS DE REFERÊNCIA-1) - ANOMES_M1
*/


%MACRO OpCobrancaM(ANOMES,ANOMES_M1,DTFIMMES,DTINMES);
/*ACHA CONTRATOS DESATIVADOS*/

PROC SQL;  
    CREATE TABLE workbck.BD_1 AS SELECT
        A.*,
        B.Data_Desativacao AS DT_DEACTS       
    FROM workcont.bdcontract AS A LEFT JOIN Safrag.Cache_deacts_ate_&ANOMES AS B ON (A.CONTRATO=B.CONTRACT);
RUN;
/*ACHA CONTRATOS DATA DE SUSPENSÃO*/

PROC SQL;  
    CREATE TABLE workbck.TempS
	AS SELECT
	t1.contrato,
	(Max(DATA_SUSPENSAO)) as DATA_SUSPENSAO FORMAT DATE10.
	FROM Safrag.Cache_suspensao as t1
	where ((DATA_SUSPENSAO <&DTFIMMES) and (&DTFIMMES - DATA_SUSPENSAO < 120))
	GROUP BY contrato
;
QUIT;

PROC SQL;  
    CREATE TABLE workbck.BD_2 AS SELECT
        A.*,
        B.DATA_SUSPENSAO FORMAT DATE10.       
    FROM workbck.BD_1 AS A 
	LEFT JOIN workbck.TempS AS B ON (A.CONTRATO=B.CONTRATO)
	;
RUN;

PROC SQL;  
    CREATE TABLE workbck.BD_3 AS SELECT
        A.*,
        B.dtsuspension FORMAT DATE10.       
    FROM workbck.BD_2 AS A 
	LEFT JOIN workcont.Prechurn&ANOMES AS B ON (A.CONTRATO=B.CONTRATO)
	;
RUN;

/* CONTA A QTD DE CONTRATOS POR TIT. VENC. E ID. & DATA SUSPENSÃO*/

PROC SQL;
    CREATE TABLE workbck.BD_4 AS 
        SELECT 
			idcliente,
			P_TITULO,
            DATA_VENC FORMAT DATE10.,
			(Min(DATA_SUSPENSAO)) as DATA_SUSPENSAO_P,
			(Min(DATA_SUSPENSAO)) as DATA_SUSPENSAO_U,
			(Min(dtsuspension) as dtsuspension,
            COUNT(CONTRATO) AS CTR
        FROM workbck.BD_3  
            WHERE DT_DEACTS = . 
                GROUP BY P_TITULO, DATA_VENC, idcliente;
RUN;
/* TRAZENDO DATA DE SUSPENSAO E # CONTRATOS PARA A BASE */

/* CRIANDO BASE BDESCOB COM 2 MESES (m & m-1) */

proc sql;
	create table work.tmp as
		select *
	from bdescobs.BDESCOB_&ANOMES;
QUIT;

proc append base=work.tmp data=bdescobs.BDESCOB_&ANOMES_M1 FORCE;          
run;

proc sql;
	create table workbck.tmp as
		select *
	from work.tmp (drop= VENC_TITULO idcliente P_TITULO) ;
QUIT;


proc sql;
	create table workbck.REMESSA as
		select *,
		input(C_CODI,best.) as  idcliente,
		input(TITULO,best.) as  P_TITULO,
		input(substr(strip(DATA_REMESSA),1,10),DDMMYY10.) as VENC_TITULO
	from workbck.tmp;     
QUIT;


/*TRAZENDO INFORMAÇÃO DO CONTRATO */

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
	t1.Titulo,
	t1.C_VPAR ,
	t1.C_VTPAR ,
	1 as contador,
	t1.DATA_REMESSA,
	t1.VENC_TITULO FORMAT=date10.,
	t2.*
from workbck.REMESSA as t1
LEFT JOIN workbck.BD_4 as t2 ON (input(TITULO,best.) = t2.P_titulo) AND (t1.VENC_TITULO = t2.DATA_VENC)
AND (t1.idcliente = t2.idcliente) 
;
QUIT;

/* BASE DE REMESSA*/

PROC SQL; 
CREATE TABLE workbck.goon2 AS 
SELECT
	t1.*,
	input(TITULO,best.) as N_titulo,
	(case
		when (DATA_SUSPENSAO_U <= DATA_ARQUIVO) then DATA_SUSPENSAO_U
		when ((DATA_SUSPENSAO_U > DATA_ARQUIVO) and (DATA_SUSPENSAO_P <= DATA_ARQUIVO)) then DATA_SUSPENSAO_P 
	END) as DATA_SUSPENSAO
from workbck.goon1 as t1
where t1.STATUS ='REMESSA'
;
QUIT;


/*CRIANDO FAIXA DE COBRANÇA DA REMESSA*/

PROC SQL; 
CREATE TABLE workbck.goon3 AS 
SELECT
	t1.*,
	(t1.DATA_ARQUIVO  - t1.VENC_TITULO ) as atraso,
	(case
		when ((t1.DATA_ARQUIVO  - t1.VENC_TITULO ) <=30) then 'Fase 1'
		when ((&DTFIMMES - t1.DATA_SUSPENSAO) >=60 and (t1.DATA_SUSPENSAO <= t1.DATA_ARQUIVO)and (t1.DATA_ARQUIVO  - t1.VENC_TITULO ) > 60) then 'Fase 3'
		else 'Fase 2'
	END) as FaseCob,
	(case		/* VERSÃO COM BASE PRECHURN */
		when ((t1.DATA_ARQUIVO  - t1.VENC_TITULO ) <=30) then 'Fase 1'
		when (t1.dtsuspension>0) then 'Fase 3'
		ELSE 'Fase 2'
	END) as FaseChurn, 	
	(case		/* VERSÃO ATUAL NEXTEL */
		when (P_COBR='00035') then 'Fase 1'
		when (P_COBR='00032') then 'Fase 1'
		when (P_COBR='00031') then 'Fase 1'
		when (P_COBR='00041') then 'Fase 1'
		when (P_COBR='00042' AND ((t1.DATA_ARQUIVO  - t1.VENC_TITULO) >60) and t1.DATA_ARQUIVO >= &DTINMES) then 'Fase 3'
		when (P_COBR='00043' AND ((t1.DATA_ARQUIVO  - t1.VENC_TITULO) >60) and t1.DATA_ARQUIVO >= &DTINMES) then 'Fase 3'
		when (P_COBR='00006' AND ((t1.DATA_ARQUIVO  - t1.VENC_TITULO) >60) and t1.DATA_ARQUIVO >= &DTINMES) then 'Fase 3'
		when (P_COBR='00042' AND ((&DTINMES  - t1.VENC_TITULO) >60) and t1.DATA_ARQUIVO < &DTINMES) then 'Fase 3'
		when (P_COBR='00043' AND ((&DTINMES  - t1.VENC_TITULO) >60) and t1.DATA_ARQUIVO < &DTINMES) then 'Fase 3'
		when (P_COBR='00006' AND ((&DTINMES  - t1.VENC_TITULO) >60) and t1.DATA_ARQUIVO < &DTINMES) then 'Fase 3'
		ELSE 'Fase 2'
	END) as FAIXA 
from workbck.goon2 as t1
;
QUIT;



/* NOVA PARTE: ADICIONANDO INFO DE BAIXA E PRESTAÇÃO */

PROC SQL; 
CREATE TABLE workbck.BAIXA as
Select /* 1.2 CAPTURANDO INFO DE BAIXA */
    t1.*      
	from workbck.REMESSA as t1
    WHERE status = 'PAGAMENTO'
;
RUN;

PROC SORT DATA= workbck.BAIXA;/*ORDENANDO BASE*/
    BY C_ID_EMP DATA_ARQUIVO;
RUN;

PROC SORT DATA= workbck.BAIXA NODUPKEY;/*VERIFICANDO DUPLICIDADE*/
    BY C_ID_EMP;
RUN;


PROC SQL; 
CREATE TABLE workbck.PC as /* 1.3 CAPTURANDO INFO DE PRESTCAO */
    select *
    from BDPRESTA.BDPRESTACAO_&ANOMES;
RUN;


proc append base=workbck.PC data=BDPRESTA.BDPRESTACAO_&ANOMES_M1 FORCE; /* FORCE POR DIFERENÇAS NA BASE*/         
run;


PROC SORT DATA= workbck.PC;/* ORDENANDO BASE*/
    BY P_ID_EMP DATA_ARQUIVO;
RUN;

PROC SORT DATA= workbck.PC NODUPKEY;/* VERIFICANDO DUPLICIDADE*/
    BY P_ID_EMP;
RUN;



PROC SQL;/* CRUZANDO INFO PART_2 - PRESTACAO*/
    CREATE TABLE workbck.goon3_0 AS SELECT
        A.*,
        B.DATA_ARQUIVO AS DATE_PC
    FROM workbck.goon3 as A LEFT JOIN workbck.PC as B ON A.C_ID_EMP = B.P_ID_EMP;
RUN;



PROC SQL;/* CRUZANDO INFO PART_1 - BAIXA*/
    CREATE TABLE workbck.goon3_1 AS SELECT
        A.*,
		B.DATA_ARQUIVO AS DATE_BX
    FROM workbck.goon3_0 as A LEFT JOIN workbck.BAIXA as B ON A.C_ID_EMP = B.C_ID_EMP;
QUIT;


DATA workbck.PGTs;/*  CAPTURANDO INFO DE PGT */
    SET    
  		GOONPGT.PGT_&ANOMES.S
        GOONPGT.PGT_&ANOMES_M1.s;
RUN;

PROC SQL; 
CREATE TABLE workbck.goon3_2 AS
SELECT
	t1.*,
	(case
		when (missing(t1.CTR)) then 1
		else t1.CTR
	END) as Ncontrato, /* colocando como 1 contrato para titulos não encontrados */
	t2.*
from workbck.goon3_1 as t1
LEFT JOIN workbck.PGTs as t2 ON (input(COMPRESS(t2.NF,'-.'),12.) = t1.N_titulo) AND (t1.idcliente = t2.CNPJ) 
AND t1.VENC_TITULO = t2.Dt_Vencto
;
QUIT;

PROC SQL; 
CREATE TABLE workbck.goon3_3 AS
SELECT
	t1.*,
	(case
		when (missing(t1.dt_baixa)) AND (missing(t1.DATE_PC)) AND (missing(t1.DATE_BX))  then 0
		else contador
	END) as contadorPgt, 
	(case
		when (missing(t1.dt_baixa)) AND (missing(t1.DATE_PC)) AND (missing(t1.DATE_BX))  then 0
		else Ncontrato
	END) as NcontratoPgt,
	(case
		when (missing(t1.dt_baixa)) AND (missing(t1.DATE_PC)) AND (missing(t1.DATE_BX))  then 0
		else 1
	END) as Flag_Pgt,
	(case
		when (t1.DATA_ARQUIVO < &DTINMES) and ((dt_baixa >= &DTINMES) or missing(t1.dt_baixa))
		and ((DATE_PC >= &DTINMES) or missing(t1.DATE_PC)) and ((DATE_BX >= &DTINMES) or missing(t1.DATE_BX))
		then 1
		else 0
	END) as Flag_rolou 
from workbck.goon3_2 as t1
;
QUIT;

/*Salvando REMESSA em .csv para a planilha do MIS */

/*Fase 1*/


PROC SQL; 
CREATE TABLE workbck.goonFS1_&ANOMES AS 
SELECT
	t1.DATA_ARQUIVO format ddmmyy10.,
	t1.ESCOB ,
	t1.FaseCob,
	t1.FAIXA,
	t1.Flag_rolou,
	t1.Flag_Pgt,
	(sum(input(t1.C_VPAR,10.2))) as TotValorParcela,
	(sum(input(t1.C_VTPAR,10.2))) as TotValorTotParcela,
	(sum(t1.contador)) as Quantidade,
	(sum(t1.Ncontrato)) as Qtd_Contrato,	
	(sum(t1.contadorPgt)) as QuantidadePgt,
	(sum(t1.NcontratoPgt)) as Qtd_ContratoPgt,
	(sum(t1.vl_titulo)) as ValorTituloTotal,
	(sum(t1.vl_baixa)) as ValorPagoTotal,
	(sum(t1.saldo_pendente)) as SaldoPendenteTotal,
	t1.atraso,
	FaseChurn
from workbck.goon3_3 as t1
where t1.FaseCob ='Fase 1' or t1.FAIXA ='Fase 1' or t1.FaseChurn ='Fase 1'
GROUP by t1.DATA_ARQUIVO, t1.ESCOB, t1.FaseCob,t1.FAIXA, Flag_rolou, Flag_Pgt, atraso, FaseChurn
;
QUIT;


proc export data=workbck.goonFS1_&ANOMES 
	outfile = "C:\Users\Di Giunta\Documents\GoOn\Nextel\01 Planilha\02 Operacional Cobrança\Operacional Fase1_&ANOMES..csv"
	dbms=csv
	replace;
run;

/*Fase 2 & 3*/

PROC SQL; 
CREATE TABLE workbck.goonFS2_3_&ANOMES AS 
SELECT
	t1.DATA_ARQUIVO format ddmmyy10.,
	t1.ESCOB ,
	t1.FaseCob,
	t1.FAIXA,
	t1.Flag_rolou,
	t1.Flag_Pgt,
	(sum(input(t1.C_VPAR,10.2))) as TotValorParcela,
	(sum(input(t1.C_VTPAR,10.2))) as TotValorTotParcela,
	(sum(t1.contador)) as Quantidade,
	(sum(t1.Ncontrato)) as Qtd_Contrato,	
	(sum(t1.contadorPgt)) as QuantidadePgt,
	(sum(t1.NcontratoPgt)) as Qtd_ContratoPgt,
	(sum(t1.vl_titulo)) as ValorTituloTotal,
	(sum(t1.vl_baixa)) as ValorPagoTotal,
	(sum(t1.saldo_pendente)) as SaldoPendenteTotal,
	FaseChurn
from workbck.goon3_3 as t1
where t1.FaseCob ='Fase 3' or t1.FaseCob ='Fase 2' OR t1.FAIXA ='Fase 3' or t1.FAIXA ='Fase 2' OR t1.FaseChurn ='Fase 3' or t1.FaseChurn ='Fase 2'
GROUP by t1.DATA_ARQUIVO, t1.ESCOB, t1.FaseCob,t1.FAIXA, Flag_rolou, Flag_Pgt, FaseChurn
;
QUIT;


proc export data=workbck.goonFS2_3_&ANOMES 
	outfile = "C:\Users\Di Giunta\Documents\GoOn\Nextel\01 Planilha\02 Operacional Cobrança\Operacional Fase2 e 3_&ANOMES..csv"
	dbms=csv
	replace;
run;

%mend OpCobrancaM;

%OpCobrancaM (201505,201504, '31May2015'd, '01May2015'd);
