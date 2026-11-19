# V0.16.3 — Acessibilidade: tamanho da fonte

Foco: jogadores com dificuldade de visão. Nova opção **Fonte** (Pequena · Média · Grande · Extra grande) nas
**Configurações do menu** e nas **Configurações do pause**. Padrão = **Média** (o jogo continua idêntico ao da 0.16.2).

## Como funciona
- **`scripts/autoloads/FontScale.gd`** (autoload novo, depois do `SettingsManager`): ponto único de tamanho de letra.
  Fatores: Pequena 0,85 · Média 1,00 · Grande 1,20 · Extra grande 1,40.
  Textos de destaque (base > 28 px, ex.: títulos) crescem proporcionalmente menos para não estourar a tela.
- Todo `add_theme_font_size_override(...)` virou `FontScale.set_size(controle, TAMANHO_BASE)` (o base é o tamanho "Média").
  Ao trocar a opção, **todos os textos na tela são refeitos na hora** (menu e pause, sem reiniciar cena).
  Controles vindos de `.tscn` são "adotados" automaticamente ao entrar na árvore.
- Exceções (`FontScale.skip`): símbolos decorativos flutuantes e os rótulos dos gomos da Roleta do Risco (tamanho fixo por gomo).
- **`SettingsManager`**: chave `font_size_level` (`pequena|media|grande|extra_grande`), saneada ao carregar; salva na hora.
- **`scripts/ui/FontSizeSelector.gd`** + ícone `icon_font.svg`: seletor reutilizado no menu (linha na seção TELA) e no pause (grade 2×2).

## Ajustes de layout por fonte maior
- Modo de jogo / Arquivos da equipe: faixa de texto dos cartões e cartões maiores.
- Modo livre: menos colunas, cartões mais largos/altos.
- Pontuação: painéis empilhados em Extra grande; alturas escalam.
- Configurações: botões em coluna única e linha "Fonte" empilhada em Grande/Extra grande; botões de dificuldade crescem.
- Pause: "Voltar" fixo fora da rolagem. Seletor de dificuldade e caixas de diálogo (introdução/novel) crescem com a fonte.

## Testes
`tools/tests/font_scale_audit.tscn` abre cada tela nos 4 tamanhos, tira print e aponta texto cortado/fora da tela:
`xvfb-run -a godot --path . --rendering-driver opengl3 --resolution 1280x720 res://tools/tests/font_scale_audit.tscn -- out=/tmp/shots [only=Settings] [levels=media,extra_grande] [pause]`
Testado no Godot 4.5 (1280×720) em 21 telas × 4 tamanhos + pause aberto. Em Grande/Extra grande várias telas passam a rolar.
Não coberto: janelas compactas/celular em Extra grande, Debrief da fase, tutoriais.
