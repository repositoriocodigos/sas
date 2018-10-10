%MACRO GUNZIP(ARQUIVO);
     DATA _NULL_;
          call system("cd /sasdata/cobranca/GLOBALSYSTEM/CONTROLDESK/CAR");
          call system("cp /sasdata/cobranca/GLOBALSYSTEM/CONTROLDESK/CAR/&Arquivo. /sasdata/cobranca/GLOBALSYSTEM/CONTROLDESK/CAR/&Arquivo.");
          call system("cd /sasdata/cobranca/GLOBALSYSTEM/CONTROLDESK/CAR");
          call system("ls -sSh | gunzip -9 &Arquivo.");
          call system("chmod 755 &Arquivo.");
     RUN;
%MEND;

*TROCAR O NOME DO ARQUIVO PARA DESCOMPACTAR;
%Gunzip(CAR_FIXA_PJ_MAS_20160705.txt.gz);
%Gunzip(CAR_MOVEL_PF_20160626.txt.gz);
%Gunzip(CAR_MOVEL_PF_20160630.txt.gz);
%Gunzip(CAR_MOVEL_PJ_CORP_20160626.txt.gz);
%Gunzip(CAR_MOVEL_PJ_CORP_20160630.txt.gz);
%Gunzip(CAR_MOVEL_PJ_MAS_20160626.txt.gz);
%Gunzip(CAR_MOVEL_PJ_MAS_20160630.txt.gz);

DATA CAR.CAR_FIXA_PJ_MAS_20160705 (COMPRESS =YES REUSE =YES);
 INFILE "/sasdata/cobranca/GLOBALSYSTEM/CONTROLDESK/CAR/CAR_FIXA_PJ_MAS_20160705.txt" 
  DLM=";" LRECL=32000 FIRSTOBS=2 OBS= MAX DSD MISSOVER;

INPUT
		ACORDO           : $CHAR1.
        AGING_ATUAL      : ?? BEST5.
        AGING_ORIGINAL   : ?? BEST4.
        CDCLIENTE        : $CHAR1.
        CDCONTA          : $CHAR1.
        CICLO            : ?? BEST2.
        CLASSE           : $CHAR2.
        CLASSIFICACAO    : $CHAR20.
        CLASSSERV        : $CHAR4.
        CLIENTE          : $CHAR40.
        COD_SERV         : ?? BEST5.
        CONTA            : $CHAR10.
        CPF_CNPJ         : $CHAR14.
        DA               : $CHAR3.
        DOCUMENTO_SAP    : $CHAR10.
        DT_CADASTRO      : ?? DDMMYY10.
        DTCONTA          : $CHAR7.
        DTCORTE          : ?? DDMMYY10.
        DTWO             : $CHAR1.
        EMPRESA          : $CHAR13.
        FAIXA_ATUAL      : $CHAR21.
        FAIXA_ORIGINAL   : $CHAR21.
        FILTRO           : $CHAR1.
        GRUPO_DE_EMPRESAS : $CHAR1.
        ID_CLIENTE       : $CHAR10.
        IP               : $CHAR3.
        NMFATURA         : $CHAR1.
        NRC              : ?? BEST11.
        OPERACAO         : $CHAR11.
        ORIGEM           : $CHAR12.
        OVERBILLING      : ?? COMMAX12.
        PARCEL_PDD       : $CHAR3.
        PARCELAMENTO     : $CHAR5.
        PERDA            : $CHAR1.
        PF_PJ            : $CHAR1.
        PRODUTO_ORIGEM   : $CHAR13.
        PROVISAO         : $CHAR13.
        RAIZ_CPF_CNPJ    : ?? BEST9.
        RECEBIVEL        : $CHAR15.
        REGI_AGR         : $CHAR10.
        REGRA_FX_ENT     : $CHAR19.
        SALDO_CAR        : ?? COMMAX12.2
        SALDO_FX_ENT     : ?? COMMAX10.
        SALDO_PDD        : ?? COMMAX12.
        SALDO_TERCEIROS  : ?? COMMAX9.
        SALDO_WO         : ?? COMMAX12.
        SEG_CLIENTE      : ?? BEST1.
        SEG_DESCR        : $CHAR11.
        SERVTERCEIROS    : $CHAR3.
        TEL              : $CHAR14.
        TERM_RET_PDD     : $CHAR3.
        TIPO_CLIENTE     : $CHAR13.
        TITULO           : $CHAR12.
        UF               : $CHAR2.
        VENC_ATUAL       : ?? DDMMYY10.
        VENC_ORIGINAL    : ?? DDMMYY10.
        WO               : $CHAR1.
        BILLING          : $CHAR14.
        STATUS           : $CHAR1.
        NOTA_FISCAL      : $CHAR10.
        PARCELA          : $CHAR1.
        DT_PROCESS       : ?? DDMMYY10.
        REGRA_PDD        : $CHAR19.
        AGING_CORTE      : ?? BEST5.
        FAIXA_CORTE      : $CHAR21.
        SEG_DESCR_CLASSE : $CHAR11.
        DOC_FAT          : $CHAR10.
        FILIAL           : $CHAR3.
        LJ_CLI           : $CHAR3.
        COD_CLI          : $CHAR6.; 

FORMAT 
			DT_CADASTRO DDMMYY10. 
			VENC_ATUAL DDMMYY10.
		    VENC_ORIGINAL DDMMYY10.
			DTCORTE	DDMMYY10.
			DT_PROCESS DDMMYY10.; 

RUN;
%MEND;
%BASE(FIXA_PJ_MAS_20160630) ;
%BASE(MOVEL_PJ_MAS_20160630) ;
%BASE(MOVEL_PJ_MAS_20160626) ;
%BASE(MOVEL_PJ_CORP_20160630) ;
%BASE(MOVEL_PJ_CORP_20160626) ;
%BASE(MOVEL_PF_20160630) ;
%BASE(MOVEL_PF_20160626) ;

