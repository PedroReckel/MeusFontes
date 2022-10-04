#INCLUDE "Protheus.ch"
#INCLUDE "Topconn.ch"

/*/{Protheus.doc} TRCLI
Relatório no modelo TReport que é responsável por imprimir os dados do cadatro de clientes, mais precisamente os campos CODIGO, LOJA e NOME
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

oReport := TReport():New("TRFOR","Relatório - Títulos por Fornecedor",cPerg,{|oReport| PrintReport(oReport)},"Relatório de pedidos de compras por fonecedor")
oReport:SetLandscape(.T.) // SIGNIFICA QUE O RELATÓRIO SERÁ EM PAISAGEM

//TrSection serve para constrole da seção do relatório, neste caso, teremos somente uma
oSecCab := TRSection():New( oReport , "TITULOS POR FORNECEDOR"  )

/*
TrCell serve para inserir os campos/colunas que você quer no relatório, lembrando que devem ser os mesmos campos que contém na QUERIE
Um detalhe importante, todos os campos contidos nas linhas abaixo, devem estar na querie, mas.. 
você pode colocar campos na querie e adcionar aqui embaixo, conforme a sua necessidade.
*/

// A2_COD, A2_NOME, C7_EMISSAO, C7_PRODUTO, C7_QUANT
TRCell():New( oSecCab, "E2_NUM"    , "SE2")
TRCell():New( oSecCab, "A2_COD"     , "SA2")
TRCell():New( oSecCab, "A2_NOME"    , "SA2")
TRCell():New( oSecCab, "C7_EMISSAO"    , "SC7")
TRCell():New( oSecCab, "C7_QUANT"    , "SC7")


oBreak := TRBreak():New(oSecCab,oSecCab:Cell("C7_FORNECE"),"Sub Total pedidos")
//ESTA LINHA IRÁ CONTAR A QUANTIDADE DE REGISTROS LISTADOS NO RELATÓRIO PARA A ÚNICA SEÇÃO QUE TEMOS
TRFunction():New(oSecCab:Cell("C7_NUM"),NIL,"SUM",oBreak)

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

	SELECT C7_FORNECE,A2_COD, A2_NOME, C7_NUM,C7_EMISSAO, C7_PRODUTO, C7_QUANT FROM %table:SC7% SC7
	INNER JOIN %table:SA2% SA2 ON SE2.E2_FORNECE = SA2.A2_COD AND SC7.C7_LOJA = SA2.A2_LOJA  
	WHERE C7_FORNECE BETWEEN %exp:(MV_PAR01)% AND %exp:(MV_PAR02)%  
	AND SC7.%notdel% = ' ' AND SA2.%notdel% = ' '  

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
