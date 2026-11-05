# CM-V0.9.2.1 — Inclusão total ao Contal Master

> Primeira versão do projeto sob o nome **Contal Master** (ainda pré-oficial: por isso o `0.` à frente).

## Objetivo
Transformar o jogo, antes com tema de TI e sob outro nome, no Contal Master de **auditoria contábil**, com banco de perguntas novo e identidade própria.

## Entregue nesta versão
**Conteúdo (banco de auditoria, base NBC PA 11 R1)**
- `question_bank.gd` + 4 JSONs: quiz (44), dilemas (24), dicionário (51 termos), matriz de riscos (45 ameaças + 37 eventos de roleta).
- Ferramentas: `validar_banco.py`, `selftest_question_bank.gd`, `aplicar_integracao.py`.
- Integração nas cenas, STOP e Roleta lendo os JSONs, `*.json` incluído no export.

**Marca e versão**
- Versão `0.9.2.1` unificada; nome do projeto, APK e artefato de CI renomeados.
- Selo no menu e créditos do final com "Contal" branco + "Master" roxo (`BrandText.gd`, tokens `BRAND_*`).
- Remoção do nome anterior de código, textos e saves (com migração do save antigo).
- `verificar_marca.py` confere ausência do nome anterior e consistência da versão.

**Documentação**
- Versionamento reorganizado em faixas 0.1–0.9 (Antes · Agora · A implementar), mapa do legado e roadmap até 1.0.0.

## Decisões sobre as fontes (banco de auditoria)
- **Guarda de documentos:** 7 anos desde a emissão do relatório (NBC PA 11, item 28g); o Anexo 2 das Instruções do CRE diverge, e a norma prevaleceu.
- **Auditoria recente do revisor:** 2 anos (item 26i).
- **Carta de recomendações:** obrigatória (item 45), embora a base do jogo diga "quando necessário".
- **Investimento em cliente do revisado:** permitido, mas o membro não revisa aquele cliente (item 23).
- **Relatório "com deficiências"** não impede atuar como revisor (item 26b).
- **Datas anuais do CRE** não entram no banco (mudam a cada ciclo). A Instrução CVM 308/99 citada nas Instruções de 2020 foi substituída pela Resolução CVM 23/2021.
- Conteúdo específico de Susep/Previc ficou de fora: as provas de apoio vieram sem gabarito.

## Fora do escopo (vai para o roadmap)
História/cutscenes ainda no tema anterior · fallbacks de TI nas cenas · conquistas · identidade visual (logo/ícone) · expansão do banco · validação dentro do Godot.

## Teste manual sugerido
1. Menu: selo "Contal Master V0.9.2.1" alinhado à direita, "Master" em roxo.
2. Jogar cada minigame nas 3 dificuldades; conferir se algum texto corta.
3. Campanha até o final: título e versão nos créditos em duas cores.
4. Com um save antigo no aparelho: abrir e confirmar que o progresso foi mantido.
5. `python3 _ferramentas/validar_banco.py` e `verificar_marca.py` → OK.
