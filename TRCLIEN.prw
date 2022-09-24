#INCLUDE "Protheus.ch"
#INCLUDE "Topconn.ch"

/*FUNÇÃO PRINCIPAL / MAIN FUNCTION*/
User Function TRCLIEN()
//VARIAVEIS 
Private oReport  := Nil //NOTAÇÃO POLONESA
Private oSecCab	 := Nil
Private cPerg 	 := "TRCLIEN" //FICAM ARMAZENADAS NA SX1

//Função responsável por chamar a pergunta criada na função ValidaPerg, 
//a variável PRIVATE cPerg, é passada.
//Pergunte(cPerg,.T.) // SE TRUE ELE CHAMA A PERGUNTA ASSIM QUE O RELATÓRIO É ACIONADO

//CHAMAMOS AS FUNÇÕES QUE CONSTRUIRÃO O RELATÓRIO
ReportDef() //MONTAR A ESTRUTURA
oReport:PrintDialog() //TRAZER OS DADOS E PRINTA/IMPRIME NA TELA OU EM ARQUIVO OU NA IMPRESSORA O RELATÓRIO

Return 


/*FUNÇÃO RESPONSÁVEL PELA ESTRUTURA DO RELATÓRIO*/
Static Function ReportDef()

oReport := TReport():New("CLIENTE","Relatório - Clientes",cPerg,{|oReport| PrintReport(oReport)},"Relatório de Clientes")

oReport:SetLandscape(.T.) // SIGNIFICA QUE O RELATÓRIO SERÁ EM PAISAGEM

//TrSection serve para constrole da seção do relatório, neste caso, teremos somente uma
oSecCab := TRSection():New( oReport , "CLIENTES", {"SQL"} )

TRCell():New( oSecCab, "A1_COD", "SA1") 
TRCell():New( oSecCab, "A1_NOME", "SA1")

TRFunction():New(oSecCab:Cell("A1_COD"),,"COUNT",,,,,.F.,.T.,.F.,oSecCab)
Return 


/*FUNÇÃO RESPONSÁVEL POR TRAZER OS DADOS*/
Static Function PrintReport(oReport)
Local cAlias := GetNextAlias()


oSecCab:BeginQuery() //Query começa a ser estruturada no relatório
	BeginSql Alias cAlias
		SELECT A1_COD, A1_NOME FROM %table:SA1%
		WHERE %notDel% 
	EndSql	
	/*
	cSQL := "SELECT B1_COD, B1_DESC FROM "+RetsqlName("SB1")
	cSql += " WHERE D_E_L_E_T_ = ' ' "
	*/
oSecCab:EndQuery() //Fim da Query
oSecCab:Print() //É dada a ordem de impressão, visto os filtros selecionados

(cAlias)->(DbCloseArea())
Return 