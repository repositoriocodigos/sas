
%let Data = '04oct2012'd;

proc sql; 		         /******************C A R D S********************/
create table Carteira_X09_cards as select
a.MIS_DATE,
a.C_P_LOCATION_CODE,
a.C_P_ACCT_NBR,
a.C_P_RESPONSIBLE_COLLECTOR_ID,
a.C_P_CACS_STATE_CODE
from brdbcon.DRI_076_ECS_COLL_PRI_ED as a
where a.MIS_DATE  = &Data and a.C_P_CACS_STATE_CODE like ("%09");
run;

proc sql;
create table Extract_cards as select
a.MIS_DATE,
a.C_E_LOCATION_CODE,
a.C_E_ACCT_NBR,
a.C_E_SERVICE_TYPE,
a.C_E_CUST_INFO_NBR,
a.C_E_TOTAL_DELINQ_AMT,
a.C_E_PHONE_NBR_1,
a.C_E_PHONE_NBR_2
from brdbcon.DRI_076_ECS_COLL_EXT_ED_VG3 as a
where a.MIS_DATE  = &Data;
run;

proc sql;
create table sasuser.tb_X09_cards as select *
from Carteira_X09_cards as a inner join Extract_cards as b
on a.C_P_ACCT_NBR = b.C_E_ACCT_NBR;
run;

proc sql; 				/******************R E T A I L********************/
create table sasuser.tb_X09_retail as select
a.MIS_DATE,
a.LOCATION_CODE,
a.ACCT_NUM,
a.CACS_FUNCTION_CODE,
a.CACS_STATE_NUMBER,
a.TOTAL_DELINQ_AMT,
a.ORIGINAL_TERM,
a.CUSTOMER_INFO_NUMBER,
a.PHONE_NUMBER_DATA_1,
a.PHONE_NUMBER_DATA_2
from nwbrrcon.DRI_076_R_CACS_EXT_PRI_DG3 as a
where a.MIS_DATE = &Data and a.LOCATION_CODE = "010101" and a.CACS_STATE_NUMBER = "09";
run;

proc sql; 	       /******************F I N A N C E I R A ********************/
create table sasuser.tb_X09_financeira as select
a.MIS_DATE,
a.LOCATION_CODE,
a.ACCT_NUM,
a.CACS_FUNCTION_CODE,
a.CACS_STATE_NUMBER,
a.TOTAL_DELINQ_AMT,
a.ORIGINAL_TERM,
a.CUSTOMER_INFO_NUMBER,
a.PHONE_NUMBER_DATA_1,
a.PHONE_NUMBER_DATA_2
from nwbrrcon.DRI_076_R_CACS_EXT_PRI_DG3 as a
where a.MIS_DATE = &Data and a.LOCATION_CODE = "010701" and a.CACS_STATE_NUMBER = "09";
run;