#!/usr/bin/env bash
set -euo pipefail

# ──────────────────────────────────────────────
#  GitHub CLI (gh) 管理工具 - macOS
# ──────────────────────────────────────────────

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
BOLD='\033[1m'
RESET='\033[0m'

print_header() {
  echo ""
  echo -e "${CYAN}${BOLD}╔══════════════════════════════════════╗${RESET}"
  echo -e "${CYAN}${BOLD}║      GitHub CLI 管理工具 (macOS)     ║${RESET}"
  echo -e "${CYAN}${BOLD}╚══════════════════════════════════════╝${RESET}"
  echo ""
}

check_brew() {
  if ! command -v brew &>/dev/null; then
    echo -e "${RED}✗ 未偵測到 Homebrew，請先安裝：https://brew.sh${RESET}"
    exit 1
  fi
}

check_fzf() {
  if ! command -v fzf &>/dev/null; then
    echo -e "${YELLOW}⏳ 未偵測到 fzf，正在透過 Homebrew 安裝...${RESET}"
    brew install fzf
    echo -e "${GREEN}✓ fzf 安裝完成${RESET}"
  fi
}

install_gh() {
  echo -e "${BOLD}▶ 安裝 GitHub CLI (gh)${RESET}"
  if command -v gh &>/dev/null; then
    echo -e "${GREEN}✓ gh 已安裝，版本：$(gh --version | head -n1)${RESET}"
  else
    echo -e "${YELLOW}⏳ 正在透過 Homebrew 安裝 gh...${RESET}"
    brew install gh
    echo -e "${GREEN}✓ 安裝完成：$(gh --version | head -n1)${RESET}"
  fi
}

login_gh() {
  echo -e "${BOLD}▶ 登入 GitHub 帳號${RESET}"
  if ! command -v gh &>/dev/null; then
    echo -e "${RED}✗ gh 尚未安裝，請先執行安裝${RESET}"
    return 1
  fi
  if gh auth status --hostname github.com &>/dev/null; then
    echo -e "${YELLOW}⚠ 已偵測到登入狀態：${RESET}"
    gh auth status || true
    echo ""
    read -rp "是否要重新登入？(y/N): " confirm
    [[ "$(echo "$confirm" | tr '[:upper:]' '[:lower:]')" != "y" ]] && echo "取消。" && return 0
  fi
  echo -e "${CYAN}⏳ 開啟瀏覽器進行 GitHub 登入驗證...${RESET}"
  gh auth login --web --git-protocol https
  echo ""
  echo -e "${GREEN}✓ 登入完成：${RESET}"
  gh auth status || true
}

logout_gh() {
  echo -e "${BOLD}▶ 登出 GitHub 帳號${RESET}"
  if ! command -v gh &>/dev/null; then
    echo -e "${RED}✗ gh 尚未安裝${RESET}"
    return 1
  fi
  if ! gh auth status --hostname github.com &>/dev/null; then
    echo -e "${YELLOW}⚠ 目前尚未登入任何 GitHub 帳號${RESET}"
    return 0
  fi
  echo -e "${YELLOW}目前登入狀態：${RESET}"
  gh auth status || true
  echo ""
  read -rp "確定要登出？(y/N): " confirm
  if [[ "$(echo "$confirm" | tr '[:upper:]' '[:lower:]')" == "y" ]]; then
    local host
    host=$(gh auth status 2>&1 | grep "Logged in to" | awk '{print $5}' | head -n1)
    host="${host:-github.com}"
    gh auth logout --hostname "$host"
    echo -e "${GREEN}✓ 已登出 ${host}${RESET}"
  else
    echo "取消。"
  fi
}

show_status() {
  echo -e "${BOLD}▶ 目前 GitHub CLI 狀態${RESET}"
  if ! command -v gh &>/dev/null; then
    echo -e "${RED}✗ gh 尚未安裝${RESET}"
    return 0
  fi
  echo -e "${GREEN}✓ gh 已安裝：$(gh --version | head -n1)${RESET}"
  if gh auth status --hostname github.com &>/dev/null; then
    gh auth status || true
  else
    echo -e "${YELLOW}⚠ 尚未登入任何 GitHub 帳號${RESET}"
  fi
}

main_menu() {
  check_brew
  check_fzf

  local options=(
    "󰮤  安裝 GitHub CLI (gh)"
    "  登入 GitHub 帳號"
    "  登出 GitHub 帳號"
    "  查看目前登入狀態"
    "  離開"
  )

  while true; do
    print_header

    local fzf_input=""
    for i in "${!options[@]}"; do
      fzf_input+="${options[$i]}\n"
    done

    local choice
    choice=$(printf '%b' "$fzf_input" | fzf \
      --ansi \
      --no-sort \
      --height=45% \
      --border=rounded \
      --prompt="  GitHub CLI ❯ " \
      --pointer="▶" \
      --color="fg:#cdd6f4,bg:#1e1e2e,hl:#89b4fa,fg+:#cdd6f4,bg+:#313244,hl+:#89b4fa,prompt:#a6e3a1,pointer:#f38ba8,border:#6c7086,preview-bg:#181825,preview-fg:#a6adc8" \
      --preview='
        case "{}" in
          *安裝*) echo "📦 透過 Homebrew 安裝 gh，已安裝則顯示版本" ;;
          *登入*) echo "🔑 使用瀏覽器 Web 驗證登入 GitHub 帳號" ;;
          *登出*) echo "🚪 登出目前已登入的 GitHub 帳號" ;;
          *查看*) echo "📋 顯示 gh 安裝版本與登入帳號資訊" ;;
          *離開*) echo "👋 結束程式" ;;
        esac
      ' \
      --preview-window="bottom:3:wrap" \
    ) || { echo -e "${CYAN}掰掰！${RESET}"; exit 0; }

    echo ""
    case "$choice" in
      *"安裝 GitHub CLI"*) install_gh ;;
      *"登入"*)            login_gh ;;
      *"登出"*)            logout_gh ;;
      *"查看"*)            show_status ;;
      *"離開"*)            echo -e "${CYAN}掰掰！${RESET}"; exit 0 ;;
    esac

    echo ""
    read -rp "按 Enter 返回主選單..."
  done
}

main_menu
