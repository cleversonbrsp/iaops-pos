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
