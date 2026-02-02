#!/bin/bash

# 정적 코드 분석으로 반응형 이슈 찾기
# 사용법: bash scan-responsive-issues.sh <project-path>

PROJECT_PATH="${1:-.}"

echo "==================================="
echo "모바일 반응형 정적 분석 리포트"
echo "==================================="
echo ""
echo "프로젝트: $PROJECT_PATH"
echo "분석 시간: $(date)"
echo ""

# 1. viewport 메타 태그 확인
echo "📱 1. Viewport 메타 태그 확인"
echo "-----------------------------------"
if grep -r "viewport" "$PROJECT_PATH" --include="*.html" --include="*.tsx" --include="*.jsx" | grep -q "width=device-width"; then
  echo "✅ viewport 메타 태그 발견"
else
  echo "❌ viewport 메타 태그 없음"
  echo "   권장: <meta name=\"viewport\" content=\"width=device-width, initial-scale=1.0\">"
fi
echo ""

# 2. vh 단위 사용 확인
echo "⚠️  2. vh 단위 사용 (모바일에서 문제 가능)"
echo "-----------------------------------"
VH_COUNT=$(grep -r "vh" "$PROJECT_PATH" --include="*.css" --include="*.scss" --include="*.tsx" --include="*.jsx" | wc -l | tr -d ' ')
if [ "$VH_COUNT" -gt 0 ]; then
  echo "발견: $VH_COUNT 곳"
  echo "파일 목록:"
  grep -rn "vh" "$PROJECT_PATH" --include="*.css" --include="*.scss" --include="*.tsx" --include="*.jsx" | head -n 10
  echo ""
  echo "권장: dvh 사용 또는 min-height로 변경"
else
  echo "✅ vh 사용 없음"
fi
echo ""

# 3. 고정 너비 확인
echo "⚠️  3. 고정 너비 사용 (반응형 문제 가능)"
echo "-----------------------------------"
FIXED_WIDTH=$(grep -rE "width:\s*[0-9]+px" "$PROJECT_PATH" --include="*.css" --include="*.scss" | wc -l | tr -d ' ')
if [ "$FIXED_WIDTH" -gt 0 ]; then
  echo "발견: $FIXED_WIDTH 곳"
  echo "샘플:"
  grep -rEn "width:\s*[0-9]+px" "$PROJECT_PATH" --include="*.css" --include="*.scss" | head -n 5
  echo ""
  echo "권장: max-width 또는 % 단위 사용"
else
  echo "✅ 고정 너비 사용 최소화됨"
fi
echo ""

# 4. overflow-x hidden 확인
echo "📏 4. 가로 스크롤 방지"
echo "-----------------------------------"
if grep -r "overflow-x.*hidden" "$PROJECT_PATH" --include="*.css" --include="*.scss" | grep -q "overflow-x"; then
  echo "✅ overflow-x: hidden 발견"
else
  echo "⚠️  overflow-x: hidden 설정 없음"
  echo "   권장: html, body에 overflow-x: hidden 추가"
fi
echo ""

# 5. 미디어 쿼리 확인
echo "📐 5. 미디어 쿼리 (반응형 브레이크포인트)"
echo "-----------------------------------"
MEDIA_QUERY_COUNT=$(grep -r "@media" "$PROJECT_PATH" --include="*.css" --include="*.scss" --include="*.tsx" --include="*.jsx" | wc -l | tr -d ' ')
if [ "$MEDIA_QUERY_COUNT" -gt 0 ]; then
  echo "✅ 미디어 쿼리 발견: $MEDIA_QUERY_COUNT 곳"
  echo ""
  echo "사용된 브레이크포인트:"
  grep -roh "@media.*max-width:\s*[0-9]*px" "$PROJECT_PATH" --include="*.css" --include="*.scss" | sort -u | head -n 10
else
  echo "❌ 미디어 쿼리 없음 - 반응형 디자인 미적용"
fi
echo ""

# 6. 터치 타겟 크기 (버튼, 링크)
echo "👆 6. 터치 타겟 크기"
echo "-----------------------------------"
if grep -rE "min-(width|height):\s*44px" "$PROJECT_PATH" --include="*.css" --include="*.scss" | grep -q "min-"; then
  echo "✅ 최소 터치 타겟 크기 설정 발견"
else
  echo "⚠️  최소 터치 타겟 크기 미설정"
  echo "   권장: 버튼/링크 최소 44×44px"
fi
echo ""

# 7. Fixed position 요소
echo "📌 7. Fixed/Absolute Position 요소"
echo "-----------------------------------"
FIXED_COUNT=$(grep -rE "position:\s*(fixed|absolute)" "$PROJECT_PATH" --include="*.css" --include="*.scss" | wc -l | tr -d ' ')
if [ "$FIXED_COUNT" -gt 0 ]; then
  echo "발견: $FIXED_COUNT 곳"
  echo "위치:"
  grep -rnE "position:\s*(fixed|absolute)" "$PROJECT_PATH" --include="*.css" --include="*.scss" | head -n 5
  echo ""
  echo "주의: 모바일에서 컨텐츠를 가릴 수 있음"
else
  echo "✅ Fixed/Absolute position 최소화됨"
fi
echo ""

# 8. 이미지 반응형
echo "🖼️  8. 이미지 반응형 설정"
echo "-----------------------------------"
if grep -rE "img.*max-width:\s*100%" "$PROJECT_PATH" --include="*.css" --include="*.scss" | grep -q "max-width"; then
  echo "✅ 이미지 반응형 설정 발견"
else
  echo "⚠️  이미지 반응형 설정 확인 필요"
  echo "   권장: img { max-width: 100%; height: auto; }"
fi
echo ""

# 9. 폰트 크기
echo "📝 9. 최소 폰트 크기"
echo "-----------------------------------"
SMALL_FONTS=$(grep -rE "font-size:\s*(1[0-4]|[0-9])px" "$PROJECT_PATH" --include="*.css" --include="*.scss" | wc -l | tr -d ' ')
if [ "$SMALL_FONTS" -gt 0 ]; then
  echo "⚠️  작은 폰트 발견: $SMALL_FONTS 곳 (< 15px)"
  echo "샘플:"
  grep -rnE "font-size:\s*(1[0-4]|[0-9])px" "$PROJECT_PATH" --include="*.css" --include="*.scss" | head -n 3
  echo ""
  echo "권장: 본문 최소 16px"
else
  echo "✅ 폰트 크기 적절"
fi
echo ""

# 10. Tailwind 모바일 우선 확인
echo "🎨 10. Tailwind CSS 모바일 우선"
echo "-----------------------------------"
if [ -f "$PROJECT_PATH/tailwind.config.js" ] || [ -f "$PROJECT_PATH/tailwind.config.ts" ]; then
  echo "✅ Tailwind CSS 프로젝트"

  # sm: 접두사 사용 확인
  SM_USAGE=$(grep -r "className.*sm:" "$PROJECT_PATH" --include="*.tsx" --include="*.jsx" | wc -l | tr -d ' ')
  echo "   sm: 사용: $SM_USAGE 곳"

  # 모바일 우선 패턴 확인
  if grep -r "className.*\(grid-cols-1\|flex-col\)" "$PROJECT_PATH" --include="*.tsx" --include="*.jsx" | grep -q "grid-cols-1"; then
    echo "   ✅ 모바일 우선 패턴 발견"
  else
    echo "   ⚠️  모바일 우선 패턴 확인 필요"
  fi
else
  echo "ℹ️  Tailwind CSS 미사용"
fi
echo ""

# 요약
echo "==================================="
echo "검사 완료"
echo "==================================="
echo ""
echo "다음 단계:"
echo "1. 발견된 이슈 검토"
echo "2. 로컬 서버 시작"
echo "3. 스크린샷 테스트 실행"
echo "4. 필요한 수정 적용"
