# Questão 02 — Script de backup do Ledger

Lorraine chegou à conclusão de que o **Ledger**, o PostgreSQL que o George levantou na EC2 anos atrás, nunca teve rotina de backup automatizada. Hoje isso é uma dependência aberta no radar da SRE, e ela quer fechar com uma **cron diária**.

## Ambiente

| Parâmetro | Valor |
|-----------|-------|
| Host | `ledger-db.internal.hvt.io` |
| Porta | `5432` |
| Banco | `ledger_prod` |
| Usuário de backup | `backup_user` |
| Senha | variável de ambiente `PGPASSWORD`, populada pelo AWS Secrets Manager via IAM role da instância |
| Região AWS | `us-east-1` |
| SO da instância | Ubuntu 22.04 LTS |
| Diretório de trabalho | `/var/backups/ledger` (80 GB livres) |
| Tamanho médio do dump compactado | ~12 GB |

## Requisitos do script

- Dump com `pg_dump`
- Compactação com `gzip`
- Upload do arquivo para o bucket S3 `hvt-ledger-backups` via `aws s3 cp`
- Retenção de **30 dias** no S3 (removendo os mais antigos)
- Registrar cada execução em `/var/log/ledger-backup.log` com timestamp
- Sair com **exit code adequado** em caso de falha

## Tarefa

Aplicando o framework **R-T-F**, escrever o prompt de IA que produza esse script bash.

## Entrega

| Item | Descrição |
|------|-----------|
| **Prompt** | Prompt completo aplicando R-T-F |
| **Modelo** | Modelo utilizado na execução |
| **Output** | Script bash (e artefatos relacionados, se aplicável) |
| **Justificativa** | Como **Role**, **Task** e **Format** aparecem no prompt |
