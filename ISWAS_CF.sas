LIBNAME COLL '/BRRISK_COLLECT/COBRANCA/MIS/';

%LET CONTRATO = DRI_899_CONTRATO_CFI_20120229;
%Let MIS_DATE = '29FEB2012:00:00:00'dt; 
%Let DTHORA_INCLUSAO_INICIO = '29FEB2012:00:00:00'dt; 
%Let DTHORA_INCLUSAO_FIM = '29FEB2012:24:00:00'dt;
PROC SQL; /* PASSO 1: ARQUIVO CRT(CONTRATO) */ 
 CREATE TABLE WORK.CONTR_ AS SELECT CONTRATO FORMAT=$12.,
	 PRODUTO FORMAT=$4.,
	 CPF,
	 LOGIN FORMAT=$15.,
	 NOME_USUARIO FORMAT=$45.,
	 PERFIL FORMAT=$15.,
	 REGIONAL FORMAT=9.,
	 FILIAL FORMAT=9.,
	 CODIGO_PROMOTOR FORMAT=9.,
	 PROMOTOR FORMAT=$35.,
	 DATA_INTEGRACAO FORMAT=DATETIME20.,
	 DATA_FORMALIZACAO FORMAT=DATETIME20.,
	 DATA_PARCELA FORMAT=DATETIME20.,
	 VENCIMENTO FORMAT=DATETIME20.,
	 CARENCIA FORMAT=4. AS CARRENCIA,
	 PLANOS FORMAT=4.,
	 PRAZO FORMAT=4.,
	 SALDO_CONTABIL FORMAT=22.2,
	 VENDA_EMPRESTIMOS FORMAT=14.2,
	 CAC FORMAT=12.2,
	 FINAC_TAC FORMAT=$1.,
	 SEGURO FORMAT=12.2,
	 FINAC_SEGURO FORMAT=$1.,
	 IOC FORMAT=12.2,
	 FINAC_IOC FORMAT=$1.,
	 VLR_FINANCIADO FORMAT=22.2,
	 TAXA_CLIENTE FORMAT=7.2,
	 TAXA_EFETIVO FORMAT=7.2,
	 MATCHED FORMAT=7.2,
	 ('') AS COD_CAMP,
	 PARCELA FORMAT=12.2,
	 FORMA_PAGTO FORMAT=$1.,
	 FORMA_LIBERACAO FORMAT=$1.,
	 PROX_VENCTO FORMAT=DATETIME20.,
	 CODTABJUROS FORMAT=$8.,
	 ('') AS SIT_ATRASO_BR,
	 SIT_CONT_NY FORMAT=$1.,
	 VAL_US_SD_PRINC FORMAT=12.2,
	 SALDO_NACC FORMAT=12.2,
	 DATA_CANCELAMENTO FORMAT=DATETIME20.,
	 DATA_LIQ_CONTR FORMAT=DATETIME20.,
	 ('') AS COD_FEATURE,
	 INTEREST FORMAT=12.2 AS VAL_TAXA,
	 CANAL FORMAT=4. AS CANAL_DIVULGACAO 
 FROM BRCFDBCO.&CONTRATO;
QUIT;
PROC SQL; /* PASSO 2: ARQUIVO PRT(PROPOSTA) */
 CREATE TABLE WORK.Propos_ AS SELECT MIS_DATE FORMAT=DATETIME20.,
	 NUM_CPF FORMAT=12.,
	 DTHORA_INCLUSAO FORMAT=DATETIME20.,
	 COD_CONTRATO FORMAT=$12.,
	 NOME_CLIENTE FORMAT=$60.,
	 COD_CEP FORMAT=9.,
	 DESC_LOGRADOURO FORMAT=$60.,
	 NUM_LOGRADOURO FORMAT=$5.,
	 DESC_COMPL_LOGR FORMAT=$45.,
	 SIGLA_UF_END FORMAT=$2.,
	 DESC_CIDADE FORMAT=$40.,
	 ESTADO_CIVIL FORMAT=$1. AS COD_ESTADO_CIVIL,
	 COD_SEXO FORMAT=$1.,
	 DATA_NASCIMENTO FORMAT=DATETIME20.,
	 DATA_ADMISSAO FORMAT=DATETIME20.,
	 QTDE_MES_EMP_ANT FORMAT=5.,
	 TIPO_RESIDENCIA FORMAT=$1.,
	 QTDE_MES_RESID FORMAT=4.,
	 DESC_PROFISSAO FORMAT=$35.,
	 DESC_CARGO FORMAT=$35.,
	 QTDE_DIAS_CAREN FORMAT=5.,
	 QTDE_PRESTACOES FORMAT=4.,
	 VAL_FINANC FORMAT=12.2,
	 DESC_NATU_OCUP FORMAT=$30.,
	 DESC_ESCOLARIDADE FORMAT=$35.,
	 COD_COR_PERFIL FORMAT=11.,
	 TAXA_CORRETA FORMAT=22.2,
	 VAL_SALARIO_LIQ FORMAT=11.2,
	 OUTRAS_RENDAS FORMAT=14.2,
	 VALOR_NF FORMAT=8.,
	 VAL_MERCADO FORMAT=8.,
	 VENDA_EMPRESTIMOS FORMAT=9.,
	 PARCELA FORMAT=12.2,
	 PRODUTO FORMAT=$4.,
	 FILIAL FORMAT=7.,
	 COD_BANCO FORMAT=5.,
	 DATA_ABERTURA FORMAT=DATETIME20.,
	 FUNCIONAL FORMAT=$35.,
	 ('') AS NOME_USUARIO,
	 DATA_ULT_CONSULTA FORMAT=DATETIME20.,
	 QDE_PASS_CDC FORMAT=4.,
	 QDE_PASS_PESSOAL FORMAT=4.,
	 QDE_PASS_OUTROS FORMAT=4.,
	 QDE_PASS_VEICULO FORMAT=4.,
	 QDE_PASS_CHEQUE FORMAT=4.,
	 SCORE_ACSP FORMAT=5.,
	 QDE_PASS_JURIDICO FORMAT=4.,
	 QDE_OCORRENCIA FORMAT=4.,
	 VAL_TOT_NEGATIVO FORMAT=12.2,
	 FLAG_INTEGRAR FORMAT=$1.,
	 BOOKED FORMAT=$12.,
	 DATA_CANCELAMENTO FORMAT=DATETIME20.,
	 SEQ_CAPA FORMAT=9.,
	 SCORE_SERASA2 FORMAT=$6.,
	 QTDE_PONTOS_SCORE FORMAT=6.,
	 SALARIO_CONJUGE FORMAT=10.2,
	 ('') AS SALARIO_COOBRIGADO,
	 COD_FEATURE FORMAT=5.,
	 COD_CAMPANHA FORMAT=4. AS COD_CAMP,
	 TIPO_LIQUIDACAO FORMAT=$1.,
	 SPOP_SCORE FORMAT=$6. AS QTDE_SCORE,
	 ('') AS VAL_SEGURO,
	 COLL_CAR_MODEL_YEAR_1 FORMAT=$4. AS ANO_MODELO,
	 COLL_CAR_MODEL_1 FORMAT=$15. AS ANO_FABRIC,
	 COD_TP_VEIC FORMAT=3.,
	 DESC_TP_VEIC FORMAT=$35.,
	 ('') AS COD_RECUSA,
	 DESC_RECUSA FORMAT=$35.,
	 VAL_PMT_LIM_CRED FORMAT=14.2,
	 CANAL FORMAT=4. AS CANAL_DIVULGACAO,
	 ('') AS COD_VEICULO,
	 ('') AS DESC_VEICULO,
	 ('') AS COD_OFFICER,
	 ('') AS NOME_OFFICER 
 FROM BRCFDBCO.DRI_899_PROPOSTA_CFI
 WHERE DRI_899_PROPOSTA_CFI.MIS_DATE = &MIS_DATE AND
	   DRI_899_PROPOSTA_CFI.DTHORA_INCLUSAO >= &DTHORA_INCLUSAO_INICIO AND
	   DRI_899_PROPOSTA_CFI.DTHORA_INCLUSAO <= &DTHORA_INCLUSAO_FIM;
QUIT;
PROC SQL; /* PASSO 3: ARQUIVO WO */
CREATE TABLE WORK.ARQ_ACUM_WO_ AS SELECT 
     CONTRATO FORMAT=$12. AS COD_CONTRATO,
	 PRODUTO FORMAT=$4.,
	 SIT_CONT_NY FORMAT=$1. AS SITUACAO,
	 SALDO_WO FORMAT=12.2,
	 DATA_WO FORMAT=DATETIME20. AS DATA_PREJUIZO
 FROM BRCFDBCO.&CONTRATO 
 WHERE ( SIT_CONT_NY = "W" AND DATA_WO NOT IS NULL );
QUIT;
DATA WORK.ARQ_ACUM_WO_;
SET WORK.ARQ_ACUM_WO_;
	FORMAT NU_SCORE 8.;
	FORMAT DT_RFRNA DATETIME20.;
	FORMAT DT_INTGO DATETIME20.;
	FORMAT CD_SGMTO 8.;
	FORMAT CD_PRDTO 8.;
RUN;
