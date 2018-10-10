LIBNAME RISCO '/brrisk_collect/cobranca/MIS/';

%LET DT_MIS_INI    = '01FEB2012:00:00:00'dt; /* primeiro dia do m�s de refer�ncia, sempre 1*/
%LET DT_MIS_FIM    = '29FEB2012:00:00:00'dt; /* ultimo dia do m�s de refer�ncia */
%LET DT_MIS_MES_ANT   = '31JAN2011:00:00:00'dt; /* ultimo dia util do m�s anterior ao de refer�ncia */
PROC SQL; /* 01 - Montar tabela de todos os acordos ('N' ou 'O') - na menor data */
	  CREATE TABLE WORK.W001_DAGRM_10 AS
	  SELECT MIN(BR_AGGR.MIS_DATE) FORMAT=DATETIME20. AS MIN_MIS_DATE
	 	   , BR_AGGR.ORG FORMAT=4.
		   , BR_AGGR.ACCOUNT_NUMBER FORMAT=$19.
		   , BR_AGGR.LOGO FORMAT=4.
		   , BR_AGGR.AGREEMENT_TYPE FORMAT=$1.
		   , BR_AGGR.AGREEMENT_DATE FORMAT=DATETIME20.
	  FROM   BRDBCON.DRI_076_ECS_AGGR_ED AS BR_AGGR
	  WHERE  BR_AGGR.MIS_DATE >= &DT_MIS_INI
	    AND  BR_AGGR.MIS_DATE <= &DT_MIS_FIM
		AND  BR_AGGR.AGREEMENT_DATE >= &DT_MIS_INI
	    AND  BR_AGGR.AGREEMENT_DATE <= &DT_MIS_FIM
	    AND  BR_AGGR.AGREEMENT_STATUS IN ('A')
		AND  BR_AGGR.AGREEMENT_TYPE IN ('N', 'O')
	  GROUP BY BR_AGGR.ORG
		     , BR_AGGR.ACCOUNT_NUMBER
		     , BR_AGGR.LOGO
		     , BR_AGGR.AGREEMENT_TYPE
		     , BR_AGGR.AGREEMENT_DATE;
	RUN;
PROC SQL; /* 02 - Montar tabela de todos os acordos ('N' ou 'O') - na maior data */
  CREATE TABLE WORK.W002_DAGRM_10 AS
  SELECT MAX(BR_AGGR.MIS_DATE) FORMAT=DATETIME20. AS MAX_MIS_DATE
 	   , BR_AGGR.ORG FORMAT=4.
	   , BR_AGGR.ACCOUNT_NUMBER FORMAT=$19.
	   , BR_AGGR.LOGO FORMAT=4.
	   , BR_AGGR.AGREEMENT_TYPE FORMAT=$1.
	   , BR_AGGR.AGREEMENT_DATE FORMAT=DATETIME20.
  FROM   BRDBCON.DRI_076_ECS_AGGR_ED AS BR_AGGR
  WHERE  BR_AGGR.MIS_DATE >= &DT_MIS_MES_ANT
    AND  BR_AGGR.MIS_DATE <= &DT_MIS_FIM
	AND  BR_AGGR.AGREEMENT_DATE >= &DT_MIS_INI
    AND  BR_AGGR.AGREEMENT_DATE <= &DT_MIS_FIM
    AND  BR_AGGR.AGREEMENT_STATUS IN ('P')
	AND  BR_AGGR.AGREEMENT_TYPE IN ('N', 'O')
  GROUP BY BR_AGGR.ORG
	     , BR_AGGR.ACCOUNT_NUMBER
	     , BR_AGGR.LOGO
	     , BR_AGGR.AGREEMENT_TYPE
	     , BR_AGGR.AGREEMENT_DATE;
RUN;
PROC SQL; /* 03 - Montar tabela com dados de descontos - todo o mes */
  CREATE TABLE WORK.W003_DAGRM_10 AS 
  SELECT BR_AGGR.MIS_DATE FORMAT=DATETIME20.
 	   , BR_AGGR.ORG FORMAT=4.
 	   , BR_AGGR.CARD_NUMBER FORMAT=$19.
	   , BR_AGGR.ACCOUNT_NUMBER FORMAT=$19.
	   , BR_AGGR.LOGO FORMAT=4.
	   , BR_AGGR.AGREEMENT_TYPE FORMAT=$1.
	   , BR_AGGR.AGREEMENT_DATE FORMAT=DATETIME20.
	   , BR_AGGR.AGREEMENT_AMOUNT FORMAT=15.2
	   , BR_AGGR.PROMISED_PAYMENT_DATE FORMAT=DATETIME20.
	   , BR_AGGR.PROMISED_AGREEMENT_AMOUNT FORMAT=15.2
	   , BR_AGGR.ACTUAL_PAYMENT_DATE FORMAT=DATETIME20.
	   , BR_AGGR.ACTUAL_PAYMENT_AMOUNT FORMAT=15.2
	   , BR_AGGR.AGREEMENT_STATUS FORMAT=$1.

	   , BR_AGGR.PRINCIPAL_BALANCE FORMAT=15.2
	   , BR_AGGR.INSTALLMENTS_WITHOUT_INTEREST FORMAT=15.2
	   , BR_AGGR.OTHER_TYPE_OF_INSTL_LOANS FORMAT=15.2
	   , BR_AGGR.INTEREST FORMAT=15.2
	   , BR_AGGR.SERVICE_CHARGES FORMAT=15.2
	   , BR_AGGR.LATE_CHARGES FORMAT=15.2
	   , BR_AGGR.MEMBERSHIP FORMAT=15.2
	   , BR_AGGR.OVER_LIMIT FORMAT=15.2
	   , BR_AGGR.INSURANCE FORMAT=15.2
	   , BR_AGGR.LATE_INTEREST FORMAT=15.2
	   , BR_AGGR.COLLECTION_FEE FORMAT=15.2
	   , BR_AGGR.NSF FORMAT=15.2

	   , BR_AGGR.PRINCIPAL_BALANCE_DISCOUNT FORMAT=15.2
	   , BR_AGGR.INSTALL_WITHOUT_INT_DISCOUNT FORMAT=15.2
	   , BR_AGGR.OTHER_TYPE_OF_INSAL_LOANS_DISC FORMAT=15.2
	   , BR_AGGR.INTEREST_DISCOUNT FORMAT=15.2
	   , BR_AGGR.SERVICE_CHARGES_DISCOUNT FORMAT=15.2
	   , BR_AGGR.LATE_CHARGES_DISCOUNT FORMAT=15.2
	   , BR_AGGR.MEMBERSHIP_DISCOUNT FORMAT=15.2
	   , BR_AGGR.OVER_LIMIT_DISCOUNT FORMAT=15.2
	   , BR_AGGR.INSURANCE_DISCOUNT FORMAT=15.2
	   , BR_AGGR.LATE_INTEREST_DISCOUNT FORMAT=15.2
	   , BR_AGGR.COLLECTION_FEE_DISCOUNT FORMAT=15.2
	   , BR_AGGR.NSF_DISCOUNT FORMAT=15.2

	   , BR_AGGR.PRINCIPAL_BALANCE_DISCOUNT1 FORMAT=15.2
	   , BR_AGGR.INSTL_WITHOUT_INT_DISCOUNT FORMAT=15.2
	   , BR_AGGR.OTHER_TYPE_OF_INSTL_LOANS_DISC FORMAT=15.2
	   , BR_AGGR.INTEREST_DISCOUNT1 FORMAT=15.2
	   , BR_AGGR.SERVICE_CHARGES_DISCOUNT1 FORMAT=15.2
	   , BR_AGGR.LATE_CHARGES_DISCOUNT1 FORMAT=15.2
	   , BR_AGGR.MEMBERSHIP_DISCOUNT1 FORMAT=15.2
	   , BR_AGGR.OVER_LIMIT_DISCOUNT1 FORMAT=15.2
	   , BR_AGGR.INSURANCE_DISCOUNT1 FORMAT=15.2
	   , BR_AGGR.LATE_INTEREST_DISCOUNT1 FORMAT=15.2
	   , BR_AGGR.COLLECTION_FEE_DISCOUNT1 FORMAT=15.2
	   , BR_AGGR.NSF_DISCOUNT1 FORMAT=15.2

	   , BR_AGGR.IOF_AMT1 FORMAT=15.2
	   , BR_AGGR.IOF_AMT2 FORMAT=15.2
	   , BR_AGGR.IOF_AMT1A FORMAT=15.2
	   , BR_AGGR.IOF_AMT2A FORMAT=15.2
	   , BR_AGGR.ICR_AMT1 FORMAT=15.2
	   , BR_AGGR.ICR_AMT2 FORMAT=15.2
	   , BR_AGGR.CURR_BAL_ICR1 FORMAT=15.2
	   , BR_AGGR.CURR_BAL_ICR2 FORMAT=15.2

  	   , BR_AGGR.OPERATOR_ID FORMAT=$8.
  FROM   BRDBCON.DRI_076_ECS_AGGR_ED AS BR_AGGR
  WHERE  BR_AGGR.MIS_DATE >= &DT_MIS_MES_ANT
    AND  BR_AGGR.MIS_DATE <= &DT_MIS_FIM
    AND  BR_AGGR.AGREEMENT_STATUS IN ('A', 'P')
	AND  BR_AGGR.AGREEMENT_TYPE IN ('N', 'O');
RUN;
PROC SQL; /* 04 - Montar tabela de todos os acordos ('N' ou 'O') - na menor data */
  CREATE TABLE WORK.W004_DAGRM_10 AS
  SELECT W001.MIN_MIS_DATE FORMAT=DATETIME20. AS MIS_DATE_A
       , W002.MAX_MIS_DATE FORMAT=DATETIME20. AS MIS_DATE_P
 	   , W001.ORG FORMAT=4.
	   , W001.ACCOUNT_NUMBER FORMAT=$19.
	   , W001.LOGO FORMAT=4.
	   , W001.AGREEMENT_TYPE FORMAT=$1.
	   , W001.AGREEMENT_DATE FORMAT=DATETIME20.
  FROM   WORK.W001_DAGRM_10 AS W001
   LEFT  JOIN WORK.W002_DAGRM_10 AS W002
     ON  W001.ACCOUNT_NUMBER = W002.ACCOUNT_NUMBER
	AND  W001.ORG = W002.ORG
	AND  W001.LOGO = W002.LOGO
	AND  W001.AGREEMENT_TYPE = W002.AGREEMENT_TYPE
	AND  W001.AGREEMENT_DATE = W002.AGREEMENT_DATE;
RUN;
PROC SQL; /* 05 - Montar tabela com dados de descontos - data MINIMA ATIVADO */
  CREATE TABLE WORK.DESCONTO_CARD AS 
  SELECT DATEPART(BR_AGGR.MIS_DATE) FORMAT=yymmdd10. AS MIS_DATE_A
 	   , BR_AGGR.ORG FORMAT=4.
 	   , BR_AGGR.CARD_NUMBER FORMAT=$19.
	   , BR_AGGR.ACCOUNT_NUMBER FORMAT=$19.
	   , BR_AGGR.LOGO FORMAT=4.
	   , BR_AGGR.AGREEMENT_TYPE FORMAT=$1.

       , DATEPART(BR_AGGR.AGREEMENT_DATE) FORMAT=yymmdd10. AS AGREEMENT_DATE
	   , BR_AGGR.AGREEMENT_AMOUNT FORMAT=15.2
	   , DATEPART(BR_AGGR.PROMISED_PAYMENT_DATE) FORMAT=yymmdd10. AS PROMISED_PAYMENT_DATE
	   , BR_AGGR.PROMISED_AGREEMENT_AMOUNT FORMAT=15.2
	   , DATEPART(BR_AGGR.ACTUAL_PAYMENT_DATE) FORMAT=yymmdd10. AS ACTUAL_PAYMENT_DATE
	   , BR_AGGR.ACTUAL_PAYMENT_AMOUNT FORMAT=15.2
	   , BR_AGGR.AGREEMENT_STATUS FORMAT=$1.

	   , BR_AGGR.PRINCIPAL_BALANCE FORMAT=15.2
	   , BR_AGGR.INSTALLMENTS_WITHOUT_INTEREST FORMAT=15.2
	   , BR_AGGR.OTHER_TYPE_OF_INSTL_LOANS FORMAT=15.2
	   , BR_AGGR.INTEREST FORMAT=15.2
	   , BR_AGGR.SERVICE_CHARGES FORMAT=15.2
	   , BR_AGGR.LATE_CHARGES FORMAT=15.2
	   , BR_AGGR.MEMBERSHIP FORMAT=15.2
	   , BR_AGGR.OVER_LIMIT FORMAT=15.2
	   , BR_AGGR.INSURANCE FORMAT=15.2
	   , BR_AGGR.LATE_INTEREST FORMAT=15.2
	   , BR_AGGR.COLLECTION_FEE FORMAT=15.2
	   , BR_AGGR.NSF FORMAT=15.2

	   , BR_AGGR.PRINCIPAL_BALANCE_DISCOUNT FORMAT=15.2
	   , BR_AGGR.INSTALL_WITHOUT_INT_DISCOUNT FORMAT=15.2
	   , BR_AGGR.OTHER_TYPE_OF_INSAL_LOANS_DISC FORMAT=15.2
	   , BR_AGGR.INTEREST_DISCOUNT FORMAT=15.2
	   , BR_AGGR.SERVICE_CHARGES_DISCOUNT FORMAT=15.2
	   , BR_AGGR.LATE_CHARGES_DISCOUNT FORMAT=15.2
	   , BR_AGGR.MEMBERSHIP_DISCOUNT FORMAT=15.2
	   , BR_AGGR.OVER_LIMIT_DISCOUNT FORMAT=15.2
	   , BR_AGGR.INSURANCE_DISCOUNT FORMAT=15.2
	   , BR_AGGR.LATE_INTEREST_DISCOUNT FORMAT=15.2
	   , BR_AGGR.COLLECTION_FEE_DISCOUNT FORMAT=15.2
	   , BR_AGGR.NSF_DISCOUNT FORMAT=15.2

	   , BR_AGGR.PRINCIPAL_BALANCE_DISCOUNT1 FORMAT=15.2
	   , BR_AGGR.INSTL_WITHOUT_INT_DISCOUNT FORMAT=15.2
	   , BR_AGGR.OTHER_TYPE_OF_INSTL_LOANS_DISC FORMAT=15.2
	   , BR_AGGR.INTEREST_DISCOUNT1 FORMAT=15.2
	   , BR_AGGR.SERVICE_CHARGES_DISCOUNT1 FORMAT=15.2
	   , BR_AGGR.LATE_CHARGES_DISCOUNT1 FORMAT=15.2
	   , BR_AGGR.MEMBERSHIP_DISCOUNT1 FORMAT=15.2
	   , BR_AGGR.OVER_LIMIT_DISCOUNT1 FORMAT=15.2
	   , BR_AGGR.INSURANCE_DISCOUNT1 FORMAT=15.2
	   , BR_AGGR.LATE_INTEREST_DISCOUNT1 FORMAT=15.2
	   , BR_AGGR.COLLECTION_FEE_DISCOUNT1 FORMAT=15.2
	   , BR_AGGR.NSF_DISCOUNT1 FORMAT=15.2

	   , BR_AGGR.IOF_AMT1 FORMAT=15.2
	   , BR_AGGR.IOF_AMT2 FORMAT=15.2
	   , BR_AGGR.IOF_AMT1A FORMAT=15.2
	   , BR_AGGR.IOF_AMT2A FORMAT=15.2
	   , BR_AGGR.ICR_AMT1 FORMAT=15.2
	   , BR_AGGR.ICR_AMT2 FORMAT=15.2
	   , BR_AGGR.CURR_BAL_ICR1 FORMAT=15.2
	   , BR_AGGR.CURR_BAL_ICR2 FORMAT=15.2

  	   , BR_AGGR.OPERATOR_ID FORMAT=$8.

       , DATEPART(BR_AGGRP.MIS_DATE) FORMAT=yymmdd10. AS MIS_DATE_P
 	   , BR_AGGRP.ORG FORMAT=4. AS ORG_P
 	   , BR_AGGRP.CARD_NUMBER FORMAT=$19. AS CARD_NUMBER_P
	   , BR_AGGRP.ACCOUNT_NUMBER FORMAT=$19. AS ACCOUNT_NUMBER_P
	   , BR_AGGRP.LOGO FORMAT=4. AS LOGO_P
	   , BR_AGGRP.AGREEMENT_TYPE FORMAT=$1. AS AGREEMENT_TYPE_P

       , DATEPART(BR_AGGRP.AGREEMENT_DATE) FORMAT=yymmdd10. AS AGREEMENT_DATE_P
	   , BR_AGGRP.AGREEMENT_AMOUNT FORMAT=15.2 AS AGREEMENT_AMOUNT_P
	   , DATEPART(BR_AGGRP.PROMISED_PAYMENT_DATE) FORMAT=yymmdd10. AS PROMISED_PAYMENT_DATE_P
	   , BR_AGGRP.PROMISED_AGREEMENT_AMOUNT FORMAT=15.2 AS PROMISED_AGREEMENT_AMOUNT_P
	   , DATEPART(BR_AGGRP.ACTUAL_PAYMENT_DATE) FORMAT=yymmdd10. AS ACTUAL_PAYMENT_DATE_P
	   , BR_AGGRP.ACTUAL_PAYMENT_AMOUNT FORMAT=15.2 AS ACTUAL_PAYMENT_AMOUNT_P
	   , BR_AGGRP.AGREEMENT_STATUS FORMAT=$1. AS AGREEMENT_STATUS_P

	   , BR_AGGRP.PRINCIPAL_BALANCE FORMAT=15.2 AS PRINCIPAL_BALANCE_P
	   , BR_AGGRP.INSTALLMENTS_WITHOUT_INTEREST FORMAT=15.2 AS INSTALLMENTS_WITHOUT_INTEREST_P
	   , BR_AGGRP.OTHER_TYPE_OF_INSTL_LOANS FORMAT=15.2 AS OTHER_TYPE_OF_INSTL_LOANS_P
	   , BR_AGGRP.INTEREST FORMAT=15.2 AS INTEREST_P
	   , BR_AGGRP.SERVICE_CHARGES FORMAT=15.2 AS SERVICE_CHARGES_P
	   , BR_AGGRP.LATE_CHARGES FORMAT=15.2 AS LATE_CHARGES_P
	   , BR_AGGRP.MEMBERSHIP FORMAT=15.2 AS MEMBERSHIP_P
	   , BR_AGGRP.OVER_LIMIT FORMAT=15.2 AS OVER_LIMIT_P
	   , BR_AGGRP.INSURANCE FORMAT=15.2 AS INSURANCE_P
	   , BR_AGGRP.LATE_INTEREST FORMAT=15.2 AS LATE_INTEREST_P
	   , BR_AGGRP.COLLECTION_FEE FORMAT=15.2 AS COLLECTION_FEE_P
	   , BR_AGGRP.NSF FORMAT=15.2 AS NSF_P

	   , BR_AGGRP.PRINCIPAL_BALANCE_DISCOUNT FORMAT=15.2 AS PRINCIPAL_BALANCE_DISCOUNT_P
	   , BR_AGGRP.INSTALL_WITHOUT_INT_DISCOUNT FORMAT=15.2 AS INSTALL_WITHOUT_INT_DISCOUNT_P
	   , BR_AGGRP.OTHER_TYPE_OF_INSAL_LOANS_DISC FORMAT=15.2 AS OTHER_TYPE_OF_INSAL_LOANS_DISC_P
	   , BR_AGGRP.INTEREST_DISCOUNT FORMAT=15.2 AS INTEREST_DISCOUNT_P
	   , BR_AGGRP.SERVICE_CHARGES_DISCOUNT FORMAT=15.2 AS SERVICE_CHARGES_DISCOUNT_P
	   , BR_AGGRP.LATE_CHARGES_DISCOUNT FORMAT=15.2 AS LATE_CHARGES_DISCOUNT_P
	   , BR_AGGRP.MEMBERSHIP_DISCOUNT FORMAT=15.2 AS MEMBERSHIP_DISCOUNT_P
	   , BR_AGGRP.OVER_LIMIT_DISCOUNT FORMAT=15.2 AS OVER_LIMIT_DISCOUNT_P
	   , BR_AGGRP.INSURANCE_DISCOUNT FORMAT=15.2 AS INSURANCE_DISCOUNT_P
	   , BR_AGGRP.LATE_INTEREST_DISCOUNT FORMAT=15.2 AS LATE_INTEREST_DISCOUNT_P
	   , BR_AGGRP.COLLECTION_FEE_DISCOUNT FORMAT=15.2 AS COLLECTION_FEE_DISCOUNT_P
	   , BR_AGGRP.NSF_DISCOUNT FORMAT=15.2 AS NSF_DISCOUNT_P

	   , BR_AGGRP.PRINCIPAL_BALANCE_DISCOUNT1 FORMAT=15.2 AS PRINCIPAL_BALANCE_DISCOUNT1_P
	   , BR_AGGRP.INSTL_WITHOUT_INT_DISCOUNT FORMAT=15.2 AS INSTL_WITHOUT_INT_DISCOUNT_P
	   , BR_AGGRP.OTHER_TYPE_OF_INSTL_LOANS_DISC FORMAT=15.2 AS OTHER_TYPE_OF_INSTL_LOANS_DISC_P
	   , BR_AGGRP.INTEREST_DISCOUNT1 FORMAT=15.2 AS INTEREST_DISCOUNT1_P
	   , BR_AGGRP.SERVICE_CHARGES_DISCOUNT1 FORMAT=15.2 AS SERVICE_CHARGES_DISCOUNT1_P
	   , BR_AGGRP.LATE_CHARGES_DISCOUNT1 FORMAT=15.2 AS LATE_CHARGES_DISCOUNT1_P
	   , BR_AGGRP.MEMBERSHIP_DISCOUNT1 FORMAT=15.2 AS MEMBERSHIP_DISCOUNT1_P
	   , BR_AGGRP.OVER_LIMIT_DISCOUNT1 FORMAT=15.2 AS OVER_LIMIT_DISCOUNT1_P
	   , BR_AGGRP.INSURANCE_DISCOUNT1 FORMAT=15.2 AS INSURANCE_DISCOUNT1_P
	   , BR_AGGRP.LATE_INTEREST_DISCOUNT1 FORMAT=15.2 AS LATE_INTEREST_DISCOUNT1_P
	   , BR_AGGRP.COLLECTION_FEE_DISCOUNT1 FORMAT=15.2 AS COLLECTION_FEE_DISCOUNT1_P
	   , BR_AGGRP.NSF_DISCOUNT1 FORMAT=15.2 AS NSF_DISCOUNT1_P

	   , BR_AGGRP.IOF_AMT1 FORMAT=15.2 AS IOF_AMT1_P
	   , BR_AGGRP.IOF_AMT2 FORMAT=15.2 AS IOF_AMT2_P
	   , BR_AGGRP.IOF_AMT1A FORMAT=15.2 AS IOF_AMT1A_P
	   , BR_AGGRP.IOF_AMT2A FORMAT=15.2 AS IOF_AMT2A_P
	   , BR_AGGRP.ICR_AMT1 FORMAT=15.2 AS ICR_AMT1_P
	   , BR_AGGRP.ICR_AMT2 FORMAT=15.2 AS ICR_AMT2_P
	   , BR_AGGRP.CURR_BAL_ICR1 FORMAT=15.2 AS CURR_BAL_ICR1_P
	   , BR_AGGRP.CURR_BAL_ICR2 FORMAT=15.2 AS CURR_BAL_ICR2_P

  	   , BR_AGGRP.OPERATOR_ID FORMAT=$8. AS OPERATOR_ID_P
  FROM  (WORK.W004_DAGRM_10 AS W004
   INNER JOIN WORK.W003_DAGRM_10 AS BR_AGGR
      ON W004.MIS_DATE_A = BR_AGGR.MIS_DATE
 	 AND W004.ORG = BR_AGGR.ORG
	 AND W004.ACCOUNT_NUMBER = BR_AGGR.ACCOUNT_NUMBER
	 AND W004.LOGO = BR_AGGR.LOGO
	 AND W004.AGREEMENT_TYPE = BR_AGGR.AGREEMENT_TYPE
	 AND W004.AGREEMENT_DATE = BR_AGGR.AGREEMENT_DATE)
    LEFT JOIN WORK.W003_DAGRM_10 AS BR_AGGRP
      ON W004.MIS_DATE_P = BR_AGGRP.MIS_DATE
 	 AND W004.ORG = BR_AGGRP.ORG
	 AND W004.ACCOUNT_NUMBER = BR_AGGRP.ACCOUNT_NUMBER
	 AND W004.LOGO = BR_AGGRP.LOGO
	 AND W004.AGREEMENT_TYPE = BR_AGGRP.AGREEMENT_TYPE
	 AND W004.AGREEMENT_DATE = BR_AGGRP.AGREEMENT_DATE;
RUN;


*/PROC SQL; /* 06 - Montar tabela com dados de descontos - MOB */
 ' CREATE TABLE WORK.W006_DAGRM_10 AS 
  SELECT 
		MIS_DATE,
		EDW_BS_DATE_OPENED,
		EDW_BS_ACCT,
		EDW_BS_USER_CODE_6

  FROM  WORK.W005_DAGRM_10 W005

	INNER JOIN BRDBCON.DRI_076_ECS_AMBS_ED ECS_AMBS

		ON W005.CARD_NUMBER = ECS_AMBS.EDW_BS_ACCT;
RUN;