/*

IF <condição> (Obrigatório)
    - Comandos
    - Comandos
ELSEIF <Condição> (Não obrigatório)
    - Comandos
    - Comandos
ELSEIF <Condição> (Não obrigatório)
    - Comandos
    - Comandos
ELSE (Não obrigatório)
    - Comandos
    - Comandos
ENDIF (Obrigatório)

*/

/*/{Protheus.doc} User Function nomeFunction
    (long_description)
    @type  Function
    @author Pedro Reckel Roberte 
    @since 16/10/2022
    @version version
    @param param_name, param_type, param_descr
    @return return_var, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
/*/

User Function VldVenda()
    Local nEstoque := 100
    Local nVenda := 105
    Local cEstNeg := "sim"

    If nEstoque > nVenda 
        msgalert('Produto em estoque!', 'Validar venda')
        ElseIf nEstoque = nVenda 
            msgalert('Esse é o ultimo produto em estoque!', 'Validar venda')
        ElseIf nEstoque < nVenda .and. cEstNeg = 'sim'
            msgalert('Pode vender, porém, o saldo em estoque ficará negativo.', 'Validar venda')
        Else 
            msgalert('Produto não tem no estoque!', 'Validar venda')
    EndIf

Return 
