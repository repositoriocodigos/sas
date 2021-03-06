libname COLL '/brrisk_collect/cobranca/MIS/';

PROC SQL;/*PARC_P*/
 CREATE TABLE COLL.PARC_20110831 AS SELECT ("31aug2011:00:00:00"dt) AS PROC_DATE,
	 REGIONAL FORMAT=6.,
	 PRODUTO FORMAT=$4.,
	 CONTRATO FORMAT=$12.,
	 NUM_PARC FORMAT=4.,
	 DTA_VCTO_PARC FORMAT=DATETIME20.,
	 QTD_PRESTA FORMAT=4.,
	 VLR_PARCELA FORMAT=12.2,
	 SALDO_CONTABIL FORMAT=12.2,
	 LIQUIDADA FORMAT=$1.,
	 DATA_PAGTO FORMAT=DATETIME20.,
	 VLR_PAGO FORMAT=12.2 
 FROM BRCFDBCO.DRI_899_PARCELA_CFI_20110831
 WHERE DATA_PAGTO >= "01jan2008:00:00:00"dt
 ORDER BY PROC_DATE, REGIONAL, PRODUTO, CONTRATO, NUM_PARC, DTA_VCTO_PARC, 
	QTD_PRESTA, VLR_PARCELA, SALDO_CONTABIL, LIQUIDADA, DATA_PAGTO, VLR_PAGO;
QUIT;
PROC SQL;/*PARC_N*/
 CREATE TABLE COLL.PARC_20110831_AR AS SELECT ("31aug2011:00:00:00"dt) AS PROC_DATE,
	 REGIONAL FORMAT=6.,
	 PRODUTO FORMAT=$4.,
	 CONTRATO FORMAT=$12.,
	 NUM_PARC FORMAT=4.,
	 DTA_VCTO_PARC FORMAT=DATETIME20.,
	 QTD_PRESTA FORMAT=4.,
	 VLR_PARCELA FORMAT=12.2,
	 SALDO_CONTABIL FORMAT=12.2,
	 LIQUIDADA FORMAT=$1.,
	 DATA_PAGTO FORMAT=DATETIME20.,
	 VLR_PAGO FORMAT=12.2 
 FROM BRCFDBCO.DRI_899_PARCELA_CFI_20110831
 WHERE DATA_PAGTO is null
 ORDER BY PROC_DATE, REGIONAL, PRODUTO, CONTRATO, NUM_PARC, DTA_VCTO_PARC, 
	QTD_PRESTA, VLR_PARCELA, SALDO_CONTABIL, LIQUIDADA, DATA_PAGTO, VLR_PAGO;
QUIT;