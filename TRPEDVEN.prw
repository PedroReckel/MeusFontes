#INCLUDE "Protheus.ch"
#INCLUDE "Topconn.ch"

/*/{Protheus.doc} TRPEDVEN
Relatório no modelo TReport que é responsável por imprimir os dados do cadatro de clientes, mais precisamente os campos CODIGO, LOJA e NOME
@type function
@author Pedro Reckel Roberte	
@since 03/10/2022
@version 1.0
/*/
User Function TRPEDVEN()

//VARIAVEIS 
Private oReport  := Nil
Private oSecCab	 := Nil
Private cPerg 	 := "TRCLI"

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
Aqui os campos contidos na querie, que você quer que apareça no relatório, são adicionados
@type function
@author Pedro Reckel Roberte
@since 03/10/2022
@version 1.0
/*/Static Function ReportDef()

oReport := TReport():New("TRPEDVEN","Relatório - Pedidos de VENDA / CLIENTE",cPerg,{|oReport| PrintReport(oReport)},"Relatório Pedidos de VENDA")
oReport:SetLandscape(.T.) // SIGNIFICA QUE O RELATÓRIO SERÁ EM PAISAGEM

//TrSection serve para constrole da seção do relatório, neste caso, teremos somente uma
oSecCab := TRSection():New( oReport , "PEDIDOS POR CLIENTE"  )

/*
TrCell serve para inserir os campos/colunas que você quer no relatório, lembrando que devem ser os mesmos campos que contém na QUERIE
Um detalhe importante, todos os campos contidos nas linhas abaixo, devem estar na querie, mas.. 
você pode colocar campos na querie e adcionar aqui embaixo, conforme a sua necessidade.
*/

//C5_NUM,A1_NOME, C5_EMISSAO, C6_PRODUTO, C6_QTDVEN, C6_PRCVEN,C6_VALOR

TRCell():New( oSecCab, "C5_NUM"    , "SC5")
TRCell():New( oSecCab, "C5_CLIENTE"     , "SC5")
TRCell():New( oSecCab, "A1_NOME"    , "SA1")
TRCell():New( oSecCab, "C5_EMISSAO"    , "SC6")
TRCell():New( oSecCab, "C6_PRODUTO"    , "SC6")
TRCell():New( oSecCab, "C6_QTDVEN"    , "SC6")
TRCell():New( oSecCab, "C6_PRCVEN"    , "SC6")
TRCell():New( oSecCab, "C6_VALOR"    , "SC6")

oBreak := TRBreak():New(oSecCab,oSecCab:Cell("C5_CLIENTE"),"Sub Total Pedidos")

//ESTA LINHA IRÁ CONTAR A QUANTIDADE DE REGISTROS LISTADOS NO RELATÓRIO PARA A ÚNICA SEÇÃO QUE TEMOS
TRFunction():New(oSecCab:Cell("C5_NUM"),NIL,"COUNT",oBreak)
TRFunction():New(oSecCab:Cell("C6_VALOR"),NIL,"SUM",oBreak)

TRFunction():New(oSecCab:Cell("C5_NUM"),,"COUNT")

Return 


/*/{Protheus.doc} PrintReport
Nesta função é inserida a query utilizada para exibição dos dados;
A função de PERGUNTAS  é chamada para que os filtros possam ser montados
@type function
@author Pedro Reckel Roberte
@since 03/10/2022
@version 1.0
@param oReport, objeto, (Descrição do parâmetro)
/*/Static Function PrintReport(oReport)
Local cAlias := GetNextAlias()


oSecCab:BeginQuery() //Relatório começa a ser estruturado
//INICIO DA QUERY
BeginSql Alias cAlias

	SELECT C5_NUM,C5_CLIENTE,A1_NOME, C5_EMISSAO, C6_PRODUTO, C6_QTDVEN, C6_PRCVEN,C6_VALOR FROM %table:SC5% SC5
	INNER JOIN %table:SC6% AS SC6 ON SC5.C5_NUM = C6_NUM AND C5_SERIE = C6_SERIE AND SC6.D_E_L_E_T_ = ' '
	INNER JOIN %table:SA1% AS SA1 ON SC5.C5_CLIENTE = A1_COD AND C5_LOJACLI = A1_LOJA  AND SA1.D_E_L_E_T_ = ' '
	WHERE SC5.%notdel% AND   (C5_CLIENTE >= %exp:(MV_PAR01)% AND C5_CLIENTE <= %exp:(MV_PAR02)%  ) AND
	(C5_NUM BETWEEN %exp:(MV_PAR03)% AND %exp:(MV_PAR04)%)
	

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
@since 03/10/2022
@version 1.0
/*/Static Function ValidPerg()
	Local aArea  := SX1->(GetArea())
	Local aRegs := {}
	Local i,j


	aadd( aRegs, { cPerg,"01","Cliente de ?","Cliente de ?","Cliente de ?","mv_ch1","C", 6,0,0,"G","","mv_par01","","","mv_par01"," ","",""," ","","","","","","","","","","","","","","","","","","SA1"          } )
	aadd( aRegs, { cPerg,"02","Cliente ate ?","Cliente ate ?","Cliente ate ?","mv_ch2","C", 6,0,0,"G","","mv_par02","","","mv_par02"," ","",""," ","","","","","","","","","","","","","","","","","","SA1"       } )
	aadd( aRegs, { cPerg,"03","Pedido  de ?","Pedido de ?","Pedido de ?","mv_ch1","C", 6,0,0,"G","","mv_par03","","","mv_par03"," ","",""," ","","","","","","","","","","","","","","","","","","SC5"          } )
	aadd( aRegs, { cPerg,"04","Pedido  ate?","Pedido ate ?","Pedido ate ?","mv_ch2","C", 6,0,0,"G","","mv_par04","","","mv_par04"," ","",""," ","","","","","","","","","","","","","","","","","","SC5"       } )


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
