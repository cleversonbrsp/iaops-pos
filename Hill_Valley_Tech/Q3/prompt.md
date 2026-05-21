[Task]
Analise o breakdown de custos AWS do último mês (CSV abaixo) e produza um
relatório executivo de oportunidades de redução de custo para a diretoria da
Hill Valley Tech. O relatório deve priorizar ações por impacto financeiro,
quantificar cada oportunidade em dólares mensais e em percentual da conta
total, classificar esforço (baixo, médio, alto) e listar riscos ou
pré-requisitos — sem recomendar cortes que degradem SLA de produção.

CSV:
servico,categoria,custo_mensal_usd,uso_medio_pct,observacao
EC2 reservada,compute,4200,72,contrato de 1 ano
EC2 on-demand,compute,8200,45,workloads variaveis
EKS,compute,6700,58,3 clusters
RDS PostgreSQL,databases,8200,62,multi-AZ
ElastiCache Redis,databases,2100,40,cluster de producao
S3 Standard,storage,3100,,5 buckets principais
EBS gp3,storage,1600,68,volumes de producao
CloudWatch Logs,observability,2800,,retencao de 90 dias
CloudWatch Metrics,observability,900,,
Data Transfer Out,network,1900,,trafego entre regioes
NAT Gateway,network,1200,,3 gateways ativos
Lambda,compute,900,30,~12M invocacoes/mes

[Action]
1. Calcular o custo mensal total e o percentual por categoria (compute,
   databases, storage, observability, network).
2. Identificar linhas com sinais de desperdício (uso_medio_pct baixo, observações
   de retenção longa, múltiplos recursos redundantes, workloads variáveis).
3. Para cada oportunidade de economia, estimar faixa de saving mensal em USD,
   converter para % da conta total e ordenar da maior para a menor economia.
4. Atribuir esforço (baixo/médio/alto) e descrever riscos ou pré-requisitos
   (compliance, migração, contratos, dependência de observabilidade/SLA).
5. Montar um plano em ondas (12 semanas) que some economia suficiente para a
   meta, com cenário conservador e provável.
6. Incluir resumo executivo com baseline, meta em USD, % alvo e recomendação
   objetiva para o CEO.

[Goal]
Entregar um relatório que permita à empresa atingir 15% de redução no custo
cloud até o fim do trimestre (baseline = soma do CSV), sem degradar SLA,
com linguagem adequada para Goldie Wilson (CEO) — foco em impacto financeiro,
priorização clara e riscos explícitos, não em detalhe técnico de implementação.

[Formato de saída]
Markdown com seções: Resumo executivo, Baseline por categoria, Tabela de
oportunidades priorizadas (#, oportunidade, linha CSV, economia USD, % conta,
esforço, riscos/pré-requisitos), Plano em ondas, Riscos transversais,
Recomendação para Goldie.
