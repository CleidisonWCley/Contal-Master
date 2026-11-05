# V0.11.2 — Feedback Pedagógico e Balanceamento da Forca Técnica

## Objetivo

Refinar a experiência de aprendizado do Party Pascal para que os cards de acerto e erro não apenas informem se o jogador acertou, mas expliquem de forma objetiva o motivo da resposta correta.

## Ajustes aplicados

### Forca Técnica

- O limite de erros agora respeita a dificuldade:
  - Fácil: 14 erros possíveis
  - Normal: 10 erros possíveis
  - Difícil: 6 erros possíveis
- A integridade do sistema passou a ser calculada proporcionalmente ao limite de erros da dificuldade.
- Os estados do sistema passaram a usar percentual de integridade, mantendo consistência entre fácil, normal e difícil.
- O feedback de rodada agora mostra o termo correto e uma explicação curta baseada na dica/área técnica.
- A pontuação por termo usa bônus proporcional à integridade preservada, evitando que o modo fácil gere vantagem excessiva apenas por ter mais erros disponíveis.

### Feedback manual

- O botão dos cards de feedback foi simplificado de `Entendi, continuar` para `Continuar`.

### Cards pedagógicos

Foram refinados os cards de resposta dos minigames:

- Show do Bilhão
- Maleta Certa
- Perseguição
- Batalha Naval
- STOP
- Forca Técnica
- Roleta de Risco

O novo padrão busca manter explicações curtas, com foco em:

- motivo do acerto;
- justificativa do erro;
- resposta correta;
- explicação objetiva da resposta correta.

## Critérios de aceite

- Forca Técnica usa 14/10/6 erros conforme dificuldade.
- O texto do botão de feedback aparece como `Continuar`.
- Os feedbacks de acerto explicam por que a resposta está correta.
- Os feedbacks de erro mostram a resposta correta e uma justificativa objetiva.
- Nenhum card de feedback volta a avançar automaticamente.
