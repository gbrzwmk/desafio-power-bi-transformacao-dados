let
    Fonte = Csv.Document(File.Contents(PastaDados & "\dept_locations.csv"), [Delimiter=",", Columns=2, Encoding=65001, QuoteStyle=QuoteStyle.Csv]),
    #"Cabeçalhos Promovidos" = Table.PromoteHeaders(Fonte, [PromoteAllScalars=true]),
    #"Tipo Alterado" = Table.TransformColumnTypes(#"Cabeçalhos Promovidos", {{"Dnumber", Int64.Type}, {"Dlocation", type text}}),
    // Mescla (não acréscimo): traz o nome do departamento para cada linha de localização pela chave Dnumber
    #"Mesclado com Departamento" = Table.NestedJoin(#"Tipo Alterado", {"Dnumber"}, departament, {"Dnumber"}, "departament", JoinKind.LeftOuter),
    #"Departamento Expandido" = Table.ExpandTableColumn(#"Mesclado com Departamento", "departament", {"Departamento"}, {"Departamento"}),
    #"Colunas Reordenadas" = Table.ReorderColumns(#"Departamento Expandido", {"Dnumber", "Departamento", "Dlocation"}),
    // Departamento e localização mesclados: cada combinação vira uma chave única (base para o modelo estrela)
    #"Departamento-Local Mesclado" = Table.CombineColumns(#"Colunas Reordenadas", {"Departamento", "Dlocation"}, Combiner.CombineTextByDelimiter("-", QuoteStyle.None), "Departamento_Local")
in
    #"Departamento-Local Mesclado"
