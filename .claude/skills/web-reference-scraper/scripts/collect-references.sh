#!/bin/bash

# 웹 레퍼런스 수집 헬퍼 스크립트
# 사용법: bash collect-references.sh --query "portfolio minimalist" --count 5 --output references/my-project

set -e

# 기본 값
QUERY=""
COUNT=3
OUTPUT_DIR="references/$(date +%Y-%m-%d)"
SOURCES=("awwwards.com" "cssdesignawards.com" "siteinspire.com")

# 인자 파싱
while [[ $# -gt 0 ]]; do
  case $1 in
    --query)
      QUERY="$2"
      shift 2
      ;;
    --count)
      COUNT="$2"
      shift 2
      ;;
    --output)
      OUTPUT_DIR="$2"
      shift 2
      ;;
    *)
      echo "Unknown option: $1"
      echo "Usage: $0 --query <search query> [--count <number>] [--output <directory>]"
      exit 1
      ;;
  esac
done

# 필수 인자 확인
if [ -z "$QUERY" ]; then
  echo "Error: --query is required"
  echo "Usage: $0 --query <search query> [--count <number>] [--output <directory>]"
  exit 1
fi

# 출력 디렉토리 생성
FULL_OUTPUT_DIR=".claude/skills/web-reference-scraper/$OUTPUT_DIR"
mkdir -p "$FULL_OUTPUT_DIR"

echo "🔍 레퍼런스 검색 시작..."
echo "   검색어: $QUERY"
echo "   수집 개수: $COUNT"
echo "   저장 위치: $FULL_OUTPUT_DIR"
echo ""

# 검색 쿼리 생성
SEARCH_QUERIES=(
  "$QUERY website design awwwards"
  "$QUERY web design inspiration"
  "best $QUERY landing page 2024"
)

# 메타데이터 파일 생성 (jq 없이)
SOURCES_JSON="["
FIRST_SOURCE=true
for src in "${SOURCES[@]}"; do
  if [ "$FIRST_SOURCE" = true ]; then
    FIRST_SOURCE=false
  else
    SOURCES_JSON+=","
  fi
  SOURCES_JSON+="\"$src\""
done
SOURCES_JSON+="]"

cat > "$FULL_OUTPUT_DIR/metadata.json" << EOF
{
  "query": "$QUERY",
  "count": $COUNT,
  "collected_at": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
  "sources": $SOURCES_JSON,
  "references": []
}
EOF

# 검색 가이드 생성
cat > "$FULL_OUTPUT_DIR/search-guide.md" << EOF
# 레퍼런스 검색 가이드

## 검색 정보
- **검색어**: $QUERY
- **목표 개수**: $COUNT
- **수집일**: $(date +%Y-%m-%d)

## 추천 검색 쿼리

EOF

for query in "${SEARCH_QUERIES[@]}"; do
  echo "- \`$query\`" >> "$FULL_OUTPUT_DIR/search-guide.md"
done

cat >> "$FULL_OUTPUT_DIR/search-guide.md" << 'EOF'

## 추천 사이트

### 디자인 쇼케이스
1. **Awwwards** (https://www.awwwards.com/)
   - 수상작 중심, 최고 품질
   - 필터: SOTD, SOTM, SOTY

2. **CSS Design Awards** (https://www.cssdesignawards.com/)
   - CSS 중심 디자인
   - 카테고리별 검색 가능

3. **SiteInspire** (https://www.siteinspire.com/)
   - 카테고리별 큐레이션
   - 스타일, 유형, 주제별 필터

4. **Behance** (https://www.behance.net/)
   - 디자이너 포트폴리오
   - 프로세스와 설명 포함

5. **Dribbble** (https://dribbble.com/)
   - UI/UX 샷 중심
   - 트렌드 파악에 유용

### 특정 유형별

**포트폴리오:**
- https://www.awwwards.com/websites/portfolio/
- https://www.siteinspire.com/websites?categories=5

**랜딩 페이지:**
- https://www.lapa.ninja/
- https://landingfolio.com/

**SaaS:**
- https://saaslandingpage.com/
- https://saasframe.io/

**대시보드:**
- https://www.uplabs.com/search?q=dashboard
- https://dribbble.com/search/dashboard

## 수집 체크리스트

각 레퍼런스마다 다음을 기록하세요:

- [ ] URL
- [ ] 스크린샷 (가능하면)
- [ ] 색상 팔레트 (최소 5개)
- [ ] 타이포그래피 (헤딩, 본문)
- [ ] 레이아웃 구조
- [ ] 주요 컴포넌트 3개
- [ ] 애니메이션/인터랙션
- [ ] 특별한 디자인 요소

## 다음 단계

1. 위 사이트에서 레퍼런스 찾기
2. 각 레퍼런스를 `reference-N.md` 파일로 저장
3. 모든 수집 완료 후 `design-guide.md` 작성
EOF

# 레퍼런스 템플릿 생성
cat > "$FULL_OUTPUT_DIR/reference-template.md" << 'EOF'
# 레퍼런스 분석: [사이트명]

## 기본 정보
- **URL**: [URL]
- **유형**: [포트폴리오/랜딩페이지/대시보드/etc]
- **스타일**: [미니멀/모던/브루탈리스트/etc]
- **수집일**: [날짜]
- **출처**: [Awwwards/CSS Design Awards/etc]

## 디자인 분석

### 색상 팔레트
```css
--primary: #XXXXXX;
--secondary: #XXXXXX;
--accent: #XXXXXX;
--background: #XXXXXX;
--text: #XXXXXX;
--text-secondary: #XXXXXX;
```

### 타이포그래피
- **헤딩 폰트**: [폰트명, 예: Inter Bold]
- **헤딩 크기**: [예: 48px / 3rem]
- **본문 폰트**: [폰트명, 예: Inter Regular]
- **본문 크기**: [예: 16px / 1rem]
- **크기 스케일**: [예: 14px, 16px, 20px, 24px, 32px, 48px, 64px]
- **행간**: [예: 1.5 / 1.6]
- **자간**: [예: -0.02em]

### 레이아웃
- **구조**: [예: Hero Section + Features Grid + Testimonials + CTA]
- **그리드 시스템**: [예: 12-column grid, max-width 1440px]
- **간격 시스템**: [예: 8px base, scale: 8, 16, 24, 48, 96, 144]
- **최대 너비**: [예: 1440px]
- **컨테이너 패딩**: [예: Desktop 80px, Mobile 24px]
- **섹션 간격**: [예: 120px]

### 주요 컴포넌트

#### 1. [컴포넌트명, 예: Hero Section]
- **설명**: [어떤 역할을 하는지]
- **구조**: [HTML 구조 간단히]
- **스타일 특징**: [CSS 특징]
- **인터랙션**: [있다면]

#### 2. [컴포넌트명]
- **설명**:
- **구조**:
- **스타일 특징**:
- **인터랙션**:

#### 3. [컴포넌트명]
- **설명**:
- **구조**:
- **스타일 특징**:
- **인터랙션**:

### 애니메이션 & 인터랙션
- **페이지 로드**: [예: Fade in with stagger]
- **스크롤 효과**: [예: Parallax, Reveal on scroll]
- **호버 효과**: [예: Scale + Shadow on cards]
- **트랜지션**: [예: 300ms ease-in-out]
- **특별한 효과**: [예: Cursor follow effect]

### 반응형 디자인
- **브레이크포인트**: [예: 768px, 1024px, 1440px]
- **모바일 조정사항**: [레이아웃 변경사항]
- **터치 최적화**: [있다면]

### 특별한 디자인 요소
1. [독특한 점 1, 예: Diagonal section dividers]
2. [독특한 점 2, 예: Custom cursor with trail effect]
3. [독특한 점 3, 예: Gradient text headings]

## 기술 스택 (추정)
- **프레임워크**: [React/Vue/Next.js/etc 또는 Vanilla]
- **CSS**: [Tailwind/Styled-components/SCSS/etc]
- **애니메이션**: [GSAP/Framer Motion/CSS/etc]

## 적용 가능한 패턴

### 우리 프로젝트에 적용할 수 있는 것
1. [패턴 1]: [구체적인 적용 방법]
2. [패턴 2]: [구체적인 적용 방법]
3. [패턴 3]: [구체적인 적용 방법]

### 피해야 할 것
1. [이유와 함께]
2. [이유와 함께]

## 개선 아이디어

레퍼런스를 넘어설 수 있는 아이디어:
1. [아이디어 1]
2. [아이디어 2]
3. [아이디어 3]

## 스크린샷
[스크린샷이 있다면 여기에 경로 기록]

## 추가 노트
[기타 관찰사항이나 생각]
EOF

echo "✅ 검색 가이드 생성 완료!"
echo ""
echo "📁 생성된 파일:"
echo "   - $FULL_OUTPUT_DIR/search-guide.md (검색 가이드)"
echo "   - $FULL_OUTPUT_DIR/reference-template.md (레퍼런스 템플릿)"
echo "   - $FULL_OUTPUT_DIR/metadata.json (메타데이터)"
echo ""
echo "📝 다음 단계:"
echo "   1. search-guide.md의 추천 사이트에서 레퍼런스 찾기"
echo "   2. reference-template.md를 복사하여 reference-1.md, reference-2.md 등으로 작성"
echo "   3. 모든 레퍼런스 수집 후 design-guide.md 작성"
echo ""
echo "💡 팁: WebSearch와 WebFetch 도구를 활용하여 자동으로 정보 수집 가능"
