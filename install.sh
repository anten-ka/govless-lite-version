#!/bin/bash
# goVLESS Lite — установщик (VLESS + Reality, маскировка под сайт, без домена).
#
# Установка одной командой:
#   sudo bash <(curl -sSL https://raw.githubusercontent.com/anten-ka/govless-lite-version/main/install.sh)
#
# Copyright (c) 2025-2026 anten-ka. Licensed under the goVLESS Source-Available License.
set -uo pipefail

if [ "$(id -u)" -ne 0 ]; then
    echo "Ошибка: запустите через sudo." >&2
    echo "  sudo bash <(curl -sSL https://raw.githubusercontent.com/anten-ka/govless-lite-version/main/install.sh)" >&2
    exit 1
fi

REPO="https://github.com/anten-ka/govless-lite-version.git"
DEST="/opt/govless-installer"

# Определяем, запущены ли мы из уже склонированного репозитория.
SRC=""
if [ -n "${BASH_SOURCE:-}" ]; then
    SRC="$(cd "$(dirname "$(readlink -f "${BASH_SOURCE[0]}" 2>/dev/null)")" 2>/dev/null && pwd || true)"
fi

if [ -n "$SRC" ] && [ -f "$SRC/govless.sh" ] && [ -d "$SRC/lib" ]; then
    # запущено из локального клона — ставим из локальных файлов (без сети)
    mkdir -p "$DEST"
    cp -rf "$SRC/govless.sh" "$SRC/lib" "$DEST"/ 2>/dev/null || true
else
    # запущено через curl|bash — доустанавливаем git/curl и клонируем
    if ! command -v git >/dev/null 2>&1 || ! command -v curl >/dev/null 2>&1; then
        export DEBIAN_FRONTEND=noninteractive
        apt-get update -qq >/dev/null 2>&1 || true
        apt-get install -y -qq git curl >/dev/null 2>&1 || true
    fi
    rm -rf "$DEST"
    if ! git clone -q --depth 1 "$REPO" "$DEST"; then
        echo "Ошибка: не удалось склонировать $REPO" >&2
        exit 1
    fi
fi

chmod +x "$DEST/govless.sh" 2>/dev/null || true

# Запуск установщика. Для curl|bash (stdin не терминал) подключаем /dev/tty,
# чтобы интерактивные вопросы работали.
if [ ! -t 0 ] && [ -e /dev/tty ]; then
    exec bash "$DEST/govless.sh" < /dev/tty
fi
exec bash "$DEST/govless.sh"
