#!/bin/bash

# Clean History Script
# 여러 작업 커밋을 의미있는 단위로 정리

set -e

VERBOSE="${GIT_WORKFLOW_VERBOSE:-false}"

log() {
    if [ "$VERBOSE" = "true" ]; then
        echo "[clean-history] $1" >&2
    fi
}

# 인자 확인
if [ $# -lt 1 ]; then
    echo "Usage: $0 <commit-count>" >&2
    echo "Example: $0 5  # Squash last 5 commits" >&2
    echo '{"success": false, "error": "Missing commit count"}'
    exit 1
fi

COMMIT_COUNT="$1"

# 숫자 확인
if ! [[ "$COMMIT_COUNT" =~ ^[0-9]+$ ]]; then
    echo "Error: Commit count must be a number" >&2
    echo '{"success": false, "error": "Invalid commit count"}'
    exit 1
fi

# Git 저장소 확인
if ! git rev-parse --git-dir > /dev/null 2>&1; then
    echo '{"success": false, "error": "Not a git repository"}'
    exit 1
fi

# 커밋 수 확인
TOTAL_COMMITS=$(git rev-list --count HEAD)
if [ "$COMMIT_COUNT" -gt "$TOTAL_COMMITS" ]; then
    echo "Error: Only $TOTAL_COMMITS commits available" >&2
    echo '{"success": false, "error": "Not enough commits"}'
    exit 1
fi

# 미커밋 변경사항 확인
if ! git diff --quiet || ! git diff --cached --quiet; then
    echo "Error: You have uncommitted changes. Please commit or stash them first." >&2
    echo '{"success": false, "error": "Uncommitted changes exist"}'
    exit 1
fi

# 현재 브랜치
CURRENT_BRANCH=$(git branch --show-current)

# Main 브랜치 보호
if [ "$CURRENT_BRANCH" = "main" ] || [ "$CURRENT_BRANCH" = "master" ]; then
    echo "Error: Cannot clean history on main/master branch" >&2
    echo '{"success": false, "error": "Cannot modify main branch"}'
    exit 1
fi

# Remote 푸시 확인
REMOTE_COMMITS=$(git rev-list --count @{u}..HEAD 2>/dev/null || echo "0")
if [ "$REMOTE_COMMITS" -eq 0 ]; then
    echo "Warning: These commits might have been pushed to remote" >&2
    echo "Warning: Cleaning history will rewrite public history!" >&2
    read -p "Continue? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo '{"success": false, "error": "User cancelled"}'
        exit 0
    fi
fi

log "백업 태그 생성..."
BACKUP_TAG="backup/before-clean-$(date +%Y%m%d-%H%M)"
git tag "$BACKUP_TAG"

log "최근 $COMMIT_COUNT 개 커밋 정리 중..."

# 커밋 메시지들 수집
COMMIT_MESSAGES=$(git log -"$COMMIT_COUNT" --pretty=format:"%s" | paste -sd "; " -)

# Interactive rebase 자동화 (squash)
# macOS와 Linux 호환성 처리
if [[ "$OSTYPE" == "darwin"* ]]; then
    GIT_SEQUENCE_EDITOR="sed -i '' '2,\$s/^pick/squash/'" git rebase -i HEAD~"$COMMIT_COUNT"
else
    GIT_SEQUENCE_EDITOR="sed -i '2,\$s/^pick/squash/'" git rebase -i HEAD~"$COMMIT_COUNT"
fi

echo "✓ 히스토리 정리 완료" >&2
echo "  정리된 커밋: $COMMIT_COUNT" >&2
echo "  백업 태그: $BACKUP_TAG" >&2
echo "" >&2
echo "롤백 방법:" >&2
echo "  git reset --hard $BACKUP_TAG" >&2

# JSON 출력
echo '{"success": true, "cleanedCommits": '$COMMIT_COUNT', "backupTag": "'"$BACKUP_TAG"'", "branch": "'"$CURRENT_BRANCH"'"}'
