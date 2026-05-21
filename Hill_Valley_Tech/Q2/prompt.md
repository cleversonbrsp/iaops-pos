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
