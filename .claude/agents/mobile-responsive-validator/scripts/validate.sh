#!/bin/bash

# 모바일 반응형 전체 검증 스크립트
# 사용법: bash validate.sh <project-path> [port]

set -e

PROJECT_PATH="${1:-.}"
PORT="${2:-3000}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
OUTPUT_DIR="$PROJECT_PATH/mobile-validation-report"

echo "📱 모바일 반응형 검증 시작..."
echo "   프로젝트: $PROJECT_PATH"
echo "   포트: $PORT"
echo ""

# 출력 디렉토리 생성
mkdir -p "$OUTPUT_DIR/screenshots"

# 1단계: 정적 분석
echo "🔍 1/4 정적 코드 분석 중..."
bash "$SCRIPT_DIR/scan-responsive-issues.sh" "$PROJECT_PATH" > "$OUTPUT_DIR/static-analysis.txt"
echo "✅ 정적 분석 완료"
echo ""

# 2단계: 서버 확인
echo "🌐 2/4 개발 서버 확인 중..."
if curl -s "http://localhost:$PORT" > /dev/null; then
  echo "✅ 서버가 이미 실행 중입니다 (포트 $PORT)"
  SERVER_STARTED=false
else
  echo "⚠️  서버가 실행되지 않음. 수동으로 서버를 시작해주세요."
  echo "   예: npm run dev 또는 npm start"
  echo ""
  read -p "서버를 시작한 후 Enter를 눌러주세요..."
  SERVER_STARTED=false
fi
echo ""

# 3단계: 스크린샷 촬영
echo "📸 3/4 다양한 화면비에서 스크린샷 촬영 중..."
bash "$SCRIPT_DIR/capture-screenshots.sh" "http://localhost:$PORT" "$OUTPUT_DIR/screenshots"
echo "✅ 스크린샷 촬영 완료"
echo ""

# 4단계: 리포트 생성
echo "📊 4/4 검증 리포트 생성 중..."
bash "$SCRIPT_DIR/generate-report.sh" "$PROJECT_PATH" "$OUTPUT_DIR"
echo "✅ 리포트 생성 완료"
echo ""

echo "🎉 모바일 반응형 검증 완료!"
echo ""
echo "📁 결과 위치: $OUTPUT_DIR/"
echo "   - static-analysis.txt (정적 분석)"
echo "   - screenshots/ (화면비별 스크린샷)"
echo "   - report.md (종합 리포트)"
echo ""
echo "📄 리포트 보기:"
echo "   cat $OUTPUT_DIR/report.md"
