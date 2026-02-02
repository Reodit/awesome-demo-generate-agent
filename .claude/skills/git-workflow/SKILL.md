---
name: git-workflow
description: Git 작업을 자동화하는 스킬입니다. 스마트 커밋, 브랜치 관리, 변경사항 분석 기능을 제공합니다.
metadata:
  author: custom
  version: "1.0.0"
---

# Git Workflow Skill

Git 작업을 지능적으로 자동화하는 스킬입니다.

## 제공 기능

### 1. 스마트 커밋 (Smart Commit)
변경사항을 분석해서 자동으로 의미있는 커밋을 생성합니다.

**사용법:**
```bash
bash .claude/skills/git-workflow/scripts/smart-commit.sh
```

**동작:**
1. `git status`로 변경사항 확인
2. 변경된 파일 경로/내용 분석
3. Conventional Commits 타입 자동 결정
4. 커밋 메시지 자동 생성
5. `git add` + `git commit` 실행

**출력 예시:**
```
분석 중...
변경사항: 3 files
- app/components/Hero.tsx (new)
- app/components/Header.tsx (modified)
- README.md (modified)

커밋 타입: feat
커밋 메시지: feat: Add Hero component and update Header

✓ 커밋 완료: abc1234
```

---

### 2. 브랜치 생성 (Create Branch)
작업 타입에 맞는 브랜치를 자동 생성합니다.

**사용법:**
```bash
bash .claude/skills/git-workflow/scripts/create-branch.sh <type> <description>
```

**타입:**
- `feature` - 새 기능 개발
- `experiment` - 실험적 작업
- `bugfix` - 버그 수정

**예시:**
```bash
# Feature 브랜치
bash .claude/skills/git-workflow/scripts/create-branch.sh feature "hero-animation"
→ feature/hero-animation-20260129-1430

# Experiment 브랜치
bash .claude/skills/git-workflow/scripts/create-branch.sh experiment "swarm-mode"
→ experiment/swarm-mode-20260129

# Bugfix 브랜치
bash .claude/skills/git-workflow/scripts/create-branch.sh bugfix "mobile-overflow"
→ bugfix/mobile-overflow-20260129
```

---

### 3. 변경사항 분석 (Analyze Changes)
현재 변경사항을 분석해서 커밋 타입과 메시지를 제안합니다.

**사용법:**
```bash
bash .claude/skills/git-workflow/scripts/analyze-changes.sh
```

**출력 (JSON):**
```json
{
  "hasChanges": true,
  "fileCount": 5,
  "changedFiles": [
    "app/components/Hero.tsx",
    "app/components/Header.tsx",
    "app/globals.css",
    "README.md",
    ".claude/agents/git-manager/AGENT.md"
  ],
  "suggestedType": "feat",
  "suggestedMessage": "feat: Add Hero component with responsive design",
  "breakdown": {
    "newFiles": 2,
    "modifiedFiles": 3,
    "deletedFiles": 0
  }
}
```

---

### 4. 체크포인트 저장 (Save Checkpoint)
중요한 작업 시점을 체크포인트로 저장합니다.

**사용법:**
```bash
bash .claude/skills/git-workflow/scripts/checkpoint.sh "<checkpoint-name>"
```

**특징:**
- 자동으로 stash 생성
- 태그와 커밋으로 이중 백업
- 롤백 쉬움

**예시:**
```bash
bash .claude/skills/git-workflow/scripts/checkpoint.sh "before-refactoring"
→ checkpoint/before-refactoring-20260129-1430 태그 생성
→ 변경사항 stash 저장
```

---

### 5. 작업 히스토리 정리 (Clean History)
여러 작업 커밋을 의미있는 단위로 정리합니다.

**사용법:**
```bash
bash .claude/skills/git-workflow/scripts/clean-history.sh <commit-count>
```

**주의:**
- 아직 push하지 않은 커밋만 정리
- 자동으로 백업 생성
- Interactive rebase 사용

---

## 통합 워크플로우

### Agent에서 사용하는 전형적인 흐름

```bash
# 1. 작업 시작 - 브랜치 생성
bash .claude/skills/git-workflow/scripts/create-branch.sh feature "new-demo"

# 2. 작업 중 - 변경사항 확인
bash .claude/skills/git-workflow/scripts/analyze-changes.sh

# 3. 중간 저장 - 스마트 커밋
bash .claude/skills/git-workflow/scripts/smart-commit.sh

# 4. 중요 시점 - 체크포인트
bash .claude/skills/git-workflow/scripts/checkpoint.sh "frontend-complete"

# 5. 작업 완료 - 최종 커밋
bash .claude/skills/git-workflow/scripts/smart-commit.sh

# 6. 히스토리 정리 (선택)
bash .claude/skills/git-workflow/scripts/clean-history.sh 5
```

---

## 커밋 메시지 규칙

### Conventional Commits 형식
```
<type>: <description>

[optional body]
```

### 타입 자동 결정 로직

**파일 경로 기반:**
- `app/components/**` → `feat`
- `app/styles/**` → `style`
- `**/*.test.ts` → `test`
- `README.md`, `docs/**` → `docs`
- `.claude/**` → `chore`

**변경 내용 기반:**
- 새 파일 추가 → `feat`
- 버그 관련 키워드 → `fix`
- 포맷팅만 변경 → `style`
- 구조 변경 → `refactor`

**기본값:** `chore`

---

## 설정 옵션

### 환경 변수로 커스터마이징

```bash
# 커밋 메시지 언어
export GIT_COMMIT_LANG="ko"  # 한국어 메시지

# 브랜치 prefix
export GIT_BRANCH_PREFIX="work"  # work/feature-name

# 자동 push 활성화
export GIT_AUTO_PUSH="true"

# Verbose 모드
export GIT_WORKFLOW_VERBOSE="true"
```

---

## JSON 출력 형식

모든 스크립트는 JSON 출력을 지원해서 다른 도구와 통합 가능합니다.

**analyze-changes.sh:**
```json
{
  "hasChanges": true,
  "fileCount": 3,
  "changedFiles": ["..."],
  "suggestedType": "feat",
  "suggestedMessage": "feat: ..."
}
```

**smart-commit.sh:**
```json
{
  "success": true,
  "commitHash": "abc1234",
  "commitMessage": "feat: Add new feature",
  "filesChanged": 3
}
```

**create-branch.sh:**
```json
{
  "success": true,
  "branchName": "feature/new-feature-20260129-1430",
  "previousBranch": "main"
}
```

---

## 에러 처리

모든 스크립트는 에러 발생 시:
1. stderr로 에러 메시지 출력
2. Exit code 1 반환
3. JSON 출력에 `"error"` 필드 포함

**예시:**
```json
{
  "success": false,
  "error": "No changes to commit"
}
```

---

## 안전 장치

1. **Main 브랜치 보호**
   - main/master 브랜치에서 직접 커밋 방지
   - 경고 메시지 출력

2. **자동 백업**
   - 위험한 작업 전 자동 stash 생성
   - 체크포인트 태그 생성

3. **변경사항 확인**
   - 큰 변경사항은 사용자 확인 요청
   - 파일 50개 이상 변경 시 경고

4. **충돌 감지**
   - 커밋 전 충돌 확인
   - 충돌 발생 시 작업 중단

---

## 디버깅

```bash
# Verbose 모드 활성화
export GIT_WORKFLOW_VERBOSE="true"

# 드라이런 (실제 실행 안 함)
export GIT_WORKFLOW_DRY_RUN="true"

# 로그 확인
tail -f ~/.claude/logs/git-workflow.log
```

---

## 예시: Agent 통합

```markdown
# demo-generator Agent에서 사용

## 작업 시작
1. git-workflow skill 호출 → 브랜치 생성
2. 작업 진행...

## 작업 중간
3. 변경사항 분석
4. 의미있는 단위 완료 시 자동 커밋

## 작업 완료
5. 최종 변경사항 커밋
6. 브랜치 정리 여부 확인
```

이 스킬로 Git 작업이 완전히 자동화되고 추적 가능해집니다! 🚀
