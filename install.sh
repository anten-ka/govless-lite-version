#!/bin/bash
# goVLESS Lite — установщик (VLESS + Reality, маскировка под сайт, без домена).
#
# Установка одной командой:
#   curl -fsSL https://raw.githubusercontent.com/anten-ka/govless-lite-version/main/install.sh -o /tmp/govless.sh && sudo bash /tmp/govless.sh
#
# Copyright (c) 2025-2026 anten-ka. Licensed under the goVLESS Source-Available License.
set -uo pipefail

if [ "$(id -u)" -ne 0 ]; then
    echo "Ошибка: запустите через sudo." >&2
    echo "  curl -fsSL https://raw.githubusercontent.com/anten-ka/govless-lite-version/main/install.sh -o /tmp/govless.sh && sudo bash /tmp/govless.sh" >&2
    exit 1
fi

echo ""
echo "  goVLESS Lite — установка. Займёт пару минут, не закрывайте окно…"
echo ""

REPO="https://github.com/anten-ka/govless-lite-version.git"
DEST="/opt/govless-installer"

# Запущены из уже склонированного репозитория?
SRC=""
if [ -n "${BASH_SOURCE:-}" ]; then
    SRC="$(cd "$(dirname "$(readlink -f "${BASH_SOURCE[0]}" 2>/dev/null)")" 2>/dev/null && pwd || true)"
fi

if [ -n "$SRC" ] && [ -f "$SRC/govless.sh" ] && [ -d "$SRC/lib" ]; then
    echo "  → Ставлю из локальной копии…"
    mkdir -p "$DEST"
    cp -rf "$SRC/govless.sh" "$SRC/lib" "$DEST"/ 2>/dev/null || true
else
    if ! command -v git >/dev/null 2>&1 || ! command -v curl >/dev/null 2>&1; then
        echo "  → Доустанавливаю git/curl…"
        export DEBIAN_FRONTEND=noninteractive
        apt-get update -qq >/dev/null 2>&1 || true
        apt-get install -y -qq git curl >/dev/null 2>&1 || true
    fi
    echo "  → Загружаю установщик goVLESS…"
    rm -rf "$DEST"
    if ! git clone -q --depth 1 "$REPO" "$DEST"; then
        echo "Ошибка: не удалось склонировать $REPO" >&2
        exit 1
    fi
fi

chmod +x "$DEST/govless.sh" 2>/dev/null || true
echo "  → Запускаю установщик…"
echo ""

# Интерактив: если stdin не терминал (запуск через pipe) — берём /dev/tty.
if [ ! -t 0 ] && [ -e /dev/tty ]; then
    exec bash "$DEST/govless.sh" < /dev/tty
fi
exec bash "$DEST/govless.sh"
