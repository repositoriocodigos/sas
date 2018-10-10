

data GOONPGT.PGT_201502;
%let _EFIERR_ = 0; /* set the ERROR detection macro variable */
infile  'C:\Users\Di Giunta\Documents\GoOn\Nextel\Base\Goon\FollPAg\02_2015.txt' delimiter = ';' MISSOVER DSD  firstobs=2 ;
informat Estab best32. ;
informat CNPJ best32. ;
informat Especie $2. ;
informat Dt_Emissao PTGDFDE9. ;
informat NF $9. ;
informat Dt_Vencto PTGDFDE9. ;
informat Vl_Titulo  NUMX9. ;
informat Vl_Baixa NUMX9. ;
informat Saldo_Pendente NUMX9. ;
informat Dt_Baixa PTGDFDE9. ;
informat Dt_GL PTGDFDE9. ;
informat Referencia $30. ;
informat Metodo_de_Recebimento $32. ;
informat Tipo_NF $19. ;
informat Razao_Social $40. ;
informat Cond_Pagto $13. ;
informat Met_Pagto $32. ;
informat Status_Receb $11. ;
informat Municipio $22. ;
informat Estado $2. ;
informat Numero_Ajuste $1. ;
informat Login_Efet_Ajuste $1. ;
informat AB $3. ;
informat Juros Best9. ;
informat Multa Best9. ;
informat Estorno $1. ;
informat Codigo_da_Conta $1. ;
informat Empresa_LD $1. ;
informat Tipo_de_Contrato $1. ;
informat Dt_Receb PTGDFDE9. ;
format Estab best12. ;
format CNPJ best12. ;
format Especie $2. ;
format Dt_Emissao PTGDFDE9. ;
format NF $9. ;
format Dt_Vencto PTGDFDE9. ;
format Vl_Titulo Best9. ;
format Vl_Baixa Best9. ;
format Saldo_Pendente Best9. ;
format Dt_Baixa PTGDFDE9. ;
format Dt_GL PTGDFDE9. ;
format Referencia $30. ;
format Metodo_de_Recebimento $32. ;
format Tipo_NF $19. ;
format Razao_Social $40. ;
format Cond_Pagto $13. ;
format Met_Pagto $32. ;
format Status_Receb $11. ;
format Municipio $22. ;
format Estado $2. ;
format Numero_Ajuste $1. ;
format Login_Efet_Ajuste $1. ;
format AB $3. ;
format Juros Best9. ;
format Multa Best9. ;
format Estorno $1. ;
format Codigo_da_Conta $1. ;
format Empresa_LD $1. ;
format Tipo_de_Contrato $1. ;
format Dt_Receb PTGDFDE9. ;
input
Estab
CNPJ
Especie $
Dt_Emissao $
NF $
Dt_Vencto $
Vl_Titulo
Vl_Baixa
Saldo_Pendente
Dt_Baixa $
Dt_GL $
Referencia $
Metodo_de_Recebimento $
Tipo_NF $
Razao_Social $
Cond_Pagto $
Met_Pagto $
Status_Receb $
Municipio $
Estado $
Numero_Ajuste $
Login_Efet_Ajuste $
AB $
Juros
Multa
Estorno $
Codigo_da_Conta $
Empresa_LD $
Tipo_de_Contrato $
Dt_Receb $
;
if _ERROR_ then call symput('_EFIERR_',1);  /* set ERROR detection macro variable */
run;


PROC SQL; 
CREATE TABLE GOONPGT.PGT_201502s AS
SELECT
	t1.CNPJ,
	t1.NF,
	t1.Vl_Titulo, 
 	t1.Vl_Baixa,
 	t1.Saldo_Pendente,
	t1.Dt_Vencto,
	t1.Metodo_de_Recebimento,
	t1.dt_Baixa,
	t1.Dt_GL,
	t1.Dt_Receb
from GOONPGT.PGT_201502 as t1
where ((t1.dt_Baixa - t1.Dt_Vencto) > 4)
;
QUIT;
 
