# Questão 08 — Entrega

## Framework escolhido

**B-A-B (Before — After — Bridge)**

## Prompt

[`prompt.md`](./prompt.md)

## Modelo

**Claude Sonnet 4** (Anthropic)

Análise causal sob pressão de tempo com evidências heterogêneas (métricas, logs, fila) — Claude estrutura bem narrativa Before→After e comparação de opções técnicas.

## Output

[`output.md`](./output.md) · Postmortem: [`postmortem-chronos-v248.md`](./postmortem-chronos-v248.md).

## Justificativa (componentes B-A-B)

**Before** ancora baseline 13:30, changelog v2.48.0 e cluster não CPU-bound; **After** separa colapso atual vs alvo numérico pós-ação; **Bridge** exige timeline, cadeia causal, matriz rollback vs scaling e recomendação em 20 min. O prompt embute todos os artefatos do enunciado no [Before].

**Retrabalho:** primeira resposta priorizou scaling RDS pelo 240/250 — subestimou pool `max=20` e timeout 2s do deploy; regenerei com matriz A/B explícita (ver `output.md`).

---

## Comparação com alternativas (≥ 2)

### vs **R-I-S-E** (usado na Q7)

| | Ganho | Perda |
|---|--------|-------|
| R-I-S-E | `[Steps]` com comandos e limiares — ótimo para plantonista executar | Não modela decisão estratégica rollback vs scale para CTO em war room |
| B-A-B | **Bridge** com matriz A/B e estado pré/pós deploy | Menos “copy-paste” operacional imediato |

**Veredito:** R-I-S-E executa incidente; Q08 **decide** em 20 min — B-A-B encaixa melhor.

### vs **T-A-G**

| | Ganho | Perda |
|---|--------|-------|
| T-A-G | `[Action]` numerado gera seções de análise | Não obriga eixo “estado antes do deploy vs colapso agora” |
| B-A-B | Changelog v2.48.0 vive no **Before** — eixo da causalidade | — |

**Veredito:** T-A-G serviu Q3/Q4 (relatório/SQL); aqui a pergunta é **o que mudou entre ontem e hoje** — nativa do Before/Bridge.

### vs **R-T-F** (menção)

R-T-F entregaria formato de postmortem correto, mas **Task/Format** não exigiriam confrontar opção A vs B com o mesmo rigor que **Bridge** impõe.

---

## Síntese

| Questão tipo | Framework |
|--------------|-----------|
| Procedimento plantão (Q7) | R-I-S-E |
| Decisão em incidente ativo (Q8) | **B-A-B** |
