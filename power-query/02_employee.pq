let
    Fonte = Csv.Document(File.Contents(PastaDados & "\employee.csv"), [Delimiter=",", Columns=10, Encoding=65001, QuoteStyle=QuoteStyle.Csv]),
    #"Cabeçalhos Promovidos" = Table.PromoteHeaders(Fonte, [PromoteAllScalars=true]),
    // Salary como Número Decimal (double) — valor monetário
    #"Tipo Alterado" = Table.TransformColumnTypes(#"Cabeçalhos Promovidos", {{"Fname", type text}, {"Minit", type text}, {"Lname", type text}, {"Ssn", type text}, {"Bdate", type date}, {"Address", type text}, {"Sex", type text}, {"Salary", type number}, {"Super_ssn", type text}, {"Dno", Int64.Type}}, "en-US"),
    // Nulos: só Super_ssn tem nulo (James Borg, diretor em Headquarters). Ele é mantido: é o topo da hierarquia, não um erro.
    #"Vazios para Nulo" = Table.ReplaceValue(#"Tipo Alterado", "", null, Replacer.ReplaceValue, {"Minit", "Super_ssn"}),
    // Coluna complexa Address ("731-Fondren-Houston-TX"): dividida pelo delimitador mais à direita (Estado, Cidade) e mais à esquerda (Número); o que sobra é a Rua (ex.: "Fire-Oak")
    #"Endereço Dividido - Estado" = Table.SplitColumn(#"Vazios para Nulo", "Address", Splitter.SplitTextByEachDelimiter({"-"}, QuoteStyle.Csv, true), {"Address.1", "Estado"}),
    #"Endereço Dividido - Cidade" = Table.SplitColumn(#"Endereço Dividido - Estado", "Address.1", Splitter.SplitTextByEachDelimiter({"-"}, QuoteStyle.Csv, true), {"Address.2", "Cidade"}),
    #"Endereço Dividido - Número e Rua" = Table.SplitColumn(#"Endereço Dividido - Cidade", "Address.2", Splitter.SplitTextByEachDelimiter({"-"}, QuoteStyle.Csv, false), {"Número", "Rua"}),
    #"Tipo Alterado1" = Table.TransformColumnTypes(#"Endereço Dividido - Número e Rua", {{"Número", type text}, {"Rua", type text}, {"Cidade", type text}, {"Estado", type text}}),
    // Nome e sobrenome mesclados em uma única coluna
    #"Nome Mesclado" = Table.CombineColumns(#"Tipo Alterado1", {"Fname", "Lname"}, Combiner.CombineTextByDelimiter(" ", QuoteStyle.None), "Nome"),
    // Mescla employee (base) x departament: junção externa esquerda, para não perder colaborador sem departamento
    #"Mesclado com Departamento" = Table.NestedJoin(#"Nome Mesclado", {"Dno"}, departament, {"Dnumber"}, "departament", JoinKind.LeftOuter),
    #"Departamento Expandido" = Table.ExpandTableColumn(#"Mesclado com Departamento", "departament", {"Departamento"}, {"Departamento"}),
    // Junção colaborador x gerente: a própria tabela (etapa "Nome Mesclado") é usada como lado direito, Super_ssn = Ssn
    #"Mesclado com Gerente" = Table.NestedJoin(#"Departamento Expandido", {"Super_ssn"}, #"Nome Mesclado", {"Ssn"}, "gerente", JoinKind.LeftOuter),
    #"Gerente Expandido" = Table.ExpandTableColumn(#"Mesclado com Gerente", "gerente", {"Nome"}, {"Gerente"}),
    #"Gerente Nulo Preenchido" = Table.ReplaceValue(#"Gerente Expandido", null, "Sem gerente (diretor)", Replacer.ReplaceValue, {"Gerente"}),
    #"Colunas Removidas" = Table.RemoveColumns(#"Gerente Nulo Preenchido", {"Minit"}),
    #"Colunas Renomeadas" = Table.RenameColumns(#"Colunas Removidas", {{"Sex", "Sexo"}, {"Bdate", "Data de Nascimento"}, {"Salary", "Salário"}}),
    #"Colunas Reordenadas" = Table.ReorderColumns(#"Colunas Renomeadas", {"Ssn", "Nome", "Sexo", "Data de Nascimento", "Salário", "Número", "Rua", "Cidade", "Estado", "Dno", "Departamento", "Super_ssn", "Gerente"})
in
    #"Colunas Reordenadas"
