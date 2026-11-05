extends RefCounted

# Banco dinâmico refinado da V0.12.1.
# Cada minigame possui 30 itens por dificuldade e cada partida sorteia 6.
# Refinamentos desta versão:
# - alternativas mais curtas e objetivas;
# - explicações sem repetir literalmente a resposta correta;
# - siglas acompanhadas de termo completo;
# - aprofundamento em ENADE, concursos, Ciência de Dados, Pandas, BI, DW, Governança, Segurança e DevOps.
# O seletor prioriza diversidade de topic e evita repetir os mesmos ids em partidas consecutivas da sessão.
const ROUND_COUNT := 6

const BANKS := {
	"show_do_bilhao": {
		"facil": [
			{
				"id": "show_facil_desenvolvimento_web_html_01",
				"topic": "Desenvolvimento Web",
				"pergunta": "Qual conceito corresponde a esta descrição? Estrutura o conteúdo de páginas web usando marcações como títulos, parágrafos, links e seções.",
				"opcoes": {
					"A": "HTML",
					"B": "Fila",
					"C": "Função",
					"D": "Requisito"
				},
				"resposta": "A",
				"motivos": {
					"A": "HTML significa HyperText Markup Language, ou Linguagem de Marcação de Hipertexto. Ele define a estrutura semântica de uma página web, como títulos, textos, listas, links e formulários."
				}
			},
			{
				"id": "show_facil_front_end_css_02",
				"topic": "Front-end",
				"pergunta": "Qual conceito corresponde a esta descrição? Controla cores, espaçamentos, fontes e layout visual de uma página web.",
				"opcoes": {
					"A": "Backup",
					"B": "CSS",
					"C": "Git",
					"D": "Teste"
				},
				"resposta": "B",
				"motivos": {
					"B": "CSS significa Cascading Style Sheets, ou Folhas de Estilo em Cascata. Ele separa a apresentação visual da estrutura HTML e permite criar interfaces responsivas e organizadas."
				}
			},
			{
				"id": "show_facil_programacao_web_javascript_03",
				"topic": "Programação Web",
				"pergunta": "Qual conceito corresponde a esta descrição? Adiciona comportamento dinâmico em páginas e aplicações web.",
				"opcoes": {
					"A": "MFA",
					"B": "Cliente",
					"C": "JavaScript",
					"D": "Bug"
				},
				"resposta": "C",
				"motivos": {
					"C": "JavaScript é uma linguagem de programação muito usada no navegador e também no back-end. Ela permite validar formulários, manipular o DOM, consumir APIs e criar interações dinâmicas."
				}
			},
			{
				"id": "show_facil_back_end_api_04",
				"topic": "Back-end",
				"pergunta": "Qual conceito corresponde a esta descrição? Permite que sistemas diferentes se comuniquem por meio de regras e pontos de acesso definidos.",
				"opcoes": {
					"A": "UX",
					"B": "Servidor",
					"C": "Dashboard",
					"D": "API"
				},
				"resposta": "D",
				"motivos": {
					"D": "API significa Application Programming Interface, ou Interface de Programação de Aplicações. Ela expõe funcionalidades para que sistemas, aplicativos ou serviços troquem dados de forma padronizada."
				}
			},
			{
				"id": "show_facil_banco_de_dados_banco_de_dados_05",
				"topic": "Banco de Dados",
				"pergunta": "Qual conceito corresponde a esta descrição? Organiza e armazena dados para consulta, atualização e uso por sistemas.",
				"opcoes": {
					"A": "Banco de Dados",
					"B": "Acessibilidade",
					"C": "Rede",
					"D": "DataFrame"
				},
				"resposta": "A",
				"motivos": {
					"A": "Banco de dados é uma estrutura usada para armazenar informações de forma persistente. Em sistemas de informação, ele sustenta cadastros, transações, consultas e relatórios."
				}
			},
			{
				"id": "show_facil_sql_select_06",
				"topic": "SQL",
				"pergunta": "Qual conceito corresponde a esta descrição? Recupera registros de tabelas em um banco de dados relacional.",
				"opcoes": {
					"A": "Algoritmo",
					"B": "SELECT",
					"C": "DNS",
					"D": "Series"
				},
				"resposta": "B",
				"motivos": {
					"B": "SELECT é um comando da linguagem SQL usado para consultar dados. Ele pode ser combinado com WHERE, JOIN, GROUP BY e ORDER BY para filtrar, relacionar e ordenar resultados."
				}
			},
			{
				"id": "show_facil_estruturas_de_dados_pilha_07",
				"topic": "Estruturas de Dados",
				"pergunta": "Qual conceito corresponde a esta descrição? Organiza dados no padrão em que o último elemento inserido é o primeiro a sair.",
				"opcoes": {
					"A": "Variável",
					"B": "Firewall",
					"C": "Pilha",
					"D": "Limpeza de Dados"
				},
				"resposta": "C",
				"motivos": {
					"C": "Pilha é uma estrutura de dados baseada em LIFO, Last In, First Out. Ela aparece em chamadas de funções, desfazer ações e controle de execução."
				}
			},
			{
				"id": "show_facil_estruturas_de_dados_fila_08",
				"topic": "Estruturas de Dados",
				"pergunta": "Qual conceito corresponde a esta descrição? Organiza dados no padrão em que o primeiro elemento inserido é o primeiro a sair.",
				"opcoes": {
					"A": "Função",
					"B": "Requisito",
					"C": "LGPD",
					"D": "Fila"
				},
				"resposta": "D",
				"motivos": {
					"D": "Fila é uma estrutura de dados baseada em FIFO, First In, First Out. Ela é útil em atendimento, processamento de tarefas e filas de mensagens."
				}
			},
			{
				"id": "show_facil_seguranca_da_informacao_backup_09",
				"topic": "Segurança da Informação",
				"pergunta": "Qual conceito corresponde a esta descrição? Preserva cópias de dados para recuperação após falhas, exclusões ou incidentes.",
				"opcoes": {
					"A": "Backup",
					"B": "Git",
					"C": "Teste",
					"D": "POO"
				},
				"resposta": "A",
				"motivos": {
					"A": "Backup é uma cópia de segurança dos dados. Ele reduz perdas em falhas, ataques, erros humanos e desastres, mas precisa ser testado para garantir restauração."
				}
			},
			{
				"id": "show_facil_ciberseguranca_mfa_10",
				"topic": "Cibersegurança",
				"pergunta": "Qual conceito corresponde a esta descrição? Exige mais de uma evidência para confirmar a identidade de um usuário.",
				"opcoes": {
					"A": "Cliente",
					"B": "MFA",
					"C": "Bug",
					"D": "HTML"
				},
				"resposta": "B",
				"motivos": {
					"B": "MFA significa Multi-Factor Authentication, ou Autenticação Multifator. Ele combina fatores como senha, aplicativo, biometria ou token para reduzir o risco de acesso indevido."
				}
			},
			{
				"id": "show_facil_ux_ihc_ux_11",
				"topic": "UX/IHC",
				"pergunta": "Qual conceito corresponde a esta descrição? Avalia como uma pessoa percebe, entende e utiliza um produto ou serviço digital.",
				"opcoes": {
					"A": "Servidor",
					"B": "Dashboard",
					"C": "UX",
					"D": "CSS"
				},
				"resposta": "C",
				"motivos": {
					"C": "UX significa User Experience, ou Experiência do Usuário. Ela envolve utilidade, facilidade de uso, eficiência, emoção, contexto e satisfação durante a interação."
				}
			},
			{
				"id": "show_facil_ihc_acessibilidade_12",
				"topic": "IHC",
				"pergunta": "Qual conceito corresponde a esta descrição? Remove barreiras para que pessoas com diferentes capacidades consigam usar sistemas.",
				"opcoes": {
					"A": "Rede",
					"B": "DataFrame",
					"C": "JavaScript",
					"D": "Acessibilidade"
				},
				"resposta": "D",
				"motivos": {
					"D": "Acessibilidade busca tornar produtos digitais utilizáveis por mais pessoas. Ela envolve contraste, navegação por teclado, texto alternativo, leitores de tela e linguagem clara."
				}
			},
			{
				"id": "show_facil_fundamentos_de_computacao_algoritmo_13",
				"topic": "Fundamentos de Computação",
				"pergunta": "Qual conceito corresponde a esta descrição? Define uma sequência finita e ordenada de passos para resolver um problema.",
				"opcoes": {
					"A": "Algoritmo",
					"B": "DNS",
					"C": "Series",
					"D": "API"
				},
				"resposta": "A",
				"motivos": {
					"A": "Algoritmo é um conjunto de instruções lógicas para chegar a uma solução. Ele pode ser representado em linguagem natural, fluxograma, pseudocódigo ou código."
				}
			},
			{
				"id": "show_facil_programacao_variavel_14",
				"topic": "Programação",
				"pergunta": "Qual conceito corresponde a esta descrição? Armazena temporariamente valores usados por um programa durante sua execução.",
				"opcoes": {
					"A": "Firewall",
					"B": "Variável",
					"C": "Limpeza de Dados",
					"D": "Banco de Dados"
				},
				"resposta": "B",
				"motivos": {
					"B": "Variável é um nome associado a um valor em memória. Ela permite guardar dados como números, textos, estados e resultados intermediários."
				}
			},
			{
				"id": "show_facil_programacao_funcao_15",
				"topic": "Programação",
				"pergunta": "Qual conceito corresponde a esta descrição? Reúne instruções reutilizáveis para executar uma tarefa específica.",
				"opcoes": {
					"A": "Requisito",
					"B": "LGPD",
					"C": "Função",
					"D": "SELECT"
				},
				"resposta": "C",
				"motivos": {
					"C": "Função organiza o código em blocos menores e reutilizáveis. Ela melhora leitura, manutenção, testes e evita repetição desnecessária."
				}
			},
			{
				"id": "show_facil_devops_git_16",
				"topic": "DevOps",
				"pergunta": "Qual conceito corresponde a esta descrição? Registra histórico de alterações e ajuda equipes a colaborarem no código.",
				"opcoes": {
					"A": "Teste",
					"B": "POO",
					"C": "Pilha",
					"D": "Git"
				},
				"resposta": "D",
				"motivos": {
					"D": "Git é um sistema de controle de versão distribuído. Ele permite criar branches, revisar mudanças, voltar versões e colaborar com mais segurança."
				}
			},
			{
				"id": "show_facil_arquitetura_web_cliente_17",
				"topic": "Arquitetura Web",
				"pergunta": "Qual conceito corresponde a esta descrição? Representa o lado que solicita serviços, páginas ou dados a outro sistema.",
				"opcoes": {
					"A": "Cliente",
					"B": "Bug",
					"C": "HTML",
					"D": "Fila"
				},
				"resposta": "A",
				"motivos": {
					"A": "Cliente é o componente que consome um serviço, como navegador, aplicativo mobile ou sistema externo. Ele envia requisições para um servidor."
				}
			},
			{
				"id": "show_facil_arquitetura_web_servidor_18",
				"topic": "Arquitetura Web",
				"pergunta": "Qual conceito corresponde a esta descrição? Processa requisições e entrega páginas, dados ou serviços para clientes.",
				"opcoes": {
					"A": "Dashboard",
					"B": "Servidor",
					"C": "CSS",
					"D": "Backup"
				},
				"resposta": "B",
				"motivos": {
					"B": "Servidor é o componente que recebe requisições, executa regras de negócio, consulta dados e envia respostas para clientes ou outros sistemas."
				}
			},
			{
				"id": "show_facil_redes_rede_19",
				"topic": "Redes",
				"pergunta": "Qual conceito corresponde a esta descrição? Permite comunicação e compartilhamento de recursos entre dispositivos.",
				"opcoes": {
					"A": "DataFrame",
					"B": "JavaScript",
					"C": "Rede",
					"D": "MFA"
				},
				"resposta": "C",
				"motivos": {
					"C": "Rede de computadores conecta dispositivos para troca de dados. Ela pode usar protocolos, endereços, roteadores, switches e serviços como DNS e HTTP."
				}
			},
			{
				"id": "show_facil_redes_dns_20",
				"topic": "Redes",
				"pergunta": "Qual conceito corresponde a esta descrição? Traduz nomes de domínio em endereços ip usados na comunicação de rede.",
				"opcoes": {
					"A": "Series",
					"B": "API",
					"C": "UX",
					"D": "DNS"
				},
				"resposta": "D",
				"motivos": {
					"D": "DNS significa Domain Name System, ou Sistema de Nomes de Domínio. Ele permite acessar sites por nomes como exemplo.com em vez de memorizar endereços IP."
				}
			},
			{
				"id": "show_facil_ciberseguranca_firewall_21",
				"topic": "Cibersegurança",
				"pergunta": "Qual conceito corresponde a esta descrição? Controla tráfego de rede usando regras de permissão e bloqueio.",
				"opcoes": {
					"A": "Firewall",
					"B": "Limpeza de Dados",
					"C": "Banco de Dados",
					"D": "Acessibilidade"
				},
				"resposta": "A",
				"motivos": {
					"A": "Firewall é um mecanismo de segurança que filtra comunicações. Ele pode bloquear conexões suspeitas, limitar portas e reduzir exposição de serviços."
				}
			},
			{
				"id": "show_facil_engenharia_de_software_requisito_22",
				"topic": "Engenharia de Software",
				"pergunta": "Qual conceito corresponde a esta descrição? Descreve uma necessidade, função ou restrição que o sistema deve atender.",
				"opcoes": {
					"A": "LGPD",
					"B": "Requisito",
					"C": "SELECT",
					"D": "Algoritmo"
				},
				"resposta": "B",
				"motivos": {
					"B": "Requisito registra o que o sistema precisa fazer ou respeitar. Pode ser funcional, quando descreve uma função, ou não funcional, quando descreve qualidade ou restrição."
				}
			},
			{
				"id": "show_facil_qualidade_de_software_teste_23",
				"topic": "Qualidade de Software",
				"pergunta": "Qual conceito corresponde a esta descrição? Verifica se o software funciona conforme esperado e ajuda a encontrar defeitos.",
				"opcoes": {
					"A": "POO",
					"B": "Pilha",
					"C": "Teste",
					"D": "Variável"
				},
				"resposta": "C",
				"motivos": {
					"C": "Teste de software reduz riscos ao verificar comportamentos esperados. Ele pode ser manual, automatizado, unitário, funcional, regressivo ou de integração."
				}
			},
			{
				"id": "show_facil_qualidade_de_software_bug_24",
				"topic": "Qualidade de Software",
				"pergunta": "Qual conceito corresponde a esta descrição? Representa um defeito que faz o sistema agir diferente do esperado.",
				"opcoes": {
					"A": "HTML",
					"B": "Fila",
					"C": "Função",
					"D": "Bug"
				},
				"resposta": "D",
				"motivos": {
					"D": "Bug é uma falha ou defeito no software. Ele pode surgir por erro de lógica, requisito mal interpretado, integração incorreta ou dados inesperados."
				}
			},
			{
				"id": "show_facil_business_intelligence_dashboard_25",
				"topic": "Business Intelligence",
				"pergunta": "Qual conceito corresponde a esta descrição? Reúne gráficos e indicadores para apoiar acompanhamento e decisão.",
				"opcoes": {
					"A": "Dashboard",
					"B": "CSS",
					"C": "Backup",
					"D": "Git"
				},
				"resposta": "A",
				"motivos": {
					"A": "Dashboard é um painel visual com métricas, gráficos e indicadores. Em BI, ele ajuda a transformar dados em leitura rápida para gestão e acompanhamento."
				}
			},
			{
				"id": "show_facil_ciencia_de_dados_dataframe_26",
				"topic": "Ciência de Dados",
				"pergunta": "Qual conceito corresponde a esta descrição? Representa dados em formato de tabela com linhas e colunas no pandas.",
				"opcoes": {
					"A": "JavaScript",
					"B": "DataFrame",
					"C": "MFA",
					"D": "Cliente"
				},
				"resposta": "B",
				"motivos": {
					"B": "DataFrame é a estrutura bidimensional do Pandas. Ele organiza dados como uma tabela, permitindo filtros, agrupamentos, junções, limpeza e análise exploratória."
				}
			},
			{
				"id": "show_facil_ciencia_de_dados_series_27",
				"topic": "Ciência de Dados",
				"pergunta": "Qual conceito corresponde a esta descrição? Representa uma sequência unidimensional de dados no pandas, parecida com uma coluna.",
				"opcoes": {
					"A": "API",
					"B": "UX",
					"C": "Series",
					"D": "Servidor"
				},
				"resposta": "C",
				"motivos": {
					"C": "Series é uma estrutura unidimensional do Pandas, formada por valores e índice. Uma coluna de um DataFrame pode ser tratada como uma Series."
				}
			},
			{
				"id": "show_facil_ciencia_de_dados_limpeza_de_dados_28",
				"topic": "Ciência de Dados",
				"pergunta": "Qual conceito corresponde a esta descrição? Trata valores ausentes, duplicados, tipos errados e inconsistências antes da análise.",
				"opcoes": {
					"A": "Banco de Dados",
					"B": "Acessibilidade",
					"C": "Rede",
					"D": "Limpeza de Dados"
				},
				"resposta": "D",
				"motivos": {
					"D": "Limpeza de dados prepara uma base para análise confiável. Em projetos reais, essa etapa costuma consumir muito tempo porque dados chegam incompletos, duplicados ou fora de padrão."
				}
			},
			{
				"id": "show_facil_lgpd_e_privacidade_lgpd_29",
				"topic": "LGPD e Privacidade",
				"pergunta": "Qual conceito corresponde a esta descrição? Define regras brasileiras para tratamento de dados pessoais.",
				"opcoes": {
					"A": "LGPD",
					"B": "SELECT",
					"C": "Algoritmo",
					"D": "DNS"
				},
				"resposta": "A",
				"motivos": {
					"A": "LGPD significa Lei Geral de Proteção de Dados. Ela regula coleta, uso, armazenamento e compartilhamento de dados pessoais no Brasil."
				}
			},
			{
				"id": "show_facil_programacao_orientada_a_objetos_poo_30",
				"topic": "Programação Orientada a Objetos",
				"pergunta": "Qual conceito corresponde a esta descrição? Organiza programas em classes, objetos, atributos e métodos.",
				"opcoes": {
					"A": "Pilha",
					"B": "POO",
					"C": "Variável",
					"D": "Firewall"
				},
				"resposta": "B",
				"motivos": {
					"B": "POO significa Programação Orientada a Objetos. Ela modela o software com objetos que possuem dados e comportamentos, favorecendo organização e reutilização."
				}
			}
		],
		"normal": [
			{
				"id": "show_normal_ciberseguranca_autenticacao_01",
				"topic": "Cibersegurança",
				"pergunta": "Qual conceito corresponde a esta descrição? Confirma se o usuário ou sistema realmente é quem afirma ser.",
				"opcoes": {
					"A": "Autenticação",
					"B": "Chave Estrangeira",
					"C": "DevOps",
					"D": "GroupBy"
				},
				"resposta": "A",
				"motivos": {
					"A": "Autenticação verifica identidade por senha, biometria, token ou outro fator. Ela responde à pergunta: quem é você?"
				}
			},
			{
				"id": "show_normal_ciberseguranca_autorizacao_02",
				"topic": "Cibersegurança",
				"pergunta": "Qual conceito corresponde a esta descrição? Define quais recursos e ações um usuário autenticado pode acessar.",
				"opcoes": {
					"A": "Diagrama ER",
					"B": "Autorização",
					"C": "Pipeline",
					"D": "Padronização de Dados"
				},
				"resposta": "B",
				"motivos": {
					"B": "Autorização ocorre depois da autenticação. Ela controla permissões e responde: o que este usuário pode fazer?"
				}
			},
			{
				"id": "show_normal_desenvolvimento_web_api_rest_03",
				"topic": "Desenvolvimento Web",
				"pergunta": "Qual conceito corresponde a esta descrição? Usa recursos, urls e métodos http para comunicação entre sistemas.",
				"opcoes": {
					"A": "Normalização",
					"B": "SQL Injection",
					"C": "API REST",
					"D": "Container"
				},
				"resposta": "C",
				"motivos": {
					"C": "API REST segue princípios de Representational State Transfer. Ela costuma usar métodos HTTP como GET, POST, PUT e DELETE para manipular recursos."
				}
			},
			{
				"id": "show_normal_desenvolvimento_web_json_04",
				"topic": "Desenvolvimento Web",
				"pergunta": "Qual conceito corresponde a esta descrição? Representa dados em formato textual leve, muito usado em apis.",
				"opcoes": {
					"A": "Roteamento",
					"B": "XSS",
					"C": "CI/CD",
					"D": "JSON"
				},
				"resposta": "D",
				"motivos": {
					"D": "JSON significa JavaScript Object Notation. Ele é comum em APIs porque é simples, legível e compatível com várias linguagens."
				}
			},
			{
				"id": "show_normal_back_end_cache_05",
				"topic": "Back-end",
				"pergunta": "Qual conceito corresponde a esta descrição? Guarda dados temporários para reduzir tempo de resposta e carga de processamento.",
				"opcoes": {
					"A": "Cache",
					"B": "HTTP",
					"C": "Persona",
					"D": "ETL"
				},
				"resposta": "A",
				"motivos": {
					"A": "Cache melhora desempenho ao reutilizar dados acessados com frequência. O cuidado é manter validade e evitar entregar informação desatualizada."
				}
			},
			{
				"id": "show_normal_banco_de_dados_transacao_06",
				"topic": "Banco de Dados",
				"pergunta": "Qual conceito corresponde a esta descrição? Agrupa operações que devem ser confirmadas ou desfeitas de forma consistente.",
				"opcoes": {
					"A": "HTTPS",
					"B": "Transação",
					"C": "Heurísticas de Nielsen",
					"D": "KPI"
				},
				"resposta": "B",
				"motivos": {
					"B": "Transação protege a consistência dos dados. Se tudo dá certo, ocorre commit; se algo falha, rollback desfaz as alterações."
				}
			},
			{
				"id": "show_normal_banco_de_dados_indice_07",
				"topic": "Banco de Dados",
				"pergunta": "Qual conceito corresponde a esta descrição? Acelera buscas em tabelas, mas pode aumentar custo de escrita e armazenamento.",
				"opcoes": {
					"A": "VPN",
					"B": "Design Responsivo",
					"C": "Índice",
					"D": "Mineração de Dados"
				},
				"resposta": "C",
				"motivos": {
					"C": "Índice é uma estrutura auxiliar para localizar registros mais rápido. Ele melhora consultas, mas exige equilíbrio porque impacta inserções e atualizações."
				}
			},
			{
				"id": "show_normal_banco_de_dados_chave_estrangeira_08",
				"topic": "Banco de Dados",
				"pergunta": "Qual conceito corresponde a esta descrição? Cria vínculo entre tabelas e preserva integridade referencial.",
				"opcoes": {
					"A": "Hash",
					"B": "DevOps",
					"C": "GroupBy",
					"D": "Chave Estrangeira"
				},
				"resposta": "D",
				"motivos": {
					"D": "Chave estrangeira referencia a chave primária de outra tabela. Ela ajuda a evitar relacionamentos inválidos entre registros."
				}
			},
			{
				"id": "show_normal_modelagem_de_dados_diagrama_er_09",
				"topic": "Modelagem de Dados",
				"pergunta": "Qual conceito corresponde a esta descrição? Representa entidades, atributos e relacionamentos de um domínio.",
				"opcoes": {
					"A": "Diagrama ER",
					"B": "Criptografia",
					"C": "Pipeline",
					"D": "Padronização de Dados"
				},
				"resposta": "A",
				"motivos": {
					"A": "Diagrama ER significa Entidade-Relacionamento. Ele apoia a modelagem conceitual de bancos de dados antes da criação das tabelas."
				}
			},
			{
				"id": "show_normal_banco_de_dados_normalizacao_10",
				"topic": "Banco de Dados",
				"pergunta": "Qual conceito corresponde a esta descrição? Organiza tabelas para reduzir redundância e anomalias de atualização.",
				"opcoes": {
					"A": "SQL Injection",
					"B": "Normalização",
					"C": "Container",
					"D": "Autenticação"
				},
				"resposta": "B",
				"motivos": {
					"B": "Normalização aplica formas normais para melhorar consistência no banco relacional. Ela reduz repetição indevida, mas pode exigir joins mais frequentes."
				}
			},
			{
				"id": "show_normal_redes_roteamento_11",
				"topic": "Redes",
				"pergunta": "Qual conceito corresponde a esta descrição? Define o caminho que pacotes percorrem entre origem e destino.",
				"opcoes": {
					"A": "XSS",
					"B": "CI/CD",
					"C": "Roteamento",
					"D": "Autorização"
				},
				"resposta": "C",
				"motivos": {
					"C": "Roteamento encaminha pacotes entre redes. Roteadores usam tabelas e protocolos para escolher o melhor caminho disponível."
				}
			},
			{
				"id": "show_normal_redes_e_web_http_12",
				"topic": "Redes e Web",
				"pergunta": "Qual conceito corresponde a esta descrição? Protocolo usado para comunicação entre clientes e servidores web.",
				"opcoes": {
					"A": "Persona",
					"B": "ETL",
					"C": "API REST",
					"D": "HTTP"
				},
				"resposta": "D",
				"motivos": {
					"D": "HTTP significa HyperText Transfer Protocol. Ele define requisições e respostas na web, usando métodos como GET e POST."
				}
			},
			{
				"id": "show_normal_redes_e_seguranca_https_13",
				"topic": "Redes e Segurança",
				"pergunta": "Qual conceito corresponde a esta descrição? Protege a comunicação web com criptografia sobre tls.",
				"opcoes": {
					"A": "HTTPS",
					"B": "Heurísticas de Nielsen",
					"C": "KPI",
					"D": "JSON"
				},
				"resposta": "A",
				"motivos": {
					"A": "HTTPS significa HyperText Transfer Protocol Secure. Ele usa TLS para proteger confidencialidade, integridade e autenticidade da comunicação."
				}
			},
			{
				"id": "show_normal_redes_e_seguranca_vpn_14",
				"topic": "Redes e Segurança",
				"pergunta": "Qual conceito corresponde a esta descrição? Cria um túnel seguro para acesso remoto ou conexão entre redes.",
				"opcoes": {
					"A": "Design Responsivo",
					"B": "VPN",
					"C": "Mineração de Dados",
					"D": "Cache"
				},
				"resposta": "B",
				"motivos": {
					"B": "VPN significa Virtual Private Network, ou Rede Privada Virtual. Ela protege tráfego e permite acesso seguro a recursos internos."
				}
			},
			{
				"id": "show_normal_ciberseguranca_hash_15",
				"topic": "Cibersegurança",
				"pergunta": "Qual conceito corresponde a esta descrição? Gera um resumo de tamanho fixo a partir de dados de entrada.",
				"opcoes": {
					"A": "DevOps",
					"B": "GroupBy",
					"C": "Hash",
					"D": "Transação"
				},
				"resposta": "C",
				"motivos": {
					"C": "Hash é uma função que transforma dados em um resumo. É usado para integridade e armazenamento seguro de senhas quando combinado com salting e boas práticas."
				}
			},
			{
				"id": "show_normal_ciberseguranca_criptografia_16",
				"topic": "Cibersegurança",
				"pergunta": "Qual conceito corresponde a esta descrição? Transforma dados para que só possam ser compreendidos com chave adequada.",
				"opcoes": {
					"A": "Pipeline",
					"B": "Padronização de Dados",
					"C": "Índice",
					"D": "Criptografia"
				},
				"resposta": "D",
				"motivos": {
					"D": "Criptografia protege confidencialidade e, em alguns usos, integridade e autenticidade. Ela é base de HTTPS, armazenamento seguro e comunicação protegida."
				}
			},
			{
				"id": "show_normal_ciberseguranca_sql_injection_17",
				"topic": "Cibersegurança",
				"pergunta": "Qual conceito corresponde a esta descrição? Ocorre quando entrada maliciosa manipula comandos sql de uma aplicação.",
				"opcoes": {
					"A": "SQL Injection",
					"B": "Container",
					"C": "Chave Estrangeira",
					"D": "DevOps"
				},
				"resposta": "A",
				"motivos": {
					"A": "SQL Injection é uma vulnerabilidade de injeção em banco de dados. Validação, consultas parametrizadas e menor privilégio reduzem esse risco."
				}
			},
			{
				"id": "show_normal_ciberseguranca_xss_18",
				"topic": "Cibersegurança",
				"pergunta": "Qual conceito corresponde a esta descrição? Injeta scripts maliciosos em páginas vistas por usuários.",
				"opcoes": {
					"A": "CI/CD",
					"B": "XSS",
					"C": "Diagrama ER",
					"D": "Pipeline"
				},
				"resposta": "B",
				"motivos": {
					"B": "XSS significa Cross-Site Scripting. Ele ocorre quando uma aplicação exibe conteúdo não tratado, permitindo execução de scripts no navegador da vítima."
				}
			},
			{
				"id": "show_normal_ux_ihc_persona_19",
				"topic": "UX/IHC",
				"pergunta": "Qual conceito corresponde a esta descrição? Representa um perfil fictício baseado em características de usuários reais.",
				"opcoes": {
					"A": "ETL",
					"B": "API REST",
					"C": "Persona",
					"D": "Normalização"
				},
				"resposta": "C",
				"motivos": {
					"C": "Persona ajuda equipes a projetarem pensando em necessidades, dores, objetivos e contexto de uso de grupos de usuários."
				}
			},
			{
				"id": "show_normal_ux_ihc_heuristicas_de_nielsen_20",
				"topic": "UX/IHC",
				"pergunta": "Qual conceito corresponde a esta descrição? São princípios usados para avaliar problemas de usabilidade em interfaces.",
				"opcoes": {
					"A": "KPI",
					"B": "JSON",
					"C": "Roteamento",
					"D": "Heurísticas de Nielsen"
				},
				"resposta": "D",
				"motivos": {
					"D": "As heurísticas de Nielsen orientam avaliação de interfaces, incluindo feedback, consistência, prevenção de erros e liberdade do usuário."
				}
			},
			{
				"id": "show_normal_front_end_design_responsivo_21",
				"topic": "Front-end",
				"pergunta": "Qual conceito corresponde a esta descrição? Adapta a interface a diferentes tamanhos de tela e dispositivos.",
				"opcoes": {
					"A": "Design Responsivo",
					"B": "Mineração de Dados",
					"C": "Cache",
					"D": "HTTP"
				},
				"resposta": "A",
				"motivos": {
					"A": "Design responsivo usa layouts flexíveis, media queries e boas práticas de interface para manter usabilidade em celular, tablet e desktop."
				}
			},
			{
				"id": "show_normal_devops_devops_22",
				"topic": "DevOps",
				"pergunta": "Qual conceito corresponde a esta descrição? Integra desenvolvimento e operações para entregar software com mais qualidade e frequência.",
				"opcoes": {
					"A": "GroupBy",
					"B": "DevOps",
					"C": "Transação",
					"D": "HTTPS"
				},
				"resposta": "B",
				"motivos": {
					"B": "DevOps combina cultura, automação e colaboração. Ele reduz atritos entre desenvolvimento, testes, infraestrutura e implantação."
				}
			},
			{
				"id": "show_normal_devops_pipeline_23",
				"topic": "DevOps",
				"pergunta": "Qual conceito corresponde a esta descrição? Automatiza etapas como build, testes, análise e deploy.",
				"opcoes": {
					"A": "Padronização de Dados",
					"B": "Índice",
					"C": "Pipeline",
					"D": "VPN"
				},
				"resposta": "C",
				"motivos": {
					"C": "Pipeline organiza o fluxo de entrega de software. Em CI/CD, ele reduz tarefas manuais e torna publicações mais repetíveis."
				}
			},
			{
				"id": "show_normal_devops_container_24",
				"topic": "DevOps",
				"pergunta": "Qual conceito corresponde a esta descrição? Empacota aplicação e dependências em ambiente isolado e reproduzível.",
				"opcoes": {
					"A": "Autenticação",
					"B": "Chave Estrangeira",
					"C": "Hash",
					"D": "Container"
				},
				"resposta": "D",
				"motivos": {
					"D": "Container ajuda a executar software de forma consistente entre desenvolvimento, teste e produção. Docker é uma ferramenta comum nesse contexto."
				}
			},
			{
				"id": "show_normal_devops_ci_cd_25",
				"topic": "DevOps",
				"pergunta": "Qual conceito corresponde a esta descrição? Automatiza integração, testes e entrega de software.",
				"opcoes": {
					"A": "CI/CD",
					"B": "Autorização",
					"C": "Diagrama ER",
					"D": "Criptografia"
				},
				"resposta": "A",
				"motivos": {
					"A": "CI/CD significa Continuous Integration e Continuous Delivery/Deployment, ou Integração Contínua e Entrega/Implantação Contínua. Ele reduz erros manuais e acelera entregas."
				}
			},
			{
				"id": "show_normal_dados_e_bi_etl_26",
				"topic": "Dados e BI",
				"pergunta": "Qual conceito corresponde a esta descrição? Extrai, transforma e carrega dados para outro ambiente de armazenamento ou análise.",
				"opcoes": {
					"A": "API REST",
					"B": "ETL",
					"C": "Normalização",
					"D": "SQL Injection"
				},
				"resposta": "B",
				"motivos": {
					"B": "ETL significa Extract, Transform and Load, ou Extração, Transformação e Carga. Ele coleta dados, aplica tratamentos e carrega o resultado em bases analíticas, como Data Warehouse."
				}
			},
			{
				"id": "show_normal_business_intelligence_kpi_27",
				"topic": "Business Intelligence",
				"pergunta": "Qual conceito corresponde a esta descrição? Mede desempenho de processos, metas ou resultados importantes para o negócio.",
				"opcoes": {
					"A": "JSON",
					"B": "Roteamento",
					"C": "KPI",
					"D": "XSS"
				},
				"resposta": "C",
				"motivos": {
					"C": "KPI significa Key Performance Indicator, ou Indicador-Chave de Desempenho. Ele ajuda a acompanhar objetivos com métricas relevantes e acionáveis."
				}
			},
			{
				"id": "show_normal_ciencia_de_dados_mineracao_de_dados_28",
				"topic": "Ciência de Dados",
				"pergunta": "Qual conceito corresponde a esta descrição? Busca padrões, relações e conhecimento útil em grandes conjuntos de dados.",
				"opcoes": {
					"A": "Cache",
					"B": "HTTP",
					"C": "Persona",
					"D": "Mineração de Dados"
				},
				"resposta": "D",
				"motivos": {
					"D": "Mineração de dados aplica técnicas para descobrir padrões, agrupamentos, associações ou classificações. Ela pode fazer parte do processo KDD."
				}
			},
			{
				"id": "show_normal_pandas_e_analise_de_dados_groupby_29",
				"topic": "Pandas e Análise de Dados",
				"pergunta": "Qual conceito corresponde a esta descrição? Agrupa registros no pandas para calcular somas, médias, contagens ou outras agregações.",
				"opcoes": {
					"A": "GroupBy",
					"B": "Transação",
					"C": "HTTPS",
					"D": "Heurísticas de Nielsen"
				},
				"resposta": "A",
				"motivos": {
					"A": "GroupBy é uma operação do Pandas inspirada no padrão split-apply-combine. Ela separa dados por grupos, aplica cálculos e combina os resultados."
				}
			},
			{
				"id": "show_normal_qualidade_de_dados_padronizacao_de_dados_30",
				"topic": "Qualidade de Dados",
				"pergunta": "Qual conceito corresponde a esta descrição? Coloca valores em formatos consistentes antes da análise.",
				"opcoes": {
					"A": "Índice",
					"B": "Padronização de Dados",
					"C": "VPN",
					"D": "Design Responsivo"
				},
				"resposta": "B",
				"motivos": {
					"B": "Padronização de dados evita categorias duplicadas e comparações incorretas. Exemplos comuns envolvem datas, nomes, siglas, letras maiúsculas e unidades de medida."
				}
			}
		],
		"dificil": [
			{
				"id": "show_dificil_business_intelligence_data_warehouse_01",
				"topic": "Business Intelligence",
				"pergunta": "Qual conceito corresponde a esta descrição? Integra dados históricos, orientados por assunto, para apoiar decisões gerenciais.",
				"opcoes": {
					"A": "Data Warehouse",
					"B": "KDD",
					"C": "Dívida Técnica",
					"D": "SLA"
				},
				"resposta": "A",
				"motivos": {
					"A": "Data Warehouse é um repositório analítico integrado, histórico e não volátil. Ele consolida dados de várias fontes para consultas, indicadores e análises estratégicas."
				}
			},
			{
				"id": "show_dificil_business_intelligence_data_mart_02",
				"topic": "Business Intelligence",
				"pergunta": "Qual conceito corresponde a esta descrição? Representa um subconjunto analítico voltado a uma área ou departamento específico.",
				"opcoes": {
					"A": "Outlier",
					"B": "Data Mart",
					"C": "MVC",
					"D": "RTO e RPO"
				},
				"resposta": "B",
				"motivos": {
					"B": "Data Mart é uma parte menor de um Data Warehouse. Ele atende necessidades de uma área, como vendas, financeiro ou recursos humanos."
				}
			},
			{
				"id": "show_dificil_business_intelligence_olap_03",
				"topic": "Business Intelligence",
				"pergunta": "Qual conceito corresponde a esta descrição? Apoia análise multidimensional de dados históricos e agregados.",
				"opcoes": {
					"A": "Correlação",
					"B": "SOLID",
					"C": "OLAP",
					"D": "Zero Trust"
				},
				"resposta": "C",
				"motivos": {
					"C": "OLAP significa Online Analytical Processing. Ele é voltado a consultas analíticas, comparações, agregações e exploração de dados para decisão."
				}
			},
			{
				"id": "show_dificil_banco_de_dados_oltp_04",
				"topic": "Banco de Dados",
				"pergunta": "Qual conceito corresponde a esta descrição? Processa transações operacionais frequentes do dia a dia.",
				"opcoes": {
					"A": "Amostragem",
					"B": "Polimorfismo",
					"C": "Menor Privilégio",
					"D": "OLTP"
				},
				"resposta": "D",
				"motivos": {
					"D": "OLTP significa Online Transaction Processing. Ele prioriza consistência, rapidez em transações e operações como cadastro, compra, pagamento e atualização."
				}
			},
			{
				"id": "show_dificil_data_warehouse_star_schema_05",
				"topic": "Data Warehouse",
				"pergunta": "Qual conceito corresponde a esta descrição? Modela dados analíticos com uma tabela fato central ligada a tabelas dimensão.",
				"opcoes": {
					"A": "Star Schema",
					"B": "Feature Engineering",
					"C": "Scrum",
					"D": "OAuth 2.0"
				},
				"resposta": "A",
				"motivos": {
					"A": "Star Schema, ou esquema estrela, facilita consultas analíticas. A tabela fato guarda métricas, enquanto dimensões descrevem contexto como tempo, produto e local."
				}
			},
			{
				"id": "show_dificil_data_warehouse_granularidade_06",
				"topic": "Data Warehouse",
				"pergunta": "Qual conceito corresponde a esta descrição? Define o nível de detalhe armazenado nos dados de uma tabela fato.",
				"opcoes": {
					"A": "Acoplamento",
					"B": "Granularidade",
					"C": "COBIT",
					"D": "JWT"
				},
				"resposta": "B",
				"motivos": {
					"B": "Granularidade indica quão detalhado é um dado. Em Data Warehouse, granularidade baixa guarda mais detalhes; granularidade alta guarda dados mais resumidos."
				}
			},
			{
				"id": "show_dificil_governanca_de_dados_metadados_07",
				"topic": "Governança de Dados",
				"pergunta": "Qual conceito corresponde a esta descrição? Descrevem origem, significado, estrutura e regras dos dados.",
				"opcoes": {
					"A": "Coesão",
					"B": "ITIL",
					"C": "Metadados",
					"D": "Observabilidade"
				},
				"resposta": "C",
				"motivos": {
					"C": "Metadados são dados sobre dados. Eles ajudam a entender campos, fontes, qualidade, periodicidade, responsáveis e regras de uso."
				}
			},
			{
				"id": "show_dificil_mineracao_de_dados_kdd_08",
				"topic": "Mineração de Dados",
				"pergunta": "Qual conceito corresponde a esta descrição? Organiza o processo de descoberta de conhecimento em bases de dados.",
				"opcoes": {
					"A": "Dívida Técnica",
					"B": "SLA",
					"C": "IaC",
					"D": "KDD"
				},
				"resposta": "D",
				"motivos": {
					"D": "KDD significa Knowledge Discovery in Databases, ou Descoberta de Conhecimento em Bases de Dados. Inclui seleção, limpeza, transformação, mineração e interpretação."
				}
			},
			{
				"id": "show_dificil_ciencia_de_dados_outlier_09",
				"topic": "Ciência de Dados",
				"pergunta": "Qual conceito corresponde a esta descrição? Representa um valor muito distante do comportamento esperado dos dados.",
				"opcoes": {
					"A": "Outlier",
					"B": "MVC",
					"C": "RTO e RPO",
					"D": "Privacidade por Design"
				},
				"resposta": "A",
				"motivos": {
					"A": "Outlier pode indicar erro, evento raro ou comportamento relevante. Antes de remover, o analista precisa entender o contexto e o impacto na análise."
				}
			},
			{
				"id": "show_dificil_estatistica_e_dados_correlacao_10",
				"topic": "Estatística e Dados",
				"pergunta": "Qual conceito corresponde a esta descrição? Mede associação entre variáveis, mas não prova relação de causa e efeito.",
				"opcoes": {
					"A": "SOLID",
					"B": "Correlação",
					"C": "Zero Trust",
					"D": "Data Warehouse"
				},
				"resposta": "B",
				"motivos": {
					"B": "Correlação indica se variáveis tendem a variar juntas. Em análise de dados, é importante lembrar que correlação não implica causalidade."
				}
			},
			{
				"id": "show_dificil_estatistica_e_dados_amostragem_11",
				"topic": "Estatística e Dados",
				"pergunta": "Qual conceito corresponde a esta descrição? Seleciona parte dos dados para representar uma população maior.",
				"opcoes": {
					"A": "Polimorfismo",
					"B": "Menor Privilégio",
					"C": "Amostragem",
					"D": "Data Mart"
				},
				"resposta": "C",
				"motivos": {
					"C": "Amostragem reduz custo de coleta e análise, mas precisa ser planejada para evitar vieses e manter representatividade."
				}
			},
			{
				"id": "show_dificil_ciencia_de_dados_feature_engineering_12",
				"topic": "Ciência de Dados",
				"pergunta": "Qual conceito corresponde a esta descrição? Cria ou transforma variáveis para melhorar análises e modelos preditivos.",
				"opcoes": {
					"A": "Scrum",
					"B": "OAuth 2.0",
					"C": "OLAP",
					"D": "Feature Engineering"
				},
				"resposta": "D",
				"motivos": {
					"D": "Feature Engineering envolve preparar atributos, criar indicadores, transformar escalas e extrair sinais úteis. A qualidade das variáveis influencia fortemente modelos de dados."
				}
			},
			{
				"id": "show_dificil_engenharia_de_software_acoplamento_13",
				"topic": "Engenharia de Software",
				"pergunta": "Qual conceito corresponde a esta descrição? Mede o grau de dependência entre módulos, classes ou componentes.",
				"opcoes": {
					"A": "Acoplamento",
					"B": "COBIT",
					"C": "JWT",
					"D": "OLTP"
				},
				"resposta": "A",
				"motivos": {
					"A": "Baixo acoplamento facilita manutenção, testes e evolução porque reduz dependências entre partes do sistema."
				}
			},
			{
				"id": "show_dificil_engenharia_de_software_coesao_14",
				"topic": "Engenharia de Software",
				"pergunta": "Qual conceito corresponde a esta descrição? Mede o quanto responsabilidades internas de um módulo estão relacionadas entre si.",
				"opcoes": {
					"A": "ITIL",
					"B": "Coesão",
					"C": "Observabilidade",
					"D": "Star Schema"
				},
				"resposta": "B",
				"motivos": {
					"B": "Alta coesão é desejável porque mantém componentes focados em uma responsabilidade clara, melhorando entendimento e manutenção."
				}
			},
			{
				"id": "show_dificil_engenharia_de_software_divida_tecnica_15",
				"topic": "Engenharia de Software",
				"pergunta": "Qual conceito corresponde a esta descrição? Representa custo futuro gerado por soluções rápidas, frágeis ou mal planejadas.",
				"opcoes": {
					"A": "SLA",
					"B": "IaC",
					"C": "Dívida Técnica",
					"D": "Granularidade"
				},
				"resposta": "C",
				"motivos": {
					"C": "Dívida técnica surge quando a equipe escolhe atalhos. Se não for controlada, aumenta retrabalho, dificulta manutenção e reduz velocidade de evolução."
				}
			},
			{
				"id": "show_dificil_arquitetura_de_software_mvc_16",
				"topic": "Arquitetura de Software",
				"pergunta": "Qual conceito corresponde a esta descrição? Separa responsabilidades entre modelo, visão e controlador.",
				"opcoes": {
					"A": "RTO e RPO",
					"B": "Privacidade por Design",
					"C": "Metadados",
					"D": "MVC"
				},
				"resposta": "D",
				"motivos": {
					"D": "MVC significa Model-View-Controller. Ele organiza dados, interface e fluxo de controle em camadas para reduzir mistura de responsabilidades."
				}
			},
			{
				"id": "show_dificil_arquitetura_de_software_solid_17",
				"topic": "Arquitetura de Software",
				"pergunta": "Qual conceito corresponde a esta descrição? Reúne princípios de design orientado a objetos para reduzir rigidez e facilitar manutenção.",
				"opcoes": {
					"A": "SOLID",
					"B": "Zero Trust",
					"C": "Data Warehouse",
					"D": "KDD"
				},
				"resposta": "A",
				"motivos": {
					"A": "SOLID é um conjunto de cinco princípios de projeto de software. Eles orientam responsabilidades claras, baixo acoplamento, extensibilidade e substituição segura."
				}
			},
			{
				"id": "show_dificil_poo_polimorfismo_18",
				"topic": "POO",
				"pergunta": "Qual conceito corresponde a esta descrição? Permite que diferentes objetos respondam de formas específicas à mesma operação.",
				"opcoes": {
					"A": "Menor Privilégio",
					"B": "Polimorfismo",
					"C": "Data Mart",
					"D": "Outlier"
				},
				"resposta": "B",
				"motivos": {
					"B": "Polimorfismo é um princípio da Programação Orientada a Objetos. Ele permite tratar objetos por uma interface comum, mantendo comportamentos especializados."
				}
			},
			{
				"id": "show_dificil_gestao_de_projetos_scrum_19",
				"topic": "Gestão de Projetos",
				"pergunta": "Qual conceito corresponde a esta descrição? Organiza trabalho ágil em eventos, papéis e artefatos para entrega incremental.",
				"opcoes": {
					"A": "OAuth 2.0",
					"B": "OLAP",
					"C": "Scrum",
					"D": "Correlação"
				},
				"resposta": "C",
				"motivos": {
					"C": "Scrum é um framework ágil com papéis como Product Owner, Scrum Master e Developers. Ele usa Sprints, Backlog e revisões para adaptação contínua."
				}
			},
			{
				"id": "show_dificil_governanca_de_ti_cobit_20",
				"topic": "Governança de TI",
				"pergunta": "Qual conceito corresponde a esta descrição? Orienta governança e gestão de ti alinhadas aos objetivos do negócio.",
				"opcoes": {
					"A": "JWT",
					"B": "OLTP",
					"C": "Amostragem",
					"D": "COBIT"
				},
				"resposta": "D",
				"motivos": {
					"D": "COBIT significa Control Objectives for Information and Related Technologies. Ele apoia governança, controle, valor, riscos e alinhamento estratégico de TI."
				}
			},
			{
				"id": "show_dificil_governanca_de_ti_itil_21",
				"topic": "Governança de TI",
				"pergunta": "Qual conceito corresponde a esta descrição? Organiza boas práticas para gestão de serviços de ti.",
				"opcoes": {
					"A": "ITIL",
					"B": "Observabilidade",
					"C": "Star Schema",
					"D": "Feature Engineering"
				},
				"resposta": "A",
				"motivos": {
					"A": "ITIL significa Information Technology Infrastructure Library. Ela trata serviços, incidentes, mudanças, problemas, níveis de serviço e melhoria contínua."
				}
			},
			{
				"id": "show_dificil_governanca_de_ti_sla_22",
				"topic": "Governança de TI",
				"pergunta": "Qual conceito corresponde a esta descrição? Formaliza níveis de serviço esperados entre provedor e cliente.",
				"opcoes": {
					"A": "IaC",
					"B": "SLA",
					"C": "Granularidade",
					"D": "Acoplamento"
				},
				"resposta": "B",
				"motivos": {
					"B": "SLA significa Service Level Agreement, ou Acordo de Nível de Serviço. Ele define metas como disponibilidade, tempo de resposta e prazo de atendimento."
				}
			},
			{
				"id": "show_dificil_continuidade_de_negocio_rto_e_rpo_23",
				"topic": "Continuidade de Negócio",
				"pergunta": "Qual conceito corresponde a esta descrição? Definem tempo máximo de recuperação e perda máxima aceitável de dados.",
				"opcoes": {
					"A": "Privacidade por Design",
					"B": "Metadados",
					"C": "RTO e RPO",
					"D": "Coesão"
				},
				"resposta": "C",
				"motivos": {
					"C": "RTO significa Recovery Time Objective, ou tempo máximo para restaurar o serviço. RPO significa Recovery Point Objective, ou ponto máximo aceitável de perda de dados."
				}
			},
			{
				"id": "show_dificil_ciberseguranca_zero_trust_24",
				"topic": "Cibersegurança",
				"pergunta": "Qual conceito corresponde a esta descrição? Assume que nenhuma conexão deve ser confiável automaticamente.",
				"opcoes": {
					"A": "Data Warehouse",
					"B": "KDD",
					"C": "Dívida Técnica",
					"D": "Zero Trust"
				},
				"resposta": "D",
				"motivos": {
					"D": "Zero Trust, ou confiança zero, exige verificação contínua de identidade, contexto e permissões. A ideia central é nunca confiar por padrão."
				}
			},
			{
				"id": "show_dificil_ciberseguranca_menor_privilegio_25",
				"topic": "Cibersegurança",
				"pergunta": "Qual conceito corresponde a esta descrição? Concede apenas as permissões necessárias para executar uma atividade.",
				"opcoes": {
					"A": "Menor Privilégio",
					"B": "Data Mart",
					"C": "Outlier",
					"D": "MVC"
				},
				"resposta": "A",
				"motivos": {
					"A": "O princípio do menor privilégio reduz danos em caso de falha ou invasão. Usuários e sistemas não devem ter acessos além do necessário."
				}
			},
			{
				"id": "show_dificil_ciberseguranca_oauth_2_0_26",
				"topic": "Cibersegurança",
				"pergunta": "Qual conceito corresponde a esta descrição? Permite autorização delegada sem compartilhar senha com aplicações terceiras.",
				"opcoes": {
					"A": "OLAP",
					"B": "OAuth 2.0",
					"C": "Correlação",
					"D": "SOLID"
				},
				"resposta": "B",
				"motivos": {
					"B": "OAuth 2.0 é um protocolo de autorização. Ele permite que uma aplicação acesse recursos em nome do usuário por meio de tokens controlados."
				}
			},
			{
				"id": "show_dificil_ciberseguranca_jwt_27",
				"topic": "Cibersegurança",
				"pergunta": "Qual conceito corresponde a esta descrição? Transporta declarações verificáveis entre sistemas em formato compacto.",
				"opcoes": {
					"A": "OLTP",
					"B": "Amostragem",
					"C": "JWT",
					"D": "Polimorfismo"
				},
				"resposta": "C",
				"motivos": {
					"C": "JWT significa JSON Web Token. Ele é usado para representar claims, como identidade e permissões, mas precisa de expiração, assinatura e armazenamento seguro."
				}
			},
			{
				"id": "show_dificil_devops_observabilidade_28",
				"topic": "DevOps",
				"pergunta": "Qual conceito corresponde a esta descrição? Permite entender o estado interno do sistema a partir de logs, métricas e traces.",
				"opcoes": {
					"A": "Star Schema",
					"B": "Feature Engineering",
					"C": "Scrum",
					"D": "Observabilidade"
				},
				"resposta": "D",
				"motivos": {
					"D": "Observabilidade combina sinais como logs, métricas e rastreamento distribuído. Ela ajuda a investigar falhas, gargalos e comportamento em produção."
				}
			},
			{
				"id": "show_dificil_devops_e_cloud_iac_29",
				"topic": "DevOps e Cloud",
				"pergunta": "Qual conceito corresponde a esta descrição? Gerencia infraestrutura por arquivos versionáveis em vez de configuração manual.",
				"opcoes": {
					"A": "IaC",
					"B": "Granularidade",
					"C": "Acoplamento",
					"D": "COBIT"
				},
				"resposta": "A",
				"motivos": {
					"A": "IaC significa Infrastructure as Code, ou Infraestrutura como Código. Ela torna ambientes reproduzíveis, auditáveis e menos dependentes de configuração manual."
				}
			},
			{
				"id": "show_dificil_lgpd_e_etica_privacidade_por_design_30",
				"topic": "LGPD e Ética",
				"pergunta": "Qual conceito corresponde a esta descrição? Inclui proteção de dados desde a concepção do sistema, não apenas no fim do projeto.",
				"opcoes": {
					"A": "Metadados",
					"B": "Privacidade por Design",
					"C": "Coesão",
					"D": "ITIL"
				},
				"resposta": "B",
				"motivos": {
					"B": "Privacidade por design coloca proteção de dados no planejamento, arquitetura e operação. Ela se relaciona com minimização, finalidade, segurança e transparência."
				}
			}
		]
	},
	"maleta_certa": {
		"facil": [
			{
				"id": "maleta_facil_desenvolvimento_web_html_01",
				"topic": "Desenvolvimento Web",
				"problema": "Cenário de Desenvolvimento Web: a equipe precisa lidar com uma situação em que estrutura o conteúdo de páginas web usando marcações como títulos, parágrafos, links e seções.",
				"opcoes": ["HTML", "Fila", "Função"],
				"correta": "HTML",
				"explanation": "HTML significa HyperText Markup Language, ou Linguagem de Marcação de Hipertexto. Ele define a estrutura semântica de uma página web, como títulos, textos, listas, links e formulários."
			},
			{
				"id": "maleta_facil_front_end_css_02",
				"topic": "Front-end",
				"problema": "Cenário de Front-end: a equipe precisa lidar com uma situação em que controla cores, espaçamentos, fontes e layout visual de uma página web.",
				"opcoes": ["CSS", "Backup", "Git"],
				"correta": "CSS",
				"explanation": "CSS significa Cascading Style Sheets, ou Folhas de Estilo em Cascata. Ele separa a apresentação visual da estrutura HTML e permite criar interfaces responsivas e organizadas."
			},
			{
				"id": "maleta_facil_programacao_web_javascript_03",
				"topic": "Programação Web",
				"problema": "Cenário de Programação Web: a equipe precisa lidar com uma situação em que adiciona comportamento dinâmico em páginas e aplicações web.",
				"opcoes": ["JavaScript", "MFA", "Cliente"],
				"correta": "JavaScript",
				"explanation": "JavaScript é uma linguagem de programação muito usada no navegador e também no back-end. Ela permite validar formulários, manipular o DOM, consumir APIs e criar interações dinâmicas."
			},
			{
				"id": "maleta_facil_back_end_api_04",
				"topic": "Back-end",
				"problema": "Cenário de Back-end: a equipe precisa lidar com uma situação em que permite que sistemas diferentes se comuniquem por meio de regras e pontos de acesso definidos.",
				"opcoes": ["API", "UX", "Servidor"],
				"correta": "API",
				"explanation": "API significa Application Programming Interface, ou Interface de Programação de Aplicações. Ela expõe funcionalidades para que sistemas, aplicativos ou serviços troquem dados de forma padronizada."
			},
			{
				"id": "maleta_facil_banco_de_dados_banco_de_dados_05",
				"topic": "Banco de Dados",
				"problema": "Cenário de Banco de Dados: a equipe precisa lidar com uma situação em que organiza e armazena dados para consulta, atualização e uso por sistemas.",
				"opcoes": ["Banco de Dados", "Acessibilidade", "Rede"],
				"correta": "Banco de Dados",
				"explanation": "Banco de dados é uma estrutura usada para armazenar informações de forma persistente. Em sistemas de informação, ele sustenta cadastros, transações, consultas e relatórios."
			},
			{
				"id": "maleta_facil_sql_select_06",
				"topic": "SQL",
				"problema": "Cenário de SQL: a equipe precisa lidar com uma situação em que recupera registros de tabelas em um banco de dados relacional.",
				"opcoes": ["SELECT", "Algoritmo", "DNS"],
				"correta": "SELECT",
				"explanation": "SELECT é um comando da linguagem SQL usado para consultar dados. Ele pode ser combinado com WHERE, JOIN, GROUP BY e ORDER BY para filtrar, relacionar e ordenar resultados."
			},
			{
				"id": "maleta_facil_estruturas_de_dados_pilha_07",
				"topic": "Estruturas de Dados",
				"problema": "Cenário de Estruturas de Dados: a equipe precisa lidar com uma situação em que organiza dados no padrão em que o último elemento inserido é o primeiro a sair.",
				"opcoes": ["Pilha", "Variável", "Firewall"],
				"correta": "Pilha",
				"explanation": "Pilha é uma estrutura de dados baseada em LIFO, Last In, First Out. Ela aparece em chamadas de funções, desfazer ações e controle de execução."
			},
			{
				"id": "maleta_facil_estruturas_de_dados_fila_08",
				"topic": "Estruturas de Dados",
				"problema": "Cenário de Estruturas de Dados: a equipe precisa lidar com uma situação em que organiza dados no padrão em que o primeiro elemento inserido é o primeiro a sair.",
				"opcoes": ["Fila", "Função", "Requisito"],
				"correta": "Fila",
				"explanation": "Fila é uma estrutura de dados baseada em FIFO, First In, First Out. Ela é útil em atendimento, processamento de tarefas e filas de mensagens."
			},
			{
				"id": "maleta_facil_seguranca_da_informacao_backup_09",
				"topic": "Segurança da Informação",
				"problema": "Cenário de Segurança da Informação: a equipe precisa lidar com uma situação em que preserva cópias de dados para recuperação após falhas, exclusões ou incidentes.",
				"opcoes": ["Backup", "Git", "Teste"],
				"correta": "Backup",
				"explanation": "Backup é uma cópia de segurança dos dados. Ele reduz perdas em falhas, ataques, erros humanos e desastres, mas precisa ser testado para garantir restauração."
			},
			{
				"id": "maleta_facil_ciberseguranca_mfa_10",
				"topic": "Cibersegurança",
				"problema": "Cenário de Cibersegurança: a equipe precisa lidar com uma situação em que exige mais de uma evidência para confirmar a identidade de um usuário.",
				"opcoes": ["MFA", "Cliente", "Bug"],
				"correta": "MFA",
				"explanation": "MFA significa Multi-Factor Authentication, ou Autenticação Multifator. Ele combina fatores como senha, aplicativo, biometria ou token para reduzir o risco de acesso indevido."
			},
			{
				"id": "maleta_facil_ux_ihc_ux_11",
				"topic": "UX/IHC",
				"problema": "Cenário de UX/IHC: a equipe precisa lidar com uma situação em que avalia como uma pessoa percebe, entende e utiliza um produto ou serviço digital.",
				"opcoes": ["UX", "Servidor", "Dashboard"],
				"correta": "UX",
				"explanation": "UX significa User Experience, ou Experiência do Usuário. Ela envolve utilidade, facilidade de uso, eficiência, emoção, contexto e satisfação durante a interação."
			},
			{
				"id": "maleta_facil_ihc_acessibilidade_12",
				"topic": "IHC",
				"problema": "Cenário de IHC: a equipe precisa lidar com uma situação em que remove barreiras para que pessoas com diferentes capacidades consigam usar sistemas.",
				"opcoes": ["Acessibilidade", "Rede", "DataFrame"],
				"correta": "Acessibilidade",
				"explanation": "Acessibilidade busca tornar produtos digitais utilizáveis por mais pessoas. Ela envolve contraste, navegação por teclado, texto alternativo, leitores de tela e linguagem clara."
			},
			{
				"id": "maleta_facil_fundamentos_de_computacao_algoritmo_13",
				"topic": "Fundamentos de Computação",
				"problema": "Cenário de Fundamentos de Computação: a equipe precisa lidar com uma situação em que define uma sequência finita e ordenada de passos para resolver um problema.",
				"opcoes": ["Algoritmo", "DNS", "Series"],
				"correta": "Algoritmo",
				"explanation": "Algoritmo é um conjunto de instruções lógicas para chegar a uma solução. Ele pode ser representado em linguagem natural, fluxograma, pseudocódigo ou código."
			},
			{
				"id": "maleta_facil_programacao_variavel_14",
				"topic": "Programação",
				"problema": "Cenário de Programação: a equipe precisa lidar com uma situação em que armazena temporariamente valores usados por um programa durante sua execução.",
				"opcoes": ["Variável", "Firewall", "Limpeza de Dados"],
				"correta": "Variável",
				"explanation": "Variável é um nome associado a um valor em memória. Ela permite guardar dados como números, textos, estados e resultados intermediários."
			},
			{
				"id": "maleta_facil_programacao_funcao_15",
				"topic": "Programação",
				"problema": "Cenário de Programação: a equipe precisa lidar com uma situação em que reúne instruções reutilizáveis para executar uma tarefa específica.",
				"opcoes": ["Função", "Requisito", "LGPD"],
				"correta": "Função",
				"explanation": "Função organiza o código em blocos menores e reutilizáveis. Ela melhora leitura, manutenção, testes e evita repetição desnecessária."
			},
			{
				"id": "maleta_facil_devops_git_16",
				"topic": "DevOps",
				"problema": "Cenário de DevOps: a equipe precisa lidar com uma situação em que registra histórico de alterações e ajuda equipes a colaborarem no código.",
				"opcoes": ["Git", "Teste", "POO"],
				"correta": "Git",
				"explanation": "Git é um sistema de controle de versão distribuído. Ele permite criar branches, revisar mudanças, voltar versões e colaborar com mais segurança."
			},
			{
				"id": "maleta_facil_arquitetura_web_cliente_17",
				"topic": "Arquitetura Web",
				"problema": "Cenário de Arquitetura Web: a equipe precisa lidar com uma situação em que representa o lado que solicita serviços, páginas ou dados a outro sistema.",
				"opcoes": ["Cliente", "Bug", "HTML"],
				"correta": "Cliente",
				"explanation": "Cliente é o componente que consome um serviço, como navegador, aplicativo mobile ou sistema externo. Ele envia requisições para um servidor."
			},
			{
				"id": "maleta_facil_arquitetura_web_servidor_18",
				"topic": "Arquitetura Web",
				"problema": "Cenário de Arquitetura Web: a equipe precisa lidar com uma situação em que processa requisições e entrega páginas, dados ou serviços para clientes.",
				"opcoes": ["Servidor", "Dashboard", "CSS"],
				"correta": "Servidor",
				"explanation": "Servidor é o componente que recebe requisições, executa regras de negócio, consulta dados e envia respostas para clientes ou outros sistemas."
			},
			{
				"id": "maleta_facil_redes_rede_19",
				"topic": "Redes",
				"problema": "Cenário de Redes: a equipe precisa lidar com uma situação em que permite comunicação e compartilhamento de recursos entre dispositivos.",
				"opcoes": ["Rede", "DataFrame", "JavaScript"],
				"correta": "Rede",
				"explanation": "Rede de computadores conecta dispositivos para troca de dados. Ela pode usar protocolos, endereços, roteadores, switches e serviços como DNS e HTTP."
			},
			{
				"id": "maleta_facil_redes_dns_20",
				"topic": "Redes",
				"problema": "Cenário de Redes: a equipe precisa lidar com uma situação em que traduz nomes de domínio em endereços IP usados na comunicação de rede.",
				"opcoes": ["DNS", "Series", "API"],
				"correta": "DNS",
				"explanation": "DNS significa Domain Name System, ou Sistema de Nomes de Domínio. Ele permite acessar sites por nomes como exemplo.com em vez de memorizar endereços IP."
			},
			{
				"id": "maleta_facil_ciberseguranca_firewall_21",
				"topic": "Cibersegurança",
				"problema": "Cenário de Cibersegurança: a equipe precisa lidar com uma situação em que controla tráfego de rede usando regras de permissão e bloqueio.",
				"opcoes": ["Firewall", "Limpeza de Dados", "Banco de Dados"],
				"correta": "Firewall",
				"explanation": "Firewall é um mecanismo de segurança que filtra comunicações. Ele pode bloquear conexões suspeitas, limitar portas e reduzir exposição de serviços."
			},
			{
				"id": "maleta_facil_engenharia_de_software_requisito_22",
				"topic": "Engenharia de Software",
				"problema": "Cenário de Engenharia de Software: a equipe precisa lidar com uma situação em que descreve uma necessidade, função ou restrição que o sistema deve atender.",
				"opcoes": ["Requisito", "LGPD", "SELECT"],
				"correta": "Requisito",
				"explanation": "Requisito registra o que o sistema precisa fazer ou respeitar. Pode ser funcional, quando descreve uma função, ou não funcional, quando descreve qualidade ou restrição."
			},
			{
				"id": "maleta_facil_qualidade_de_software_teste_23",
				"topic": "Qualidade de Software",
				"problema": "Cenário de Qualidade de Software: a equipe precisa lidar com uma situação em que verifica se o software funciona conforme esperado e ajuda a encontrar defeitos.",
				"opcoes": ["Teste", "POO", "Pilha"],
				"correta": "Teste",
				"explanation": "Teste de software reduz riscos ao verificar comportamentos esperados. Ele pode ser manual, automatizado, unitário, funcional, regressivo ou de integração."
			},
			{
				"id": "maleta_facil_qualidade_de_software_bug_24",
				"topic": "Qualidade de Software",
				"problema": "Cenário de Qualidade de Software: a equipe precisa lidar com uma situação em que representa um defeito que faz o sistema agir diferente do esperado.",
				"opcoes": ["Bug", "HTML", "Fila"],
				"correta": "Bug",
				"explanation": "Bug é uma falha ou defeito no software. Ele pode surgir por erro de lógica, requisito mal interpretado, integração incorreta ou dados inesperados."
			},
			{
				"id": "maleta_facil_business_intelligence_dashboard_25",
				"topic": "Business Intelligence",
				"problema": "Cenário de Business Intelligence: a equipe precisa lidar com uma situação em que reúne gráficos e indicadores para apoiar acompanhamento e decisão.",
				"opcoes": ["Dashboard", "CSS", "Backup"],
				"correta": "Dashboard",
				"explanation": "Dashboard é um painel visual com métricas, gráficos e indicadores. Em BI, ele ajuda a transformar dados em leitura rápida para gestão e acompanhamento."
			},
			{
				"id": "maleta_facil_ciencia_de_dados_dataframe_26",
				"topic": "Ciência de Dados",
				"problema": "Cenário de Ciência de Dados: a equipe precisa lidar com uma situação em que representa dados em formato de tabela com linhas e colunas no Pandas.",
				"opcoes": ["DataFrame", "JavaScript", "MFA"],
				"correta": "DataFrame",
				"explanation": "DataFrame é a estrutura bidimensional do Pandas. Ele organiza dados como uma tabela, permitindo filtros, agrupamentos, junções, limpeza e análise exploratória."
			},
			{
				"id": "maleta_facil_ciencia_de_dados_series_27",
				"topic": "Ciência de Dados",
				"problema": "Cenário de Ciência de Dados: a equipe precisa lidar com uma situação em que representa uma sequência unidimensional de dados no Pandas, parecida com uma coluna.",
				"opcoes": ["Series", "API", "UX"],
				"correta": "Series",
				"explanation": "Series é uma estrutura unidimensional do Pandas, formada por valores e índice. Uma coluna de um DataFrame pode ser tratada como uma Series."
			},
			{
				"id": "maleta_facil_ciencia_de_dados_limpeza_de_dados_28",
				"topic": "Ciência de Dados",
				"problema": "Cenário de Ciência de Dados: a equipe precisa lidar com uma situação em que trata valores ausentes, duplicados, tipos errados e inconsistências antes da análise.",
				"opcoes": ["Limpeza de Dados", "Banco de Dados", "Acessibilidade"],
				"correta": "Limpeza de Dados",
				"explanation": "Limpeza de dados prepara uma base para análise confiável. Em projetos reais, essa etapa costuma consumir muito tempo porque dados chegam incompletos, duplicados ou fora de padrão."
			},
			{
				"id": "maleta_facil_lgpd_e_privacidade_lgpd_29",
				"topic": "LGPD e Privacidade",
				"problema": "Cenário de LGPD e Privacidade: a equipe precisa lidar com uma situação em que define regras brasileiras para tratamento de dados pessoais.",
				"opcoes": ["LGPD", "SELECT", "Algoritmo"],
				"correta": "LGPD",
				"explanation": "LGPD significa Lei Geral de Proteção de Dados. Ela regula coleta, uso, armazenamento e compartilhamento de dados pessoais no Brasil."
			},
			{
				"id": "maleta_facil_programacao_orientada_a_objetos_poo_30",
				"topic": "Programação Orientada a Objetos",
				"problema": "Cenário de Programação Orientada a Objetos: a equipe precisa lidar com uma situação em que organiza programas em classes, objetos, atributos e métodos.",
				"opcoes": ["POO", "Pilha", "Variável"],
				"correta": "POO",
				"explanation": "POO significa Programação Orientada a Objetos. Ela modela o software com objetos que possuem dados e comportamentos, favorecendo organização e reutilização."
			}
		],
		"normal": [
			{
				"id": "maleta_normal_ciberseguranca_autenticacao_01",
				"topic": "Cibersegurança",
				"problema": "Cenário de Cibersegurança: a equipe precisa lidar com uma situação em que confirma se o usuário ou sistema realmente é quem afirma ser.",
				"opcoes": ["Autenticação", "Chave Estrangeira", "DevOps"],
				"correta": "Autenticação",
				"explanation": "Autenticação verifica identidade por senha, biometria, token ou outro fator. Ela responde à pergunta: quem é você?"
			},
			{
				"id": "maleta_normal_ciberseguranca_autorizacao_02",
				"topic": "Cibersegurança",
				"problema": "Cenário de Cibersegurança: a equipe precisa lidar com uma situação em que define quais recursos e ações um usuário autenticado pode acessar.",
				"opcoes": ["Autorização", "Diagrama ER", "Pipeline"],
				"correta": "Autorização",
				"explanation": "Autorização ocorre depois da autenticação. Ela controla permissões e responde: o que este usuário pode fazer?"
			},
			{
				"id": "maleta_normal_desenvolvimento_web_api_rest_03",
				"topic": "Desenvolvimento Web",
				"problema": "Cenário de Desenvolvimento Web: a equipe precisa lidar com uma situação em que usa recursos, URLs e métodos HTTP para comunicação entre sistemas.",
				"opcoes": ["API REST", "Normalização", "SQL Injection"],
				"correta": "API REST",
				"explanation": "API REST segue princípios de Representational State Transfer. Ela costuma usar métodos HTTP como GET, POST, PUT e DELETE para manipular recursos."
			},
			{
				"id": "maleta_normal_desenvolvimento_web_json_04",
				"topic": "Desenvolvimento Web",
				"problema": "Cenário de Desenvolvimento Web: a equipe precisa lidar com uma situação em que representa dados em formato textual leve, muito usado em APIs.",
				"opcoes": ["JSON", "Roteamento", "XSS"],
				"correta": "JSON",
				"explanation": "JSON significa JavaScript Object Notation. Ele é comum em APIs porque é simples, legível e compatível com várias linguagens."
			},
			{
				"id": "maleta_normal_back_end_cache_05",
				"topic": "Back-end",
				"problema": "Cenário de Back-end: a equipe precisa lidar com uma situação em que guarda dados temporários para reduzir tempo de resposta e carga de processamento.",
				"opcoes": ["Cache", "HTTP", "Persona"],
				"correta": "Cache",
				"explanation": "Cache melhora desempenho ao reutilizar dados acessados com frequência. O cuidado é manter validade e evitar entregar informação desatualizada."
			},
			{
				"id": "maleta_normal_banco_de_dados_transacao_06",
				"topic": "Banco de Dados",
				"problema": "Cenário de Banco de Dados: a equipe precisa lidar com uma situação em que agrupa operações que devem ser confirmadas ou desfeitas de forma consistente.",
				"opcoes": ["Transação", "HTTPS", "Heurísticas de Nielsen"],
				"correta": "Transação",
				"explanation": "Transação protege a consistência dos dados. Se tudo dá certo, ocorre commit; se algo falha, rollback desfaz as alterações."
			},
			{
				"id": "maleta_normal_banco_de_dados_indice_07",
				"topic": "Banco de Dados",
				"problema": "Cenário de Banco de Dados: a equipe precisa lidar com uma situação em que acelera buscas em tabelas, mas pode aumentar custo de escrita e armazenamento.",
				"opcoes": ["Índice", "VPN", "Design Responsivo"],
				"correta": "Índice",
				"explanation": "Índice é uma estrutura auxiliar para localizar registros mais rápido. Ele melhora consultas, mas exige equilíbrio porque impacta inserções e atualizações."
			},
			{
				"id": "maleta_normal_banco_de_dados_chave_estrangeira_08",
				"topic": "Banco de Dados",
				"problema": "Cenário de Banco de Dados: a equipe precisa lidar com uma situação em que cria vínculo entre tabelas e preserva integridade referencial.",
				"opcoes": ["Chave Estrangeira", "Hash", "DevOps"],
				"correta": "Chave Estrangeira",
				"explanation": "Chave estrangeira referencia a chave primária de outra tabela. Ela ajuda a evitar relacionamentos inválidos entre registros."
			},
			{
				"id": "maleta_normal_modelagem_de_dados_diagrama_er_09",
				"topic": "Modelagem de Dados",
				"problema": "Cenário de Modelagem de Dados: a equipe precisa lidar com uma situação em que representa entidades, atributos e relacionamentos de um domínio.",
				"opcoes": ["Diagrama ER", "Criptografia", "Pipeline"],
				"correta": "Diagrama ER",
				"explanation": "Diagrama ER significa Entidade-Relacionamento. Ele apoia a modelagem conceitual de bancos de dados antes da criação das tabelas."
			},
			{
				"id": "maleta_normal_banco_de_dados_normalizacao_10",
				"topic": "Banco de Dados",
				"problema": "Cenário de Banco de Dados: a equipe precisa lidar com uma situação em que organiza tabelas para reduzir redundância e anomalias de atualização.",
				"opcoes": ["Normalização", "SQL Injection", "Container"],
				"correta": "Normalização",
				"explanation": "Normalização aplica formas normais para melhorar consistência no banco relacional. Ela reduz repetição indevida, mas pode exigir joins mais frequentes."
			},
			{
				"id": "maleta_normal_redes_roteamento_11",
				"topic": "Redes",
				"problema": "Cenário de Redes: a equipe precisa lidar com uma situação em que define o caminho que pacotes percorrem entre origem e destino.",
				"opcoes": ["Roteamento", "XSS", "CI/CD"],
				"correta": "Roteamento",
				"explanation": "Roteamento encaminha pacotes entre redes. Roteadores usam tabelas e protocolos para escolher o melhor caminho disponível."
			},
			{
				"id": "maleta_normal_redes_e_web_http_12",
				"topic": "Redes e Web",
				"problema": "Cenário de Redes e Web: a equipe precisa lidar com uma situação em que protocolo usado para comunicação entre clientes e servidores web.",
				"opcoes": ["HTTP", "Persona", "ETL"],
				"correta": "HTTP",
				"explanation": "HTTP significa HyperText Transfer Protocol. Ele define requisições e respostas na web, usando métodos como GET e POST."
			},
			{
				"id": "maleta_normal_redes_e_seguranca_https_13",
				"topic": "Redes e Segurança",
				"problema": "Cenário de Redes e Segurança: a equipe precisa lidar com uma situação em que protege a comunicação web com criptografia sobre TLS.",
				"opcoes": ["HTTPS", "Heurísticas de Nielsen", "KPI"],
				"correta": "HTTPS",
				"explanation": "HTTPS significa HyperText Transfer Protocol Secure. Ele usa TLS para proteger confidencialidade, integridade e autenticidade da comunicação."
			},
			{
				"id": "maleta_normal_redes_e_seguranca_vpn_14",
				"topic": "Redes e Segurança",
				"problema": "Cenário de Redes e Segurança: a equipe precisa lidar com uma situação em que cria um túnel seguro para acesso remoto ou conexão entre redes.",
				"opcoes": ["VPN", "Design Responsivo", "Mineração de Dados"],
				"correta": "VPN",
				"explanation": "VPN significa Virtual Private Network, ou Rede Privada Virtual. Ela protege tráfego e permite acesso seguro a recursos internos."
			},
			{
				"id": "maleta_normal_ciberseguranca_hash_15",
				"topic": "Cibersegurança",
				"problema": "Cenário de Cibersegurança: a equipe precisa lidar com uma situação em que gera um resumo de tamanho fixo a partir de dados de entrada.",
				"opcoes": ["Hash", "DevOps", "GroupBy"],
				"correta": "Hash",
				"explanation": "Hash é uma função que transforma dados em um resumo. É usado para integridade e armazenamento seguro de senhas quando combinado com salting e boas práticas."
			},
			{
				"id": "maleta_normal_ciberseguranca_criptografia_16",
				"topic": "Cibersegurança",
				"problema": "Cenário de Cibersegurança: a equipe precisa lidar com uma situação em que transforma dados para que só possam ser compreendidos com chave adequada.",
				"opcoes": ["Criptografia", "Pipeline", "Padronização de Dados"],
				"correta": "Criptografia",
				"explanation": "Criptografia protege confidencialidade e, em alguns usos, integridade e autenticidade. Ela é base de HTTPS, armazenamento seguro e comunicação protegida."
			},
			{
				"id": "maleta_normal_ciberseguranca_sql_injection_17",
				"topic": "Cibersegurança",
				"problema": "Cenário de Cibersegurança: a equipe precisa lidar com uma situação em que ocorre quando entrada maliciosa manipula comandos SQL de uma aplicação.",
				"opcoes": ["SQL Injection", "Container", "Chave Estrangeira"],
				"correta": "SQL Injection",
				"explanation": "SQL Injection é uma vulnerabilidade de injeção em banco de dados. Validação, consultas parametrizadas e menor privilégio reduzem esse risco."
			},
			{
				"id": "maleta_normal_ciberseguranca_xss_18",
				"topic": "Cibersegurança",
				"problema": "Cenário de Cibersegurança: a equipe precisa lidar com uma situação em que injeta scripts maliciosos em páginas vistas por usuários.",
				"opcoes": ["XSS", "CI/CD", "Diagrama ER"],
				"correta": "XSS",
				"explanation": "XSS significa Cross-Site Scripting. Ele ocorre quando uma aplicação exibe conteúdo não tratado, permitindo execução de scripts no navegador da vítima."
			},
			{
				"id": "maleta_normal_ux_ihc_persona_19",
				"topic": "UX/IHC",
				"problema": "Cenário de UX/IHC: a equipe precisa lidar com uma situação em que representa um perfil fictício baseado em características de usuários reais.",
				"opcoes": ["Persona", "ETL", "API REST"],
				"correta": "Persona",
				"explanation": "Persona ajuda equipes a projetarem pensando em necessidades, dores, objetivos e contexto de uso de grupos de usuários."
			},
			{
				"id": "maleta_normal_ux_ihc_heuristicas_de_nielsen_20",
				"topic": "UX/IHC",
				"problema": "Cenário de UX/IHC: a equipe precisa lidar com uma situação em que são princípios usados para avaliar problemas de usabilidade em interfaces.",
				"opcoes": ["Heurísticas de Nielsen", "KPI", "JSON"],
				"correta": "Heurísticas de Nielsen",
				"explanation": "As heurísticas de Nielsen orientam avaliação de interfaces, incluindo feedback, consistência, prevenção de erros e liberdade do usuário."
			},
			{
				"id": "maleta_normal_front_end_design_responsivo_21",
				"topic": "Front-end",
				"problema": "Cenário de Front-end: a equipe precisa lidar com uma situação em que adapta a interface a diferentes tamanhos de tela e dispositivos.",
				"opcoes": ["Design Responsivo", "Mineração de Dados", "Cache"],
				"correta": "Design Responsivo",
				"explanation": "Design responsivo usa layouts flexíveis, media queries e boas práticas de interface para manter usabilidade em celular, tablet e desktop."
			},
			{
				"id": "maleta_normal_devops_devops_22",
				"topic": "DevOps",
				"problema": "Cenário de DevOps: a equipe precisa lidar com uma situação em que integra desenvolvimento e operações para entregar software com mais qualidade e frequência.",
				"opcoes": ["DevOps", "GroupBy", "Transação"],
				"correta": "DevOps",
				"explanation": "DevOps combina cultura, automação e colaboração. Ele reduz atritos entre desenvolvimento, testes, infraestrutura e implantação."
			},
			{
				"id": "maleta_normal_devops_pipeline_23",
				"topic": "DevOps",
				"problema": "Cenário de DevOps: a equipe precisa lidar com uma situação em que automatiza etapas como build, testes, análise e deploy.",
				"opcoes": ["Pipeline", "Padronização de Dados", "Índice"],
				"correta": "Pipeline",
				"explanation": "Pipeline organiza o fluxo de entrega de software. Em CI/CD, ele reduz tarefas manuais e torna publicações mais repetíveis."
			},
			{
				"id": "maleta_normal_devops_container_24",
				"topic": "DevOps",
				"problema": "Cenário de DevOps: a equipe precisa lidar com uma situação em que empacota aplicação e dependências em ambiente isolado e reproduzível.",
				"opcoes": ["Container", "Autenticação", "Chave Estrangeira"],
				"correta": "Container",
				"explanation": "Container ajuda a executar software de forma consistente entre desenvolvimento, teste e produção. Docker é uma ferramenta comum nesse contexto."
			},
			{
				"id": "maleta_normal_devops_ci_cd_25",
				"topic": "DevOps",
				"problema": "Cenário de DevOps: a equipe precisa lidar com uma situação em que automatiza integração, testes e entrega de software.",
				"opcoes": ["CI/CD", "Autorização", "Diagrama ER"],
				"correta": "CI/CD",
				"explanation": "CI/CD significa Continuous Integration e Continuous Delivery/Deployment, ou Integração Contínua e Entrega/Implantação Contínua. Ele reduz erros manuais e acelera entregas."
			},
			{
				"id": "maleta_normal_dados_e_bi_etl_26",
				"topic": "Dados e BI",
				"problema": "Cenário de Dados e BI: a equipe precisa lidar com uma situação em que extrai, transforma e carrega dados para outro ambiente de armazenamento ou análise.",
				"opcoes": ["ETL", "API REST", "Normalização"],
				"correta": "ETL",
				"explanation": "ETL significa Extract, Transform and Load, ou Extração, Transformação e Carga. Ele coleta dados, aplica tratamentos e carrega o resultado em bases analíticas, como Data Warehouse."
			},
			{
				"id": "maleta_normal_business_intelligence_kpi_27",
				"topic": "Business Intelligence",
				"problema": "Cenário de Business Intelligence: a equipe precisa lidar com uma situação em que mede desempenho de processos, metas ou resultados importantes para o negócio.",
				"opcoes": ["KPI", "JSON", "Roteamento"],
				"correta": "KPI",
				"explanation": "KPI significa Key Performance Indicator, ou Indicador-Chave de Desempenho. Ele ajuda a acompanhar objetivos com métricas relevantes e acionáveis."
			},
			{
				"id": "maleta_normal_ciencia_de_dados_mineracao_de_dados_28",
				"topic": "Ciência de Dados",
				"problema": "Cenário de Ciência de Dados: a equipe precisa lidar com uma situação em que busca padrões, relações e conhecimento útil em grandes conjuntos de dados.",
				"opcoes": ["Mineração de Dados", "Cache", "HTTP"],
				"correta": "Mineração de Dados",
				"explanation": "Mineração de dados aplica técnicas para descobrir padrões, agrupamentos, associações ou classificações. Ela pode fazer parte do processo KDD."
			},
			{
				"id": "maleta_normal_pandas_e_analise_de_dados_groupby_29",
				"topic": "Pandas e Análise de Dados",
				"problema": "Cenário de Pandas e Análise de Dados: a equipe precisa lidar com uma situação em que agrupa registros no Pandas para calcular somas, médias, contagens ou outras agregações.",
				"opcoes": ["GroupBy", "Transação", "HTTPS"],
				"correta": "GroupBy",
				"explanation": "GroupBy é uma operação do Pandas inspirada no padrão split-apply-combine. Ela separa dados por grupos, aplica cálculos e combina os resultados."
			},
			{
				"id": "maleta_normal_qualidade_de_dados_padronizacao_de_dados_30",
				"topic": "Qualidade de Dados",
				"problema": "Cenário de Qualidade de Dados: a equipe precisa lidar com uma situação em que coloca valores em formatos consistentes antes da análise.",
				"opcoes": ["Padronização de Dados", "Índice", "VPN"],
				"correta": "Padronização de Dados",
				"explanation": "Padronização de dados evita categorias duplicadas e comparações incorretas. Exemplos comuns envolvem datas, nomes, siglas, letras maiúsculas e unidades de medida."
			}
		],
		"dificil": [
			{
				"id": "maleta_dificil_business_intelligence_data_warehouse_01",
				"topic": "Business Intelligence",
				"problema": "Cenário de Business Intelligence: a equipe precisa lidar com uma situação em que integra dados históricos, orientados por assunto, para apoiar decisões gerenciais.",
				"opcoes": ["Data Warehouse", "KDD", "Dívida Técnica"],
				"correta": "Data Warehouse",
				"explanation": "Data Warehouse é um repositório analítico integrado, histórico e não volátil. Ele consolida dados de várias fontes para consultas, indicadores e análises estratégicas."
			},
			{
				"id": "maleta_dificil_business_intelligence_data_mart_02",
				"topic": "Business Intelligence",
				"problema": "Cenário de Business Intelligence: a equipe precisa lidar com uma situação em que representa um subconjunto analítico voltado a uma área ou departamento específico.",
				"opcoes": ["Data Mart", "Outlier", "MVC"],
				"correta": "Data Mart",
				"explanation": "Data Mart é uma parte menor de um Data Warehouse. Ele atende necessidades de uma área, como vendas, financeiro ou recursos humanos."
			},
			{
				"id": "maleta_dificil_business_intelligence_olap_03",
				"topic": "Business Intelligence",
				"problema": "Cenário de Business Intelligence: a equipe precisa lidar com uma situação em que apoia análise multidimensional de dados históricos e agregados.",
				"opcoes": ["OLAP", "Correlação", "SOLID"],
				"correta": "OLAP",
				"explanation": "OLAP significa Online Analytical Processing. Ele é voltado a consultas analíticas, comparações, agregações e exploração de dados para decisão."
			},
			{
				"id": "maleta_dificil_banco_de_dados_oltp_04",
				"topic": "Banco de Dados",
				"problema": "Cenário de Banco de Dados: a equipe precisa lidar com uma situação em que processa transações operacionais frequentes do dia a dia.",
				"opcoes": ["OLTP", "Amostragem", "Polimorfismo"],
				"correta": "OLTP",
				"explanation": "OLTP significa Online Transaction Processing. Ele prioriza consistência, rapidez em transações e operações como cadastro, compra, pagamento e atualização."
			},
			{
				"id": "maleta_dificil_data_warehouse_star_schema_05",
				"topic": "Data Warehouse",
				"problema": "Cenário de Data Warehouse: a equipe precisa lidar com uma situação em que modela dados analíticos com uma tabela fato central ligada a tabelas dimensão.",
				"opcoes": ["Star Schema", "Feature Engineering", "Scrum"],
				"correta": "Star Schema",
				"explanation": "Star Schema, ou esquema estrela, facilita consultas analíticas. A tabela fato guarda métricas, enquanto dimensões descrevem contexto como tempo, produto e local."
			},
			{
				"id": "maleta_dificil_data_warehouse_granularidade_06",
				"topic": "Data Warehouse",
				"problema": "Cenário de Data Warehouse: a equipe precisa lidar com uma situação em que define o nível de detalhe armazenado nos dados de uma tabela fato.",
				"opcoes": ["Granularidade", "Acoplamento", "COBIT"],
				"correta": "Granularidade",
				"explanation": "Granularidade indica quão detalhado é um dado. Em Data Warehouse, granularidade baixa guarda mais detalhes; granularidade alta guarda dados mais resumidos."
			},
			{
				"id": "maleta_dificil_governanca_de_dados_metadados_07",
				"topic": "Governança de Dados",
				"problema": "Cenário de Governança de Dados: a equipe precisa lidar com uma situação em que descrevem origem, significado, estrutura e regras dos dados.",
				"opcoes": ["Metadados", "Coesão", "ITIL"],
				"correta": "Metadados",
				"explanation": "Metadados são dados sobre dados. Eles ajudam a entender campos, fontes, qualidade, periodicidade, responsáveis e regras de uso."
			},
			{
				"id": "maleta_dificil_mineracao_de_dados_kdd_08",
				"topic": "Mineração de Dados",
				"problema": "Cenário de Mineração de Dados: a equipe precisa lidar com uma situação em que organiza o processo de descoberta de conhecimento em bases de dados.",
				"opcoes": ["KDD", "Dívida Técnica", "SLA"],
				"correta": "KDD",
				"explanation": "KDD significa Knowledge Discovery in Databases, ou Descoberta de Conhecimento em Bases de Dados. Inclui seleção, limpeza, transformação, mineração e interpretação."
			},
			{
				"id": "maleta_dificil_ciencia_de_dados_outlier_09",
				"topic": "Ciência de Dados",
				"problema": "Cenário de Ciência de Dados: a equipe precisa lidar com uma situação em que representa um valor muito distante do comportamento esperado dos dados.",
				"opcoes": ["Outlier", "MVC", "RTO e RPO"],
				"correta": "Outlier",
				"explanation": "Outlier pode indicar erro, evento raro ou comportamento relevante. Antes de remover, o analista precisa entender o contexto e o impacto na análise."
			},
			{
				"id": "maleta_dificil_estatistica_e_dados_correlacao_10",
				"topic": "Estatística e Dados",
				"problema": "Cenário de Estatística e Dados: a equipe precisa lidar com uma situação em que mede associação entre variáveis, mas não prova relação de causa e efeito.",
				"opcoes": ["Correlação", "SOLID", "Zero Trust"],
				"correta": "Correlação",
				"explanation": "Correlação indica se variáveis tendem a variar juntas. Em análise de dados, é importante lembrar que correlação não implica causalidade."
			},
			{
				"id": "maleta_dificil_estatistica_e_dados_amostragem_11",
				"topic": "Estatística e Dados",
				"problema": "Cenário de Estatística e Dados: a equipe precisa lidar com uma situação em que seleciona parte dos dados para representar uma população maior.",
				"opcoes": ["Amostragem", "Polimorfismo", "Menor Privilégio"],
				"correta": "Amostragem",
				"explanation": "Amostragem reduz custo de coleta e análise, mas precisa ser planejada para evitar vieses e manter representatividade."
			},
			{
				"id": "maleta_dificil_ciencia_de_dados_feature_engineering_12",
				"topic": "Ciência de Dados",
				"problema": "Cenário de Ciência de Dados: a equipe precisa lidar com uma situação em que cria ou transforma variáveis para melhorar análises e modelos preditivos.",
				"opcoes": ["Feature Engineering", "Scrum", "OAuth 2.0"],
				"correta": "Feature Engineering",
				"explanation": "Feature Engineering envolve preparar atributos, criar indicadores, transformar escalas e extrair sinais úteis. A qualidade das variáveis influencia fortemente modelos de dados."
			},
			{
				"id": "maleta_dificil_engenharia_de_software_acoplamento_13",
				"topic": "Engenharia de Software",
				"problema": "Cenário de Engenharia de Software: a equipe precisa lidar com uma situação em que mede o grau de dependência entre módulos, classes ou componentes.",
				"opcoes": ["Acoplamento", "COBIT", "JWT"],
				"correta": "Acoplamento",
				"explanation": "Baixo acoplamento facilita manutenção, testes e evolução porque reduz dependências entre partes do sistema."
			},
			{
				"id": "maleta_dificil_engenharia_de_software_coesao_14",
				"topic": "Engenharia de Software",
				"problema": "Cenário de Engenharia de Software: a equipe precisa lidar com uma situação em que mede o quanto responsabilidades internas de um módulo estão relacionadas entre si.",
				"opcoes": ["Coesão", "ITIL", "Observabilidade"],
				"correta": "Coesão",
				"explanation": "Alta coesão é desejável porque mantém componentes focados em uma responsabilidade clara, melhorando entendimento e manutenção."
			},
			{
				"id": "maleta_dificil_engenharia_de_software_divida_tecnica_15",
				"topic": "Engenharia de Software",
				"problema": "Cenário de Engenharia de Software: a equipe precisa lidar com uma situação em que representa custo futuro gerado por soluções rápidas, frágeis ou mal planejadas.",
				"opcoes": ["Dívida Técnica", "SLA", "IaC"],
				"correta": "Dívida Técnica",
				"explanation": "Dívida técnica surge quando a equipe escolhe atalhos. Se não for controlada, aumenta retrabalho, dificulta manutenção e reduz velocidade de evolução."
			},
			{
				"id": "maleta_dificil_arquitetura_de_software_mvc_16",
				"topic": "Arquitetura de Software",
				"problema": "Cenário de Arquitetura de Software: a equipe precisa lidar com uma situação em que separa responsabilidades entre modelo, visão e controlador.",
				"opcoes": ["MVC", "RTO e RPO", "Privacidade por Design"],
				"correta": "MVC",
				"explanation": "MVC significa Model-View-Controller. Ele organiza dados, interface e fluxo de controle em camadas para reduzir mistura de responsabilidades."
			},
			{
				"id": "maleta_dificil_arquitetura_de_software_solid_17",
				"topic": "Arquitetura de Software",
				"problema": "Cenário de Arquitetura de Software: a equipe precisa lidar com uma situação em que reúne princípios de design orientado a objetos para reduzir rigidez e facilitar manutenção.",
				"opcoes": ["SOLID", "Zero Trust", "Data Warehouse"],
				"correta": "SOLID",
				"explanation": "SOLID é um conjunto de cinco princípios de projeto de software. Eles orientam responsabilidades claras, baixo acoplamento, extensibilidade e substituição segura."
			},
			{
				"id": "maleta_dificil_poo_polimorfismo_18",
				"topic": "POO",
				"problema": "Cenário de POO: a equipe precisa lidar com uma situação em que permite que diferentes objetos respondam de formas específicas à mesma operação.",
				"opcoes": ["Polimorfismo", "Menor Privilégio", "Data Mart"],
				"correta": "Polimorfismo",
				"explanation": "Polimorfismo é um princípio da Programação Orientada a Objetos. Ele permite tratar objetos por uma interface comum, mantendo comportamentos especializados."
			},
			{
				"id": "maleta_dificil_gestao_de_projetos_scrum_19",
				"topic": "Gestão de Projetos",
				"problema": "Cenário de Gestão de Projetos: a equipe precisa lidar com uma situação em que organiza trabalho ágil em eventos, papéis e artefatos para entrega incremental.",
				"opcoes": ["Scrum", "OAuth 2.0", "OLAP"],
				"correta": "Scrum",
				"explanation": "Scrum é um framework ágil com papéis como Product Owner, Scrum Master e Developers. Ele usa Sprints, Backlog e revisões para adaptação contínua."
			},
			{
				"id": "maleta_dificil_governanca_de_ti_cobit_20",
				"topic": "Governança de TI",
				"problema": "Cenário de Governança de TI: a equipe precisa lidar com uma situação em que orienta governança e gestão de TI alinhadas aos objetivos do negócio.",
				"opcoes": ["COBIT", "JWT", "OLTP"],
				"correta": "COBIT",
				"explanation": "COBIT significa Control Objectives for Information and Related Technologies. Ele apoia governança, controle, valor, riscos e alinhamento estratégico de TI."
			},
			{
				"id": "maleta_dificil_governanca_de_ti_itil_21",
				"topic": "Governança de TI",
				"problema": "Cenário de Governança de TI: a equipe precisa lidar com uma situação em que organiza boas práticas para gestão de serviços de TI.",
				"opcoes": ["ITIL", "Observabilidade", "Star Schema"],
				"correta": "ITIL",
				"explanation": "ITIL significa Information Technology Infrastructure Library. Ela trata serviços, incidentes, mudanças, problemas, níveis de serviço e melhoria contínua."
			},
			{
				"id": "maleta_dificil_governanca_de_ti_sla_22",
				"topic": "Governança de TI",
				"problema": "Cenário de Governança de TI: a equipe precisa lidar com uma situação em que formaliza níveis de serviço esperados entre provedor e cliente.",
				"opcoes": ["SLA", "IaC", "Granularidade"],
				"correta": "SLA",
				"explanation": "SLA significa Service Level Agreement, ou Acordo de Nível de Serviço. Ele define metas como disponibilidade, tempo de resposta e prazo de atendimento."
			},
			{
				"id": "maleta_dificil_continuidade_de_negocio_rto_e_rpo_23",
				"topic": "Continuidade de Negócio",
				"problema": "Cenário de Continuidade de Negócio: a equipe precisa lidar com uma situação em que definem tempo máximo de recuperação e perda máxima aceitável de dados.",
				"opcoes": ["RTO e RPO", "Privacidade por Design", "Metadados"],
				"correta": "RTO e RPO",
				"explanation": "RTO significa Recovery Time Objective, ou tempo máximo para restaurar o serviço. RPO significa Recovery Point Objective, ou ponto máximo aceitável de perda de dados."
			},
			{
				"id": "maleta_dificil_ciberseguranca_zero_trust_24",
				"topic": "Cibersegurança",
				"problema": "Cenário de Cibersegurança: a equipe precisa lidar com uma situação em que assume que nenhuma conexão deve ser confiável automaticamente.",
				"opcoes": ["Zero Trust", "Data Warehouse", "KDD"],
				"correta": "Zero Trust",
				"explanation": "Zero Trust, ou confiança zero, exige verificação contínua de identidade, contexto e permissões. A ideia central é nunca confiar por padrão."
			},
			{
				"id": "maleta_dificil_ciberseguranca_menor_privilegio_25",
				"topic": "Cibersegurança",
				"problema": "Cenário de Cibersegurança: a equipe precisa lidar com uma situação em que concede apenas as permissões necessárias para executar uma atividade.",
				"opcoes": ["Menor Privilégio", "Data Mart", "Outlier"],
				"correta": "Menor Privilégio",
				"explanation": "O princípio do menor privilégio reduz danos em caso de falha ou invasão. Usuários e sistemas não devem ter acessos além do necessário."
			},
			{
				"id": "maleta_dificil_ciberseguranca_oauth_2_0_26",
				"topic": "Cibersegurança",
				"problema": "Cenário de Cibersegurança: a equipe precisa lidar com uma situação em que permite autorização delegada sem compartilhar senha com aplicações terceiras.",
				"opcoes": ["OAuth 2.0", "OLAP", "Correlação"],
				"correta": "OAuth 2.0",
				"explanation": "OAuth 2.0 é um protocolo de autorização. Ele permite que uma aplicação acesse recursos em nome do usuário por meio de tokens controlados."
			},
			{
				"id": "maleta_dificil_ciberseguranca_jwt_27",
				"topic": "Cibersegurança",
				"problema": "Cenário de Cibersegurança: a equipe precisa lidar com uma situação em que transporta declarações verificáveis entre sistemas em formato compacto.",
				"opcoes": ["JWT", "OLTP", "Amostragem"],
				"correta": "JWT",
				"explanation": "JWT significa JSON Web Token. Ele é usado para representar claims, como identidade e permissões, mas precisa de expiração, assinatura e armazenamento seguro."
			},
			{
				"id": "maleta_dificil_devops_observabilidade_28",
				"topic": "DevOps",
				"problema": "Cenário de DevOps: a equipe precisa lidar com uma situação em que permite entender o estado interno do sistema a partir de logs, métricas e traces.",
				"opcoes": ["Observabilidade", "Star Schema", "Feature Engineering"],
				"correta": "Observabilidade",
				"explanation": "Observabilidade combina sinais como logs, métricas e rastreamento distribuído. Ela ajuda a investigar falhas, gargalos e comportamento em produção."
			},
			{
				"id": "maleta_dificil_devops_e_cloud_iac_29",
				"topic": "DevOps e Cloud",
				"problema": "Cenário de DevOps e Cloud: a equipe precisa lidar com uma situação em que gerencia infraestrutura por arquivos versionáveis em vez de configuração manual.",
				"opcoes": ["IaC", "Granularidade", "Acoplamento"],
				"correta": "IaC",
				"explanation": "IaC significa Infrastructure as Code, ou Infraestrutura como Código. Ela torna ambientes reproduzíveis, auditáveis e menos dependentes de configuração manual."
			},
			{
				"id": "maleta_dificil_lgpd_e_etica_privacidade_por_design_30",
				"topic": "LGPD e Ética",
				"problema": "Cenário de LGPD e Ética: a equipe precisa lidar com uma situação em que inclui proteção de dados desde a concepção do sistema, não apenas no fim do projeto.",
				"opcoes": ["Privacidade por Design", "Metadados", "Coesão"],
				"correta": "Privacidade por Design",
				"explanation": "Privacidade por design coloca proteção de dados no planejamento, arquitetura e operação. Ela se relaciona com minimização, finalidade, segurança e transparência."
			}
		]
	},
	"perseguicao": {
		"facil": [
			{
				"id": "perseguicao_facil_desenvolvimento_web_html_01",
				"topic": "Desenvolvimento Web",
				"descricao": "Incidente de Desenvolvimento Web: Estrutura o conteúdo de páginas web usando marcações como títulos, parágrafos, links e seções. Qual ação reduz melhor o risco?",
				"opcoes": ["Revisar com HTML", "Ignorar HTML", "Improvisar sem validar"],
				"correta": "Revisar com HTML",
				"explanation": "Revisar com HTML é adequado. Conceito revisado: HTML significa HyperText Markup Language, ou Linguagem de Marcação de Hipertexto. Ele define a estrutura semântica de uma página web, como títulos, textos, listas, links e formulários."
			},
			{
				"id": "perseguicao_facil_front_end_css_02",
				"topic": "Front-end",
				"descricao": "Incidente de Front-end: Controla cores, espaçamentos, fontes e layout visual de uma página web. Qual ação reduz melhor o risco?",
				"opcoes": ["Revisar com CSS", "Ignorar CSS", "Improvisar sem validar"],
				"correta": "Revisar com CSS",
				"explanation": "Revisar com CSS é adequado. Conceito revisado: CSS significa Cascading Style Sheets, ou Folhas de Estilo em Cascata. Ele separa a apresentação visual da estrutura HTML e permite criar interfaces responsivas e organizadas."
			},
			{
				"id": "perseguicao_facil_programacao_web_javascript_03",
				"topic": "Programação Web",
				"descricao": "Incidente de Programação Web: Adiciona comportamento dinâmico em páginas e aplicações web. Qual ação reduz melhor o risco?",
				"opcoes": ["Revisar com JavaScript", "Ignorar JavaScript", "Improvisar sem validar"],
				"correta": "Revisar com JavaScript",
				"explanation": "Revisar com JavaScript é adequado. Conceito revisado: JavaScript é uma linguagem de programação muito usada no navegador e também no back-end. Ela permite validar formulários, manipular o DOM, consumir APIs e criar interações dinâmicas."
			},
			{
				"id": "perseguicao_facil_back_end_api_04",
				"topic": "Back-end",
				"descricao": "Incidente de Back-end: Permite que sistemas diferentes se comuniquem por meio de regras e pontos de acesso definidos. Qual ação reduz melhor o risco?",
				"opcoes": ["Revisar com API", "Ignorar API", "Improvisar sem validar"],
				"correta": "Revisar com API",
				"explanation": "Revisar com API é adequado. Conceito revisado: API significa Application Programming Interface, ou Interface de Programação de Aplicações. Ela expõe funcionalidades para que sistemas, aplicativos ou serviços troquem dados de forma padronizada."
			},
			{
				"id": "perseguicao_facil_banco_de_dados_banco_de_dados_05",
				"topic": "Banco de Dados",
				"descricao": "Incidente de Banco de Dados: Organiza e armazena dados para consulta, atualização e uso por sistemas. Qual ação reduz melhor o risco?",
				"opcoes": ["Analisar com Banco de Dados", "Ignorar Banco de Dados", "Improvisar sem validar"],
				"correta": "Analisar com Banco de Dados",
				"explanation": "Analisar com Banco de Dados é adequado. Conceito revisado: Banco de dados é uma estrutura usada para armazenar informações de forma persistente. Em sistemas de informação, ele sustenta cadastros, transações, consultas e relatórios."
			},
			{
				"id": "perseguicao_facil_sql_select_06",
				"topic": "SQL",
				"descricao": "Incidente de SQL: Recupera registros de tabelas em um banco de dados relacional. Qual ação reduz melhor o risco?",
				"opcoes": ["Revisar com SELECT", "Ignorar SELECT", "Improvisar sem validar"],
				"correta": "Revisar com SELECT",
				"explanation": "Revisar com SELECT é adequado. Conceito revisado: SELECT é um comando da linguagem SQL usado para consultar dados. Ele pode ser combinado com WHERE, JOIN, GROUP BY e ORDER BY para filtrar, relacionar e ordenar resultados."
			},
			{
				"id": "perseguicao_facil_estruturas_de_dados_pilha_07",
				"topic": "Estruturas de Dados",
				"descricao": "Incidente de Estruturas de Dados: Organiza dados no padrão em que o último elemento inserido é o primeiro a sair. Qual ação reduz melhor o risco?",
				"opcoes": ["Analisar com Pilha", "Ignorar Pilha", "Improvisar sem validar"],
				"correta": "Analisar com Pilha",
				"explanation": "Analisar com Pilha é adequado. Conceito revisado: Pilha é uma estrutura de dados baseada em LIFO, Last In, First Out. Ela aparece em chamadas de funções, desfazer ações e controle de execução."
			},
			{
				"id": "perseguicao_facil_estruturas_de_dados_fila_08",
				"topic": "Estruturas de Dados",
				"descricao": "Incidente de Estruturas de Dados: Organiza dados no padrão em que o primeiro elemento inserido é o primeiro a sair. Qual ação reduz melhor o risco?",
				"opcoes": ["Analisar com Fila", "Ignorar Fila", "Improvisar sem validar"],
				"correta": "Analisar com Fila",
				"explanation": "Analisar com Fila é adequado. Conceito revisado: Fila é uma estrutura de dados baseada em FIFO, First In, First Out. Ela é útil em atendimento, processamento de tarefas e filas de mensagens."
			},
			{
				"id": "perseguicao_facil_seguranca_da_informacao_backup_09",
				"topic": "Segurança da Informação",
				"descricao": "Incidente de Segurança da Informação: Preserva cópias de dados para recuperação após falhas, exclusões ou incidentes. Qual ação reduz melhor o risco?",
				"opcoes": ["Aplicar Backup", "Ignorar Backup", "Improvisar sem validar"],
				"correta": "Aplicar Backup",
				"explanation": "Aplicar Backup é adequado. Conceito revisado: Backup é uma cópia de segurança dos dados. Ele reduz perdas em falhas, ataques, erros humanos e desastres, mas precisa ser testado para garantir restauração."
			},
			{
				"id": "perseguicao_facil_ciberseguranca_mfa_10",
				"topic": "Cibersegurança",
				"descricao": "Incidente de Cibersegurança: Exige mais de uma evidência para confirmar a identidade de um usuário. Qual ação reduz melhor o risco?",
				"opcoes": ["Aplicar MFA", "Ignorar MFA", "Improvisar sem validar"],
				"correta": "Aplicar MFA",
				"explanation": "Aplicar MFA é adequado. Conceito revisado: MFA significa Multi-Factor Authentication, ou Autenticação Multifator. Ele combina fatores como senha, aplicativo, biometria ou token para reduzir o risco de acesso indevido."
			},
			{
				"id": "perseguicao_facil_ux_ihc_ux_11",
				"topic": "UX/IHC",
				"descricao": "Incidente de UX/IHC: Avalia como uma pessoa percebe, entende e utiliza um produto ou serviço digital. Qual ação reduz melhor o risco?",
				"opcoes": ["Validar com UX", "Ignorar UX", "Improvisar sem validar"],
				"correta": "Validar com UX",
				"explanation": "Validar com UX é adequado. Conceito revisado: UX significa User Experience, ou Experiência do Usuário. Ela envolve utilidade, facilidade de uso, eficiência, emoção, contexto e satisfação durante a interação."
			},
			{
				"id": "perseguicao_facil_ihc_acessibilidade_12",
				"topic": "IHC",
				"descricao": "Incidente de IHC: Remove barreiras para que pessoas com diferentes capacidades consigam usar sistemas. Qual ação reduz melhor o risco?",
				"opcoes": ["Validar com Acessibilidade", "Ignorar Acessibilidade", "Improvisar sem validar"],
				"correta": "Validar com Acessibilidade",
				"explanation": "Validar com Acessibilidade é adequado. Conceito revisado: Acessibilidade busca tornar produtos digitais utilizáveis por mais pessoas. Ela envolve contraste, navegação por teclado, texto alternativo, leitores de tela e linguagem clara."
			},
			{
				"id": "perseguicao_facil_fundamentos_de_computacao_algoritmo_13",
				"topic": "Fundamentos de Computação",
				"descricao": "Incidente de Fundamentos de Computação: Define uma sequência finita e ordenada de passos para resolver um problema. Qual ação reduz melhor o risco?",
				"opcoes": ["Revisar com Algoritmo", "Ignorar Algoritmo", "Improvisar sem validar"],
				"correta": "Revisar com Algoritmo",
				"explanation": "Revisar com Algoritmo é adequado. Conceito revisado: Algoritmo é um conjunto de instruções lógicas para chegar a uma solução. Ele pode ser representado em linguagem natural, fluxograma, pseudocódigo ou código."
			},
			{
				"id": "perseguicao_facil_programacao_variavel_14",
				"topic": "Programação",
				"descricao": "Incidente de Programação: Armazena temporariamente valores usados por um programa durante sua execução. Qual ação reduz melhor o risco?",
				"opcoes": ["Revisar com Variável", "Ignorar Variável", "Improvisar sem validar"],
				"correta": "Revisar com Variável",
				"explanation": "Revisar com Variável é adequado. Conceito revisado: Variável é um nome associado a um valor em memória. Ela permite guardar dados como números, textos, estados e resultados intermediários."
			},
			{
				"id": "perseguicao_facil_programacao_funcao_15",
				"topic": "Programação",
				"descricao": "Incidente de Programação: Reúne instruções reutilizáveis para executar uma tarefa específica. Qual ação reduz melhor o risco?",
				"opcoes": ["Revisar com Função", "Ignorar Função", "Improvisar sem validar"],
				"correta": "Revisar com Função",
				"explanation": "Revisar com Função é adequado. Conceito revisado: Função organiza o código em blocos menores e reutilizáveis. Ela melhora leitura, manutenção, testes e evita repetição desnecessária."
			},
			{
				"id": "perseguicao_facil_devops_git_16",
				"topic": "DevOps",
				"descricao": "Incidente de DevOps: Registra histórico de alterações e ajuda equipes a colaborarem no código. Qual ação reduz melhor o risco?",
				"opcoes": ["Automatizar com Git", "Ignorar Git", "Improvisar sem validar"],
				"correta": "Automatizar com Git",
				"explanation": "Automatizar com Git é adequado. Conceito revisado: Git é um sistema de controle de versão distribuído. Ele permite criar branches, revisar mudanças, voltar versões e colaborar com mais segurança."
			},
			{
				"id": "perseguicao_facil_arquitetura_web_cliente_17",
				"topic": "Arquitetura Web",
				"descricao": "Incidente de Arquitetura Web: Representa o lado que solicita serviços, páginas ou dados a outro sistema. Qual ação reduz melhor o risco?",
				"opcoes": ["Revisar com Cliente", "Ignorar Cliente", "Improvisar sem validar"],
				"correta": "Revisar com Cliente",
				"explanation": "Revisar com Cliente é adequado. Conceito revisado: Cliente é o componente que consome um serviço, como navegador, aplicativo mobile ou sistema externo. Ele envia requisições para um servidor."
			},
			{
				"id": "perseguicao_facil_arquitetura_web_servidor_18",
				"topic": "Arquitetura Web",
				"descricao": "Incidente de Arquitetura Web: Processa requisições e entrega páginas, dados ou serviços para clientes. Qual ação reduz melhor o risco?",
				"opcoes": ["Revisar com Servidor", "Ignorar Servidor", "Improvisar sem validar"],
				"correta": "Revisar com Servidor",
				"explanation": "Revisar com Servidor é adequado. Conceito revisado: Servidor é o componente que recebe requisições, executa regras de negócio, consulta dados e envia respostas para clientes ou outros sistemas."
			},
			{
				"id": "perseguicao_facil_redes_rede_19",
				"topic": "Redes",
				"descricao": "Incidente de Redes: Permite comunicação e compartilhamento de recursos entre dispositivos. Qual ação reduz melhor o risco?",
				"opcoes": ["Revisar com Rede", "Ignorar Rede", "Improvisar sem validar"],
				"correta": "Revisar com Rede",
				"explanation": "Revisar com Rede é adequado. Conceito revisado: Rede de computadores conecta dispositivos para troca de dados. Ela pode usar protocolos, endereços, roteadores, switches e serviços como DNS e HTTP."
			},
			{
				"id": "perseguicao_facil_redes_dns_20",
				"topic": "Redes",
				"descricao": "Incidente de Redes: Traduz nomes de domínio em endereços ip usados na comunicação de rede. Qual ação reduz melhor o risco?",
				"opcoes": ["Revisar com DNS", "Ignorar DNS", "Improvisar sem validar"],
				"correta": "Revisar com DNS",
				"explanation": "Revisar com DNS é adequado. Conceito revisado: DNS significa Domain Name System, ou Sistema de Nomes de Domínio. Ele permite acessar sites por nomes como exemplo.com em vez de memorizar endereços IP."
			},
			{
				"id": "perseguicao_facil_ciberseguranca_firewall_21",
				"topic": "Cibersegurança",
				"descricao": "Incidente de Cibersegurança: Controla tráfego de rede usando regras de permissão e bloqueio. Qual ação reduz melhor o risco?",
				"opcoes": ["Aplicar Firewall", "Ignorar Firewall", "Improvisar sem validar"],
				"correta": "Aplicar Firewall",
				"explanation": "Aplicar Firewall é adequado. Conceito revisado: Firewall é um mecanismo de segurança que filtra comunicações. Ele pode bloquear conexões suspeitas, limitar portas e reduzir exposição de serviços."
			},
			{
				"id": "perseguicao_facil_engenharia_de_software_requisito_22",
				"topic": "Engenharia de Software",
				"descricao": "Incidente de Engenharia de Software: Descreve uma necessidade, função ou restrição que o sistema deve atender. Qual ação reduz melhor o risco?",
				"opcoes": ["Revisar com Requisito", "Ignorar Requisito", "Improvisar sem validar"],
				"correta": "Revisar com Requisito",
				"explanation": "Revisar com Requisito é adequado. Conceito revisado: Requisito registra o que o sistema precisa fazer ou respeitar. Pode ser funcional, quando descreve uma função, ou não funcional, quando descreve qualidade ou restrição."
			},
			{
				"id": "perseguicao_facil_qualidade_de_software_teste_23",
				"topic": "Qualidade de Software",
				"descricao": "Incidente de Qualidade de Software: Verifica se o software funciona conforme esperado e ajuda a encontrar defeitos. Qual ação reduz melhor o risco?",
				"opcoes": ["Revisar com Teste", "Ignorar Teste", "Improvisar sem validar"],
				"correta": "Revisar com Teste",
				"explanation": "Revisar com Teste é adequado. Conceito revisado: Teste de software reduz riscos ao verificar comportamentos esperados. Ele pode ser manual, automatizado, unitário, funcional, regressivo ou de integração."
			},
			{
				"id": "perseguicao_facil_qualidade_de_software_bug_24",
				"topic": "Qualidade de Software",
				"descricao": "Incidente de Qualidade de Software: Representa um defeito que faz o sistema agir diferente do esperado. Qual ação reduz melhor o risco?",
				"opcoes": ["Revisar com Bug", "Ignorar Bug", "Improvisar sem validar"],
				"correta": "Revisar com Bug",
				"explanation": "Revisar com Bug é adequado. Conceito revisado: Bug é uma falha ou defeito no software. Ele pode surgir por erro de lógica, requisito mal interpretado, integração incorreta ou dados inesperados."
			},
			{
				"id": "perseguicao_facil_business_intelligence_dashboard_25",
				"topic": "Business Intelligence",
				"descricao": "Incidente de Business Intelligence: Reúne gráficos e indicadores para apoiar acompanhamento e decisão. Qual ação reduz melhor o risco?",
				"opcoes": ["Analisar com Dashboard", "Ignorar Dashboard", "Improvisar sem validar"],
				"correta": "Analisar com Dashboard",
				"explanation": "Analisar com Dashboard é adequado. Conceito revisado: Dashboard é um painel visual com métricas, gráficos e indicadores. Em BI, ele ajuda a transformar dados em leitura rápida para gestão e acompanhamento."
			},
			{
				"id": "perseguicao_facil_ciencia_de_dados_dataframe_26",
				"topic": "Ciência de Dados",
				"descricao": "Incidente de Ciência de Dados: Representa dados em formato de tabela com linhas e colunas no pandas. Qual ação reduz melhor o risco?",
				"opcoes": ["Analisar com DataFrame", "Ignorar DataFrame", "Improvisar sem validar"],
				"correta": "Analisar com DataFrame",
				"explanation": "Analisar com DataFrame é adequado. Conceito revisado: DataFrame é a estrutura bidimensional do Pandas. Ele organiza dados como uma tabela, permitindo filtros, agrupamentos, junções, limpeza e análise exploratória."
			},
			{
				"id": "perseguicao_facil_ciencia_de_dados_series_27",
				"topic": "Ciência de Dados",
				"descricao": "Incidente de Ciência de Dados: Representa uma sequência unidimensional de dados no pandas, parecida com uma coluna. Qual ação reduz melhor o risco?",
				"opcoes": ["Analisar com Series", "Ignorar Series", "Improvisar sem validar"],
				"correta": "Analisar com Series",
				"explanation": "Analisar com Series é adequado. Conceito revisado: Series é uma estrutura unidimensional do Pandas, formada por valores e índice. Uma coluna de um DataFrame pode ser tratada como uma Series."
			},
			{
				"id": "perseguicao_facil_ciencia_de_dados_limpeza_de_dados_28",
				"topic": "Ciência de Dados",
				"descricao": "Incidente de Ciência de Dados: Trata valores ausentes, duplicados, tipos errados e inconsistências antes da análise. Qual ação reduz melhor o risco?",
				"opcoes": ["Analisar com Limpeza de Dados", "Ignorar Limpeza de Dados", "Improvisar sem validar"],
				"correta": "Analisar com Limpeza de Dados",
				"explanation": "Analisar com Limpeza de Dados é adequado. Conceito revisado: Limpeza de dados prepara uma base para análise confiável. Em projetos reais, essa etapa costuma consumir muito tempo porque dados chegam incompletos, duplicados ou fora de padrão."
			},
			{
				"id": "perseguicao_facil_lgpd_e_privacidade_lgpd_29",
				"topic": "LGPD e Privacidade",
				"descricao": "Incidente de LGPD e Privacidade: Define regras brasileiras para tratamento de dados pessoais. Qual ação reduz melhor o risco?",
				"opcoes": ["Aplicar LGPD", "Ignorar LGPD", "Improvisar sem validar"],
				"correta": "Aplicar LGPD",
				"explanation": "Aplicar LGPD é adequado. Conceito revisado: LGPD significa Lei Geral de Proteção de Dados. Ela regula coleta, uso, armazenamento e compartilhamento de dados pessoais no Brasil."
			},
			{
				"id": "perseguicao_facil_programacao_orientada_a_objetos_poo_30",
				"topic": "Programação Orientada a Objetos",
				"descricao": "Incidente de Programação Orientada a Objetos: Organiza programas em classes, objetos, atributos e métodos. Qual ação reduz melhor o risco?",
				"opcoes": ["Revisar com POO", "Ignorar POO", "Improvisar sem validar"],
				"correta": "Revisar com POO",
				"explanation": "Revisar com POO é adequado. Conceito revisado: POO significa Programação Orientada a Objetos. Ela modela o software com objetos que possuem dados e comportamentos, favorecendo organização e reutilização."
			}
		],
		"normal": [
			{
				"id": "perseguicao_normal_ciberseguranca_autenticacao_01",
				"topic": "Cibersegurança",
				"descricao": "Incidente de Cibersegurança: Confirma se o usuário ou sistema realmente é quem afirma ser. Qual ação reduz melhor o risco?",
				"opcoes": ["Aplicar Autenticação", "Ignorar Autenticação", "Improvisar sem validar"],
				"correta": "Aplicar Autenticação",
				"explanation": "Aplicar Autenticação é adequado. Conceito revisado: Autenticação verifica identidade por senha, biometria, token ou outro fator. Ela responde à pergunta: quem é você?"
			},
			{
				"id": "perseguicao_normal_ciberseguranca_autorizacao_02",
				"topic": "Cibersegurança",
				"descricao": "Incidente de Cibersegurança: Define quais recursos e ações um usuário autenticado pode acessar. Qual ação reduz melhor o risco?",
				"opcoes": ["Aplicar Autorização", "Ignorar Autorização", "Improvisar sem validar"],
				"correta": "Aplicar Autorização",
				"explanation": "Aplicar Autorização é adequado. Conceito revisado: Autorização ocorre depois da autenticação. Ela controla permissões e responde: o que este usuário pode fazer?"
			},
			{
				"id": "perseguicao_normal_desenvolvimento_web_api_rest_03",
				"topic": "Desenvolvimento Web",
				"descricao": "Incidente de Desenvolvimento Web: Usa recursos, urls e métodos http para comunicação entre sistemas. Qual ação reduz melhor o risco?",
				"opcoes": ["Revisar com API REST", "Ignorar API REST", "Improvisar sem validar"],
				"correta": "Revisar com API REST",
				"explanation": "Revisar com API REST é adequado. Conceito revisado: API REST segue princípios de Representational State Transfer. Ela costuma usar métodos HTTP como GET, POST, PUT e DELETE para manipular recursos."
			},
			{
				"id": "perseguicao_normal_desenvolvimento_web_json_04",
				"topic": "Desenvolvimento Web",
				"descricao": "Incidente de Desenvolvimento Web: Representa dados em formato textual leve, muito usado em apis. Qual ação reduz melhor o risco?",
				"opcoes": ["Revisar com JSON", "Ignorar JSON", "Improvisar sem validar"],
				"correta": "Revisar com JSON",
				"explanation": "Revisar com JSON é adequado. Conceito revisado: JSON significa JavaScript Object Notation. Ele é comum em APIs porque é simples, legível e compatível com várias linguagens."
			},
			{
				"id": "perseguicao_normal_back_end_cache_05",
				"topic": "Back-end",
				"descricao": "Incidente de Back-end: Guarda dados temporários para reduzir tempo de resposta e carga de processamento. Qual ação reduz melhor o risco?",
				"opcoes": ["Revisar com Cache", "Ignorar Cache", "Improvisar sem validar"],
				"correta": "Revisar com Cache",
				"explanation": "Revisar com Cache é adequado. Conceito revisado: Cache melhora desempenho ao reutilizar dados acessados com frequência. O cuidado é manter validade e evitar entregar informação desatualizada."
			},
			{
				"id": "perseguicao_normal_banco_de_dados_transacao_06",
				"topic": "Banco de Dados",
				"descricao": "Incidente de Banco de Dados: Agrupa operações que devem ser confirmadas ou desfeitas de forma consistente. Qual ação reduz melhor o risco?",
				"opcoes": ["Analisar com Transação", "Ignorar Transação", "Improvisar sem validar"],
				"correta": "Analisar com Transação",
				"explanation": "Analisar com Transação é adequado. Conceito revisado: Transação protege a consistência dos dados. Se tudo dá certo, ocorre commit; se algo falha, rollback desfaz as alterações."
			},
			{
				"id": "perseguicao_normal_banco_de_dados_indice_07",
				"topic": "Banco de Dados",
				"descricao": "Incidente de Banco de Dados: Acelera buscas em tabelas, mas pode aumentar custo de escrita e armazenamento. Qual ação reduz melhor o risco?",
				"opcoes": ["Analisar com Índice", "Ignorar Índice", "Improvisar sem validar"],
				"correta": "Analisar com Índice",
				"explanation": "Analisar com Índice é adequado. Conceito revisado: Índice é uma estrutura auxiliar para localizar registros mais rápido. Ele melhora consultas, mas exige equilíbrio porque impacta inserções e atualizações."
			},
			{
				"id": "perseguicao_normal_banco_de_dados_chave_estrangeira_08",
				"topic": "Banco de Dados",
				"descricao": "Incidente de Banco de Dados: Cria vínculo entre tabelas e preserva integridade referencial. Qual ação reduz melhor o risco?",
				"opcoes": ["Analisar com Chave Estrangeira", "Ignorar Chave Estrangeira", "Improvisar sem validar"],
				"correta": "Analisar com Chave Estrangeira",
				"explanation": "Analisar com Chave Estrangeira é adequado. Conceito revisado: Chave estrangeira referencia a chave primária de outra tabela. Ela ajuda a evitar relacionamentos inválidos entre registros."
			},
			{
				"id": "perseguicao_normal_modelagem_de_dados_diagrama_er_09",
				"topic": "Modelagem de Dados",
				"descricao": "Incidente de Modelagem de Dados: Representa entidades, atributos e relacionamentos de um domínio. Qual ação reduz melhor o risco?",
				"opcoes": ["Analisar com Diagrama ER", "Ignorar Diagrama ER", "Improvisar sem validar"],
				"correta": "Analisar com Diagrama ER",
				"explanation": "Analisar com Diagrama ER é adequado. Conceito revisado: Diagrama ER significa Entidade-Relacionamento. Ele apoia a modelagem conceitual de bancos de dados antes da criação das tabelas."
			},
			{
				"id": "perseguicao_normal_banco_de_dados_normalizacao_10",
				"topic": "Banco de Dados",
				"descricao": "Incidente de Banco de Dados: Organiza tabelas para reduzir redundância e anomalias de atualização. Qual ação reduz melhor o risco?",
				"opcoes": ["Analisar com Normalização", "Ignorar Normalização", "Improvisar sem validar"],
				"correta": "Analisar com Normalização",
				"explanation": "Analisar com Normalização é adequado. Conceito revisado: Normalização aplica formas normais para melhorar consistência no banco relacional. Ela reduz repetição indevida, mas pode exigir joins mais frequentes."
			},
			{
				"id": "perseguicao_normal_redes_roteamento_11",
				"topic": "Redes",
				"descricao": "Incidente de Redes: Define o caminho que pacotes percorrem entre origem e destino. Qual ação reduz melhor o risco?",
				"opcoes": ["Revisar com Roteamento", "Ignorar Roteamento", "Improvisar sem validar"],
				"correta": "Revisar com Roteamento",
				"explanation": "Revisar com Roteamento é adequado. Conceito revisado: Roteamento encaminha pacotes entre redes. Roteadores usam tabelas e protocolos para escolher o melhor caminho disponível."
			},
			{
				"id": "perseguicao_normal_redes_e_web_http_12",
				"topic": "Redes e Web",
				"descricao": "Incidente de Redes e Web: Protocolo usado para comunicação entre clientes e servidores web. Qual ação reduz melhor o risco?",
				"opcoes": ["Revisar com HTTP", "Ignorar HTTP", "Improvisar sem validar"],
				"correta": "Revisar com HTTP",
				"explanation": "Revisar com HTTP é adequado. Conceito revisado: HTTP significa HyperText Transfer Protocol. Ele define requisições e respostas na web, usando métodos como GET e POST."
			},
			{
				"id": "perseguicao_normal_redes_e_seguranca_https_13",
				"topic": "Redes e Segurança",
				"descricao": "Incidente de Redes e Segurança: Protege a comunicação web com criptografia sobre tls. Qual ação reduz melhor o risco?",
				"opcoes": ["Aplicar HTTPS", "Ignorar HTTPS", "Improvisar sem validar"],
				"correta": "Aplicar HTTPS",
				"explanation": "Aplicar HTTPS é adequado. Conceito revisado: HTTPS significa HyperText Transfer Protocol Secure. Ele usa TLS para proteger confidencialidade, integridade e autenticidade da comunicação."
			},
			{
				"id": "perseguicao_normal_redes_e_seguranca_vpn_14",
				"topic": "Redes e Segurança",
				"descricao": "Incidente de Redes e Segurança: Cria um túnel seguro para acesso remoto ou conexão entre redes. Qual ação reduz melhor o risco?",
				"opcoes": ["Aplicar VPN", "Ignorar VPN", "Improvisar sem validar"],
				"correta": "Aplicar VPN",
				"explanation": "Aplicar VPN é adequado. Conceito revisado: VPN significa Virtual Private Network, ou Rede Privada Virtual. Ela protege tráfego e permite acesso seguro a recursos internos."
			},
			{
				"id": "perseguicao_normal_ciberseguranca_hash_15",
				"topic": "Cibersegurança",
				"descricao": "Incidente de Cibersegurança: Gera um resumo de tamanho fixo a partir de dados de entrada. Qual ação reduz melhor o risco?",
				"opcoes": ["Aplicar Hash", "Ignorar Hash", "Improvisar sem validar"],
				"correta": "Aplicar Hash",
				"explanation": "Aplicar Hash é adequado. Conceito revisado: Hash é uma função que transforma dados em um resumo. É usado para integridade e armazenamento seguro de senhas quando combinado com salting e boas práticas."
			},
			{
				"id": "perseguicao_normal_ciberseguranca_criptografia_16",
				"topic": "Cibersegurança",
				"descricao": "Incidente de Cibersegurança: Transforma dados para que só possam ser compreendidos com chave adequada. Qual ação reduz melhor o risco?",
				"opcoes": ["Aplicar Criptografia", "Ignorar Criptografia", "Improvisar sem validar"],
				"correta": "Aplicar Criptografia",
				"explanation": "Aplicar Criptografia é adequado. Conceito revisado: Criptografia protege confidencialidade e, em alguns usos, integridade e autenticidade. Ela é base de HTTPS, armazenamento seguro e comunicação protegida."
			},
			{
				"id": "perseguicao_normal_ciberseguranca_sql_injection_17",
				"topic": "Cibersegurança",
				"descricao": "Incidente de Cibersegurança: Ocorre quando entrada maliciosa manipula comandos sql de uma aplicação. Qual ação reduz melhor o risco?",
				"opcoes": ["Aplicar SQL Injection", "Ignorar SQL Injection", "Improvisar sem validar"],
				"correta": "Aplicar SQL Injection",
				"explanation": "Aplicar SQL Injection é adequado. Conceito revisado: SQL Injection é uma vulnerabilidade de injeção em banco de dados. Validação, consultas parametrizadas e menor privilégio reduzem esse risco."
			},
			{
				"id": "perseguicao_normal_ciberseguranca_xss_18",
				"topic": "Cibersegurança",
				"descricao": "Incidente de Cibersegurança: Injeta scripts maliciosos em páginas vistas por usuários. Qual ação reduz melhor o risco?",
				"opcoes": ["Aplicar XSS", "Ignorar XSS", "Improvisar sem validar"],
				"correta": "Aplicar XSS",
				"explanation": "Aplicar XSS é adequado. Conceito revisado: XSS significa Cross-Site Scripting. Ele ocorre quando uma aplicação exibe conteúdo não tratado, permitindo execução de scripts no navegador da vítima."
			},
			{
				"id": "perseguicao_normal_ux_ihc_persona_19",
				"topic": "UX/IHC",
				"descricao": "Incidente de UX/IHC: Representa um perfil fictício baseado em características de usuários reais. Qual ação reduz melhor o risco?",
				"opcoes": ["Validar com Persona", "Ignorar Persona", "Improvisar sem validar"],
				"correta": "Validar com Persona",
				"explanation": "Validar com Persona é adequado. Conceito revisado: Persona ajuda equipes a projetarem pensando em necessidades, dores, objetivos e contexto de uso de grupos de usuários."
			},
			{
				"id": "perseguicao_normal_ux_ihc_heuristicas_de_nielsen_20",
				"topic": "UX/IHC",
				"descricao": "Incidente de UX/IHC: São princípios usados para avaliar problemas de usabilidade em interfaces. Qual ação reduz melhor o risco?",
				"opcoes": ["Validar com Heurísticas de Nielsen", "Ignorar Heurísticas de Nielsen", "Improvisar sem validar"],
				"correta": "Validar com Heurísticas de Nielsen",
				"explanation": "Validar com Heurísticas de Nielsen é adequado. Conceito revisado: As heurísticas de Nielsen orientam avaliação de interfaces, incluindo feedback, consistência, prevenção de erros e liberdade do usuário."
			},
			{
				"id": "perseguicao_normal_front_end_design_responsivo_21",
				"topic": "Front-end",
				"descricao": "Incidente de Front-end: Adapta a interface a diferentes tamanhos de tela e dispositivos. Qual ação reduz melhor o risco?",
				"opcoes": ["Revisar com Design Responsivo", "Ignorar Design Responsivo", "Improvisar sem validar"],
				"correta": "Revisar com Design Responsivo",
				"explanation": "Revisar com Design Responsivo é adequado. Conceito revisado: Design responsivo usa layouts flexíveis, media queries e boas práticas de interface para manter usabilidade em celular, tablet e desktop."
			},
			{
				"id": "perseguicao_normal_devops_devops_22",
				"topic": "DevOps",
				"descricao": "Incidente de DevOps: Integra desenvolvimento e operações para entregar software com mais qualidade e frequência. Qual ação reduz melhor o risco?",
				"opcoes": ["Automatizar com DevOps", "Ignorar DevOps", "Improvisar sem validar"],
				"correta": "Automatizar com DevOps",
				"explanation": "Automatizar com DevOps é adequado. Conceito revisado: DevOps combina cultura, automação e colaboração. Ele reduz atritos entre desenvolvimento, testes, infraestrutura e implantação."
			},
			{
				"id": "perseguicao_normal_devops_pipeline_23",
				"topic": "DevOps",
				"descricao": "Incidente de DevOps: Automatiza etapas como build, testes, análise e deploy. Qual ação reduz melhor o risco?",
				"opcoes": ["Automatizar com Pipeline", "Ignorar Pipeline", "Improvisar sem validar"],
				"correta": "Automatizar com Pipeline",
				"explanation": "Automatizar com Pipeline é adequado. Conceito revisado: Pipeline organiza o fluxo de entrega de software. Em CI/CD, ele reduz tarefas manuais e torna publicações mais repetíveis."
			},
			{
				"id": "perseguicao_normal_devops_container_24",
				"topic": "DevOps",
				"descricao": "Incidente de DevOps: Empacota aplicação e dependências em ambiente isolado e reproduzível. Qual ação reduz melhor o risco?",
				"opcoes": ["Automatizar com Container", "Ignorar Container", "Improvisar sem validar"],
				"correta": "Automatizar com Container",
				"explanation": "Automatizar com Container é adequado. Conceito revisado: Container ajuda a executar software de forma consistente entre desenvolvimento, teste e produção. Docker é uma ferramenta comum nesse contexto."
			},
			{
				"id": "perseguicao_normal_devops_ci_cd_25",
				"topic": "DevOps",
				"descricao": "Incidente de DevOps: Automatiza integração, testes e entrega de software. Qual ação reduz melhor o risco?",
				"opcoes": ["Automatizar com CI/CD", "Ignorar CI/CD", "Improvisar sem validar"],
				"correta": "Automatizar com CI/CD",
				"explanation": "Automatizar com CI/CD é adequado. Conceito revisado: CI/CD significa Continuous Integration e Continuous Delivery/Deployment, ou Integração Contínua e Entrega/Implantação Contínua. Ele reduz erros manuais e acelera entregas."
			},
			{
				"id": "perseguicao_normal_dados_e_bi_etl_26",
				"topic": "Dados e BI",
				"descricao": "Incidente de Dados e BI: Extrai, transforma e carrega dados para outro ambiente de armazenamento ou análise. Qual ação reduz melhor o risco?",
				"opcoes": ["Analisar com ETL", "Ignorar ETL", "Improvisar sem validar"],
				"correta": "Analisar com ETL",
				"explanation": "Analisar com ETL é adequado. Conceito revisado: ETL significa Extract, Transform and Load, ou Extração, Transformação e Carga. Ele coleta dados, aplica tratamentos e carrega o resultado em bases analíticas, como Data Warehouse."
			},
			{
				"id": "perseguicao_normal_business_intelligence_kpi_27",
				"topic": "Business Intelligence",
				"descricao": "Incidente de Business Intelligence: Mede desempenho de processos, metas ou resultados importantes para o negócio. Qual ação reduz melhor o risco?",
				"opcoes": ["Analisar com KPI", "Ignorar KPI", "Improvisar sem validar"],
				"correta": "Analisar com KPI",
				"explanation": "Analisar com KPI é adequado. Conceito revisado: KPI significa Key Performance Indicator, ou Indicador-Chave de Desempenho. Ele ajuda a acompanhar objetivos com métricas relevantes e acionáveis."
			},
			{
				"id": "perseguicao_normal_ciencia_de_dados_mineracao_de_dados_28",
				"topic": "Ciência de Dados",
				"descricao": "Incidente de Ciência de Dados: Busca padrões, relações e conhecimento útil em grandes conjuntos de dados. Qual ação reduz melhor o risco?",
				"opcoes": ["Analisar com Mineração de Dados", "Ignorar Mineração de Dados", "Improvisar sem validar"],
				"correta": "Analisar com Mineração de Dados",
				"explanation": "Analisar com Mineração de Dados é adequado. Conceito revisado: Mineração de dados aplica técnicas para descobrir padrões, agrupamentos, associações ou classificações. Ela pode fazer parte do processo KDD."
			},
			{
				"id": "perseguicao_normal_pandas_e_analise_de_dados_groupby_29",
				"topic": "Pandas e Análise de Dados",
				"descricao": "Incidente de Pandas e Análise de Dados: Agrupa registros no pandas para calcular somas, médias, contagens ou outras agregações. Qual ação reduz melhor o risco?",
				"opcoes": ["Analisar com GroupBy", "Ignorar GroupBy", "Improvisar sem validar"],
				"correta": "Analisar com GroupBy",
				"explanation": "Analisar com GroupBy é adequado. Conceito revisado: GroupBy é uma operação do Pandas inspirada no padrão split-apply-combine. Ela separa dados por grupos, aplica cálculos e combina os resultados."
			},
			{
				"id": "perseguicao_normal_qualidade_de_dados_padronizacao_de_dados_30",
				"topic": "Qualidade de Dados",
				"descricao": "Incidente de Qualidade de Dados: Coloca valores em formatos consistentes antes da análise. Qual ação reduz melhor o risco?",
				"opcoes": ["Analisar com Padronização de Dados", "Ignorar Padronização de Dados", "Improvisar sem validar"],
				"correta": "Analisar com Padronização de Dados",
				"explanation": "Analisar com Padronização de Dados é adequado. Conceito revisado: Padronização de dados evita categorias duplicadas e comparações incorretas. Exemplos comuns envolvem datas, nomes, siglas, letras maiúsculas e unidades de medida."
			}
		],
		"dificil": [
			{
				"id": "perseguicao_dificil_business_intelligence_data_warehouse_01",
				"topic": "Business Intelligence",
				"descricao": "Incidente de Business Intelligence: Integra dados históricos, orientados por assunto, para apoiar decisões gerenciais. Qual ação reduz melhor o risco?",
				"opcoes": ["Analisar com Data Warehouse", "Ignorar Data Warehouse", "Improvisar sem validar"],
				"correta": "Analisar com Data Warehouse",
				"explanation": "Analisar com Data Warehouse é adequado. Conceito revisado: Data Warehouse é um repositório analítico integrado, histórico e não volátil. Ele consolida dados de várias fontes para consultas, indicadores e análises estratégicas."
			},
			{
				"id": "perseguicao_dificil_business_intelligence_data_mart_02",
				"topic": "Business Intelligence",
				"descricao": "Incidente de Business Intelligence: Representa um subconjunto analítico voltado a uma área ou departamento específico. Qual ação reduz melhor o risco?",
				"opcoes": ["Analisar com Data Mart", "Ignorar Data Mart", "Improvisar sem validar"],
				"correta": "Analisar com Data Mart",
				"explanation": "Analisar com Data Mart é adequado. Conceito revisado: Data Mart é uma parte menor de um Data Warehouse. Ele atende necessidades de uma área, como vendas, financeiro ou recursos humanos."
			},
			{
				"id": "perseguicao_dificil_business_intelligence_olap_03",
				"topic": "Business Intelligence",
				"descricao": "Incidente de Business Intelligence: Apoia análise multidimensional de dados históricos e agregados. Qual ação reduz melhor o risco?",
				"opcoes": ["Analisar com OLAP", "Ignorar OLAP", "Improvisar sem validar"],
				"correta": "Analisar com OLAP",
				"explanation": "Analisar com OLAP é adequado. Conceito revisado: OLAP significa Online Analytical Processing. Ele é voltado a consultas analíticas, comparações, agregações e exploração de dados para decisão."
			},
			{
				"id": "perseguicao_dificil_banco_de_dados_oltp_04",
				"topic": "Banco de Dados",
				"descricao": "Incidente de Banco de Dados: Processa transações operacionais frequentes do dia a dia. Qual ação reduz melhor o risco?",
				"opcoes": ["Analisar com OLTP", "Ignorar OLTP", "Improvisar sem validar"],
				"correta": "Analisar com OLTP",
				"explanation": "Analisar com OLTP é adequado. Conceito revisado: OLTP significa Online Transaction Processing. Ele prioriza consistência, rapidez em transações e operações como cadastro, compra, pagamento e atualização."
			},
			{
				"id": "perseguicao_dificil_data_warehouse_star_schema_05",
				"topic": "Data Warehouse",
				"descricao": "Incidente de Data Warehouse: Modela dados analíticos com uma tabela fato central ligada a tabelas dimensão. Qual ação reduz melhor o risco?",
				"opcoes": ["Revisar com Star Schema", "Ignorar Star Schema", "Improvisar sem validar"],
				"correta": "Revisar com Star Schema",
				"explanation": "Revisar com Star Schema é adequado. Conceito revisado: Star Schema, ou esquema estrela, facilita consultas analíticas. A tabela fato guarda métricas, enquanto dimensões descrevem contexto como tempo, produto e local."
			},
			{
				"id": "perseguicao_dificil_data_warehouse_granularidade_06",
				"topic": "Data Warehouse",
				"descricao": "Incidente de Data Warehouse: Define o nível de detalhe armazenado nos dados de uma tabela fato. Qual ação reduz melhor o risco?",
				"opcoes": ["Revisar com Granularidade", "Ignorar Granularidade", "Improvisar sem validar"],
				"correta": "Revisar com Granularidade",
				"explanation": "Revisar com Granularidade é adequado. Conceito revisado: Granularidade indica quão detalhado é um dado. Em Data Warehouse, granularidade baixa guarda mais detalhes; granularidade alta guarda dados mais resumidos."
			},
			{
				"id": "perseguicao_dificil_governanca_de_dados_metadados_07",
				"topic": "Governança de Dados",
				"descricao": "Incidente de Governança de Dados: Descrevem origem, significado, estrutura e regras dos dados. Qual ação reduz melhor o risco?",
				"opcoes": ["Analisar com Metadados", "Ignorar Metadados", "Improvisar sem validar"],
				"correta": "Analisar com Metadados",
				"explanation": "Analisar com Metadados é adequado. Conceito revisado: Metadados são dados sobre dados. Eles ajudam a entender campos, fontes, qualidade, periodicidade, responsáveis e regras de uso."
			},
			{
				"id": "perseguicao_dificil_mineracao_de_dados_kdd_08",
				"topic": "Mineração de Dados",
				"descricao": "Incidente de Mineração de Dados: Organiza o processo de descoberta de conhecimento em bases de dados. Qual ação reduz melhor o risco?",
				"opcoes": ["Analisar com KDD", "Ignorar KDD", "Improvisar sem validar"],
				"correta": "Analisar com KDD",
				"explanation": "Analisar com KDD é adequado. Conceito revisado: KDD significa Knowledge Discovery in Databases, ou Descoberta de Conhecimento em Bases de Dados. Inclui seleção, limpeza, transformação, mineração e interpretação."
			},
			{
				"id": "perseguicao_dificil_ciencia_de_dados_outlier_09",
				"topic": "Ciência de Dados",
				"descricao": "Incidente de Ciência de Dados: Representa um valor muito distante do comportamento esperado dos dados. Qual ação reduz melhor o risco?",
				"opcoes": ["Analisar com Outlier", "Ignorar Outlier", "Improvisar sem validar"],
				"correta": "Analisar com Outlier",
				"explanation": "Analisar com Outlier é adequado. Conceito revisado: Outlier pode indicar erro, evento raro ou comportamento relevante. Antes de remover, o analista precisa entender o contexto e o impacto na análise."
			},
			{
				"id": "perseguicao_dificil_estatistica_e_dados_correlacao_10",
				"topic": "Estatística e Dados",
				"descricao": "Incidente de Estatística e Dados: Mede associação entre variáveis, mas não prova relação de causa e efeito. Qual ação reduz melhor o risco?",
				"opcoes": ["Analisar com Correlação", "Ignorar Correlação", "Improvisar sem validar"],
				"correta": "Analisar com Correlação",
				"explanation": "Analisar com Correlação é adequado. Conceito revisado: Correlação indica se variáveis tendem a variar juntas. Em análise de dados, é importante lembrar que correlação não implica causalidade."
			},
			{
				"id": "perseguicao_dificil_estatistica_e_dados_amostragem_11",
				"topic": "Estatística e Dados",
				"descricao": "Incidente de Estatística e Dados: Seleciona parte dos dados para representar uma população maior. Qual ação reduz melhor o risco?",
				"opcoes": ["Analisar com Amostragem", "Ignorar Amostragem", "Improvisar sem validar"],
				"correta": "Analisar com Amostragem",
				"explanation": "Analisar com Amostragem é adequado. Conceito revisado: Amostragem reduz custo de coleta e análise, mas precisa ser planejada para evitar vieses e manter representatividade."
			},
			{
				"id": "perseguicao_dificil_ciencia_de_dados_feature_engineering_12",
				"topic": "Ciência de Dados",
				"descricao": "Incidente de Ciência de Dados: Cria ou transforma variáveis para melhorar análises e modelos preditivos. Qual ação reduz melhor o risco?",
				"opcoes": ["Analisar com Feature Engineering", "Ignorar Feature Engineering", "Improvisar sem validar"],
				"correta": "Analisar com Feature Engineering",
				"explanation": "Analisar com Feature Engineering é adequado. Conceito revisado: Feature Engineering envolve preparar atributos, criar indicadores, transformar escalas e extrair sinais úteis. A qualidade das variáveis influencia fortemente modelos de dados."
			},
			{
				"id": "perseguicao_dificil_engenharia_de_software_acoplamento_13",
				"topic": "Engenharia de Software",
				"descricao": "Incidente de Engenharia de Software: Mede o grau de dependência entre módulos, classes ou componentes. Qual ação reduz melhor o risco?",
				"opcoes": ["Revisar com Acoplamento", "Ignorar Acoplamento", "Improvisar sem validar"],
				"correta": "Revisar com Acoplamento",
				"explanation": "Revisar com Acoplamento é adequado. Conceito revisado: Baixo acoplamento facilita manutenção, testes e evolução porque reduz dependências entre partes do sistema."
			},
			{
				"id": "perseguicao_dificil_engenharia_de_software_coesao_14",
				"topic": "Engenharia de Software",
				"descricao": "Incidente de Engenharia de Software: Mede o quanto responsabilidades internas de um módulo estão relacionadas entre si. Qual ação reduz melhor o risco?",
				"opcoes": ["Revisar com Coesão", "Ignorar Coesão", "Improvisar sem validar"],
				"correta": "Revisar com Coesão",
				"explanation": "Revisar com Coesão é adequado. Conceito revisado: Alta coesão é desejável porque mantém componentes focados em uma responsabilidade clara, melhorando entendimento e manutenção."
			},
			{
				"id": "perseguicao_dificil_engenharia_de_software_divida_tecnica_15",
				"topic": "Engenharia de Software",
				"descricao": "Incidente de Engenharia de Software: Representa custo futuro gerado por soluções rápidas, frágeis ou mal planejadas. Qual ação reduz melhor o risco?",
				"opcoes": ["Revisar com Dívida Técnica", "Ignorar Dívida Técnica", "Improvisar sem validar"],
				"correta": "Revisar com Dívida Técnica",
				"explanation": "Revisar com Dívida Técnica é adequado. Conceito revisado: Dívida técnica surge quando a equipe escolhe atalhos. Se não for controlada, aumenta retrabalho, dificulta manutenção e reduz velocidade de evolução."
			},
			{
				"id": "perseguicao_dificil_arquitetura_de_software_mvc_16",
				"topic": "Arquitetura de Software",
				"descricao": "Incidente de Arquitetura de Software: Separa responsabilidades entre modelo, visão e controlador. Qual ação reduz melhor o risco?",
				"opcoes": ["Revisar com MVC", "Ignorar MVC", "Improvisar sem validar"],
				"correta": "Revisar com MVC",
				"explanation": "Revisar com MVC é adequado. Conceito revisado: MVC significa Model-View-Controller. Ele organiza dados, interface e fluxo de controle em camadas para reduzir mistura de responsabilidades."
			},
			{
				"id": "perseguicao_dificil_arquitetura_de_software_solid_17",
				"topic": "Arquitetura de Software",
				"descricao": "Incidente de Arquitetura de Software: Reúne princípios de design orientado a objetos para reduzir rigidez e facilitar manutenção. Qual ação reduz melhor o risco?",
				"opcoes": ["Revisar com SOLID", "Ignorar SOLID", "Improvisar sem validar"],
				"correta": "Revisar com SOLID",
				"explanation": "Revisar com SOLID é adequado. Conceito revisado: SOLID é um conjunto de cinco princípios de projeto de software. Eles orientam responsabilidades claras, baixo acoplamento, extensibilidade e substituição segura."
			},
			{
				"id": "perseguicao_dificil_poo_polimorfismo_18",
				"topic": "POO",
				"descricao": "Incidente de POO: Permite que diferentes objetos respondam de formas específicas à mesma operação. Qual ação reduz melhor o risco?",
				"opcoes": ["Revisar com Polimorfismo", "Ignorar Polimorfismo", "Improvisar sem validar"],
				"correta": "Revisar com Polimorfismo",
				"explanation": "Revisar com Polimorfismo é adequado. Conceito revisado: Polimorfismo é um princípio da Programação Orientada a Objetos. Ele permite tratar objetos por uma interface comum, mantendo comportamentos especializados."
			},
			{
				"id": "perseguicao_dificil_gestao_de_projetos_scrum_19",
				"topic": "Gestão de Projetos",
				"descricao": "Incidente de Gestão de Projetos: Organiza trabalho ágil em eventos, papéis e artefatos para entrega incremental. Qual ação reduz melhor o risco?",
				"opcoes": ["Revisar com Scrum", "Ignorar Scrum", "Improvisar sem validar"],
				"correta": "Revisar com Scrum",
				"explanation": "Revisar com Scrum é adequado. Conceito revisado: Scrum é um framework ágil com papéis como Product Owner, Scrum Master e Developers. Ele usa Sprints, Backlog e revisões para adaptação contínua."
			},
			{
				"id": "perseguicao_dificil_governanca_de_ti_cobit_20",
				"topic": "Governança de TI",
				"descricao": "Incidente de Governança de TI: Orienta governança e gestão de ti alinhadas aos objetivos do negócio. Qual ação reduz melhor o risco?",
				"opcoes": ["Revisar com COBIT", "Ignorar COBIT", "Improvisar sem validar"],
				"correta": "Revisar com COBIT",
				"explanation": "Revisar com COBIT é adequado. Conceito revisado: COBIT significa Control Objectives for Information and Related Technologies. Ele apoia governança, controle, valor, riscos e alinhamento estratégico de TI."
			},
			{
				"id": "perseguicao_dificil_governanca_de_ti_itil_21",
				"topic": "Governança de TI",
				"descricao": "Incidente de Governança de TI: Organiza boas práticas para gestão de serviços de ti. Qual ação reduz melhor o risco?",
				"opcoes": ["Revisar com ITIL", "Ignorar ITIL", "Improvisar sem validar"],
				"correta": "Revisar com ITIL",
				"explanation": "Revisar com ITIL é adequado. Conceito revisado: ITIL significa Information Technology Infrastructure Library. Ela trata serviços, incidentes, mudanças, problemas, níveis de serviço e melhoria contínua."
			},
			{
				"id": "perseguicao_dificil_governanca_de_ti_sla_22",
				"topic": "Governança de TI",
				"descricao": "Incidente de Governança de TI: Formaliza níveis de serviço esperados entre provedor e cliente. Qual ação reduz melhor o risco?",
				"opcoes": ["Revisar com SLA", "Ignorar SLA", "Improvisar sem validar"],
				"correta": "Revisar com SLA",
				"explanation": "Revisar com SLA é adequado. Conceito revisado: SLA significa Service Level Agreement, ou Acordo de Nível de Serviço. Ele define metas como disponibilidade, tempo de resposta e prazo de atendimento."
			},
			{
				"id": "perseguicao_dificil_continuidade_de_negocio_rto_e_rpo_23",
				"topic": "Continuidade de Negócio",
				"descricao": "Incidente de Continuidade de Negócio: Definem tempo máximo de recuperação e perda máxima aceitável de dados. Qual ação reduz melhor o risco?",
				"opcoes": ["Aplicar RTO e RPO", "Ignorar RTO e RPO", "Improvisar sem validar"],
				"correta": "Aplicar RTO e RPO",
				"explanation": "Aplicar RTO e RPO é adequado. Conceito revisado: RTO significa Recovery Time Objective, ou tempo máximo para restaurar o serviço. RPO significa Recovery Point Objective, ou ponto máximo aceitável de perda de dados."
			},
			{
				"id": "perseguicao_dificil_ciberseguranca_zero_trust_24",
				"topic": "Cibersegurança",
				"descricao": "Incidente de Cibersegurança: Assume que nenhuma conexão deve ser confiável automaticamente. Qual ação reduz melhor o risco?",
				"opcoes": ["Aplicar Zero Trust", "Ignorar Zero Trust", "Improvisar sem validar"],
				"correta": "Aplicar Zero Trust",
				"explanation": "Aplicar Zero Trust é adequado. Conceito revisado: Zero Trust, ou confiança zero, exige verificação contínua de identidade, contexto e permissões. A ideia central é nunca confiar por padrão."
			},
			{
				"id": "perseguicao_dificil_ciberseguranca_menor_privilegio_25",
				"topic": "Cibersegurança",
				"descricao": "Incidente de Cibersegurança: Concede apenas as permissões necessárias para executar uma atividade. Qual ação reduz melhor o risco?",
				"opcoes": ["Aplicar Menor Privilégio", "Ignorar Menor Privilégio", "Improvisar sem validar"],
				"correta": "Aplicar Menor Privilégio",
				"explanation": "Aplicar Menor Privilégio é adequado. Conceito revisado: O princípio do menor privilégio reduz danos em caso de falha ou invasão. Usuários e sistemas não devem ter acessos além do necessário."
			},
			{
				"id": "perseguicao_dificil_ciberseguranca_oauth_2_0_26",
				"topic": "Cibersegurança",
				"descricao": "Incidente de Cibersegurança: Permite autorização delegada sem compartilhar senha com aplicações terceiras. Qual ação reduz melhor o risco?",
				"opcoes": ["Aplicar OAuth 2.0", "Ignorar OAuth 2.0", "Improvisar sem validar"],
				"correta": "Aplicar OAuth 2.0",
				"explanation": "Aplicar OAuth 2.0 é adequado. Conceito revisado: OAuth 2.0 é um protocolo de autorização. Ele permite que uma aplicação acesse recursos em nome do usuário por meio de tokens controlados."
			},
			{
				"id": "perseguicao_dificil_ciberseguranca_jwt_27",
				"topic": "Cibersegurança",
				"descricao": "Incidente de Cibersegurança: Transporta declarações verificáveis entre sistemas em formato compacto. Qual ação reduz melhor o risco?",
				"opcoes": ["Aplicar JWT", "Ignorar JWT", "Improvisar sem validar"],
				"correta": "Aplicar JWT",
				"explanation": "Aplicar JWT é adequado. Conceito revisado: JWT significa JSON Web Token. Ele é usado para representar claims, como identidade e permissões, mas precisa de expiração, assinatura e armazenamento seguro."
			},
			{
				"id": "perseguicao_dificil_devops_observabilidade_28",
				"topic": "DevOps",
				"descricao": "Incidente de DevOps: Permite entender o estado interno do sistema a partir de logs, métricas e traces. Qual ação reduz melhor o risco?",
				"opcoes": ["Automatizar com Observabilidade", "Ignorar Observabilidade", "Improvisar sem validar"],
				"correta": "Automatizar com Observabilidade",
				"explanation": "Automatizar com Observabilidade é adequado. Conceito revisado: Observabilidade combina sinais como logs, métricas e rastreamento distribuído. Ela ajuda a investigar falhas, gargalos e comportamento em produção."
			},
			{
				"id": "perseguicao_dificil_devops_e_cloud_iac_29",
				"topic": "DevOps e Cloud",
				"descricao": "Incidente de DevOps e Cloud: Gerencia infraestrutura por arquivos versionáveis em vez de configuração manual. Qual ação reduz melhor o risco?",
				"opcoes": ["Automatizar com IaC", "Ignorar IaC", "Improvisar sem validar"],
				"correta": "Automatizar com IaC",
				"explanation": "Automatizar com IaC é adequado. Conceito revisado: IaC significa Infrastructure as Code, ou Infraestrutura como Código. Ela torna ambientes reproduzíveis, auditáveis e menos dependentes de configuração manual."
			},
			{
				"id": "perseguicao_dificil_lgpd_e_etica_privacidade_por_design_30",
				"topic": "LGPD e Ética",
				"descricao": "Incidente de LGPD e Ética: Inclui proteção de dados desde a concepção do sistema, não apenas no fim do projeto. Qual ação reduz melhor o risco?",
				"opcoes": ["Aplicar Privacidade por Design", "Ignorar Privacidade por Design", "Improvisar sem validar"],
				"correta": "Aplicar Privacidade por Design",
				"explanation": "Aplicar Privacidade por Design é adequado. Conceito revisado: Privacidade por design coloca proteção de dados no planejamento, arquitetura e operação. Ela se relaciona com minimização, finalidade, segurança e transparência."
			}
		]
	},
	"batalha_naval": {
		"facil": [
			{
				"id": "naval_facil_desenvolvimento_web_html_01",
				"topic": "Desenvolvimento Web",
				"ameaca": "Lacuna em HTML",
				"controle": "Revisar HTML",
				"explanation": "Revisar HTML reduz o risco. Conceito revisado: HTML significa HyperText Markup Language, ou Linguagem de Marcação de Hipertexto. Ele define a estrutura semântica de uma página web, como títulos, textos, listas, links e formulários."
			},
			{
				"id": "naval_facil_front_end_css_02",
				"topic": "Front-end",
				"ameaca": "Lacuna em CSS",
				"controle": "Revisar CSS",
				"explanation": "Revisar CSS reduz o risco. Conceito revisado: CSS significa Cascading Style Sheets, ou Folhas de Estilo em Cascata. Ele separa a apresentação visual da estrutura HTML e permite criar interfaces responsivas e organizadas."
			},
			{
				"id": "naval_facil_programacao_web_javascript_03",
				"topic": "Programação Web",
				"ameaca": "Lacuna em JavaScript",
				"controle": "Revisar JavaScript",
				"explanation": "Revisar JavaScript reduz o risco. Conceito revisado: JavaScript é uma linguagem de programação muito usada no navegador e também no back-end. Ela permite validar formulários, manipular o DOM, consumir APIs e criar interações dinâmicas."
			},
			{
				"id": "naval_facil_back_end_api_04",
				"topic": "Back-end",
				"ameaca": "Lacuna em API",
				"controle": "Revisar API",
				"explanation": "Revisar API reduz o risco. Conceito revisado: API significa Application Programming Interface, ou Interface de Programação de Aplicações. Ela expõe funcionalidades para que sistemas, aplicativos ou serviços troquem dados de forma padronizada."
			},
			{
				"id": "naval_facil_banco_de_dados_banco_de_dados_05",
				"topic": "Banco de Dados",
				"ameaca": "Lacuna em Banco de Dados",
				"controle": "Revisar Banco de Dados",
				"explanation": "Revisar Banco de Dados reduz o risco. Conceito revisado: Banco de dados é uma estrutura usada para armazenar informações de forma persistente. Em sistemas de informação, ele sustenta cadastros, transações, consultas e relatórios."
			},
			{
				"id": "naval_facil_sql_select_06",
				"topic": "SQL",
				"ameaca": "Lacuna em SELECT",
				"controle": "Revisar SELECT",
				"explanation": "Revisar SELECT reduz o risco. Conceito revisado: SELECT é um comando da linguagem SQL usado para consultar dados. Ele pode ser combinado com WHERE, JOIN, GROUP BY e ORDER BY para filtrar, relacionar e ordenar resultados."
			},
			{
				"id": "naval_facil_estruturas_de_dados_pilha_07",
				"topic": "Estruturas de Dados",
				"ameaca": "Lacuna em Pilha",
				"controle": "Revisar Pilha",
				"explanation": "Revisar Pilha reduz o risco. Conceito revisado: Pilha é uma estrutura de dados baseada em LIFO, Last In, First Out. Ela aparece em chamadas de funções, desfazer ações e controle de execução."
			},
			{
				"id": "naval_facil_estruturas_de_dados_fila_08",
				"topic": "Estruturas de Dados",
				"ameaca": "Lacuna em Fila",
				"controle": "Revisar Fila",
				"explanation": "Revisar Fila reduz o risco. Conceito revisado: Fila é uma estrutura de dados baseada em FIFO, First In, First Out. Ela é útil em atendimento, processamento de tarefas e filas de mensagens."
			},
			{
				"id": "naval_facil_seguranca_da_informacao_backup_09",
				"topic": "Segurança da Informação",
				"ameaca": "Lacuna em Backup",
				"controle": "Revisar Backup",
				"explanation": "Revisar Backup reduz o risco. Conceito revisado: Backup é uma cópia de segurança dos dados. Ele reduz perdas em falhas, ataques, erros humanos e desastres, mas precisa ser testado para garantir restauração."
			},
			{
				"id": "naval_facil_ciberseguranca_mfa_10",
				"topic": "Cibersegurança",
				"ameaca": "Lacuna em MFA",
				"controle": "Revisar MFA",
				"explanation": "Revisar MFA reduz o risco. Conceito revisado: MFA significa Multi-Factor Authentication, ou Autenticação Multifator. Ele combina fatores como senha, aplicativo, biometria ou token para reduzir o risco de acesso indevido."
			},
			{
				"id": "naval_facil_ux_ihc_ux_11",
				"topic": "UX/IHC",
				"ameaca": "Lacuna em UX",
				"controle": "Revisar UX",
				"explanation": "Revisar UX reduz o risco. Conceito revisado: UX significa User Experience, ou Experiência do Usuário. Ela envolve utilidade, facilidade de uso, eficiência, emoção, contexto e satisfação durante a interação."
			},
			{
				"id": "naval_facil_ihc_acessibilidade_12",
				"topic": "IHC",
				"ameaca": "Lacuna em Acessibilidade",
				"controle": "Revisar Acessibilidade",
				"explanation": "Revisar Acessibilidade reduz o risco. Conceito revisado: Acessibilidade busca tornar produtos digitais utilizáveis por mais pessoas. Ela envolve contraste, navegação por teclado, texto alternativo, leitores de tela e linguagem clara."
			},
			{
				"id": "naval_facil_fundamentos_de_computacao_algoritmo_13",
				"topic": "Fundamentos de Computação",
				"ameaca": "Lacuna em Algoritmo",
				"controle": "Revisar Algoritmo",
				"explanation": "Revisar Algoritmo reduz o risco. Conceito revisado: Algoritmo é um conjunto de instruções lógicas para chegar a uma solução. Ele pode ser representado em linguagem natural, fluxograma, pseudocódigo ou código."
			},
			{
				"id": "naval_facil_programacao_variavel_14",
				"topic": "Programação",
				"ameaca": "Lacuna em Variável",
				"controle": "Revisar Variável",
				"explanation": "Revisar Variável reduz o risco. Conceito revisado: Variável é um nome associado a um valor em memória. Ela permite guardar dados como números, textos, estados e resultados intermediários."
			},
			{
				"id": "naval_facil_programacao_funcao_15",
				"topic": "Programação",
				"ameaca": "Lacuna em Função",
				"controle": "Revisar Função",
				"explanation": "Revisar Função reduz o risco. Conceito revisado: Função organiza o código em blocos menores e reutilizáveis. Ela melhora leitura, manutenção, testes e evita repetição desnecessária."
			},
			{
				"id": "naval_facil_devops_git_16",
				"topic": "DevOps",
				"ameaca": "Lacuna em Git",
				"controle": "Revisar Git",
				"explanation": "Revisar Git reduz o risco. Conceito revisado: Git é um sistema de controle de versão distribuído. Ele permite criar branches, revisar mudanças, voltar versões e colaborar com mais segurança."
			},
			{
				"id": "naval_facil_arquitetura_web_cliente_17",
				"topic": "Arquitetura Web",
				"ameaca": "Lacuna em Cliente",
				"controle": "Revisar Cliente",
				"explanation": "Revisar Cliente reduz o risco. Conceito revisado: Cliente é o componente que consome um serviço, como navegador, aplicativo mobile ou sistema externo. Ele envia requisições para um servidor."
			},
			{
				"id": "naval_facil_arquitetura_web_servidor_18",
				"topic": "Arquitetura Web",
				"ameaca": "Lacuna em Servidor",
				"controle": "Revisar Servidor",
				"explanation": "Revisar Servidor reduz o risco. Conceito revisado: Servidor é o componente que recebe requisições, executa regras de negócio, consulta dados e envia respostas para clientes ou outros sistemas."
			},
			{
				"id": "naval_facil_redes_rede_19",
				"topic": "Redes",
				"ameaca": "Lacuna em Rede",
				"controle": "Revisar Rede",
				"explanation": "Revisar Rede reduz o risco. Conceito revisado: Rede de computadores conecta dispositivos para troca de dados. Ela pode usar protocolos, endereços, roteadores, switches e serviços como DNS e HTTP."
			},
			{
				"id": "naval_facil_redes_dns_20",
				"topic": "Redes",
				"ameaca": "Lacuna em DNS",
				"controle": "Revisar DNS",
				"explanation": "Revisar DNS reduz o risco. Conceito revisado: DNS significa Domain Name System, ou Sistema de Nomes de Domínio. Ele permite acessar sites por nomes como exemplo.com em vez de memorizar endereços IP."
			},
			{
				"id": "naval_facil_ciberseguranca_firewall_21",
				"topic": "Cibersegurança",
				"ameaca": "Lacuna em Firewall",
				"controle": "Revisar Firewall",
				"explanation": "Revisar Firewall reduz o risco. Conceito revisado: Firewall é um mecanismo de segurança que filtra comunicações. Ele pode bloquear conexões suspeitas, limitar portas e reduzir exposição de serviços."
			},
			{
				"id": "naval_facil_engenharia_de_software_requisito_22",
				"topic": "Engenharia de Software",
				"ameaca": "Lacuna em Requisito",
				"controle": "Revisar Requisito",
				"explanation": "Revisar Requisito reduz o risco. Conceito revisado: Requisito registra o que o sistema precisa fazer ou respeitar. Pode ser funcional, quando descreve uma função, ou não funcional, quando descreve qualidade ou restrição."
			},
			{
				"id": "naval_facil_qualidade_de_software_teste_23",
				"topic": "Qualidade de Software",
				"ameaca": "Lacuna em Teste",
				"controle": "Revisar Teste",
				"explanation": "Revisar Teste reduz o risco. Conceito revisado: Teste de software reduz riscos ao verificar comportamentos esperados. Ele pode ser manual, automatizado, unitário, funcional, regressivo ou de integração."
			},
			{
				"id": "naval_facil_qualidade_de_software_bug_24",
				"topic": "Qualidade de Software",
				"ameaca": "Lacuna em Bug",
				"controle": "Revisar Bug",
				"explanation": "Revisar Bug reduz o risco. Conceito revisado: Bug é uma falha ou defeito no software. Ele pode surgir por erro de lógica, requisito mal interpretado, integração incorreta ou dados inesperados."
			},
			{
				"id": "naval_facil_business_intelligence_dashboard_25",
				"topic": "Business Intelligence",
				"ameaca": "Lacuna em Dashboard",
				"controle": "Revisar Dashboard",
				"explanation": "Revisar Dashboard reduz o risco. Conceito revisado: Dashboard é um painel visual com métricas, gráficos e indicadores. Em BI, ele ajuda a transformar dados em leitura rápida para gestão e acompanhamento."
			},
			{
				"id": "naval_facil_ciencia_de_dados_dataframe_26",
				"topic": "Ciência de Dados",
				"ameaca": "Lacuna em DataFrame",
				"controle": "Revisar DataFrame",
				"explanation": "Revisar DataFrame reduz o risco. Conceito revisado: DataFrame é a estrutura bidimensional do Pandas. Ele organiza dados como uma tabela, permitindo filtros, agrupamentos, junções, limpeza e análise exploratória."
			},
			{
				"id": "naval_facil_ciencia_de_dados_series_27",
				"topic": "Ciência de Dados",
				"ameaca": "Lacuna em Series",
				"controle": "Revisar Series",
				"explanation": "Revisar Series reduz o risco. Conceito revisado: Series é uma estrutura unidimensional do Pandas, formada por valores e índice. Uma coluna de um DataFrame pode ser tratada como uma Series."
			},
			{
				"id": "naval_facil_ciencia_de_dados_limpeza_de_dados_28",
				"topic": "Ciência de Dados",
				"ameaca": "Lacuna em Limpeza de Dados",
				"controle": "Revisar Limpeza de Dados",
				"explanation": "Revisar Limpeza de Dados reduz o risco. Conceito revisado: Limpeza de dados prepara uma base para análise confiável. Em projetos reais, essa etapa costuma consumir muito tempo porque dados chegam incompletos, duplicados ou fora de padrão."
			},
			{
				"id": "naval_facil_lgpd_e_privacidade_lgpd_29",
				"topic": "LGPD e Privacidade",
				"ameaca": "Lacuna em LGPD",
				"controle": "Revisar LGPD",
				"explanation": "Revisar LGPD reduz o risco. Conceito revisado: LGPD significa Lei Geral de Proteção de Dados. Ela regula coleta, uso, armazenamento e compartilhamento de dados pessoais no Brasil."
			},
			{
				"id": "naval_facil_programacao_orientada_a_objetos_poo_30",
				"topic": "Programação Orientada a Objetos",
				"ameaca": "Lacuna em POO",
				"controle": "Revisar POO",
				"explanation": "Revisar POO reduz o risco. Conceito revisado: POO significa Programação Orientada a Objetos. Ela modela o software com objetos que possuem dados e comportamentos, favorecendo organização e reutilização."
			}
		],
		"normal": [
			{
				"id": "naval_normal_ciberseguranca_autenticacao_01",
				"topic": "Cibersegurança",
				"ameaca": "Lacuna em Autenticação",
				"controle": "Revisar Autenticação",
				"explanation": "Revisar Autenticação reduz o risco. Conceito revisado: Autenticação verifica identidade por senha, biometria, token ou outro fator. Ela responde à pergunta: quem é você?"
			},
			{
				"id": "naval_normal_ciberseguranca_autorizacao_02",
				"topic": "Cibersegurança",
				"ameaca": "Lacuna em Autorização",
				"controle": "Revisar Autorização",
				"explanation": "Revisar Autorização reduz o risco. Conceito revisado: Autorização ocorre depois da autenticação. Ela controla permissões e responde: o que este usuário pode fazer?"
			},
			{
				"id": "naval_normal_desenvolvimento_web_api_rest_03",
				"topic": "Desenvolvimento Web",
				"ameaca": "Lacuna em API REST",
				"controle": "Revisar API REST",
				"explanation": "Revisar API REST reduz o risco. Conceito revisado: API REST segue princípios de Representational State Transfer. Ela costuma usar métodos HTTP como GET, POST, PUT e DELETE para manipular recursos."
			},
			{
				"id": "naval_normal_desenvolvimento_web_json_04",
				"topic": "Desenvolvimento Web",
				"ameaca": "Lacuna em JSON",
				"controle": "Revisar JSON",
				"explanation": "Revisar JSON reduz o risco. Conceito revisado: JSON significa JavaScript Object Notation. Ele é comum em APIs porque é simples, legível e compatível com várias linguagens."
			},
			{
				"id": "naval_normal_back_end_cache_05",
				"topic": "Back-end",
				"ameaca": "Lacuna em Cache",
				"controle": "Revisar Cache",
				"explanation": "Revisar Cache reduz o risco. Conceito revisado: Cache melhora desempenho ao reutilizar dados acessados com frequência. O cuidado é manter validade e evitar entregar informação desatualizada."
			},
			{
				"id": "naval_normal_banco_de_dados_transacao_06",
				"topic": "Banco de Dados",
				"ameaca": "Lacuna em Transação",
				"controle": "Revisar Transação",
				"explanation": "Revisar Transação reduz o risco. Conceito revisado: Transação protege a consistência dos dados. Se tudo dá certo, ocorre commit; se algo falha, rollback desfaz as alterações."
			},
			{
				"id": "naval_normal_banco_de_dados_indice_07",
				"topic": "Banco de Dados",
				"ameaca": "Lacuna em Índice",
				"controle": "Revisar Índice",
				"explanation": "Revisar Índice reduz o risco. Conceito revisado: Índice é uma estrutura auxiliar para localizar registros mais rápido. Ele melhora consultas, mas exige equilíbrio porque impacta inserções e atualizações."
			},
			{
				"id": "naval_normal_banco_de_dados_chave_estrangeira_08",
				"topic": "Banco de Dados",
				"ameaca": "Lacuna em Chave Estrangeira",
				"controle": "Revisar Chave Estrangeira",
				"explanation": "Revisar Chave Estrangeira reduz o risco. Conceito revisado: Chave estrangeira referencia a chave primária de outra tabela. Ela ajuda a evitar relacionamentos inválidos entre registros."
			},
			{
				"id": "naval_normal_modelagem_de_dados_diagrama_er_09",
				"topic": "Modelagem de Dados",
				"ameaca": "Lacuna em Diagrama ER",
				"controle": "Revisar Diagrama ER",
				"explanation": "Revisar Diagrama ER reduz o risco. Conceito revisado: Diagrama ER significa Entidade-Relacionamento. Ele apoia a modelagem conceitual de bancos de dados antes da criação das tabelas."
			},
			{
				"id": "naval_normal_banco_de_dados_normalizacao_10",
				"topic": "Banco de Dados",
				"ameaca": "Lacuna em Normalização",
				"controle": "Revisar Normalização",
				"explanation": "Revisar Normalização reduz o risco. Conceito revisado: Normalização aplica formas normais para melhorar consistência no banco relacional. Ela reduz repetição indevida, mas pode exigir joins mais frequentes."
			},
			{
				"id": "naval_normal_redes_roteamento_11",
				"topic": "Redes",
				"ameaca": "Lacuna em Roteamento",
				"controle": "Revisar Roteamento",
				"explanation": "Revisar Roteamento reduz o risco. Conceito revisado: Roteamento encaminha pacotes entre redes. Roteadores usam tabelas e protocolos para escolher o melhor caminho disponível."
			},
			{
				"id": "naval_normal_redes_e_web_http_12",
				"topic": "Redes e Web",
				"ameaca": "Lacuna em HTTP",
				"controle": "Revisar HTTP",
				"explanation": "Revisar HTTP reduz o risco. Conceito revisado: HTTP significa HyperText Transfer Protocol. Ele define requisições e respostas na web, usando métodos como GET e POST."
			},
			{
				"id": "naval_normal_redes_e_seguranca_https_13",
				"topic": "Redes e Segurança",
				"ameaca": "Lacuna em HTTPS",
				"controle": "Revisar HTTPS",
				"explanation": "Revisar HTTPS reduz o risco. Conceito revisado: HTTPS significa HyperText Transfer Protocol Secure. Ele usa TLS para proteger confidencialidade, integridade e autenticidade da comunicação."
			},
			{
				"id": "naval_normal_redes_e_seguranca_vpn_14",
				"topic": "Redes e Segurança",
				"ameaca": "Lacuna em VPN",
				"controle": "Revisar VPN",
				"explanation": "Revisar VPN reduz o risco. Conceito revisado: VPN significa Virtual Private Network, ou Rede Privada Virtual. Ela protege tráfego e permite acesso seguro a recursos internos."
			},
			{
				"id": "naval_normal_ciberseguranca_hash_15",
				"topic": "Cibersegurança",
				"ameaca": "Lacuna em Hash",
				"controle": "Revisar Hash",
				"explanation": "Revisar Hash reduz o risco. Conceito revisado: Hash é uma função que transforma dados em um resumo. É usado para integridade e armazenamento seguro de senhas quando combinado com salting e boas práticas."
			},
			{
				"id": "naval_normal_ciberseguranca_criptografia_16",
				"topic": "Cibersegurança",
				"ameaca": "Lacuna em Criptografia",
				"controle": "Revisar Criptografia",
				"explanation": "Revisar Criptografia reduz o risco. Conceito revisado: Criptografia protege confidencialidade e, em alguns usos, integridade e autenticidade. Ela é base de HTTPS, armazenamento seguro e comunicação protegida."
			},
			{
				"id": "naval_normal_ciberseguranca_sql_injection_17",
				"topic": "Cibersegurança",
				"ameaca": "Lacuna em SQL Injection",
				"controle": "Revisar SQL Injection",
				"explanation": "Revisar SQL Injection reduz o risco. Conceito revisado: SQL Injection é uma vulnerabilidade de injeção em banco de dados. Validação, consultas parametrizadas e menor privilégio reduzem esse risco."
			},
			{
				"id": "naval_normal_ciberseguranca_xss_18",
				"topic": "Cibersegurança",
				"ameaca": "Lacuna em XSS",
				"controle": "Revisar XSS",
				"explanation": "Revisar XSS reduz o risco. Conceito revisado: XSS significa Cross-Site Scripting. Ele ocorre quando uma aplicação exibe conteúdo não tratado, permitindo execução de scripts no navegador da vítima."
			},
			{
				"id": "naval_normal_ux_ihc_persona_19",
				"topic": "UX/IHC",
				"ameaca": "Lacuna em Persona",
				"controle": "Revisar Persona",
				"explanation": "Revisar Persona reduz o risco. Conceito revisado: Persona ajuda equipes a projetarem pensando em necessidades, dores, objetivos e contexto de uso de grupos de usuários."
			},
			{
				"id": "naval_normal_ux_ihc_heuristicas_de_nielsen_20",
				"topic": "UX/IHC",
				"ameaca": "Lacuna em Heurísticas de Nielsen",
				"controle": "Revisar Heurísticas de Nielsen",
				"explanation": "Revisar Heurísticas de Nielsen reduz o risco. Conceito revisado: As heurísticas de Nielsen orientam avaliação de interfaces, incluindo feedback, consistência, prevenção de erros e liberdade do usuário."
			},
			{
				"id": "naval_normal_front_end_design_responsivo_21",
				"topic": "Front-end",
				"ameaca": "Lacuna em Design Responsivo",
				"controle": "Revisar Design Responsivo",
				"explanation": "Revisar Design Responsivo reduz o risco. Conceito revisado: Design responsivo usa layouts flexíveis, media queries e boas práticas de interface para manter usabilidade em celular, tablet e desktop."
			},
			{
				"id": "naval_normal_devops_devops_22",
				"topic": "DevOps",
				"ameaca": "Lacuna em DevOps",
				"controle": "Revisar DevOps",
				"explanation": "Revisar DevOps reduz o risco. Conceito revisado: DevOps combina cultura, automação e colaboração. Ele reduz atritos entre desenvolvimento, testes, infraestrutura e implantação."
			},
			{
				"id": "naval_normal_devops_pipeline_23",
				"topic": "DevOps",
				"ameaca": "Lacuna em Pipeline",
				"controle": "Revisar Pipeline",
				"explanation": "Revisar Pipeline reduz o risco. Conceito revisado: Pipeline organiza o fluxo de entrega de software. Em CI/CD, ele reduz tarefas manuais e torna publicações mais repetíveis."
			},
			{
				"id": "naval_normal_devops_container_24",
				"topic": "DevOps",
				"ameaca": "Lacuna em Container",
				"controle": "Revisar Container",
				"explanation": "Revisar Container reduz o risco. Conceito revisado: Container ajuda a executar software de forma consistente entre desenvolvimento, teste e produção. Docker é uma ferramenta comum nesse contexto."
			},
			{
				"id": "naval_normal_devops_ci_cd_25",
				"topic": "DevOps",
				"ameaca": "Lacuna em CI/CD",
				"controle": "Revisar CI/CD",
				"explanation": "Revisar CI/CD reduz o risco. Conceito revisado: CI/CD significa Continuous Integration e Continuous Delivery/Deployment, ou Integração Contínua e Entrega/Implantação Contínua. Ele reduz erros manuais e acelera entregas."
			},
			{
				"id": "naval_normal_dados_e_bi_etl_26",
				"topic": "Dados e BI",
				"ameaca": "Lacuna em ETL",
				"controle": "Revisar ETL",
				"explanation": "Revisar ETL reduz o risco. Conceito revisado: ETL significa Extract, Transform and Load, ou Extração, Transformação e Carga. Ele coleta dados, aplica tratamentos e carrega o resultado em bases analíticas, como Data Warehouse."
			},
			{
				"id": "naval_normal_business_intelligence_kpi_27",
				"topic": "Business Intelligence",
				"ameaca": "Lacuna em KPI",
				"controle": "Revisar KPI",
				"explanation": "Revisar KPI reduz o risco. Conceito revisado: KPI significa Key Performance Indicator, ou Indicador-Chave de Desempenho. Ele ajuda a acompanhar objetivos com métricas relevantes e acionáveis."
			},
			{
				"id": "naval_normal_ciencia_de_dados_mineracao_de_dados_28",
				"topic": "Ciência de Dados",
				"ameaca": "Lacuna em Mineração de Dados",
				"controle": "Revisar Mineração de Dados",
				"explanation": "Revisar Mineração de Dados reduz o risco. Conceito revisado: Mineração de dados aplica técnicas para descobrir padrões, agrupamentos, associações ou classificações. Ela pode fazer parte do processo KDD."
			},
			{
				"id": "naval_normal_pandas_e_analise_de_dados_groupby_29",
				"topic": "Pandas e Análise de Dados",
				"ameaca": "Lacuna em GroupBy",
				"controle": "Revisar GroupBy",
				"explanation": "Revisar GroupBy reduz o risco. Conceito revisado: GroupBy é uma operação do Pandas inspirada no padrão split-apply-combine. Ela separa dados por grupos, aplica cálculos e combina os resultados."
			},
			{
				"id": "naval_normal_qualidade_de_dados_padronizacao_de_dados_30",
				"topic": "Qualidade de Dados",
				"ameaca": "Lacuna em Padronização de Dados",
				"controle": "Revisar Padronização de Dados",
				"explanation": "Revisar Padronização de Dados reduz o risco. Conceito revisado: Padronização de dados evita categorias duplicadas e comparações incorretas. Exemplos comuns envolvem datas, nomes, siglas, letras maiúsculas e unidades de medida."
			}
		],
		"dificil": [
			{
				"id": "naval_dificil_business_intelligence_data_warehouse_01",
				"topic": "Business Intelligence",
				"ameaca": "Lacuna em Data Warehouse",
				"controle": "Revisar Data Warehouse",
				"explanation": "Revisar Data Warehouse reduz o risco. Conceito revisado: Data Warehouse é um repositório analítico integrado, histórico e não volátil. Ele consolida dados de várias fontes para consultas, indicadores e análises estratégicas."
			},
			{
				"id": "naval_dificil_business_intelligence_data_mart_02",
				"topic": "Business Intelligence",
				"ameaca": "Lacuna em Data Mart",
				"controle": "Revisar Data Mart",
				"explanation": "Revisar Data Mart reduz o risco. Conceito revisado: Data Mart é uma parte menor de um Data Warehouse. Ele atende necessidades de uma área, como vendas, financeiro ou recursos humanos."
			},
			{
				"id": "naval_dificil_business_intelligence_olap_03",
				"topic": "Business Intelligence",
				"ameaca": "Lacuna em OLAP",
				"controle": "Revisar OLAP",
				"explanation": "Revisar OLAP reduz o risco. Conceito revisado: OLAP significa Online Analytical Processing. Ele é voltado a consultas analíticas, comparações, agregações e exploração de dados para decisão."
			},
			{
				"id": "naval_dificil_banco_de_dados_oltp_04",
				"topic": "Banco de Dados",
				"ameaca": "Lacuna em OLTP",
				"controle": "Revisar OLTP",
				"explanation": "Revisar OLTP reduz o risco. Conceito revisado: OLTP significa Online Transaction Processing. Ele prioriza consistência, rapidez em transações e operações como cadastro, compra, pagamento e atualização."
			},
			{
				"id": "naval_dificil_data_warehouse_star_schema_05",
				"topic": "Data Warehouse",
				"ameaca": "Lacuna em Star Schema",
				"controle": "Revisar Star Schema",
				"explanation": "Revisar Star Schema reduz o risco. Conceito revisado: Star Schema, ou esquema estrela, facilita consultas analíticas. A tabela fato guarda métricas, enquanto dimensões descrevem contexto como tempo, produto e local."
			},
			{
				"id": "naval_dificil_data_warehouse_granularidade_06",
				"topic": "Data Warehouse",
				"ameaca": "Lacuna em Granularidade",
				"controle": "Revisar Granularidade",
				"explanation": "Revisar Granularidade reduz o risco. Conceito revisado: Granularidade indica quão detalhado é um dado. Em Data Warehouse, granularidade baixa guarda mais detalhes; granularidade alta guarda dados mais resumidos."
			},
			{
				"id": "naval_dificil_governanca_de_dados_metadados_07",
				"topic": "Governança de Dados",
				"ameaca": "Lacuna em Metadados",
				"controle": "Revisar Metadados",
				"explanation": "Revisar Metadados reduz o risco. Conceito revisado: Metadados são dados sobre dados. Eles ajudam a entender campos, fontes, qualidade, periodicidade, responsáveis e regras de uso."
			},
			{
				"id": "naval_dificil_mineracao_de_dados_kdd_08",
				"topic": "Mineração de Dados",
				"ameaca": "Lacuna em KDD",
				"controle": "Revisar KDD",
				"explanation": "Revisar KDD reduz o risco. Conceito revisado: KDD significa Knowledge Discovery in Databases, ou Descoberta de Conhecimento em Bases de Dados. Inclui seleção, limpeza, transformação, mineração e interpretação."
			},
			{
				"id": "naval_dificil_ciencia_de_dados_outlier_09",
				"topic": "Ciência de Dados",
				"ameaca": "Lacuna em Outlier",
				"controle": "Revisar Outlier",
				"explanation": "Revisar Outlier reduz o risco. Conceito revisado: Outlier pode indicar erro, evento raro ou comportamento relevante. Antes de remover, o analista precisa entender o contexto e o impacto na análise."
			},
			{
				"id": "naval_dificil_estatistica_e_dados_correlacao_10",
				"topic": "Estatística e Dados",
				"ameaca": "Lacuna em Correlação",
				"controle": "Revisar Correlação",
				"explanation": "Revisar Correlação reduz o risco. Conceito revisado: Correlação indica se variáveis tendem a variar juntas. Em análise de dados, é importante lembrar que correlação não implica causalidade."
			},
			{
				"id": "naval_dificil_estatistica_e_dados_amostragem_11",
				"topic": "Estatística e Dados",
				"ameaca": "Lacuna em Amostragem",
				"controle": "Revisar Amostragem",
				"explanation": "Revisar Amostragem reduz o risco. Conceito revisado: Amostragem reduz custo de coleta e análise, mas precisa ser planejada para evitar vieses e manter representatividade."
			},
			{
				"id": "naval_dificil_ciencia_de_dados_feature_engineering_12",
				"topic": "Ciência de Dados",
				"ameaca": "Lacuna em Feature Engineering",
				"controle": "Revisar Feature Engineering",
				"explanation": "Revisar Feature Engineering reduz o risco. Conceito revisado: Feature Engineering envolve preparar atributos, criar indicadores, transformar escalas e extrair sinais úteis. A qualidade das variáveis influencia fortemente modelos de dados."
			},
			{
				"id": "naval_dificil_engenharia_de_software_acoplamento_13",
				"topic": "Engenharia de Software",
				"ameaca": "Lacuna em Acoplamento",
				"controle": "Revisar Acoplamento",
				"explanation": "Revisar Acoplamento reduz o risco. Conceito revisado: Baixo acoplamento facilita manutenção, testes e evolução porque reduz dependências entre partes do sistema."
			},
			{
				"id": "naval_dificil_engenharia_de_software_coesao_14",
				"topic": "Engenharia de Software",
				"ameaca": "Lacuna em Coesão",
				"controle": "Revisar Coesão",
				"explanation": "Revisar Coesão reduz o risco. Conceito revisado: Alta coesão é desejável porque mantém componentes focados em uma responsabilidade clara, melhorando entendimento e manutenção."
			},
			{
				"id": "naval_dificil_engenharia_de_software_divida_tecnica_15",
				"topic": "Engenharia de Software",
				"ameaca": "Lacuna em Dívida Técnica",
				"controle": "Revisar Dívida Técnica",
				"explanation": "Revisar Dívida Técnica reduz o risco. Conceito revisado: Dívida técnica surge quando a equipe escolhe atalhos. Se não for controlada, aumenta retrabalho, dificulta manutenção e reduz velocidade de evolução."
			},
			{
				"id": "naval_dificil_arquitetura_de_software_mvc_16",
				"topic": "Arquitetura de Software",
				"ameaca": "Lacuna em MVC",
				"controle": "Revisar MVC",
				"explanation": "Revisar MVC reduz o risco. Conceito revisado: MVC significa Model-View-Controller. Ele organiza dados, interface e fluxo de controle em camadas para reduzir mistura de responsabilidades."
			},
			{
				"id": "naval_dificil_arquitetura_de_software_solid_17",
				"topic": "Arquitetura de Software",
				"ameaca": "Lacuna em SOLID",
				"controle": "Revisar SOLID",
				"explanation": "Revisar SOLID reduz o risco. Conceito revisado: SOLID é um conjunto de cinco princípios de projeto de software. Eles orientam responsabilidades claras, baixo acoplamento, extensibilidade e substituição segura."
			},
			{
				"id": "naval_dificil_poo_polimorfismo_18",
				"topic": "POO",
				"ameaca": "Lacuna em Polimorfismo",
				"controle": "Revisar Polimorfismo",
				"explanation": "Revisar Polimorfismo reduz o risco. Conceito revisado: Polimorfismo é um princípio da Programação Orientada a Objetos. Ele permite tratar objetos por uma interface comum, mantendo comportamentos especializados."
			},
			{
				"id": "naval_dificil_gestao_de_projetos_scrum_19",
				"topic": "Gestão de Projetos",
				"ameaca": "Lacuna em Scrum",
				"controle": "Revisar Scrum",
				"explanation": "Revisar Scrum reduz o risco. Conceito revisado: Scrum é um framework ágil com papéis como Product Owner, Scrum Master e Developers. Ele usa Sprints, Backlog e revisões para adaptação contínua."
			},
			{
				"id": "naval_dificil_governanca_de_ti_cobit_20",
				"topic": "Governança de TI",
				"ameaca": "Lacuna em COBIT",
				"controle": "Revisar COBIT",
				"explanation": "Revisar COBIT reduz o risco. Conceito revisado: COBIT significa Control Objectives for Information and Related Technologies. Ele apoia governança, controle, valor, riscos e alinhamento estratégico de TI."
			},
			{
				"id": "naval_dificil_governanca_de_ti_itil_21",
				"topic": "Governança de TI",
				"ameaca": "Lacuna em ITIL",
				"controle": "Revisar ITIL",
				"explanation": "Revisar ITIL reduz o risco. Conceito revisado: ITIL significa Information Technology Infrastructure Library. Ela trata serviços, incidentes, mudanças, problemas, níveis de serviço e melhoria contínua."
			},
			{
				"id": "naval_dificil_governanca_de_ti_sla_22",
				"topic": "Governança de TI",
				"ameaca": "Lacuna em SLA",
				"controle": "Revisar SLA",
				"explanation": "Revisar SLA reduz o risco. Conceito revisado: SLA significa Service Level Agreement, ou Acordo de Nível de Serviço. Ele define metas como disponibilidade, tempo de resposta e prazo de atendimento."
			},
			{
				"id": "naval_dificil_continuidade_de_negocio_rto_e_rpo_23",
				"topic": "Continuidade de Negócio",
				"ameaca": "Lacuna em RTO e RPO",
				"controle": "Revisar RTO e RPO",
				"explanation": "Revisar RTO e RPO reduz o risco. Conceito revisado: RTO significa Recovery Time Objective, ou tempo máximo para restaurar o serviço. RPO significa Recovery Point Objective, ou ponto máximo aceitável de perda de dados."
			},
			{
				"id": "naval_dificil_ciberseguranca_zero_trust_24",
				"topic": "Cibersegurança",
				"ameaca": "Lacuna em Zero Trust",
				"controle": "Revisar Zero Trust",
				"explanation": "Revisar Zero Trust reduz o risco. Conceito revisado: Zero Trust, ou confiança zero, exige verificação contínua de identidade, contexto e permissões. A ideia central é nunca confiar por padrão."
			},
			{
				"id": "naval_dificil_ciberseguranca_menor_privilegio_25",
				"topic": "Cibersegurança",
				"ameaca": "Lacuna em Menor Privilégio",
				"controle": "Revisar Menor Privilégio",
				"explanation": "Revisar Menor Privilégio reduz o risco. Conceito revisado: O princípio do menor privilégio reduz danos em caso de falha ou invasão. Usuários e sistemas não devem ter acessos além do necessário."
			},
			{
				"id": "naval_dificil_ciberseguranca_oauth_2_0_26",
				"topic": "Cibersegurança",
				"ameaca": "Lacuna em OAuth 2.0",
				"controle": "Revisar OAuth 2.0",
				"explanation": "Revisar OAuth 2.0 reduz o risco. Conceito revisado: OAuth 2.0 é um protocolo de autorização. Ele permite que uma aplicação acesse recursos em nome do usuário por meio de tokens controlados."
			},
			{
				"id": "naval_dificil_ciberseguranca_jwt_27",
				"topic": "Cibersegurança",
				"ameaca": "Lacuna em JWT",
				"controle": "Revisar JWT",
				"explanation": "Revisar JWT reduz o risco. Conceito revisado: JWT significa JSON Web Token. Ele é usado para representar claims, como identidade e permissões, mas precisa de expiração, assinatura e armazenamento seguro."
			},
			{
				"id": "naval_dificil_devops_observabilidade_28",
				"topic": "DevOps",
				"ameaca": "Lacuna em Observabilidade",
				"controle": "Revisar Observabilidade",
				"explanation": "Revisar Observabilidade reduz o risco. Conceito revisado: Observabilidade combina sinais como logs, métricas e rastreamento distribuído. Ela ajuda a investigar falhas, gargalos e comportamento em produção."
			},
			{
				"id": "naval_dificil_devops_e_cloud_iac_29",
				"topic": "DevOps e Cloud",
				"ameaca": "Lacuna em IaC",
				"controle": "Revisar IaC",
				"explanation": "Revisar IaC reduz o risco. Conceito revisado: IaC significa Infrastructure as Code, ou Infraestrutura como Código. Ela torna ambientes reproduzíveis, auditáveis e menos dependentes de configuração manual."
			},
			{
				"id": "naval_dificil_lgpd_e_etica_privacidade_por_design_30",
				"topic": "LGPD e Ética",
				"ameaca": "Lacuna em Privacidade por Design",
				"controle": "Revisar Privacidade por Design",
				"explanation": "Revisar Privacidade por Design reduz o risco. Conceito revisado: Privacidade por design coloca proteção de dados no planejamento, arquitetura e operação. Ela se relaciona com minimização, finalidade, segurança e transparência."
			}
		]
	},
	"stop": {
		"facil": [
			{
				"id": "stop_facil_desenvolvimento_web_html_01",
				"topic": "Desenvolvimento Web",
				"categoria": "Desenvolvimento Web",
				"letra": "H",
				"dica": "Estrutura o conteúdo de páginas web usando marcações como títulos, parágrafos, links e seções.",
				"opcoes": ["HTML", "Fila", "Função", "Requisito", "LGPD"],
				"correta": "HTML",
				"explanation": "HTML significa HyperText Markup Language, ou Linguagem de Marcação de Hipertexto. Ele define a estrutura semântica de uma página web, como títulos, textos, listas, links e formulários."
			},
			{
				"id": "stop_facil_front_end_css_02",
				"topic": "Front-end",
				"categoria": "Front-end",
				"letra": "C",
				"dica": "Controla cores, espaçamentos, fontes e layout visual de uma página web.",
				"opcoes": ["CSS", "Backup", "Git", "Teste", "POO"],
				"correta": "CSS",
				"explanation": "CSS significa Cascading Style Sheets, ou Folhas de Estilo em Cascata. Ele separa a apresentação visual da estrutura HTML e permite criar interfaces responsivas e organizadas."
			},
			{
				"id": "stop_facil_programacao_web_javascript_03",
				"topic": "Programação Web",
				"categoria": "Programação Web",
				"letra": "J",
				"dica": "Adiciona comportamento dinâmico em páginas e aplicações web.",
				"opcoes": ["JavaScript", "MFA", "Cliente", "Bug", "HTML"],
				"correta": "JavaScript",
				"explanation": "JavaScript é uma linguagem de programação muito usada no navegador e também no back-end. Ela permite validar formulários, manipular o DOM, consumir APIs e criar interações dinâmicas."
			},
			{
				"id": "stop_facil_back_end_api_04",
				"topic": "Back-end",
				"categoria": "Back-end",
				"letra": "A",
				"dica": "Permite que sistemas diferentes se comuniquem por meio de regras e pontos de acesso definidos.",
				"opcoes": ["API", "UX", "Servidor", "Dashboard", "CSS"],
				"correta": "API",
				"explanation": "API significa Application Programming Interface, ou Interface de Programação de Aplicações. Ela expõe funcionalidades para que sistemas, aplicativos ou serviços troquem dados de forma padronizada."
			},
			{
				"id": "stop_facil_banco_de_dados_banco_de_dados_05",
				"topic": "Banco de Dados",
				"categoria": "Banco de Dados",
				"letra": "B",
				"dica": "Organiza e armazena dados para consulta, atualização e uso por sistemas.",
				"opcoes": ["Banco de Dados", "Acessibilidade", "Rede", "DataFrame", "JavaScript"],
				"correta": "Banco de Dados",
				"explanation": "Banco de dados é uma estrutura usada para armazenar informações de forma persistente. Em sistemas de informação, ele sustenta cadastros, transações, consultas e relatórios."
			},
			{
				"id": "stop_facil_sql_select_06",
				"topic": "SQL",
				"categoria": "SQL",
				"letra": "S",
				"dica": "Recupera registros de tabelas em um banco de dados relacional.",
				"opcoes": ["SELECT", "Algoritmo", "DNS", "Series", "API"],
				"correta": "SELECT",
				"explanation": "SELECT é um comando da linguagem SQL usado para consultar dados. Ele pode ser combinado com WHERE, JOIN, GROUP BY e ORDER BY para filtrar, relacionar e ordenar resultados."
			},
			{
				"id": "stop_facil_estruturas_de_dados_pilha_07",
				"topic": "Estruturas de Dados",
				"categoria": "Estruturas de Dados",
				"letra": "P",
				"dica": "Organiza dados no padrão em que o último elemento inserido é o primeiro a sair.",
				"opcoes": ["Pilha", "Variável", "Firewall", "Limpeza de Dados", "Banco de Dados"],
				"correta": "Pilha",
				"explanation": "Pilha é uma estrutura de dados baseada em LIFO, Last In, First Out. Ela aparece em chamadas de funções, desfazer ações e controle de execução."
			},
			{
				"id": "stop_facil_estruturas_de_dados_fila_08",
				"topic": "Estruturas de Dados",
				"categoria": "Estruturas de Dados",
				"letra": "F",
				"dica": "Organiza dados no padrão em que o primeiro elemento inserido é o primeiro a sair.",
				"opcoes": ["Fila", "Função", "Requisito", "LGPD", "SELECT"],
				"correta": "Fila",
				"explanation": "Fila é uma estrutura de dados baseada em FIFO, First In, First Out. Ela é útil em atendimento, processamento de tarefas e filas de mensagens."
			},
			{
				"id": "stop_facil_seguranca_da_informacao_backup_09",
				"topic": "Segurança da Informação",
				"categoria": "Segurança da Informação",
				"letra": "B",
				"dica": "Preserva cópias de dados para recuperação após falhas, exclusões ou incidentes.",
				"opcoes": ["Backup", "Git", "Teste", "POO", "Pilha"],
				"correta": "Backup",
				"explanation": "Backup é uma cópia de segurança dos dados. Ele reduz perdas em falhas, ataques, erros humanos e desastres, mas precisa ser testado para garantir restauração."
			},
			{
				"id": "stop_facil_ciberseguranca_mfa_10",
				"topic": "Cibersegurança",
				"categoria": "Cibersegurança",
				"letra": "M",
				"dica": "Exige mais de uma evidência para confirmar a identidade de um usuário.",
				"opcoes": ["MFA", "Cliente", "Bug", "HTML", "Fila"],
				"correta": "MFA",
				"explanation": "MFA significa Multi-Factor Authentication, ou Autenticação Multifator. Ele combina fatores como senha, aplicativo, biometria ou token para reduzir o risco de acesso indevido."
			},
			{
				"id": "stop_facil_ux_ihc_ux_11",
				"topic": "UX/IHC",
				"categoria": "UX/IHC",
				"letra": "U",
				"dica": "Avalia como uma pessoa percebe, entende e utiliza um produto ou serviço digital.",
				"opcoes": ["UX", "Servidor", "Dashboard", "CSS", "Backup"],
				"correta": "UX",
				"explanation": "UX significa User Experience, ou Experiência do Usuário. Ela envolve utilidade, facilidade de uso, eficiência, emoção, contexto e satisfação durante a interação."
			},
			{
				"id": "stop_facil_ihc_acessibilidade_12",
				"topic": "IHC",
				"categoria": "IHC",
				"letra": "A",
				"dica": "Remove barreiras para que pessoas com diferentes capacidades consigam usar sistemas.",
				"opcoes": ["Acessibilidade", "Rede", "DataFrame", "JavaScript", "MFA"],
				"correta": "Acessibilidade",
				"explanation": "Acessibilidade busca tornar produtos digitais utilizáveis por mais pessoas. Ela envolve contraste, navegação por teclado, texto alternativo, leitores de tela e linguagem clara."
			},
			{
				"id": "stop_facil_fundamentos_de_computacao_algoritmo_13",
				"topic": "Fundamentos de Computação",
				"categoria": "Fundamentos de Computação",
				"letra": "A",
				"dica": "Define uma sequência finita e ordenada de passos para resolver um problema.",
				"opcoes": ["Algoritmo", "DNS", "Series", "API", "UX"],
				"correta": "Algoritmo",
				"explanation": "Algoritmo é um conjunto de instruções lógicas para chegar a uma solução. Ele pode ser representado em linguagem natural, fluxograma, pseudocódigo ou código."
			},
			{
				"id": "stop_facil_programacao_variavel_14",
				"topic": "Programação",
				"categoria": "Programação",
				"letra": "V",
				"dica": "Armazena temporariamente valores usados por um programa durante sua execução.",
				"opcoes": ["Variável", "Firewall", "Limpeza de Dados", "Banco de Dados", "Acessibilidade"],
				"correta": "Variável",
				"explanation": "Variável é um nome associado a um valor em memória. Ela permite guardar dados como números, textos, estados e resultados intermediários."
			},
			{
				"id": "stop_facil_programacao_funcao_15",
				"topic": "Programação",
				"categoria": "Programação",
				"letra": "F",
				"dica": "Reúne instruções reutilizáveis para executar uma tarefa específica.",
				"opcoes": ["Função", "Requisito", "LGPD", "SELECT", "Algoritmo"],
				"correta": "Função",
				"explanation": "Função organiza o código em blocos menores e reutilizáveis. Ela melhora leitura, manutenção, testes e evita repetição desnecessária."
			},
			{
				"id": "stop_facil_devops_git_16",
				"topic": "DevOps",
				"categoria": "DevOps",
				"letra": "G",
				"dica": "Registra histórico de alterações e ajuda equipes a colaborarem no código.",
				"opcoes": ["Git", "Teste", "POO", "Pilha", "Variável"],
				"correta": "Git",
				"explanation": "Git é um sistema de controle de versão distribuído. Ele permite criar branches, revisar mudanças, voltar versões e colaborar com mais segurança."
			},
			{
				"id": "stop_facil_arquitetura_web_cliente_17",
				"topic": "Arquitetura Web",
				"categoria": "Arquitetura Web",
				"letra": "C",
				"dica": "Representa o lado que solicita serviços, páginas ou dados a outro sistema.",
				"opcoes": ["Cliente", "Bug", "HTML", "Fila", "Função"],
				"correta": "Cliente",
				"explanation": "Cliente é o componente que consome um serviço, como navegador, aplicativo mobile ou sistema externo. Ele envia requisições para um servidor."
			},
			{
				"id": "stop_facil_arquitetura_web_servidor_18",
				"topic": "Arquitetura Web",
				"categoria": "Arquitetura Web",
				"letra": "S",
				"dica": "Processa requisições e entrega páginas, dados ou serviços para clientes.",
				"opcoes": ["Servidor", "Dashboard", "CSS", "Backup", "Git"],
				"correta": "Servidor",
				"explanation": "Servidor é o componente que recebe requisições, executa regras de negócio, consulta dados e envia respostas para clientes ou outros sistemas."
			},
			{
				"id": "stop_facil_redes_rede_19",
				"topic": "Redes",
				"categoria": "Redes",
				"letra": "R",
				"dica": "Permite comunicação e compartilhamento de recursos entre dispositivos.",
				"opcoes": ["Rede", "DataFrame", "JavaScript", "MFA", "Cliente"],
				"correta": "Rede",
				"explanation": "Rede de computadores conecta dispositivos para troca de dados. Ela pode usar protocolos, endereços, roteadores, switches e serviços como DNS e HTTP."
			},
			{
				"id": "stop_facil_redes_dns_20",
				"topic": "Redes",
				"categoria": "Redes",
				"letra": "D",
				"dica": "Traduz nomes de domínio em endereços ip usados na comunicação de rede.",
				"opcoes": ["DNS", "Series", "API", "UX", "Servidor"],
				"correta": "DNS",
				"explanation": "DNS significa Domain Name System, ou Sistema de Nomes de Domínio. Ele permite acessar sites por nomes como exemplo.com em vez de memorizar endereços IP."
			},
			{
				"id": "stop_facil_ciberseguranca_firewall_21",
				"topic": "Cibersegurança",
				"categoria": "Cibersegurança",
				"letra": "F",
				"dica": "Controla tráfego de rede usando regras de permissão e bloqueio.",
				"opcoes": ["Firewall", "Limpeza de Dados", "Banco de Dados", "Acessibilidade", "Rede"],
				"correta": "Firewall",
				"explanation": "Firewall é um mecanismo de segurança que filtra comunicações. Ele pode bloquear conexões suspeitas, limitar portas e reduzir exposição de serviços."
			},
			{
				"id": "stop_facil_engenharia_de_software_requisito_22",
				"topic": "Engenharia de Software",
				"categoria": "Engenharia de Software",
				"letra": "R",
				"dica": "Descreve uma necessidade, função ou restrição que o sistema deve atender.",
				"opcoes": ["Requisito", "LGPD", "SELECT", "Algoritmo", "DNS"],
				"correta": "Requisito",
				"explanation": "Requisito registra o que o sistema precisa fazer ou respeitar. Pode ser funcional, quando descreve uma função, ou não funcional, quando descreve qualidade ou restrição."
			},
			{
				"id": "stop_facil_qualidade_de_software_teste_23",
				"topic": "Qualidade de Software",
				"categoria": "Qualidade de Software",
				"letra": "T",
				"dica": "Verifica se o software funciona conforme esperado e ajuda a encontrar defeitos.",
				"opcoes": ["Teste", "POO", "Pilha", "Variável", "Firewall"],
				"correta": "Teste",
				"explanation": "Teste de software reduz riscos ao verificar comportamentos esperados. Ele pode ser manual, automatizado, unitário, funcional, regressivo ou de integração."
			},
			{
				"id": "stop_facil_qualidade_de_software_bug_24",
				"topic": "Qualidade de Software",
				"categoria": "Qualidade de Software",
				"letra": "B",
				"dica": "Representa um defeito que faz o sistema agir diferente do esperado.",
				"opcoes": ["Bug", "HTML", "Fila", "Função", "Requisito"],
				"correta": "Bug",
				"explanation": "Bug é uma falha ou defeito no software. Ele pode surgir por erro de lógica, requisito mal interpretado, integração incorreta ou dados inesperados."
			},
			{
				"id": "stop_facil_business_intelligence_dashboard_25",
				"topic": "Business Intelligence",
				"categoria": "Business Intelligence",
				"letra": "D",
				"dica": "Reúne gráficos e indicadores para apoiar acompanhamento e decisão.",
				"opcoes": ["Dashboard", "CSS", "Backup", "Git", "Teste"],
				"correta": "Dashboard",
				"explanation": "Dashboard é um painel visual com métricas, gráficos e indicadores. Em BI, ele ajuda a transformar dados em leitura rápida para gestão e acompanhamento."
			},
			{
				"id": "stop_facil_ciencia_de_dados_dataframe_26",
				"topic": "Ciência de Dados",
				"categoria": "Ciência de Dados",
				"letra": "D",
				"dica": "Representa dados em formato de tabela com linhas e colunas no pandas.",
				"opcoes": ["DataFrame", "JavaScript", "MFA", "Cliente", "Bug"],
				"correta": "DataFrame",
				"explanation": "DataFrame é a estrutura bidimensional do Pandas. Ele organiza dados como uma tabela, permitindo filtros, agrupamentos, junções, limpeza e análise exploratória."
			},
			{
				"id": "stop_facil_ciencia_de_dados_series_27",
				"topic": "Ciência de Dados",
				"categoria": "Ciência de Dados",
				"letra": "S",
				"dica": "Representa uma sequência unidimensional de dados no pandas, parecida com uma coluna.",
				"opcoes": ["Series", "API", "UX", "Servidor", "Dashboard"],
				"correta": "Series",
				"explanation": "Series é uma estrutura unidimensional do Pandas, formada por valores e índice. Uma coluna de um DataFrame pode ser tratada como uma Series."
			},
			{
				"id": "stop_facil_ciencia_de_dados_limpeza_de_dados_28",
				"topic": "Ciência de Dados",
				"categoria": "Ciência de Dados",
				"letra": "L",
				"dica": "Trata valores ausentes, duplicados, tipos errados e inconsistências antes da análise.",
				"opcoes": ["Limpeza de Dados", "Banco de Dados", "Acessibilidade", "Rede", "JavaScript"],
				"correta": "Limpeza de Dados",
				"explanation": "Limpeza de dados prepara uma base para análise confiável. Em projetos reais, essa etapa costuma consumir muito tempo porque dados chegam incompletos, duplicados ou fora de padrão."
			},
			{
				"id": "stop_facil_lgpd_e_privacidade_lgpd_29",
				"topic": "LGPD e Privacidade",
				"categoria": "LGPD e Privacidade",
				"letra": "L",
				"dica": "Define regras brasileiras para tratamento de dados pessoais.",
				"opcoes": ["LGPD", "SELECT", "Algoritmo", "DNS", "Series"],
				"correta": "LGPD",
				"explanation": "LGPD significa Lei Geral de Proteção de Dados. Ela regula coleta, uso, armazenamento e compartilhamento de dados pessoais no Brasil."
			},
			{
				"id": "stop_facil_programacao_orientada_a_objetos_poo_30",
				"topic": "Programação Orientada a Objetos",
				"categoria": "Programação Orientada a Objetos",
				"letra": "P",
				"dica": "Organiza programas em classes, objetos, atributos e métodos.",
				"opcoes": ["POO", "Pilha", "Variável", "Firewall", "Limpeza de Dados"],
				"correta": "POO",
				"explanation": "POO significa Programação Orientada a Objetos. Ela modela o software com objetos que possuem dados e comportamentos, favorecendo organização e reutilização."
			}
		],
		"normal": [
			{
				"id": "stop_normal_ciberseguranca_autenticacao_01",
				"topic": "Cibersegurança",
				"categoria": "Cibersegurança",
				"letra": "A",
				"dica": "Confirma se o usuário ou sistema realmente é quem afirma ser.",
				"opcoes": ["Autenticação", "Chave Estrangeira", "DevOps", "GroupBy", "Transação"],
				"correta": "Autenticação",
				"explanation": "Autenticação verifica identidade por senha, biometria, token ou outro fator. Ela responde à pergunta: quem é você?"
			},
			{
				"id": "stop_normal_ciberseguranca_autorizacao_02",
				"topic": "Cibersegurança",
				"categoria": "Cibersegurança",
				"letra": "A",
				"dica": "Define quais recursos e ações um usuário autenticado pode acessar.",
				"opcoes": ["Autorização", "Diagrama ER", "Pipeline", "Padronização de Dados", "Índice"],
				"correta": "Autorização",
				"explanation": "Autorização ocorre depois da autenticação. Ela controla permissões e responde: o que este usuário pode fazer?"
			},
			{
				"id": "stop_normal_desenvolvimento_web_api_rest_03",
				"topic": "Desenvolvimento Web",
				"categoria": "Desenvolvimento Web",
				"letra": "A",
				"dica": "Usa recursos, urls e métodos http para comunicação entre sistemas.",
				"opcoes": ["API REST", "Normalização", "SQL Injection", "Container", "Autenticação"],
				"correta": "API REST",
				"explanation": "API REST segue princípios de Representational State Transfer. Ela costuma usar métodos HTTP como GET, POST, PUT e DELETE para manipular recursos."
			},
			{
				"id": "stop_normal_desenvolvimento_web_json_04",
				"topic": "Desenvolvimento Web",
				"categoria": "Desenvolvimento Web",
				"letra": "J",
				"dica": "Representa dados em formato textual leve, muito usado em apis.",
				"opcoes": ["JSON", "Roteamento", "XSS", "CI/CD", "Autorização"],
				"correta": "JSON",
				"explanation": "JSON significa JavaScript Object Notation. Ele é comum em APIs porque é simples, legível e compatível com várias linguagens."
			},
			{
				"id": "stop_normal_back_end_cache_05",
				"topic": "Back-end",
				"categoria": "Back-end",
				"letra": "C",
				"dica": "Guarda dados temporários para reduzir tempo de resposta e carga de processamento.",
				"opcoes": ["Cache", "HTTP", "Persona", "ETL", "API REST"],
				"correta": "Cache",
				"explanation": "Cache melhora desempenho ao reutilizar dados acessados com frequência. O cuidado é manter validade e evitar entregar informação desatualizada."
			},
			{
				"id": "stop_normal_banco_de_dados_transacao_06",
				"topic": "Banco de Dados",
				"categoria": "Banco de Dados",
				"letra": "T",
				"dica": "Agrupa operações que devem ser confirmadas ou desfeitas de forma consistente.",
				"opcoes": ["Transação", "HTTPS", "Heurísticas de Nielsen", "KPI", "JSON"],
				"correta": "Transação",
				"explanation": "Transação protege a consistência dos dados. Se tudo dá certo, ocorre commit; se algo falha, rollback desfaz as alterações."
			},
			{
				"id": "stop_normal_banco_de_dados_indice_07",
				"topic": "Banco de Dados",
				"categoria": "Banco de Dados",
				"letra": "I",
				"dica": "Acelera buscas em tabelas, mas pode aumentar custo de escrita e armazenamento.",
				"opcoes": ["Índice", "VPN", "Design Responsivo", "Mineração de Dados", "Cache"],
				"correta": "Índice",
				"explanation": "Índice é uma estrutura auxiliar para localizar registros mais rápido. Ele melhora consultas, mas exige equilíbrio porque impacta inserções e atualizações."
			},
			{
				"id": "stop_normal_banco_de_dados_chave_estrangeira_08",
				"topic": "Banco de Dados",
				"categoria": "Banco de Dados",
				"letra": "C",
				"dica": "Cria vínculo entre tabelas e preserva integridade referencial.",
				"opcoes": ["Chave Estrangeira", "Hash", "DevOps", "GroupBy", "HTTPS"],
				"correta": "Chave Estrangeira",
				"explanation": "Chave estrangeira referencia a chave primária de outra tabela. Ela ajuda a evitar relacionamentos inválidos entre registros."
			},
			{
				"id": "stop_normal_modelagem_de_dados_diagrama_er_09",
				"topic": "Modelagem de Dados",
				"categoria": "Modelagem de Dados",
				"letra": "D",
				"dica": "Representa entidades, atributos e relacionamentos de um domínio.",
				"opcoes": ["Diagrama ER", "Criptografia", "Pipeline", "Padronização de Dados", "Índice"],
				"correta": "Diagrama ER",
				"explanation": "Diagrama ER significa Entidade-Relacionamento. Ele apoia a modelagem conceitual de bancos de dados antes da criação das tabelas."
			},
			{
				"id": "stop_normal_banco_de_dados_normalizacao_10",
				"topic": "Banco de Dados",
				"categoria": "Banco de Dados",
				"letra": "N",
				"dica": "Organiza tabelas para reduzir redundância e anomalias de atualização.",
				"opcoes": ["Normalização", "SQL Injection", "Container", "Autenticação", "Hash"],
				"correta": "Normalização",
				"explanation": "Normalização aplica formas normais para melhorar consistência no banco relacional. Ela reduz repetição indevida, mas pode exigir joins mais frequentes."
			},
			{
				"id": "stop_normal_redes_roteamento_11",
				"topic": "Redes",
				"categoria": "Redes",
				"letra": "R",
				"dica": "Define o caminho que pacotes percorrem entre origem e destino.",
				"opcoes": ["Roteamento", "XSS", "CI/CD", "Autorização", "Diagrama ER"],
				"correta": "Roteamento",
				"explanation": "Roteamento encaminha pacotes entre redes. Roteadores usam tabelas e protocolos para escolher o melhor caminho disponível."
			},
			{
				"id": "stop_normal_redes_e_web_http_12",
				"topic": "Redes e Web",
				"categoria": "Redes e Web",
				"letra": "H",
				"dica": "Protocolo usado para comunicação entre clientes e servidores web.",
				"opcoes": ["HTTP", "Persona", "ETL", "API REST", "Normalização"],
				"correta": "HTTP",
				"explanation": "HTTP significa HyperText Transfer Protocol. Ele define requisições e respostas na web, usando métodos como GET e POST."
			},
			{
				"id": "stop_normal_redes_e_seguranca_https_13",
				"topic": "Redes e Segurança",
				"categoria": "Redes e Segurança",
				"letra": "H",
				"dica": "Protege a comunicação web com criptografia sobre tls.",
				"opcoes": ["HTTPS", "Heurísticas de Nielsen", "KPI", "JSON", "Roteamento"],
				"correta": "HTTPS",
				"explanation": "HTTPS significa HyperText Transfer Protocol Secure. Ele usa TLS para proteger confidencialidade, integridade e autenticidade da comunicação."
			},
			{
				"id": "stop_normal_redes_e_seguranca_vpn_14",
				"topic": "Redes e Segurança",
				"categoria": "Redes e Segurança",
				"letra": "V",
				"dica": "Cria um túnel seguro para acesso remoto ou conexão entre redes.",
				"opcoes": ["VPN", "Design Responsivo", "Mineração de Dados", "Cache", "HTTP"],
				"correta": "VPN",
				"explanation": "VPN significa Virtual Private Network, ou Rede Privada Virtual. Ela protege tráfego e permite acesso seguro a recursos internos."
			},
			{
				"id": "stop_normal_ciberseguranca_hash_15",
				"topic": "Cibersegurança",
				"categoria": "Cibersegurança",
				"letra": "H",
				"dica": "Gera um resumo de tamanho fixo a partir de dados de entrada.",
				"opcoes": ["Hash", "DevOps", "GroupBy", "Transação", "HTTPS"],
				"correta": "Hash",
				"explanation": "Hash é uma função que transforma dados em um resumo. É usado para integridade e armazenamento seguro de senhas quando combinado com salting e boas práticas."
			},
			{
				"id": "stop_normal_ciberseguranca_criptografia_16",
				"topic": "Cibersegurança",
				"categoria": "Cibersegurança",
				"letra": "C",
				"dica": "Transforma dados para que só possam ser compreendidos com chave adequada.",
				"opcoes": ["Criptografia", "Pipeline", "Padronização de Dados", "Índice", "VPN"],
				"correta": "Criptografia",
				"explanation": "Criptografia protege confidencialidade e, em alguns usos, integridade e autenticidade. Ela é base de HTTPS, armazenamento seguro e comunicação protegida."
			},
			{
				"id": "stop_normal_ciberseguranca_sql_injection_17",
				"topic": "Cibersegurança",
				"categoria": "Cibersegurança",
				"letra": "S",
				"dica": "Ocorre quando entrada maliciosa manipula comandos sql de uma aplicação.",
				"opcoes": ["SQL Injection", "Container", "Chave Estrangeira", "DevOps", "GroupBy"],
				"correta": "SQL Injection",
				"explanation": "SQL Injection é uma vulnerabilidade de injeção em banco de dados. Validação, consultas parametrizadas e menor privilégio reduzem esse risco."
			},
			{
				"id": "stop_normal_ciberseguranca_xss_18",
				"topic": "Cibersegurança",
				"categoria": "Cibersegurança",
				"letra": "X",
				"dica": "Injeta scripts maliciosos em páginas vistas por usuários.",
				"opcoes": ["XSS", "CI/CD", "Diagrama ER", "Pipeline", "Padronização de Dados"],
				"correta": "XSS",
				"explanation": "XSS significa Cross-Site Scripting. Ele ocorre quando uma aplicação exibe conteúdo não tratado, permitindo execução de scripts no navegador da vítima."
			},
			{
				"id": "stop_normal_ux_ihc_persona_19",
				"topic": "UX/IHC",
				"categoria": "UX/IHC",
				"letra": "P",
				"dica": "Representa um perfil fictício baseado em características de usuários reais.",
				"opcoes": ["Persona", "ETL", "API REST", "Normalização", "SQL Injection"],
				"correta": "Persona",
				"explanation": "Persona ajuda equipes a projetarem pensando em necessidades, dores, objetivos e contexto de uso de grupos de usuários."
			},
			{
				"id": "stop_normal_ux_ihc_heuristicas_de_nielsen_20",
				"topic": "UX/IHC",
				"categoria": "UX/IHC",
				"letra": "H",
				"dica": "São princípios usados para avaliar problemas de usabilidade em interfaces.",
				"opcoes": ["Heurísticas de Nielsen", "KPI", "JSON", "Roteamento", "XSS"],
				"correta": "Heurísticas de Nielsen",
				"explanation": "As heurísticas de Nielsen orientam avaliação de interfaces, incluindo feedback, consistência, prevenção de erros e liberdade do usuário."
			},
			{
				"id": "stop_normal_front_end_design_responsivo_21",
				"topic": "Front-end",
				"categoria": "Front-end",
				"letra": "D",
				"dica": "Adapta a interface a diferentes tamanhos de tela e dispositivos.",
				"opcoes": ["Design Responsivo", "Mineração de Dados", "Cache", "HTTP", "Persona"],
				"correta": "Design Responsivo",
				"explanation": "Design responsivo usa layouts flexíveis, media queries e boas práticas de interface para manter usabilidade em celular, tablet e desktop."
			},
			{
				"id": "stop_normal_devops_devops_22",
				"topic": "DevOps",
				"categoria": "DevOps",
				"letra": "D",
				"dica": "Integra desenvolvimento e operações para entregar software com mais qualidade e frequência.",
				"opcoes": ["DevOps", "GroupBy", "Transação", "HTTPS", "Heurísticas de Nielsen"],
				"correta": "DevOps",
				"explanation": "DevOps combina cultura, automação e colaboração. Ele reduz atritos entre desenvolvimento, testes, infraestrutura e implantação."
			},
			{
				"id": "stop_normal_devops_pipeline_23",
				"topic": "DevOps",
				"categoria": "DevOps",
				"letra": "P",
				"dica": "Automatiza etapas como build, testes, análise e deploy.",
				"opcoes": ["Pipeline", "Padronização de Dados", "Índice", "VPN", "Design Responsivo"],
				"correta": "Pipeline",
				"explanation": "Pipeline organiza o fluxo de entrega de software. Em CI/CD, ele reduz tarefas manuais e torna publicações mais repetíveis."
			},
			{
				"id": "stop_normal_devops_container_24",
				"topic": "DevOps",
				"categoria": "DevOps",
				"letra": "C",
				"dica": "Empacota aplicação e dependências em ambiente isolado e reproduzível.",
				"opcoes": ["Container", "Autenticação", "Chave Estrangeira", "Hash", "GroupBy"],
				"correta": "Container",
				"explanation": "Container ajuda a executar software de forma consistente entre desenvolvimento, teste e produção. Docker é uma ferramenta comum nesse contexto."
			},
			{
				"id": "stop_normal_devops_ci_cd_25",
				"topic": "DevOps",
				"categoria": "DevOps",
				"letra": "C",
				"dica": "Automatiza integração, testes e entrega de software.",
				"opcoes": ["CI/CD", "Autorização", "Diagrama ER", "Criptografia", "Padronização de Dados"],
				"correta": "CI/CD",
				"explanation": "CI/CD significa Continuous Integration e Continuous Delivery/Deployment, ou Integração Contínua e Entrega/Implantação Contínua. Ele reduz erros manuais e acelera entregas."
			},
			{
				"id": "stop_normal_dados_e_bi_etl_26",
				"topic": "Dados e BI",
				"categoria": "Dados e BI",
				"letra": "E",
				"dica": "Extrai, transforma e carrega dados para outro ambiente de armazenamento ou análise.",
				"opcoes": ["ETL", "API REST", "Normalização", "SQL Injection", "Container"],
				"correta": "ETL",
				"explanation": "ETL significa Extract, Transform and Load, ou Extração, Transformação e Carga. Ele coleta dados, aplica tratamentos e carrega o resultado em bases analíticas, como Data Warehouse."
			},
			{
				"id": "stop_normal_business_intelligence_kpi_27",
				"topic": "Business Intelligence",
				"categoria": "Business Intelligence",
				"letra": "K",
				"dica": "Mede desempenho de processos, metas ou resultados importantes para o negócio.",
				"opcoes": ["KPI", "JSON", "Roteamento", "XSS", "CI/CD"],
				"correta": "KPI",
				"explanation": "KPI significa Key Performance Indicator, ou Indicador-Chave de Desempenho. Ele ajuda a acompanhar objetivos com métricas relevantes e acionáveis."
			},
			{
				"id": "stop_normal_ciencia_de_dados_mineracao_de_dados_28",
				"topic": "Ciência de Dados",
				"categoria": "Ciência de Dados",
				"letra": "M",
				"dica": "Busca padrões, relações e conhecimento útil em grandes conjuntos de dados.",
				"opcoes": ["Mineração de Dados", "Cache", "HTTP", "Persona", "ETL"],
				"correta": "Mineração de Dados",
				"explanation": "Mineração de dados aplica técnicas para descobrir padrões, agrupamentos, associações ou classificações. Ela pode fazer parte do processo KDD."
			},
			{
				"id": "stop_normal_pandas_e_analise_de_dados_groupby_29",
				"topic": "Pandas e Análise de Dados",
				"categoria": "Pandas e Análise de Dados",
				"letra": "G",
				"dica": "Agrupa registros no pandas para calcular somas, médias, contagens ou outras agregações.",
				"opcoes": ["GroupBy", "Transação", "HTTPS", "Heurísticas de Nielsen", "KPI"],
				"correta": "GroupBy",
				"explanation": "GroupBy é uma operação do Pandas inspirada no padrão split-apply-combine. Ela separa dados por grupos, aplica cálculos e combina os resultados."
			},
			{
				"id": "stop_normal_qualidade_de_dados_padronizacao_de_dados_30",
				"topic": "Qualidade de Dados",
				"categoria": "Qualidade de Dados",
				"letra": "P",
				"dica": "Coloca valores em formatos consistentes antes da análise.",
				"opcoes": ["Padronização de Dados", "Índice", "VPN", "Design Responsivo", "Mineração de Dados"],
				"correta": "Padronização de Dados",
				"explanation": "Padronização de dados evita categorias duplicadas e comparações incorretas. Exemplos comuns envolvem datas, nomes, siglas, letras maiúsculas e unidades de medida."
			}
		],
		"dificil": [
			{
				"id": "stop_dificil_business_intelligence_data_warehouse_01",
				"topic": "Business Intelligence",
				"categoria": "Business Intelligence",
				"letra": "D",
				"dica": "Integra dados históricos, orientados por assunto, para apoiar decisões gerenciais.",
				"opcoes": ["Data Warehouse", "KDD", "Dívida Técnica", "SLA", "IaC"],
				"correta": "Data Warehouse",
				"explanation": "Data Warehouse é um repositório analítico integrado, histórico e não volátil. Ele consolida dados de várias fontes para consultas, indicadores e análises estratégicas."
			},
			{
				"id": "stop_dificil_business_intelligence_data_mart_02",
				"topic": "Business Intelligence",
				"categoria": "Business Intelligence",
				"letra": "D",
				"dica": "Representa um subconjunto analítico voltado a uma área ou departamento específico.",
				"opcoes": ["Data Mart", "Outlier", "MVC", "RTO e RPO", "Privacidade por Design"],
				"correta": "Data Mart",
				"explanation": "Data Mart é uma parte menor de um Data Warehouse. Ele atende necessidades de uma área, como vendas, financeiro ou recursos humanos."
			},
			{
				"id": "stop_dificil_business_intelligence_olap_03",
				"topic": "Business Intelligence",
				"categoria": "Business Intelligence",
				"letra": "O",
				"dica": "Apoia análise multidimensional de dados históricos e agregados.",
				"opcoes": ["OLAP", "Correlação", "SOLID", "Zero Trust", "KDD"],
				"correta": "OLAP",
				"explanation": "OLAP significa Online Analytical Processing. Ele é voltado a consultas analíticas, comparações, agregações e exploração de dados para decisão."
			},
			{
				"id": "stop_dificil_banco_de_dados_oltp_04",
				"topic": "Banco de Dados",
				"categoria": "Banco de Dados",
				"letra": "O",
				"dica": "Processa transações operacionais frequentes do dia a dia.",
				"opcoes": ["OLTP", "Amostragem", "Polimorfismo", "Menor Privilégio", "Data Mart"],
				"correta": "OLTP",
				"explanation": "OLTP significa Online Transaction Processing. Ele prioriza consistência, rapidez em transações e operações como cadastro, compra, pagamento e atualização."
			},
			{
				"id": "stop_dificil_data_warehouse_star_schema_05",
				"topic": "Data Warehouse",
				"categoria": "Data Warehouse",
				"letra": "S",
				"dica": "Modela dados analíticos com uma tabela fato central ligada a tabelas dimensão.",
				"opcoes": ["Star Schema", "Feature Engineering", "Scrum", "OAuth 2.0", "OLAP"],
				"correta": "Star Schema",
				"explanation": "Star Schema, ou esquema estrela, facilita consultas analíticas. A tabela fato guarda métricas, enquanto dimensões descrevem contexto como tempo, produto e local."
			},
			{
				"id": "stop_dificil_data_warehouse_granularidade_06",
				"topic": "Data Warehouse",
				"categoria": "Data Warehouse",
				"letra": "G",
				"dica": "Define o nível de detalhe armazenado nos dados de uma tabela fato.",
				"opcoes": ["Granularidade", "Acoplamento", "COBIT", "JWT", "OLTP"],
				"correta": "Granularidade",
				"explanation": "Granularidade indica quão detalhado é um dado. Em Data Warehouse, granularidade baixa guarda mais detalhes; granularidade alta guarda dados mais resumidos."
			},
			{
				"id": "stop_dificil_governanca_de_dados_metadados_07",
				"topic": "Governança de Dados",
				"categoria": "Governança de Dados",
				"letra": "M",
				"dica": "Descrevem origem, significado, estrutura e regras dos dados.",
				"opcoes": ["Metadados", "Coesão", "ITIL", "Observabilidade", "Star Schema"],
				"correta": "Metadados",
				"explanation": "Metadados são dados sobre dados. Eles ajudam a entender campos, fontes, qualidade, periodicidade, responsáveis e regras de uso."
			},
			{
				"id": "stop_dificil_mineracao_de_dados_kdd_08",
				"topic": "Mineração de Dados",
				"categoria": "Mineração de Dados",
				"letra": "K",
				"dica": "Organiza o processo de descoberta de conhecimento em bases de dados.",
				"opcoes": ["KDD", "Dívida Técnica", "SLA", "IaC", "Granularidade"],
				"correta": "KDD",
				"explanation": "KDD significa Knowledge Discovery in Databases, ou Descoberta de Conhecimento em Bases de Dados. Inclui seleção, limpeza, transformação, mineração e interpretação."
			},
			{
				"id": "stop_dificil_ciencia_de_dados_outlier_09",
				"topic": "Ciência de Dados",
				"categoria": "Ciência de Dados",
				"letra": "O",
				"dica": "Representa um valor muito distante do comportamento esperado dos dados.",
				"opcoes": ["Outlier", "MVC", "RTO e RPO", "Privacidade por Design", "Metadados"],
				"correta": "Outlier",
				"explanation": "Outlier pode indicar erro, evento raro ou comportamento relevante. Antes de remover, o analista precisa entender o contexto e o impacto na análise."
			},
			{
				"id": "stop_dificil_estatistica_e_dados_correlacao_10",
				"topic": "Estatística e Dados",
				"categoria": "Estatística e Dados",
				"letra": "C",
				"dica": "Mede associação entre variáveis, mas não prova relação de causa e efeito.",
				"opcoes": ["Correlação", "SOLID", "Zero Trust", "Data Warehouse", "KDD"],
				"correta": "Correlação",
				"explanation": "Correlação indica se variáveis tendem a variar juntas. Em análise de dados, é importante lembrar que correlação não implica causalidade."
			},
			{
				"id": "stop_dificil_estatistica_e_dados_amostragem_11",
				"topic": "Estatística e Dados",
				"categoria": "Estatística e Dados",
				"letra": "A",
				"dica": "Seleciona parte dos dados para representar uma população maior.",
				"opcoes": ["Amostragem", "Polimorfismo", "Menor Privilégio", "Data Mart", "Outlier"],
				"correta": "Amostragem",
				"explanation": "Amostragem reduz custo de coleta e análise, mas precisa ser planejada para evitar vieses e manter representatividade."
			},
			{
				"id": "stop_dificil_ciencia_de_dados_feature_engineering_12",
				"topic": "Ciência de Dados",
				"categoria": "Ciência de Dados",
				"letra": "F",
				"dica": "Cria ou transforma variáveis para melhorar análises e modelos preditivos.",
				"opcoes": ["Feature Engineering", "Scrum", "OAuth 2.0", "OLAP", "Correlação"],
				"correta": "Feature Engineering",
				"explanation": "Feature Engineering envolve preparar atributos, criar indicadores, transformar escalas e extrair sinais úteis. A qualidade das variáveis influencia fortemente modelos de dados."
			},
			{
				"id": "stop_dificil_engenharia_de_software_acoplamento_13",
				"topic": "Engenharia de Software",
				"categoria": "Engenharia de Software",
				"letra": "A",
				"dica": "Mede o grau de dependência entre módulos, classes ou componentes.",
				"opcoes": ["Acoplamento", "COBIT", "JWT", "OLTP", "Amostragem"],
				"correta": "Acoplamento",
				"explanation": "Baixo acoplamento facilita manutenção, testes e evolução porque reduz dependências entre partes do sistema."
			},
			{
				"id": "stop_dificil_engenharia_de_software_coesao_14",
				"topic": "Engenharia de Software",
				"categoria": "Engenharia de Software",
				"letra": "C",
				"dica": "Mede o quanto responsabilidades internas de um módulo estão relacionadas entre si.",
				"opcoes": ["Coesão", "ITIL", "Observabilidade", "Star Schema", "Feature Engineering"],
				"correta": "Coesão",
				"explanation": "Alta coesão é desejável porque mantém componentes focados em uma responsabilidade clara, melhorando entendimento e manutenção."
			},
			{
				"id": "stop_dificil_engenharia_de_software_divida_tecnica_15",
				"topic": "Engenharia de Software",
				"categoria": "Engenharia de Software",
				"letra": "D",
				"dica": "Representa custo futuro gerado por soluções rápidas, frágeis ou mal planejadas.",
				"opcoes": ["Dívida Técnica", "SLA", "IaC", "Granularidade", "COBIT"],
				"correta": "Dívida Técnica",
				"explanation": "Dívida técnica surge quando a equipe escolhe atalhos. Se não for controlada, aumenta retrabalho, dificulta manutenção e reduz velocidade de evolução."
			},
			{
				"id": "stop_dificil_arquitetura_de_software_mvc_16",
				"topic": "Arquitetura de Software",
				"categoria": "Arquitetura de Software",
				"letra": "M",
				"dica": "Separa responsabilidades entre modelo, visão e controlador.",
				"opcoes": ["MVC", "RTO e RPO", "Privacidade por Design", "Metadados", "Coesão"],
				"correta": "MVC",
				"explanation": "MVC significa Model-View-Controller. Ele organiza dados, interface e fluxo de controle em camadas para reduzir mistura de responsabilidades."
			},
			{
				"id": "stop_dificil_arquitetura_de_software_solid_17",
				"topic": "Arquitetura de Software",
				"categoria": "Arquitetura de Software",
				"letra": "S",
				"dica": "Reúne princípios de design orientado a objetos para reduzir rigidez e facilitar manutenção.",
				"opcoes": ["SOLID", "Zero Trust", "Data Warehouse", "KDD", "Dívida Técnica"],
				"correta": "SOLID",
				"explanation": "SOLID é um conjunto de cinco princípios de projeto de software. Eles orientam responsabilidades claras, baixo acoplamento, extensibilidade e substituição segura."
			},
			{
				"id": "stop_dificil_poo_polimorfismo_18",
				"topic": "POO",
				"categoria": "POO",
				"letra": "P",
				"dica": "Permite que diferentes objetos respondam de formas específicas à mesma operação.",
				"opcoes": ["Polimorfismo", "Menor Privilégio", "Data Mart", "Outlier", "MVC"],
				"correta": "Polimorfismo",
				"explanation": "Polimorfismo é um princípio da Programação Orientada a Objetos. Ele permite tratar objetos por uma interface comum, mantendo comportamentos especializados."
			},
			{
				"id": "stop_dificil_gestao_de_projetos_scrum_19",
				"topic": "Gestão de Projetos",
				"categoria": "Gestão de Projetos",
				"letra": "S",
				"dica": "Organiza trabalho ágil em eventos, papéis e artefatos para entrega incremental.",
				"opcoes": ["Scrum", "OAuth 2.0", "OLAP", "Correlação", "SOLID"],
				"correta": "Scrum",
				"explanation": "Scrum é um framework ágil com papéis como Product Owner, Scrum Master e Developers. Ele usa Sprints, Backlog e revisões para adaptação contínua."
			},
			{
				"id": "stop_dificil_governanca_de_ti_cobit_20",
				"topic": "Governança de TI",
				"categoria": "Governança de TI",
				"letra": "C",
				"dica": "Orienta governança e gestão de ti alinhadas aos objetivos do negócio.",
				"opcoes": ["COBIT", "JWT", "OLTP", "Amostragem", "Polimorfismo"],
				"correta": "COBIT",
				"explanation": "COBIT significa Control Objectives for Information and Related Technologies. Ele apoia governança, controle, valor, riscos e alinhamento estratégico de TI."
			},
			{
				"id": "stop_dificil_governanca_de_ti_itil_21",
				"topic": "Governança de TI",
				"categoria": "Governança de TI",
				"letra": "I",
				"dica": "Organiza boas práticas para gestão de serviços de ti.",
				"opcoes": ["ITIL", "Observabilidade", "Star Schema", "Feature Engineering", "Scrum"],
				"correta": "ITIL",
				"explanation": "ITIL significa Information Technology Infrastructure Library. Ela trata serviços, incidentes, mudanças, problemas, níveis de serviço e melhoria contínua."
			},
			{
				"id": "stop_dificil_governanca_de_ti_sla_22",
				"topic": "Governança de TI",
				"categoria": "Governança de TI",
				"letra": "S",
				"dica": "Formaliza níveis de serviço esperados entre provedor e cliente.",
				"opcoes": ["SLA", "IaC", "Granularidade", "Acoplamento", "JWT"],
				"correta": "SLA",
				"explanation": "SLA significa Service Level Agreement, ou Acordo de Nível de Serviço. Ele define metas como disponibilidade, tempo de resposta e prazo de atendimento."
			},
			{
				"id": "stop_dificil_continuidade_de_negocio_rto_e_rpo_23",
				"topic": "Continuidade de Negócio",
				"categoria": "Continuidade de Negócio",
				"letra": "R",
				"dica": "Definem tempo máximo de recuperação e perda máxima aceitável de dados.",
				"opcoes": ["RTO e RPO", "Privacidade por Design", "Metadados", "Coesão", "ITIL"],
				"correta": "RTO e RPO",
				"explanation": "RTO significa Recovery Time Objective, ou tempo máximo para restaurar o serviço. RPO significa Recovery Point Objective, ou ponto máximo aceitável de perda de dados."
			},
			{
				"id": "stop_dificil_ciberseguranca_zero_trust_24",
				"topic": "Cibersegurança",
				"categoria": "Cibersegurança",
				"letra": "Z",
				"dica": "Assume que nenhuma conexão deve ser confiável automaticamente.",
				"opcoes": ["Zero Trust", "Data Warehouse", "KDD", "Dívida Técnica", "SLA"],
				"correta": "Zero Trust",
				"explanation": "Zero Trust, ou confiança zero, exige verificação contínua de identidade, contexto e permissões. A ideia central é nunca confiar por padrão."
			},
			{
				"id": "stop_dificil_ciberseguranca_menor_privilegio_25",
				"topic": "Cibersegurança",
				"categoria": "Cibersegurança",
				"letra": "M",
				"dica": "Concede apenas as permissões necessárias para executar uma atividade.",
				"opcoes": ["Menor Privilégio", "Data Mart", "Outlier", "MVC", "RTO e RPO"],
				"correta": "Menor Privilégio",
				"explanation": "O princípio do menor privilégio reduz danos em caso de falha ou invasão. Usuários e sistemas não devem ter acessos além do necessário."
			},
			{
				"id": "stop_dificil_ciberseguranca_oauth_2_0_26",
				"topic": "Cibersegurança",
				"categoria": "Cibersegurança",
				"letra": "O",
				"dica": "Permite autorização delegada sem compartilhar senha com aplicações terceiras.",
				"opcoes": ["OAuth 2.0", "OLAP", "Correlação", "SOLID", "Data Warehouse"],
				"correta": "OAuth 2.0",
				"explanation": "OAuth 2.0 é um protocolo de autorização. Ele permite que uma aplicação acesse recursos em nome do usuário por meio de tokens controlados."
			},
			{
				"id": "stop_dificil_ciberseguranca_jwt_27",
				"topic": "Cibersegurança",
				"categoria": "Cibersegurança",
				"letra": "J",
				"dica": "Transporta declarações verificáveis entre sistemas em formato compacto.",
				"opcoes": ["JWT", "OLTP", "Amostragem", "Polimorfismo", "Data Mart"],
				"correta": "JWT",
				"explanation": "JWT significa JSON Web Token. Ele é usado para representar claims, como identidade e permissões, mas precisa de expiração, assinatura e armazenamento seguro."
			},
			{
				"id": "stop_dificil_devops_observabilidade_28",
				"topic": "DevOps",
				"categoria": "DevOps",
				"letra": "O",
				"dica": "Permite entender o estado interno do sistema a partir de logs, métricas e traces.",
				"opcoes": ["Observabilidade", "Star Schema", "Feature Engineering", "Scrum", "OAuth 2.0"],
				"correta": "Observabilidade",
				"explanation": "Observabilidade combina sinais como logs, métricas e rastreamento distribuído. Ela ajuda a investigar falhas, gargalos e comportamento em produção."
			},
			{
				"id": "stop_dificil_devops_e_cloud_iac_29",
				"topic": "DevOps e Cloud",
				"categoria": "DevOps e Cloud",
				"letra": "I",
				"dica": "Gerencia infraestrutura por arquivos versionáveis em vez de configuração manual.",
				"opcoes": ["IaC", "Granularidade", "Acoplamento", "COBIT", "JWT"],
				"correta": "IaC",
				"explanation": "IaC significa Infrastructure as Code, ou Infraestrutura como Código. Ela torna ambientes reproduzíveis, auditáveis e menos dependentes de configuração manual."
			},
			{
				"id": "stop_dificil_lgpd_e_etica_privacidade_por_design_30",
				"topic": "LGPD e Ética",
				"categoria": "LGPD e Ética",
				"letra": "P",
				"dica": "Inclui proteção de dados desde a concepção do sistema, não apenas no fim do projeto.",
				"opcoes": ["Privacidade por Design", "Metadados", "Coesão", "ITIL", "Observabilidade"],
				"correta": "Privacidade por Design",
				"explanation": "Privacidade por design coloca proteção de dados no planejamento, arquitetura e operação. Ela se relaciona com minimização, finalidade, segurança e transparência."
			}
		]
	},
	"forca_tecnica": {
		"facil": [
			{
				"id": "forca_facil_desenvolvimento_web_html_01",
				"topic": "Desenvolvimento Web",
				"word": "HTML",
				"area": "Desenvolvimento Web",
				"hint": "Estrutura o conteúdo de páginas web usando marcações como títulos, parágrafos, links e seções.",
				"explanation": "HTML significa HyperText Markup Language, ou Linguagem de Marcação de Hipertexto. Ele define a estrutura semântica de uma página web, como títulos, textos, listas, links e formulários."
			},
			{
				"id": "forca_facil_front_end_css_02",
				"topic": "Front-end",
				"word": "CSS",
				"area": "Front-end",
				"hint": "Controla cores, espaçamentos, fontes e layout visual de uma página web.",
				"explanation": "CSS significa Cascading Style Sheets, ou Folhas de Estilo em Cascata. Ele separa a apresentação visual da estrutura HTML e permite criar interfaces responsivas e organizadas."
			},
			{
				"id": "forca_facil_programacao_web_javascript_03",
				"topic": "Programação Web",
				"word": "JavaScript",
				"area": "Programação Web",
				"hint": "Adiciona comportamento dinâmico em páginas e aplicações web.",
				"explanation": "JavaScript é uma linguagem de programação muito usada no navegador e também no back-end. Ela permite validar formulários, manipular o DOM, consumir APIs e criar interações dinâmicas."
			},
			{
				"id": "forca_facil_back_end_api_04",
				"topic": "Back-end",
				"word": "API",
				"area": "Back-end",
				"hint": "Permite que sistemas diferentes se comuniquem por meio de regras e pontos de acesso definidos.",
				"explanation": "API significa Application Programming Interface, ou Interface de Programação de Aplicações. Ela expõe funcionalidades para que sistemas, aplicativos ou serviços troquem dados de forma padronizada."
			},
			{
				"id": "forca_facil_banco_de_dados_banco_de_dados_05",
				"topic": "Banco de Dados",
				"word": "Banco de Dados",
				"area": "Banco de Dados",
				"hint": "Organiza e armazena dados para consulta, atualização e uso por sistemas.",
				"explanation": "Banco de dados é uma estrutura usada para armazenar informações de forma persistente. Em sistemas de informação, ele sustenta cadastros, transações, consultas e relatórios."
			},
			{
				"id": "forca_facil_sql_select_06",
				"topic": "SQL",
				"word": "SELECT",
				"area": "SQL",
				"hint": "Recupera registros de tabelas em um banco de dados relacional.",
				"explanation": "SELECT é um comando da linguagem SQL usado para consultar dados. Ele pode ser combinado com WHERE, JOIN, GROUP BY e ORDER BY para filtrar, relacionar e ordenar resultados."
			},
			{
				"id": "forca_facil_estruturas_de_dados_pilha_07",
				"topic": "Estruturas de Dados",
				"word": "Pilha",
				"area": "Estruturas de Dados",
				"hint": "Organiza dados no padrão em que o último elemento inserido é o primeiro a sair.",
				"explanation": "Pilha é uma estrutura de dados baseada em LIFO, Last In, First Out. Ela aparece em chamadas de funções, desfazer ações e controle de execução."
			},
			{
				"id": "forca_facil_estruturas_de_dados_fila_08",
				"topic": "Estruturas de Dados",
				"word": "Fila",
				"area": "Estruturas de Dados",
				"hint": "Organiza dados no padrão em que o primeiro elemento inserido é o primeiro a sair.",
				"explanation": "Fila é uma estrutura de dados baseada em FIFO, First In, First Out. Ela é útil em atendimento, processamento de tarefas e filas de mensagens."
			},
			{
				"id": "forca_facil_seguranca_da_informacao_backup_09",
				"topic": "Segurança da Informação",
				"word": "Backup",
				"area": "Segurança da Informação",
				"hint": "Preserva cópias de dados para recuperação após falhas, exclusões ou incidentes.",
				"explanation": "Backup é uma cópia de segurança dos dados. Ele reduz perdas em falhas, ataques, erros humanos e desastres, mas precisa ser testado para garantir restauração."
			},
			{
				"id": "forca_facil_ciberseguranca_mfa_10",
				"topic": "Cibersegurança",
				"word": "MFA",
				"area": "Cibersegurança",
				"hint": "Exige mais de uma evidência para confirmar a identidade de um usuário.",
				"explanation": "MFA significa Multi-Factor Authentication, ou Autenticação Multifator. Ele combina fatores como senha, aplicativo, biometria ou token para reduzir o risco de acesso indevido."
			},
			{
				"id": "forca_facil_ux_ihc_ux_11",
				"topic": "UX/IHC",
				"word": "UX",
				"area": "UX/IHC",
				"hint": "Avalia como uma pessoa percebe, entende e utiliza um produto ou serviço digital.",
				"explanation": "UX significa User Experience, ou Experiência do Usuário. Ela envolve utilidade, facilidade de uso, eficiência, emoção, contexto e satisfação durante a interação."
			},
			{
				"id": "forca_facil_ihc_acessibilidade_12",
				"topic": "IHC",
				"word": "Acessibilidade",
				"area": "IHC",
				"hint": "Remove barreiras para que pessoas com diferentes capacidades consigam usar sistemas.",
				"explanation": "Acessibilidade busca tornar produtos digitais utilizáveis por mais pessoas. Ela envolve contraste, navegação por teclado, texto alternativo, leitores de tela e linguagem clara."
			},
			{
				"id": "forca_facil_fundamentos_de_computacao_algoritmo_13",
				"topic": "Fundamentos de Computação",
				"word": "Algoritmo",
				"area": "Fundamentos de Computação",
				"hint": "Define uma sequência finita e ordenada de passos para resolver um problema.",
				"explanation": "Algoritmo é um conjunto de instruções lógicas para chegar a uma solução. Ele pode ser representado em linguagem natural, fluxograma, pseudocódigo ou código."
			},
			{
				"id": "forca_facil_programacao_variavel_14",
				"topic": "Programação",
				"word": "Variável",
				"area": "Programação",
				"hint": "Armazena temporariamente valores usados por um programa durante sua execução.",
				"explanation": "Variável é um nome associado a um valor em memória. Ela permite guardar dados como números, textos, estados e resultados intermediários."
			},
			{
				"id": "forca_facil_programacao_funcao_15",
				"topic": "Programação",
				"word": "Função",
				"area": "Programação",
				"hint": "Reúne instruções reutilizáveis para executar uma tarefa específica.",
				"explanation": "Função organiza o código em blocos menores e reutilizáveis. Ela melhora leitura, manutenção, testes e evita repetição desnecessária."
			},
			{
				"id": "forca_facil_devops_git_16",
				"topic": "DevOps",
				"word": "Git",
				"area": "DevOps",
				"hint": "Registra histórico de alterações e ajuda equipes a colaborarem no código.",
				"explanation": "Git é um sistema de controle de versão distribuído. Ele permite criar branches, revisar mudanças, voltar versões e colaborar com mais segurança."
			},
			{
				"id": "forca_facil_arquitetura_web_cliente_17",
				"topic": "Arquitetura Web",
				"word": "Cliente",
				"area": "Arquitetura Web",
				"hint": "Representa o lado que solicita serviços, páginas ou dados a outro sistema.",
				"explanation": "Cliente é o componente que consome um serviço, como navegador, aplicativo mobile ou sistema externo. Ele envia requisições para um servidor."
			},
			{
				"id": "forca_facil_arquitetura_web_servidor_18",
				"topic": "Arquitetura Web",
				"word": "Servidor",
				"area": "Arquitetura Web",
				"hint": "Processa requisições e entrega páginas, dados ou serviços para clientes.",
				"explanation": "Servidor é o componente que recebe requisições, executa regras de negócio, consulta dados e envia respostas para clientes ou outros sistemas."
			},
			{
				"id": "forca_facil_redes_rede_19",
				"topic": "Redes",
				"word": "Rede",
				"area": "Redes",
				"hint": "Permite comunicação e compartilhamento de recursos entre dispositivos.",
				"explanation": "Rede de computadores conecta dispositivos para troca de dados. Ela pode usar protocolos, endereços, roteadores, switches e serviços como DNS e HTTP."
			},
			{
				"id": "forca_facil_redes_dns_20",
				"topic": "Redes",
				"word": "DNS",
				"area": "Redes",
				"hint": "Traduz nomes de domínio em endereços ip usados na comunicação de rede.",
				"explanation": "DNS significa Domain Name System, ou Sistema de Nomes de Domínio. Ele permite acessar sites por nomes como exemplo.com em vez de memorizar endereços IP."
			},
			{
				"id": "forca_facil_ciberseguranca_firewall_21",
				"topic": "Cibersegurança",
				"word": "Firewall",
				"area": "Cibersegurança",
				"hint": "Controla tráfego de rede usando regras de permissão e bloqueio.",
				"explanation": "Firewall é um mecanismo de segurança que filtra comunicações. Ele pode bloquear conexões suspeitas, limitar portas e reduzir exposição de serviços."
			},
			{
				"id": "forca_facil_engenharia_de_software_requisito_22",
				"topic": "Engenharia de Software",
				"word": "Requisito",
				"area": "Engenharia de Software",
				"hint": "Descreve uma necessidade, função ou restrição que o sistema deve atender.",
				"explanation": "Requisito registra o que o sistema precisa fazer ou respeitar. Pode ser funcional, quando descreve uma função, ou não funcional, quando descreve qualidade ou restrição."
			},
			{
				"id": "forca_facil_qualidade_de_software_teste_23",
				"topic": "Qualidade de Software",
				"word": "Teste",
				"area": "Qualidade de Software",
				"hint": "Verifica se o software funciona conforme esperado e ajuda a encontrar defeitos.",
				"explanation": "Teste de software reduz riscos ao verificar comportamentos esperados. Ele pode ser manual, automatizado, unitário, funcional, regressivo ou de integração."
			},
			{
				"id": "forca_facil_qualidade_de_software_bug_24",
				"topic": "Qualidade de Software",
				"word": "Bug",
				"area": "Qualidade de Software",
				"hint": "Representa um defeito que faz o sistema agir diferente do esperado.",
				"explanation": "Bug é uma falha ou defeito no software. Ele pode surgir por erro de lógica, requisito mal interpretado, integração incorreta ou dados inesperados."
			},
			{
				"id": "forca_facil_business_intelligence_dashboard_25",
				"topic": "Business Intelligence",
				"word": "Dashboard",
				"area": "Business Intelligence",
				"hint": "Reúne gráficos e indicadores para apoiar acompanhamento e decisão.",
				"explanation": "Dashboard é um painel visual com métricas, gráficos e indicadores. Em BI, ele ajuda a transformar dados em leitura rápida para gestão e acompanhamento."
			},
			{
				"id": "forca_facil_ciencia_de_dados_dataframe_26",
				"topic": "Ciência de Dados",
				"word": "DataFrame",
				"area": "Ciência de Dados",
				"hint": "Representa dados em formato de tabela com linhas e colunas no pandas.",
				"explanation": "DataFrame é a estrutura bidimensional do Pandas. Ele organiza dados como uma tabela, permitindo filtros, agrupamentos, junções, limpeza e análise exploratória."
			},
			{
				"id": "forca_facil_ciencia_de_dados_series_27",
				"topic": "Ciência de Dados",
				"word": "Series",
				"area": "Ciência de Dados",
				"hint": "Representa uma sequência unidimensional de dados no pandas, parecida com uma coluna.",
				"explanation": "Series é uma estrutura unidimensional do Pandas, formada por valores e índice. Uma coluna de um DataFrame pode ser tratada como uma Series."
			},
			{
				"id": "forca_facil_ciencia_de_dados_limpeza_de_dados_28",
				"topic": "Ciência de Dados",
				"word": "Limpeza de Dados",
				"area": "Ciência de Dados",
				"hint": "Trata valores ausentes, duplicados, tipos errados e inconsistências antes da análise.",
				"explanation": "Limpeza de dados prepara uma base para análise confiável. Em projetos reais, essa etapa costuma consumir muito tempo porque dados chegam incompletos, duplicados ou fora de padrão."
			},
			{
				"id": "forca_facil_lgpd_e_privacidade_lgpd_29",
				"topic": "LGPD e Privacidade",
				"word": "LGPD",
				"area": "LGPD e Privacidade",
				"hint": "Define regras brasileiras para tratamento de dados pessoais.",
				"explanation": "LGPD significa Lei Geral de Proteção de Dados. Ela regula coleta, uso, armazenamento e compartilhamento de dados pessoais no Brasil."
			},
			{
				"id": "forca_facil_programacao_orientada_a_objetos_poo_30",
				"topic": "Programação Orientada a Objetos",
				"word": "POO",
				"area": "Programação Orientada a Objetos",
				"hint": "Organiza programas em classes, objetos, atributos e métodos.",
				"explanation": "POO significa Programação Orientada a Objetos. Ela modela o software com objetos que possuem dados e comportamentos, favorecendo organização e reutilização."
			}
		],
		"normal": [
			{
				"id": "forca_normal_ciberseguranca_autenticacao_01",
				"topic": "Cibersegurança",
				"word": "Autenticação",
				"area": "Cibersegurança",
				"hint": "Confirma se o usuário ou sistema realmente é quem afirma ser.",
				"explanation": "Autenticação verifica identidade por senha, biometria, token ou outro fator. Ela responde à pergunta: quem é você?"
			},
			{
				"id": "forca_normal_ciberseguranca_autorizacao_02",
				"topic": "Cibersegurança",
				"word": "Autorização",
				"area": "Cibersegurança",
				"hint": "Define quais recursos e ações um usuário autenticado pode acessar.",
				"explanation": "Autorização ocorre depois da autenticação. Ela controla permissões e responde: o que este usuário pode fazer?"
			},
			{
				"id": "forca_normal_desenvolvimento_web_api_rest_03",
				"topic": "Desenvolvimento Web",
				"word": "API REST",
				"area": "Desenvolvimento Web",
				"hint": "Usa recursos, urls e métodos http para comunicação entre sistemas.",
				"explanation": "API REST segue princípios de Representational State Transfer. Ela costuma usar métodos HTTP como GET, POST, PUT e DELETE para manipular recursos."
			},
			{
				"id": "forca_normal_desenvolvimento_web_json_04",
				"topic": "Desenvolvimento Web",
				"word": "JSON",
				"area": "Desenvolvimento Web",
				"hint": "Representa dados em formato textual leve, muito usado em apis.",
				"explanation": "JSON significa JavaScript Object Notation. Ele é comum em APIs porque é simples, legível e compatível com várias linguagens."
			},
			{
				"id": "forca_normal_back_end_cache_05",
				"topic": "Back-end",
				"word": "Cache",
				"area": "Back-end",
				"hint": "Guarda dados temporários para reduzir tempo de resposta e carga de processamento.",
				"explanation": "Cache melhora desempenho ao reutilizar dados acessados com frequência. O cuidado é manter validade e evitar entregar informação desatualizada."
			},
			{
				"id": "forca_normal_banco_de_dados_transacao_06",
				"topic": "Banco de Dados",
				"word": "Transação",
				"area": "Banco de Dados",
				"hint": "Agrupa operações que devem ser confirmadas ou desfeitas de forma consistente.",
				"explanation": "Transação protege a consistência dos dados. Se tudo dá certo, ocorre commit; se algo falha, rollback desfaz as alterações."
			},
			{
				"id": "forca_normal_banco_de_dados_indice_07",
				"topic": "Banco de Dados",
				"word": "Índice",
				"area": "Banco de Dados",
				"hint": "Acelera buscas em tabelas, mas pode aumentar custo de escrita e armazenamento.",
				"explanation": "Índice é uma estrutura auxiliar para localizar registros mais rápido. Ele melhora consultas, mas exige equilíbrio porque impacta inserções e atualizações."
			},
			{
				"id": "forca_normal_banco_de_dados_chave_estrangeira_08",
				"topic": "Banco de Dados",
				"word": "Chave Estrangeira",
				"area": "Banco de Dados",
				"hint": "Cria vínculo entre tabelas e preserva integridade referencial.",
				"explanation": "Chave estrangeira referencia a chave primária de outra tabela. Ela ajuda a evitar relacionamentos inválidos entre registros."
			},
			{
				"id": "forca_normal_modelagem_de_dados_diagrama_er_09",
				"topic": "Modelagem de Dados",
				"word": "Diagrama ER",
				"area": "Modelagem de Dados",
				"hint": "Representa entidades, atributos e relacionamentos de um domínio.",
				"explanation": "Diagrama ER significa Entidade-Relacionamento. Ele apoia a modelagem conceitual de bancos de dados antes da criação das tabelas."
			},
			{
				"id": "forca_normal_banco_de_dados_normalizacao_10",
				"topic": "Banco de Dados",
				"word": "Normalização",
				"area": "Banco de Dados",
				"hint": "Organiza tabelas para reduzir redundância e anomalias de atualização.",
				"explanation": "Normalização aplica formas normais para melhorar consistência no banco relacional. Ela reduz repetição indevida, mas pode exigir joins mais frequentes."
			},
			{
				"id": "forca_normal_redes_roteamento_11",
				"topic": "Redes",
				"word": "Roteamento",
				"area": "Redes",
				"hint": "Define o caminho que pacotes percorrem entre origem e destino.",
				"explanation": "Roteamento encaminha pacotes entre redes. Roteadores usam tabelas e protocolos para escolher o melhor caminho disponível."
			},
			{
				"id": "forca_normal_redes_e_web_http_12",
				"topic": "Redes e Web",
				"word": "HTTP",
				"area": "Redes e Web",
				"hint": "Protocolo usado para comunicação entre clientes e servidores web.",
				"explanation": "HTTP significa HyperText Transfer Protocol. Ele define requisições e respostas na web, usando métodos como GET e POST."
			},
			{
				"id": "forca_normal_redes_e_seguranca_https_13",
				"topic": "Redes e Segurança",
				"word": "HTTPS",
				"area": "Redes e Segurança",
				"hint": "Protege a comunicação web com criptografia sobre tls.",
				"explanation": "HTTPS significa HyperText Transfer Protocol Secure. Ele usa TLS para proteger confidencialidade, integridade e autenticidade da comunicação."
			},
			{
				"id": "forca_normal_redes_e_seguranca_vpn_14",
				"topic": "Redes e Segurança",
				"word": "VPN",
				"area": "Redes e Segurança",
				"hint": "Cria um túnel seguro para acesso remoto ou conexão entre redes.",
				"explanation": "VPN significa Virtual Private Network, ou Rede Privada Virtual. Ela protege tráfego e permite acesso seguro a recursos internos."
			},
			{
				"id": "forca_normal_ciberseguranca_hash_15",
				"topic": "Cibersegurança",
				"word": "Hash",
				"area": "Cibersegurança",
				"hint": "Gera um resumo de tamanho fixo a partir de dados de entrada.",
				"explanation": "Hash é uma função que transforma dados em um resumo. É usado para integridade e armazenamento seguro de senhas quando combinado com salting e boas práticas."
			},
			{
				"id": "forca_normal_ciberseguranca_criptografia_16",
				"topic": "Cibersegurança",
				"word": "Criptografia",
				"area": "Cibersegurança",
				"hint": "Transforma dados para que só possam ser compreendidos com chave adequada.",
				"explanation": "Criptografia protege confidencialidade e, em alguns usos, integridade e autenticidade. Ela é base de HTTPS, armazenamento seguro e comunicação protegida."
			},
			{
				"id": "forca_normal_ciberseguranca_sql_injection_17",
				"topic": "Cibersegurança",
				"word": "SQL Injection",
				"area": "Cibersegurança",
				"hint": "Ocorre quando entrada maliciosa manipula comandos sql de uma aplicação.",
				"explanation": "SQL Injection é uma vulnerabilidade de injeção em banco de dados. Validação, consultas parametrizadas e menor privilégio reduzem esse risco."
			},
			{
				"id": "forca_normal_ciberseguranca_xss_18",
				"topic": "Cibersegurança",
				"word": "XSS",
				"area": "Cibersegurança",
				"hint": "Injeta scripts maliciosos em páginas vistas por usuários.",
				"explanation": "XSS significa Cross-Site Scripting. Ele ocorre quando uma aplicação exibe conteúdo não tratado, permitindo execução de scripts no navegador da vítima."
			},
			{
				"id": "forca_normal_ux_ihc_persona_19",
				"topic": "UX/IHC",
				"word": "Persona",
				"area": "UX/IHC",
				"hint": "Representa um perfil fictício baseado em características de usuários reais.",
				"explanation": "Persona ajuda equipes a projetarem pensando em necessidades, dores, objetivos e contexto de uso de grupos de usuários."
			},
			{
				"id": "forca_normal_ux_ihc_heuristicas_de_nielsen_20",
				"topic": "UX/IHC",
				"word": "Heurísticas de Nielsen",
				"area": "UX/IHC",
				"hint": "São princípios usados para avaliar problemas de usabilidade em interfaces.",
				"explanation": "As heurísticas de Nielsen orientam avaliação de interfaces, incluindo feedback, consistência, prevenção de erros e liberdade do usuário."
			},
			{
				"id": "forca_normal_front_end_design_responsivo_21",
				"topic": "Front-end",
				"word": "Design Responsivo",
				"area": "Front-end",
				"hint": "Adapta a interface a diferentes tamanhos de tela e dispositivos.",
				"explanation": "Design responsivo usa layouts flexíveis, media queries e boas práticas de interface para manter usabilidade em celular, tablet e desktop."
			},
			{
				"id": "forca_normal_devops_devops_22",
				"topic": "DevOps",
				"word": "DevOps",
				"area": "DevOps",
				"hint": "Integra desenvolvimento e operações para entregar software com mais qualidade e frequência.",
				"explanation": "DevOps combina cultura, automação e colaboração. Ele reduz atritos entre desenvolvimento, testes, infraestrutura e implantação."
			},
			{
				"id": "forca_normal_devops_pipeline_23",
				"topic": "DevOps",
				"word": "Pipeline",
				"area": "DevOps",
				"hint": "Automatiza etapas como build, testes, análise e deploy.",
				"explanation": "Pipeline organiza o fluxo de entrega de software. Em CI/CD, ele reduz tarefas manuais e torna publicações mais repetíveis."
			},
			{
				"id": "forca_normal_devops_container_24",
				"topic": "DevOps",
				"word": "Container",
				"area": "DevOps",
				"hint": "Empacota aplicação e dependências em ambiente isolado e reproduzível.",
				"explanation": "Container ajuda a executar software de forma consistente entre desenvolvimento, teste e produção. Docker é uma ferramenta comum nesse contexto."
			},
			{
				"id": "forca_normal_devops_ci_cd_25",
				"topic": "DevOps",
				"word": "CI/CD",
				"area": "DevOps",
				"hint": "Automatiza integração, testes e entrega de software.",
				"explanation": "CI/CD significa Continuous Integration e Continuous Delivery/Deployment, ou Integração Contínua e Entrega/Implantação Contínua. Ele reduz erros manuais e acelera entregas."
			},
			{
				"id": "forca_normal_dados_e_bi_etl_26",
				"topic": "Dados e BI",
				"word": "ETL",
				"area": "Dados e BI",
				"hint": "Extrai, transforma e carrega dados para outro ambiente de armazenamento ou análise.",
				"explanation": "ETL significa Extract, Transform and Load, ou Extração, Transformação e Carga. Ele coleta dados, aplica tratamentos e carrega o resultado em bases analíticas, como Data Warehouse."
			},
			{
				"id": "forca_normal_business_intelligence_kpi_27",
				"topic": "Business Intelligence",
				"word": "KPI",
				"area": "Business Intelligence",
				"hint": "Mede desempenho de processos, metas ou resultados importantes para o negócio.",
				"explanation": "KPI significa Key Performance Indicator, ou Indicador-Chave de Desempenho. Ele ajuda a acompanhar objetivos com métricas relevantes e acionáveis."
			},
			{
				"id": "forca_normal_ciencia_de_dados_mineracao_de_dados_28",
				"topic": "Ciência de Dados",
				"word": "Mineração de Dados",
				"area": "Ciência de Dados",
				"hint": "Busca padrões, relações e conhecimento útil em grandes conjuntos de dados.",
				"explanation": "Mineração de dados aplica técnicas para descobrir padrões, agrupamentos, associações ou classificações. Ela pode fazer parte do processo KDD."
			},
			{
				"id": "forca_normal_pandas_e_analise_de_dados_groupby_29",
				"topic": "Pandas e Análise de Dados",
				"word": "GroupBy",
				"area": "Pandas e Análise de Dados",
				"hint": "Agrupa registros no pandas para calcular somas, médias, contagens ou outras agregações.",
				"explanation": "GroupBy é uma operação do Pandas inspirada no padrão split-apply-combine. Ela separa dados por grupos, aplica cálculos e combina os resultados."
			},
			{
				"id": "forca_normal_qualidade_de_dados_padronizacao_de_dados_30",
				"topic": "Qualidade de Dados",
				"word": "Padronização de Dados",
				"area": "Qualidade de Dados",
				"hint": "Coloca valores em formatos consistentes antes da análise.",
				"explanation": "Padronização de dados evita categorias duplicadas e comparações incorretas. Exemplos comuns envolvem datas, nomes, siglas, letras maiúsculas e unidades de medida."
			}
		],
		"dificil": [
			{
				"id": "forca_dificil_business_intelligence_data_warehouse_01",
				"topic": "Business Intelligence",
				"word": "Data Warehouse",
				"area": "Business Intelligence",
				"hint": "Integra dados históricos, orientados por assunto, para apoiar decisões gerenciais.",
				"explanation": "Data Warehouse é um repositório analítico integrado, histórico e não volátil. Ele consolida dados de várias fontes para consultas, indicadores e análises estratégicas."
			},
			{
				"id": "forca_dificil_business_intelligence_data_mart_02",
				"topic": "Business Intelligence",
				"word": "Data Mart",
				"area": "Business Intelligence",
				"hint": "Representa um subconjunto analítico voltado a uma área ou departamento específico.",
				"explanation": "Data Mart é uma parte menor de um Data Warehouse. Ele atende necessidades de uma área, como vendas, financeiro ou recursos humanos."
			},
			{
				"id": "forca_dificil_business_intelligence_olap_03",
				"topic": "Business Intelligence",
				"word": "OLAP",
				"area": "Business Intelligence",
				"hint": "Apoia análise multidimensional de dados históricos e agregados.",
				"explanation": "OLAP significa Online Analytical Processing. Ele é voltado a consultas analíticas, comparações, agregações e exploração de dados para decisão."
			},
			{
				"id": "forca_dificil_banco_de_dados_oltp_04",
				"topic": "Banco de Dados",
				"word": "OLTP",
				"area": "Banco de Dados",
				"hint": "Processa transações operacionais frequentes do dia a dia.",
				"explanation": "OLTP significa Online Transaction Processing. Ele prioriza consistência, rapidez em transações e operações como cadastro, compra, pagamento e atualização."
			},
			{
				"id": "forca_dificil_data_warehouse_star_schema_05",
				"topic": "Data Warehouse",
				"word": "Star Schema",
				"area": "Data Warehouse",
				"hint": "Modela dados analíticos com uma tabela fato central ligada a tabelas dimensão.",
				"explanation": "Star Schema, ou esquema estrela, facilita consultas analíticas. A tabela fato guarda métricas, enquanto dimensões descrevem contexto como tempo, produto e local."
			},
			{
				"id": "forca_dificil_data_warehouse_granularidade_06",
				"topic": "Data Warehouse",
				"word": "Granularidade",
				"area": "Data Warehouse",
				"hint": "Define o nível de detalhe armazenado nos dados de uma tabela fato.",
				"explanation": "Granularidade indica quão detalhado é um dado. Em Data Warehouse, granularidade baixa guarda mais detalhes; granularidade alta guarda dados mais resumidos."
			},
			{
				"id": "forca_dificil_governanca_de_dados_metadados_07",
				"topic": "Governança de Dados",
				"word": "Metadados",
				"area": "Governança de Dados",
				"hint": "Descrevem origem, significado, estrutura e regras dos dados.",
				"explanation": "Metadados são dados sobre dados. Eles ajudam a entender campos, fontes, qualidade, periodicidade, responsáveis e regras de uso."
			},
			{
				"id": "forca_dificil_mineracao_de_dados_kdd_08",
				"topic": "Mineração de Dados",
				"word": "KDD",
				"area": "Mineração de Dados",
				"hint": "Organiza o processo de descoberta de conhecimento em bases de dados.",
				"explanation": "KDD significa Knowledge Discovery in Databases, ou Descoberta de Conhecimento em Bases de Dados. Inclui seleção, limpeza, transformação, mineração e interpretação."
			},
			{
				"id": "forca_dificil_ciencia_de_dados_outlier_09",
				"topic": "Ciência de Dados",
				"word": "Outlier",
				"area": "Ciência de Dados",
				"hint": "Representa um valor muito distante do comportamento esperado dos dados.",
				"explanation": "Outlier pode indicar erro, evento raro ou comportamento relevante. Antes de remover, o analista precisa entender o contexto e o impacto na análise."
			},
			{
				"id": "forca_dificil_estatistica_e_dados_correlacao_10",
				"topic": "Estatística e Dados",
				"word": "Correlação",
				"area": "Estatística e Dados",
				"hint": "Mede associação entre variáveis, mas não prova relação de causa e efeito.",
				"explanation": "Correlação indica se variáveis tendem a variar juntas. Em análise de dados, é importante lembrar que correlação não implica causalidade."
			},
			{
				"id": "forca_dificil_estatistica_e_dados_amostragem_11",
				"topic": "Estatística e Dados",
				"word": "Amostragem",
				"area": "Estatística e Dados",
				"hint": "Seleciona parte dos dados para representar uma população maior.",
				"explanation": "Amostragem reduz custo de coleta e análise, mas precisa ser planejada para evitar vieses e manter representatividade."
			},
			{
				"id": "forca_dificil_ciencia_de_dados_feature_engineering_12",
				"topic": "Ciência de Dados",
				"word": "Feature Engineering",
				"area": "Ciência de Dados",
				"hint": "Cria ou transforma variáveis para melhorar análises e modelos preditivos.",
				"explanation": "Feature Engineering envolve preparar atributos, criar indicadores, transformar escalas e extrair sinais úteis. A qualidade das variáveis influencia fortemente modelos de dados."
			},
			{
				"id": "forca_dificil_engenharia_de_software_acoplamento_13",
				"topic": "Engenharia de Software",
				"word": "Acoplamento",
				"area": "Engenharia de Software",
				"hint": "Mede o grau de dependência entre módulos, classes ou componentes.",
				"explanation": "Baixo acoplamento facilita manutenção, testes e evolução porque reduz dependências entre partes do sistema."
			},
			{
				"id": "forca_dificil_engenharia_de_software_coesao_14",
				"topic": "Engenharia de Software",
				"word": "Coesão",
				"area": "Engenharia de Software",
				"hint": "Mede o quanto responsabilidades internas de um módulo estão relacionadas entre si.",
				"explanation": "Alta coesão é desejável porque mantém componentes focados em uma responsabilidade clara, melhorando entendimento e manutenção."
			},
			{
				"id": "forca_dificil_engenharia_de_software_divida_tecnica_15",
				"topic": "Engenharia de Software",
				"word": "Dívida Técnica",
				"area": "Engenharia de Software",
				"hint": "Representa custo futuro gerado por soluções rápidas, frágeis ou mal planejadas.",
				"explanation": "Dívida técnica surge quando a equipe escolhe atalhos. Se não for controlada, aumenta retrabalho, dificulta manutenção e reduz velocidade de evolução."
			},
			{
				"id": "forca_dificil_arquitetura_de_software_mvc_16",
				"topic": "Arquitetura de Software",
				"word": "MVC",
				"area": "Arquitetura de Software",
				"hint": "Separa responsabilidades entre modelo, visão e controlador.",
				"explanation": "MVC significa Model-View-Controller. Ele organiza dados, interface e fluxo de controle em camadas para reduzir mistura de responsabilidades."
			},
			{
				"id": "forca_dificil_arquitetura_de_software_solid_17",
				"topic": "Arquitetura de Software",
				"word": "SOLID",
				"area": "Arquitetura de Software",
				"hint": "Reúne princípios de design orientado a objetos para reduzir rigidez e facilitar manutenção.",
				"explanation": "SOLID é um conjunto de cinco princípios de projeto de software. Eles orientam responsabilidades claras, baixo acoplamento, extensibilidade e substituição segura."
			},
			{
				"id": "forca_dificil_poo_polimorfismo_18",
				"topic": "POO",
				"word": "Polimorfismo",
				"area": "POO",
				"hint": "Permite que diferentes objetos respondam de formas específicas à mesma operação.",
				"explanation": "Polimorfismo é um princípio da Programação Orientada a Objetos. Ele permite tratar objetos por uma interface comum, mantendo comportamentos especializados."
			},
			{
				"id": "forca_dificil_gestao_de_projetos_scrum_19",
				"topic": "Gestão de Projetos",
				"word": "Scrum",
				"area": "Gestão de Projetos",
				"hint": "Organiza trabalho ágil em eventos, papéis e artefatos para entrega incremental.",
				"explanation": "Scrum é um framework ágil com papéis como Product Owner, Scrum Master e Developers. Ele usa Sprints, Backlog e revisões para adaptação contínua."
			},
			{
				"id": "forca_dificil_governanca_de_ti_cobit_20",
				"topic": "Governança de TI",
				"word": "COBIT",
				"area": "Governança de TI",
				"hint": "Orienta governança e gestão de ti alinhadas aos objetivos do negócio.",
				"explanation": "COBIT significa Control Objectives for Information and Related Technologies. Ele apoia governança, controle, valor, riscos e alinhamento estratégico de TI."
			},
			{
				"id": "forca_dificil_governanca_de_ti_itil_21",
				"topic": "Governança de TI",
				"word": "ITIL",
				"area": "Governança de TI",
				"hint": "Organiza boas práticas para gestão de serviços de ti.",
				"explanation": "ITIL significa Information Technology Infrastructure Library. Ela trata serviços, incidentes, mudanças, problemas, níveis de serviço e melhoria contínua."
			},
			{
				"id": "forca_dificil_governanca_de_ti_sla_22",
				"topic": "Governança de TI",
				"word": "SLA",
				"area": "Governança de TI",
				"hint": "Formaliza níveis de serviço esperados entre provedor e cliente.",
				"explanation": "SLA significa Service Level Agreement, ou Acordo de Nível de Serviço. Ele define metas como disponibilidade, tempo de resposta e prazo de atendimento."
			},
			{
				"id": "forca_dificil_continuidade_de_negocio_rto_e_rpo_23",
				"topic": "Continuidade de Negócio",
				"word": "RTO e RPO",
				"area": "Continuidade de Negócio",
				"hint": "Definem tempo máximo de recuperação e perda máxima aceitável de dados.",
				"explanation": "RTO significa Recovery Time Objective, ou tempo máximo para restaurar o serviço. RPO significa Recovery Point Objective, ou ponto máximo aceitável de perda de dados."
			},
			{
				"id": "forca_dificil_ciberseguranca_zero_trust_24",
				"topic": "Cibersegurança",
				"word": "Zero Trust",
				"area": "Cibersegurança",
				"hint": "Assume que nenhuma conexão deve ser confiável automaticamente.",
				"explanation": "Zero Trust, ou confiança zero, exige verificação contínua de identidade, contexto e permissões. A ideia central é nunca confiar por padrão."
			},
			{
				"id": "forca_dificil_ciberseguranca_menor_privilegio_25",
				"topic": "Cibersegurança",
				"word": "Menor Privilégio",
				"area": "Cibersegurança",
				"hint": "Concede apenas as permissões necessárias para executar uma atividade.",
				"explanation": "O princípio do menor privilégio reduz danos em caso de falha ou invasão. Usuários e sistemas não devem ter acessos além do necessário."
			},
			{
				"id": "forca_dificil_ciberseguranca_oauth_2_0_26",
				"topic": "Cibersegurança",
				"word": "OAuth 2.0",
				"area": "Cibersegurança",
				"hint": "Permite autorização delegada sem compartilhar senha com aplicações terceiras.",
				"explanation": "OAuth 2.0 é um protocolo de autorização. Ele permite que uma aplicação acesse recursos em nome do usuário por meio de tokens controlados."
			},
			{
				"id": "forca_dificil_ciberseguranca_jwt_27",
				"topic": "Cibersegurança",
				"word": "JWT",
				"area": "Cibersegurança",
				"hint": "Transporta declarações verificáveis entre sistemas em formato compacto.",
				"explanation": "JWT significa JSON Web Token. Ele é usado para representar claims, como identidade e permissões, mas precisa de expiração, assinatura e armazenamento seguro."
			},
			{
				"id": "forca_dificil_devops_observabilidade_28",
				"topic": "DevOps",
				"word": "Observabilidade",
				"area": "DevOps",
				"hint": "Permite entender o estado interno do sistema a partir de logs, métricas e traces.",
				"explanation": "Observabilidade combina sinais como logs, métricas e rastreamento distribuído. Ela ajuda a investigar falhas, gargalos e comportamento em produção."
			},
			{
				"id": "forca_dificil_devops_e_cloud_iac_29",
				"topic": "DevOps e Cloud",
				"word": "IaC",
				"area": "DevOps e Cloud",
				"hint": "Gerencia infraestrutura por arquivos versionáveis em vez de configuração manual.",
				"explanation": "IaC significa Infrastructure as Code, ou Infraestrutura como Código. Ela torna ambientes reproduzíveis, auditáveis e menos dependentes de configuração manual."
			},
			{
				"id": "forca_dificil_lgpd_e_etica_privacidade_por_design_30",
				"topic": "LGPD e Ética",
				"word": "Privacidade por Design",
				"area": "LGPD e Ética",
				"hint": "Inclui proteção de dados desde a concepção do sistema, não apenas no fim do projeto.",
				"explanation": "Privacidade por design coloca proteção de dados no planejamento, arquitetura e operação. Ela se relaciona com minimização, finalidade, segurança e transparência."
			}
		]
	},
	"desvio_logico": {
		"facil": [
			{
				"id": "desvio_facil_web_html_css_01",
				"topic": "Desenvolvimento Web",
				"pergunta": "Uma página precisa estruturar títulos, parágrafos e links. Qual caminho faz mais sentido?",
				"opcoes": {"A": "HTML", "B": "CSS"},
				"resposta": "A",
				"motivos": {
					"A": "HTML significa HyperText Markup Language, ou Linguagem de Marcação de Hipertexto. Ele define a estrutura do conteúdo de páginas web.",
					"B": "CSS cuida da aparência visual, mas não é a base estrutural do conteúdo."
				}
			},
			{
				"id": "desvio_facil_front_css_html_02",
				"topic": "Front-end",
				"pergunta": "A equipe quer mudar cores, fontes e espaçamentos da interface. Qual rota escolher?",
				"opcoes": {"A": "HTML", "B": "CSS"},
				"resposta": "B",
				"motivos": {
					"B": "CSS significa Cascading Style Sheets, ou Folhas de Estilo em Cascata. Ele controla o visual e o layout de páginas web.",
					"A": "HTML estrutura o conteúdo, mas não é o recurso principal para estilização."
				}
			},
			{
				"id": "desvio_facil_js_interacao_03",
				"topic": "Programação Web",
				"pergunta": "O sistema precisa reagir a cliques e validar um formulário no navegador. Qual opção combina mais?",
				"opcoes": {"A": "JavaScript", "B": "SQL"},
				"resposta": "A",
				"motivos": {
					"A": "JavaScript adiciona comportamento dinâmico à página, permitindo eventos, validações, interações e consumo de APIs.",
					"B": "SQL é voltado a consultas em banco de dados, não à interação direta no navegador."
				}
			},
			{
				"id": "desvio_facil_api_comunicacao_04",
				"topic": "Back-end",
				"pergunta": "Um aplicativo precisa conversar com um serviço externo por pontos de acesso definidos. Qual caminho seguir?",
				"opcoes": {"A": "Planilha", "B": "API"},
				"resposta": "B",
				"motivos": {
					"B": "API significa Application Programming Interface. Ela padroniza a comunicação entre sistemas e aplicações.",
					"A": "Planilhas podem organizar dados, mas não definem uma interface de comunicação entre sistemas."
				}
			},
			{
				"id": "desvio_facil_banco_persistencia_05",
				"topic": "Banco de Dados",
				"pergunta": "O projeto precisa guardar cadastros para consulta futura. Qual decisão é mais adequada?",
				"opcoes": {"A": "Banco de Dados", "B": "Variável"},
				"resposta": "A",
				"motivos": {
					"A": "Banco de dados armazena informações de forma persistente para consulta, atualização e relatórios.",
					"B": "Variáveis guardam dados temporários durante a execução do programa."
				}
			},
			{
				"id": "desvio_facil_select_consulta_06",
				"topic": "SQL",
				"pergunta": "Você precisa recuperar registros de uma tabela. Qual comando seguir?",
				"opcoes": {"A": "DROP", "B": "SELECT"},
				"resposta": "B",
				"motivos": {
					"B": "SELECT consulta dados em tabelas relacionais. DROP remove estruturas e pode causar perda de objetos do banco.",
					"A": "Essa opção não resolve melhor a situação apresentada."
				}
			},
			{
				"id": "desvio_facil_pilha_fila_07",
				"topic": "Estruturas de Dados",
				"pergunta": "A funcionalidade de desfazer ações precisa acessar primeiro a última ação realizada. Qual estrutura combina?",
				"opcoes": {"A": "Pilha", "B": "Fila"},
				"resposta": "A",
				"motivos": {
					"A": "Pilha usa LIFO, Last In, First Out. O último elemento inserido é o primeiro removido.",
					"B": "Fila usa FIFO, First In, First Out, ideal quando a ordem de chegada deve ser preservada."
				}
			},
			{
				"id": "desvio_facil_fila_pilha_08",
				"topic": "Estruturas de Dados",
				"pergunta": "Chamados devem ser atendidos na ordem em que chegaram. Qual estrutura usar?",
				"opcoes": {"A": "Pilha", "B": "Fila"},
				"resposta": "B",
				"motivos": {
					"B": "Fila usa FIFO, First In, First Out. O primeiro item a entrar é o primeiro a sair.",
					"A": "Pilha prioriza o último item inserido, o que não representa atendimento por ordem de chegada."
				}
			},
			{
				"id": "desvio_facil_backup_risco_09",
				"topic": "Segurança da Informação",
				"pergunta": "A equipe quer reduzir perdas após falhas, exclusões ou incidentes. Qual rota é melhor?",
				"opcoes": {"A": "Backup", "B": "Remover logs"},
				"resposta": "A",
				"motivos": {
					"A": "Backup mantém cópias de segurança para recuperação. Ele deve ser testado para garantir restauração.",
					"B": "Remover logs reduz rastreabilidade e não recupera dados perdidos."
				}
			},
			{
				"id": "desvio_facil_mfa_senha_10",
				"topic": "Cibersegurança",
				"pergunta": "Para proteger contas além da senha, qual decisão é mais segura?",
				"opcoes": {"A": "Senha única compartilhada", "B": "MFA"},
				"resposta": "B",
				"motivos": {
					"B": "MFA significa Multi-Factor Authentication, ou Autenticação Multifator. Ele exige mais de uma evidência de identidade.",
					"A": "Compartilhar senha aumenta o risco de acesso indevido e dificulta auditoria."
				}
			},
			{
				"id": "desvio_facil_ux_interface_11",
				"topic": "UX/IHC",
				"pergunta": "A equipe quer melhorar como a pessoa percebe e utiliza o sistema. Qual caminho escolher?",
				"opcoes": {"A": "UX", "B": "Overclock"},
				"resposta": "A",
				"motivos": {
					"A": "UX significa User Experience, ou Experiência do Usuário. Ela analisa percepção, facilidade e satisfação no uso.",
					"B": "Overclock é relacionado a desempenho de hardware, não à experiência da pessoa usuária."
				}
			},
			{
				"id": "desvio_facil_acessibilidade_12",
				"topic": "IHC",
				"pergunta": "Um sistema precisa funcionar melhor para pessoas com diferentes necessidades. Qual rota seguir?",
				"opcoes": {"A": "Ofuscação", "B": "Acessibilidade"},
				"resposta": "B",
				"motivos": {
					"B": "Acessibilidade remove barreiras de uso com contraste, teclado, texto alternativo e suporte a leitores de tela.",
					"A": "Ofuscação dificulta leitura de código e não melhora o acesso das pessoas à interface."
				}
			},
			{
				"id": "desvio_facil_algoritmo_13",
				"topic": "Fundamentos de Computação",
				"pergunta": "Para resolver um problema, o estudante define uma sequência finita de passos. Qual é o conceito?",
				"opcoes": {"A": "Algoritmo", "B": "Firewall"},
				"resposta": "A",
				"motivos": {
					"A": "Algoritmo é uma sequência lógica de instruções para chegar a uma solução.",
					"B": "Firewall filtra tráfego de rede; não representa a sequência de solução de um problema."
				}
			},
			{
				"id": "desvio_facil_variavel_14",
				"topic": "Programação",
				"pergunta": "O programa precisa guardar temporariamente a idade digitada pelo usuário. Qual rota escolher?",
				"opcoes": {"A": "Gateway", "B": "Variável"},
				"resposta": "B",
				"motivos": {
					"B": "Variável é um nome associado a um valor em memória durante a execução do programa.",
					"A": "Gateway conecta redes ou sistemas, não armazena valores temporários do programa."
				}
			},
			{
				"id": "desvio_facil_funcao_15",
				"topic": "Programação",
				"pergunta": "Um trecho de código será reutilizado várias vezes. Qual decisão ajuda mais?",
				"opcoes": {"A": "Função", "B": "Duplicação de código"},
				"resposta": "A",
				"motivos": {
					"A": "Função reúne instruções reutilizáveis, melhora organização e reduz repetição.",
					"B": "Duplicar código aumenta manutenção e risco de inconsistência."
				}
			},
			{
				"id": "desvio_facil_git_16",
				"topic": "DevOps",
				"pergunta": "A equipe quer controlar versões e voltar mudanças quando necessário. Qual caminho seguir?",
				"opcoes": {"A": "Cache", "B": "Git"},
				"resposta": "B",
				"motivos": {
					"B": "Git é um sistema de controle de versão usado para histórico, branches e colaboração.",
					"A": "Cache acelera acesso a dados, mas não gerencia histórico de versões."
				}
			},
			{
				"id": "desvio_facil_cliente_servidor_17",
				"topic": "Arquitetura Web",
				"pergunta": "O navegador que envia uma requisição para a aplicação representa qual papel?",
				"opcoes": {"A": "Cliente", "B": "Servidor"},
				"resposta": "A",
				"motivos": {
					"A": "Cliente é o componente que consome serviços, como navegador, app ou sistema externo.",
					"B": "Servidor processa requisições e responde, mas não é o navegador consumidor."
				}
			},
			{
				"id": "desvio_facil_servidor_cliente_18",
				"topic": "Arquitetura Web",
				"pergunta": "Quem processa uma requisição e envia uma resposta ao navegador?",
				"opcoes": {"A": "Cliente", "B": "Servidor"},
				"resposta": "B",
				"motivos": {
					"B": "Servidor executa regras, consulta dados e responde às solicitações dos clientes.",
					"A": "Cliente inicia a requisição, mas não é o componente principal de processamento da resposta."
				}
			},
			{
				"id": "desvio_facil_dns_19",
				"topic": "Redes",
				"pergunta": "O usuário digita um domínio em vez de um endereço IP. Qual serviço ajuda nisso?",
				"opcoes": {"A": "DNS", "B": "CSS"},
				"resposta": "A",
				"motivos": {
					"A": "DNS significa Domain Name System. Ele traduz nomes de domínio em endereços IP.",
					"B": "CSS controla estilo visual de páginas web e não resolve nomes de domínio."
				}
			},
			{
				"id": "desvio_facil_firewall_20",
				"topic": "Cibersegurança",
				"pergunta": "A rede precisa filtrar conexões suspeitas por regras. Qual caminho seguir?",
				"opcoes": {"A": "Dashboard", "B": "Firewall"},
				"resposta": "B",
				"motivos": {
					"B": "Firewall controla tráfego de rede conforme regras de segurança.",
					"A": "Dashboard visualiza indicadores, mas não bloqueia tráfego suspeito."
				}
			},
			{
				"id": "desvio_facil_requisito_21",
				"topic": "Engenharia de Software",
				"pergunta": "O cliente descreve uma necessidade que o sistema deve atender. Como registrar isso?",
				"opcoes": {"A": "Requisito", "B": "Pixel art"},
				"resposta": "A",
				"motivos": {
					"A": "Requisito define o que o sistema precisa fazer ou respeitar, incluindo funções e restrições.",
					"B": "Pixel art é um estilo visual e não registra necessidades do sistema."
				}
			},
			{
				"id": "desvio_facil_teste_22",
				"topic": "Qualidade de Software",
				"pergunta": "Antes de entregar, a equipe precisa verificar se o comportamento esperado funciona. Qual rota escolher?",
				"opcoes": {"A": "Paleta de cores", "B": "Teste"},
				"resposta": "B",
				"motivos": {
					"B": "Teste de software ajuda a encontrar defeitos e validar comportamentos esperados.",
					"A": "Paleta de cores influencia visual, mas não verifica regras do sistema."
				}
			},
			{
				"id": "desvio_facil_bug_23",
				"topic": "Qualidade de Software",
				"pergunta": "Uma falha faz o sistema agir diferente do esperado. Qual é o termo?",
				"opcoes": {"A": "Bug", "B": "KPI"},
				"resposta": "A",
				"motivos": {
					"A": "Bug é um defeito ou falha no software que causa comportamento incorreto.",
					"B": "KPI é indicador de desempenho, não uma falha de software."
				}
			},
			{
				"id": "desvio_facil_dashboard_24",
				"topic": "BI",
				"pergunta": "A gestão quer acompanhar indicadores por gráficos e cartões visuais. Qual caminho?",
				"opcoes": {"A": "Pilha", "B": "Dashboard"},
				"resposta": "B",
				"motivos": {
					"B": "Dashboard reúne métricas, gráficos e indicadores para leitura rápida e apoio à decisão.",
					"A": "Pilha é uma estrutura de dados e não um painel visual de indicadores."
				}
			},
			{
				"id": "desvio_facil_dataframe_25",
				"topic": "Ciência de Dados",
				"pergunta": "No Pandas, uma tabela com linhas e colunas é representada por qual estrutura?",
				"opcoes": {"A": "DataFrame", "B": "DNS"},
				"resposta": "A",
				"motivos": {
					"A": "DataFrame é uma estrutura bidimensional do Pandas usada para análise tabular.",
					"B": "DNS traduz nomes de domínio e não representa uma tabela de dados."
				}
			},
			{
				"id": "desvio_facil_series_26",
				"topic": "Ciência de Dados",
				"pergunta": "No Pandas, uma coluna unidimensional com índice é chamada de quê?",
				"opcoes": {"A": "Servidor", "B": "Series"},
				"resposta": "B",
				"motivos": {
					"B": "Series é uma estrutura unidimensional do Pandas, formada por valores e índice.",
					"A": "Servidor processa requisições; não é uma estrutura de análise de dados."
				}
			},
			{
				"id": "desvio_facil_limpeza_dados_27",
				"topic": "Ciência de Dados",
				"pergunta": "Dados chegaram duplicados, incompletos e fora de padrão. Qual etapa vem antes da análise?",
				"opcoes": {"A": "Limpeza de Dados", "B": "Deploy direto"},
				"resposta": "A",
				"motivos": {
					"A": "Limpeza de dados trata ausências, duplicidades e formatos para tornar a análise confiável.",
					"B": "Deploy direto colocaria uma solução em operação sem preparar corretamente os dados."
				}
			},
			{
				"id": "desvio_facil_lgpd_28",
				"topic": "LGPD e Privacidade",
				"pergunta": "O sistema coleta dados pessoais no Brasil. Qual lei precisa ser considerada?",
				"opcoes": {"A": "HTTP", "B": "LGPD"},
				"resposta": "B",
				"motivos": {
					"B": "LGPD significa Lei Geral de Proteção de Dados. Ela regula o uso de dados pessoais no Brasil.",
					"A": "HTTP é protocolo de comunicação web; não define regras legais de proteção de dados."
				}
			},
			{
				"id": "desvio_facil_poo_29",
				"topic": "POO",
				"pergunta": "O código será organizado com classes, objetos, atributos e métodos. Qual paradigma é esse?",
				"opcoes": {"A": "POO", "B": "BI"},
				"resposta": "A",
				"motivos": {
					"A": "POO significa Programação Orientada a Objetos. Ela modela sistemas com objetos que possuem dados e comportamentos.",
					"B": "BI apoia decisões com dados, mas não organiza código em classes e objetos."
				}
			},
			{
				"id": "desvio_facil_nuvem_30",
				"topic": "Computação em Nuvem",
				"pergunta": "A aplicação será hospedada em serviços acessados pela internet, com recursos sob demanda. Qual rota?",
				"opcoes": {"A": "Impressora local", "B": "Computação em Nuvem"},
				"resposta": "B",
				"motivos": {
					"B": "Computação em nuvem oferece infraestrutura, plataformas e serviços sob demanda pela internet.",
					"A": "Impressora local é um periférico e não fornece recursos computacionais sob demanda."
				}
			}
		],
		"normal": [
			{
				"id": "desvio_normal_autenticacao_autorizacao_01",
				"topic": "Cibersegurança",
				"pergunta": "O sistema precisa confirmar quem é o usuário antes de liberar acesso. Qual caminho?",
				"opcoes": {"A": "Autenticação", "B": "Autorização"},
				"resposta": "A",
				"motivos": {
					"A": "Autenticação verifica identidade. Ela responde à pergunta: quem é você?",
					"B": "Autorização define permissões depois da identidade ser confirmada."
				}
			},
			{
				"id": "desvio_normal_autorizacao_autenticacao_02",
				"topic": "Cibersegurança",
				"pergunta": "Depois do login, o sistema precisa decidir quais telas o usuário pode acessar. Qual rota?",
				"opcoes": {"A": "Autenticação", "B": "Autorização"},
				"resposta": "B",
				"motivos": {
					"B": "Autorização controla permissões e define o que um usuário autenticado pode fazer.",
					"A": "Autenticação confirma identidade, mas não define níveis de acesso."
				}
			},
			{
				"id": "desvio_normal_api_rest_03",
				"topic": "Desenvolvimento Web",
				"pergunta": "Uma API usa recursos e métodos HTTP como GET, POST, PUT e DELETE. Qual estilo está envolvido?",
				"opcoes": {"A": "API REST", "B": "Planilha local"},
				"resposta": "A",
				"motivos": {
					"A": "API REST aplica princípios de Representational State Transfer para manipular recursos por HTTP.",
					"B": "Planilha local não define um estilo arquitetural para serviços web."
				}
			},
			{
				"id": "desvio_normal_json_xml_04",
				"topic": "Desenvolvimento Web",
				"pergunta": "A aplicação web precisa trocar dados leves e fáceis de consumir por JavaScript. Qual formato tende a ser mais usado?",
				"opcoes": {"A": "DOCX", "B": "JSON"},
				"resposta": "B",
				"motivos": {
					"B": "JSON significa JavaScript Object Notation. Ele é leve, legível e comum em APIs.",
					"A": "DOCX é formato de documento, não um formato típico para troca de dados em APIs."
				}
			},
			{
				"id": "desvio_normal_cache_desempenho_05",
				"topic": "Back-end",
				"pergunta": "Uma consulta pesada é repetida muitas vezes. Qual solução pode melhorar o desempenho?",
				"opcoes": {"A": "Cache", "B": "Repetir consulta sempre"},
				"resposta": "A",
				"motivos": {
					"A": "Cache armazena resultados frequentes temporariamente, reduzindo tempo de resposta e carga.",
					"B": "Repetir a consulta sem otimização mantém o custo alto a cada acesso."
				}
			},
			{
				"id": "desvio_normal_transacao_06",
				"topic": "Banco de Dados",
				"pergunta": "Um pagamento precisa confirmar várias operações ou desfazer tudo se houver erro. Qual conceito usar?",
				"opcoes": {"A": "Estilo CSS", "B": "Transação"},
				"resposta": "B",
				"motivos": {
					"B": "Transação agrupa operações com consistência. Commit confirma e rollback desfaz em caso de falha.",
					"A": "CSS controla aparência visual e não garante consistência de operações no banco."
				}
			},
			{
				"id": "desvio_normal_indice_07",
				"topic": "Banco de Dados",
				"pergunta": "Uma tabela grande está lenta em buscas por CPF. Qual estrutura pode ajudar?",
				"opcoes": {"A": "Índice", "B": "Comentário no código"},
				"resposta": "A",
				"motivos": {
					"A": "Índice acelera consultas em colunas usadas para busca, filtro ou ordenação.",
					"B": "Comentário ajuda documentação, mas não otimiza busca no banco."
				}
			},
			{
				"id": "desvio_normal_chave_estrangeira_08",
				"topic": "Banco de Dados",
				"pergunta": "Uma tabela de pedidos precisa referenciar clientes cadastrados. Qual recurso relacional usar?",
				"opcoes": {"A": "Cor primária", "B": "Chave estrangeira"},
				"resposta": "B",
				"motivos": {
					"B": "Chave estrangeira cria referência entre tabelas e preserva integridade relacional.",
					"A": "Cor primária é conceito visual, não vínculo entre tabelas."
				}
			},
			{
				"id": "desvio_normal_diagrama_er_09",
				"topic": "Modelagem de Dados",
				"pergunta": "Antes de criar tabelas, a equipe quer representar entidades e relacionamentos. Qual caminho?",
				"opcoes": {"A": "Diagrama ER", "B": "Teste de carga"},
				"resposta": "A",
				"motivos": {
					"A": "Diagrama ER representa entidades, atributos e relacionamentos na modelagem de dados.",
					"B": "Teste de carga avalia desempenho, não modelagem conceitual de dados."
				}
			},
			{
				"id": "desvio_normal_normalizacao_10",
				"topic": "Banco de Dados",
				"pergunta": "As tabelas possuem dados repetidos e inconsistências. Qual técnica ajuda a organizar melhor?",
				"opcoes": {"A": "Hardcode", "B": "Normalização"},
				"resposta": "B",
				"motivos": {
					"B": "Normalização organiza tabelas para reduzir redundância e anomalias de atualização.",
					"A": "Hardcode fixa valores no código e pode aumentar manutenção e inconsistência."
				}
			},
			{
				"id": "desvio_normal_roteamento_11",
				"topic": "Redes",
				"pergunta": "Pacotes precisam escolher caminhos entre redes até o destino. Qual processo está envolvido?",
				"opcoes": {"A": "Roteamento", "B": "Renderização"},
				"resposta": "A",
				"motivos": {
					"A": "Roteamento define o caminho de pacotes entre redes, geralmente por roteadores.",
					"B": "Renderização desenha elementos na tela e não escolhe caminho de pacotes."
				}
			},
			{
				"id": "desvio_normal_https_12",
				"topic": "Redes e Segurança",
				"pergunta": "A comunicação web deve proteger dados em trânsito. Qual opção é mais adequada?",
				"opcoes": {"A": "HTTP sem criptografia", "B": "HTTPS"},
				"resposta": "B",
				"motivos": {
					"B": "HTTPS usa HTTP sobre TLS para proteger confidencialidade e integridade da comunicação.",
					"A": "HTTP sem criptografia expõe dados a interceptação em redes inseguras."
				}
			},
			{
				"id": "desvio_normal_vpn_13",
				"topic": "Redes e Segurança",
				"pergunta": "Um colaborador remoto precisa acessar recursos internos com túnel protegido. Qual rota?",
				"opcoes": {"A": "VPN", "B": "Planilha pública"},
				"resposta": "A",
				"motivos": {
					"A": "VPN significa Virtual Private Network. Ela cria um túnel seguro entre usuário e rede.",
					"B": "Planilha pública pode expor dados e não cria canal seguro."
				}
			},
			{
				"id": "desvio_normal_hash_14",
				"topic": "Cibersegurança",
				"pergunta": "A senha não deve ser guardada em texto claro. Qual técnica é melhor para armazenar verificação?",
				"opcoes": {"A": "Salvar senha pura", "B": "Hash com sal"},
				"resposta": "B",
				"motivos": {
					"B": "Hash com sal reduz risco ao armazenar uma representação não reversível da senha.",
					"A": "Salvar senha pura expõe credenciais se a base vazar."
				}
			},
			{
				"id": "desvio_normal_sql_injection_15",
				"topic": "Cibersegurança",
				"pergunta": "Entradas do usuário são concatenadas direto em SQL. Qual risco aparece?",
				"opcoes": {"A": "SQL Injection", "B": "Acessibilidade"},
				"resposta": "A",
				"motivos": {
					"A": "SQL Injection ocorre quando entradas maliciosas alteram comandos SQL. Consultas parametrizadas reduzem o risco.",
					"B": "Acessibilidade melhora uso por pessoas, mas não descreve esse ataque."
				}
			},
			{
				"id": "desvio_normal_xss_16",
				"topic": "Cibersegurança Web",
				"pergunta": "Um campo aceita script e depois executa no navegador de outros usuários. Qual risco é esse?",
				"opcoes": {"A": "Backup incremental", "B": "XSS"},
				"resposta": "B",
				"motivos": {
					"B": "XSS significa Cross-Site Scripting. Ele injeta scripts em páginas vistas por outros usuários.",
					"A": "Backup incremental protege cópias de dados, mas não descreve execução de scripts no navegador."
				}
			},
			{
				"id": "desvio_normal_persona_17",
				"topic": "UX/IHC",
				"pergunta": "A equipe cria um perfil fictício baseado em usuários reais para orientar decisões de design. Qual conceito?",
				"opcoes": {"A": "Persona", "B": "Dockerfile"},
				"resposta": "A",
				"motivos": {
					"A": "Persona resume características, objetivos e dores de usuários para guiar decisões de UX.",
					"B": "Dockerfile descreve imagem de container, não perfil de usuário."
				}
			},
			{
				"id": "desvio_normal_jornada_usuario_18",
				"topic": "UX/IHC",
				"pergunta": "A equipe quer mapear passos, emoções e pontos de dor durante o uso do serviço. Qual caminho?",
				"opcoes": {"A": "Normalização de tabelas", "B": "Jornada do Usuário"},
				"resposta": "B",
				"motivos": {
					"B": "Jornada do usuário mostra etapas e experiências ao interagir com um produto ou serviço.",
					"A": "Normalização organiza bancos relacionais, não experiências de uso."
				}
			},
			{
				"id": "desvio_normal_ci_cd_19",
				"topic": "DevOps",
				"pergunta": "A equipe quer automatizar build, testes e entrega com frequência. Qual prática é adequada?",
				"opcoes": {"A": "CI/CD", "B": "Copiar arquivos manualmente"},
				"resposta": "A",
				"motivos": {
					"A": "CI/CD significa Continuous Integration e Continuous Delivery/Deployment. Automatiza integração, testes e entrega.",
					"B": "Copiar arquivos manualmente aumenta risco de erro e reduz rastreabilidade."
				}
			},
			{
				"id": "desvio_normal_container_20",
				"topic": "DevOps",
				"pergunta": "A aplicação precisa rodar com dependências empacotadas de forma reproduzível. Qual caminho?",
				"opcoes": {"A": "Papel impresso", "B": "Container"},
				"resposta": "B",
				"motivos": {
					"B": "Containers empacotam aplicação e dependências para execução consistente entre ambientes.",
					"A": "Papel impresso não reproduz ambiente de execução."
				}
			},
			{
				"id": "desvio_normal_datawarehouse_21",
				"topic": "BI/Data Warehouse",
				"pergunta": "A empresa quer consolidar dados históricos para análise gerencial. Qual estrutura combina?",
				"opcoes": {"A": "Data Warehouse", "B": "Banco temporário isolado"},
				"resposta": "A",
				"motivos": {
					"A": "Data Warehouse centraliza dados históricos integrados para consultas analíticas e BI.",
					"B": "Banco temporário isolado não consolida histórico corporativo de forma analítica."
				}
			},
			{
				"id": "desvio_normal_olap_oltp_22",
				"topic": "BI/Data Warehouse",
				"pergunta": "Consultas analíticas multidimensionais para decisão gerencial combinam mais com qual abordagem?",
				"opcoes": {"A": "OLTP", "B": "OLAP"},
				"resposta": "B",
				"motivos": {
					"B": "OLAP significa Online Analytical Processing e apoia análises agregadas e multidimensionais.",
					"A": "OLTP significa Online Transaction Processing e é voltado a operações transacionais do dia a dia."
				}
			},
			{
				"id": "desvio_normal_kpi_23",
				"topic": "BI",
				"pergunta": "A gestão quer medir desempenho com indicador acompanhado ao longo do tempo. Qual termo usar?",
				"opcoes": {"A": "KPI", "B": "Bug"},
				"resposta": "A",
				"motivos": {
					"A": "KPI significa Key Performance Indicator, ou Indicador-Chave de Desempenho. Ele acompanha objetivos importantes.",
					"B": "Bug é falha de software, não indicador gerencial."
				}
			},
			{
				"id": "desvio_normal_groupby_24",
				"topic": "Pandas",
				"pergunta": "No Pandas, você precisa agrupar vendas por cidade e somar valores. Qual operação ajuda?",
				"opcoes": {"A": "drop database", "B": "groupby"},
				"resposta": "B",
				"motivos": {
					"B": "groupby agrupa dados por uma ou mais colunas para aplicar agregações como soma, média e contagem.",
					"A": "DROP DATABASE remove um banco de dados e é perigoso nesse contexto."
				}
			},
			{
				"id": "desvio_normal_merge_25",
				"topic": "Pandas",
				"pergunta": "Duas tabelas precisam ser combinadas por uma chave comum. Qual função do Pandas é mais adequada?",
				"opcoes": {"A": "merge", "B": "print"},
				"resposta": "A",
				"motivos": {
					"A": "merge combina DataFrames por chaves, semelhante a joins em bancos relacionais.",
					"B": "print exibe informação, mas não combina tabelas."
				}
			},
			{
				"id": "desvio_normal_outlier_26",
				"topic": "Ciência de Dados",
				"pergunta": "Um valor muito distante dos demais pode distorcer médias. Como ele é chamado?",
				"opcoes": {"A": "Endpoint", "B": "Outlier"},
				"resposta": "B",
				"motivos": {
					"B": "Outlier é um valor atípico que pode indicar erro, evento raro ou comportamento relevante.",
					"A": "Endpoint é ponto de acesso de API, não valor atípico."
				}
			},
			{
				"id": "desvio_normal_lgpd_finalidade_27",
				"topic": "LGPD e Privacidade",
				"pergunta": "Dados pessoais devem ser coletados para um propósito claro e informado. Qual princípio está ligado a isso?",
				"opcoes": {"A": "Finalidade", "B": "Polimorfismo"},
				"resposta": "A",
				"motivos": {
					"A": "O princípio da finalidade exige propósito legítimo, específico e informado para tratamento de dados.",
					"B": "Polimorfismo é princípio de POO, não regra de tratamento de dados pessoais."
				}
			},
			{
				"id": "desvio_normal_sla_28",
				"topic": "Governança de TI",
				"pergunta": "Um contrato define tempo de resposta e disponibilidade esperada do serviço. Qual termo?",
				"opcoes": {"A": "DOM", "B": "SLA"},
				"resposta": "B",
				"motivos": {
					"B": "SLA significa Service Level Agreement, ou Acordo de Nível de Serviço. Ele define metas mensuráveis de serviço.",
					"A": "DOM representa estrutura de uma página web, não acordo de nível de serviço."
				}
			},
			{
				"id": "desvio_normal_incidente_29",
				"topic": "ITIL/Gestão de Serviços",
				"pergunta": "Um serviço ficou indisponível e precisa ser restaurado rapidamente. Qual processo é acionado?",
				"opcoes": {"A": "Gestão de Incidentes", "B": "Refatoração estética"},
				"resposta": "A",
				"motivos": {
					"A": "Gestão de incidentes busca restaurar o serviço normal o mais rápido possível.",
					"B": "Refatoração melhora estrutura interna do código, mas não é o processo de restauração do serviço."
				}
			},
			{
				"id": "desvio_normal_scrum_30",
				"topic": "Gestão de Projetos",
				"pergunta": "A equipe trabalha em ciclos curtos chamados Sprints. Qual framework combina?",
				"opcoes": {"A": "Waterfall apenas linear", "B": "Scrum"},
				"resposta": "B",
				"motivos": {
					"B": "Scrum organiza trabalho ágil em Sprints, papéis, eventos e artefatos para entrega incremental.",
					"A": "Um modelo estritamente linear não usa Sprints como base."
				}
			}
		],
		"dificil": [
			{
				"id": "desvio_dificil_acoplamento_01",
				"topic": "Engenharia de Software",
				"pergunta": "A equipe quer facilitar testes e evolução reduzindo dependências diretas entre módulos. Qual rota é melhor?",
				"opcoes": {"A": "Baixo acoplamento", "B": "Alto acoplamento"},
				"resposta": "A",
				"motivos": {
					"A": "Baixo acoplamento reduz dependências entre componentes, favorecendo manutenção, testes e evolução.",
					"B": "Alto acoplamento aumenta dependências e torna mudanças mais arriscadas."
				}
			},
			{
				"id": "desvio_dificil_coesao_02",
				"topic": "Engenharia de Software",
				"pergunta": "Um módulo deve ter responsabilidades bem relacionadas entre si. Qual qualidade é desejável?",
				"opcoes": {"A": "Baixa coesão", "B": "Alta coesão"},
				"resposta": "B",
				"motivos": {
					"B": "Alta coesão indica que um módulo tem foco claro e responsabilidades relacionadas.",
					"A": "Baixa coesão mistura responsabilidades e dificulta entendimento e manutenção."
				}
			},
			{
				"id": "desvio_dificil_requisito_nao_funcional_03",
				"topic": "Engenharia de Software",
				"pergunta": "A exigência fala sobre desempenho, segurança e disponibilidade, não sobre uma função específica. Qual tipo é?",
				"opcoes": {"A": "Requisito não funcional", "B": "Caso de teste unitário"},
				"resposta": "A",
				"motivos": {
					"A": "Requisito não funcional define qualidades, restrições e atributos do sistema.",
					"B": "Teste unitário verifica partes do código, mas não classifica esse tipo de exigência."
				}
			},
			{
				"id": "desvio_dificil_mvc_04",
				"topic": "Arquitetura de Software",
				"pergunta": "O sistema precisa separar dados, interface e fluxo de controle. Qual padrão ajuda?",
				"opcoes": {"A": "SQL Injection", "B": "MVC"},
				"resposta": "B",
				"motivos": {
					"B": "MVC separa Model, View e Controller, reduzindo mistura entre dados, interface e controle.",
					"A": "SQL Injection é um ataque, não um padrão de organização de interface e lógica."
				}
			},
			{
				"id": "desvio_dificil_mvvm_05",
				"topic": "Arquitetura de Software",
				"pergunta": "Uma interface com data binding precisa separar visual e estado de apresentação. Qual padrão é comum?",
				"opcoes": {"A": "MVVM", "B": "FIFO"},
				"resposta": "A",
				"motivos": {
					"A": "MVVM significa Model-View-ViewModel e ajuda a separar interface, dados e estado de apresentação.",
					"B": "FIFO é regra de fila em estruturas de dados."
				}
			},
			{
				"id": "desvio_dificil_atomicidade_06",
				"topic": "Banco de Dados",
				"pergunta": "Em uma transação, ou todas as operações são concluídas, ou nenhuma deve permanecer. Qual propriedade ACID?",
				"opcoes": {"A": "Latência", "B": "Atomicidade"},
				"resposta": "B",
				"motivos": {
					"B": "Atomicidade garante que uma transação seja tratada como unidade indivisível.",
					"A": "Latência é atraso de comunicação, não propriedade ACID."
				}
			},
			{
				"id": "desvio_dificil_isolamento_07",
				"topic": "Banco de Dados",
				"pergunta": "Transações simultâneas não devem interferir indevidamente nos resultados umas das outras. Qual propriedade ACID?",
				"opcoes": {"A": "Isolamento", "B": "Herança"},
				"resposta": "A",
				"motivos": {
					"A": "Isolamento controla efeitos de concorrência entre transações.",
					"B": "Herança é conceito de POO e não propriedade ACID."
				}
			},
			{
				"id": "desvio_dificil_star_schema_08",
				"topic": "Data Warehouse",
				"pergunta": "Um Data Warehouse usa tabela fato central ligada a dimensões. Qual modelagem é essa?",
				"opcoes": {"A": "Lista encadeada", "B": "Star Schema"},
				"resposta": "B",
				"motivos": {
					"B": "Star Schema, ou esquema estrela, organiza fatos e dimensões para consultas analíticas eficientes.",
					"A": "Lista encadeada é estrutura de dados, não modelagem dimensional."
				}
			},
			{
				"id": "desvio_dificil_data_mart_09",
				"topic": "BI/Data Warehouse",
				"pergunta": "Um subconjunto de dados atende uma área específica, como financeiro ou vendas. Qual termo?",
				"opcoes": {"A": "Data Mart", "B": "Kernel"},
				"resposta": "A",
				"motivos": {
					"A": "Data Mart é um recorte departamental de dados analíticos, geralmente derivado de um Data Warehouse.",
					"B": "Kernel é núcleo do sistema operacional, não subconjunto analítico."
				}
			},
			{
				"id": "desvio_dificil_kdd_10",
				"topic": "Mineração de Dados",
				"pergunta": "O processo envolve seleção, pré-processamento, transformação, mineração e interpretação. Qual conceito?",
				"opcoes": {"A": "CRUD", "B": "KDD"},
				"resposta": "B",
				"motivos": {
					"B": "KDD significa Knowledge Discovery in Databases, ou Descoberta de Conhecimento em Bases de Dados.",
					"A": "CRUD representa criar, ler, atualizar e excluir dados, não o processo completo de descoberta de conhecimento."
				}
			},
			{
				"id": "desvio_dificil_pandas_pipeline_11",
				"topic": "Ciência de Dados",
				"pergunta": "O analista encadeia limpeza, padronização e agregação para tornar a análise reproduzível. Qual decisão é melhor?",
				"opcoes": {"A": "Pipeline de dados", "B": "Editar valores manualmente"},
				"resposta": "A",
				"motivos": {
					"A": "Pipeline de dados organiza etapas reproduzíveis de tratamento e análise, reduzindo erro manual.",
					"B": "Editar manualmente dificulta auditoria, repetição e rastreabilidade."
				}
			},
			{
				"id": "desvio_dificil_series_dataframe_12",
				"topic": "Pandas",
				"pergunta": "Uma coluna isolada com índice e uma tabela bidimensional são, respectivamente, quais estruturas?",
				"opcoes": {"A": "Array e Firewall", "B": "Series e DataFrame"},
				"resposta": "B",
				"motivos": {
					"B": "Series é unidimensional; DataFrame é bidimensional e reúne linhas e colunas.",
					"A": "Firewall é segurança de rede e não estrutura de dados do Pandas."
				}
			},
			{
				"id": "desvio_dificil_padronizacao_13",
				"topic": "Ciência de Dados",
				"pergunta": "Datas em formatos diferentes e categorias escritas de várias formas prejudicam a análise. Qual etapa corrige isso?",
				"opcoes": {"A": "Padronização de dados", "B": "Deploy em produção"},
				"resposta": "A",
				"motivos": {
					"A": "Padronização coloca valores em formatos consistentes antes da análise e dos indicadores.",
					"B": "Deploy publica software, mas não corrige inconsistências dos dados."
				}
			},
			{
				"id": "desvio_dificil_preparacao_dados_14",
				"topic": "Ciência de Dados",
				"pergunta": "Por que a preparação dos dados costuma consumir muito tempo em projetos reais?",
				"opcoes": {"A": "Gráficos são impossíveis", "B": "Dados chegam sujos e inconsistentes"},
				"resposta": "B",
				"motivos": {
					"B": "Dados reais costumam vir incompletos, duplicados, divergentes e fora de padrão, exigindo tratamento antes da análise.",
					"A": "Gráficos não são impossíveis; o risco é gerar visualizações sobre dados ruins."
				}
			},
			{
				"id": "desvio_dificil_zero_trust_15",
				"topic": "Cibersegurança",
				"pergunta": "A arquitetura assume que nenhum acesso deve ser confiável automaticamente. Qual abordagem?",
				"opcoes": {"A": "Zero Trust", "B": "Confiança total na rede interna"},
				"resposta": "A",
				"motivos": {
					"A": "Zero Trust exige verificação contínua de identidade, contexto e permissões.",
					"B": "Confiar totalmente na rede interna aumenta riscos em caso de invasão ou credencial comprometida."
				}
			},
			{
				"id": "desvio_dificil_menor_privilegio_16",
				"topic": "Cibersegurança",
				"pergunta": "Um usuário deve receber apenas os acessos necessários para sua função. Qual princípio?",
				"opcoes": {"A": "Acesso irrestrito", "B": "Menor privilégio"},
				"resposta": "B",
				"motivos": {
					"B": "O menor privilégio reduz impacto de falhas, abusos e credenciais comprometidas.",
					"A": "Acesso irrestrito amplia danos potenciais e dificulta controle."
				}
			},
			{
				"id": "desvio_dificil_oauth_17",
				"topic": "Cibersegurança",
				"pergunta": "Uma aplicação acessa recursos em nome do usuário sem receber a senha dele. Qual protocolo é comum?",
				"opcoes": {"A": "OAuth 2.0", "B": "FTP anônimo"},
				"resposta": "A",
				"motivos": {
					"A": "OAuth 2.0 permite autorização delegada por tokens, sem compartilhar senha com terceiros.",
					"B": "FTP anônimo não oferece esse modelo seguro de autorização delegada."
				}
			},
			{
				"id": "desvio_dificil_jwt_18",
				"topic": "Cibersegurança",
				"pergunta": "Um token compacto carrega claims assinadas para comunicação entre sistemas. Qual formato?",
				"opcoes": {"A": "CSV puro", "B": "JWT"},
				"resposta": "B",
				"motivos": {
					"B": "JWT significa JSON Web Token. Ele representa declarações assinadas, mas exige expiração e armazenamento seguro.",
					"A": "CSV puro é formato tabular e não representa token assinado."
				}
			},
			{
				"id": "desvio_dificil_observabilidade_19",
				"topic": "DevOps",
				"pergunta": "Para investigar falhas em produção, a equipe usa logs, métricas e traces. Qual conceito?",
				"opcoes": {"A": "Observabilidade", "B": "Minificação CSS"},
				"resposta": "A",
				"motivos": {
					"A": "Observabilidade permite compreender o comportamento do sistema a partir de sinais como logs, métricas e rastros.",
					"B": "Minificação reduz tamanho de arquivos, mas não monitora comportamento em produção."
				}
			},
			{
				"id": "desvio_dificil_iac_20",
				"topic": "DevOps e Cloud",
				"pergunta": "Ambientes são criados por arquivos versionados em vez de configuração manual. Qual prática?",
				"opcoes": {"A": "Clique manual sem registro", "B": "IaC"},
				"resposta": "B",
				"motivos": {
					"B": "IaC significa Infrastructure as Code, ou Infraestrutura como Código. Ela torna ambientes reproduzíveis e auditáveis.",
					"A": "Configuração manual sem registro dificulta auditoria e repetição."
				}
			},
			{
				"id": "desvio_dificil_escalabilidade_horizontal_21",
				"topic": "Cloud/Arquitetura",
				"pergunta": "A demanda cresceu e a solução adiciona mais instâncias do serviço. Qual tipo de escala?",
				"opcoes": {"A": "Escalabilidade horizontal", "B": "Escalabilidade vertical apenas"},
				"resposta": "A",
				"motivos": {
					"A": "Escalabilidade horizontal aumenta capacidade adicionando mais nós ou instâncias.",
					"B": "Escalabilidade vertical aumenta recursos de uma única máquina, como CPU e memória."
				}
			},
			{
				"id": "desvio_dificil_rto_rpo_22",
				"topic": "Continuidade de Negócio",
				"pergunta": "A empresa define tempo máximo de recuperação e perda máxima aceitável de dados. Quais métricas?",
				"opcoes": {"A": "UX e UI", "B": "RTO e RPO"},
				"resposta": "B",
				"motivos": {
					"B": "RTO é Recovery Time Objective; RPO é Recovery Point Objective. Eles orientam recuperação e continuidade.",
					"A": "UX e UI tratam experiência e interface, não metas de recuperação."
				}
			},
			{
				"id": "desvio_dificil_cobit_23",
				"topic": "Governança de TI",
				"pergunta": "A organização quer alinhar TI a valor, risco, controle e objetivos do negócio. Qual framework ajuda?",
				"opcoes": {"A": "COBIT", "B": "HTML semântico"},
				"resposta": "A",
				"motivos": {
					"A": "COBIT apoia governança e gestão de TI com foco em valor, riscos, controles e alinhamento estratégico.",
					"B": "HTML semântico organiza páginas web, mas não governa TI corporativa."
				}
			},
			{
				"id": "desvio_dificil_itil_24",
				"topic": "Governança de TI",
				"pergunta": "A área quer melhorar gestão de serviços, incidentes, mudanças e níveis de serviço. Qual biblioteca é referência?",
				"opcoes": {"A": "Array bidimensional", "B": "ITIL"},
				"resposta": "B",
				"motivos": {
					"B": "ITIL reúne boas práticas para gestão de serviços de TI e melhoria contínua.",
					"A": "Array bidimensional é estrutura de programação, não gestão de serviços."
				}
			},
			{
				"id": "desvio_dificil_privacidade_design_25",
				"topic": "LGPD e Ética",
				"pergunta": "Proteção de dados é considerada desde a concepção do sistema. Qual abordagem?",
				"opcoes": {"A": "Privacidade por Design", "B": "Correção só no final"},
				"resposta": "A",
				"motivos": {
					"A": "Privacidade por design incorpora proteção de dados em requisitos, arquitetura e operação.",
					"B": "Corrigir só no final aumenta risco, custo e violações de privacidade."
				}
			},
			{
				"id": "desvio_dificil_anonimizacao_26",
				"topic": "LGPD e Privacidade",
				"pergunta": "Dados são tratados para não identificar o titular de forma razoável. Qual técnica?",
				"opcoes": {"A": "Autenticação", "B": "Anonimização"},
				"resposta": "B",
				"motivos": {
					"B": "Anonimização reduz vínculo com uma pessoa identificável e pode diminuir riscos de privacidade.",
					"A": "Autenticação verifica identidade; não remove identificação dos dados."
				}
			},
			{
				"id": "desvio_dificil_heuristica_nielsen_27",
				"topic": "UX/IHC",
				"pergunta": "A interface deve informar ao usuário o que está acontecendo após uma ação. Qual heurística se relaciona?",
				"opcoes": {"A": "Visibilidade do status", "B": "Encapsulamento"},
				"resposta": "A",
				"motivos": {
					"A": "Visibilidade do status do sistema é uma heurística de Nielsen ligada a feedback claro e oportuno.",
					"B": "Encapsulamento é princípio de POO, não heurística de interface."
				}
			},
			{
				"id": "desvio_dificil_affordance_28",
				"topic": "UX/IHC",
				"pergunta": "Um botão parece clicável porque sua forma sugere uso. Qual conceito ajuda a explicar isso?",
				"opcoes": {"A": "Rollback", "B": "Affordance"},
				"resposta": "B",
				"motivos": {
					"B": "Affordance é uma pista percebida que sugere como um elemento pode ser usado.",
					"A": "Rollback desfaz transações e não descreve pistas visuais de interação."
				}
			},
			{
				"id": "desvio_dificil_testes_regressao_29",
				"topic": "Qualidade de Software",
				"pergunta": "Após corrigir uma falha, a equipe verifica se funcionalidades antigas não quebraram. Qual teste?",
				"opcoes": {"A": "Teste regressivo", "B": "Teste de paleta"},
				"resposta": "A",
				"motivos": {
					"A": "Teste regressivo busca garantir que mudanças não reintroduzam defeitos em funcionalidades existentes.",
					"B": "Teste de paleta avalia visual, mas não cobre regressão funcional."
				}
			},
			{
				"id": "desvio_dificil_divida_tecnica_30",
				"topic": "Engenharia de Software",
				"pergunta": "Uma solução rápida resolve agora, mas aumenta custo de manutenção futura. Qual conceito?",
				"opcoes": {"A": "Cache hit", "B": "Dívida técnica"},
				"resposta": "B",
				"motivos": {
					"B": "Dívida técnica representa escolhas que aceleram entrega no curto prazo, mas geram custo e risco no futuro.",
					"A": "Cache hit indica dado encontrado em cache, não custo futuro de manutenção."
				}
			}
		]
	},
	"roleta_risco": {
		"facil": [
			{
				"id": "roleta_facil_desenvolvimento_web_html_01",
				"topic": "Desenvolvimento Web",
				"name": "Boa prática: HTML",
				"impact": "good",
				"strength": "high",
				"description": "A equipe aplicou HTML de forma consciente durante a Jornada SI.",
				"learning": "HTML significa HyperText Markup Language, ou Linguagem de Marcação de Hipertexto. Ele define a estrutura semântica de uma página web, como títulos, textos, listas, links e formulários."
			},
			{
				"id": "roleta_facil_front_end_css_02",
				"topic": "Front-end",
				"name": "Falha em CSS",
				"impact": "bad",
				"strength": "low",
				"description": "A equipe negligenciou CSS e criou risco técnico ou pedagógico.",
				"learning": "Esse risco seria menor com atenção ao conceito: CSS significa Cascading Style Sheets, ou Folhas de Estilo em Cascata. Ele separa a apresentação visual da estrutura HTML e permite criar interfaces responsivas e organizadas."
			},
			{
				"id": "roleta_facil_programacao_web_javascript_03",
				"topic": "Programação Web",
				"name": "Boa prática: JavaScript",
				"impact": "good",
				"strength": "high",
				"description": "A equipe aplicou JavaScript de forma consciente durante a Jornada SI.",
				"learning": "JavaScript é uma linguagem de programação muito usada no navegador e também no back-end. Ela permite validar formulários, manipular o DOM, consumir APIs e criar interações dinâmicas."
			},
			{
				"id": "roleta_facil_back_end_api_04",
				"topic": "Back-end",
				"name": "Boa prática: API",
				"impact": "good",
				"strength": "low",
				"description": "A equipe aplicou API de forma consciente durante a Jornada SI.",
				"learning": "API significa Application Programming Interface, ou Interface de Programação de Aplicações. Ela expõe funcionalidades para que sistemas, aplicativos ou serviços troquem dados de forma padronizada."
			},
			{
				"id": "roleta_facil_banco_de_dados_banco_de_dados_05",
				"topic": "Banco de Dados",
				"name": "Falha em Banco de Dados",
				"impact": "bad",
				"strength": "high",
				"description": "A equipe negligenciou Banco de Dados e criou risco técnico ou pedagógico.",
				"learning": "Esse risco seria menor com atenção ao conceito: Banco de dados é uma estrutura usada para armazenar informações de forma persistente. Em sistemas de informação, ele sustenta cadastros, transações, consultas e relatórios."
			},
			{
				"id": "roleta_facil_sql_select_06",
				"topic": "SQL",
				"name": "Boa prática: SELECT",
				"impact": "good",
				"strength": "low",
				"description": "A equipe aplicou SELECT de forma consciente durante a Jornada SI.",
				"learning": "SELECT é um comando da linguagem SQL usado para consultar dados. Ele pode ser combinado com WHERE, JOIN, GROUP BY e ORDER BY para filtrar, relacionar e ordenar resultados."
			},
			{
				"id": "roleta_facil_estruturas_de_dados_pilha_07",
				"topic": "Estruturas de Dados",
				"name": "Boa prática: Pilha",
				"impact": "good",
				"strength": "high",
				"description": "A equipe aplicou Pilha de forma consciente durante a Jornada SI.",
				"learning": "Pilha é uma estrutura de dados baseada em LIFO, Last In, First Out. Ela aparece em chamadas de funções, desfazer ações e controle de execução."
			},
			{
				"id": "roleta_facil_estruturas_de_dados_fila_08",
				"topic": "Estruturas de Dados",
				"name": "Falha em Fila",
				"impact": "bad",
				"strength": "low",
				"description": "A equipe negligenciou Fila e criou risco técnico ou pedagógico.",
				"learning": "Esse risco seria menor com atenção ao conceito: Fila é uma estrutura de dados baseada em FIFO, First In, First Out. Ela é útil em atendimento, processamento de tarefas e filas de mensagens."
			},
			{
				"id": "roleta_facil_seguranca_da_informacao_backup_09",
				"topic": "Segurança da Informação",
				"name": "Boa prática: Backup",
				"impact": "good",
				"strength": "high",
				"description": "A equipe aplicou Backup de forma consciente durante a Jornada SI.",
				"learning": "Backup é uma cópia de segurança dos dados. Ele reduz perdas em falhas, ataques, erros humanos e desastres, mas precisa ser testado para garantir restauração."
			},
			{
				"id": "roleta_facil_ciberseguranca_mfa_10",
				"topic": "Cibersegurança",
				"name": "Boa prática: MFA",
				"impact": "good",
				"strength": "low",
				"description": "A equipe aplicou MFA de forma consciente durante a Jornada SI.",
				"learning": "MFA significa Multi-Factor Authentication, ou Autenticação Multifator. Ele combina fatores como senha, aplicativo, biometria ou token para reduzir o risco de acesso indevido."
			},
			{
				"id": "roleta_facil_ux_ihc_ux_11",
				"topic": "UX/IHC",
				"name": "Falha em UX",
				"impact": "bad",
				"strength": "high",
				"description": "A equipe negligenciou UX e criou risco técnico ou pedagógico.",
				"learning": "Esse risco seria menor com atenção ao conceito: UX significa User Experience, ou Experiência do Usuário. Ela envolve utilidade, facilidade de uso, eficiência, emoção, contexto e satisfação durante a interação."
			},
			{
				"id": "roleta_facil_ihc_acessibilidade_12",
				"topic": "IHC",
				"name": "Boa prática: Acessibilidade",
				"impact": "good",
				"strength": "low",
				"description": "A equipe aplicou Acessibilidade de forma consciente durante a Jornada SI.",
				"learning": "Acessibilidade busca tornar produtos digitais utilizáveis por mais pessoas. Ela envolve contraste, navegação por teclado, texto alternativo, leitores de tela e linguagem clara."
			},
			{
				"id": "roleta_facil_fundamentos_de_computacao_algoritmo_13",
				"topic": "Fundamentos de Computação",
				"name": "Boa prática: Algoritmo",
				"impact": "good",
				"strength": "high",
				"description": "A equipe aplicou Algoritmo de forma consciente durante a Jornada SI.",
				"learning": "Algoritmo é um conjunto de instruções lógicas para chegar a uma solução. Ele pode ser representado em linguagem natural, fluxograma, pseudocódigo ou código."
			},
			{
				"id": "roleta_facil_programacao_variavel_14",
				"topic": "Programação",
				"name": "Falha em Variável",
				"impact": "bad",
				"strength": "low",
				"description": "A equipe negligenciou Variável e criou risco técnico ou pedagógico.",
				"learning": "Esse risco seria menor com atenção ao conceito: Variável é um nome associado a um valor em memória. Ela permite guardar dados como números, textos, estados e resultados intermediários."
			},
			{
				"id": "roleta_facil_programacao_funcao_15",
				"topic": "Programação",
				"name": "Boa prática: Função",
				"impact": "good",
				"strength": "high",
				"description": "A equipe aplicou Função de forma consciente durante a Jornada SI.",
				"learning": "Função organiza o código em blocos menores e reutilizáveis. Ela melhora leitura, manutenção, testes e evita repetição desnecessária."
			},
			{
				"id": "roleta_facil_devops_git_16",
				"topic": "DevOps",
				"name": "Boa prática: Git",
				"impact": "good",
				"strength": "low",
				"description": "A equipe aplicou Git de forma consciente durante a Jornada SI.",
				"learning": "Git é um sistema de controle de versão distribuído. Ele permite criar branches, revisar mudanças, voltar versões e colaborar com mais segurança."
			},
			{
				"id": "roleta_facil_arquitetura_web_cliente_17",
				"topic": "Arquitetura Web",
				"name": "Falha em Cliente",
				"impact": "bad",
				"strength": "high",
				"description": "A equipe negligenciou Cliente e criou risco técnico ou pedagógico.",
				"learning": "Esse risco seria menor com atenção ao conceito: Cliente é o componente que consome um serviço, como navegador, aplicativo mobile ou sistema externo. Ele envia requisições para um servidor."
			},
			{
				"id": "roleta_facil_arquitetura_web_servidor_18",
				"topic": "Arquitetura Web",
				"name": "Boa prática: Servidor",
				"impact": "good",
				"strength": "low",
				"description": "A equipe aplicou Servidor de forma consciente durante a Jornada SI.",
				"learning": "Servidor é o componente que recebe requisições, executa regras de negócio, consulta dados e envia respostas para clientes ou outros sistemas."
			},
			{
				"id": "roleta_facil_redes_rede_19",
				"topic": "Redes",
				"name": "Boa prática: Rede",
				"impact": "good",
				"strength": "high",
				"description": "A equipe aplicou Rede de forma consciente durante a Jornada SI.",
				"learning": "Rede de computadores conecta dispositivos para troca de dados. Ela pode usar protocolos, endereços, roteadores, switches e serviços como DNS e HTTP."
			},
			{
				"id": "roleta_facil_redes_dns_20",
				"topic": "Redes",
				"name": "Falha em DNS",
				"impact": "bad",
				"strength": "low",
				"description": "A equipe negligenciou DNS e criou risco técnico ou pedagógico.",
				"learning": "Esse risco seria menor com atenção ao conceito: DNS significa Domain Name System, ou Sistema de Nomes de Domínio. Ele permite acessar sites por nomes como exemplo.com em vez de memorizar endereços IP."
			},
			{
				"id": "roleta_facil_ciberseguranca_firewall_21",
				"topic": "Cibersegurança",
				"name": "Boa prática: Firewall",
				"impact": "good",
				"strength": "high",
				"description": "A equipe aplicou Firewall de forma consciente durante a Jornada SI.",
				"learning": "Firewall é um mecanismo de segurança que filtra comunicações. Ele pode bloquear conexões suspeitas, limitar portas e reduzir exposição de serviços."
			},
			{
				"id": "roleta_facil_engenharia_de_software_requisito_22",
				"topic": "Engenharia de Software",
				"name": "Boa prática: Requisito",
				"impact": "good",
				"strength": "low",
				"description": "A equipe aplicou Requisito de forma consciente durante a Jornada SI.",
				"learning": "Requisito registra o que o sistema precisa fazer ou respeitar. Pode ser funcional, quando descreve uma função, ou não funcional, quando descreve qualidade ou restrição."
			},
			{
				"id": "roleta_facil_qualidade_de_software_teste_23",
				"topic": "Qualidade de Software",
				"name": "Falha em Teste",
				"impact": "bad",
				"strength": "high",
				"description": "A equipe negligenciou Teste e criou risco técnico ou pedagógico.",
				"learning": "Esse risco seria menor com atenção ao conceito: Teste de software reduz riscos ao verificar comportamentos esperados. Ele pode ser manual, automatizado, unitário, funcional, regressivo ou de integração."
			},
			{
				"id": "roleta_facil_qualidade_de_software_bug_24",
				"topic": "Qualidade de Software",
				"name": "Boa prática: Bug",
				"impact": "good",
				"strength": "low",
				"description": "A equipe aplicou Bug de forma consciente durante a Jornada SI.",
				"learning": "Bug é uma falha ou defeito no software. Ele pode surgir por erro de lógica, requisito mal interpretado, integração incorreta ou dados inesperados."
			},
			{
				"id": "roleta_facil_business_intelligence_dashboard_25",
				"topic": "Business Intelligence",
				"name": "Boa prática: Dashboard",
				"impact": "good",
				"strength": "high",
				"description": "A equipe aplicou Dashboard de forma consciente durante a Jornada SI.",
				"learning": "Dashboard é um painel visual com métricas, gráficos e indicadores. Em BI, ele ajuda a transformar dados em leitura rápida para gestão e acompanhamento."
			},
			{
				"id": "roleta_facil_ciencia_de_dados_dataframe_26",
				"topic": "Ciência de Dados",
				"name": "Falha em DataFrame",
				"impact": "bad",
				"strength": "low",
				"description": "A equipe negligenciou DataFrame e criou risco técnico ou pedagógico.",
				"learning": "Esse risco seria menor com atenção ao conceito: DataFrame é a estrutura bidimensional do Pandas. Ele organiza dados como uma tabela, permitindo filtros, agrupamentos, junções, limpeza e análise exploratória."
			},
			{
				"id": "roleta_facil_ciencia_de_dados_series_27",
				"topic": "Ciência de Dados",
				"name": "Boa prática: Series",
				"impact": "good",
				"strength": "high",
				"description": "A equipe aplicou Series de forma consciente durante a Jornada SI.",
				"learning": "Series é uma estrutura unidimensional do Pandas, formada por valores e índice. Uma coluna de um DataFrame pode ser tratada como uma Series."
			},
			{
				"id": "roleta_facil_ciencia_de_dados_limpeza_de_dados_28",
				"topic": "Ciência de Dados",
				"name": "Boa prática: Limpeza de Dados",
				"impact": "good",
				"strength": "low",
				"description": "A equipe aplicou Limpeza de Dados de forma consciente durante a Jornada SI.",
				"learning": "Limpeza de dados prepara uma base para análise confiável. Em projetos reais, essa etapa costuma consumir muito tempo porque dados chegam incompletos, duplicados ou fora de padrão."
			},
			{
				"id": "roleta_facil_lgpd_e_privacidade_lgpd_29",
				"topic": "LGPD e Privacidade",
				"name": "Falha em LGPD",
				"impact": "bad",
				"strength": "high",
				"description": "A equipe negligenciou LGPD e criou risco técnico ou pedagógico.",
				"learning": "Esse risco seria menor com atenção ao conceito: LGPD significa Lei Geral de Proteção de Dados. Ela regula coleta, uso, armazenamento e compartilhamento de dados pessoais no Brasil."
			},
			{
				"id": "roleta_facil_programacao_orientada_a_objetos_poo_30",
				"topic": "Programação Orientada a Objetos",
				"name": "Boa prática: POO",
				"impact": "good",
				"strength": "low",
				"description": "A equipe aplicou POO de forma consciente durante a Jornada SI.",
				"learning": "POO significa Programação Orientada a Objetos. Ela modela o software com objetos que possuem dados e comportamentos, favorecendo organização e reutilização."
			}
		],
		"normal": [
			{
				"id": "roleta_normal_ciberseguranca_autenticacao_01",
				"topic": "Cibersegurança",
				"name": "Boa prática: Autenticação",
				"impact": "good",
				"strength": "high",
				"description": "A equipe aplicou Autenticação de forma consciente durante a Jornada SI.",
				"learning": "Autenticação verifica identidade por senha, biometria, token ou outro fator. Ela responde à pergunta: quem é você?"
			},
			{
				"id": "roleta_normal_ciberseguranca_autorizacao_02",
				"topic": "Cibersegurança",
				"name": "Falha em Autorização",
				"impact": "bad",
				"strength": "low",
				"description": "A equipe negligenciou Autorização e criou risco técnico ou pedagógico.",
				"learning": "Esse risco seria menor com atenção ao conceito: Autorização ocorre depois da autenticação. Ela controla permissões e responde: o que este usuário pode fazer?"
			},
			{
				"id": "roleta_normal_desenvolvimento_web_api_rest_03",
				"topic": "Desenvolvimento Web",
				"name": "Boa prática: API REST",
				"impact": "good",
				"strength": "high",
				"description": "A equipe aplicou API REST de forma consciente durante a Jornada SI.",
				"learning": "API REST segue princípios de Representational State Transfer. Ela costuma usar métodos HTTP como GET, POST, PUT e DELETE para manipular recursos."
			},
			{
				"id": "roleta_normal_desenvolvimento_web_json_04",
				"topic": "Desenvolvimento Web",
				"name": "Boa prática: JSON",
				"impact": "good",
				"strength": "low",
				"description": "A equipe aplicou JSON de forma consciente durante a Jornada SI.",
				"learning": "JSON significa JavaScript Object Notation. Ele é comum em APIs porque é simples, legível e compatível com várias linguagens."
			},
			{
				"id": "roleta_normal_back_end_cache_05",
				"topic": "Back-end",
				"name": "Falha em Cache",
				"impact": "bad",
				"strength": "high",
				"description": "A equipe negligenciou Cache e criou risco técnico ou pedagógico.",
				"learning": "Esse risco seria menor com atenção ao conceito: Cache melhora desempenho ao reutilizar dados acessados com frequência. O cuidado é manter validade e evitar entregar informação desatualizada."
			},
			{
				"id": "roleta_normal_banco_de_dados_transacao_06",
				"topic": "Banco de Dados",
				"name": "Boa prática: Transação",
				"impact": "good",
				"strength": "low",
				"description": "A equipe aplicou Transação de forma consciente durante a Jornada SI.",
				"learning": "Transação protege a consistência dos dados. Se tudo dá certo, ocorre commit; se algo falha, rollback desfaz as alterações."
			},
			{
				"id": "roleta_normal_banco_de_dados_indice_07",
				"topic": "Banco de Dados",
				"name": "Boa prática: Índice",
				"impact": "good",
				"strength": "high",
				"description": "A equipe aplicou Índice de forma consciente durante a Jornada SI.",
				"learning": "Índice é uma estrutura auxiliar para localizar registros mais rápido. Ele melhora consultas, mas exige equilíbrio porque impacta inserções e atualizações."
			},
			{
				"id": "roleta_normal_banco_de_dados_chave_estrangeira_08",
				"topic": "Banco de Dados",
				"name": "Falha em Chave Estrangeira",
				"impact": "bad",
				"strength": "low",
				"description": "A equipe negligenciou Chave Estrangeira e criou risco técnico ou pedagógico.",
				"learning": "Esse risco seria menor com atenção ao conceito: Chave estrangeira referencia a chave primária de outra tabela. Ela ajuda a evitar relacionamentos inválidos entre registros."
			},
			{
				"id": "roleta_normal_modelagem_de_dados_diagrama_er_09",
				"topic": "Modelagem de Dados",
				"name": "Boa prática: Diagrama ER",
				"impact": "good",
				"strength": "high",
				"description": "A equipe aplicou Diagrama ER de forma consciente durante a Jornada SI.",
				"learning": "Diagrama ER significa Entidade-Relacionamento. Ele apoia a modelagem conceitual de bancos de dados antes da criação das tabelas."
			},
			{
				"id": "roleta_normal_banco_de_dados_normalizacao_10",
				"topic": "Banco de Dados",
				"name": "Boa prática: Normalização",
				"impact": "good",
				"strength": "low",
				"description": "A equipe aplicou Normalização de forma consciente durante a Jornada SI.",
				"learning": "Normalização aplica formas normais para melhorar consistência no banco relacional. Ela reduz repetição indevida, mas pode exigir joins mais frequentes."
			},
			{
				"id": "roleta_normal_redes_roteamento_11",
				"topic": "Redes",
				"name": "Falha em Roteamento",
				"impact": "bad",
				"strength": "high",
				"description": "A equipe negligenciou Roteamento e criou risco técnico ou pedagógico.",
				"learning": "Esse risco seria menor com atenção ao conceito: Roteamento encaminha pacotes entre redes. Roteadores usam tabelas e protocolos para escolher o melhor caminho disponível."
			},
			{
				"id": "roleta_normal_redes_e_web_http_12",
				"topic": "Redes e Web",
				"name": "Boa prática: HTTP",
				"impact": "good",
				"strength": "low",
				"description": "A equipe aplicou HTTP de forma consciente durante a Jornada SI.",
				"learning": "HTTP significa HyperText Transfer Protocol. Ele define requisições e respostas na web, usando métodos como GET e POST."
			},
			{
				"id": "roleta_normal_redes_e_seguranca_https_13",
				"topic": "Redes e Segurança",
				"name": "Boa prática: HTTPS",
				"impact": "good",
				"strength": "high",
				"description": "A equipe aplicou HTTPS de forma consciente durante a Jornada SI.",
				"learning": "HTTPS significa HyperText Transfer Protocol Secure. Ele usa TLS para proteger confidencialidade, integridade e autenticidade da comunicação."
			},
			{
				"id": "roleta_normal_redes_e_seguranca_vpn_14",
				"topic": "Redes e Segurança",
				"name": "Falha em VPN",
				"impact": "bad",
				"strength": "low",
				"description": "A equipe negligenciou VPN e criou risco técnico ou pedagógico.",
				"learning": "Esse risco seria menor com atenção ao conceito: VPN significa Virtual Private Network, ou Rede Privada Virtual. Ela protege tráfego e permite acesso seguro a recursos internos."
			},
			{
				"id": "roleta_normal_ciberseguranca_hash_15",
				"topic": "Cibersegurança",
				"name": "Boa prática: Hash",
				"impact": "good",
				"strength": "high",
				"description": "A equipe aplicou Hash de forma consciente durante a Jornada SI.",
				"learning": "Hash é uma função que transforma dados em um resumo. É usado para integridade e armazenamento seguro de senhas quando combinado com salting e boas práticas."
			},
			{
				"id": "roleta_normal_ciberseguranca_criptografia_16",
				"topic": "Cibersegurança",
				"name": "Boa prática: Criptografia",
				"impact": "good",
				"strength": "low",
				"description": "A equipe aplicou Criptografia de forma consciente durante a Jornada SI.",
				"learning": "Criptografia protege confidencialidade e, em alguns usos, integridade e autenticidade. Ela é base de HTTPS, armazenamento seguro e comunicação protegida."
			},
			{
				"id": "roleta_normal_ciberseguranca_sql_injection_17",
				"topic": "Cibersegurança",
				"name": "Falha em SQL Injection",
				"impact": "bad",
				"strength": "high",
				"description": "A equipe negligenciou SQL Injection e criou risco técnico ou pedagógico.",
				"learning": "Esse risco seria menor com atenção ao conceito: SQL Injection é uma vulnerabilidade de injeção em banco de dados. Validação, consultas parametrizadas e menor privilégio reduzem esse risco."
			},
			{
				"id": "roleta_normal_ciberseguranca_xss_18",
				"topic": "Cibersegurança",
				"name": "Boa prática: XSS",
				"impact": "good",
				"strength": "low",
				"description": "A equipe aplicou XSS de forma consciente durante a Jornada SI.",
				"learning": "XSS significa Cross-Site Scripting. Ele ocorre quando uma aplicação exibe conteúdo não tratado, permitindo execução de scripts no navegador da vítima."
			},
			{
				"id": "roleta_normal_ux_ihc_persona_19",
				"topic": "UX/IHC",
				"name": "Boa prática: Persona",
				"impact": "good",
				"strength": "high",
				"description": "A equipe aplicou Persona de forma consciente durante a Jornada SI.",
				"learning": "Persona ajuda equipes a projetarem pensando em necessidades, dores, objetivos e contexto de uso de grupos de usuários."
			},
			{
				"id": "roleta_normal_ux_ihc_heuristicas_de_nielsen_20",
				"topic": "UX/IHC",
				"name": "Falha em Heurísticas de Nielsen",
				"impact": "bad",
				"strength": "low",
				"description": "A equipe negligenciou Heurísticas de Nielsen e criou risco técnico ou pedagógico.",
				"learning": "Esse risco seria menor com atenção ao conceito: As heurísticas de Nielsen orientam avaliação de interfaces, incluindo feedback, consistência, prevenção de erros e liberdade do usuário."
			},
			{
				"id": "roleta_normal_front_end_design_responsivo_21",
				"topic": "Front-end",
				"name": "Boa prática: Design Responsivo",
				"impact": "good",
				"strength": "high",
				"description": "A equipe aplicou Design Responsivo de forma consciente durante a Jornada SI.",
				"learning": "Design responsivo usa layouts flexíveis, media queries e boas práticas de interface para manter usabilidade em celular, tablet e desktop."
			},
			{
				"id": "roleta_normal_devops_devops_22",
				"topic": "DevOps",
				"name": "Boa prática: DevOps",
				"impact": "good",
				"strength": "low",
				"description": "A equipe aplicou DevOps de forma consciente durante a Jornada SI.",
				"learning": "DevOps combina cultura, automação e colaboração. Ele reduz atritos entre desenvolvimento, testes, infraestrutura e implantação."
			},
			{
				"id": "roleta_normal_devops_pipeline_23",
				"topic": "DevOps",
				"name": "Falha em Pipeline",
				"impact": "bad",
				"strength": "high",
				"description": "A equipe negligenciou Pipeline e criou risco técnico ou pedagógico.",
				"learning": "Esse risco seria menor com atenção ao conceito: Pipeline organiza o fluxo de entrega de software. Em CI/CD, ele reduz tarefas manuais e torna publicações mais repetíveis."
			},
			{
				"id": "roleta_normal_devops_container_24",
				"topic": "DevOps",
				"name": "Boa prática: Container",
				"impact": "good",
				"strength": "low",
				"description": "A equipe aplicou Container de forma consciente durante a Jornada SI.",
				"learning": "Container ajuda a executar software de forma consistente entre desenvolvimento, teste e produção. Docker é uma ferramenta comum nesse contexto."
			},
			{
				"id": "roleta_normal_devops_ci_cd_25",
				"topic": "DevOps",
				"name": "Boa prática: CI/CD",
				"impact": "good",
				"strength": "high",
				"description": "A equipe aplicou CI/CD de forma consciente durante a Jornada SI.",
				"learning": "CI/CD significa Continuous Integration e Continuous Delivery/Deployment, ou Integração Contínua e Entrega/Implantação Contínua. Ele reduz erros manuais e acelera entregas."
			},
			{
				"id": "roleta_normal_dados_e_bi_etl_26",
				"topic": "Dados e BI",
				"name": "Falha em ETL",
				"impact": "bad",
				"strength": "low",
				"description": "A equipe negligenciou ETL e criou risco técnico ou pedagógico.",
				"learning": "Esse risco seria menor com atenção ao conceito: ETL significa Extract, Transform and Load, ou Extração, Transformação e Carga. Ele coleta dados, aplica tratamentos e carrega o resultado em bases analíticas, como Data Warehouse."
			},
			{
				"id": "roleta_normal_business_intelligence_kpi_27",
				"topic": "Business Intelligence",
				"name": "Boa prática: KPI",
				"impact": "good",
				"strength": "high",
				"description": "A equipe aplicou KPI de forma consciente durante a Jornada SI.",
				"learning": "KPI significa Key Performance Indicator, ou Indicador-Chave de Desempenho. Ele ajuda a acompanhar objetivos com métricas relevantes e acionáveis."
			},
			{
				"id": "roleta_normal_ciencia_de_dados_mineracao_de_dados_28",
				"topic": "Ciência de Dados",
				"name": "Boa prática: Mineração de Dados",
				"impact": "good",
				"strength": "low",
				"description": "A equipe aplicou Mineração de Dados de forma consciente durante a Jornada SI.",
				"learning": "Mineração de dados aplica técnicas para descobrir padrões, agrupamentos, associações ou classificações. Ela pode fazer parte do processo KDD."
			},
			{
				"id": "roleta_normal_pandas_e_analise_de_dados_groupby_29",
				"topic": "Pandas e Análise de Dados",
				"name": "Falha em GroupBy",
				"impact": "bad",
				"strength": "high",
				"description": "A equipe negligenciou GroupBy e criou risco técnico ou pedagógico.",
				"learning": "Esse risco seria menor com atenção ao conceito: GroupBy é uma operação do Pandas inspirada no padrão split-apply-combine. Ela separa dados por grupos, aplica cálculos e combina os resultados."
			},
			{
				"id": "roleta_normal_qualidade_de_dados_padronizacao_de_dados_30",
				"topic": "Qualidade de Dados",
				"name": "Boa prática: Padronização de Dados",
				"impact": "good",
				"strength": "low",
				"description": "A equipe aplicou Padronização de Dados de forma consciente durante a Jornada SI.",
				"learning": "Padronização de dados evita categorias duplicadas e comparações incorretas. Exemplos comuns envolvem datas, nomes, siglas, letras maiúsculas e unidades de medida."
			}
		],
		"dificil": [
			{
				"id": "roleta_dificil_business_intelligence_data_warehouse_01",
				"topic": "Business Intelligence",
				"name": "Boa prática: Data Warehouse",
				"impact": "good",
				"strength": "high",
				"description": "A equipe aplicou Data Warehouse de forma consciente durante a Jornada SI.",
				"learning": "Data Warehouse é um repositório analítico integrado, histórico e não volátil. Ele consolida dados de várias fontes para consultas, indicadores e análises estratégicas."
			},
			{
				"id": "roleta_dificil_business_intelligence_data_mart_02",
				"topic": "Business Intelligence",
				"name": "Falha em Data Mart",
				"impact": "bad",
				"strength": "low",
				"description": "A equipe negligenciou Data Mart e criou risco técnico ou pedagógico.",
				"learning": "Esse risco seria menor com atenção ao conceito: Data Mart é uma parte menor de um Data Warehouse. Ele atende necessidades de uma área, como vendas, financeiro ou recursos humanos."
			},
			{
				"id": "roleta_dificil_business_intelligence_olap_03",
				"topic": "Business Intelligence",
				"name": "Boa prática: OLAP",
				"impact": "good",
				"strength": "high",
				"description": "A equipe aplicou OLAP de forma consciente durante a Jornada SI.",
				"learning": "OLAP significa Online Analytical Processing. Ele é voltado a consultas analíticas, comparações, agregações e exploração de dados para decisão."
			},
			{
				"id": "roleta_dificil_banco_de_dados_oltp_04",
				"topic": "Banco de Dados",
				"name": "Boa prática: OLTP",
				"impact": "good",
				"strength": "low",
				"description": "A equipe aplicou OLTP de forma consciente durante a Jornada SI.",
				"learning": "OLTP significa Online Transaction Processing. Ele prioriza consistência, rapidez em transações e operações como cadastro, compra, pagamento e atualização."
			},
			{
				"id": "roleta_dificil_data_warehouse_star_schema_05",
				"topic": "Data Warehouse",
				"name": "Falha em Star Schema",
				"impact": "bad",
				"strength": "high",
				"description": "A equipe negligenciou Star Schema e criou risco técnico ou pedagógico.",
				"learning": "Esse risco seria menor com atenção ao conceito: Star Schema, ou esquema estrela, facilita consultas analíticas. A tabela fato guarda métricas, enquanto dimensões descrevem contexto como tempo, produto e local."
			},
			{
				"id": "roleta_dificil_data_warehouse_granularidade_06",
				"topic": "Data Warehouse",
				"name": "Boa prática: Granularidade",
				"impact": "good",
				"strength": "low",
				"description": "A equipe aplicou Granularidade de forma consciente durante a Jornada SI.",
				"learning": "Granularidade indica quão detalhado é um dado. Em Data Warehouse, granularidade baixa guarda mais detalhes; granularidade alta guarda dados mais resumidos."
			},
			{
				"id": "roleta_dificil_governanca_de_dados_metadados_07",
				"topic": "Governança de Dados",
				"name": "Boa prática: Metadados",
				"impact": "good",
				"strength": "high",
				"description": "A equipe aplicou Metadados de forma consciente durante a Jornada SI.",
				"learning": "Metadados são dados sobre dados. Eles ajudam a entender campos, fontes, qualidade, periodicidade, responsáveis e regras de uso."
			},
			{
				"id": "roleta_dificil_mineracao_de_dados_kdd_08",
				"topic": "Mineração de Dados",
				"name": "Falha em KDD",
				"impact": "bad",
				"strength": "low",
				"description": "A equipe negligenciou KDD e criou risco técnico ou pedagógico.",
				"learning": "Esse risco seria menor com atenção ao conceito: KDD significa Knowledge Discovery in Databases, ou Descoberta de Conhecimento em Bases de Dados. Inclui seleção, limpeza, transformação, mineração e interpretação."
			},
			{
				"id": "roleta_dificil_ciencia_de_dados_outlier_09",
				"topic": "Ciência de Dados",
				"name": "Boa prática: Outlier",
				"impact": "good",
				"strength": "high",
				"description": "A equipe aplicou Outlier de forma consciente durante a Jornada SI.",
				"learning": "Outlier pode indicar erro, evento raro ou comportamento relevante. Antes de remover, o analista precisa entender o contexto e o impacto na análise."
			},
			{
				"id": "roleta_dificil_estatistica_e_dados_correlacao_10",
				"topic": "Estatística e Dados",
				"name": "Boa prática: Correlação",
				"impact": "good",
				"strength": "low",
				"description": "A equipe aplicou Correlação de forma consciente durante a Jornada SI.",
				"learning": "Correlação indica se variáveis tendem a variar juntas. Em análise de dados, é importante lembrar que correlação não implica causalidade."
			},
			{
				"id": "roleta_dificil_estatistica_e_dados_amostragem_11",
				"topic": "Estatística e Dados",
				"name": "Falha em Amostragem",
				"impact": "bad",
				"strength": "high",
				"description": "A equipe negligenciou Amostragem e criou risco técnico ou pedagógico.",
				"learning": "Esse risco seria menor com atenção ao conceito: Amostragem reduz custo de coleta e análise, mas precisa ser planejada para evitar vieses e manter representatividade."
			},
			{
				"id": "roleta_dificil_ciencia_de_dados_feature_engineering_12",
				"topic": "Ciência de Dados",
				"name": "Boa prática: Feature Engineering",
				"impact": "good",
				"strength": "low",
				"description": "A equipe aplicou Feature Engineering de forma consciente durante a Jornada SI.",
				"learning": "Feature Engineering envolve preparar atributos, criar indicadores, transformar escalas e extrair sinais úteis. A qualidade das variáveis influencia fortemente modelos de dados."
			},
			{
				"id": "roleta_dificil_engenharia_de_software_acoplamento_13",
				"topic": "Engenharia de Software",
				"name": "Boa prática: Acoplamento",
				"impact": "good",
				"strength": "high",
				"description": "A equipe aplicou Acoplamento de forma consciente durante a Jornada SI.",
				"learning": "Baixo acoplamento facilita manutenção, testes e evolução porque reduz dependências entre partes do sistema."
			},
			{
				"id": "roleta_dificil_engenharia_de_software_coesao_14",
				"topic": "Engenharia de Software",
				"name": "Falha em Coesão",
				"impact": "bad",
				"strength": "low",
				"description": "A equipe negligenciou Coesão e criou risco técnico ou pedagógico.",
				"learning": "Esse risco seria menor com atenção ao conceito: Alta coesão é desejável porque mantém componentes focados em uma responsabilidade clara, melhorando entendimento e manutenção."
			},
			{
				"id": "roleta_dificil_engenharia_de_software_divida_tecnica_15",
				"topic": "Engenharia de Software",
				"name": "Boa prática: Dívida Técnica",
				"impact": "good",
				"strength": "high",
				"description": "A equipe aplicou Dívida Técnica de forma consciente durante a Jornada SI.",
				"learning": "Dívida técnica surge quando a equipe escolhe atalhos. Se não for controlada, aumenta retrabalho, dificulta manutenção e reduz velocidade de evolução."
			},
			{
				"id": "roleta_dificil_arquitetura_de_software_mvc_16",
				"topic": "Arquitetura de Software",
				"name": "Boa prática: MVC",
				"impact": "good",
				"strength": "low",
				"description": "A equipe aplicou MVC de forma consciente durante a Jornada SI.",
				"learning": "MVC significa Model-View-Controller. Ele organiza dados, interface e fluxo de controle em camadas para reduzir mistura de responsabilidades."
			},
			{
				"id": "roleta_dificil_arquitetura_de_software_solid_17",
				"topic": "Arquitetura de Software",
				"name": "Falha em SOLID",
				"impact": "bad",
				"strength": "high",
				"description": "A equipe negligenciou SOLID e criou risco técnico ou pedagógico.",
				"learning": "Esse risco seria menor com atenção ao conceito: SOLID é um conjunto de cinco princípios de projeto de software. Eles orientam responsabilidades claras, baixo acoplamento, extensibilidade e substituição segura."
			},
			{
				"id": "roleta_dificil_poo_polimorfismo_18",
				"topic": "POO",
				"name": "Boa prática: Polimorfismo",
				"impact": "good",
				"strength": "low",
				"description": "A equipe aplicou Polimorfismo de forma consciente durante a Jornada SI.",
				"learning": "Polimorfismo é um princípio da Programação Orientada a Objetos. Ele permite tratar objetos por uma interface comum, mantendo comportamentos especializados."
			},
			{
				"id": "roleta_dificil_gestao_de_projetos_scrum_19",
				"topic": "Gestão de Projetos",
				"name": "Boa prática: Scrum",
				"impact": "good",
				"strength": "high",
				"description": "A equipe aplicou Scrum de forma consciente durante a Jornada SI.",
				"learning": "Scrum é um framework ágil com papéis como Product Owner, Scrum Master e Developers. Ele usa Sprints, Backlog e revisões para adaptação contínua."
			},
			{
				"id": "roleta_dificil_governanca_de_ti_cobit_20",
				"topic": "Governança de TI",
				"name": "Falha em COBIT",
				"impact": "bad",
				"strength": "low",
				"description": "A equipe negligenciou COBIT e criou risco técnico ou pedagógico.",
				"learning": "Esse risco seria menor com atenção ao conceito: COBIT significa Control Objectives for Information and Related Technologies. Ele apoia governança, controle, valor, riscos e alinhamento estratégico de TI."
			},
			{
				"id": "roleta_dificil_governanca_de_ti_itil_21",
				"topic": "Governança de TI",
				"name": "Boa prática: ITIL",
				"impact": "good",
				"strength": "high",
				"description": "A equipe aplicou ITIL de forma consciente durante a Jornada SI.",
				"learning": "ITIL significa Information Technology Infrastructure Library. Ela trata serviços, incidentes, mudanças, problemas, níveis de serviço e melhoria contínua."
			},
			{
				"id": "roleta_dificil_governanca_de_ti_sla_22",
				"topic": "Governança de TI",
				"name": "Boa prática: SLA",
				"impact": "good",
				"strength": "low",
				"description": "A equipe aplicou SLA de forma consciente durante a Jornada SI.",
				"learning": "SLA significa Service Level Agreement, ou Acordo de Nível de Serviço. Ele define metas como disponibilidade, tempo de resposta e prazo de atendimento."
			},
			{
				"id": "roleta_dificil_continuidade_de_negocio_rto_e_rpo_23",
				"topic": "Continuidade de Negócio",
				"name": "Falha em RTO e RPO",
				"impact": "bad",
				"strength": "high",
				"description": "A equipe negligenciou RTO e RPO e criou risco técnico ou pedagógico.",
				"learning": "Esse risco seria menor com atenção ao conceito: RTO significa Recovery Time Objective, ou tempo máximo para restaurar o serviço. RPO significa Recovery Point Objective, ou ponto máximo aceitável de perda de dados."
			},
			{
				"id": "roleta_dificil_ciberseguranca_zero_trust_24",
				"topic": "Cibersegurança",
				"name": "Boa prática: Zero Trust",
				"impact": "good",
				"strength": "low",
				"description": "A equipe aplicou Zero Trust de forma consciente durante a Jornada SI.",
				"learning": "Zero Trust, ou confiança zero, exige verificação contínua de identidade, contexto e permissões. A ideia central é nunca confiar por padrão."
			},
			{
				"id": "roleta_dificil_ciberseguranca_menor_privilegio_25",
				"topic": "Cibersegurança",
				"name": "Boa prática: Menor Privilégio",
				"impact": "good",
				"strength": "high",
				"description": "A equipe aplicou Menor Privilégio de forma consciente durante a Jornada SI.",
				"learning": "O princípio do menor privilégio reduz danos em caso de falha ou invasão. Usuários e sistemas não devem ter acessos além do necessário."
			},
			{
				"id": "roleta_dificil_ciberseguranca_oauth_2_0_26",
				"topic": "Cibersegurança",
				"name": "Falha em OAuth 2.0",
				"impact": "bad",
				"strength": "low",
				"description": "A equipe negligenciou OAuth 2.0 e criou risco técnico ou pedagógico.",
				"learning": "Esse risco seria menor com atenção ao conceito: OAuth 2.0 é um protocolo de autorização. Ele permite que uma aplicação acesse recursos em nome do usuário por meio de tokens controlados."
			},
			{
				"id": "roleta_dificil_ciberseguranca_jwt_27",
				"topic": "Cibersegurança",
				"name": "Boa prática: JWT",
				"impact": "good",
				"strength": "high",
				"description": "A equipe aplicou JWT de forma consciente durante a Jornada SI.",
				"learning": "JWT significa JSON Web Token. Ele é usado para representar claims, como identidade e permissões, mas precisa de expiração, assinatura e armazenamento seguro."
			},
			{
				"id": "roleta_dificil_devops_observabilidade_28",
				"topic": "DevOps",
				"name": "Boa prática: Observabilidade",
				"impact": "good",
				"strength": "low",
				"description": "A equipe aplicou Observabilidade de forma consciente durante a Jornada SI.",
				"learning": "Observabilidade combina sinais como logs, métricas e rastreamento distribuído. Ela ajuda a investigar falhas, gargalos e comportamento em produção."
			},
			{
				"id": "roleta_dificil_devops_e_cloud_iac_29",
				"topic": "DevOps e Cloud",
				"name": "Falha em IaC",
				"impact": "bad",
				"strength": "high",
				"description": "A equipe negligenciou IaC e criou risco técnico ou pedagógico.",
				"learning": "Esse risco seria menor com atenção ao conceito: IaC significa Infrastructure as Code, ou Infraestrutura como Código. Ela torna ambientes reproduzíveis, auditáveis e menos dependentes de configuração manual."
			},
			{
				"id": "roleta_dificil_lgpd_e_etica_privacidade_por_design_30",
				"topic": "LGPD e Ética",
				"name": "Boa prática: Privacidade por Design",
				"impact": "good",
				"strength": "low",
				"description": "A equipe aplicou Privacidade por Design de forma consciente durante a Jornada SI.",
				"learning": "Privacidade por design coloca proteção de dados no planejamento, arquitetura e operação. Ela se relaciona com minimização, finalidade, segurança e transparência."
			}
		]
	}
}

static var _recent_ids_by_key: Dictionary = {}
static var _recent_topics_by_difficulty: Dictionary = {}
static var _recent_signatures_by_difficulty: Dictionary = {}

static func get_bank(minigame: String, difficulty: String) -> Array:
	var game_banks: Dictionary = BANKS.get(minigame, {})
	if game_banks.is_empty():
		return []
	var diff: String = difficulty
	if not game_banks.has(diff):
		diff = "normal"
	return game_banks.get(diff, []).duplicate(true)

static func pick_rounds(minigame: String, difficulty: String, count: int = ROUND_COUNT) -> Array:
	var pool: Array = get_bank(minigame, difficulty)
	if pool.is_empty():
		return []
	var key: String = "%s:%s" % [minigame, difficulty]
	var recent_ids: Array = _recent_ids_by_key.get(key, [])
	var recent_topics: Array = _recent_topics_by_difficulty.get(difficulty, [])
	var recent_signatures: Array = _recent_signatures_by_difficulty.get(difficulty, [])
	var picked: Array = _pick_diverse(pool, count, recent_ids, recent_topics, recent_signatures, true)
	if picked.size() < count:
		picked = _pick_diverse(pool, count, recent_ids, recent_topics, recent_signatures, false)
	if picked.size() < count:
		recent_ids = []
		picked = _pick_diverse(pool, count, recent_ids, [], [], false)
	_register_recent_ids(key, pool.size(), count, picked)
	_register_recent_content(difficulty, picked)
	return picked

static func _pick_diverse(pool: Array, count: int, recent_ids: Array, recent_topics: Array, recent_signatures: Array, avoid_cross_content: bool) -> Array:
	var shuffled: Array = pool.duplicate(true)
	shuffled.shuffle()
	var picked: Array = []
	var picked_ids: Dictionary = {}
	var used_topics: Dictionary = {}
	var used_signatures: Dictionary = {}

	for item in shuffled:
		if picked.size() >= count:
			break
		if not item is Dictionary:
			continue
		var data: Dictionary = item as Dictionary
		var item_id: String = str(data.get("id", ""))
		var topic: String = _get_item_topic(data)
		var signature: String = _get_item_signature(data)
		if recent_ids.has(item_id):
			continue
		if used_topics.has(topic):
			continue
		if signature != "" and used_signatures.has(signature):
			continue
		if avoid_cross_content and recent_topics.has(topic):
			continue
		if avoid_cross_content and signature != "" and recent_signatures.has(signature):
			continue
		picked.append(data.duplicate(true))
		picked_ids[item_id] = true
		used_topics[topic] = true
		if signature != "":
			used_signatures[signature] = true

	for item in shuffled:
		if picked.size() >= count:
			break
		if not item is Dictionary:
			continue
		var data: Dictionary = item as Dictionary
		var item_id: String = str(data.get("id", ""))
		var signature: String = _get_item_signature(data)
		if picked_ids.has(item_id) or recent_ids.has(item_id):
			continue
		if signature != "" and used_signatures.has(signature):
			continue
		if avoid_cross_content and signature != "" and recent_signatures.has(signature):
			continue
		picked.append(data.duplicate(true))
		picked_ids[item_id] = true
		if signature != "":
			used_signatures[signature] = true

	for item in shuffled:
		if picked.size() >= count:
			break
		if not item is Dictionary:
			continue
		var data: Dictionary = item as Dictionary
		var item_id: String = str(data.get("id", ""))
		if picked_ids.has(item_id):
			continue
		picked.append(data.duplicate(true))
		picked_ids[item_id] = true

	return picked

static func _get_item_topic(data: Dictionary) -> String:
	return str(data.get("topic", data.get("area", data.get("categoria", "Geral"))))

static func _get_item_signature(data: Dictionary) -> String:
	if data.has("word"):
		return str(data.get("word", "")).strip_edges().to_lower()
	if data.has("correta"):
		return str(data.get("correta", "")).strip_edges().to_lower()
	if data.has("resposta") and data.has("opcoes"):
		var options_value: Variant = data.get("opcoes", {})
		if options_value is Dictionary:
			var options: Dictionary = options_value as Dictionary
			var answer_key: String = str(data.get("resposta", ""))
			return str(options.get(answer_key, "")).strip_edges().to_lower()
	if data.has("controle"):
		return str(data.get("controle", "")).strip_edges().to_lower()
	if data.has("ameaca"):
		return str(data.get("ameaca", "")).strip_edges().to_lower()
	if data.has("name"):
		return str(data.get("name", "")).strip_edges().to_lower()
	return ""

static func _register_recent_ids(key: String, pool_size: int, count: int, picked: Array) -> void:
	var recent_ids: Array = _recent_ids_by_key.get(key, [])
	for item in picked:
		if item is Dictionary:
			var data: Dictionary = item as Dictionary
			var item_id: String = str(data.get("id", ""))
			if item_id != "" and not recent_ids.has(item_id):
				recent_ids.append(item_id)
	var max_recent: int = maxi(0, pool_size - count)
	while max_recent > 0 and recent_ids.size() > max_recent:
		recent_ids.pop_front()
	if max_recent <= 0:
		recent_ids.clear()
	_recent_ids_by_key[key] = recent_ids

static func _register_recent_content(difficulty: String, picked: Array) -> void:
	var recent_topics: Array = _recent_topics_by_difficulty.get(difficulty, [])
	var recent_signatures: Array = _recent_signatures_by_difficulty.get(difficulty, [])
	for item in picked:
		if not item is Dictionary:
			continue
		var data: Dictionary = item as Dictionary
		var topic: String = _get_item_topic(data)
		var signature: String = _get_item_signature(data)
		if topic != "" and not recent_topics.has(topic):
			recent_topics.append(topic)
		if signature != "" and not recent_signatures.has(signature):
			recent_signatures.append(signature)
	while recent_topics.size() > 12:
		recent_topics.pop_front()
	while recent_signatures.size() > 18:
		recent_signatures.pop_front()
	_recent_topics_by_difficulty[difficulty] = recent_topics
	_recent_signatures_by_difficulty[difficulty] = recent_signatures
