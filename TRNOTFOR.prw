#INCLUDE "Protheus.ch"
#INCLUDE "Topconn.ch"

User Function TRNOTFOR()
Private oReport    := Nil
Private oSection1  := Nil //Primeira Sessão
Private oSection2  := Nil //Segunda  Sessão

Private cPerg 	 := "TRFOR2"

ValidPerg()

Pergunte(cPerg,.T.)

ReportDef()
oReport:PrintDialog()
Return 


Static Function ReportDef()
oReport := TReport():New("TRNOTFOR","Relatório - Títulos por Fornecedor",cPerg,{|oReport| PrintReport(oReport)},"Relatório de Títulos por Fornecedor")
oReport:SetLandscape(.T.) 

oSection1 := TRSection():New(oReport,"FORNECEDOR","SA2")
TRCell():New( oSection1, "A2_COD"      , "SA2")
TRCell():New( oSection1, "A2_LOJA"     , "SA2")
TRCell():New( oSection1, "A2_NOME"     , "SA2")

oSection2 := TRSection():New( oSection1 , "NOTAS FISCAIS","SF1" ) 
TRCell():New( oSection2, "F1_DOC"     , "SF1")
TRCell():New( oSection2, "F1_SERIE"     , "SF1")
TRCell():New( oSection2, "F1_EMISSAO"     , "SF1")
TRCell():New( oSection2, "F1_VALBRUT"     , "SF1")

TRFunction():New(oSection2:Cell("F1_VALBRUT"),,"SUM")
TRFunction():New(oSection2:Cell("F1_DOC"),,"COUNT")

Return 


Static Function PrintReport(oReport)
Local cAlias := GetNextAlias()

oSection1:BeginQuery() 

BeginSql Alias cAlias
  
	SELECT A2_COD,A2_LOJA,A2_NOME, F1_DOC, F1_SERIE,  F1_EMISSAO, F1_VALBRUT FROM %table:SF1% AS SF1
	INNER JOIN %table:SA2% AS SA2 ON SF1.F1_FORNECE = A2_COD AND F1_LOJA = A2_LOJA AND SA2.%notdel%
	WHERE  SF1.%notdel%  AND F1_FORNECE BETWEEN %exp:(MV_PAR01)% AND %exp:(MV_PAR02)% 
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
