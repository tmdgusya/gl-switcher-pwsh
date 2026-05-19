# gl-switcher-pwsh

[gl-switcher](https://github.com/tmdgusya/gl-switcher)의 **PowerShell 포트** — [Claude Code](https://claude.com/claude-code)에서 LLM provider를 **WSL 없이 Windows 네이티브**로 전환합니다.

`gt` 한 글자 명령으로 GLM (Z.AI), Kimi (Moonshot), MiniMax, OpenRouter, 그리고 Anthropic 네이티브 Claude 사이를 오갈 수 있어요. WSL 설치하기 싫은 Windows + PowerShell 사용자를 위한 도구입니다.

[English README →](./README.md)

---

## 왜 만들었나

원본 `gl-switcher`는 bash 스크립트이고 `tmux`에 의존합니다. 둘 다 Windows엔 기본으로 없어요. WSL로 우회할 수도 있지만, Windows에서 Claude Code를 PowerShell로 바로 돌리는 사람한텐 API provider 바꾸자고 리눅스 환경 세팅하는 게 오버킬이죠.

이 포트는:

- **Windows PowerShell 5.1**과 **PowerShell 7+** 어디서나 그대로 동작
- 외부 의존성 0 (tmux, bash, WSL 전부 불필요)
- Claude Code가 읽는 환경변수(`ANTHROPIC_AUTH_TOKEN`, `ANTHROPIC_BASE_URL` 등)를 그대로 조작
- 원본의 `gt [g|k|m|o|c|s]` 명령 구조를 100% 유지

원본의 tmux 세션 동기화 기능은 **빠졌습니다**. Windows Terminal의 탭/페인은 tmux처럼 환경을 공유하지 않거든요. 여러 PowerShell 창을 띄웠다면 각 창에서 `gt <provider>`를 실행하시면 됩니다.

---

## 요구사항

- Windows 10/11
- PowerShell 5.1 (Windows 기본 탑재) 또는 PowerShell 7+
- [Claude Code](https://claude.com/claude-code) 설치
- 지원되는 provider 중 최소 하나의 API 키

---

## 설치

### 1. `gt.ps1` 내려받기

안정적인 위치에 두세요. 사용자 홈 디렉토리(`$env:USERPROFILE`) 추천.

```powershell
Invoke-WebRequest -Uri "https://raw.githubusercontent.com/tmdgusya/gl-switcher-pwsh/main/gt.ps1" `
    -OutFile "$env:USERPROFILE\gt.ps1"
```

또는 그냥 이 레포를 `git clone` 받아서 원하는 위치로 옮기셔도 됩니다.

### 2. 로컬 스크립트 실행 허용 (1회만)

PowerShell은 기본적으로 서명 안 된 스크립트를 차단해요. 로컬 스크립트만 허용:

```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

`Y` 입력. 본인 계정에만 적용되고, 본인이 만든 로컬 스크립트만 영향 받습니다.

### 3. PowerShell 시작할 때마다 `gt` 자동 로드

프로필 파일에 dot-source 한 줄 추가:

```powershell
# 프로필 파일 없으면 만들기
if (-not (Test-Path $PROFILE)) { New-Item -Path $PROFILE -ItemType File -Force }

# dot-source 라인 추가
Add-Content -Path $PROFILE -Value '. "$env:USERPROFILE\gt.ps1"'
```

> **참고:** Windows에서 `$PROFILE`은 보통
> `C:\Users\<유저>\Documents\WindowsPowerShell\Microsoft.PowerShell_profile.ps1` 또는,
> OneDrive가 문서 폴더를 동기화 중이면
> `C:\Users\<유저>\OneDrive\문서\WindowsPowerShell\Microsoft.PowerShell_profile.ps1` 입니다.
> 둘 다 정상이에요. PowerShell이 `$PROFILE` 변수가 가리키는 경로를 그대로 씁니다.

### 4. 재로드

새 PowerShell 창을 열거나, 현재 창에서:

```powershell
. $PROFILE
```

확인:

```powershell
gt
# 사용법 안내가 출력되면 성공
```

---

## 설정

API 키 공급 방법은 두 가지. 편한 쪽으로 고르세요.

### 방법 A — 환경변수 (추천)

Windows 사용자 환경변수에 한 번 등록해두면 스크립트가 자동으로 가져옵니다. 스크립트에 하드코딩된 값보다 우선해요.

```powershell
[Environment]::SetEnvironmentVariable('GT_GLM_AUTH_TOKEN',        'your-glm-key',        'User')
[Environment]::SetEnvironmentVariable('GT_KIMI_AUTH_TOKEN',       'your-kimi-key',       'User')
[Environment]::SetEnvironmentVariable('GT_MINIMAX_AUTH_TOKEN',    'your-minimax-key',    'User')
[Environment]::SetEnvironmentVariable('GT_OPENROUTER_AUTH_TOKEN', 'your-openrouter-key', 'User')
```

설정 후 PowerShell 재시작해야 적용됩니다.

### 방법 B — `gt.ps1` 직접 수정

`gt.ps1` 상단의 `YOUR_*_API_KEY` 자리표시자를 본인 키로 교체:

```powershell
$script:GT_GLM_AUTH_TOKEN = 'your-actual-key-here'
```

> ⚠️ 방법 B 쓰실 거면 **키가 박힌 `gt.ps1`을 절대 공개 레포에 올리지 마세요**. 방법 A를 쓰시거나, git 추적 안 되는 위치에 복사해서 쓰시는 걸 권장합니다.

---

## 사용법

```powershell
gt g    # GLM (Z.AI) 로 전환
gt k    # Kimi (Moonshot) 로 전환
gt m    # MiniMax 로 전환
gt o    # OpenRouter 로 전환
gt c    # Anthropic 네이티브 Claude 로 복귀 (override 환경변수 모두 제거)
gt s    # 현재 활성 provider 확인 (인자 없을 때 기본값)
gt      # `gt s` 와 동일
```

전환 후 같은 셸에서 `claude` (Claude Code CLI)를 실행하면 새 환경변수를 자동으로 사용합니다.

### 예시

```powershell
PS C:\> gt s
Claude (Anthropic)

PS C:\> gt g
GLM mode

PS C:\> gt s
GLM (glm-5.1)

PS C:\> claude
# ... Z.AI의 Anthropic 호환 엔드포인트로 GLM 사용 ...

PS C:\> gt c
Claude mode

PS C:\> gt s
Claude (Anthropic)
```

---

## 지원 provider

| 모드 | Provider | 엔드포인트 | API 키 발급처 |
|------|----------|----------|--------------|
| `g`  | GLM (Z.AI) | `https://api.z.ai/api/anthropic` | <https://z.ai> |
| `k`  | Kimi (Moonshot) | `https://api.kimi.com/coding/` | <https://platform.moonshot.cn> |
| `m`  | MiniMax | `https://api.minimax.io/anthropic` | <https://api.minimax.io> |
| `o`  | OpenRouter | `https://openrouter.ai/api` | <https://openrouter.ai> |
| `c`  | Anthropic (Claude) | — `~/.claude/`의 OAuth 인증 사용 | <https://claude.com/claude-code> |

기본 모델명은 `gt.ps1` 상단에 박혀 있어요. provider 측에서 모델명을 바꾸면 그쪽 값도 같이 수정하시면 됩니다.

---

## 동작 원리

Claude Code는 몇 가지 환경변수로 어떤 API를 호출할지 결정합니다:

- `ANTHROPIC_BASE_URL` — API 호스트 오버라이드
- `ANTHROPIC_AUTH_TOKEN` — Anthropic 외 provider용 인증 토큰
- `ANTHROPIC_DEFAULT_HAIKU_MODEL` / `ANTHROPIC_DEFAULT_SONNET_MODEL` / `ANTHROPIC_DEFAULT_OPUS_MODEL` — 모델 매핑
- 기타 (`ANTHROPIC_VERSION`, `API_TIMEOUT_MS`, `CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC`)

`gt g` 실행 시 이 변수들을 GLM 값으로 일괄 설정합니다. `gt c` 실행 시 전부 제거해서 Claude Code가 기본 Anthropic OAuth 흐름으로 돌아가게 만들고요. 각 `gt <mode>`는 결국 `Set-Item env:VAR`와 `Remove-Item env:VAR` 묶음일 뿐입니다.

---

## 문제 해결

**`gt : 용어가 cmdlet... 인식되지 않습니다`**

스크립트가 아직 로드되지 않았습니다.

```powershell
. $PROFILE                          # 프로필 다시 로드
# 또는
. "$env:USERPROFILE\gt.ps1"         # 이 스크립트만 로드
```

**`이 시스템에서 스크립트를 실행할 수 없으므로...` 에러**

설치 단계 2를 다시 실행:

```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

**`gt g` 했는데도 Claude Code가 Anthropic을 부른다**

`gt g`를 실행한 그 *같은* PowerShell 창에서 `claude`를 실행했는지 확인하세요. 환경변수는 세션 간 공유되지 않습니다. 검증:

```powershell
gt s
$env:ANTHROPIC_BASE_URL
```

**`$PROFILE`이 OneDrive 경로를 가리킨다**

OneDrive가 `Documents` 폴더를 동기화 중일 때 발생합니다. 별도 `profile.ps1`을 만들어 `$PROFILE`을 다른 경로로 설정할 수도 있지만, 대부분의 경우 OneDrive 경로도 정상 동작합니다 — 그저 프로필이 여러 PC 간 동기화될 뿐이에요.

---

## 원본 [gl-switcher](https://github.com/tmdgusya/gl-switcher) 와의 차이

| 항목 | gl-switcher (bash) | gl-switcher-pwsh |
|------|-------------------|-----------------|
| 셸 | bash / zsh | Windows PowerShell 5.1 / PowerShell 7+ |
| OS | macOS, Linux, WSL | Windows 네이티브 |
| tmux 환경변수 동기화 | ✅ | ❌ (Windows엔 tmux 없음) |
| 멀티 페인 환경 전파 | ✅ tmux 사용 | 각 페인에서 `gt` 따로 실행 |
| Provider 명령 | 동일 | 동일 |
| 설정 구조 | 동일 | 동일 |

---

## 라이선스

MIT — 원본 [gl-switcher](https://github.com/tmdgusya/gl-switcher)와 동일.

## 크레딧

- 원본 [gl-switcher](https://github.com/tmdgusya/gl-switcher) by [@tmdgusya](https://github.com/tmdgusya)
- 이 PowerShell 포트는 원본과 동일한 명령/설정 컨벤션을 따릅니다.
