# Roteiro Narrativo — Contal Master V0.10.1 (atualizado na V0.10.2)

> **Atualização V0.11:** a campanha agora acontece em **dois dias** (dia 1: Show do Bilhão até STOP; dia 2: Desvio Lógico), com cenários próprios por cutscene e uma nova cena final. Veja [V0.11 — Dois Dias](V0_11_DOIS_DIAS_CENARIOS_NUMERADOS_FINALE_DOURADO.md). Os textos de intro, estações 1/4/7/8 e final abaixo mudaram nessa versão; a fonte da verdade continua sendo `scripts/data/dialogues/*.json`.

Fonte dos textos: `scripts/data/dialogues/*.json` (editáveis sem tocar em código).

## 1. Premissa (começo)
- A **ContalMaster** é uma firma de auditoria que funciona como uma família, liderada pelo **Jales**.
- **Amanhã às 9h** a firma passa pela **revisão pelos pares (NBC PA 11)**. Se passar, ganha o selo de excelência.
- O jogador é o **olhar novo** que o Jales convida para percorrer a firma ao longo do dia. Em cada estação um especialista o desafia e, ao vencer, entrega um **Selo de Qualidade**.
- **Por que o jogador joga:** ajudar a firma a se preparar e, no caminho, treinar o raciocínio de um revisor de verdade.
- **Fim do dia:** a equipe se reúne na sala de reunião para agradecer e mostrar o resultado.

## 2. Arco em três atos
- **Começo (estações 1 a 3):** conhecimento e método. Norma, evidências e pareceres: o jogador aprende o que a revisão exige.
- **Meio (estações 4 a 6):** incerteza e pressão. A roleta traz o imprevisto, a perseguição aperta o prazo e a Aline cobra precisão. É o ponto de virada: o dia fica difícil.
- **Fim (estações 7 e 8):** controle e ética. O STOP exige domínio rápido e o Desvio Lógico pede a decisão mais difícil. Depois, a sala de reunião.

## 3. Elenco e personalidade
| Personagem | Papel | Traços (JSON) | Como demonstra afeto |
|---|---|---|---|
| Priscila | Líder de Checagem Normativa & Compliance | Rigorosa, Analítica, Perfeccionista, Incentivadora | Rigorosa, mas torce por cada um |
| Anderson | Especialista em Estratégia & Mapeamento de Evidências | Entusiasta, Agitado, Estrategista, Bem-humorado | Brinca e anima, chama o jogador de navegador |
| Tiago | Auditor Assistente / Especialista em Emissão de Pareceres | Entusiasta, Didático, Prestativo, Motivado | Aprende junto e agradece o tempo todo |
| Julios | Especialista em Riscos Profissionais & Ética | Arrogante, Sarcástico, Provocador, Peculiar | Provoca, mas admite que se importa |
| Ariel | Analista de Campo & Inspeção de Inconsistências | Observador, Calmo sob pressão, Direto, Agil | Poucas palavras, respeito direto |
| Aline | Professora & Mentora de Rigor Normativo | Perfeccionista, Aristocrática, Sarcástica, Exigente | Exigente porque acredita no potencial |
| Cleiton | Auditor Sênior & Especialista em Controle Normativo | Gentil, Muito Sério, Pragmático, Focado | Gentileza séria, honra o trabalho do outro |
| Natalia | Especialista Sênior em Raciocínio Crítico & Análise de Desvios Éticos | Extremamente Carismática, Acolhedora, Sorridente, Gentil, Encantadora | Acolhe, acompanha e se orgulha |
| Jales | Líder da equipe ContalMaster | Acolhedor, orgulhoso da equipe, guia | Apresenta cada especialista e fecha a jornada |

## 4. Estações (transição = título + novel de 3 quadros)
Cada transição mostra o **título** e em seguida a novel: (1) o Jales apresenta o especialista, que **sobe** na tela ao fim da fala; (2) o especialista se apresenta; (3) ele justifica o minigame na história, cita o selo e avisa que vai explicar. Depois entra o tutorial, só com o anfitrião.

| # | Minigame | Selo | Foco pedagógico |
|---|---|---|---|
| 1 | Show do Bilhão | Selo da Norma | Conhecimento teórico (NBC PA 11: prazos, ciclos, órgãos) |
| 2 | Batalha Naval | Selo da Evidência | Evidências e inconsistências em papéis de trabalho |
| 3 | Maleta Certa | Selo do Parecer | Escolha da conclusão/conduta correta |
| 4 (bônus) | Roleta de Risco | — (rodada bônus) | Riscos profissionais e ética: conflito de interesse, familiaridade, intimidação |
| 5 | Perseguição | Selo do Prazo | Não conformidades sob pressão de tempo |
| 6 | Forca Técnica | Selo da Terminologia | Glossário técnico e precisão de termos |
| 7 | STOP | Selo do Controle | Vocabulário normativo e categorização rápida |
| 8 | Desvio Lógico | Selo da Ética | Decisão ética sob risco e confidencialidade |

### Estação 1: Show do Bilhão — Priscila
- **Jales** — *Primeira Estação: A Norma*: Primeira estação do nosso dia! A revisão pelos pares de amanhã começa pela norma, e quem cuida dela é a Priscila, nossa líder de checagem normativa. Ela não perdoa 'achismo'... mas torce por cada um de nós.
- **Priscila** — *Prazer, Priscila*: Prazer em conhecê-lo! Sou a Priscila e cuido do que não pode falhar: prazos, ciclos e órgãos da NBC PA 11. O talento não substitui a precisão, mas com dedicação você chega lá.
- **Priscila** — *O Desafio: Show do Bilhão*: Por isso criamos o Show do Bilhão: um quiz direto sobre as regras formais, sem espaço para achismos. Acertando, você conquista o Selo da Norma. Vou te mostrar como funciona e depois é com você!

### Estação 2: Batalha Naval — Anderson
- **Jales** — *Segunda Estação: As Evidências*: Com a norma na mão, vamos às evidências! O Anderson é apaixonado por estratégia e transformou a checagem de papéis de trabalho em um verdadeiro mapa tático.
- **Anderson** — *Anderson na Área*: Eae! Anderson na área! Pra mim auditoria é navegação: se você não varre cada coordenada da documentação, a falha afunda o projeto inteiro. Preparado?
- **Anderson** — *O Desafio: Batalha Naval*: Por isso a Batalha Naval: um mapa tático em que cada coordenada pode esconder uma falha nos papéis de trabalho. Mira afiada garante o Selo da Evidência. Deixa que eu mostro como funciona!

### Estação 3: Maleta Certa — Tiago
- **Jales** — *Terceira Estação: O Parecer*: Agora é hora de concluir! Quem vai te guiar é o Tiago, o mais novo da equipe. Chegou há pouco, mas já preparou uma dinâmica super prática sobre pareceres de auditoria.
- **Tiago** — *Muito Prazer, Tiago*: Muito prazer, eu sou o Tiago! Ainda sou novo por aqui, mas aprendi rápido: saber qual conclusão emitir depois de analisar as evidências é o coração do nosso trabalho.
- **Tiago** — *O Desafio: Maleta Certa*: Por isso a Maleta Certa: cada cenário pede a conclusão certa, e acertar rende o Selo do Parecer. Pode contar comigo, eu te explico como funciona!

### Estação 4 (bônus): Roleta de Risco — Julios
- **Jales** — *Rodada Bônus: O Imprevisto*: (Suspiro)... Metade do dia já passou e chegou a rodada bônus. Esta é a estação do Julios. Figura peculiar e um tanto arrogante, eu admito, mas ninguém fareja riscos como ele.
- **Julios** — *Julios, o Provocador*: Então você é o novo revisor? Que fofo. Achava que auditoria era só olhar planilha bonitinha? No mundo real você tropeça em conflito de interesse, familiaridade e intimidação sem nem perceber.
- **Julios** — *O Desafio: Roleta de Risco*: A Roleta de Risco mostra o que acontece quando o imprevisto bate à porta: o que cair, você encara. Vamos ver se tem coragem... ou tolice. Não que eu me importe, claro.

### Estação 5: Perseguição — Ariel
- **Jales** — *Quinta Estação: O Prazo*: O relógio da revisão não para, e agora ele aperta! Esta é a estação do Ariel, nosso analista de campo: calmo sob pressão e implacável na inspeção rápida.
- **Ariel** — *Ariel em Campo*: E aí. Ariel. Na auditoria real, inconsistência não pede licença para surgir e o relógio do relatório não espera ninguém. Vacilou, perdeu o prazo.
- **Ariel** — *O Desafio: Perseguição*: Na Perseguição, raciocínio lento custa caro. Identifique e resolva as não conformidades antes que o tempo te alcance. Quem for ágil leva o Selo do Prazo. Vou te mostrar o ritmo.

### Estação 6: Forca Técnica — Aline
- **Jales** — *Sexta Estação: A Terminologia*: Agora a instrutora Aline vai testar a assimilação dos conceitos centrais. Ela é exigente e perfeccionista... e a maior defensora de cada um de nós. Boa sorte. Você vai precisar!
- **Aline** — *Aline, a Mentora*: Bem-vindo. Sou a Aline, mas pode me chamar de Malfoid, se tiver coragem. Espero que não me façam perder tempo: o domínio exato dos termos é a única garantia de clareza nos nossos relatórios.
- **Aline** — *O Desafio: Forca Técnica*: Por isso a Forca Técnica: os termos do nosso glossário precisam estar na ponta da língua. Erre e verá seu prestígio enforcado. Acerte, e quem sabe eu admita que você merece o Selo da Terminologia.

### Estação 7: STOP — Cleiton
- **Jales** — *Sétima Estação: O Controle*: Estamos na reta final! Auditores de excelência dominam os conceitos com precisão imediata. Quero te apresentar o Cleiton: ele é muito gentil, mas não brinca em serviço quando o assunto é técnica.
- **Cleiton** — *Cleiton, Controle Normativo*: Olá, muito prazer. Sou o Cleiton. Na nossa rotina de avaliação de papéis de trabalho não há espaço para hesitação: o vocabulário normativo precisa estar rigorosamente na ponta da língua.
- **Cleiton** — *O Desafio: STOP*: Por isso o STOP: sua agilidade mental será testada com órgãos, normas e documentos. Respire fundo, mantenha o foco e o Selo do Controle será seu. Eu explico como funciona.

### Estação 8: Desvio Lógico — Natalia
- **Jales** — *Última Estação: A Ética*: Chegamos à última estação e, confesso, estou orgulhoso de você. Quem fecha o dia é a Natalia, nossa especialista em raciocínio crítico, com uma energia incrível para guiar o momento mais desafiador.
- **Natalia** — *Natalia, de Coração*: Que alegria ter você aqui! Na pista ou na auditoria, um desvio ético mal calculado pode comprometer a confidencialidade e o trabalho de toda a equipe. Mas eu sei que você tem clareza para escolher bem!
- **Natalia** — *O Desafio: Desvio Lógico*: No Desvio Lógico, as bifurcações testam seus reflexos e a sua ética ao limite. Respire fundo, confie no seu potencial e venha ver a pista comigo. Depois dela, a sala de reunião nos espera. Estou torcendo por você!

## 5. Briefing de abertura (Jales)

- *Bem-vindo ao ContalMaster!*: Olá! Que bom ter você aqui! Sou o Jales, líder da equipe ContalMaster. Aqui a gente trabalha com muito rigor, mas cuida uns dos outros como uma família.
- *A revisão pelos pares*: Amanhã às 9h, outra firma vai revisar o nosso controle de qualidade: a revisão pelos pares da NBC PA 11. Se passarmos, a ContalMaster ganha o selo de excelência.
- *Por que você?*: Preciso de um olhar novo para percorrer a firma comigo hoje. Em cada estação, um especialista vai te desafiar. Aprender a interpretar cenários é a melhor preparação para uma revisão de verdade.
- *Sua jornada começa agora*: São 8 estações, 8 especialistas e uma sala de reunião esperando no fim do dia. Eu estarei por perto o tempo todo. Vamos começar?

## 6. Cutscene final
Ordem: despedida do Jales → Natalia chama para a reunião → corte para a narração de apoio → elenco reunido agradecendo → Ariel anuncia o placar → o score sobe → fala final do Jales (por desempenho) → créditos. As trocas de personagem usam fade e *subida*.

### 6.1 Despedida do Jales
- **Jales** — *Missão cumprida*: Chegamos ao fim da nossa jornada! Percorremos as oito estações lado a lado e, sinceramente, foi um prazer ter você na equipe hoje.
- **Jales** — *Uma família*: Cada especialista deixou um pouco do que sabe com você. É isso que faz da ContalMaster uma família, e a partir de hoje você faz parte dela.

### 6.2 Natalia chama para a sala de reunião
- **Natalia** — *Sala de reunião*: Jales, o pessoal já está todo reunido! Ei, venha comigo, a equipe inteira está esperando você na sala de reunião. Ninguém quis começar sem você, sabia?
- **Natalia** — *Venha comigo*: Vamos? Eu te acompanho até lá. E não fique nervoso: hoje o assunto é só agradecer. Estou muito orgulhosa de você!

### 6.3 Narração de apoio (Natalia)
- **Natalia · apoio**: Enquanto caminhamos até a sala, respire fundo e olhe para trás. Você começou o dia aprendendo a norma e termina tomando decisões éticas.
- **Natalia · apoio**: Errar fez parte do caminho: cada tropeço virou uma explicação que você não esquece mais. É assim que bons auditores se formam, um erro corrigido de cada vez.
- **Natalia · apoio**: O que você leva daqui vai além de pontos. É um jeito de pensar com rigor, cuidado e coragem, e isso ninguém tira de você.

### 6.4 Elenco reunido agradecendo
- **Jales** — *A equipe reunida*: Pessoal, nosso revisor chegou! Vamos dar a ele as boas-vindas que merece.
- **Priscila** — *A Norma*: Cada prazo e cada ciclo da norma, você respeitou. Obrigada por levar a precisão a sério. É isso que sustenta uma revisão.
- **Anderson** — *As Evidências*: Eae, navegador! Você varreu o mapa inteiro e não deixou nenhuma falha afundar a gente. Valeu demais!
- **Tiago** — *O Parecer*: Eu aprendi um monte te vendo trabalhar! Obrigado por mostrar que um parecer bem pensado faz toda a diferença.
- **Julios** — *O Imprevisto*: Tá, tá... você girou a roleta e encarou o risco. Admito que não foi tolice. Não conte pra ninguém que eu disse isso.
- **Ariel** — *O Prazo*: Você manteve a calma com o relógio correndo. Respeito. Obrigado por jogar com a gente.
- **Aline** — *A Terminologia*: Hmpf. Seu vocabulário melhorou a olhos vistos. Fico... satisfeita. Não se acostume com o elogio.
- **Cleiton** — *O Controle*: Foi uma honra revisar papéis ao seu lado. Obrigado pela seriedade e pela gentileza com que você jogou.
- **Natalia** — *A Ética*: E obrigada por cada escolha cuidadosa. Foi um prazer te guiar até aqui, de coração.
- **Jales** — *Todos juntos*: Em nome de toda a equipe ContalMaster: obrigado por jogar e por superar cada desafio com a gente!

## 7. Finais por desempenho (4 variações)
A nota é a razão entre os pontos e a referência da dificuldade escolhida (escala da conquista Platina). Os limites ficam em `final.json` (`min_ratio`).

### Mestre da Revisão (a partir de 80% da referência)
- **Ariel:** Antes que alguém saia: eu anotei tudo, ponto por ponto. Prepare-se, essa pontuação chamou a atenção até do Julios.
- **Jales** — *Que desempenho!*: Você dominou as oito estações com precisão de veterano. Se a revisão de amanhã dependesse só de você, eu dormiria tranquilo.
- **Jales** — *Sempre dá para ir além*: Mas quem é bom continua estudando. Que tal tentar o nível Difícil e superar o seu próprio recorde? Nós estaremos aqui. Obrigado, de coração.

### Revisor de Confiança (a partir de 55% da referência)
- **Ariel:** Antes que alguém saia: eu anotei tudo, ponto por ponto. Vamos ver como foi a sua jornada.
- **Jales** — *Ótimo trabalho!*: Seu desempenho foi sólido e mostrou que você entende o que está fazendo. Dá para confiar em você numa revisão.
- **Jales** — *Falta pouco*: Ainda existem pontos para lapidar e você sabe quais são: treine os minigames em que tropeçou no modo livre e volte para a campanha. A ContalMaster te espera!

### Revisor em Evolução (a partir de 30% da referência)
- **Ariel:** Antes que alguém saia: eu anotei tudo. Vamos olhar o placar com calma, porque cada ponto aqui conta uma história.
- **Jales** — *Você chegou ao fim!*: E isso já diz muito sobre você. Teve acertos bonitos e alguns tropeços, e todo auditor passa por isso no começo.
- **Jales** — *Vamos de novo?*: Que tal rever no modo livre os minigames mais difíceis e tentar a campanha outra vez? Cada rodada afia o seu raciocínio. Estou torcendo por você!

### Revisor em Formação (a partir de 0% da referência)
- **Ariel:** Sem pressa. O placar mostra onde estamos hoje, e é daqui que a gente começa. Eu anotei tudo.
- **Jales** — *Olhe só onde você chegou*: Você terminou a jornada, e muita gente nem chega até aqui. Isso exige coragem, e coragem é a base de um bom auditor.
- **Jales** — *O começo de tudo*: A pontuação de hoje é só o ponto de partida. Treine no modo livre, tente o nível Fácil e volte quando quiser. A gente acredita em você!

## 8. Observação sobre a ordem das estações
Os textos assumem a ordem atual do código (`GameManager.PHASES`): Show, Naval, Maleta, Roleta (bônus), Perseguição, Forca, STOP, Desvio. Se a ordem mudar, ajuste apenas os títulos "Primeira/Segunda... Estação" e a fala "metade do dia já passou" na Roleta.
