# Questão 02 — Entrega

## Prompt (framework R-T-F)

```
[Role]
Você é um engenheiro SRE sênior, especialista em operação de PostgreSQL em
produção, scripts bash idempotentes em Ubuntu LTS, integração com AWS CLI
(S3, IAM instance profile) e rotinas de backup com retenção e observabilidade
via log estruturado com timestamp.

[Task]
Crie um script bash de backup diário do banco Ledger (PostgreSQL) para ser
executado via cron em uma instância Ubuntu 22.04 na região us-east-1.

Contexto operacional:
- Host: ledger-db.internal.hvt.io
- Porta: 5432
- Banco: ledger_prod
- Usuário: backup_user
- Senha: variável de ambiente PGPASSWORD (já exportada no ambiente pelo
  AWS Secrets Manager via IAM role da instância — NÃO hardcodar credenciais)
- Diretório local de trabalho: /var/backups/ledger (~80 GB livres; dump
  compactado médio ~12 GB)
- Bucket S3: hvt-ledger-backups
- Região AWS: us-east-1

Requisitos obrigatórios do script:
1. Executar pg_dump do banco ledger_prod e compactar a saída com gzip
   (arquivo local nomeado com timestamp UTC, ex.: ledger_prod_YYYYMMDD_HHMMSS.sql.gz)
2. Enviar o arquivo para o bucket via `aws s3 cp`, prefixo sugerido: daily/
3. Implementar retenção de 30 dias no S3: listar objetos no prefixo e remover
   arquivos mais antigos que o cutoff (não depender apenas de lifecycle rule
   no prompt — o script deve fazer a limpeza)
4. Registrar cada etapa relevante (início, dump, upload, limpeza, sucesso ou
   erro) em /var/log/ledger-backup.log com timestamp ISO-8601 em UTC
5. Usar `set -euo pipefail` e trap em ERR para garantir exit code != 0 em falha
6. Validar que PGPASSWORD está definida antes do dump; falhar cedo se ausente
7. Remover o arquivo local após upload bem-sucedido (liberar disco)
8. Não exigir interação humana; adequado para cron (PATH padrão do sistema)

[Format]
Responda em três blocos markdown, nesta ordem:

1. **ledger-backup.sh** — script bash completo, executável, com shebang e
   comentário de cabeçalho (host, bucket, log)
2. **Crontab** — linha de exemplo para execução diária às 02:00 UTC, com
   redirecionamento mínimo (cron já loga no arquivo do script)
3. **Justificativa técnica** — lista numerada (máx. 8 itens) explicando
   pg_dump flags, gzip, retenção S3, exit codes, limpeza local e premissas
   de IAM/Secrets Manager
```

## Modelo

**Composer** (agente Cursor) — execução em 21/05/2026.

## Output

Artefatos gerados e organizados em `Q2/`:

| Arquivo | Função |
|---------|--------|
| `ledger-backup.sh` | Script de backup diário (pg_dump → gzip → S3 → retenção) |
| `Enunciado.md` | Enunciado da questão |

Instalação e agendamento (na instância de backup):

```bash
sudo install -m 750 -o root -g root \
  Hill_Valley_Tech/Q2/ledger-backup.sh /usr/local/bin/ledger-backup.sh

# Crontab (root ou usuário de serviço com IAM role e PGPASSWORD no ambiente)
0 2 * * * /usr/local/bin/ledger-backup.sh
```

Pré-requisitos na instância: `postgresql-client`, `awscli`, IAM role com
`s3:PutObject`, `s3:ListBucket`, `s3:DeleteObject` no bucket `hvt-ledger-backups`.

## Justificativa (R-T-F no prompt)

| Componente | Onde aparece no prompt | Efeito na resposta |
|------------|------------------------|--------------------|
| **Role** | Bloco `[Role]` — SRE sênior, PostgreSQL, bash Ubuntu, AWS CLI, logs com timestamp | Orienta práticas operacionais: `set -euo pipefail`, validação de `PGPASSWORD`, log em UTC e sem secrets no script |
| **Task** | Bloco `[Task]` — parâmetros do ambiente (host, banco, bucket, região) e requisitos numerados (1–8) | Delimita escopo completo: pg_dump + gzip + `aws s3 cp` + retenção 30 dias + log + exit codes + limpeza local |
| **Format** | Bloco `[Format]` — três seções markdown fixas (script, crontab, justificativa) | Garante entrega estruturada: artefato executável, exemplo de cron e raciocínio técnico separados |

### Decisões técnicas do script

1. **`set -euo pipefail` + `trap ERR`** — qualquer falha em pipe ou comando aborta com log e exit ≠ 0, adequado para alertas de cron.
2. **Validação de `PGPASSWORD`** — falha rápida se o Secrets Manager não populou o ambiente antes do dump.
3. **`pg_dump --no-owner --no-acl`** — dump portável para restore sem arrastar ownership do `backup_user`.
4. **`gzip -9` via pipe** — evita arquivo `.sql` intermediário de dezenas de GB em `/var/backups/ledger`.
5. **Prefixo `daily/` no S3** — organização por data no nome do objeto facilita listagem para retenção.
6. **Retenção por comparação de data no nome** — script remove objetos com data no filename anterior ao cutoff de 30 dias (complementa lifecycle no bucket).
7. **`cleanup_local` no sucesso e no trap** — libera os ~12 GB após upload; em falha também tenta remover dump parcial.
8. **Log com `tee -a`** — mesma linha no arquivo e no stdout, útil se o operador rodar o script manualmente.
