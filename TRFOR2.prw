#INCLUDE "Protheus.ch"
#INCLUDE "Topconn.ch"

/*/{Protheus.doc} TRCLI
Relatório no modelo TReport que é responsável por imprimir os dados do cadatro de clientes, mais precisamente os campos CODIGO, LOJA e NOME
@type function
@author Pedro Reckel Roberte
@since 07/10/2019
@version 1.0
/*/
User Function TRFOR2()

//VARIAVEIS 
Private oReport    := Nil
Private oSection1  := Nil //Primeira Sessão
Private oSection2  := Nil //Segunda  Sessão

Private cPerg 	 := "TRFOR2"

ValidPerg()

Pergunte(cPerg,.T.)

ReportDef()
oReport:PrintDialog()

Return 



/*/{Protheus.doc} ReportDef
Função responsável por estruturar as seções e campos que darão forma ao relatório, bem como outras características.
Aqui os campos contidos na querie, que você quer que apareça no relatório, são adicionados
@type function
@author Pedro Reckel Roberte
@since 07/10/2019
@version 1.0
/*/Static Function ReportDef()
oReport := TReport():New("TRFOR","Relatório - Títulos por Fornecedor",cPerg,{|oReport| PrintReport(oReport)},"Relatório de Títulos por Fornecedor")
oReport:SetLandscape(.T.) // SIGNIFICA QUE O RELATÓRIO SERÁ EM PAISAGEM


//Primeira sessão, terá os dados do fornecedor SA2
oSection1 := TRSection():New(oReport,"FORNECEDOR","SA2")
TRCell():New( oSection1, "A2_COD"     , "SA2")
TRCell():New( oSection1, "A2_LOJA"    , "SA2")
TRCell():New( oSection1, "A2_NOME"    , "SA2")


//TrSection serve para constrole da seção do relatório, neste caso, teremos somente uma
oSection2 := TRSection():New( oSection1 , "TITULOS POR FORNECEDOR","SE2" ) //SE2
TRCell():New( oSection2, "E2_NUM"     , "SE2")
TRCell():New( oSection2, "E2_PREFIXO" , "SE2")
TRCell():New( oSection2, "E2_EMISSAO" , "SE2")
TRCell():New( oSection2, "E2_VALOR"   , "SE2")
TRCell():New( oSection2, "E2_SALDO"   , "SE2")


TRFunction():New(oSection2:Cell("E2_VALOR"),,"SUM")
TRFunction():New(oSection2:Cell("E2_SALDO"),,"SUM")
TRFunction():New(oSection2:Cell("E2_VALOR"),,"MAX")
TRFunction():New(oSection2:Cell("E2_NUM"),,"COUNT")

Return 


/*/{Protheus.doc} PrintReport
Nesta função é inserida a query utilizada para exibição dos dados;
A função de PERGUNTAS  é chamada para que os filtros possam ser montados
@type function
@author Pedro Reckel Roberte
@since 07/10/2019
@version 1.0
@param oReport, objeto, (Descrição do parâmetro)
/*/Static Function PrintReport(oReport)
Local cAlias := GetNextAlias()


oSection1:BeginQuery() //Relatório começa a ser estruturado
//INICIO DA QUERY
BeginSql Alias cAlias

	SELECT A2_COD,A2_LOJA,A2_NOME,E2_NUM, E2_PREFIXO, E2_EMISSAO, E2_VALOR, E2_SALDO 
	FROM %table:SE2% SE2
	INNER JOIN %table:SA2% SA2 ON SE2.E2_FORNECE = SA2.A2_COD AND E2_LOJA = A2_LOJA  
	WHERE E2_FORNECE BETWEEN %exp:(MV_PAR01)% AND %exp:(MV_PAR02)%  
	AND SE2.D_E_L_E_T_ = ' ' AND SA2.D_E_L_E_T_ = ' '  

//FIM DA QUERY
EndSql

oSection1:EndQuery() //Fim da Query
oSection2:SetParentQuery() 
oSection2:SetParentFilter({|cForLoja| (cAlias)->A2_COD+(cAlias)->A2_LOJA = cForLoja},{|| (cAlias)->A2_COD+(cAlias)->A2_LOJA})

oSection1:Print() //É dada a ordem de impressão, visto os filtros selecionados

//O Alias utilizado para execução da querie é fechado.
(cAlias)->(DbCloseArea())

Return 


/*/{Protheus.doc} ValidPerg
FUNÇÃO RESPONSÁVEL POR CRIAR AS PERGUNTAS NA SX1 
@type function
@author Pedro Reckel Roberte
@since 07/10/2019
@version 1.0
/*/Static Function ValidPerg()
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
