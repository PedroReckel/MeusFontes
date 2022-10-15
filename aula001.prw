/*/{Protheus.doc} nomeFunction
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

/*

User functions -> {
    - Podem ser criadas por usuários e pela TOTVS;  
    - Podem ser acessadas do mesmo fonte onde foram criadas ou de outro fonte;
}

Static functions -> {
    - Podem ser criadas por usuários e pela TOTVS;
    - Só podem ser acessadas se a função estiver dentro do mesmo fonte onde se criou a mesma; 
}

Functions -> {
    - Podem ser criadas apenas pela TOTVS;
    - Acesso a partir de outro fonte;
}

*/

User Function aula001()
    alert("Hello World!!!")
    func2()
Return 


Static Function func2()
    alert("Função 2!!")
Return 
