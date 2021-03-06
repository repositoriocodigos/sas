PROC SQL;/*GERA TABLE*/
 CREATE TABLE SASUSER.AC_CITICARDS_TEMP AS SELECT DRI_076_TRIAD_DELQ_ED.TFDWH_ACCT_NUM, DRI_076_TRIAD_DELQ_ED.TFDWH_PROC_DATE FORMAT=DATETIME20.,
	 (COUNT(DRI_076_TRIAD_DELQ_ED.TFDWH_ACCT_NUM)) AS ACCT_NUM,
	 DRI_076_TRIAD_DELQ_ED.TFDWH_D_BLK_CODE FORMAT=$3.,
	 DRI_076_TRIAD_DELQ_ED.TFDWH_D_STMT_INSERT FORMAT=$5. 
 FROM BRDBCON.DRI_076_TRIAD_DELQ_ED AS DRI_076_TRIAD_DELQ_ED
 WHERE ( DRI_076_TRIAD_DELQ_ED.TFDWH_PROC_DATE BETWEEN '01FEB2012:00:00:00'dt and '29FEB2012:00:00:00'dt
		AND ( DRI_076_TRIAD_DELQ_ED.TFDWH_D_COLL_IND = "850" AND
( DRI_076_TRIAD_DELQ_ED.TFDWH_SCEN_ID = 800 AND
DRI_076_TRIAD_DELQ_ED.TFDWH_SPID IN (1, 2, 3, 4) ) ) )
 GROUP BY DRI_076_TRIAD_DELQ_ED.TFDWH_ACCT_NUM, DRI_076_TRIAD_DELQ_ED.TFDWH_PROC_DATE, DRI_076_TRIAD_DELQ_ED.TFDWH_D_STMT_INSERT, DRI_076_TRIAD_DELQ_ED.TFDWH_D_BLK_CODE;
QUIT;
PROC SQL;/*RESULTADO FINAL*/
 CREATE TABLE SASUSER.AC_CITICARDS AS SELECT (COUNT(AC_CITICARDS_TEMP.TFDWH_ACCT_NUM)) AS COUNT
 FROM SASUSER.AC_CITICARDS_TEMP AS AC_CITICARDS_TEMP;
QUIT;
PROC DATASETS/* DROP TABLE */

LIB = SASUSER;

DELETE AC_CITICARDS_TEMP;

RUN;