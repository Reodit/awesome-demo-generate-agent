#!/bin/bash

# Checkpoint Script
# 중요한 작업 시점을 체크포인트로 저장

set -e

VERBOSE="${GIT_WORKFLOW_VERBOSE:-false}"

log() {
    if [ "$VERBOSE" = "true" ]; then
        echo "[checkpoint] $1" >&2
    fi
}

# 인자 확인
if [ $# -lt 1 ]; then
    echo "Usage: $0 <checkpoint-name>" >&2
    echo '{"success": false, "error": "Missing checkpoint name"}'
    exit 1
fi

CHECKPOINT_NAME="$1"

# Git 저장소 확인
if ! git rev-parse --git-dir > /dev/null 2>&1; then
    echo '{"success": false, "error": "Not a git repository"}'
    exit 1
fi

# 타임스탬프
TIMESTAMP=$(date +"%Y%m%d-%H%M")

# 태그 이름 생성
TAG_NAME="checkpoint/${CHECKPOINT_NAME}-${TIMESTAMP}"

# 이름 정규화
TAG_NAME=$(echo "$TAG_NAME" | tr ' ' '-' | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9\/-]//g')

log "체크포인트 생성: $TAG_NAME"

# 변경사항 확인
HAS_CHANGES=false
if ! git diff --quiet || ! git diff --cached --quiet || [ -n "$(git ls-files --others --exclude-standard)" ]; then
    HAS_CHANGES=true
fi

# 변경사항 있으면 stash
STASH_CREATED=false
if [ "$HAS_CHANGES" = "true" ]; then
    log "변경사항을 stash에 저장..."
    git stash push -m "Checkpoint: $CHECKPOINT_NAME"
    STASH_CREATED=true
    echo "[Info] 변경사항을 stash에 저장했습니다" >&2
fi

# 현재 커밋에 태그 생성
CURRENT_COMMIT=$(git rev-parse --short HEAD)
git tag -a "$TAG_NAME" -m "Checkpoint: $CHECKPOINT_NAME"

log "태그 생성 완료: $TAG_NAME @ $CURRENT_COMMIT"

echo "✓ 체크포인트 생성 완료" >&2
echo "  이름: $TAG_NAME" >&2
echo "  커밋: $CURRENT_COMMIT" >&2
if [ "$STASH_CREATED" = "true" ]; then
    echo "  Stash: 변경사항 저장됨" >&2
fi
echo "" >&2
echo "롤백 방법:" >&2
echo "  git checkout $TAG_NAME" >&2
if [ "$STASH_CREATED" = "true" ]; then
    echo "  git stash pop  # 변경사항 복원" >&2
fi

# JSON 출력
echo '{"success": true, "tagName": "'"$TAG_NAME"'", "commit": "'"$CURRENT_COMMIT"'", "stashCreated": '$STASH_CREATED'}'
