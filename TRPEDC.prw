#INCLUDE "Protheus.ch"
#INCLUDE "Topconn.ch"

/*/{Protheus.doc} TRCLI
Relat�rio no modelo TReport que � respons�vel por imprimir os dados do cadatro de clientes, mais precisamente os campos CODIGO, LOJA e NOME
@type function
@author Pedro Reckel Roberte
@since 27/09/2022
@version 1.0
/*/
User Function TRPEDC()

    LOCAL cNomefuncao    := ""  //variavel que deve receber o nome do fonte digitado
    LOCAL aPergs        := {}  //Array que armazena as perguntas do ParamBox()

//adiciona elementos no array de perguntas
    aAdd( aPergs , {1, "TRPEDC.PRW", space(10), "", "", "", "", 40, .T.} )

//If que valida o OK do parambox() e passa o conteudo do parametro para a variavel
    IF ParamBox(aPergs, "TRPEDC.PRW" )
        cNomefuncao := ALLTRIM( MV_PAR01 )
    ELSE
        RETURN
    ENDIF

//Caso o usuario digite o U_ ou () no nome do fonte, retira esses caracteres
    cNomefuncao := StrTran( cNomefuncao , "U_" , "" )
    cNomefuncao := StrTran( cNomefuncao , "()" , "" )

//Valida se a funcao existe no rpo
    IF !FindFunction( cNomefuncao )
        MsgAlert( "Funcao nao encontrada no RPO" , "ops!" )
        RETURN u_ExecFonte()
    ENDIF

//complementa a variavel e executa macro substituicao chamando a rotina
    cNomefuncao := "U_"+cNomefuncao+"()"
    &cNomefuncao

//VARIAVEIS 
Private oReport  := Nil
Private oSecCab	 := Nil
Private cPerg 	 := "TRPEDC"

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
Aqui os campos contidos na query, que voc� quer que apare�a no relat�rio, s�o adicionados
@type function
@author Pedro Reckel Roberte
@since 27/09/2022
@version 1.0
/*/

Static Function ReportDef()

oReport := TReport():New("TRFOR","Relat�rio - T�tulos por Fornecedor",cPerg,{|oReport| PrintReport(oReport)},"Relat�rio de pedidos de compras por fonecedor")
oReport:SetLandscape(.T.) // SIGNIFICA QUE O RELAT�RIO SER� EM PAISAGEM

//TrSection serve para constrole da se��o do relat�rio, neste caso, teremos somente uma
oSecCab := TRSection():New( oReport , "TITULOS POR FORNECEDOR"  )

/*
TrCell serve para inserir os campos/colunas que voc� quer no relat�rio, lembrando que devem ser os mesmos campos que cont�m na QUERIE
Um detalhe importante, todos os campos contidos nas linhas abaixo, devem estar na querie, mas.. 
voc� pode colocar campos na querie e adcionar aqui embaixo, conforme a sua necessidade.
*/

// A2_COD, A2_NOME, C7_EMISSAO, C7_PRODUTO, C7_QUANT
TRCell():New( oSecCab, "E2_NUM"    , "SE2")
TRCell():New( oSecCab, "A2_COD"     , "SA2")
TRCell():New( oSecCab, "A2_NOME"    , "SA2")
TRCell():New( oSecCab, "C7_EMISSAO"    , "SC7")
TRCell():New( oSecCab, "C7_QUANT"    , "SC7")


oBreak := TRBreak():New(oSecCab,oSecCab:Cell("C7_FORNECE"),"Sub Total pedidos")
//ESTA LINHA IR� CONTAR A QUANTIDADE DE REGISTROS LISTADOS NO RELAT�RIO PARA A �NICA SE��O QUE TEMOS
TRFunction():New(oSecCab:Cell("C7_NUM"),NIL,"SUM",oBreak)

TRFunction():New(oSecCab:Cell("A2_COD"),,"COUNT")

Return 


/*/{Protheus.doc} PrintReport
Nesta fun��o � inserida a query utilizada para exibi��o dos dados;
A fun��o de PERGUNTAS  � chamada para que os filtros possam ser montados
@type function
@author Pedro Reckel Roberte
@since 27/09/2022
@version 1.0
@param oReport, objeto, (Descri��o do par�metro)
/*/

Static Function PrintReport(oReport)
Local cAlias := GetNextAlias()


oSecCab:BeginQuery() //Relat�rio come�a a ser estruturado
//INICIO DA QUERY
BeginSql Alias cAlias

	SELECT C7_FORNECE,A2_COD, A2_NOME, C7_NUM,C7_EMISSAO, C7_PRODUTO, C7_QUANT FROM %table:SC7% SC7
	INNER JOIN %table:SA2% SA2 ON SE2.E2_FORNECE = SA2.A2_COD AND SC7.C7_LOJA = SA2.A2_LOJA  
	WHERE C7_FORNECE BETWEEN %exp:(MV_PAR01)% AND %exp:(MV_PAR02)%  
	AND SC7.%notdel% = ' ' AND SA2.%notdel% = ' '  

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
