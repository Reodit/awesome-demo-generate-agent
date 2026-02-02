#!/bin/bash

# 종합 검증 리포트 생성
# 사용법: bash generate-report.sh <project-path> <output-dir>

PROJECT_PATH="${1:-.}"
OUTPUT_DIR="${2:-./mobile-validation-report}"

REPORT_FILE="$OUTPUT_DIR/report.md"

echo "📊 검증 리포트 생성 중..."

# 출력 디렉토리 생성
mkdir -p "$OUTPUT_DIR"

# 리포트 작성
cat > "$REPORT_FILE" << EOF
# 모바일 반응형 검증 리포트

## 프로젝트 정보
- **경로**: \`$PROJECT_PATH\`
- **검증 시간**: $(date '+%Y-%m-%d %H:%M:%S')
- **검증자**: Mobile Responsive Validator Agent

---

## 📋 검증 요약

EOF

# 정적 분석 결과 포함
if [ -f "$OUTPUT_DIR/static-analysis.txt" ]; then
  echo "### 정적 분석 결과" >> "$REPORT_FILE"
  echo '```' >> "$REPORT_FILE"
  cat "$OUTPUT_DIR/static-analysis.txt" >> "$REPORT_FILE"
  echo '```' >> "$REPORT_FILE"
  echo "" >> "$REPORT_FILE"
fi

# 스크린샷 결과 포함
if [ -f "$OUTPUT_DIR/screenshots/results.json" ]; then
  echo "### 화면비별 테스트 결과" >> "$REPORT_FILE"
  echo "" >> "$REPORT_FILE"

  # JSON 파일 파싱 (jq 사용 가능하면)
  if command -v jq &> /dev/null; then
    jq -r '.[] | "#### \(.device) (\(.viewport))\n- **비율**: \(.aspectRatio):1\n- **페이지 크기**: \(.pageWidth)×\(.pageHeight)px\n- **가로 스크롤**: \(if .hasHorizontalScroll then "⚠️  있음" else "✅ 없음" end)\n- **스크린샷**: `\(.screenshot)`\n"' "$OUTPUT_DIR/screenshots/results.json" >> "$REPORT_FILE"
  else
    echo "스크린샷 결과는 \`screenshots/results.json\` 파일을 확인하세요." >> "$REPORT_FILE"
    echo "" >> "$REPORT_FILE"
  fi
fi

# 발견된 문제 섹션
cat >> "$REPORT_FILE" << 'EOF'

---

## ⚠️  발견된 주요 문제

### 우선순위 1 (치명적)
- [ ] 가로 스크롤 발생
- [ ] 세로 모드에서 컨텐츠 접근 불가
- [ ] Viewport 메타 태그 없음

### 우선순위 2 (중요)
- [ ] vh 단위 오용
- [ ] 고정 너비로 인한 레이아웃 깨짐
- [ ] 터치 타겟 크기 부족 (< 44px)

### 우선순위 3 (개선)
- [ ] 미디어 쿼리 부족
- [ ] 작은 폰트 크기
- [ ] 이미지 반응형 미설정

---

## 🔧 권장 수정사항

### 1. Viewport 메타 태그 추가/수정
```html
<meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=5.0">
```

### 2. 기본 반응형 CSS 추가
```css
/* 가로 스크롤 방지 */
html, body {
  width: 100%;
  overflow-x: hidden;
}

/* 박스 사이징 */
* {
  box-sizing: border-box;
}

/* 이미지 반응형 */
img {
  max-width: 100%;
  height: auto;
}

/* 터치 타겟 크기 */
button, a {
  min-height: 44px;
  min-width: 44px;
}
```

### 3. vh 단위 수정
```css
/* ❌ 문제 */
.hero {
  height: 100vh;
}

/* ✅ 해결 1: dvh 사용 */
.hero {
  height: 100dvh;
}

/* ✅ 해결 2: min-height 사용 */
.hero {
  min-height: 100vh;
}
```

### 4. 모바일 브레이크포인트 추가
```css
/* 모바일 세로 (대부분) */
@media (max-width: 430px) {
  .container {
    padding: 1rem;
  }

  h1 {
    font-size: 2rem;
  }

  .grid {
    grid-template-columns: 1fr;
  }
}

/* 작은 모바일 */
@media (max-width: 375px) {
  .container {
    padding: 0.75rem;
  }
}

/* 세로 모드 특화 */
@media (max-width: 768px) and (orientation: portrait) {
  /* 세로 모드 최적화 */
}
```

### 5. Tailwind CSS 모바일 우선
```jsx
{/* ❌ 데스크톱 우선 */}
<div className="grid grid-cols-3 sm:grid-cols-1">

{/* ✅ 모바일 우선 */}
<div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3">

{/* ✅ 반응형 간격 */}
<div className="p-4 sm:p-6 md:p-8 lg:p-12">

{/* ✅ 반응형 텍스트 */}
<h1 className="text-3xl sm:text-4xl md:text-5xl lg:text-6xl">
```

---

## 📱 테스트된 화면비

| 기기 | 해상도 | 비율 | 상태 |
|------|--------|------|------|
| iPhone SE | 375×667 | 9:16 | - |
| iPhone 13 | 390×844 | 9:19.4 | - |
| iPhone 14 Pro | 393×852 | 9:19.5 | - |
| iPhone 14 Pro Max | 430×932 | 9:19.5 | - |
| Android Small | 360×740 | 9:18.5 | - |
| Android Large | 412×915 | 9:20 | - |
| iPad Portrait | 768×1024 | 3:4 | - |

> 상태는 스크린샷을 확인한 후 수동으로 업데이트하세요.
> ✅ 정상 | ⚠️  경고 | ❌ 실패

---

## 📸 스크린샷

스크린샷은 다음 위치에 저장되어 있습니다:

EOF

# 스크린샷 목록 추가
if [ -d "$OUTPUT_DIR/screenshots" ]; then
  for screenshot in "$OUTPUT_DIR/screenshots"/*.png; do
    if [ -f "$screenshot" ]; then
      filename=$(basename "$screenshot")
      echo "- \`screenshots/$filename\`" >> "$REPORT_FILE"
    fi
  done
fi

cat >> "$REPORT_FILE" << 'EOF'

---

## ✅ 체크리스트

다음 항목을 모두 통과해야 합니다:

### 필수 항목
- [ ] Viewport 메타 태그 설정
- [ ] 모든 화면비에서 가로 스크롤 없음
- [ ] 세로 모드에서 모든 컨텐츠 접근 가능
- [ ] 터치 타겟 최소 44×44px
- [ ] 본문 폰트 최소 16px
- [ ] 이미지 반응형 (max-width: 100%)
- [ ] Fixed 요소가 컨텐츠 가리지 않음

### 세로 화면 특화 (9:16, 9:20)
- [ ] 레이아웃 정상
- [ ] vh 단위 올바르게 사용
- [ ] 세로 스크롤 원활
- [ ] 컨텐츠 잘림 없음

### 최적화
- [ ] 모바일 우선 CSS
- [ ] 적절한 브레이크포인트
- [ ] 터치 제스처 지원
- [ ] Safe area 고려 (iPhone 노치)

---

## 📝 다음 단계

1. 이 리포트의 "발견된 주요 문제" 섹션 검토
2. "권장 수정사항" 적용
3. 수정 후 재검증:
   ```bash
   bash .claude/agents/mobile-responsive-validator/scripts/validate.sh
   ```
4. 모든 체크리스트 항목 통과 확인

---

## 🔗 참고 자료

- [Responsive Web Design - MDN](https://developer.mozilla.org/en-US/docs/Learn/CSS/CSS_layout/Responsive_Design)
- [Mobile Web Best Practices](https://www.w3.org/TR/mobile-bp/)
- [Touch Target Sizes](https://web.dev/accessible-tap-targets/)
- [The new CSS unit dvh](https://css-tricks.com/the-large-small-and-dynamic-viewports/)

---

**생성 시간**: $(date '+%Y-%m-%d %H:%M:%S')
**도구**: Mobile Responsive Validator Agent
EOF

echo "✅ 리포트 생성 완료: $REPORT_FILE"
echo ""
echo "📄 리포트 보기:"
echo "   cat $REPORT_FILE"
echo "   # 또는"
echo "   open $REPORT_FILE  # macOS"
