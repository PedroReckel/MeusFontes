#INCLUDE "PROTHEUS.CH"

/*/{Protheus.doc} ExecFonte
    (Essa user function tende a executar uma funcao de usuario que seja informada por parametro
    A partir do release 25 do protheus nao e mais possi­vel executar funcoes de usuario pelo 
    lancamento padronizado. Sendo assim, criamos essa rotina para que seja colocada no menu do Protheus 12
    e por meio dela o desenvolver possa executar suas rotinas sem a necessidade de ficar colocando-as nos menus)
    @type Function
    @author Augusto
    @since 04/06/2020
    @version 0.02
    @see (https://logostechnology.zendesk.com/hc/pt-br/articles/360049701433-Como-chamar-uma-fun%C3%A7%C3%A3o-de-usu%C3%A1rio-no-Protheus-)
/*/

USER FUNCTION ExecFonte()

    LOCAL cNomefuncao    := ""  //variavel que deve receber o nome do fonte digitado 
    LOCAL aPergs        := {}  //Array que armazena as perguntas do ParamBox()

//adiciona elementos no array de perguntas 
    aAdd( aPergs , {1, "Nome do fonte ", space(10), "", "", "", "", 40, .T.} ) 
 
//If que valida o OK do parambox() e passa o conteudo do parametro para a variavel
    IF ParamBox(aPergs, "execfonte.prw" )
        cNomefuncao := ALLTRIM( MV_PAR01 )
    ELSE
        RETURN
    ENDIF

//Caso o usuario digite o U_ ou () no nome do fonte, retira esses caracteres
    cNomefuncao := StrTran( cNomefuncao , "U_" , "" )
    cNomefuncao := StrTran( cNomefuncao , "()" , "" )

//Valida se a funcao existe no rpo
    IF !FindFunction( cNomefuncao )
        MsgAlert( "Funcao nao encontrada no RPO" , "ops!" )
        RETURN u_ExecFonte()
    ENDIF

//complementa a variavel e executa macro substituicao chamando a rotina
    cNomefuncao := "U_"+cNomefuncao+"()"
    &cNomefuncao

RETURN
