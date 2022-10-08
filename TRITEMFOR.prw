#INCLUDE "Protheus.ch"
#INCLUDE "Topconn.ch"

User Function TRITEMFOR()
Private oReport    := Nil
Private oSection1  := Nil //Primeira Sessão
Private oSection2  := Nil //Segunda  Sessão

Private cPerg 	 := "TRFOR"

ValidPerg()

Pergunte(cPerg,.T.)

ReportDef()
oReport:PrintDialog()
Return 


Static Function ReportDef()
oReport := TReport():New("TRITEMFOR","Relatório - Produtos Comprados por Fornecedor",cPerg,{|oReport| PrintReport(oReport)},"Relatório Produtos Comprados por Fornecedor")
oReport:SetLandscape(.T.) 

oSection1 := TRSection():New(oReport,"FORNECEDOR","SA2")
TRCell():New( oSection1, "A2_COD"      , "SA2")
TRCell():New( oSection1, "A2_LOJA"     , "SA2")
TRCell():New( oSection1, "A2_NOME"     , "SA2")

oSection2 := TRSection():New( oSection1 , "ITENS DAS NF DE ENTRADA",{"SD1","SB1"} ) // Quando tiver mais de uma tabela tem que instânciar as duas
TRCell():New( oSection2, "B1_COD"       , "SB1")
TRCell():New( oSection2, "B1_DESC"      , "SB1")
TRCell():New( oSection2, "D1_QUANT"   , "SD1")
TRCell():New( oSection2, "D1_VUNIT"   , "SD1")
TRCell():New( oSection2, "D1_TOTAL"   , "SD1")

TRFunction():New(oSection2:Cell("D1_QUANT"),,"SUM")
TRFunction():New(oSection2:Cell("D1_TOTAL"),,"SUM")

Return 


Static Function PrintReport(oReport)
Local cAlias := GetNextAlias()

oSection1:BeginQuery() // Inicio Query

BeginSql Alias cAlias
  
SELECT 
	A2_COD, 
	A2_LOJA, 
	A2_NOME, 
	B1_COD, 
	B1_DESC, 
	D1_QUANT,
	D1_VUNIT,
	D1_TOTAL 
FROM %table:SD1%  AS SD1
	INNER JOIN %table:SA2%  AS SA2 ON SD1.D1_FORNECE = A2_COD AND D1_LOJA   = A2_LOJA   AND SA2.%notdel%
	INNER JOIN %table:SB1%  AS SB1 ON SD1.D1_COD     = B1_COD AND B1_FILIAL = D1_FILIAL AND SB1.%notdel%
WHERE  SD1.%notdel%    AND A2_COD BETWEEN %exp:(MV_PAR01)% AND %exp:(MV_PAR02)% 
ORDER BY A2_COD, A2_LOJA
  
EndSql

oSection1:EndQuery() //Fim da Query
oSection2:SetParentQuery() 
oSection2:SetParentFilter({|cForLoja| (cAlias)->A2_COD+(cAlias)->A2_LOJA = cForLoja},{|| (cAlias)->A2_COD+(cAlias)->A2_LOJA})

oSection1:Print() 

//O Alias utilizado para execução da querie é fechado.
(cAlias)->(DbCloseArea())

Return 


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
