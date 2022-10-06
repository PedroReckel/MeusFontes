#INCLUDE "Protheus.ch"
#INCLUDE "Topconn.ch"

/*/{Protheus.doc} TRPEDC
Relatório no modelo TReport que é responsável por trazer as NF de entrada com o campo descrição do produto
@type function
@author Pedro Reckel Roberte
@since 04/10/2022
@version 1.0
/*/
User Function TRNFENTRADA()

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

Static Function ReportDef()

oReport := TReport():New("TRNFENTRADA","Relatório - NF de entrada com o campo descrição do produto",cPerg,{|oReport| PrintReport(oReport)},"Relatório NF de entrada com o campo descrição do produto")
oReport:SetLandscape(.T.) // SIGNIFICA QUE O RELATÓRIO SERÁ EM PAISAGEM

//TrSection serve para constrole da seção do relatório, neste caso, teremos somente uma
oSecCab := TRSection():New( oReport , "Relatório NF de entrada com o campo descrição do produto"  )

/*
TrCell serve para inserir os campos/colunas que você quer no relatório, lembrando que devem ser os mesmos campos que contém na QUERIE
Um detalhe importante, todos os campos contidos nas linhas abaixo, devem estar na querie, mas.. 
você pode colocar campos na querie e adcionar aqui embaixo, conforme a sua necessidade.
*/

// D1_FILIAL, D1_ITEM, D1_COD, B1_DESC, D1_UM, D1_QUANT, D1_VUNIT, D1_FORNECE, D1_LOJA, D1_EMISSAO

TRCell():New( oSecCab, "D1_FILIAL"    , "SD1")
TRCell():New( oSecCab, "D1_ITEM"     , "SD1")
TRCell():New( oSecCab, "D1_COD"    , "SD1")
TRCell():New( oSecCab, "B1_DESC"    , "SB1")
TRCell():New( oSecCab, "D1_UM"    , "SD1")
TRCell():New( oSecCab, "D1_QUANT"    , "SD1")
TRCell():New( oSecCab, "D1_VUNIT"    , "SD1")
TRCell():New( oSecCab, "D1_FORNECE"    , "SD1")
TRCell():New( oSecCab, "D1_LOJA"    , "SD1")
TRCell():New( oSecCab, "D1_EMISSAO"    , "SD1")

oBreak := TRBreak():New(oSecCab,oSecCab:Cell("D1_ITEM"),"Sub Total Pedidos")

//ESTA LINHA IRÁ CONTAR A QUANTIDADE DE REGISTROS LISTADOS NO RELATÓRIO PARA A ÚNICA SEÇÃO QUE TEMOS
TRFunction():New(oSecCab:Cell("D1_COD"),NIL,"COUNT",oBreak)
//TRFunction():New(oSecCab:Cell("E2_SALDO"),NIL,"SUM",oBreak)

//TRFunction():New(oSecCab:Cell("C7_FORNECE"),,"COUNT")

Return 


/*/{Protheus.doc} PrintReport
Nesta função é inserida a query utilizada para exibição dos dados;
A função de PERGUNTAS  é chamada para que os filtros possam ser montados
@type function
@author Pedro Reckel Roberte
@since 04/10/2022
@version 1.0
@param oReport, objeto, (Descrição do parâmetro)
/*/Static Function PrintReport(oReport)
Local cAlias := GetNextAlias()


oSecCab:BeginQuery() //Relatório começa a ser estruturado
//INICIO DA QUERY
BeginSql Alias cAlias

SELECT  
	D1_FILIAL AS Filial,
	D1_ITEM AS Item,
	D1_COD AS Cod_produto,
	B1_DESC AS Descrição,
	D1_UM AS Unidade,
	D1_QUANT AS Quantidade,
	D1_VUNIT AS Vlr_unidade,
	D1_TOTAL AS Total,
	D1_FORNECE AS Cod_fornecedor,
	D1_LOJA AS Loja,
	CONVERT(VARCHAR,CONVERT(DATE, SD1.D1_EMISSAO),103) AS Data_emissao
FROM %table:SD1%  SD1
	INNER JOIN %table:SB1% SB1 ON SB1.B1_COD = SD1.D1_COD
WHERE D1_ITEM BETWEEN %exp:(MV_PAR01)% AND %exp:(MV_PAR02)% AND SD1.%notdel% AND SB1.%notdel%

/*/
	SELECT C7_FORNECE, A2_NOME, C7_NUM, C7_EMISSAO,C7_PRODUTO, C7_QUANT FROM %table:SC7% SC7
	INNER JOIN %table:SA2% SA2 ON SC7.C7_FORNECE = SA2.A2_COD AND SC7.C7_LOJA = SA2.A2_LOJA 
	WHERE C7_FORNECE BETWEEN %exp:(MV_PAR01)% AND %exp:(MV_PAR02)%  
	AND SC7.%notdel% and SA2.%notdel%
/*/

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
@since 04/10/2022
@version 1.0/*/
Static Function ValidPerg()
	Local aArea  := SX1->(GetArea())
	Local aRegs := {}
	Local i,j

	aadd( aRegs, { cPerg,"01","Item de ?","Item de ?","Item de ?","mv_ch1","C", 6,0,0,"G","","mv_par01","","","mv_par01"," ","",""," ","","","","","","","","","","","","","","","","","","SD1"          } )
	aadd( aRegs, { cPerg,"02","Item ate ?","Item ate ?","Item ate ?","mv_ch2","C", 6,0,0,"G","","mv_par02","","","mv_par02"," ","",""," ","","","","","","","","","","","","","","","","","","SD1"       } )

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
