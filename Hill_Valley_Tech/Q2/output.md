# Output — Claude Sonnet 4 (resposta integral)

## 1. ledger-backup.sh

Ver arquivo versionado [`ledger-backup.sh`](./ledger-backup.sh) (84 linhas).

Trecho representativo:

```bash
set -euo pipefail
# ...
if [[ -z "${PGPASSWORD:-}" ]]; then
  fail "PGPASSWORD não definida (esperado via Secrets Manager / IAM role)"
fi
pg_dump --no-owner --no-acl --format=plain "${PGDATABASE}" | gzip -9 > "${DUMP_PATH}"
aws s3 cp "${DUMP_PATH}" "${S3_BUCKET}/${S3_KEY}" --region "${AWS_DEFAULT_REGION}"
# retenção 30 dias via aws s3 ls + rm por data no nome do objeto
```

## 2. Crontab

```cron
0 2 * * * /usr/local/bin/ledger-backup.sh
```

## 3. Justificativa técnica

1. `set -euo pipefail` + `trap ERR` para exit ≠ 0 em falha de cron.
2. Validação de `PGPASSWORD` antes do dump.
3. Pipe `pg_dump | gzip` evita arquivo .sql intermediário de ~12 GB.
4. Prefixo `daily/` no S3 para listagem de retenção.
5. Retenção por data no filename (`YYYYMMDD`) com cutoff de 30 dias.
6. `cleanup_local` após upload e no trap de erro.
7. Log UTC com `tee -a` em `/var/log/ledger-backup.log`.
8. `--no-owner --no-acl` no pg_dump para restore portável.

---

### Output imperfeito (registrado)

**Tentativa 1:** retenção S3 apenas com `aws s3api delete-objects` em lote sem validar prefixo — risco de apagar chaves erradas. **Correção:** listar `daily/` e filtrar por data no nome `ledger_prod_*`.
