let
    Fonte = Csv.Document(File.Contents(PastaDados & "\works_on.csv"), [Delimiter=",", Columns=3, Encoding=65001, QuoteStyle=QuoteStyle.Csv]),
    #"Cabeçalhos Promovidos" = Table.PromoteHeaders(Fonte, [PromoteAllScalars=true]),
    #"Tipo Alterado" = Table.TransformColumnTypes(#"Cabeçalhos Promovidos", {{"Essn", type text}, {"Pno", Int64.Type}, {"Hours", type number}}, "en-US"),
    // Verificação de horas: nenhum valor nulo ou negativo; um registro com 0 h (James Borg em Reorganization) foi mantido e sinalizado
    #"Horas Zeradas Sinalizadas" = Table.AddColumn(#"Tipo Alterado", "Horas Zeradas", each [Hours] = 0, type logical),
    #"Mesclado com Colaborador" = Table.NestedJoin(#"Horas Zeradas Sinalizadas", {"Essn"}, employee, {"Ssn"}, "employee", JoinKind.LeftOuter),
    #"Colaborador Expandido" = Table.ExpandTableColumn(#"Mesclado com Colaborador", "employee", {"Nome"}, {"Colaborador"}),
    #"Mesclado com Projeto" = Table.NestedJoin(#"Colaborador Expandido", {"Pno"}, project, {"Pnumber"}, "project", JoinKind.LeftOuter),
    #"Projeto Expandido" = Table.ExpandTableColumn(#"Mesclado com Projeto", "project", {"Projeto"}, {"Projeto"}),
    #"Colunas Renomeadas" = Table.RenameColumns(#"Projeto Expandido", {{"Hours", "Horas"}}),
    #"Colunas Reordenadas" = Table.ReorderColumns(#"Colunas Renomeadas", {"Essn", "Colaborador", "Pno", "Projeto", "Horas", "Horas Zeradas"})
in
    #"Colunas Reordenadas"
