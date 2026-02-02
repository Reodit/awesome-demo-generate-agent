#!/bin/bash

# Playwright를 사용한 모바일 화면비 스크린샷 촬영
# 사용법: bash capture-screenshots.sh <url> [output-dir]

URL="${1:-http://localhost:3000}"
OUTPUT_DIR="${2:-./screenshots}"

# 절대 경로로 변환
OUTPUT_DIR=$(cd "$(dirname "$OUTPUT_DIR")" 2>/dev/null && pwd)/$(basename "$OUTPUT_DIR") || OUTPUT_DIR="$(pwd)/$OUTPUT_DIR"
mkdir -p "$OUTPUT_DIR"

echo "📸 모바일 화면비 스크린샷 촬영"
echo "   URL: $URL"
echo "   출력: $OUTPUT_DIR"
echo ""

# Node.js 설치 확인
if ! command -v node &> /dev/null; then
  echo "❌ Node.js가 설치되지 않았습니다"
  exit 1
fi

# 임시 작업 디렉토리 생성
WORK_DIR=$(mktemp -d)
trap "rm -rf $WORK_DIR" EXIT

echo "ℹ️  Playwright 환경 준비 중..."

# package.json 생성
cat > "$WORK_DIR/package.json" << 'EOF'
{
  "name": "screenshot-capture",
  "type": "module",
  "dependencies": {
    "playwright": "^1.40.0"
  }
}
EOF

# Playwright 스크립트 생성
cat > "$WORK_DIR/capture.mjs" << 'EOF'
import { chromium } from 'playwright';

const url = process.argv[2] || 'http://localhost:3000';
const outputDir = process.argv[3] || './screenshots';

// 테스트할 모바일 화면비
const viewports = [
  { width: 375, height: 667, name: 'iphone-se', device: 'iPhone SE' },
  { width: 390, height: 844, name: 'iphone-13', device: 'iPhone 13' },
  { width: 393, height: 852, name: 'iphone-14-pro', device: 'iPhone 14 Pro' },
  { width: 430, height: 932, name: 'iphone-14-pro-max', device: 'iPhone 14 Pro Max' },
  { width: 360, height: 740, name: 'android-small', device: 'Android Small' },
  { width: 412, height: 915, name: 'android-large', device: 'Pixel 5' },
  { width: 768, height: 1024, name: 'ipad-portrait', device: 'iPad Portrait' },
];

(async () => {
  console.log('🚀 Playwright 시작...\n');

  const browser = await chromium.launch();
  const results = [];

  for (const viewport of viewports) {
    try {
      console.log(`📱 ${viewport.device} (${viewport.width}×${viewport.height}) 촬영 중...`);

      const context = await browser.newContext({
        viewport: { width: viewport.width, height: viewport.height },
        deviceScaleFactor: 2,
        hasTouch: true,
        isMobile: true,
      });

      const page = await context.newPage();

      // 페이지 로드
      await page.goto(url, { waitUntil: 'networkidle', timeout: 30000 });

      // 전체 페이지 스크린샷
      const screenshotPath = `${outputDir}/${viewport.name}.png`;
      await page.screenshot({
        path: screenshotPath,
        fullPage: true,
      });

      // 페이지 높이 확인
      const dimensions = await page.evaluate(() => ({
        width: document.documentElement.scrollWidth,
        height: document.documentElement.scrollHeight,
        viewportHeight: window.innerHeight,
      }));

      // 가로 스크롤 확인
      const hasHorizontalScroll = dimensions.width > viewport.width;

      results.push({
        device: viewport.device,
        viewport: `${viewport.width}×${viewport.height}`,
        screenshot: screenshotPath,
        pageWidth: dimensions.width,
        pageHeight: dimensions.height,
        hasHorizontalScroll,
        aspectRatio: (viewport.height / viewport.width).toFixed(2),
      });

      console.log(`   ✅ 저장: ${screenshotPath}`);
      if (hasHorizontalScroll) {
        console.log(`   ⚠️  가로 스크롤 감지! (페이지 너비: ${dimensions.width}px)`);
      }

      await context.close();
    } catch (error) {
      console.error(`   ❌ 오류: ${error.message}`);
      results.push({
        device: viewport.device,
        viewport: `${viewport.width}×${viewport.height}`,
        error: error.message,
      });
    }

    console.log('');
  }

  await browser.close();

  // 결과 요약
  console.log('='.repeat(50));
  console.log('📊 촬영 완료 요약\n');

  for (const result of results) {
    if (result.error) {
      console.log(`❌ ${result.device} (${result.viewport}): ${result.error}`);
    } else {
      const status = result.hasHorizontalScroll ? '⚠️ ' : '✅';
      console.log(`${status} ${result.device} (${result.viewport})`);
      console.log(`   비율: ${result.aspectRatio}:1`);
      console.log(`   페이지 크기: ${result.pageWidth}×${result.pageHeight}px`);
      if (result.hasHorizontalScroll) {
        console.log(`   ⚠️  가로 스크롤 존재`);
      }
      console.log('');
    }
  }

  // JSON 결과 저장
  const fs = await import('fs');
  fs.writeFileSync(
    `${outputDir}/results.json`,
    JSON.stringify(results, null, 2)
  );

  console.log(`\n💾 결과 저장: ${outputDir}/results.json`);
  console.log('\n다음 단계: 스크린샷을 확인하고 문제가 있는 화면비를 찾아 수정하세요.');
})();
EOF

# 작업 디렉토리로 이동하여 의존성 설치 및 실행
cd "$WORK_DIR"

echo "📦 Playwright 설치 중..."
npm install --silent 2>/dev/null

echo "🎭 Chromium 브라우저 설치 중..."
npx playwright install chromium --quiet 2>/dev/null || npx playwright install chromium

echo ""
echo "🎬 스크린샷 촬영 시작..."
echo ""

node capture.mjs "$URL" "$OUTPUT_DIR"

echo ""
echo "✅ 모든 스크린샷 촬영 완료!"
echo ""
echo "📁 결과 확인:"
echo "   ls -lh $OUTPUT_DIR/"
