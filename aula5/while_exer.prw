/*

While <Condição>
    - Comandos
    - Comandos
    - Comandos
    Exit
    Loop 
    - Comandos
    - Comandos
    - Comandos
End    

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

User Function Exerwhile()
    Local nCont := 0

    while nCont <= 10

        // If nCont == 5
        //     exit
        // EndIf        

        alert(nCont)

        If nCont % 2 == 0
            Alert('O numero é par')
        EndIf

        nCont++    
    end

Alert('Finalizada a execução da rotina!')

Return 
