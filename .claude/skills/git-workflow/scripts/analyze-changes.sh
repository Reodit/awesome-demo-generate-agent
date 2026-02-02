#!/bin/bash

# Analyze Changes Script
# 현재 변경사항을 분석해서 커밋 타입과 메시지 제안

set -e

# Git 저장소 확인
if ! git rev-parse --git-dir > /dev/null 2>&1; then
    echo '{"success": false, "error": "Not a git repository"}'
    exit 1
fi

# 변경사항 확인
HAS_CHANGES=false
if ! git diff --quiet || ! git diff --cached --quiet || [ -n "$(git ls-files --others --exclude-standard)" ]; then
    HAS_CHANGES=true
fi

if [ "$HAS_CHANGES" = "false" ]; then
    echo '{"hasChanges": false, "fileCount": 0, "changedFiles": [], "suggestedType": null, "suggestedMessage": null}'
    exit 0
fi

# 변경된 파일 목록
CHANGED_FILES=$(git diff --name-only; git diff --cached --name-only; git ls-files --others --exclude-standard)
FILE_COUNT=$(echo "$CHANGED_FILES" | wc -l | tr -d ' ')

# 파일 분류
NEW_FILES=$(git ls-files --others --exclude-standard | wc -l | tr -d ' ')
MODIFIED_FILES=$(git diff --name-only | wc -l | tr -d ' ')
STAGED_FILES=$(git diff --cached --name-only | wc -l | tr -d ' ')
DELETED_FILES=$(git diff --diff-filter=D --name-only | wc -l | tr -d ' ')

# 커밋 타입 결정 로직
determine_type() {
    local files="$1"

    # 테스트 파일
    if echo "$files" | grep -q "\.test\.\|\.spec\.\|__tests__"; then
        echo "test"
        return
    fi

    # 문서
    if echo "$files" | grep -q "README\.md\|docs/\|\.md$"; then
        echo "docs"
        return
    fi

    # 스타일
    if echo "$files" | grep -q "\.css$\|\.scss$\|tailwind\|styles/"; then
        echo "style"
        return
    fi

    # 설정
    if echo "$files" | grep -q "\.claude/\|\.github/\|package\.json\|tsconfig\.json\|\.gitignore"; then
        echo "chore"
        return
    fi

    # 컴포넌트/기능
    if echo "$files" | grep -q "components/\|app/\|src/"; then
        if [ "$NEW_FILES" -gt 0 ]; then
            echo "feat"
        else
            echo "refactor"
        fi
        return
    fi

    # 기본값
    if [ "$NEW_FILES" -gt 0 ]; then
        echo "feat"
    else
        echo "chore"
    fi
}

SUGGESTED_TYPE=$(determine_type "$CHANGED_FILES")

# 커밋 메시지 제안
generate_message() {
    local type="$1"
    local files="$2"

    local main_file=$(echo "$files" | head -1 | sed 's/.*\///' | sed 's/\.[^.]*$//')

    if echo "$files" | grep -q "components/"; then
        local component_names=$(echo "$files" | grep "components/" | sed 's/.*\///' | sed 's/\.[^.]*$//' | head -3 | paste -sd ", " -)
        if [ "$NEW_FILES" -gt 0 ]; then
            echo "${type}: Add ${component_names} component"
        else
            echo "${type}: Update ${component_names} component"
        fi
    elif echo "$files" | grep -q "\.claude/"; then
        echo "${type}: Update Claude Code configuration"
    elif echo "$files" | grep -q "README\.md"; then
        echo "${type}: Update README documentation"
    elif echo "$files" | grep -q "package\.json"; then
        echo "${type}: Update project dependencies"
    else
        if [ "$NEW_FILES" -gt 0 ] && [ "$MODIFIED_FILES" -gt 0 ]; then
            echo "${type}: Add and update project files"
        elif [ "$NEW_FILES" -gt 0 ]; then
            echo "${type}: Add new files ($FILE_COUNT files)"
        elif [ "$DELETED_FILES" -gt 0 ]; then
            echo "${type}: Remove files ($DELETED_FILES files)"
        else
            echo "${type}: Update project files ($FILE_COUNT files)"
        fi
    fi
}

SUGGESTED_MESSAGE=$(generate_message "$SUGGESTED_TYPE" "$CHANGED_FILES")

# 파일 목록을 JSON 배열로 변환 (jq 없이)
FILES_JSON="["
FIRST=true
while IFS= read -r file; do
    if [ -n "$file" ]; then
        if [ "$FIRST" = true ]; then
            FIRST=false
        else
            FILES_JSON+=","
        fi
        FILES_JSON+="\"$file\""
    fi
done <<< "$CHANGED_FILES"
FILES_JSON+="]"

# JSON 출력
cat <<EOF
{
  "hasChanges": true,
  "fileCount": $FILE_COUNT,
  "changedFiles": $FILES_JSON,
  "suggestedType": "$SUGGESTED_TYPE",
  "suggestedMessage": "$SUGGESTED_MESSAGE",
  "breakdown": {
    "newFiles": $NEW_FILES,
    "modifiedFiles": $MODIFIED_FILES,
    "stagedFiles": $STAGED_FILES,
    "deletedFiles": $DELETED_FILES
  }
}
EOF
