**************************************************************************************************************;
******* ATENÇÃO: CERTIFICAR O CAMINHO (G:\COMUM\HISTÓRICO) E RENOMEAR OS ARQUIVOS ANTES DE COMEÇAR !!! *******;
**************************************************************************************************************;

Title;
ODS NoProcTitle;
Options
   Compress=Yes
   Details
   FullSTimer
   LineSize=145
   MError
   MLogic
   MPrint
   MsgLevel=i
   NoDate
   NoNumber
   PageSize=MAX
   Reuse=Yes
   SortSize=2G
   SumSize=2G
   Symbolgen
   Yearcutoff=1920;

%macro Limpa(Var);
   &Var. = tranwrd(&Var., '   ', ' ');
   &Var. = trim(compbl(&Var.));

   &Var. = translate(&Var.,"AEIOU", "ÁÉÍÓÚ");
   &Var. = translate(&Var.,"AEIOU", "ÀÈÌÒÙ");
   &Var. = translate(&Var.,"AEIOU", "ÂÊÎÔÛ");
   &Var. = translate(&Var.,"AEIOU", "ÄËÏÖÜ");
   &Var. = translate(&Var.,"CAON", "ÇÃÕÑ");

   &Var. = translate(&Var.,"aeiou", "áéíóú");
   &Var. = translate(&Var.,"aeiou", "àèìòù");
   &Var. = translate(&Var.,"aeiou", "âêîôû");
   &Var. = translate(&Var.,"aeiou", "äëïöü");
   &Var. = translate(&Var.,"caon", "çãõñ");
%mend Limpa;

%macro Ajeita(Var);
   &Var. = Propcase(trim(compbl(&Var)));
   &Var. = tranwrd(&Var,' Da ',' da ');
   &Var. = tranwrd(&Var,' De ',' de ');
   &Var. = tranwrd(&Var,' Do ',' do ');
   &Var. = tranwrd(&Var,' Das ',' das ');
   &Var. = tranwrd(&Var,' Dos ',' dos ');
%mend Ajeita;

Proc Datasets Library=work MemType=Data;
Quit;

Title;

Proc Setinit NoAlias;
Run;

%let caminho = G:\Comum\Histórico\ ;

Data _NULL_;
   dt = put(date(),ddmmyy10.)||' '||put(time(),time12.3);
   Put 'Início do Processo: ' dt;
Run;


**********************************************;
******* Dados do arquivo de Fraudes... *******;
**********************************************;

Data work.Fraudes(Compress=Yes Reuse=Yes Label="Base de Fraudadores");
   %let _EFIERR_ = 0; /* set the ERROR detection macro variable */
   Infile "&caminho.Fraude.txt" delimiter = ';' MISSOVER DSD lrecl=32767 firstobs=2 ;
      informat CNPJ $15. ;
      informat Cliente $40. ;
      informat Centro_de_Custo $20. ;
      informat Motivo $30. ;
      informat Data_Inicio ddmmyy10. ;
      informat Data_Termino ddmmyy10. ;
      format CNPJ $15. ;
      format Cliente $40. ;
      format Centro_de_Custo $20. ;
      format Motivo $30. ;
      format Data_Inicio ddmmyy10. ;
      format Data_Termino ddmmyy10. ;
   Input
      CNPJ $
      Cliente $
      Centro_de_Custo $
      Motivo $
      Data_Inicio
      Data_Termino
   ;
   %Limpa(Cliente);
   %Limpa(Motivo);
   %Ajeita(Motivo);
   if _ERROR_ then call symputx('_EFIERR_',1);  /* set ERROR detection macro variable */
Run;

Proc Sort Data=work.Fraudes(Compress=Yes Reuse=Yes Label="Base de Fraudadores") SortSize=2G;
   By CNPJ descending Centro_de_Custo;
Run;

Data work.Dups_Fraudes(Compress=Yes Reuse=Yes Label="Duplicidades no Arquivo de Fraudes");
   Set work.Fraudes;
   By CNPJ;
   If first.CNPJ ne last.CNPJ;
Run;

Proc Sort Data=work.Fraudes(Compress=Yes Reuse=Yes Label="Base de Fraudadores") SortSize=2G NoDupKey;
   By CNPJ;
   Where trim(CNPJ) ne '';
Run;


**********************************************************;
******* Dados do Arquivo de Contestações Jurídicas *******;
**********************************************************;

Data work.Juridico(Compress=Yes Reuse=Yes Label="Base de Contestações do Jurídico");
   %let _EFIERR_ = 0; /* set the ERROR detection macro variable */
   Infile "&caminho.Juridico.txt" delimiter = ';' MISSOVER DSD lrecl=32767 firstobs=2 ;
      informat CNPJ $15. ;
      informat UF $2. ;
      informat Ocorr best32. ;
      informat Data anydtdtm40. ;
      informat Solicitante $40. ;
      informat Motivo $38. ;
      informat Comentarios $52. ;
      format CNPJ $15. ;
      format UF $2. ;
      format Ocorr best12. ;
      format Data ddmmyy10. ;
      format Solicitante $40. ;
      format Motivo $38. ;
      format Comentarios $52. ;
   Input
      CNPJ $
      UF $
      Ocorr
      Data
      Solicitante $
      Motivo $
      Comentarios $
   ;
   %Limpa(Solicitante);
   %Limpa(Comentarios);
   %Ajeita(Solicitante);
   %Ajeita(Comentarios);
   Solicitante = Tranwrd(Solicitante,'Shu','SHU');
   Comentarios = Tranwrd(Comentarios,'Shu','SHU');
   if _ERROR_ then call symputx('_EFIERR_',1);  /* set ERROR detection macro variable */
Run;

Proc Sort Data=work.Juridico(Compress=Yes Reuse=Yes Label="Base de Contestações do Jurídico") SortSize=2G;
   By CNPJ Motivo Data descending Comentarios;
Run;

Data work.Dups_Juridico(Compress=Yes Reuse=Yes Label="Duplicações na Base do Jurídico");
   Set work.Juridico;
   By CNPJ;
   If first.CNPJ ne last.CNPJ;
Run;

Proc Sort Data=work.Juridico(Compress=Yes Reuse=Yes Label="Base de Contestações do Jurídico") SortSize=2G NoDupKey;
   By CNPJ;
   Where trim(CNPJ) ne '';
Run;


*******************************************************;
*******   Importacao do Arquivo de Historico    *******;
******* Atenção à pontuação dos Campos de Valor *******;
*******************************************************;

Data Work.Historico(Compress=Yes Reuse=Yes Label='Relatório Histórico de Escritório');
   Infile "&caminho.Historico.txt" delimiter = ';' MISSOVER DSD lrecl=32767 firstobs=2 ;
      informat Esc_Cob $20. ;
      informat Cnpj $15. ;
      informat Centro_Custo $15. ;
      informat Empresa $3. ;
      informat Estabelecimento $3. ;
      informat Transacao $32. ;
      informat Especie $2. ;
      informat Metodo $32. ;
      informat Titulo $22. ;
      informat Parcela $2. ;
      informat Nosso_Numero $22. ;
      informat Data_Emissao ptgdfde9. ;
      informat Data_Vencto ptgdfde9. ;
      informat Campanha $3. ;
      informat Status $3. ;
      informat Valor_Original0 BEST32. ;
      informat Saldo_Titulo0 BEST32. ;  
      informat Valor_Enviado_EC0 BEST32. ;
    /*  informat Valor_Original0 NLNUM32.2 ;
      informat Saldo_Titulo0 NLNUM32.2 ;  
      informat Valor_Enviado_EC0 NLNUM32.2 ; */
   /* informat Valor_Original0 commax32.2 ;
      informat Saldo_Titulo0 commax32.2 ;  
      informat Valor_Enviado_EC0 commax32.2 ;*/
      informat Data_Ult_Processo ptgdfde9. ;
      informat Tipo_de_Tecnologia $10. ;

      format Esc_Cob $20. ;
      format Cnpj $15. ;
      format Centro_Custo $15. ;
      format Empresa $3. ;
      format Estabelecimento $3. ;
      format Transacao $32. ;
      format Especie $2. ;
      format Metodo $32. ;
      format Titulo $22. ;
      format Parcela $2. ;
      format Nosso_Numero $22. ;
      format Data_Emissao ddmmyy10. ;
      format Data_Vencto ddmmyy10. ;
      format Campanha $3. ;
      format Status $3. ;
   /* format Valor_Original0 BEST32.2 ;
      format Saldo_Titulo0 BEST32.2 ;
      format Valor_Enviado_EC0 BEST32.2 ; */
      format Valor_Original0 NLPVALUE32.2 ;
      format Saldo_Titulo0 NLPVALUE32.2 ;
      format Valor_Enviado_EC0 NLPVALUE32.2 ;
   /* format Valor_Original0 commax12.2 ;
      format Saldo_Titulo0 commax12.2 ;
      format Valor_Enviado_EC0 commax12.2 ; */
      format Data_Ult_Processo ddmmyy10. ;
      format Tipo_de_Tecnologia $10. ;

   Input
      Esc_Cob $
      Cnpj $
      Centro_Custo $
      Empresa $
      Estabelecimento $
      Transacao $
      Especie $
      Metodo $
      Titulo $
      Parcela $
      Nosso_Numero $
      Data_Emissao
      Data_Vencto  
      Campanha $
      Status $
      Valor_Original0
      Saldo_Titulo0
      Valor_Enviado_EC0
      Data_Ult_Processo
      Tipo_de_Tecnologia ;

      Informat Natureza $1.; Format Natureza $1.;

      If length(CNPJ) eq 11 then Natureza = 'F';
         Else If length(CNPJ) eq 14 then Natureza = 'J';

      Valor_Original=round(Valor_Original0,.01);
      Saldo_Titulo=round(Saldo_Titulo0,.01);
      Valor_Enviado_EC=round(Valor_Enviado_EC0,.01);

      FORMAT Valor_Original NLPVALUE32.2 ;
      FORMAT Saldo_Titulo NLPVALUE32.2 ;
      FORMAT Valor_Enviado_EC NLPVALUE32.2 ; 

    /*FORMAT Valor_Original BEST32.2;
      FORMAT Saldo_Titulo BEST32.2;
      FORMAT Valor_Enviado_EC BEST32.2;    */

 /*   FORMAT Valor_Original nlpvalue12.2;
      FORMAT Saldo_Titulo nlpvalue12.2;
      FORMAT Valor_Enviado_EC nlpvalue12.2;  */

  /*  FORMAT Valor_Original commax12.2;
      FORMAT Saldo_Titulo commax12.2;
      FORMAT Valor_Enviado_EC commax12.2;   */

   if _ERROR_ then call symputx('_EFIERR_',1);
   Format dt $39.;
   If mod(_N_,50000) eq 0 then do;
      dt = put (_N_,commax15.0)||' '||put(date(),ddmmyy10.)||' '||put(time(),time12.3);
      Put 'Registro Processado: ' dt;
   End;
   Drop dt Valor_Original0 Saldo_Titulo0 Valor_Enviado_EC0;
Run;

Proc Sort Data=work.Historico(Compress=Yes Reuse=Yes Label='Relatório Histórico de Escritório') SortSize=2G;
   By CNPJ Centro_Custo Empresa Estabelecimento Transacao Especie Metodo Titulo Parcela;
Run;

Proc SQL FeedBack;
   Update work.Historico
      Set Esc_Cob = 'QUATRO C'
      Where Historico.Esc_Cob like 'MAGNO ADVOGADOS';
   Update work.Historico
      Set Esc_Cob = 'QUATRO C'
      Where Historico.Esc_Cob like 'ZANC ASSESSORIA';
Quit;


proc sort data=WORK.Historico; 
by Esc_Cob
Cnpj
Centro_Custo
Empresa
Estabelecimento
Transacao
Especie
Metodo
Titulo
Parcela
Nosso_Numero
Data_Emissao
Data_Vencto
Campanha
Status
Data_Ult_Processo
Tipo_de_Tecnologia
Natureza
Valor_Original
Saldo_Titulo
Valor_Enviado_EC;
run;


proc sort data=WORK.Historico nodupkey out=work.Historico1;
by 
Cnpj
Centro_Custo
Empresa
Estabelecimento
Especie
Titulo
Parcela
Data_Emissao;
run;

/*Criando Variável Título Completo (Título+Parcela)*/

Data work.Historico2;
   Set work.Historico1;
   Titulo_Parcela= Titulo||'#'||Parcela||'#'||Data_Emissao ;
Run;


proc sort data=WORK.Historico2;
by 
Cnpj
Centro_Custo
Empresa
Estabelecimento
Especie
Titulo_Parcela;
run;


proc sort data=WORK.Historico2 nodupkey out=work.Historico3;
by 
Cnpj
Centro_Custo
Empresa
Estabelecimento
Especie
Titulo_Parcela;
run;


/*Completando os zeros no CNPJ*/

Data work.Historico4;
   Set work.Historico3;
   if length(CNPJ)=11 then Cod_Cliente = '000'||CNPJ;
   else Cod_Cliente = CNPJ; 
Run;
******************************************************************************;
******Criando o Aging e deduplicando pelo MAIOR ******
********************************FIXA - PRI ***************************************************;

Data work.Aging;
   Set work.Historico4;
   Informat Aging $22.; Format Aging $22.;

   dias_atraso = MDY( 08, 19, 2013 ) - Data_Vencto ;  /*USAR SEMPRE UM MÊS DEPOIS ARQUIVO FEB USAR 1 DE MARÇO*/
   
   If dias_atraso <   61 then Aging = "1.< 61 dias"; Else
   If dias_atraso >   60 and dias_atraso <   91 then Aging = "2.Entre 61 a 90 dias"; Else
   If dias_atraso >   90 and dias_atraso <  121 then Aging = "3.Entre 91 a 120 dias"; Else
   If dias_atraso >  120 and dias_atraso <  151 then Aging = "4.Entre 121 a 150 dias"; Else
   If dias_atraso >  150 and dias_atraso <  181 then Aging = "5.Entre 151 a 180 dias"; Else
   If dias_atraso >  180 and dias_atraso <  211 then Aging = "6.Entre 181 a 210 dias"; Else
   If dias_atraso >  210 and dias_atraso <  241 then Aging = "7.Entre 211 a 240 dias"; Else
   If dias_atraso >  240 and dias_atraso <  271 then Aging = "8.Entre 241 a 270 dias"; Else
   If dias_atraso >  270 and dias_atraso <  301 then Aging = "9.Entre 271 a 300 dias"; Else
   If dias_atraso >  300 and dias_atraso <  331 then Aging = "91.Entre 301 a 330 dias"; Else
   If dias_atraso >  330 and dias_atraso <  366 then Aging = "92.Entre 331 a 365 dias"; Else
   If dias_atraso >  365 and dias_atraso <  731 then Aging = "93.Até 2 anos"; Else
   If dias_atraso >  730 and dias_atraso < 1096 then Aging = "94.Até 3 anos"; Else
   If dias_atraso > 1095 and dias_atraso < 1461 then Aging = "95.Até 4 anos"; Else
   If dias_atraso > 1460 and dias_atraso < 1826 then Aging = "96.Até 5 anos"; Else
   If dias_atraso > 1825 then Aging = "97.> 5 anos";

Run;

******************************************************************************;
******Criando o Aging e deduplicando pelo MAIOR (Ou o anterior ou ESTE) *******
********************************FIXA - PRI ***************************************************;

Data work.Aging;
   Set work.Historico4;
   Informat Aging $22.; Format Aging $22.;

   dias_atraso = date() - Data_Vencto ;
   
   If dias_atraso <   61 then Aging = "1.< 61 dias"; Else
   If dias_atraso >   60 and dias_atraso <   91 then Aging = "2.Entre 61 a 90 dias"; Else
   If dias_atraso >   90 and dias_atraso <  121 then Aging = "3.Entre 91 a 120 dias"; Else
   If dias_atraso >  120 and dias_atraso <  151 then Aging = "4.Entre 121 a 150 dias"; Else
   If dias_atraso >  150 and dias_atraso <  181 then Aging = "5.Entre 151 a 180 dias"; Else
   If dias_atraso >  180 and dias_atraso <  211 then Aging = "6.Entre 181 a 210 dias"; Else
   If dias_atraso >  210 and dias_atraso <  241 then Aging = "7.Entre 211 a 240 dias"; Else
   If dias_atraso >  240 and dias_atraso <  271 then Aging = "8.Entre 241 a 270 dias"; Else
   If dias_atraso >  270 and dias_atraso <  301 then Aging = "9.Entre 271 a 300 dias"; Else
   If dias_atraso >  300 and dias_atraso <  331 then Aging = "91.Entre 301 a 330 dias"; Else
   If dias_atraso >  330 and dias_atraso <  366 then Aging = "92.Entre 331 a 365 dias"; Else
   If dias_atraso >  365 and dias_atraso <  731 then Aging = "93.Até 2 anos"; Else
   If dias_atraso >  730 and dias_atraso < 1096 then Aging = "94.Até 3 anos"; Else
   If dias_atraso > 1095 and dias_atraso < 1461 then Aging = "95.Até 4 anos"; Else
   If dias_atraso > 1460 and dias_atraso < 1826 then Aging = "96.Até 5 anos"; Else
   If dias_atraso > 1825 then Aging = "97.> 5 anos";

Run;

proc sort data=work.Aging; by Cod_Cliente descending dias_atraso;Run;
proc sort data=work.Aging nodupkey out=work.Aging2;by Cod_Cliente;run;

Data work.Aging_Maior_Zero;
   Set work.Aging;
   Where Saldo_Titulo > 0;
Run;


/*######################################################*/
         /*Sumarizando Valores por ESCRITÓRIO*/
/*######################################################*/

PROC SQL;
CREATE TABLE Valores_escritorio AS
SELECT
   Cod_Cliente,
   Natureza,
   Centro_Custo,
   esc_cob,
   SUM(Valor_Original) AS Soma_Valor_Original,
   SUM(Saldo_Titulo) AS Soma_Saldo_Titulo,
   SUM(Valor_Enviado_EC) AS Soma_Valor_Enviado,
   COUNT(distinct Centro_Custo) AS QTD_Centro_Custo,
   COUNT(distinct Titulo_Parcela) AS QTD_Titulo,
   COUNT(distinct Esc_Cob) AS QTD_Escritorio
FROM work.Aging_Maior_Zero
GROUP BY 1,2,3,4;
QUIT;


/*Enriquecendo com Fraude e Jurídico*/

proc sql;
create table WORK.Valores_Juridico_esc as
select a.*, b.Motivo as Motivo_Juridico
from Valores_escritorio a left join work.Juridico b
on a.Cod_Cliente = b.CNPJ;
quit;

proc sql;
create table WORK.Valores_Juridico_Fraude_esc as
select a.*, b.Motivo as Motivo_Fraude
from WORK.Valores_Juridico_esc a left join work.Fraudes b
on a.Cod_Cliente = b.CNPJ;
quit;

Data work.Base_esc;
   Set WORK.Valores_Juridico_Fraude_esc;
   if Motivo_Fraude='' then Fraude="Não";
   else Fraude="Sim";

   if Motivo_Juridico='' then Juridico="Não";
   else Juridico="Sim";
   drop Motivo_Fraude Motivo_Juridico;
Run;

/*Deduplicando pelo MAIOR Aging por Escritório*/

proc sort data=work.Aging_Maior_Zero; by Cod_Cliente esc_cob descending dias_atraso;Run;
proc sort data=work.Aging_Maior_Zero nodupkey out=work.Aging_Maior_Zero2_esc;by Cod_Cliente esc_cob;run;



proc sql;
create table work.Base1_esc as
select a.*, b.dias_atraso, b.Aging
from WORK.Base_esc a left join work.Aging_Maior_Zero2_esc b
on a.Cod_Cliente = b.Cod_Cliente and a.esc_cob=b.esc_cob;
quit;

PROC SQL;
CREATE TABLE work.SUMARIO_GERAL_ESC AS
SELECT
   Natureza,
   Fraude,
   Juridico,
   Aging,
   esc_cob,
   SUM(Soma_Valor_Original) AS Soma_Valor_Original,
   SUM(Soma_Saldo_Titulo) AS Soma_Saldo_Titulo,
   SUM(Soma_Valor_Enviado) AS Soma_Valor_Enviado,
   SUM(QTD_Centro_Custo) AS QTD_Centro_Custo,
   SUM(QTD_Titulo) AS QTD_Titulo,
   COUNT(distinct Cod_Cliente) AS QTD_Clientes
FROM work.Base1_esc
GROUP BY 1,2,3,4,5;
QUIT;


Proc Export Data= work.SUMARIO_GERAL_ESC
            OutFile= 'G:\Comum\Histórico\SUMARIO_GERAL_ESC_ddmmaa.txt' 
            DBMS=DLM Replace;
     Delimiter=';'; 
     PutNames=Yes;
Run;

