#INCLUDE "Protheus.ch"
#INCLUDE "Topconn.ch"

/*FUNÇÃO PRINCIPAL / MAIN FUNCTION*/
User Function TRPROD()
//VARIAVEIS 
Private oReport  := Nil //NOTAÇÃO POLONESA
Private oSecCab	 := Nil
Private cPerg 	 := "TRPROD" //FICAM ARMAZENADAS NA SX1

//Função responsável por chamar a pergunta criada na função ValidaPerg, 
//a variável PRIVATE cPerg, é passada.

Pergunte(cPerg,.T.) // SE TRUE ELE CHAMA A PERGUNTA ASSIM QUE O RELATÓRIO É ACIONADO

//CHAMAMOS AS FUNÇÕES QUE CONSTRUIRÃO O RELATÓRIO
ReportDef() //MONTAR A ESTRUTURA
oReport:PrintDialog() //TRAZER OS DADOS E PRINTA/IMPRIME NA TELA OU EM ARQUIVO OU NA IMPRESSORA O RELATÓRIO

Return 


/*FUNÇÃO RESPONSÁVEL PELA ESTRUTURA DO RELATÓRIO*/
Static Function ReportDef()

oReport := TReport():New("PROD","Relatório - Produtos",cPerg,{|oReport| PrintReport(oReport)},"Relatório de Produtos")

oReport:SetLandscape(.T.) // SIGNIFICA QUE O RELATÓRIO SERÁ EM PAISAGEM

//TrSection serve para constrole da seção do relatório, neste caso, teremos somente uma
oSecCab := TRSection():New( oReport , "PRODUTOS", {"SQL"} )

TRCell():New( oSecCab, "B1_COD", "SB1") 
TRCell():New( oSecCab, "B1_DESC", "SB1")

TRFunction():New(oSecCab:Cell("B1_COD"),,"COUNT",,,,,.F.,.T.,.F.,oSecCab)
Return 


/*FUNÇÃO RESPONSÁVEL POR TRAZER OS DADOS*/
Static Function PrintReport(oReport)
Local cAlias := GetNextAlias()


oSecCab:BeginQuery() //Query começa a ser estruturada no relatório
	BeginSql Alias cAlias
		SELECT B1_COD, B1_DESC FROM %table:SB1%
		WHERE %notDel% AND B1_COD BETWEEN %exp:(MV_CH0)% AND %exp:(MV_CH0)%
	EndSql	
	/*
	cSQL := "SELECT B1_COD, B1_DESC FROM "+RetsqlName("SB1")
	cSql += " WHERE D_E_L_E_T_ = ' ' "
	*/
oSecCab:EndQuery() //Fim da Query
oSecCab:Print() //É dada a ordem de impressão, visto os filtros selecionados

(cAlias)->(DbCloseArea())
Return 
