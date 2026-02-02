#!/bin/bash

# Stop Hook
# Claude 작업 완료 시 Git 변경사항 확인

# Git 저장소인지 확인
if ! git rev-parse --git-dir > /dev/null 2>&1; then
    echo '{"continue": true}'
    exit 0
fi

# 변경사항 확인
if git diff --quiet && git diff --cached --quiet && [ -z "$(git ls-files --others --exclude-standard)" ]; then
    # 변경사항 없음
    echo '{"continue": true}'
    exit 0
fi

# 변경사항 있음
CHANGED_FILES=$({ git diff --name-only; git diff --cached --name-only; git ls-files --others --exclude-standard; } | wc -l | tr -d ' ')

echo "" >&2
echo "💾 Git 변경사항 감지: $CHANGED_FILES 파일" >&2
echo "   커밋하려면: git add -A && git commit -m \"메시지\"" >&2
echo "   또는 git-manager 에이전트를 사용하세요" >&2
echo "" >&2

# 정상 종료 (continue: true)
echo '{"continue": true}'
