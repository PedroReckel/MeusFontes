#INCLUDE 'Protheus.ch'
#INCLUDE 'Topconn.ch' // Adicionando biblioteca

/*/{Protheus.doc} nomeFunction
    (long_description)
    @type  Function
    @author Pedro Reckel Roberte
    @since 26/09/2022
    @version version
    @param param_name, param_type, param_descr
    @return return_var, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
    /*/

User Function SB1EXCEL()
    Local aDados := {}  // Array para armazenar os dados da TABELA DE PRODUTOS
    Local aCabec := {}  // Array para armazenar o conteúdo do cabeçalho
    Local cQuery := ""  // Variável que armazenará a query

    aCabec := {"FILIAL","CODIGO","DESCRICAO","TIPO"}

    cQuery := " SELECT B1_FILIAL, B1_COD, B1_DESC, B1_TIPO FROM " +RetSqlName("SB1")+ " AS SB1 "
    cQuery += " WHERE D_E_L_E_T_ = ' ' "

    TCQUERY cQuery new Alias "SB1" // Existe outra forma mais segura e dinamica de realizar a execução da query

    If Select("SB1") > 0
        SB1->(DBCLOSEAREA())
    EndIF

    While !SB1->(EOF()) // Enquanto não chegar no final do arquivo, continue lendo
        
        aAdd(aDados, {SB1->B1_FILIAL, SB1->CODIGO, SB1->B1_DESC, SB1->B1_TIPO})

    SB1->(dbSkip())
    Enddo

SB1->(DBCLOSEAREA())

DlgToExcel({{"ARRAY","Relatorio Produtos", aCabec, aDados}})

Return 
