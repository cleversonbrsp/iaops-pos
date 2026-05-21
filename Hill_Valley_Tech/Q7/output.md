# Output — Gemini 2.5 Pro (resposta integral)

Documento completo gerado pelo modelo: [`runbook-chronos-high-memory.md`](./runbook-chronos-high-memory.md).

## Estrutura retornada (sumário)

1. Objetivo e pré-requisitos (#oncall-chronos ack)  
2. Passos 1–5: diagnóstico (pods, HPA, Argo CD, Ledger/Reactor, métricas/logs)  
3. Passo 6: mitigação ordenada (restart → scale HPA → rollback)  
4. Escalação E1–E6 + template Slack `@chronos-core`  
5. Encerramento com checklist ≥ 10 min + post RESOLVED  
6. Referência rápida (namespace `production`, deployment `chronos-api`)  

## Trecho — critério de escalação E1

> Após Passo 6a e 6b, memória continua **> 85%** por **≥ 10 min** em **≥ 2 pods** → escalar `@chronos-core`.

---

### Output imperfeito (registrado)

**Tentativa 1:** runbook sugeria `kubectl scale deployment` manual antes de checar HPA — conflita com política de escala automática. **Correção:** [Steps] item 4 fixa ordem e avisa contra scale manual de réplicas; usar patch de `maxReplicas` só se documentado.
