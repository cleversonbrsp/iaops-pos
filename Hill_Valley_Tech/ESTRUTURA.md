# Decisão de estrutura do repositório

Este repositório organiza as **8 entregas do desafio IAOPS** de forma intencional para comparar, no Capítulo 4 (*Criação e Versionamento de Prompts*), com práticas de versionamento de prompts.

## Princípio

Cada questão vive em `Hill_Valley_Tech/Q{n}/` com **três artefatos de prompt separados** do código de cenário:

| Arquivo | Conteúdo |
|---------|----------|
| `Enunciado.md` | Cenário fictício Hill Valley Tech (enunciado original) |
| `prompt.md` | Texto **exato** enviado ao modelo |
| `output.md` | Resposta **integral ou trecho relevante** do modelo |
| `Entrega.md` | **Modelo** (+ 1 linha de escolha) e **Justificativa** (2–4 linhas; Q08 estendida) |
| Artefatos (`*.sql`, `*.yaml`, módulos Terraform, etc.) | Outputs aplicáveis versionados junto à pasta |

## Por que não um único `prompts/` flat?

- **Colocalização**: prompt, output e artefato ficam na mesma pasta — facilita diff e revisão por questão.
- **Rastreabilidade**: `Enunciado` → `prompt` → `output` → `Entrega` é ordem de leitura natural.
- **Preparação para Cap. 4**: evoluir para `prompts/q01/v1.md`, `v2.md` sem quebrar paths dos artefatos.

## Providers usados (≥ 2)

| Questão | Modelo | Provider |
|---------|--------|----------|
| Q01 | GPT-4o | OpenAI |
| Q02 | Claude Sonnet 4 | Anthropic |
| Q03 | Gemini 2.5 Pro | Google |
| Q04 | GPT-4o | OpenAI |
| Q05 | Claude Sonnet 4 | Anthropic |
| Q06 | GPT-4o | OpenAI |
| Q07 | Gemini 2.5 Pro | Google |
| Q08 | Claude Sonnet 4 | Anthropic |

Registro detalhado em cada `Entrega.md`, incluindo outputs imperfeitos e retrabalho.

## Repositório público

URL: **https://github.com/cleversonbrsp/iaops-pos** (enviar este link na entrega final do módulo).
