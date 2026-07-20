#!/usr/bin/env bash
set -euo pipefail

if command -v gh &>/dev/null; then
  echo "gh 已安裝，版本：$(gh --version | head -n1)"
else
  echo "正在安裝 GitHub CLI (gh)..."

  (type -p wget >/dev/null || (sudo apt update && sudo apt-get install wget -y)) \
    && sudo mkdir -p -m 755 /etc/apt/keyrings \
    && out=$(mktemp) && wget -nv -O"$out" https://cli.github.com/packages/githubcli-archive-keyring.gpg \
    && cat "$out" | sudo tee /etc/apt/keyrings/githubcli-archive-keyring.gpg > /dev/null \
    && sudo chmod go+r /etc/apt/keyrings/githubcli-archive-keyring.gpg \
    && sudo mkdir -p -m 755 /etc/apt/sources.list.d \
    && echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null \
    && sudo apt update \
    && sudo apt install gh -y
fi

if gh auth status &>/dev/null; then
  echo "已經登入 GitHub 帳號："
  gh auth status
else
  echo "開始使用瀏覽器登入驗證 GitHub 帳號..."
  gh auth login --web --git-protocol https
fi
