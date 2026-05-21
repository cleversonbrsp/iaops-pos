# Relatório de redução de custos cloud — Hill Valley Tech

**Destinatário:** Goldie Wilson (CEO)  
**Elaborado por:** Doc Brown / time de plataforma  
**Período de referência:** último mês (breakdown AWS)  
**Meta do trimestre:** redução de **15%** no custo cloud **sem degradar SLA**

---

## Resumo executivo

| Métrica | Valor |
|---------|-------|
| Custo mensal total (CSV) | **US$ 41.800** |
| Meta de redução (15%) | **US$ 6.270/mês** |
| Economia estimada no plano (cenário provável) | **US$ 6.450–7.100/mês** (**15,4%–17,0%**) |
| Prazo sugerido | 12 semanas (3 ondas de implementação) |

O plano abaixo prioriza linhas com **baixo risco operacional** e **alto percentual da conta**, usando `uso_medio_pct` e observações do CSV como sinal de desperdício (ex.: EC2 on-demand a 45%, ElastiCache a 40%, retenção de logs em 90 dias).

---

## Baseline por categoria

| Categoria | Custo mensal | % da conta |
|-----------|-------------:|-----------:|
| Compute | US$ 20.000 | 47,8% |
| Databases | US$ 10.300 | 24,6% |
| Storage | US$ 4.700 | 11,2% |
| Observability | US$ 3.700 | 8,9% |
| Network | US$ 3.100 | 7,4% |
| **Total** | **US$ 41.800** | **100%** |

---

## Oportunidades priorizadas por impacto

Ordenação: **economia mensal estimada (cenário provável)** decrescente.  
Coluna **% conta** = economia estimada ÷ US$ 41.800.

| # | Oportunidade | Linha(s) CSV | Economia est. (USD/mês) | % da conta | Esforço | Risco / pré-requisitos |
|---|--------------|--------------|------------------------:|-----------:|---------|-------------------------|
| 1 | **Reduzir retenção e volume de CloudWatch Logs** (90→30 dias, filtros, export para S3 Glacier) | CloudWatch Logs | 1.120–1.400 | 2,7%–3,4% | Baixo | Validar requisitos de compliance/auditoria (Strickland); não remover logs de segurança |
| 2 | **Rightsizing e Spot para workloads variáveis em EC2 on-demand** | EC2 on-demand | 1.230–1.640 | 2,9%–3,9% | Médio | Cargas stateless apenas; testar em staging; manter buffer para picos (SLA) |
| 3 | **Consolidar clusters EKS e otimizar node groups** (3→2 clusters onde possível, Karpenter, Graviton) | EKS | 1.000–1.340 | 2,4%–3,2% | Alto | Janela de migração; regressão em deploy precisa de rollback documentado |
| 4 | **RDS: Reserved Instances / Savings Plans + revisão multi-AZ** (dev/staging single-AZ) | RDS PostgreSQL | 980–1.230 | 2,3%–2,9% | Médio | Multi-AZ em produção mantido; mudança em não-prod exige backup validado |
| 5 | **S3: Intelligent-Tiering e lifecycle** (Standard→IA/Glacier para objetos frios) | S3 Standard | 775–1.085 | 1,9%–2,6% | Baixo | Latência em objetos arquivados; mapear buckets dos 5 principais |
| 6 | **NAT Gateway: consolidar 3→1–2 e VPC endpoints** (S3, DynamoDB, ECR) | NAT Gateway + Data Transfer | 540–760 | 1,3%–1,8% | Médio | Alteração de roteamento; testar conectividade cross-AZ antes do cutover |
| 7 | **ElastiCache: rightsizing do cluster** (uso médio 40%) | ElastiCache Redis | 315–420 | 0,8%–1,0% | Baixo | Monitorar hit rate e latência pós-redução; janela em horário de baixo tráfego |
| 8 | **Data Transfer: reduzir tráfego entre regiões** (CloudFront, colocalizar serviços) | Data Transfer Out | 380–570 | 0,9%–1,4% | Médio | Depende de arquitetura multi-região; alinhar com Reactor/Chronos |
| 9 | **EBS gp3: IOPS/throughput provisionados vs. real** + volumes órfãos | EBS gp3 | 240–400 | 0,6%–1,0% | Baixo | Confirmar volumes “órfãos” com owners antes de delete |
| 10 | **Lambda: memória e arquitetura ARM (Graviton)** | Lambda | 135–225 | 0,3%–0,5% | Baixo | Retestar timeouts com dependências nativas |
| 11 | **CloudWatch Metrics: limpeza de métricas customizadas** | CloudWatch Metrics | 180–270 | 0,4%–0,6% | Baixo | Não remover métricas ligadas a alertas do Beacon |
| 12 | **EC2 reservada: renegociar no vencimento** (família/tamanho alinhados ao uso 72%) | EC2 reservada | 210–420 | 0,5%–1,0% | Alto | Contrato vigente 1 ano; ganho no renewal, não imediato |

---

## Plano em ondas (atingir 15% sem degradar SLA)

### Onda 1 — semanas 1–4 (esforço baixo, ~US$ 2.650/mês · **6,3%**)

- CloudWatch Logs (retenção + filtros)
- S3 lifecycle / Intelligent-Tiering
- EBS gp3 tuning e limpeza
- ElastiCache rightsizing
- Lambda + métricas customizadas

**Pré-requisito:** aprovação de retenção de logs com Strickland.

### Onda 2 — semanas 5–8 (esforço médio, ~US$ 2.900/mês · **6,9%**)

- EC2 on-demand → Spot + rightsizing
- RDS RI/Savings Plans e single-AZ em não-prod
- NAT consolidation + VPC endpoints
- Data Transfer (quick wins de colocalização)

**Pré-requisito:** métricas de SLA do Beacon antes/depois por serviço.

### Onda 3 — semanas 9–12 (esforço alto, ~US$ 1.200/mês · **2,9%**)

- Consolidação EKS (3 clusters)
- Renegociação EC2 reservada (planejamento para renewal)

**Pré-requisito:** runbooks de rollback aprovados por Lorraine (SRE).

### Acumulado provável

| Onda | Economia (USD/mês) | % acumulado da conta |
|------|-------------------:|---------------------:|
| 1 | 2.650 | 6,3% |
| 2 | 2.900 | 13,3% |
| 3 | 1.200 | 16,1% |

Cenário **conservador** (somente ondas 1+2 parcial): **~US$ 5.400/mês (12,9%)** — exige complemento na onda 3 ou economia máxima em EC2/EKS para fechar 15%.

Cenário **provável** (ondas 1+2 completas + parte da 3): **US$ 6.450–6.800/mês (15,4%–16,3%)** — **meta atingida**.

---

## Riscos transversais à meta

| Risco | Mitigação |
|-------|-----------|
| Redução agressiva em compute afeta latência | Limitar Spot a workloads tolerantes a interrupção; manter on-demand para Ledger/RDS críticos |
| Corte em observability cega o plantão | Manter métricas e logs de alertas do Beacon; só reduzir verbosidade de debug |
| Economia “no papel” não realizada | FinOps: revisão semanal de Cost Explorer vs. baseline US$ 41.800 |
| SLA não formalizado no CSV | Doc Brown define SLOs por sistema (Chronos, Ledger, Lift) antes da onda 2 |

---

## Recomendação para Goldie

1. **Aprovar o plano em 3 ondas** com checkpoint quinzenal de % realizado vs. meta 15%.
2. **Priorizar onda 1 imediatamente** — baixo esforço, sem impacto em SLA, ~6% da conta.
3. **Reservar budget de engenharia** para onda 3 (EKS); é o que destrava o teto da meta se ondas 1–2 ficarem no meio da faixa estimada.
4. **KPI de sucesso:** custo mensal ≤ **US$ 35.530** (41.800 × 0,85) até o fim do trimestre, com SLA estável reportado pelo Beacon.

---

*Fonte: `custos-aws.csv` — breakdown AWS último mês. Valores de economia são estimativas de mercado; refinar com Cost Explorer e tags por sistema (Chronos, Ledger, Reactor, Beacon, Lift).*
