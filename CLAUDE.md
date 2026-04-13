# Claude Code Knowledge Base

## Usuario
- Usuario: jeanlopez
- Sistema: Fedora 43 con Hyprland + NVIDIA
- Shell: zsh con Oh My Zsh + Starship

## Direnv para Kubernetes

Usar direnv para cambiar automáticamente el contexto de Kubernetes por proyecto/cliente:

```bash
cd ~/Documents/redhat/scripts/<cliente>
echo 'export KUBECONFIG=~/.kube/<cliente>-config' > .envrc
direnv allow
# Ahora al entrar a ese directorio, cambia el contexto k8s automáticamente
```

### Clientes RedHat (directorios de trabajo)
- ~/Documents/redhat/scripts/banbif
- ~/Documents/redhat/scripts/bancofalabella
- ~/Documents/redhat/scripts/cajaarequipa
- ~/Documents/redhat/scripts/clarocl
- ~/Documents/redhat/scripts/financieraoh
- ~/Documents/redhat/scripts/gedeba
- ~/Documents/redhat/scripts/medife
- ~/Documents/redhat/scripts/pichincha
- ~/Documents/redhat/scripts/sancor
- ~/Documents/redhat/scripts/telefonicacl

## Aliases útiles configurados

### Claude Code
- `cc` - claude
- `ccc` - claude --continue
- `ccp` - claude --dangerously-skip-permissions
- `ccpc` - claude --dangerously-skip-permissions -c

### Kubernetes
- `k` - kubectl
- `kgp` - kubectl get pods
- `kgs` - kubectl get svc
- `kgn` - kubectl get nodes
- `klog` - kubectl logs -f
- `kex` - kubectl exec -it

### Navegación
- `cdwork` - ~/Documents/redhat
- `cdpersonal` - ~/Documents/personal
- `cdprojects` - ~/Documents/personal/projects
- `cdai` - ~/Documents/personal/projects/ai

## Herramientas CLI modernas
- `bat` en lugar de cat
- `eza` en lugar de ls
- `fd` en lugar de find
- `rg` (ripgrep) en lugar de grep
- `zoxide` para cd inteligente (usa `z`)
- `lazygit` para git TUI (`lg`)
- `k9s` para Kubernetes TUI
- `btop` para monitoreo

## FZF Atajos
- `Ctrl+R` - Buscar historial
- `Ctrl+T` - Buscar archivos
- `Alt+C` - Navegar directorios

## Hyprland Atajos principales
- `Super+Enter` - Terminal
- `Super+Q` - Cerrar ventana
- `Super+D` - Launcher (wofi)
- `Super+L` - Bloquear pantalla
- `Print` - Screenshot área al portapapeles
- `Super+Print` - Grabar pantalla
- `Super+.` - Emoji picker
- `Super+C` - Calculadora
- `Alt+Shift` - Cambiar idioma teclado (LATAM/US)

---

## Steel Browser (MCP Server)

### Ubicación
- **Browser:** `~/Documents/personal/projects/steel/steel-browser/`
- **MCP Server:** `~/Documents/personal/projects/steel/steel-mcp-server/`
- **Script:** `~/Documents/personal/projects/steel/run-steel-mcp.sh`

### Comandos de gestión
```bash
# Iniciar Steel Browser
cd ~/Documents/personal/projects/steel/steel-browser && podman-compose up -d

# Detener Steel Browser
cd ~/Documents/personal/projects/steel/steel-browser && podman-compose down

# Ver logs
podman-compose logs -f

# Verificar estado
curl http://localhost:3000/v1/sessions
```

### UI de Steel Browser
- **URL:** http://localhost:3001 (UI para debug de sesiones)
- **API:** http://localhost:3000

### Casos de uso para Claude Code

#### 1. Web Scraping con anti-detección
```
"Navega a [sitio] y extrae [datos] - usa Steel para evitar bloqueos"
```
Steel tiene fingerprinting que evita detección de bots.

#### 2. Automatización de formularios
```
"Llena el formulario de [sitio] con estos datos: [...]"
```
Útil para sitios que detectan Selenium/Puppeteer.

#### 3. Screenshots de sitios protegidos
```
"Toma screenshot de [sitio que bloquea bots]"
```

#### 4. Sesiones persistentes
```
"Inicia sesión en [sitio], guarda la sesión, y luego navega a [página protegida]"
```
Steel mantiene cookies/localStorage entre requests.

#### 5. Navegación con proxies
```
"Navega a [sitio] usando el proxy [ip:puerto]"
```

#### 6. Extracción de datos dinámicos
```
"Espera a que cargue [elemento JS] y extrae los datos"
```

#### 7. Monitoreo de páginas
```
"Revisa [sitio] cada X minutos y notifica si [condición]"
```

### Steel vs Playwright (ya configurado)

| Usar Steel cuando... | Usar Playwright cuando... |
|---------------------|--------------------------|
| Sitio bloquea bots | Sitio normal |
| Necesitas proxies | No necesitas proxies |
| Sesión persistente | Sesión efímera |
| Anti-fingerprinting | Velocidad importa |

### Herramientas disponibles (MCP)
- `navigate` - Ir a URL
- `screenshot` - Capturar pantalla
- `click` - Click en elemento
- `type` - Escribir texto
- `scroll` - Hacer scroll
- `wait` - Esperar elemento/tiempo
- `get_text` - Obtener texto
- `scrape` - Extraer contenido (markdown/html)
