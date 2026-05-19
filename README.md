# gl-switcher-pwsh

A **PowerShell** port of [gl-switcher](https://github.com/tmdgusya/gl-switcher) — switch LLM providers for [Claude Code](https://claude.com/claude-code) on **native Windows** without WSL.

`gt` lets you flip between GLM (Z.AI), Kimi (Moonshot), MiniMax, OpenRouter, and Anthropic's native Claude with a single character. Designed for Windows users who run Claude Code in PowerShell and don't want to install WSL.

[한국어 README →](./README.ko.md)

---

## Why this exists

The original `gl-switcher` is a bash script that depends on `tmux` — neither of which ships with Windows. WSL works fine for many people, but if you're a native Windows + PowerShell developer (running Claude Code directly on Windows), you don't want to set up Linux just to switch API providers.

This port:

- Runs in **Windows PowerShell 5.1** and **PowerShell 7+** out of the box
- Uses no external dependencies (no tmux, no bash, no WSL)
- Manipulates the same environment variables Claude Code reads (`ANTHROPIC_AUTH_TOKEN`, `ANTHROPIC_BASE_URL`, etc.)
- Preserves the exact same `gt [g|k|m|o|c|s]` command surface

The tmux session-sync feature from the original is **omitted** — Windows Terminal panes don't share environment the way tmux panes do, so there's nothing to sync. If you open multiple PowerShell tabs/panes, run `gt <provider>` in each one.

---

## Requirements

- Windows 10/11
- PowerShell 5.1 (built-in) or PowerShell 7+
- [Claude Code](https://claude.com/claude-code) installed
- An API key for at least one of the supported providers

---

## Installation

### 1. Download `gt.ps1`

Place it somewhere stable. Recommended: your user profile root.

```powershell
Invoke-WebRequest -Uri "https://raw.githubusercontent.com/tmdgusya/gl-switcher-pwsh/main/gt.ps1" `
    -OutFile "$env:USERPROFILE\gt.ps1"
```

Or `git clone` this repo and copy `gt.ps1` wherever you want.

### 2. Allow local scripts to run (one-time)

PowerShell blocks unsigned scripts by default. Permit local ones:

```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

Answer `Y`. This only affects your user account, and only for scripts you write locally.

### 3. Auto-load `gt` in every PowerShell session

Append a dot-source line to your PowerShell profile:

```powershell
# Create the profile file if it doesn't exist
if (-not (Test-Path $PROFILE)) { New-Item -Path $PROFILE -ItemType File -Force }

# Add the dot-source line
Add-Content -Path $PROFILE -Value '. "$env:USERPROFILE\gt.ps1"'
```

> **Note:** On Windows, `$PROFILE` typically resolves to
> `C:\Users\<you>\Documents\WindowsPowerShell\Microsoft.PowerShell_profile.ps1` —
> or, if OneDrive is redirecting your Documents folder, to
> `C:\Users\<you>\OneDrive\Documents\WindowsPowerShell\Microsoft.PowerShell_profile.ps1`.
> Either is fine; PowerShell uses whatever `$PROFILE` points at.

### 4. Reload

Either open a new PowerShell window, or in the current one:

```powershell
. $PROFILE
```

Verify:

```powershell
gt
# Should print the usage banner
```

---

## Configuration

You have two ways to supply API keys. Pick whichever you prefer.

### Option A — Environment variables (recommended)

Set them once via Windows' user environment, and the script picks them up. They take precedence over hardcoded defaults in the script.

```powershell
[Environment]::SetEnvironmentVariable('GT_GLM_AUTH_TOKEN',        'your-glm-key',        'User')
[Environment]::SetEnvironmentVariable('GT_KIMI_AUTH_TOKEN',       'your-kimi-key',       'User')
[Environment]::SetEnvironmentVariable('GT_MINIMAX_AUTH_TOKEN',    'your-minimax-key',    'User')
[Environment]::SetEnvironmentVariable('GT_OPENROUTER_AUTH_TOKEN', 'your-openrouter-key', 'User')
```

Restart PowerShell after setting these so they propagate.

### Option B — Edit `gt.ps1` directly

Open `gt.ps1` and replace the `YOUR_*_API_KEY` placeholders at the top of the file:

```powershell
$script:GT_GLM_AUTH_TOKEN = 'your-actual-key-here'
```

> ⚠️ If you choose Option B, **never commit `gt.ps1` to a public repo** with your keys baked in. Use Option A or copy `gt.ps1` to a personal location that isn't tracked by git.

---

## Usage

```powershell
gt g    # Switch to GLM (Z.AI)
gt k    # Switch to Kimi (Moonshot)
gt m    # Switch to MiniMax
gt o    # Switch to OpenRouter
gt c    # Switch back to native Claude (clears all override env vars)
gt s    # Show current active provider (default if no arg)
gt      # Same as `gt s`
```

After switching, run `claude` (Claude Code's CLI) in the same shell and it will pick up the new env vars automatically.

### Example session

```powershell
PS C:\> gt s
Claude (Anthropic)

PS C:\> gt g
GLM mode

PS C:\> gt s
GLM (glm-5.1)

PS C:\> claude
# ... uses GLM via Z.AI's Anthropic-compatible endpoint ...

PS C:\> gt c
Claude mode

PS C:\> gt s
Claude (Anthropic)
```

---

## Supported providers

| Mode | Provider | Endpoint | Where to get a key |
|------|----------|----------|-------------------|
| `g`  | GLM (Z.AI) | `https://api.z.ai/api/anthropic` | <https://z.ai> |
| `k`  | Kimi (Moonshot) | `https://api.kimi.com/coding/` | <https://platform.moonshot.cn> |
| `m`  | MiniMax | `https://api.minimax.io/anthropic` | <https://api.minimax.io> |
| `o`  | OpenRouter | `https://openrouter.ai/api` | <https://openrouter.ai> |
| `c`  | Anthropic (Claude) | — uses your `~/.claude/` OAuth credentials | <https://claude.com/claude-code> |

Default model names are baked into `gt.ps1` near the top — edit them if the providers rename their models.

---

## How it works

Claude Code reads a handful of environment variables to decide which API to call:

- `ANTHROPIC_BASE_URL` — overrides the API host
- `ANTHROPIC_AUTH_TOKEN` — auth token for non-Anthropic providers
- `ANTHROPIC_DEFAULT_HAIKU_MODEL` / `ANTHROPIC_DEFAULT_SONNET_MODEL` / `ANTHROPIC_DEFAULT_OPUS_MODEL` — model mapping
- A few others (`ANTHROPIC_VERSION`, `API_TIMEOUT_MS`, `CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC`)

When you run `gt g`, the script sets all of these to GLM's values. When you run `gt c`, it clears them, so Claude Code falls back to its built-in Anthropic OAuth flow. Each `gt <mode>` is just `Set-Item env:VAR` followed by `Remove-Item env:VAR` for whatever the previous provider needed.

---

## Troubleshooting

**`gt : 용어가 cmdlet... 인식되지 않습니다` / `gt is not recognized`**

The script isn't loaded yet. Either:

```powershell
. $PROFILE                          # reload your profile
# or
. "$env:USERPROFILE\gt.ps1"         # load just this script
```

**`이 시스템에서 스크립트를 실행할 수 없으므로...` / Execution policy error**

Run step 2 of the installation again:

```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

**Claude Code still calls Anthropic after `gt g`**

Make sure you're running `claude` in the *same* PowerShell window where you ran `gt g`. Env vars don't cross sessions. Verify with:

```powershell
gt s
$env:ANTHROPIC_BASE_URL
```

**`$PROFILE` points to a OneDrive path I don't trust**

OneDrive sometimes redirects `Documents`. You can move the profile out of OneDrive by setting `$PROFILE` to a different path in a custom `profile.ps1`, but for most users the OneDrive path is fine — it just means your profile syncs across machines.

---

## Differences vs. the original [gl-switcher](https://github.com/tmdgusya/gl-switcher)

| Feature | gl-switcher (bash) | gl-switcher-pwsh |
|---------|-------------------|-----------------|
| Shell | bash / zsh | Windows PowerShell 5.1 / PowerShell 7+ |
| OS | macOS, Linux, WSL | Native Windows |
| tmux env sync | ✅ | ❌ (no tmux on Windows) |
| Multi-pane env propagation | ✅ via tmux | Run `gt` in each pane |
| Provider commands | identical | identical |
| Config layout | identical | identical |

---

## License

MIT — same as the original [gl-switcher](https://github.com/tmdgusya/gl-switcher).

## Credits

- Original [gl-switcher](https://github.com/tmdgusya/gl-switcher) by [@tmdgusya](https://github.com/tmdgusya)
- This PowerShell port follows the same command surface and config conventions.
