---
name: claude-wrapper-guide
description: Claude Code CLI를 HTTP API로 래핑하여 웹 애플리케이션에서 사용하는 방법을 안내합니다. "claude wrapper 사용법", "HTTP API로 Claude 사용", "웹에서 Claude 호출" 등의 요청 시 사용됩니다.
allowed-tools: Read, Bash, WebFetch
disable-model-invocation: false
---

# Claude Wrapper 사용 가이드

Claude Code CLI를 HTTP API로 래핑하여 **어떤 언어나 프레임워크에서든** Claude를 사용할 수 있게 해주는 도구입니다.

## 핵심 개념

### 왜 Claude Wrapper를 사용하나?

1. **비용 절감** 💰
   - Anthropic API 직접 호출 대신 Claude Code 구독으로 무제한 사용
   - API 키 불필요 (Claude Code 인증만 필요)

2. **도구 활용** 🔧
   - WebSearch, WebFetch 등 내장 도구 사용 가능
   - 파일 읽기/쓰기, Bash 명령어 실행

3. **에이전트 시스템** 🤖
   - 서브에이전트로 전문화된 분석
   - 커스텀 에이전트 추가 가능

## 설치 및 설정

### 1단계: Claude Code CLI 설치

```bash
# 글로벌 설치
npm install -g @anthropic-ai/claude-code

# 설치 확인
claude --version
```

### 2단계: 최초 인증

```bash
# 터미널에서 실행
claude

# 브라우저가 열리면:
# 1. Anthropic 계정으로 로그인
# 2. "Authorize" 버튼 클릭
# 3. 터미널로 돌아가면 인증 완료
```

**인증 확인:**
```bash
claude --print "hello"
# 출력: Hello! How can I help you today?
```

### 3단계: Claude Wrapper 프로젝트 설정

claude-wrapper 디렉토리에서:

```bash
# 의존성 설치
npm install

# 개발 서버 실행
npm run dev

# 브라우저에서 http://localhost:3000 접속
```

## 사용 방법

### 웹 UI로 테스트

브라우저에서 `http://localhost:3000`을 열면:
- 바로 사용할 수 있는 테스트 인터페이스 제공
- 실시간 스트리밍 응답 확인
- 다양한 프롬프트 테스트 가능

### HTTP API 사용

서버가 실행되면 **어떤 언어에서든** HTTP API로 사용 가능합니다.

#### API 엔드포인트

**1. POST /api/claude/stream (스트리밍)**
- 실시간 스트리밍 응답
- 긴 응답에 적합
- 사용자 경험 향상

**2. POST /api/claude (동기)**
- 전체 응답 대기 후 반환
- 간단한 쿼리에 적합

**3. GET /api/claude**
- API 문서 반환

## 다양한 언어에서 사용하기

### cURL

```bash
# 스트리밍 API
curl -X POST http://localhost:3000/api/claude/stream \
  -H "Content-Type: application/json" \
  -d '{"prompt": "React 컴포넌트 예제 보여줘"}' \
  --no-buffer

# 동기 API
curl -X POST http://localhost:3000/api/claude \
  -H "Content-Type: application/json" \
  -d '{"prompt": "TypeScript 타입 설명해줘"}'
```

### Python

```python
import requests
import json

# 스트리밍 응답
response = requests.post(
    "http://localhost:3000/api/claude/stream",
    json={"prompt": "Python 데코레이터 설명해줘"},
    stream=True
)

for line in response.iter_lines():
    if line:
        data = json.loads(line.decode('utf-8'))
        if data['type'] == 'assistant':
            print(data['message']['content'][0].get('text', ''), end='')
        elif data['type'] == 'result':
            print(f"\n\n비용: ${data['total_cost_usd']:.4f}")

# 동기 응답
response = requests.post(
    "http://localhost:3000/api/claude",
    json={"prompt": "FastAPI 예제 보여줘"}
)
result = response.json()
print(result['result'])
```

### JavaScript/TypeScript

```javascript
// 스트리밍
const response = await fetch('http://localhost:3000/api/claude/stream', {
  method: 'POST',
  headers: { 'Content-Type': 'application/json' },
  body: JSON.stringify({ prompt: 'Next.js App Router 설명해줘' })
});

const reader = response.body.getReader();
const decoder = new TextDecoder();

while (true) {
  const { done, value } = await reader.read();
  if (done) break;

  const text = decoder.decode(value);
  const lines = text.split('\n').filter(line => line.trim());

  for (const line of lines) {
    const msg = JSON.parse(line);
    if (msg.type === 'assistant') {
      console.log(msg.message.content[0]?.text);
    }
  }
}

// 동기
const syncResponse = await fetch('http://localhost:3000/api/claude', {
  method: 'POST',
  headers: { 'Content-Type': 'application/json' },
  body: JSON.stringify({ prompt: 'React Hooks 설명해줘' })
});

const data = await syncResponse.json();
console.log(data.result);
```

### Go

```go
package main

import (
    "bufio"
    "bytes"
    "encoding/json"
    "fmt"
    "net/http"
)

func main() {
    body := map[string]string{"prompt": "Go 컨텍스트 설명해줘"}
    jsonData, _ := json.Marshal(body)

    resp, _ := http.Post(
        "http://localhost:3000/api/claude/stream",
        "application/json",
        bytes.NewBuffer(jsonData),
    )
    defer resp.Body.Close()

    scanner := bufio.NewScanner(resp.Body)
    for scanner.Scan() {
        var msg map[string]interface{}
        json.Unmarshal(scanner.Bytes(), &msg)

        if msg["type"] == "assistant" {
            content := msg["message"].(map[string]interface{})["content"]
            fmt.Println(content)
        }
    }
}
```

### Ruby

```ruby
require 'net/http'
require 'json'
require 'uri'

# 동기 요청
uri = URI('http://localhost:3000/api/claude')
req = Net::HTTP::Post.new(uri, 'Content-Type' => 'application/json')
req.body = { prompt: 'Ruby 메타프로그래밍 설명해줘' }.to_json

res = Net::HTTP.start(uri.hostname, uri.port) { |http| http.request(req) }
result = JSON.parse(res.body)
puts result['result']
```

## 고급 기능

### 요청 옵션

```javascript
{
  "prompt": "코드 리뷰해줘",           // 필수: 요청 내용
  "agents": {                         // 선택: 커스텀 에이전트
    "code-reviewer": {
      "description": "코드 리뷰 전문가",
      "prompt": "코드 품질, 성능, 보안을 검토하세요",
      "tools": ["Read", "Grep"],
      "model": "sonnet"               // sonnet | opus | haiku
    }
  },
  "useDefaultAgents": true,           // 기본 에이전트 사용 여부
  "allowedTools": ["WebSearch"],      // 허용 도구 목록
  "disallowedTools": ["Bash"]         // 차단 도구 목록
}
```

### 커스텀 서브에이전트

```javascript
fetch('/api/claude/stream', {
  method: 'POST',
  body: JSON.stringify({
    prompt: '최신 React 뉴스 요약해줘',
    agents: {
      'news-researcher': {
        description: '기술 뉴스 리서치 전문가',
        prompt: 'WebSearch로 최신 뉴스를 검색하고 핵심만 요약하세요.',
        tools: ['WebSearch', 'WebFetch'],
        model: 'sonnet'
      }
    }
  })
});
```

### 사용 가능한 도구

| 카테고리 | 도구 | 설명 |
|----------|------|------|
| 파일 | `Read`, `Edit`, `Write` | 파일 읽기/수정/생성 |
| 검색 | `Glob`, `Grep` | 패턴 매칭, 내용 검색 |
| 실행 | `Bash` | 셸 명령어 실행 |
| 웹 | `WebSearch`, `WebFetch` | 웹 검색, 페이지 가져오기 |
| 작업 | `TodoRead`, `TodoWrite` | 작업 관리 |

## Claude Code 설정

### 권한 설정 (Permissions)

`.claude/settings.json`에서 도구 사용 권한 제어:

```json
{
  "permissions": {
    "allow": [
      "WebFetch(domain:github.com)",    // 특정 도메인만 허용
      "Bash(npm:*)",                     // npm 명령어 허용
      "Read",                            // 파일 읽기 전체 허용
      "WebSearch"                        // 웹 검색 허용
    ],
    "deny": [
      "Bash(rm -rf:*)",                  // 위험한 명령어 차단
      "Write(*.env)"                     // .env 파일 수정 차단
    ]
  }
}
```

### 훅 설정 (Hooks)

도구 실행 전/후에 자동으로 명령어 실행:

```json
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "WebSearch",
        "hooks": [
          {
            "type": "command",
            "command": "echo '검색 시작' >> /tmp/log.txt"
          }
        ]
      }
    ],
    "PostToolUse": [
      {
        "matcher": "Edit",
        "hooks": [
          {
            "type": "command",
            "command": "echo '파일 수정됨' >> /tmp/log.txt"
          }
        ]
      }
    ]
  }
}
```

**환경 변수:**
- `$CLAUDE_TOOL_INPUT` - 도구 입력값
- `$CLAUDE_TOOL_NAME` - 도구 이름
- `$CLAUDE_SESSION_ID` - 세션 ID

### 스킬 생성

`.claude/skills/<skill-name>/SKILL.md` 파일 생성:

```markdown
# 코드 리뷰 스킬

## 트리거
- "코드 리뷰", "코드 검토", "리뷰해줘" 키워드

## 검토 항목
1. **품질**: 가독성, 유지보수성
2. **성능**: 불필요한 재렌더링, 메모리 누수
3. **보안**: SQL 인젝션, XSS 취약점
4. **베스트 프랙티스**: 네이밍, 구조

## 출력 형식
- 🟢 좋은 점
- 🟡 개선 필요
- 🔴 치명적 문제
```

## 스트리밍 메시지 타입

```typescript
interface StreamMessage {
  type: 'system' | 'assistant' | 'user' | 'result' | 'stream_event';
  subtype?: string;
  message?: {
    content: Array<{ type: string; text?: string }>
  };
  event?: {
    type: string;
    delta?: { text: string }
  };
  result?: string;
  duration_ms?: number;
  total_cost_usd?: number;
}
```

## 프로젝트 구조

```
claude-wrapper/
├── .claude/                        # Claude Code 설정
│   ├── settings.json               # 팀 공유 설정
│   ├── settings.local.json         # 개인 설정 (git 무시)
│   └── skills/
│       └── macro-analysis/         # 커스텀 스킬
│           └── SKILL.md
├── app/                            # Next.js App Router
│   ├── api/
│   │   └── claude/
│   │       ├── route.ts            # 동기 API
│   │       └── stream/
│   │           └── route.ts        # 스트리밍 API
│   ├── layout.tsx
│   ├── page.tsx                    # 웹 UI
│   └── globals.css
├── next.config.ts
├── package.json
├── tailwind.config.ts
└── README.md
```

## 사용 예시

### 웹앱 개발 도우미

```javascript
// React 컴포넌트 생성 요청
fetch('/api/claude', {
  method: 'POST',
  body: JSON.stringify({
    prompt: '사용자 프로필 카드 컴포넌트를 React + TypeScript + Tailwind로 만들어줘'
  })
});
```

### 코드 리뷰 자동화

```javascript
// 파일 읽기 + 리뷰
fetch('/api/claude/stream', {
  method: 'POST',
  body: JSON.stringify({
    prompt: './src/components/UserProfile.tsx 파일을 읽고 코드 리뷰해줘',
    allowedTools: ['Read', 'Grep']
  })
});
```

### 기술 문서 검색

```javascript
// 웹 검색 + 요약
fetch('/api/claude/stream', {
  method: 'POST',
  body: JSON.stringify({
    prompt: 'React Server Components 최신 베스트 프랙티스를 검색하고 요약해줘',
    allowedTools: ['WebSearch', 'WebFetch']
  })
});
```

## 주의사항

### 보안
- **신뢰할 수 있는 환경**에서만 실행
- `--dangerously-skip-permissions` 플래그 사용
- 프로덕션 환경에서는 권한 설정 필수

### 성능
- 타임아웃: 20분 (복잡한 작업 고려)
- 스트리밍 API 사용 권장 (긴 응답)
- 동기 API는 간단한 쿼리에만

### 비용
- Claude Code 구독 필요
- API 키 불필요 (별도 API 비용 없음)
- 무제한 사용 가능

## 문제 해결

### 인증 실패
```bash
# 재인증
claude

# 인증 상태 확인
ls -la ~/.claude
claude --verbose --print "test"
```

### 서버 실행 오류
```bash
# 포트 충돌 시
lsof -ti:3000 | xargs kill -9

# 의존성 재설치
rm -rf node_modules package-lock.json
npm install
```

### API 응답 없음
```bash
# Claude Code 프로세스 확인
ps aux | grep claude

# 로그 확인
tail -f /tmp/claude.log
```

## 통합 예시

### demo-generator와 함께 사용

```javascript
// demo-generator 에이전트 호출
fetch('/api/claude/stream', {
  method: 'POST',
  body: JSON.stringify({
    prompt: 'demo-generator를 사용해서 포트폴리오 웹사이트 만들어줘',
    agents: {
      'demo-generator': {
        description: '아름다운 웹앱 데모 생성 전문가',
        tools: ['Read', 'Write', 'Edit', 'Bash', 'WebSearch'],
        model: 'sonnet'
      }
    }
  })
});
```

### React 앱에서 사용

```typescript
// hooks/useClaude.ts
import { useState } from 'react';

export function useClaude() {
  const [response, setResponse] = useState('');
  const [loading, setLoading] = useState(false);

  const query = async (prompt: string) => {
    setLoading(true);
    const res = await fetch('/api/claude/stream', {
      method: 'POST',
      body: JSON.stringify({ prompt })
    });

    const reader = res.body?.getReader();
    const decoder = new TextDecoder();

    while (true) {
      const { done, value } = await reader!.read();
      if (done) break;

      const text = decoder.decode(value);
      const lines = text.split('\n').filter(line => line.trim());

      for (const line of lines) {
        const msg = JSON.parse(line);
        if (msg.type === 'assistant') {
          setResponse(prev => prev + msg.message.content[0]?.text);
        }
      }
    }

    setLoading(false);
  };

  return { response, loading, query };
}
```

## 참고 자료

- [Claude Code 공식 문서](https://docs.claude.com/claude-code)
- [Next.js 공식 문서](https://nextjs.org/docs)
- [Anthropic API 문서](https://docs.anthropic.com)

## 베스트 프랙티스

### ✅ DO
- 스트리밍 API 사용 (긴 응답)
- 명확한 프롬프트 작성
- 적절한 도구 권한 설정
- 에러 핸들링 구현
- 타임아웃 설정

### ❌ DON'T
- 프로덕션에서 권한 검증 생략
- 동기 API로 긴 작업 실행
- 무분별한 도구 허용
- 에러 처리 생략
- 민감한 정보 프롬프트에 포함

## 라이선스

MIT

---

이 스킬을 통해 Claude를 HTTP API로 래핑하여 **어떤 언어나 프레임워크에서든** 강력한 AI 기능을 통합할 수 있습니다.
