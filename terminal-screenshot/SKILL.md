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
user-invocable: true
argument-hint: "[command-or-text]"
allowed-tools: Bash Read Write mcp__playwright__browser_navigate mcp__playwright__browser_take_screenshot mcp__playwright__browser_run_code
---

# Terminal Screenshot Generator

Genera PNGs profesionales que parecen ventanas de terminal reales.
Playwright headless — sin pantalla ni display.

## Reglas de Estandarización (OBLIGATORIAS)

### Tamaño fijo
- **Viewport**: 1920x1080 SIEMPRE
- **Ancho terminal**: `min-width: 1100px` — todas las capturas tienen el mismo ancho
- **Font size**: `13px` FIJO — nunca cambiar entre capturas
- **Padding**: `20px` en content — consistente

### Formato: Comando + Resultado (SIEMPRE)
Cada captura DEBE mostrar:
1. **Prompt** (verde) — `[user@host path]$ `
2. **Comando** (azul) — el comando ejecutado
3. **Línea vacía**
4. **Output** (gris claro) — resultado real del comando

NUNCA generar capturas solo con output sin el comando.
NUNCA generar capturas solo con el comando sin output.

### Multi-comando en una captura
Si hay múltiples comandos en una captura, cada uno sigue el mismo patrón:
```
[user@host ~]$ comando1
...output1...

[user@host ~]$ comando2
...output2...
```

### Font y colores (Catppuccin Mocha — NO cambiar)
- **Font**: `'JetBrains Mono', 'Fira Code', 'Courier New', monospace` — 13px
- **Background**: `#1e1e2e`
- **Titlebar**: `#313244`
- **Prompt**: `#a6e3a1` (verde) bold
- **Comando**: `#89b4fa` (azul) bold
- **Output**: `#cdd6f4` (gris claro)
- **Dots**: red `#f38ba8`, yellow `#f9e2af`, green `#a6e3a1`
- **Border radius**: 10px, box-shadow `0 8px 32px rgba(0,0,0,0.3)`

---

## Workflow

### 1. HTTP server

```bash
lsof -i :8899 >/dev/null 2>&1 || (cd /tmp && python3 -m http.server 8899 &)
```

### 2. Ejecutar comando

```bash
# Local
OUTPUT=$(oc get nodes -o wide 2>&1)

# Remoto via SSH
OUTPUT=$(ssh <alias> "<command>" 2>/dev/null | grep -v Warning)
```

SIEMPRE ejecutar el comando REAL — nunca inventar output.

### 3. Generar HTML

Escribir `/tmp/terminal-capture.html`:

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
  font-family: 'JetBrains Mono', 'Fira Code', 'Courier New', monospace;
  min-width: 1100px;
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
  padding: 20px;
  color: #cdd6f4;
  font-size: 13px;
  line-height: 1.5;
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

Reemplazar placeholders con Python (HTML-escape obligatorio):

```python
python3 -c "
import html
output = '''RAW_OUTPUT'''
escaped = html.escape(output)
with open('/tmp/terminal-capture.html', 'r') as f:
    content = f.read()
content = content.replace('OUTPUT_PLACEHOLDER', escaped)
content = content.replace('TITLE_PLACEHOLDER', 'user@host: /path')
content = content.replace('PROMPT_PLACEHOLDER', '[user@host path]$ ')
content = content.replace('COMMAND_PLACEHOLDER', 'the command')
with open('/tmp/terminal-capture.html', 'w') as f:
    f.write(content)
"
```

### 4. Screenshot con Playwright

```javascript
async (page) => {
  await page.setViewportSize({ width: 1920, height: 1080 });
  await page.goto('http://localhost:8899/terminal-capture.html');
  await page.waitForTimeout(500);
  const terminal = await page.locator('.terminal');
  await terminal.screenshot({ path: '/path/to/output.png', type: 'png', scale: 'device' });
  return 'done';
}
```

`scale: 'device'` para texto nítido. Viewport 1920x1080 SIEMPRE.

---

## Parámetros

| Parámetro | Descripción | Ejemplo |
|-----------|-------------|---------|
| **command** | Comando a ejecutar | `oc get nodes -o wide` |
| **host** | SSH alias o "local" | `bastion`, `local` |
| **title** | Texto del titlebar | `root@bastion: /opt/OCP4` |
| **prompt** | Prompt del shell | `[root@bastion ~]$ ` |
| **output_path** | Dónde guardar PNG | `evidencias/01-nodos.png` |

### Consistencia entre capturas

En un batch, title y prompt DEBEN ser iguales en TODAS las capturas:
- Mismo usuario
- Mismo host
- Mismo path (o path relevante)

---

## Batch Mode

Para múltiples capturas (ej: evidencias ATP):

1. Iniciar HTTP server una vez
2. Loop: ejecutar → generar HTML → screenshot
3. Reportar resumen

Todas las capturas del batch usan:
- Mismo viewport (1920x1080)
- Mismo font (13px)
- Mismo min-width (1100px)
- Mismo theme (Catppuccin Mocha)
- Mismo prompt/title

---

## Reglas

1. SIEMPRE ejecutar el comando REAL — nunca inventar output
2. SIEMPRE mostrar comando + output juntos
3. SIEMPRE HTML-escape con `html.escape()`
4. SIEMPRE `min-width: 1100px` para ancho consistente
5. SIEMPRE font 13px — nunca variar
6. SIEMPRE viewport 1920x1080
7. SIEMPRE `scale: 'device'` para texto nítido
8. Filtrar warnings de SSH con `grep -v Warning`
9. Si output > 50 líneas, dividir en múltiples capturas
10. NO usar para GUIs, browsers, ni grabaciones (asciinema)
