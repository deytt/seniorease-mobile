#!/usr/bin/env bash
# update-memory-bank.sh
# Atualiza o submodule memory-bank e re-sincroniza rules e skills (Cursor + GitHub Copilot).
# Uso: bash scripts/update-memory-bank.sh
# Nota: não faz commit — fica a teu cargo decidir quando e o que commitar.

set -e

SUBMODULE_PATH="memory-bank"
RULES_SRC="$SUBMODULE_PATH/.cursor/rules"
RULES_DST=".cursor/rules"
SKILLS_SRC="$SUBMODULE_PATH/.cursor/skills"
SKILLS_DST=".cursor/skills"
COPILOT_INSTRUCTIONS_SRC="$SUBMODULE_PATH/.github/copilot-instructions.md"
COPILOT_INSTRUCTIONS_DST=".github/copilot-instructions.md"
COPILOT_SKILLS_SRC="$SUBMODULE_PATH/.github/skills"
COPILOT_SKILLS_DST=".github/skills"

# ─── Verifica que estamos na raiz de um repositório Git ───────────────────────
if [ ! -d ".git" ]; then
  echo "❌ Erro: execute este script a partir da raiz do projeto (onde está a pasta .git)."
  exit 1
fi

# ─── Verifica que o submodule existe ──────────────────────────────────────────
if [ ! -d "$SUBMODULE_PATH/.git" ] && [ ! -f "$SUBMODULE_PATH/.git" ]; then
  echo "❌ Erro: submodule '$SUBMODULE_PATH' não encontrado."
  echo "   Inicializa-o com: git submodule update --init --recursive"
  exit 1
fi

# ─── Captura o commit atual do submodule ──────────────────────────────────────
COMMIT_BEFORE=$(git -C "$SUBMODULE_PATH" rev-parse HEAD)

echo "🔄 A verificar atualizações do memory-bank..."
git submodule update --remote "$SUBMODULE_PATH"

COMMIT_AFTER=$(git -C "$SUBMODULE_PATH" rev-parse HEAD)

# ─── Verifica se houve mudanças ───────────────────────────────────────────────
if [ "$COMMIT_BEFORE" = "$COMMIT_AFTER" ]; then
  echo "✅ memory-bank já está na versão mais recente. Nenhuma atualização necessária."
  echo "   Commit atual: $(git -C "$SUBMODULE_PATH" log -1 --format='%h — %s (%cr)')"
  exit 0
fi

echo ""
echo "📦 Nova versão detectada:"
echo "   Antes : ${COMMIT_BEFORE:0:7}"
echo "   Depois: ${COMMIT_AFTER:0:7}"
echo ""
echo "📋 Commits incluídos nesta atualização:"
git -C "$SUBMODULE_PATH" log --oneline "${COMMIT_BEFORE}..${COMMIT_AFTER}"
echo ""

# ─── Sincroniza Cursor rules ──────────────────────────────────────────────────
if [ -d "$RULES_SRC" ]; then
  RULES_CHANGED=false
  mkdir -p "$RULES_DST"

  for src_file in "$RULES_SRC"/*; do
    [ -f "$src_file" ] || continue
    filename=$(basename "$src_file")
    dst_file="$RULES_DST/$filename"

    if [ ! -f "$dst_file" ] || ! diff -q "$src_file" "$dst_file" > /dev/null 2>&1; then
      cp "$src_file" "$dst_file"
      echo "  📄 Cursor rule sincronizada: .cursor/rules/$filename"
      RULES_CHANGED=true
    fi
  done

  if [ "$RULES_CHANGED" = false ]; then
    echo "  ℹ️  Cursor rules: sem alterações."
  fi
else
  echo "  ⚠️  Pasta $RULES_SRC não encontrada — nenhuma Cursor rule sincronizada."
fi

# ─── Sincroniza Cursor skills ─────────────────────────────────────────────────
if [ -d "$SKILLS_SRC" ]; then
  SKILLS_CHANGED=false
  mkdir -p "$SKILLS_DST"

  for skill_dir in "$SKILLS_SRC"/*/; do
    [ -d "$skill_dir" ] || continue
    skill_name=$(basename "$skill_dir")
    dst_skill="$SKILLS_DST/$skill_name"
    mkdir -p "$dst_skill"

    for src_file in "$skill_dir"*; do
      [ -f "$src_file" ] || continue
      filename=$(basename "$src_file")
      dst_file="$dst_skill/$filename"

      if [ ! -f "$dst_file" ] || ! diff -q "$src_file" "$dst_file" > /dev/null 2>&1; then
        cp "$src_file" "$dst_file"
        echo "  🧠 Cursor skill sincronizada: .cursor/skills/$skill_name/$filename"
        SKILLS_CHANGED=true
      fi
    done
  done

  if [ "$SKILLS_CHANGED" = false ]; then
    echo "  ℹ️  Cursor skills: sem alterações."
  fi
else
  echo "  ℹ️  Pasta $SKILLS_SRC não encontrada — nenhuma Cursor skill para sincronizar."
fi

# ─── Sincroniza GitHub Copilot instructions ───────────────────────────────────
if [ -f "$COPILOT_INSTRUCTIONS_SRC" ]; then
  mkdir -p "$(dirname "$COPILOT_INSTRUCTIONS_DST")"
  if [ ! -f "$COPILOT_INSTRUCTIONS_DST" ] || ! diff -q "$COPILOT_INSTRUCTIONS_SRC" "$COPILOT_INSTRUCTIONS_DST" > /dev/null 2>&1; then
    cp "$COPILOT_INSTRUCTIONS_SRC" "$COPILOT_INSTRUCTIONS_DST"
    echo "  📄 Copilot instructions sincronizadas: .github/copilot-instructions.md"
  else
    echo "  ℹ️  Copilot instructions: sem alterações."
  fi
else
  echo "  ⚠️  Ficheiro $COPILOT_INSTRUCTIONS_SRC não encontrado — instruções Copilot não sincronizadas."
fi

# ─── Sincroniza GitHub Copilot skills ─────────────────────────────────────────
if [ -d "$COPILOT_SKILLS_SRC" ]; then
  COPILOT_SKILLS_CHANGED=false
  mkdir -p "$COPILOT_SKILLS_DST"

  for skill_dir in "$COPILOT_SKILLS_SRC"/*/; do
    [ -d "$skill_dir" ] || continue
    skill_name=$(basename "$skill_dir")
    dst_skill="$COPILOT_SKILLS_DST/$skill_name"
    mkdir -p "$dst_skill"

    for src_file in "$skill_dir"*; do
      [ -f "$src_file" ] || continue
      filename=$(basename "$src_file")
      dst_file="$dst_skill/$filename"

      if [ ! -f "$dst_file" ] || ! diff -q "$src_file" "$dst_file" > /dev/null 2>&1; then
        cp "$src_file" "$dst_file"
        echo "  🧠 Copilot skill sincronizada: .github/skills/$skill_name/$filename"
        COPILOT_SKILLS_CHANGED=true
      fi
    done
  done

  if [ "$COPILOT_SKILLS_CHANGED" = false ]; then
    echo "  ℹ️  Copilot skills: sem alterações."
  fi
else
  echo "  ℹ️  Pasta $COPILOT_SKILLS_SRC não encontrada — nenhuma Copilot skill para sincronizar."
fi

# ─── Sincroniza scripts do memory-bank ───────────────────────────────────────
SCRIPTS_SRC="$SUBMODULE_PATH/scripts"
SCRIPTS_DST="scripts"

if [ -d "$SCRIPTS_SRC" ]; then
  SCRIPTS_CHANGED=false
  mkdir -p "$SCRIPTS_DST"

  for src_file in "$SCRIPTS_SRC"/*; do
    [ -f "$src_file" ] || continue
    filename=$(basename "$src_file")
    dst_file="$SCRIPTS_DST/$filename"

    if [ ! -f "$dst_file" ] || ! diff -q "$src_file" "$dst_file" > /dev/null 2>&1; then
      cp "$src_file" "$dst_file"
      chmod +x "$dst_file"
      echo "  🔧 Script sincronizado: scripts/$filename"
      SCRIPTS_CHANGED=true
    fi
  done

  if [ "$SCRIPTS_CHANGED" = false ]; then
    echo "  ℹ️  Scripts: sem alterações."
  fi
fi

# ─── Resumo final ─────────────────────────────────────────────────────────────
echo ""
echo "✅ Sincronização concluída."
echo ""
echo "   Os seguintes ficheiros podem ter sido alterados (verifica com 'git status'):"
echo "   • memory-bank              (ponteiro do submodule)"
echo "   • .cursor/rules/           (Cursor rules)"
echo "   • .cursor/skills/          (Cursor skills)"
echo "   • .github/copilot-instructions.md"
echo "   • .github/skills/          (GitHub Copilot skills)"
echo "   • scripts/                 (scripts utilitários)"
echo ""
echo "   Quando estiveres pronto, faz commit das alterações:"
echo "   git add memory-bank .cursor/rules .cursor/skills .github/copilot-instructions.md .github/skills scripts"
echo "   git commit -m \"chore: update memory-bank to \$(git -C memory-bank rev-parse --short HEAD)\""
