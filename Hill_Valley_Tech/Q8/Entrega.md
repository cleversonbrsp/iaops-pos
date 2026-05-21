# Questão 08 — Entrega

## Framework escolhido

**B-A-B (Before — After — Bridge)**

Cenário de decisão binária sob pressão de tempo, com mudança de estado clara (pré-deploy / pós-deploy / estado desejado) e necessidade de ligar evidências à recomendação rollback vs scaling.

---

## Prompt (framework B-A-B)

```
[Before]
Estado e evidências ANTES da degradação crítica e do ponto de decisão:

- Deploy v2.48.0 em 2026-04-23 18:42 UTC (changelog: batch endpoint, refactor pool
  Ledger, psycopg 3.2.0, timeout 5s→2s)
- Métricas baseline 13:30 UTC: p99 420ms, err 0.2%, 1200 req/s
- Inflexão 14:10 UTC: p99 2400ms, err 4.5%
- Colapso 14:20 UTC: p99 8100ms, err 11.7%, 2650 req/s
- Logs: pool exhausted max=20 active=20 waiting=147; timeout 2000ms; batch handler
  failed; circuit breaker OPEN 87%; reactor publish failed
- Reactor: 50127 msgs, +800/min, lag 18min
- Cluster: 12/12 pods HPA max, CPU 62%, mem 71%, RDS 240/250 connections

Descreva o Before como: (a) baseline saudável sob carga, (b) mudanças introduzidas
pelo v2.48.0 que criam risco, (c) capacidade aparente do cluster (não-CPU-bound).

[After]
Estado ATUAL do incidente e estado ALVO pós-decisão:

- Atual: métricas de colapso, pool/RDS saturados, backlog Reactor, CB aberto
- Alvo: p99 <800ms, err <1%, pool sem waiting, RDS <200 conn, lag estável,
  circuit breaker closed — em 15-20 min após ação

Doc Brown precisa decidir em 20 minutos entre:
A) Rollback v2.48.0 → v2.47.0
B) Scaling emergencial RDS + pool de conexões

[Bridge]
Construa o postmortem técnico que conecte Before → After:

1. Linha do tempo correlacionando deploy, métricas e logs
2. Cadeia causal em texto (pico → batch → pool → timeout → CB → Reactor)
3. Análise das opções A e B (tempo, eficácia, risco) com matriz de decisão
4. Recomendação objetiva para Doc Brown (primária + complemento condicional)
5. Follow-up pós-incidente e lacunas de dados

Formato Markdown: Resumo executivo (30s), Linha do tempo, Before, After,
Bridge (causal + opções + matriz), Recomendação, Follow-up, Incertezas.
Tom: técnico, direto, sem linguagem de marketing. Máximo ~2 páginas equivalentes.
```

## Modelo

**Composer**

## Output

| Arquivo | Função |
|---------|--------|
| `postmortem-chronos-v248.md` | Postmortem técnico para decisão em 20 min |
| `Enunciado.md` | Enunciado e artefatos do incidente |

**Decisão do postmortem:** **rollback v2.47.0** como ação primária; scaling RDS/pool apenas como complemento se RDS permanecer > 220 conexões após rollback.

---

## Justificativa estendida

### Por que B-A-B é o melhor encaixe

O pedido do Doc Brown não é um runbook (“o que executar passo a passo”) nem um módulo reutilizável — é uma **análise de transição de estado** entre dois mundos:

| Estado | No incidente |
|--------|----------------|
| **Before** | Pré-pico saudável + mudanças do v2.48.0 + capacidade K8s aparentemente suficiente |
| **After (atual)** | Colapso de latência/erro, pool e RDS no limite, Reactor em backlog |
| **After (alvo)** | Métricas de recuperação em 15–20 min |
| **Bridge** | Por que A (rollback) ou B (scaling) leva de atual → alvo |

O componente **Bridge** força a IA a fazer o trabalho analítico que Doc Brown precisa: correlacionar changelog → logs → métricas → recomendação, em vez de apenas formatar dados.

### Como B-A-B aparece no prompt

| Componente | No prompt | Efeito no output |
|------------|-----------|------------------|
| **Before** | Baseline 13:30, changelog v2.48.0, cluster não CPU-bound | Seções 2–3: separa “saudável” de “mudanças de risco” |
| **After** | Estado colapso + alvo numérico pós-ação | Seções 4 e matriz: critérios objetivos de sucesso |
| **Bridge** | Cadeia causal + opções A/B + matriz + recomendação | Seções 5–6: núcleo da decisão rollback vs scaling |

---

### Comparação com framework 1: **R-T-F** (Role — Task — Format)

| | R-T-F | B-A-B (escolhido) |
|---|--------|-------------------|
| **Ganho** | `[Role]` SRE sênior + `[Format]` fixo (timeline, RCA, recomendação) produz documento limpo rapidamente | `[Before]/[After]` obrigam narrativa de transição de estado |
| **Perda** | `[Task]` “escreva postmortem” não exige comparar estado pré-deploy vs pós-pico nem confrontar opções A/B com mesma estrutura | — |
| **Risco** | Output pode virar relatório genérico que **lista** evidências sem **conectar** deploy ao pool exhausted | Bridge elimina esse gap |

**Veredito:** R-T-F entrega formato correto, mas em incidente com **decisão binária temporal** (ontem deploy, hoje colapso) o Before/After é mais natural que Role/Format sozinhos.

---

### Comparação com framework 2: **R-I-S-E** (Role — Input — Steps — Expectation)

| | R-I-S-E | B-A-B (escolhido) |
|---|---------|-------------------|
| **Ganho** | `[Steps]` excelente para plantonista executar comandos; `[Expectation]` com limiares verificáveis | — |
| **Perda** | Orientado a **procedimento**, não a **deliberação estratégica** em war room | Bridge inclui matriz de decisão e tradeoffs A/B |
| **Risco** | Postmortem viraria “passo 1 rollback, passo 2 scale” sem análise de **por que** rollback vence com HPA já no máximo | B-A-B explicita que scaling de pods não ajuda (CPU 62%) |

**Veredito:** R-I-S-E foi ideal na Q7 (runbook); aqui o consumidor é **CTO decidindo**, não plantonista seguindo comandos — B-A-B prioriza análise sobre sequência operacional.

---

### Comparação com framework 3: **T-A-G** (Task — Action — Goal)

| | T-A-G | B-A-B (escolhido) |
|---|-------|-------------------|
| **Ganho** | `[Action]` numerado garante passos de análise (timeline, RCA, recomendação) | — |
| **Perda** | `[Goal]` fixa entrega mas não modela **estado anterior vs atual** do sistema | Before/After tornam explícita a regressão pós-v2.48.0 |
| **Risco** | Análise do deploy v2.48.0 pode ficar **um item entre vários**, não o eixo central | No B-A-B, changelog está no Before — eixo da Bridge |

**Veredito:** T-A-G funcionaria razoavelmente (Q3/Q4 usaram bem), mas para “rollback vs scaling” a pergunta implícita é **“o que mudou entre ontem e agora?”** — pergunta nativa do Before/Bridge, não do Task/Action.

---

### Frameworks não escolhidos (menção breve)

| Framework | Por que não |
|-----------|-------------|
| **C-A-R-E** | Otimizado para módulos reutilizáveis + exemplo (Q6); incidente único, não template |
| **T-A-G** (terceiro candidato) | Ver tabela acima — bom, mas menos centrado em transição de estado que B-A-B |

---

### Síntese da escolha

```
Cenário: decisão sob tempo + mudança de versão + evidências heterogêneas
         (métricas, logs, fila, cluster)

Melhor fit: B-A-B
  Before  → o que era / o que o deploy mudou
  After   → colapso atual + alvo de recuperação
  Bridge  → causal + rollback vs scaling + recomendação

Q7 → R-I-S-E (executar)
Q8 → B-A-B (decidir)
```

---

### Decisões técnicas do postmortem (output)

1. **Rollback primário** — pool `max=20` + timeout 2s + batch são da v2.48.0; HPA esgotado sem CPU alta.
2. **Scaling secundário** — RDS 240/250 é sintoma; 10 conexões livres não drenam 147 waiting.
3. **Não escalar pods** — 12/12 já; evita ação inútil de 20 min.
4. **Latência deploy→inflexão ~19h** — documentada para não descartar correlação por “deploy antigo”.
5. **Follow-up** — reintrodução v2.48.0 só com load test de pool/batch.
