#!/usr/bin/env bash
set -euo pipefail

if ! command -v brew &>/dev/null; then
  echo "未偵測到 Homebrew，請先安裝：https://brew.sh"
  exit 1
fi

if command -v gh &>/dev/null; then
  echo "gh 已安裝，版本：$(gh --version | head -n1)"
else
  echo "正在安裝 GitHub CLI (gh)..."
  brew install gh
fi

if gh auth status &>/dev/null; then
  echo "已經登入 GitHub 帳號："
  gh auth status
else
  echo "開始使用瀏覽器登入驗證 GitHub 帳號..."
  gh auth login --web --git-protocol https
fi
