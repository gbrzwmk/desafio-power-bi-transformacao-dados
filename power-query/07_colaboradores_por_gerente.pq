let
    Fonte = employee,
    // O diretor (sem Super_ssn) não entra na contagem, pois não tem gerente
    #"Linhas Filtradas" = Table.SelectRows(Fonte, each [Super_ssn] <> null),
    #"Linhas Agrupadas" = Table.Group(#"Linhas Filtradas", {"Super_ssn", "Gerente"}, {{"Colaboradores", each Table.RowCount(_), Int64.Type}}),
    #"Linhas Classificadas" = Table.Sort(#"Linhas Agrupadas", {{"Colaboradores", Order.Descending}})
in
    #"Linhas Classificadas"
