let
    Fonte = Csv.Document(File.Contents(PastaDados & "\departament.csv"), [Delimiter=",", Columns=5, Encoding=65001, QuoteStyle=QuoteStyle.Csv]),
    #"Cabeçalhos Promovidos" = Table.PromoteHeaders(Fonte, [PromoteAllScalars=true]),
    #"Tipo Alterado" = Table.TransformColumnTypes(#"Cabeçalhos Promovidos", {{"Dname", type text}, {"Dnumber", Int64.Type}, {"Mgr_ssn", type text}, {"Mgr_start_date", type date}, {"Dept_create_date", type date}}, "en-US"),
    #"Vazios para Nulo" = Table.ReplaceValue(#"Tipo Alterado", "", null, Replacer.ReplaceValue, {"Mgr_ssn"}),
    // Verificação: nenhum departamento está sem gerente (Mgr_ssn sem nulos), então não há lacuna a preencher
    #"Colunas Removidas" = Table.RemoveColumns(#"Vazios para Nulo", {"Mgr_start_date", "Dept_create_date"}),
    #"Colunas Renomeadas" = Table.RenameColumns(#"Colunas Removidas", {{"Dname", "Departamento"}})
in
    #"Colunas Renomeadas"
