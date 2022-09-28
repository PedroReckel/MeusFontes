#INCLUDE "Protheus.ch"
#INCLUDE "Topconn.ch"

/*/{Protheus.doc} TRCLI
Relatório no modelo TReport que é responsável por imprimir os dados do cadatro de clientes, mais precisamente os campos CODIGO, LOJA e NOME
@type function
@author Pedro Reckel Roberte
@since 27/09/2022
@version 1.0
/*/
User Function TRFOR()

//VARIAVEIS 
Private oReport  := Nil
Private oSecCab	 := Nil
Private cPerg 	 := "TRFOR"

//Função que cria as perguntas/filtros que iremos usar no relatório, na SX1
ValidPerg()

//Função responsável por chamar a pergunta criada na função ValidaPerg, a variável PRIVATE cPerg, é passada.
Pergunte(cPerg,.T.)

//CHAMAMOS AS FUNÇÕES QUE CONSTRUIRÃO O RELATÓRIO
ReportDef()
oReport:PrintDialog()

Return 



/*/{Protheus.doc} ReportDef
Função responsável por estruturar as seções e campos que darão forma ao relatório, bem como outras características.
Aqui os campos contidos na query, que você quer que apareça no relatório, são adicionados
@type function
@author Pedro Reckel Roberte
@since 27/09/2022
@version 1.0
/*/

Static Function ReportDef()

oReport := TReport():New("TRFOR","Relatório - Títulos por Fornecedor",cPerg,{|oReport| PrintReport(oReport)},"Relatório de Títulos por Fornecedor")
oReport:SetLandscape(.T.) // SIGNIFICA QUE O RELATÓRIO SERÁ EM PAISAGEM

//TrSection serve para constrole da seção do relatório, neste caso, teremos somente uma
oSecCab := TRSection():New( oReport , "TITULOS POR FORNECEDOR"  )

/*
TrCell serve para inserir os campos/colunas que você quer no relatório, lembrando que devem ser os mesmos campos que contém na QUERIE
Um detalhe importante, todos os campos contidos nas linhas abaixo, devem estar na querie, mas.. 
você pode colocar campos na querie e adcionar aqui embaixo, conforme a sua necessidade.
*/
TRCell():New( oSecCab, "E2_NUM"    , "SE2")
TRCell():New( oSecCab, "A2_COD"     , "SA2")
TRCell():New( oSecCab, "A2_NOME"    , "SA2")
TRCell():New( oSecCab, "E2_VALOR"    , "SE2")
TRCell():New( oSecCab, "E2_SALDO"    , "SE2")


oBreak := TRBreak():New(oSecCab,oSecCab:Cell("A2_COD"),"Sub Total Titulos")
//ESTA LINHA IRÁ CONTAR A QUANTIDADE DE REGISTROS LISTADOS NO RELATÓRIO PARA A ÚNICA SEÇÃO QUE TEMOS
TRFunction():New(oSecCab:Cell("E2_VALOR"),NIL,"SUM",oBreak)
TRFunction():New(oSecCab:Cell("E2_SALDO"),NIL,"SUM",oBreak)

TRFunction():New(oSecCab:Cell("A2_COD"),,"COUNT")

Return 


/*/{Protheus.doc} PrintReport
Nesta função é inserida a query utilizada para exibição dos dados;
A função de PERGUNTAS  é chamada para que os filtros possam ser montados
@type function
@author Pedro Reckel Roberte
@since 27/09/2022
@version 1.0
@param oReport, objeto, (Descrição do parâmetro)
/*/

Static Function PrintReport(oReport)
Local cAlias := GetNextAlias()


oSecCab:BeginQuery() //Relatório começa a ser estruturado
//INICIO DA QUERY
BeginSql Alias cAlias

	SELECT E2_PREFIXO, E2_NUM, A2_COD,A2_NOME, E2_VALOR, E2_SALDO FROM %table:SE2% SE2
	INNER JOIN %table:SA2% SA2 ON SE2.E2_FORNECE = SA2.A2_COD AND E2_LOJA = A2_LOJA  
	WHERE E2_FORNECE BETWEEN %exp:(MV_PAR01)% AND %exp:(MV_PAR02)%  
	AND SE2.D_E_L_E_T_ = ' ' AND SA2.D_E_L_E_T_ = ' '  

//FIM DA QUERY
EndSql


oSecCab:EndQuery() //Fim da Query
oSecCab:Print() //É dada a ordem de impressão, visto os filtros selecionados

//O Alias utilizado para execução da querie é fechado.
(cAlias)->(DbCloseArea())

Return 


/*/{Protheus.doc} ValidPerg
FUNÇÃO RESPONSÁVEL POR CRIAR AS PERGUNTAS NA SX1 
@type function
@author Pedro Reckel Roberte
@since 27/09/2022
@version 1.0
/*/

Static Function ValidPerg()
	Local aArea  := SX1->(GetArea())
	Local aRegs := {}
	Local i,j

	aadd( aRegs, { cPerg,"01","Fornecedor de ?","Fornecedor de ?","Fornecedor de ?","mv_ch1","C", 6,0,0,"G","","mv_par01","","","mv_par01"," ","",""," ","","","","","","","","","","","","","","","","","","SA2"          } )
	aadd( aRegs, { cPerg,"02","Fornecedor ate ?","Fornecedor ate ?","Fornecedor ate ?","mv_ch2","C", 6,0,0,"G","","mv_par02","","","mv_par02"," ","",""," ","","","","","","","","","","","","","","","","","","SA2"       } )

	DbselectArea('SX1')
	SX1->(DBSETORDER(1))
	For i:= 1 To Len(aRegs)
		If ! SX1->(DBSEEK( AvKey(cPerg,"X1_GRUPO") +aRegs[i,2]) )
			Reclock('SX1', .T.)
			FOR j:= 1 to SX1->( FCOUNT() )
				IF j <= Len(aRegs[i])
					FieldPut(j,aRegs[i,j])
				ENDIF
			Next j
			SX1->(MsUnlock())
		Endif
	Next i 
	RestArea(aArea) 
Return(cPerg)
