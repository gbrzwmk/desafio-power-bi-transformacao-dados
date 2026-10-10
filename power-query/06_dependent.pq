let
    Fonte = Csv.Document(File.Contents(PastaDados & "\dependent.csv"), [Delimiter=",", Columns=5, Encoding=65001, QuoteStyle=QuoteStyle.Csv]),
    #"Cabeçalhos Promovidos" = Table.PromoteHeaders(Fonte, [PromoteAllScalars=true]),
    #"Tipo Alterado" = Table.TransformColumnTypes(#"Cabeçalhos Promovidos", {{"Essn", type text}, {"Dependent_name", type text}, {"Sex", type text}, {"Bdate", type date}, {"Relationship", type text}}, "en-US"),
    #"Mesclado com Colaborador" = Table.NestedJoin(#"Tipo Alterado", {"Essn"}, employee, {"Ssn"}, "employee", JoinKind.LeftOuter),
    #"Colaborador Expandido" = Table.ExpandTableColumn(#"Mesclado com Colaborador", "employee", {"Nome"}, {"Colaborador"}),
    #"Colunas Renomeadas" = Table.RenameColumns(#"Colaborador Expandido", {{"Dependent_name", "Dependente"}, {"Sex", "Sexo"}, {"Bdate", "Data de Nascimento"}, {"Relationship", "Parentesco"}}),
    #"Colunas Reordenadas" = Table.ReorderColumns(#"Colunas Renomeadas", {"Essn", "Colaborador", "Dependente", "Parentesco", "Sexo", "Data de Nascimento"})
in
    #"Colunas Reordenadas"
