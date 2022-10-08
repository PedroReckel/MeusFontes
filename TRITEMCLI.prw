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

oSection1 := TRSection():New(oReport,"Cliente","SA1")
TRCell():New( oSection1, "A1_COD"      , "SA1")
TRCell():New( oSection1, "A1_LOJA"     , "SA1")
TRCell():New( oSection1, "A1_NOME"     , "SA1")

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
	A1_COD, 
	A1_LOJA, 
	A1_NOME, 
	B1_COD, 
	B1_DESC, 
	D1_QUANT,
	D1_VUNIT,
	D1_TOTAL 
FROM %table:SD1%  AS SD1
	INNER JOIN %table:SA1%  AS SA1 ON SD1.D1_FORNECE = A1_COD AND D1_LOJA   = A1_LOJA   AND SA1.%notdel%
	INNER JOIN %table:SB1%  AS SB1 ON SD1.D1_COD     = B1_COD AND B1_FILIAL = D1_FILIAL AND SB1.%notdel%
WHERE  SD1.%notdel%    AND A1_COD BETWEEN %exp:(MV_PAR01)% AND %exp:(MV_PAR02)% 
ORDER BY A1_COD, A1_LOJA
  
EndSql

oSection1:EndQuery() //Fim da Query
oSection2:SetParentQuery() 
oSection2:SetParentFilter({|cCliLoja| (cAlias)->A1_COD+(cAlias)->A1_LOJA = cCliLoja},{|| (cAlias)->A1_COD+(cAlias)->A1_LOJA})

oSection1:Print() 

//O Alias utilizado para execução da querie é fechado.
(cAlias)->(DbCloseArea())

Return 


Static Function ValidPerg()
	Local aArea  := SX1->(GetArea())
	Local aRegs := {}
	Local i,j

	aadd( aRegs, { cPerg,"01","Cliente de ?","Cliente de ?","Cliente de ?","mv_ch1","C", 6,0,0,"G","","mv_par01","","","mv_par01"," ","",""," ","","","","","","","","","","","","","","","","","","SA1"          } )
	aadd( aRegs, { cPerg,"02","Cliente ate ?","Cliente ate ?","Cliente ate ?","mv_ch2","C", 6,0,0,"G","","mv_par02","","","mv_par02"," ","",""," ","","","","","","","","","","","","","","","","","","SA1"       } )

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
