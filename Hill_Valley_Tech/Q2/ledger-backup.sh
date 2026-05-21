#!/usr/bin/env bash
#
# ledger-backup.sh — backup diário do PostgreSQL Ledger para S3
# Destino: hvt-ledger-backups (us-east-1)
# Log: /var/log/ledger-backup.log
#

set -euo pipefail

readonly PGHOST="ledger-db.internal.hvt.io"
readonly PGPORT="5432"
readonly PGDATABASE="ledger_prod"
readonly PGUSER="backup_user"
readonly AWS_DEFAULT_REGION="us-east-1"
readonly S3_BUCKET="s3://hvt-ledger-backups"
readonly BACKUP_DIR="/var/backups/ledger"
readonly LOG_FILE="/var/log/ledger-backup.log"
readonly RETENTION_DAYS=30

TIMESTAMP="$(date -u +%Y%m%d_%H%M%S)"
DUMP_BASENAME="ledger_prod_${TIMESTAMP}"
DUMP_PATH="${BACKUP_DIR}/${DUMP_BASENAME}.sql.gz"
S3_KEY="daily/${DUMP_BASENAME}.sql.gz"

log() {
  echo "[$(date -u +%Y-%m-%dT%H:%M:%SZ)] $*" | tee -a "${LOG_FILE}"
}

fail() {
  log "ERROR: $*"
  exit 1
}

cleanup_local() {
  if [[ -f "${DUMP_PATH}" ]]; then
    rm -f "${DUMP_PATH}"
    log "Arquivo local removido: ${DUMP_PATH}"
  fi
}

trap 'log "Falha na execução (linha ${LINENO}, exit $?)"; cleanup_local; exit 1' ERR

if [[ -z "${PGPASSWORD:-}" ]]; then
  fail "PGPASSWORD não definida (esperado via Secrets Manager / IAM role)"
fi

export PGHOST PGPORT PGDATABASE PGUSER

mkdir -p "${BACKUP_DIR}"
touch "${LOG_FILE}" 2>/dev/null || fail "Sem permissão de escrita em ${LOG_FILE}"

log "=== Início do backup Ledger ==="

log "Executando pg_dump -> ${DUMP_PATH}"
if ! pg_dump --no-owner --no-acl --format=plain "${PGDATABASE}" | gzip -9 > "${DUMP_PATH}"; then
  fail "pg_dump ou gzip falhou"
fi

DUMP_SIZE="$(du -h "${DUMP_PATH}" | cut -f1)"
log "Dump compactado gerado (${DUMP_SIZE}): ${DUMP_PATH}"

log "Enviando para ${S3_BUCKET}/${S3_KEY}"
if ! aws s3 cp "${DUMP_PATH}" "${S3_BUCKET}/${S3_KEY}" --region "${AWS_DEFAULT_REGION}"; then
  fail "Upload S3 falhou"
fi

log "Aplicando retenção de ${RETENTION_DAYS} dias no bucket"
CUTOFF_DATE="$(date -u -d "${RETENTION_DAYS} days ago" +%Y%m%d)"
aws s3 ls "${S3_BUCKET}/daily/" --region "${AWS_DEFAULT_REGION}" 2>/dev/null | while read -r _ _ _ key; do
  [[ -z "${key}" ]] && continue
  OBJECT_DATE="${key#ledger_prod_}"
  OBJECT_DATE="${OBJECT_DATE%%_*}"
  if [[ "${#OBJECT_DATE}" -eq 8 && "${OBJECT_DATE}" < "${CUTOFF_DATE}" ]]; then
    log "Removendo objeto antigo: ${key}"
    aws s3 rm "${S3_BUCKET}/daily/${key}" --region "${AWS_DEFAULT_REGION}" || \
      log "WARN: falha ao remover ${key}"
  fi
done

cleanup_local

log "=== Backup concluído com sucesso ==="
exit 0
