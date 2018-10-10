PROC SQL;/*GERAR TABLE TEMP*/
 CREATE TABLE SASUSER.EPD_CARDS_TEMP AS SELECT DRI_076_CARD_MASTER_EM_FACT.BS_ORG FORMAT=4.,
	 (COUNT(DRI_076_CARD_MASTER_EM_FACT.DIM_ACCOUNT_ID)) AS ACCOUNTS 
 FROM BRDBCON.DRI_076_CARD_MASTER_EM_FACT AS DRI_076_CARD_MASTER_EM_FACT
 WHERE ( DRI_076_CARD_MASTER_EM_FACT.MIS_DATE = '29FEB2012:00:00:00'dt 
	AND ( DRI_076_CARD_MASTER_EM_FACT.DW_DAYS_PAST_DUE > 0 AND DRI_076_CARD_MASTER_EM_FACT.BS_MONTH_SINCE_DATE_OPENED IN (1, 3, 0, 5, 4, 2) ) )
 GROUP BY DRI_076_CARD_MASTER_EM_FACT.BS_ORG;
RUN;
PROC SQL;/*RESULTADO FINAL*/
 CREATE TABLE SASUSER.EPD_CARDS AS SELECT (SUM(EPD_CARDS_TEMP.ACCOUNTS)) AS EPD_CARDS 
 FROM SASUSER.EPD_CARDS_TEMP AS EPD_CARDS_TEMP;
RUN;
PROC DATASETS/* DROP TABLE */

LIB = SASUSER;

DELETE EPD_CARDS_TEMP;

RUN;