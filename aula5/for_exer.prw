/*



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

User Function ExerFor()
    Local nInicio := 0
    Local nFim := 100

    For nInicio := 10 To nFim Step 10
        If nInicio == 90
            exit
        EndIf
        
        If nInicio == 50
            loop
        EndIf
        Alert(nInicio)
    Next    
    
Return 
