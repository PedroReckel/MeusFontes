/*/{Protheus.doc} User Function nomeFunction
    (long_description)
    @type  Function
    @author Pedro 
    @since 15/10/2022
    @version version
    @param param_name, param_type, param_descr
    @return return_var, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
/*/

/*/

Char/Character: � utilizado parar gravar informa��es caracter.
Number: � utilizado para gravar infoma��es do tipo num�rico.
Date: � utilizado para gravar uma data.
Logical (Boolean): � utilizado para gravar uma cole��o de dados.
Array: � utilizado para gravar uma cole��o de dados.
Block/codeblock (Bloco de c�digo): � utilizado para gravar uma cole��o de comandos que podem ser macroexecutados.
Object: � utilizado para gravar um objeto que pode ser utilizado para criar uma interface.
Null: Ou Nullo. 

/*/

User Function VarTipos()
    Local cTexto   := "Variavel do tipo caracter"
    Local nNumero  := 0
    Local dDate    := CTOD("20221015")
    Local lLogical := .T. // .F.
    Local aVetor   := {"Pedro Reckel Roberte", 21, .T.}
    Local bBloco   := { || 5 + 10 }
    Local oObjeto  := NIL
    Local xNull    := NIL

    alert(cTexto)
    cTexto := 10
    alert(cTexto)
Return 
