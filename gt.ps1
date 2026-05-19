# gt.ps1 — LLM provider switcher for Claude Code (PowerShell port)
# Usage: gt [g|k|m|o|c|s]
#
# Install: dot-source from your PowerShell profile, e.g.
#   . "$env:USERPROFILE\gt.ps1"
# Then reload: . $PROFILE

# ── User config ────────────────────────────────────────────────────────────────
# GLM (Z.ai)
if (-not $env:GT_GLM_AUTH_TOKEN) { $script:GT_GLM_AUTH_TOKEN = 'YOUR_GLM_API_KEY' } else { $script:GT_GLM_AUTH_TOKEN = $env:GT_GLM_AUTH_TOKEN }
$script:GT_GLM_BASE_URL     = 'https://api.z.ai/api/anthropic'
$script:GT_GLM_HAIKU_MODEL  = 'glm-5-turbo'
$script:GT_GLM_SONNET_MODEL = 'glm-5.1'
$script:GT_GLM_OPUS_MODEL   = 'glm-5.1'

# Kimi (Moonshot)
if (-not $env:GT_KIMI_AUTH_TOKEN) { $script:GT_KIMI_AUTH_TOKEN = 'YOUR_KIMI_API_KEY' } else { $script:GT_KIMI_AUTH_TOKEN = $env:GT_KIMI_AUTH_TOKEN }
$script:GT_KIMI_BASE_URL = 'https://api.kimi.com/coding/'
$script:GT_KIMI_MODEL    = 'kimi-k2.6-code-preview'

# MiniMax
if (-not $env:GT_MINIMAX_AUTH_TOKEN) { $script:GT_MINIMAX_AUTH_TOKEN = 'YOUR_MINIMAX_API_KEY' } else { $script:GT_MINIMAX_AUTH_TOKEN = $env:GT_MINIMAX_AUTH_TOKEN }
$script:GT_MINIMAX_BASE_URL = 'https://api.minimax.io/anthropic'
$script:GT_MINIMAX_MODEL    = 'MiniMax-M2.7-highspeed'

# OpenRouter
if (-not $env:GT_OPENROUTER_AUTH_TOKEN) { $script:GT_OPENROUTER_AUTH_TOKEN = 'YOUR_OPENROUTER_API_KEY' } else { $script:GT_OPENROUTER_AUTH_TOKEN = $env:GT_OPENROUTER_AUTH_TOKEN }
$script:GT_OPENROUTER_BASE_URL = 'https://openrouter.ai/api'
$script:GT_OPENROUTER_MODEL    = 'qwen/qwen3.6-plus:free'
# ── End user config ────────────────────────────────────────────────────────────

function _Gt-Clear {
    param([string[]]$Names)
    foreach ($n in $Names) {
        if (Test-Path "env:$n") { Remove-Item "env:$n" -ErrorAction SilentlyContinue }
    }
}

function gt {
    param([string]$Mode = 's')

    switch ($Mode) {
        'g' {
            $env:ANTHROPIC_AUTH_TOKEN          = $script:GT_GLM_AUTH_TOKEN
            $env:ANTHROPIC_BASE_URL            = $script:GT_GLM_BASE_URL
            $env:ANTHROPIC_VERSION             = '2023-06-01'
            $env:API_TIMEOUT_MS                = '3000000'
            $env:ANTHROPIC_DEFAULT_HAIKU_MODEL  = $script:GT_GLM_HAIKU_MODEL
            $env:ANTHROPIC_DEFAULT_SONNET_MODEL = $script:GT_GLM_SONNET_MODEL
            $env:ANTHROPIC_DEFAULT_OPUS_MODEL   = $script:GT_GLM_OPUS_MODEL
            $env:ANTHROPIC_MODEL               = $script:GT_GLM_OPUS_MODEL
            _Gt-Clear @('CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC')
            Write-Host 'GLM mode'
        }
        'k' {
            $env:ANTHROPIC_AUTH_TOKEN          = $script:GT_KIMI_AUTH_TOKEN
            $env:ANTHROPIC_BASE_URL            = $script:GT_KIMI_BASE_URL
            $env:ANTHROPIC_MODEL               = $script:GT_KIMI_MODEL
            $env:ANTHROPIC_DEFAULT_HAIKU_MODEL  = $script:GT_KIMI_MODEL
            $env:ANTHROPIC_DEFAULT_SONNET_MODEL = $script:GT_KIMI_MODEL
            $env:ANTHROPIC_DEFAULT_OPUS_MODEL   = $script:GT_KIMI_MODEL
            _Gt-Clear @('ANTHROPIC_VERSION','API_TIMEOUT_MS','CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC')
            Write-Host 'Kimi mode'
        }
        'm' {
            $env:ANTHROPIC_AUTH_TOKEN          = $script:GT_MINIMAX_AUTH_TOKEN
            $env:ANTHROPIC_BASE_URL            = $script:GT_MINIMAX_BASE_URL
            $env:ANTHROPIC_MODEL               = $script:GT_MINIMAX_MODEL
            $env:API_TIMEOUT_MS                = '3000000'
            $env:CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC = '1'
            $env:ANTHROPIC_DEFAULT_HAIKU_MODEL  = $script:GT_MINIMAX_MODEL
            $env:ANTHROPIC_DEFAULT_SONNET_MODEL = $script:GT_MINIMAX_MODEL
            $env:ANTHROPIC_DEFAULT_OPUS_MODEL   = $script:GT_MINIMAX_MODEL
            _Gt-Clear @('ANTHROPIC_VERSION')
            Write-Host 'MiniMax mode'
        }
        'o' {
            $env:ANTHROPIC_AUTH_TOKEN          = $script:GT_OPENROUTER_AUTH_TOKEN
            $env:ANTHROPIC_API_KEY             = ''
            $env:ANTHROPIC_BASE_URL            = $script:GT_OPENROUTER_BASE_URL
            $env:ANTHROPIC_MODEL               = $script:GT_OPENROUTER_MODEL
            $env:API_TIMEOUT_MS                = '3000000'
            $env:CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC = '1'
            $env:ANTHROPIC_DEFAULT_HAIKU_MODEL  = $script:GT_OPENROUTER_MODEL
            $env:ANTHROPIC_DEFAULT_SONNET_MODEL = $script:GT_OPENROUTER_MODEL
            $env:ANTHROPIC_DEFAULT_OPUS_MODEL   = $script:GT_OPENROUTER_MODEL
            _Gt-Clear @('ANTHROPIC_VERSION')
            Write-Host 'OpenRouter mode'
        }
        'c' {
            _Gt-Clear @(
                'ANTHROPIC_AUTH_TOKEN','ANTHROPIC_API_KEY','ANTHROPIC_BASE_URL',
                'ANTHROPIC_VERSION','ANTHROPIC_MODEL','API_TIMEOUT_MS',
                'ANTHROPIC_DEFAULT_HAIKU_MODEL','ANTHROPIC_DEFAULT_SONNET_MODEL',
                'ANTHROPIC_DEFAULT_OPUS_MODEL','CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC'
            )
            Write-Host 'Claude mode'
        }
        { $_ -eq 's' -or $_ -eq '' } {
            if     ($env:ANTHROPIC_BASE_URL -like '*z.ai*')       { Write-Host "GLM ($env:ANTHROPIC_DEFAULT_SONNET_MODEL)" }
            elseif ($env:ANTHROPIC_BASE_URL -like '*kimi.com*')   { Write-Host "Kimi ($env:ANTHROPIC_DEFAULT_SONNET_MODEL)" }
            elseif ($env:ANTHROPIC_BASE_URL -like '*minimax*')    { Write-Host "MiniMax ($env:ANTHROPIC_MODEL)" }
            elseif ($env:ANTHROPIC_BASE_URL -like '*openrouter*') { Write-Host "OpenRouter ($env:ANTHROPIC_MODEL)" }
            else                                                  { Write-Host 'Claude (Anthropic)' }
        }
        default {
            Write-Host 'Usage: gt [g|k|m|o|c|s]'
            Write-Host '  g - GLM mode (Z.ai)'
            Write-Host '  k - Kimi mode (Moonshot)'
            Write-Host '  m - MiniMax mode'
            Write-Host '  o - OpenRouter mode'
            Write-Host '  c - Claude mode (Anthropic)'
            Write-Host '  s - show current mode (default)'
        }
    }
}
