#INCLUDE "TOPCONN.CH"
#INCLUDE "PROTHEUS.CH"                                                      

/*/{Protheus.doc} ValidPerg
FUNÇÃO RESPONSÁVEL POR CRIAR AS PERGUNTAS NA SX1 
@type function
@author Pedro Reckel Roberte
@since 27/09/2022
@version 1.0
/*/

User Function SQLEXCEL()
Local cAlias := GetNextAlias() //Declarei meu ALIAS

Private aCabec := {} //ARRAY DO CABEÇALHO
Private aDados := {} //ARRAY QUE ARMAZENARÁ OS DADOS

Private cPerg 	 := "TRFOR" //VARIÁVEL QUE ARMAZENA O NOME DO GRUPO DE PERGUNTAS

//Função que cria as perguntas/filtros que iremos usar no relatório, na SX1
ValidPerg() 

//Função responsável por chamar a pergunta criada na função ValidaPerg, a variável PRIVATE cPerg, é passada.
Pergunte(cPerg,.T.)


//COMEÇO A MINHA CONSULTA SQL
BeginSql Alias cAlias
		SELECT E2_PREFIXO, E2_NUM, A2_COD,A2_NOME, E2_VALOR FROM %table:SE2% SE2
		INNER JOIN %table:SA2% SA2 ON SE2.E2_FORNECE = SA2.A2_COD AND E2_LOJA = A2_LOJA  
		WHERE E2_FORNECE BETWEEN %exp:(MV_PAR01)% AND %exp:(MV_PAR02)%  //FILTRO WHERE
		AND SE2.%notdel% AND SA2.%notdel%  
EndSql //FINALIZO A MINHA QUERY
	
//CABEÇALHO
aCabec := {"PREFIXO","TITULO","CODFORNECEDOR","NOMEFORNECEDOR","VALORDOTITULO"}

While !(cAlias)->(Eof())

	aAdd(aDados,{E2_PREFIXO,E2_NUM, A2_COD, A2_NOME, E2_VALOR})
	
	(cAlias)->(dbSkip()) //PASSAR PARA O PRÓXIMO REGISTRO                                     
enddo

//JOGO TODO CONTEÚDO DO ARRAY PARA O EXCEL
DlgtoExcel({{"ARRAY","Relatório de títulos a pagar", aCabec, aDados}})
	                                          
(cAlias)->(dbClosearea())	

return


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
			Reclock('SX1', .T.) //FUnção utilizada para gravar dados em um arquivo/tabela
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
