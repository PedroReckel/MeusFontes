/*/{Protheus.doc} User Function nomeFunction
    (long_description)
    @type  Function
    @author Pedro Reckel Roberte
    @since 15/10/2022
    @version version
    @param param_name, param_type, param_descr
    @return return_var, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
/*/

/*/
Local   -> Visível apenas dentro da função onde foi criada.
Private -> Visível na função onde ela foi criada e nas funções seguintes.
Public  -> Visível em todas as funções a partir do momento que ela foi criada.  
Static  -> Visível apenas dentro da função onde foi criada. Pode ser declarada fora da função (no cabeçalho do fonte)
/*/

Static cVar5 := "Static"  // Não está visivel em outro fonte

User Function Func1()
    Local cVar1 := "Local"
    Private cVar2 := "Private"

    u_Func2()

    Alert(cVar3)
    Alert(cVar4) // Uma outra diferença entre public e private é que a private é disponivel nas funções que são chamadas a serguir da função que ela foi criada  
Return 

User Function Func2()
    Public cVar3 := "Public"
    Public cVar4 := "Private cVar4"

    Alert(cVar2) // Private
    Alert(cVar3) // Public 

    U_Func4()
Return 

User Function Func4()
    Alert(cVar3) // Public
    Alert(cVar2) // Private
Return
