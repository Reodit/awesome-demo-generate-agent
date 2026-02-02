# awesome-demo-generate-agent

Claude Code를 활용한 웹 애플리케이션 데모 자동 생성 시스템

## 개요

React + TypeScript 기반의 독창적인 웹 데모를 자동으로 생성하는 도구입니다.
- 에이전트와 스킬 시스템으로 구성
- Git 자동화 및 모바일 반응형 검증 포함
- Vercel 즉시 배포 지원

## 프로젝트 구조

```
awesome-demo-generate-agent/
├── .claude/
│   ├── agents/
│   │   ├── demo-generator/              # 메인 데모 생성 에이전트
│   │   ├── git-manager/                 # Git 작업 자동화
│   │   └── mobile-responsive-validator/ # 모바일 반응형 검증
│   ├── skills/
│   │   ├── frontend-design/             # Anthropic 공식
│   │   ├── web-artifacts-builder/       # Anthropic 공식
│   │   ├── theme-factory/               # Anthropic 공식
│   │   ├── web-reference-scraper/       # 커스텀
│   │   ├── git-workflow/                # 커스텀
│   │   ├── claude-wrapper-guide/        # 커스텀
│   │   ├── react-best-practices/        # Vercel
│   │   ├── web-design-guidelines/       # Vercel
│   │   └── vercel-deploy/               # Vercel
│   ├── hooks/                           # 세션 훅
│   └── settings.json
├── .mcp.json.example                    # MCP 서버 설정 예시
├── .gitignore
├── LICENSE
├── NOTICE
└── README.md
```

## 설치

```bash
git clone https://github.com/Reodit/awesome-demo-generate-agent.git
cd awesome-demo-generate-agent
bash setup.sh
```

setup.sh가 자동으로:
- Node.js, pnpm 확인
- `.mcp.json` 설정 (경로 자동 입력)
- MCP 서버 패키지 사전 설치
- Playwright 브라우저 설치 (선택)

### 수동 설정

```bash
cp .mcp.json.example .mcp.json
# .mcp.json 파일을 열어 경로와 API 키 수정
```

### Claude Code 실행

```bash
claude .
```

## 사용 방법

### 기본 사용

Claude Code에서 요청:
```
포트폴리오 웹사이트를 만들어줘
```

### 에이전트 직접 호출

```
/demo-generator를 사용해서 대시보드를 만들어줘
```

## 주요 기능

### 에이전트 (3개)

**demo-generator**
- 독창적인 디자인 생성
- React 18 + TypeScript + Tailwind CSS
- 모바일 우선 개발
- Git 자동 추적

**git-manager**
- 스마트 커밋 (Conventional Commits)
- 브랜치 자동 생성
- 체크포인트 관리

**mobile-responsive-validator**
- 7가지 모바일 화면비 테스트
- 스크린샷 캡처 및 분석
- 자동 수정 제안

### 스킬 (9개)

**Anthropic 공식 (3개)**
- frontend-design: 독창적 프론트엔드 디자인
- web-artifacts-builder: React 프로젝트 생성
- theme-factory: 테마 시스템 (10개 프리셋)

**커스텀 (3개)**
- web-reference-scraper: 디자인 레퍼런스 수집
- git-workflow: Git 작업 자동화
- claude-wrapper-guide: HTTP API 래퍼 가이드

**Vercel (3개)**
- react-best-practices: React 성능 최적화
- web-design-guidelines: 웹 표준 검증
- vercel-deploy: 즉시 배포

## 워크플로우

```
1. Git 브랜치 생성 (자동)
2. 레퍼런스 수집 (선택)
3. 프로젝트 초기화
4. 개발 (독창적 디자인)
5. React 품질 검증
6. 번들링
7. 모바일 반응형 검증
8. 웹 표준 검증 (선택)
9. Vercel 배포 (선택)
10. Git 커밋 및 체크포인트
```

## 기술 스택

- React 18, TypeScript
- Vite, Parcel
- Tailwind CSS 3.4.1
- shadcn/ui (40+ 컴포넌트)
- Framer Motion

## Git 작업 자동화

```bash
# 브랜치 생성
bash .claude/skills/git-workflow/scripts/create-branch.sh feature "demo-name"

# 스마트 커밋
bash .claude/skills/git-workflow/scripts/smart-commit.sh

# 체크포인트 저장
bash .claude/skills/git-workflow/scripts/checkpoint.sh "checkpoint-name"
```

## 모바일 검증

```bash
# 전체 검증
bash .claude/agents/mobile-responsive-validator/scripts/validate.sh <project-path>

# 스크린샷 촬영
bash .claude/agents/mobile-responsive-validator/scripts/capture-screenshots.sh <url>
```

테스트 화면비:
- 375×667 (iPhone SE)
- 390×844 (iPhone 13)
- 393×852 (iPhone 14 Pro)
- 430×932 (iPhone 14 Pro Max)
- 360×740 (Android Small)
- 412×915 (Android Large)
- 768×1024 (iPad Portrait)

## 배포

```bash
bash .claude/skills/vercel-deploy/scripts/deploy.sh <project-path>
```

## 라이선스

MIT License

사용된 Anthropic 공식 스킬은 각각의 라이선스를 따릅니다.
