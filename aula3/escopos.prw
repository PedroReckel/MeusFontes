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
Local   -> Vis�vel apenas dentro da fun��o onde foi criada.
Private -> Vis�vel na fun��o onde ela foi criada e nas fun��es seguintes.
Public  -> Vis�vel em todas as fun��es a partir do momento que ela foi criada.  
Static  -> Vis�vel apenas dentro da fun��o onde foi criada. Pode ser declarada fora da fun��o (no cabe�alho do fonte)
/*/

Static cVar5 := "Static"  // N�o est� visivel em outro fonte

User Function Func1()
    Local cVar1 := "Local"
    Private cVar2 := "Private"

    u_Func2()

    Alert(cVar3)
    Alert(cVar4) // Uma outra diferen�a entre public e private � que a private � disponivel nas fun��es que s�o chamadas a serguir da fun��o que ela foi criada  
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
