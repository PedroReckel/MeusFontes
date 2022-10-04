#INCLUDE "Protheus.ch"
#INCLUDE "Topconn.ch"

/*/{Protheus.doc} TRPEDVEN
Relat�rio no modelo TReport que � respons�vel por imprimir os dados do cadatro de clientes, mais precisamente os campos CODIGO, LOJA e NOME
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

//Fun��o que cria as perguntas/filtros que iremos usar no relat�rio, na SX1
ValidPerg()

//Fun��o respons�vel por chamar a pergunta criada na fun��o ValidaPerg, a vari�vel PRIVATE cPerg, � passada.
Pergunte(cPerg,.T.)

//CHAMAMOS AS FUN��ES QUE CONSTRUIR�O O RELAT�RIO
ReportDef()
oReport:PrintDialog()

Return 



/*/{Protheus.doc} ReportDef
Fun��o respons�vel por estruturar as se��es e campos que dar�o forma ao relat�rio, bem como outras caracter�sticas.
Aqui os campos contidos na querie, que voc� quer que apare�a no relat�rio, s�o adicionados
@type function
@author Pedro Reckel Roberte
@since 03/10/2022
@version 1.0
/*/Static Function ReportDef()

oReport := TReport():New("TRPEDVEN","Relat�rio - Pedidos de VENDA / CLIENTE",cPerg,{|oReport| PrintReport(oReport)},"Relat�rio Pedidos de VENDA")
oReport:SetLandscape(.T.) // SIGNIFICA QUE O RELAT�RIO SER� EM PAISAGEM

//TrSection serve para constrole da se��o do relat�rio, neste caso, teremos somente uma
oSecCab := TRSection():New( oReport , "PEDIDOS POR CLIENTE"  )

/*
TrCell serve para inserir os campos/colunas que voc� quer no relat�rio, lembrando que devem ser os mesmos campos que cont�m na QUERIE
Um detalhe importante, todos os campos contidos nas linhas abaixo, devem estar na querie, mas.. 
voc� pode colocar campos na querie e adcionar aqui embaixo, conforme a sua necessidade.
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

//ESTA LINHA IR� CONTAR A QUANTIDADE DE REGISTROS LISTADOS NO RELAT�RIO PARA A �NICA SE��O QUE TEMOS
TRFunction():New(oSecCab:Cell("C5_NUM"),NIL,"COUNT",oBreak)
TRFunction():New(oSecCab:Cell("C6_VALOR"),NIL,"SUM",oBreak)

TRFunction():New(oSecCab:Cell("C5_NUM"),,"COUNT")

Return 


/*/{Protheus.doc} PrintReport
Nesta fun��o � inserida a query utilizada para exibi��o dos dados;
A fun��o de PERGUNTAS  � chamada para que os filtros possam ser montados
@type function
@author Pedro Reckel Roberte
@since 03/10/2022
@version 1.0
@param oReport, objeto, (Descri��o do par�metro)
/*/Static Function PrintReport(oReport)
Local cAlias := GetNextAlias()


oSecCab:BeginQuery() //Relat�rio come�a a ser estruturado
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
oSecCab:Print() //� dada a ordem de impress�o, visto os filtros selecionados

//O Alias utilizado para execu��o da querie � fechado.
(cAlias)->(DbCloseArea())

Return 


/*/{Protheus.doc} ValidPerg
FUN��O RESPONS�VEL POR CRIAR AS PERGUNTAS NA SX1 
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
