#!/usr/bin/env bash
# scripts/coverage.sh
# Executa os testes Flutter com cobertura e gera relatório HTML via lcov.
#
# Dependência: lcov
#   macOS:  brew install lcov
#   Ubuntu: sudo apt-get install lcov
#
# Uso:
#   bash scripts/coverage.sh
#
# Saída:
#   coverage/lcov.info       — dados brutos de cobertura
#   coverage/html/index.html — relatório HTML navegável

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

LCOV_INFO="coverage/lcov.info"
HTML_DIR="coverage/html"

echo "▶ Executando testes com cobertura..."
flutter test --coverage

echo "▶ Removendo arquivos gerados (mocks, providers automáticos)..."
lcov \
  --remove "$LCOV_INFO" \
  '*/generated/*' \
  '*/firebase_options.dart' \
  '**/*.g.dart' \
  '**/*.freezed.dart' \
  --output-file "$LCOV_INFO" \
  --ignore-errors unused \
  2>/dev/null || true

echo "▶ Gerando relatório HTML em $HTML_DIR ..."
genhtml "$LCOV_INFO" \
  --output-directory "$HTML_DIR" \
  --title "SeniorEase Mobile — Cobertura de Testes" \
  --show-details \
  --legend

TOTAL_COVERAGE=$(lcov --summary "$LCOV_INFO" 2>&1 | grep -E "lines\.\.\.\." | grep -oP '\d+\.\d+(?=%)' || echo "N/A")

echo ""
echo "✅ Relatório gerado com sucesso!"
echo "   Arquivo : $HTML_DIR/index.html"
echo "   Cobertura de linhas: ${TOTAL_COVERAGE}%"
echo ""
echo "Para abrir no navegador:"
echo "  macOS  : open $HTML_DIR/index.html"
echo "  Linux  : xdg-open $HTML_DIR/index.html"
