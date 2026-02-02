#!/bin/bash

# Smart Commit Script
# 변경사항을 분석해서 자동으로 의미있는 커밋 생성

set -e

VERBOSE="${GIT_WORKFLOW_VERBOSE:-false}"
DRY_RUN="${GIT_WORKFLOW_DRY_RUN:-false}"
LANG="${GIT_COMMIT_LANG:-en}"

# 로그 함수
log() {
    if [ "$VERBOSE" = "true" ]; then
        echo "[smart-commit] $1" >&2
    fi
}

# Git 상태 확인
check_git_status() {
    if ! git rev-parse --git-dir > /dev/null 2>&1; then
        echo '{"success": false, "error": "Not a git repository"}'
        exit 1
    fi
}

# Main 브랜치 보호
check_main_branch() {
    local current_branch=$(git branch --show-current)
    if [ "$current_branch" = "main" ] || [ "$current_branch" = "master" ]; then
        log "경고: main/master 브랜치에서 직접 커밋하려고 합니다"
        echo "[경고] main/master 브랜치에 직접 커밋합니다" >&2
    fi
}

# 변경사항 확인
has_changes() {
    if ! git diff --quiet || ! git diff --cached --quiet || [ -n "$(git ls-files --others --exclude-standard)" ]; then
        return 0
    else
        return 1
    fi
}

# 변경된 파일 목록
get_changed_files() {
    git diff --name-only
    git diff --cached --name-only
    git ls-files --others --exclude-standard
}

# 커밋 타입 결정
determine_commit_type() {
    local files="$1"

    # 새 파일 확인
    local new_files=$(git ls-files --others --exclude-standard | wc -l | tr -d ' ')

    # 경로 기반 분석
    if echo "$files" | grep -q "^app/components/\|^components/\|^src/components/"; then
        if [ "$new_files" -gt 0 ]; then
            echo "feat"
            return
        fi
    fi

    if echo "$files" | grep -q "\.test\.\|\.spec\.\|__tests__"; then
        echo "test"
        return
    fi

    if echo "$files" | grep -q "README\.md\|docs/\|\.md$"; then
        echo "docs"
        return
    fi

    if echo "$files" | grep -q "\.css$\|\.scss$\|tailwind\|styles/"; then
        echo "style"
        return
    fi

    if echo "$files" | grep -q "\.claude/\|\.github/\|package\.json\|tsconfig\.json"; then
        echo "chore"
        return
    fi

    # diff 내용 기반 분석
    local diff_content=$(git diff HEAD 2>/dev/null || git diff)

    if echo "$diff_content" | grep -qi "fix\|bug\|issue\|error"; then
        echo "fix"
        return
    fi

    if [ "$new_files" -gt 0 ]; then
        echo "feat"
        return
    fi

    # 기본값
    echo "chore"
}

# 커밋 메시지 생성
generate_commit_message() {
    local commit_type="$1"
    local files="$2"

    local file_count=$(echo "$files" | wc -l | tr -d ' ')
    local new_files=$(git ls-files --others --exclude-standard | wc -l | tr -d ' ')
    local modified_files=$(git diff --name-only | wc -l | tr -d ' ')

    # 주요 변경 파일 추출
    local main_file=$(echo "$files" | head -1 | sed 's/.*\///' | sed 's/\.[^.]*$//')

    # 디렉토리 기반 설명
    local description=""

    if echo "$files" | grep -q "app/components/\|components/"; then
        local component_names=$(echo "$files" | grep "components/" | sed 's/.*\///' | sed 's/\.[^.]*$//' | head -3 | paste -sd ", " -)
        if [ "$new_files" -gt 0 ]; then
            description="Add $component_names component"
        else
            description="Update $component_names component"
        fi
    elif echo "$files" | grep -q "\.claude/agents/"; then
        description="Update agent configuration"
    elif echo "$files" | grep -q "\.claude/skills/"; then
        description="Update skill configuration"
    elif echo "$files" | grep -q "README\.md"; then
        description="Update README"
    elif echo "$files" | grep -q "package\.json"; then
        description="Update dependencies"
    else
        if [ "$new_files" -gt 0 ] && [ "$modified_files" -gt 0 ]; then
            description="Add and update $file_count files"
        elif [ "$new_files" -gt 0 ]; then
            description="Add $file_count files"
        else
            description="Update $file_count files"
        fi
    fi

    # 한국어 변환
    if [ "$LANG" = "ko" ]; then
        description=$(echo "$description" | sed \
            -e 's/Add/추가:/' \
            -e 's/Update/수정:/' \
            -e 's/component/컴포넌트/' \
            -e 's/files/파일/' \
            -e 's/dependencies/의존성/')
    fi

    echo "${commit_type}: ${description}"
}

# 메인 실행
main() {
    log "Git 저장소 확인..."
    check_git_status

    log "변경사항 확인..."
    if ! has_changes; then
        echo '{"success": false, "error": "No changes to commit"}'
        exit 0
    fi

    check_main_branch

    log "변경된 파일 분석..."
    local changed_files=$(get_changed_files)
    local file_count=$(echo "$changed_files" | wc -l | tr -d ' ')

    log "커밋 타입 결정..."
    local commit_type=$(determine_commit_type "$changed_files")

    log "커밋 메시지 생성..."
    local commit_message=$(generate_commit_message "$commit_type" "$changed_files")

    # DRY RUN 모드
    if [ "$DRY_RUN" = "true" ]; then
        echo "변경사항: $file_count files" >&2
        echo "커밋 타입: $commit_type" >&2
        echo "커밋 메시지: $commit_message" >&2
        echo '{"success": true, "dryRun": true, "commitMessage": "'"$commit_message"'", "fileCount": '$file_count'}'
        exit 0
    fi

    # 실제 커밋 실행
    log "git add 실행..."
    git add -A

    log "git commit 실행..."
    git commit -m "$commit_message" --no-verify

    local commit_hash=$(git rev-parse --short HEAD)

    echo "✓ 커밋 완료: $commit_hash" >&2
    echo "  메시지: $commit_message" >&2
    echo "  파일: $file_count" >&2

    # JSON 출력
    echo '{"success": true, "commitHash": "'"$commit_hash"'", "commitMessage": "'"$commit_message"'", "filesChanged": '$file_count'}'
}

main "$@"
