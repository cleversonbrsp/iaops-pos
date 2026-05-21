# Questão 07 — Entrega

## Prompt (framework R-I-S-E)

```
[Role]
Você é um engenheiro SRE sênior especializado em runbooks de plantão para
Kubernetes (EKS), com experiência em APIs de alta disponibilidade, HPA, Argo CD
e observabilidade (Prometheus/Grafana). Escreva para plantonistas que NÃO
conhecem o Chronos em profundidade — linguagem direta, imperativa, sem jargão
interno não explicado.

[Input]
Alerta recorrente (4x/semana, 30–40 min para resolver sem procedimento):
[CRITICAL] High memory usage on Chronos API pods (>85% for 10min)

Ambiente obrigatório no runbook:
- Chronos API no EKS, namespace production, 6 réplicas
- HPA: min 4, max 12, CPU target 70%
- Deploy via Argo CD, app/repo hvt/chronos-api
- Dependências: Ledger (PostgreSQL), Reactor (filas SQS)
- Observabilidade: /metrics, logs Beacon, dashboards Grafana
- Ferramentas: kubectl, aws cli, argocd cli
- Slack: #oncall-chronos
- Escalação: @chronos-core (SLA 15 min comercial, 30 min fora)

[Steps]
Produza um runbook procedural com, no mínimo:

1. Cabeçalho (alerta, canal, escalação, versão)
2. Pré-requisitos e mensagem de ack no Slack
3. Passos numerados de diagnóstico, cada um com:
   - bloco de comandos copy-paste (kubectl / aws / argocd)
   - tabela "Verificação esperada" (OK vs Atenção)
4. Passo de mitigação em ordem fixa: rolling restart → scale HPA (se aplicável)
   → rollback Argo (se deploy recente) — com aviso do que NÃO fazer
5. Seção "Critérios de escalação" com IDs (E1–E6) e critérios objetivos mensuráveis
6. Template de mensagem de escalação para @chronos-core
7. Seção "Encerramento" com checklist (≥ 10 min estável) e post de resolved
8. Referência rápida (namespace, deployment, labels, HPA, Argo app)

[Expectation]
O leitor deve conseguir executar o runbook sozinho em < 30 min até mitigação ou
escalação fundamentada. Cada passo termina com critério verificável (não subjetivo).
Escalação e encerramento usam limiares numéricos (85%, 10 min, 15 min, 50k mensagens).
Formato: Markdown único, pronto para publicar no wiki de plantão da Lorraine.
```

## Modelo

**Composer**

## Output

Artefatos gerados e organizados em `Q7/`:

| Arquivo | Função |
|---------|--------|
| `runbook-chronos-high-memory.md` | Runbook procedural completo |
| `Enunciado.md` | Enunciado da questão |

**Estrutura do runbook:**

| Seção | Conteúdo |
|-------|----------|
| Passos 1–5 | Diagnóstico (pods, HPA, Argo CD, Ledger/Reactor, métricas/logs) |
| Passo 6 | Mitigação ordenada (restart → scale → rollback) |
| §4 | Escalação E1–E6 com template Slack |
| §5 | Encerramento com 6 critérios + post resolved |

## Justificativa (R-I-S-E no prompt)

| Componente | Onde aparece no prompt | Efeito na resposta |
|------------|------------------------|--------------------|
| **Role** | Bloco `[Role]` — SRE sênior, runbooks K8s, linguagem para quem não conhece Chronos | Tom imperativo, comandos explícitos, sem assumir conhecimento tribal |
| **Input** | Bloco `[Input]` — texto do alerta + tabela do ambiente (EKS, HPA, Argo, deps, ferramentas, Slack, SLA) | Ancora todos os detalhes do enunciado no artefato final |
| **Steps** | Bloco `[Steps]` — 8 itens estruturais (cabecalho, pré-reqs, passos com comando+verificação, mitigação, escalação, encerramento) | Garante runbook completo de ponta a ponta, não só lista de comandos soltos |
| **Expectation** | Bloco `[Expectation]` — < 30 min, critérios verificáveis, limiares numéricos, Markdown publicável | Exige tabelas OK/Atenção, IDs E1–E6, checklist de resolved com 10 min estáveis |

### Decisões do runbook

1. **Ordem diagnóstico → mitigação** — confirma alerta antes de restart evita mascarar falso positivo.
2. **Rolling restart como 6a** — ação de menor risco alinhada ao alerta de memória.
3. **HPA max 12 documentado** — patch temporário só com carga confirmada; reversão no encerramento.
4. **E5 com SLA 15/30 min** — critério temporal objetivo do enunciado.
5. **Template de escalação** — reduz variabilidade dos 30–40 min atuais.
6. **Ledger + Reactor no Passo 4** — memória alta frequentemente correlaciona com dependência degradada.
