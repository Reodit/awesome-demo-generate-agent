#!/bin/bash

# Session Start Hook
# 새 세션 시작 시 Git 상태 확인 및 준비

# Git 저장소인지 확인
if ! git rev-parse --git-dir > /dev/null 2>&1; then
    exit 0
fi

# 현재 브랜치
CURRENT_BRANCH=$(git branch --show-current)

# Git 상태 출력
echo "📋 Git 상태:" >&2
echo "  브랜치: $CURRENT_BRANCH" >&2

# 변경사항 확인
if ! git diff --quiet || ! git diff --cached --quiet; then
    CHANGED_FILES=$(git diff --name-only | wc -l | tr -d ' ')
    echo "  ⚠️  미커밋 변경사항: $CHANGED_FILES 파일" >&2
fi

# Stash 확인
STASH_COUNT=$(git stash list | wc -l | tr -d ' ')
if [ "$STASH_COUNT" -gt 0 ]; then
    echo "  📦 Stash: $STASH_COUNT 개" >&2
fi

# 최근 커밋
LAST_COMMIT=$(git log -1 --pretty=format:"%h %s" 2>/dev/null)
if [ -n "$LAST_COMMIT" ]; then
    echo "  최근 커밋: $LAST_COMMIT" >&2
fi

echo "" >&2

# 정상 종료 (continue: true)
echo '{"continue": true}'
