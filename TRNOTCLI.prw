#INCLUDE "Protheus.ch"
#INCLUDE "Topconn.ch"

User Function TRNOTFOR()
Private oReport    := Nil
Private oSection1  := Nil //Primeira Sessão
Private oSection2  := Nil //Segunda  Sessão

Private cPerg 	 := "TRCLI"

ValidPerg()

Pergunte(cPerg,.T.)

ReportDef()
oReport:PrintDialog()
Return 


Static Function ReportDef()
oReport := TReport():New("TRNOTCLI","Relatório - NF's por cliente",cPerg,{|oReport| PrintReport(oReport)},"Relatório de NF's por cliente")
oReport:SetLandscape(.T.) 

oSection1 := TRSection():New(oReport,"Clientes","SA1")
TRCell():New( oSection1, "A1_COD"      , "SA1")
TRCell():New( oSection1, "A1_LOJA"     , "SA1")
TRCell():New( oSection1, "A1_NOME"     , "SA1")

oSection2 := TRSection():New( oSection1 , "NOTAS FISCAIS","SF2" ) 
TRCell():New( oSection2, "F2_DOC"     , "SF2")
TRCell():New( oSection2, "F2_SERIE"     , "SF2")
TRCell():New( oSection2, "F2_EMISSAO"     , "SF2")
TRCell():New( oSection2, "F2_VALBRUT"     , "SF2")

TRFunction():New(oSection2:Cell("F2_VALBRUT"),,"SUM")
TRFunction():New(oSection2:Cell("F2_DOC"),,"COUNT")

Return 


Static Function PrintReport(oReport)
Local cAlias := GetNextAlias()

oSection1:BeginQuery() 

BeginSql Alias cAlias
  
	SELECT A1_COD,A1_LOJA,A1_NOME, F2_DOC, F2_SERIE,  F2_EMISSAO, F2_VALBRUT FROM %table:SF2% AS SF2
	INNER JOIN %table:SA1% AS SA1 ON SF2.F2_CLIENTE = A1_COD AND F2_LOJA = A1_LOJA AND SA1.%notdel%
	WHERE  SF2.%notdel%  AND F2_CLIENTE BETWEEN %exp:(MV_PAR01)% AND %exp:(MV_PAR02)% 
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
