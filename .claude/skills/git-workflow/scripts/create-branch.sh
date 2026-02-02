#!/bin/bash

# Create Branch Script
# 작업 타입에 맞는 브랜치를 자동 생성

set -e

VERBOSE="${GIT_WORKFLOW_VERBOSE:-false}"

log() {
    if [ "$VERBOSE" = "true" ]; then
        echo "[create-branch] $1" >&2
    fi
}

# 인자 확인
if [ $# -lt 2 ]; then
    echo "Usage: $0 <type> <description>" >&2
    echo "Types: feature, experiment, bugfix" >&2
    echo '{"success": false, "error": "Missing arguments"}'
    exit 1
fi

TYPE="$1"
DESCRIPTION="$2"

# 타입 검증
case "$TYPE" in
    feature|experiment|bugfix)
        ;;
    *)
        echo "Error: Invalid type '$TYPE'" >&2
        echo "Valid types: feature, experiment, bugfix" >&2
        echo '{"success": false, "error": "Invalid type"}'
        exit 1
        ;;
esac

# Git 저장소 확인
if ! git rev-parse --git-dir > /dev/null 2>&1; then
    echo '{"success": false, "error": "Not a git repository"}'
    exit 1
fi

# 현재 브랜치 저장
PREVIOUS_BRANCH=$(git branch --show-current)

# 브랜치 이름 생성
TIMESTAMP=$(date +"%Y%m%d-%H%M")
if [ "$TYPE" = "experiment" ]; then
    # Experiment는 시간 빼고 날짜만
    TIMESTAMP=$(date +"%Y%m%d")
fi

BRANCH_NAME="${TYPE}/${DESCRIPTION}-${TIMESTAMP}"

# 설명에서 공백과 특수문자 제거
BRANCH_NAME=$(echo "$BRANCH_NAME" | tr ' ' '-' | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9\/-]//g')

log "브랜치 생성: $BRANCH_NAME"

# 미커밋 변경사항 확인
if ! git diff --quiet || ! git diff --cached --quiet; then
    log "경고: 미커밋 변경사항이 있습니다"
    echo "[경고] 변경사항을 stash에 저장합니다" >&2
    git stash push -m "Auto-stash before creating branch $BRANCH_NAME"
fi

# 브랜치 생성 및 전환
git checkout -b "$BRANCH_NAME"

echo "✓ 브랜치 생성 완료: $BRANCH_NAME" >&2
echo "  이전 브랜치: $PREVIOUS_BRANCH" >&2

# JSON 출력
echo '{"success": true, "branchName": "'"$BRANCH_NAME"'", "previousBranch": "'"$PREVIOUS_BRANCH"'", "type": "'"$TYPE"'"}'
