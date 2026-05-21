# Output — Claude Sonnet 4 (trecho da resposta)

Documento integral: [`postmortem-chronos-v248.md`](./postmortem-chronos-v248.md).

## Resumo executivo (como retornado)

> O incidente **não é limitado por CPU/memória do cluster** (62% / 71%, HPA no teto). A falha está na **camada Ledger**: pool esgotado (max=20, 147 waiting), timeout 2s do v2.48.0, RDS 240/250.  
> **Recomendação imediata: rollback v2.47.0.** Scaling RDS/pool sozinho não corrige pool por pod × 12 pods.

## Cadeia causal (Bridge)

```
Pico tráfego → POST /v2/transactions/batch → pool exhausted
  → timeout 2s → circuit breaker OPEN → Reactor backlog → p99 8100ms
```

## Matriz de decisão

| Critério | Rollback (A) | Scaling (B) |
|----------|:------------:|:-------------:|
| Tempo até alívio | ~10 min | 15–30+ min |
| Ataca causa v2.48.0 | Sim | Não |
| Com HPA no máximo | Eficaz | Parcial |

**Decisão:** A primária; B complementar se RDS > 220 após rollback.

---

### Output imperfeito (registrado)

**Tentativa 1:** recomendou **scaling RDS primeiro** por 240/250 conexões — trata sintoma, não pool `max=20` nem timeout novo. **Correção:** reforço no [Bridge] para comparar A vs B; segunda geração prioriza rollback.
