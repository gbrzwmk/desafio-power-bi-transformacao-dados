let
    Fonte = Csv.Document(File.Contents(PastaDados & "\project.csv"), [Delimiter=",", Columns=4, Encoding=65001, QuoteStyle=QuoteStyle.Csv]),
    #"Cabeçalhos Promovidos" = Table.PromoteHeaders(Fonte, [PromoteAllScalars=true]),
    #"Tipo Alterado" = Table.TransformColumnTypes(#"Cabeçalhos Promovidos", {{"Pname", type text}, {"Pnumber", Int64.Type}, {"Plocation", type text}, {"Dnum", Int64.Type}}),
    #"Mesclado com Departamento" = Table.NestedJoin(#"Tipo Alterado", {"Dnum"}, departament, {"Dnumber"}, "departament", JoinKind.LeftOuter),
    #"Departamento Expandido" = Table.ExpandTableColumn(#"Mesclado com Departamento", "departament", {"Departamento"}, {"Departamento"}),
    #"Colunas Renomeadas" = Table.RenameColumns(#"Departamento Expandido", {{"Pname", "Projeto"}, {"Plocation", "Local do Projeto"}})
in
    #"Colunas Renomeadas"
