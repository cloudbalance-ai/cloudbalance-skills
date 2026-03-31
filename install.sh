#!/usr/bin/env bash
# CloudBalance Skills installer
#
# Usage:
#   Interactive (will prompt for install location):
#     curl -sL https://raw.githubusercontent.com/cloudbalance-ai/cloudbalance-skills/main/install.sh | bash
#     bash install.sh
#
#   Non-interactive flags:
#     --global           Install to ~/.claude/skills/ (all projects)
#     --project          Install to .claude/skills/ in current directory
#     --dir /some/path   Install to /some/path/.claude/skills/

set -euo pipefail

REPO="https://github.com/cloudbalance-ai/cloudbalance-skills.git"
SKILLS_SOURCE_DIR="."
TARGET_DIR=""
GLOBAL_INSTALL=false
PROJECT_INSTALL=false
INTERACTIVE=true

# ── Parse arguments ───────────────────────────────────────────────────────────

while [[ $# -gt 0 ]]; do
  case $1 in
    --global)
      GLOBAL_INSTALL=true
      INTERACTIVE=false
      shift
      ;;
    --project)
      PROJECT_INSTALL=true
      INTERACTIVE=false
      shift
      ;;
    --dir)
      if [[ -z "${2:-}" ]]; then
        echo "  ERROR: --dir requires a path argument"
        exit 1
      fi
      TARGET_DIR="${2/#\~/$HOME}"
      INTERACTIVE=false
      shift 2
      ;;
    -h|--help)
      echo "Usage: install.sh [--global] [--project] [--dir /path/to/project]"
      echo ""
      echo "  --global           Install to ~/.claude/skills/ (available in all projects)"
      echo "  --project          Install to ./.claude/skills/ (current directory only)"
      echo "  --dir /path        Install to /path/.claude/skills/"
      echo ""
      echo "  No flags: interactive prompt"
      exit 0
      ;;
    *)
      echo "  Unknown option: $1"
      echo "  Run with --help for usage."
      exit 1
      ;;
  esac
done

# ── Header ────────────────────────────────────────────────────────────────────

echo ""
echo "  CloudBalance Skills — installer"
echo "  https://www.cloudbalance.ai"
echo "  ────────────────────────────────────────"
echo ""

# ── Interactive mode ──────────────────────────────────────────────────────────
# Reads from /dev/tty so prompts work even when script is piped via curl | bash

if [[ "$INTERACTIVE" == "true" ]]; then
  echo "  Where would you like to install the CloudBalance skills?"
  echo ""
  echo "  1) Global   — ~/.claude/skills/  (available in all Claude Code projects)"
  echo "  2) Project  — ./.claude/skills/  (current directory only)"
  echo "  3) Custom   — specify a project directory"
  echo ""

  read -r -p "  Enter choice [1/2/3]: " choice </dev/tty
  echo ""

  case "$choice" in
    1) GLOBAL_INSTALL=true ;;
    2) PROJECT_INSTALL=true ;;
    3)
      read -r -p "  Project directory path: " TARGET_DIR </dev/tty
      TARGET_DIR="${TARGET_DIR/#\~/$HOME}"
      echo ""
      ;;
    *)
      echo "  Invalid choice. Exiting."
      exit 1
      ;;
  esac
fi

# ── Resolve install root ──────────────────────────────────────────────────────

if [[ "$GLOBAL_INSTALL" == "true" ]]; then
  SKILLS_ROOT="$HOME/.claude/skills"
elif [[ -n "$TARGET_DIR" ]]; then
  SKILLS_ROOT="$TARGET_DIR/.claude/skills"
else
  SKILLS_ROOT="$(pwd)/.claude/skills"
fi

PROJECT_DIR="${SKILLS_ROOT%/.claude/skills}"

# ── Validation ────────────────────────────────────────────────────────────────

echo "  Install location: $SKILLS_ROOT"
echo ""

if [[ "$GLOBAL_INSTALL" == "true" ]]; then
  # Warn if Claude Code doesn't appear to be installed
  if [[ ! -d "$HOME/.claude" ]]; then
    echo "  ⚠  WARNING: $HOME/.claude does not exist."
    echo "     Claude Code may not be installed yet."
    echo "     The skills will be installed but won't be detected until Claude Code is set up."
    echo ""
    read -r -p "  Continue anyway? [y/N]: " confirm </dev/tty
    echo ""
    [[ "$confirm" =~ ^[Yy]$ ]] || { echo "  Cancelled."; exit 0; }
  fi
else
  # Validate the target directory exists
  if [[ ! -d "$PROJECT_DIR" ]]; then
    echo "  ERROR: Directory does not exist: $PROJECT_DIR"
    exit 1
  fi

  # Warn if it doesn't look like a Claude Code project or git repo
  if [[ ! -d "$PROJECT_DIR/.claude" ]] && [[ ! -d "$PROJECT_DIR/.git" ]]; then
    echo "  ⚠  WARNING: $PROJECT_DIR does not appear to be a Claude Code project"
    echo "     (no .claude/ or .git/ directory found)"
    echo ""
    read -r -p "  Continue anyway? [y/N]: " confirm </dev/tty
    echo ""
    [[ "$confirm" =~ ^[Yy]$ ]] || { echo "  Cancelled."; exit 0; }
  fi
fi

# ── Confirm ───────────────────────────────────────────────────────────────────

echo "  Ready to install:"
echo "    Skill     : cloudbalance"
echo "    Destination: $SKILLS_ROOT/cloudbalance/"
echo ""

if [[ "$INTERACTIVE" == "true" ]]; then
  read -r -p "  Proceed? [Y/n]: " confirm </dev/tty
  confirm="${confirm:-Y}"
  echo ""
  [[ "$confirm" =~ ^[Yy]$ ]] || { echo "  Cancelled."; exit 0; }
fi

# ── Download and install ──────────────────────────────────────────────────────

WORK_DIR=$(mktemp -d 2>/dev/null || mktemp -d -t 'cb-skills')
trap 'rm -rf "$WORK_DIR"' EXIT

echo "  Downloading from GitHub..."
git clone --depth 1 --branch main --quiet "$REPO" "$WORK_DIR/repo"

SOURCE="$WORK_DIR/repo/$SKILLS_SOURCE_DIR"

if [[ ! -d "$SOURCE" ]]; then
  echo "  ERROR: Expected skills source directory not found in cloned repo."
  exit 1
fi

mkdir -p "$SKILLS_ROOT"

INSTALLED=()
SKIPPED=()

for skill_dir in "$SOURCE"/*/; do
  [[ -d "$skill_dir" ]] || continue
  skill_name=$(basename "$skill_dir")

  if [[ ! -f "$skill_dir/SKILL.md" ]]; then
    SKIPPED+=("$skill_name")
    continue
  fi

  DEST="$SKILLS_ROOT/$skill_name"
  [[ -d "$DEST" ]] && rm -rf "$DEST"
  cp -r "$skill_dir" "$DEST"
  INSTALLED+=("$skill_name")
done

# ── Results ───────────────────────────────────────────────────────────────────

echo ""

if [[ ${#INSTALLED[@]} -gt 0 ]]; then
  echo "  Installed (${#INSTALLED[@]}):"
  for skill in "${INSTALLED[@]}"; do
    echo "    /$skill  →  $SKILLS_ROOT/$skill/SKILL.md"
  done
fi

if [[ ${#SKIPPED[@]} -gt 0 ]]; then
  echo ""
  echo "  Skipped (no SKILL.md): ${SKIPPED[*]}"
fi

# ── Verify ────────────────────────────────────────────────────────────────────

echo ""
ERRORS=0
for skill in "${INSTALLED[@]}"; do
  if [[ ! -f "$SKILLS_ROOT/$skill/SKILL.md" ]]; then
    echo "  VERIFICATION FAILED: $SKILLS_ROOT/$skill/SKILL.md missing"
    ERRORS=$((ERRORS + 1))
  fi
done

if [[ $ERRORS -gt 0 ]]; then
  echo "  Installation completed with $ERRORS error(s)."
  exit 1
fi

echo "  Verification: OK"
echo ""

if [[ "$GLOBAL_INSTALL" == "true" ]]; then
  echo "  The /cloudbalance skill is now available in all Claude Code projects."
else
  echo "  The /cloudbalance skill is active when Claude Code is opened in:"
  echo "  $PROJECT_DIR"
fi

echo ""
echo "  Try it:"
echo "    \"What are my top AWS services by spend last month?\""
echo "    \"Show me EC2 rightsizing opportunities\""
echo "    \"How are my Savings Plans performing?\""
echo ""
