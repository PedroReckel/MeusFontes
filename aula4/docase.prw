/*

Do case
    Case <Condição>
        - Comandos
        - Comandos

    Case <Condição>
        - Comandos
        - Comandos

    Case <Condição>
        - Comandos
        - Comandos

    OtherWise (Não obrigatório)
        - Comandos
        - Comandos

EndCase

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

User Function Do_case()
    Local nNumero := 0

    Do Case
        Case nNumero > 0 
            MsgAlert('Numero positivo', 'Validar numero')
        Case nNumero < 0 
            MsgAlert('Numero negativo', 'Validar numero')
        Otherwise
            MsgAlert('O numeoro é zero', 'Validar numero')
    EndCase
    
Return 
