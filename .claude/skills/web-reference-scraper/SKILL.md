---
name: web-reference-scraper
description: 사용자 요청에 맞는 아름다운 웹사이트를 인터넷에서 검색하고, 디자인 레퍼런스를 수집 및 분석합니다. 웹앱 데모 생성 전 영감과 참고 자료가 필요할 때 사용합니다.
allowed-tools: WebSearch, WebFetch, Bash, Write, Read
disable-model-invocation: false
---

# 웹 레퍼런스 스크래퍼

사용자의 요청에 가장 잘 맞는 웹 디자인 레퍼런스를 찾아서 분석하고 저장하는 스킬입니다.

## 목적

실제 사람들이 만든 아름다운 웹사이트를 찾아서:
- 디자인 패턴 분석
- 색상 팔레트 추출
- 레이아웃 구조 파악
- 타이포그래피 선택 이해
- 인터랙션 패턴 학습

이를 통해 더 현실적이고 검증된 디자인을 생성합니다.

## 워크플로우

### 1단계: 요구사항 분석
사용자의 요청에서 핵심 키워드를 추출합니다:
- 웹앱 유형 (포트폴리오, 대시보드, 랜딩페이지 등)
- 디자인 스타일 (미니멀, 모던, 브루탈리스트 등)
- 주요 기능 (애니메이션, 다크모드 등)
- 산업 분야 (테크, 패션, 예술 등)

### 2단계: 레퍼런스 검색
다음 소스에서 레퍼런스를 검색합니다:

**디자인 쇼케이스 사이트:**
- Awwwards (awwwards.com)
- CSS Design Awards (cssdesignawards.com)
- Behance (behance.net)
- Dribbble (dribbble.com)
- SiteInspire (siteinspire.com)

**검색 쿼리 예시:**
```
"[유형] website design [스타일] awwwards"
"best [유형] landing page 2024"
"[스타일] [산업] web design inspiration"
```

### 3단계: 페이지 분석
선택한 레퍼런스 사이트를 분석합니다:

```bash
# WebFetch를 사용하여 페이지 내용 가져오기
# 다음 정보에 집중:
# - HTML 구조와 시맨틱 태그
# - CSS 클래스 네이밍 패턴
# - 색상 값 (hex, rgb)
# - 폰트 패밀리
# - 주요 레이아웃 패턴
```

### 4단계: 레퍼런스 저장
분석 결과를 구조화된 형식으로 저장합니다:

```markdown
# 레퍼런스 분석: [사이트명]

## 기본 정보
- URL: [URL]
- 유형: [유형]
- 스타일: [스타일]
- 수집일: [날짜]

## 디자인 분석

### 색상 팔레트
- Primary: #XXXXXX
- Secondary: #XXXXXX
- Accent: #XXXXXX
- Background: #XXXXXX
- Text: #XXXXXX

### 타이포그래피
- 헤딩 폰트: [폰트명] - [굵기]
- 본문 폰트: [폰트명] - [굵기]
- 크기 스케일: [예: 14px, 16px, 24px, 48px]

### 레이아웃
- 구조: [예: Hero + Features + CTA]
- 그리드: [예: 12-column grid]
- 간격: [예: 24px, 48px, 96px]
- 최대 너비: [예: 1440px]

### 주요 컴포넌트
1. [컴포넌트명]: [설명]
2. [컴포넌트명]: [설명]

### 애니메이션 & 인터랙션
- [효과 설명]

### 특별한 디자인 요소
- [독특한 점 1]
- [독특한 점 2]

## 적용 가능한 패턴
[이 레퍼런스에서 가져올 수 있는 구체적인 패턴들]

## 개선 아이디어
[레퍼런스를 넘어설 수 있는 아이디어들]
```

### 5단계: 다중 레퍼런스 종합
여러 레퍼런스를 종합하여 최종 디자인 가이드 생성:

```markdown
# 종합 디자인 가이드

## 추천 색상 팔레트
[여러 레퍼런스에서 가장 좋은 조합 선택]

## 추천 타이포그래피
[트렌드와 가독성을 고려한 선택]

## 추천 레이아웃 패턴
[가장 효과적인 구조]

## 차별화 전략
[레퍼런스들과 차별화할 독특한 요소]
```

## 사용 예시

### 예시 1: 포트폴리오 웹사이트
```
사용자 요청: "미니멀한 디자이너 포트폴리오 웹사이트"

1. 검색: "minimalist designer portfolio awwwards 2024"
2. 찾은 레퍼런스:
   - https://example-portfolio.com
   - https://another-designer.com
3. 분석 및 저장
4. 종합 가이드 생성
```

### 예시 2: SaaS 랜딩 페이지
```
사용자 요청: "모던한 SaaS 제품 랜딩페이지"

1. 검색: "modern saas landing page design 2024"
2. 찾은 레퍼런스:
   - Linear (linear.app)
   - Vercel (vercel.com)
3. 분석 및 저장
4. 종합 가이드 생성
```

## 저장 위치

레퍼런스 분석 결과는 다음 위치에 저장:
```
.claude/skills/web-reference-scraper/references/
  ├── [날짜]-[프로젝트명]/
  │   ├── reference-1.md
  │   ├── reference-2.md
  │   ├── reference-3.md
  │   └── design-guide.md
```

## 베스트 프랙티스

### ✅ DO
- 최소 3개 이상의 레퍼런스 수집
- 최신 디자인 트렌드 우선 (2023-2024)
- 실제 프로덕션 사이트 우선
- 수상작이나 주목받은 디자인 우선
- 색상 값을 정확히 기록
- 폰트 이름을 정확히 기록
- 모바일 반응형 고려사항 체크

### ❌ DON'T
- 오래된 디자인 참고 (2020년 이전)
- 단일 레퍼런스만 참고
- 저작권 있는 이미지 직접 사용
- 완전히 똑같이 복사
- 진부한 템플릿 사이트 참고

## 검색 전략

### 유형별 검색 키워드

**포트폴리오:**
```
"creative portfolio website awwwards"
"designer portfolio minimalist"
"developer portfolio interactive"
```

**랜딩 페이지:**
```
"product landing page design"
"saas landing page best"
"startup landing page modern"
```

**대시보드:**
```
"admin dashboard ui design"
"analytics dashboard modern"
"data visualization dashboard"
```

**이커머스:**
```
"ecommerce website design luxury"
"online store creative layout"
"product page design best"
```

### 스타일별 검색 키워드

**미니멀:**
```
"minimalist web design white space"
"clean simple website layout"
```

**브루탈리스트:**
```
"brutalist web design typography"
"raw minimalist website"
```

**다크 모드:**
```
"dark mode website design"
"black theme web interface"
```

**그라디언트:**
```
"gradient web design colorful"
"vibrant color website"
```

## 스크립트 활용

레퍼런스 수집을 자동화하는 헬퍼 스크립트 사용:

```bash
# 레퍼런스 검색 및 저장
bash .claude/skills/web-reference-scraper/scripts/collect-references.sh \
  --query "minimalist portfolio" \
  --count 5 \
  --output references/portfolio-2024
```

## 통합 워크플로우

이 스킬은 다른 스킬들과 함께 사용됩니다:

```
1. web-reference-scraper: 레퍼런스 수집 및 분석
   ↓
2. frontend-design: 레퍼런스 기반 독창적 디자인
   ↓
3. web-artifacts-builder: 실제 구현
   ↓
4. mobile-responsive-validator: 모바일 검증
```

## 주의사항

1. **저작권 존중**: 레퍼런스는 영감용이며, 직접 복사 금지
2. **신선함 유지**: 레퍼런스를 참고하되 독창성 유지
3. **컨텍스트 이해**: 왜 그 디자인이 효과적인지 이해
4. **선택적 적용**: 모든 요소를 가져오지 말고 필요한 것만

## 출력 예시

스킬 실행 후 다음과 같은 출력을 제공합니다:

```
✅ 레퍼런스 수집 완료

📊 수집된 레퍼런스: 5개
📁 저장 위치: .claude/skills/web-reference-scraper/references/2024-01-29-portfolio

🎨 주요 발견사항:
- 색상: 모노크롬 + 단일 액센트 컬러가 트렌드
- 타이포그래피: 큰 헤딩 (60px+) + 여백 활용
- 레이아웃: 비대칭 그리드가 주목받음
- 애니메이션: 스크롤 기반 페이드인 효과

💡 추천 디자인 방향:
1. 대담한 타이포그래피 중심 레이아웃
2. 모노크롬 + 네온 그린 액센트
3. 비대칭 그리드 + 대형 이미지
4. 부드러운 스크롤 애니메이션

📄 종합 가이드: references/2024-01-29-portfolio/design-guide.md
```

이 스킬을 통해 검증된 디자인 패턴을 기반으로 더욱 완성도 높은 웹앱을 생성할 수 있습니다.
