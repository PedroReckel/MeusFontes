#Include "Protheus.Ch"

User Function TRCLI2()
	Local oReport
	Private oSection1
	Private oSection2
	Private cPerg 	 := "TRCLI"

	ValidPerg()
	
	If TRepInUse()
		Pergunte(cPerg,.F.)
		oReport := ReportDef()
		oReport:PrintDialog()
	EndIf
Return

Static Function ReportDef()
	Local oReport
	oReport := TReport():New("TRCLI2","Relatorio de titulos por CLIENTE ",cPerg,{|oReport| PrintReport(oReport)},"Relatorio de Titulos por Cliente")
	
	//SESSÃO 1
	oSection1 := TRSection():New(oReport,"CLIENTE","SA1")
	TRCell():New(oSection1,"A1_COD" ,"SA1")
	TRCell():New(oSection1,"A1_LOJA" ,"SA1")
	TRCell():New(oSection1,"A1_NOME","SA1")
	
	//SESSÃO 2
	oSection2 := TRSection():New(oSection1,"TITULOS","SE1")
	TRCell():New(oSection2,"E1_NUM","SE1")
	TRCell():New(oSection2,"E1_PREFIXO","SE1")
	TRCell():New(oSection2,"E1_EMISSAO","SE1")
	TRCell():New(oSection2,"E1_VALOR","SE1")
	TRCell():New(oSection2,"E1_SALDO","SE1")
	
	//TOTALIZADORES
	TRFunction():New(oSection2:Cell("E1_NUM"),NIL,"COUNT")
	TRFunction():New(oSection2:Cell("E1_VALOR"),NIL,"SUM")
	TRFunction():New(oSection2:Cell("E1_VALOR"),NIL,"MAX")
	TRFunction():New(oSection2:Cell("E1_VALOR"),NIL,"MIN")
	TRFunction():New(oSection2:Cell("E1_SALDO"),NIL,"SUM")
Return oReport

Static Function PrintReport(oReport)
	Local cAlias := GetNextAlias() //Pega o próximo alias aberto
	
	oSection1:BeginQuery()
	BeginSql Alias cAlias
	
		SELECT A1_COD,A1_LOJA,A1_NOME,E1_NUM, E1_PREFIXO, E1_EMISSAO,E1_VALOR, E1_SALDO 
		FROM %table:SE1% SE1
		INNER JOIN %table:SA1% SA1 ON SE1.E1_CLIENTE = SA1.A1_COD
		AND E1_LOJA = A1_LOJA AND SA1.%notdel% AND E1_FILIAL = A1_FILIAL
		WHERE A1_COD BETWEEN %exp:(MV_PAR01)% AND  %exp:(MV_PAR02)% 
		AND SE1.%notdel%
		ORDER BY A1_COD, A1_LOJA
	
	EndSql
	
	oSection1:EndQuery()
	
	oSection2:SetParentQuery()
	oSection2:SetParentFilter({|cCliLoja| (cAlias)->A1_COD+(cAlias)->A1_LOJA = cCliLoja},{|| (cAlias)->A1_COD+(cAlias)->A1_LOJA})
	oSection1:Print()
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
