---
name: terminal-screenshot
description: >
  This skill should be used when the user asks to "take a terminal screenshot",
  "capture terminal output", "generate terminal evidence", "screenshot of command",
  "evidencia de terminal", "captura de pantalla del terminal", or needs to create PNG
  images that look like real terminal windows from command output. Works headless via
  Playwright — no screen required. Generates styled HTML rendered to PNG with dark
  terminal theme, monospace font, and proper colors. Supports single commands and
  batch mode for multiple screenshots.
---

# Terminal Screenshot Generator

Generate professional PNG screenshots that look like real terminal windows from
command output. Uses Playwright headless browser to render styled HTML — no
screen or display required.

## How It Works

1. Execute the command (locally or via SSH)
2. Generate an HTML page styled as a terminal window
3. Render with Playwright and screenshot the terminal element
4. Save as PNG

## Template

The HTML template uses this style:

- **Title bar**: dark gray (#313244) with red/yellow/green dots + title text
- **Background**: dark (#1e1e2e), Catppuccin Mocha theme
- **Prompt**: green (#a6e3a1) bold
- **Command**: blue (#89b4fa) bold
- **Output**: light gray (#cdd6f4)
- **Font**: Courier New monospace, 11px
- **Border radius**: 10px with box-shadow

## Execution Steps

### Step 1: Ensure HTTP server is running

Check if port 8899 is serving. If not, start one:

```bash
lsof -i :8899 >/dev/null 2>&1 || (cd /tmp && python3 -m http.server 8899 &)
```

### Step 2: Execute command and capture output

Run the command and store the output. For remote commands use SSH:

```bash
# Local
OUTPUT=$(kubectl get nodes -o wide 2>&1)

# Remote via SSH
OUTPUT=$(ssh <alias> "<command>" 2>/dev/null | grep -v Warning)
```

### Step 3: Generate terminal HTML

Write `/tmp/terminal-capture.html` with:

```html
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<style>
body { margin: 0; padding: 20px; background: #f0f0f0; display: inline-block; }
.terminal {
  background: #1e1e2e;
  border-radius: 10px;
  box-shadow: 0 8px 32px rgba(0,0,0,0.3);
  overflow: hidden;
  font-family: 'Courier New', monospace;
  display: inline-block;
}
.titlebar {
  background: #313244;
  padding: 10px 15px;
  display: flex;
  align-items: center;
  gap: 8px;
}
.dot { width: 12px; height: 12px; border-radius: 50%; }
.red { background: #f38ba8; }
.yellow { background: #f9e2af; }
.green { background: #a6e3a1; }
.title { color: #6c7086; font-size: 12px; margin-left: 10px; }
.content {
  padding: 15px 20px 20px 20px;
  color: #cdd6f4;
  font-size: 11px;
  line-height: 1.4;
  white-space: pre;
  overflow: visible;
}
.prompt { color: #a6e3a1; font-weight: bold; }
.command { color: #89b4fa; font-weight: bold; }
</style>
</head>
<body>
<div class="terminal">
  <div class="titlebar">
    <div class="dot red"></div>
    <div class="dot yellow"></div>
    <div class="dot green"></div>
    <span class="title">TITLE_PLACEHOLDER</span>
  </div>
  <div class="content"><span class="prompt">PROMPT_PLACEHOLDER</span><span class="command">COMMAND_PLACEHOLDER</span>
OUTPUT_PLACEHOLDER</div>
</div>
</body>
</html>
```

Replace placeholders using Python to HTML-escape the output:

```python
python3 -c "
import html
output = '''RAW_OUTPUT'''
escaped = html.escape(output)
with open('/tmp/terminal-capture.html', 'r') as f:
    content = f.read()
content = content.replace('OUTPUT_PLACEHOLDER', escaped)
content = content.replace('TITLE_PLACEHOLDER', 'user@host: /path')
content = content.replace('PROMPT_PLACEHOLDER', '[user@host path]# ')
content = content.replace('COMMAND_PLACEHOLDER', 'the command')
with open('/tmp/terminal-capture.html', 'w') as f:
    f.write(content)
"
```

### Step 4: Screenshot with Playwright

```javascript
// Use mcp__playwright__browser_run_code
async (page) => {
  await page.setViewportSize({ width: 1920, height: 1080 });
  await page.goto('http://localhost:8899/terminal-capture.html');
  await page.waitForTimeout(500);
  const terminal = await page.locator('.terminal');
  await terminal.screenshot({
    path: '/path/to/output.png',
    type: 'png',
    scale: 'device'
  });
  return 'done';
}
```

## Parameters

When invoked, determine these from context or arguments:

| Parameter | Description | Example |
|-----------|-------------|---------|
| **command** | The command to execute | `oc get nodes -o wide` |
| **host** | SSH alias or "local" | `cabasprd`, `cabascnt`, `local` |
| **title** | Title bar text | `root@prbast1001: /opt/OCP4` |
| **prompt** | Shell prompt text | `[root@prbast1001 install-fase2]# ` |
| **output_path** | Where to save PNG | `evidencias/01-nodos.png` |
| **env_vars** | Environment to set before command | `KUBECONFIG=/opt/OCP4/install-fase2/auth/kubeconfig` |

## Batch Mode

For generating multiple screenshots (e.g., ATP evidencias), accept a list:

```
/terminal-screenshot batch
  host: cabasprd
  env: KUBECONFIG=/opt/OCP4/install-fase2/auth/kubeconfig
  title: root@prbast1001: /opt/OCP4
  prompt: [root@prbast1001 ~]#
  commands:
    - cmd: "oc get nodes -o wide"
      out: evidencias/01-nodos-cluster.png
    - cmd: "oc get co"
      out: evidencias/02-cluster-operators.png
    - cmd: "oc get mcp"
      out: evidencias/03-mcp.png
```

For batch mode:
1. Start HTTP server once
2. Loop through commands: execute, generate HTML, screenshot
3. Report summary of generated files

## Multi-command Screenshots

Some evidencias need multiple commands in one screenshot. Concatenate outputs:

```bash
OUTPUT=$(ssh host "cmd1 2>&1; echo ''; cmd2 2>&1")
```

Show both commands in the terminal:

```
[root@host ~]# cmd1
...output1...

[root@host ~]# cmd2
...output2...
```

For multi-command, build the content manually with multiple prompt+command+output blocks.

## Customization

### Font size
Change `.content { font-size: 11px; }` — use 10px for wide outputs, 12px for short ones.

### Theme variants
- **Catppuccin Mocha** (default): bg=#1e1e2e, titlebar=#313244
- **Dracula**: bg=#282a36, titlebar=#44475a
- **Nord**: bg=#2e3440, titlebar=#3b4252

### Max width
If output is very wide, consider using `-o custom-columns` or column filtering instead of `-o wide` to keep screenshots readable.

## Rules

1. ALWAYS execute the REAL command — never fake output
2. HTML-escape ALL output with `html.escape()` to prevent XSS/rendering issues
3. Use `grep -v Warning` to filter SSH warnings from output
4. Title and prompt MUST be consistent (same user, host, path)
5. Ensure HTTP server is running before Playwright navigation
6. Use `scale: 'device'` in screenshot for crisp text
7. Set viewport to 1920x1080 to fit wide outputs
8. For very long outputs (>50 lines), consider splitting into multiple screenshots

## Do NOT use this skill for

- Taking screenshots of GUI applications (use grim/flameshot instead)
- Capturing browser pages (use Playwright directly)
- Recording terminal sessions (use asciinema)
