---
name: redhat-cer-docs
description: >
  This skill should be used when the user asks to "create a CER", "engagement report",
  "consulting report", "reporte de consultoría", "informe de implementación",
  "documento de entrega", "Red Hat CER", "AsciiDoc report", "generar PDF del CER",
  or needs to fill CER sections like resumen ejecutivo, arquitectura, implementación,
  validación, recomendaciones, problemas y resoluciones. Generates Red Hat Consulting
  Engagement Reports in AsciiDoc/Spanish as TECHNICAL documents with tables, procedures,
  and concrete data. Do NOT use for ATP/acceptance test plans (use redhat-atp-docs).
  CER = technical consulting report. ATP = test cases with pass/fail.
user-invocable: true
argument-hint: "[sección] [producto]"
allowed-tools: Read Glob Grep Edit Write Bash
---

# Red Hat CER Documentation Skill

Genera **Consulting Engagement Reports (CER)** como documentos técnicos con tablas,
procedimientos, configuraciones y datos concretos. **NO es un diario de actividades.**

## Filosofía: Conectar → Extraer → Documentar

El CER se **conecta al cluster** para extraer datos reales y generar secciones técnicas
con información verificada — no placeholders.

- Tablas con datos concretos extraídos del cluster (versiones, IPs, sizing, configuraciones)
- Procedimientos paso a paso con comandos reales ejecutados
- Validaciones con estado PASS/FAIL verificadas en el cluster
- Problemas con causa raíz y resolución técnica
- Recomendaciones con justificación y referencia oficial

**NO es**: un diario, cronología, blog, ni narrativa. **Sin fechas** en el contenido técnico.

---

## Conexión al cluster

### Opción A: oc directo (kubeconfig local)
```bash
oc whoami && oc get nodes --no-headers | head -1
```

### Opción B: via SSH al bastion
```bash
ssh <user>@<bastion> "oc whoami && oc get nodes --no-headers | head -1"
```

### Opción C: sin acceso
Generar secciones con placeholders `#TODO#` para que el usuario complete manualmente.

### Qué extraer del cluster automáticamente

| Sección | Datos a extraer | Comando |
|---------|----------------|---------|
| **140 Arquitectura — Topología** | Nodos, IPs, roles, versión | `oc get nodes -o wide` |
| **140 Arquitectura — Operadores** | CSVs instalados, versiones | `oc get csv -A --no-headers` |
| **140 Arquitectura — Storage** | StorageClasses, PVCs | `oc get sc` y `oc get pv` |
| **140 Arquitectura — Networking** | SDN, IngressControllers | `oc get co network` y `oc get ingresscontroller -A` |
| **140 Arquitectura — Monitoring** | ConfigMap monitoring | `oc get cm cluster-monitoring-config -n openshift-monitoring` |
| **150 Implementación — Versión** | ClusterVersion, canal | `oc get clusterversion` |
| **150 Implementación — install-config** | Networking CIDRs | `oc get network.config cluster -o yaml` |
| **160 Validación — Nodos** | Status de nodos | `oc get nodes -o wide` |
| **160 Validación — Operators** | Estado de COs | `oc get co` |
| **160 Validación — MCP** | Estado de MCPs | `oc get mcp` |
| **160 Validación — Alertas** | Alertas activas | API Prometheus vía `oc exec` |

### Flujo de extracción

1. Verificar acceso al cluster
2. Ejecutar comandos de discovery (nodos, versión, operadores, storage, networking)
3. Con los datos reales, generar las tablas de las secciones 140, 150, 160
4. Para datos que no se pueden extraer (contexto del cliente, decisiones de diseño), usar `#TODO#`

---

## Bootstrap

```bash
git clone https://github.com/jeanlopezxyz/cer_template.git cer-<cliente>-<producto>-<año>
```

Si ya existe, leer primero: `vars/customer-vars.adoc`, `vars/redhat-vars.adoc`, y el archivo target.

---

## Reglas Críticas

- **NO modificar**: `content/aprobado-legalmente/`, `vars/render-vars.adoc`, `vars/redhat-vars.adoc`
- **Idioma**: Español (es_US), tono profesional técnico
- **Variables**: Usar `{rhocp}`, `{ocp}`, `{rhconsulting}`, `{cliente}`, `{cust}` — NUNCA nombres hardcodeados
- **Sin fechas**: NO poner fechas en secciones técnicas. Las fechas solo van en metadata (080)
- **Sin nombres de cliente**: Usar SIEMPRE `{cliente}` o `{cust}` — NUNCA el nombre real
- **Sin datos personales**: Tablas de participantes solo con Nombre / Rol / Correo corporativo. NUNCA teléfonos, celulares, extensiones, ni datos personales
- **#TODO#**: Reemplazar TODOS antes de finalizar
- **Texto justificado**: El theme PDF DEBE tener `base.text-align: justify` (no left)
- **Resumen ejecutivo conciso**: Máximo 1 página. Bullets cortos con datos técnicos, sin párrafos largos
- **Solo lo implementado por Red Hat**: El CER documenta EXCLUSIVAMENTE lo que {rhconsulting} implementó. NO incluir: aplicaciones del cliente (sizing, microservicios, nombres de producto del cliente), componentes de terceros no-Red Hat, capacidad de negocio, fases futuras. Si algo no se implementó: "No configurado" o "Fuera de alcance" — sin más
- **Theme PDF desde assets**: NO mantener el theme manualmente. Copiar el theme oficial del skill:
  ```bash
  cp ~/.claude/skills/redhat-cer-docs/assets/styles/pdf/redhat-theme.yml <cer-dir>/styles/pdf/redhat-theme.yml
  ```
  El mismo archivo se usa para CER, LLD y ATP. Contiene: base 8.5pt (texto corrido), tablas 7pt, code 6pt Courier, admoniciones 7pt, headings absolutos (h1 19, h2 15.2, h3 12.8, h4 11.4, h5 10.4, h6 10), texto justificado, fuente RedHatText, header/footer Red Hat Consulting.
- **Pipes en tablas**: NUNCA usar `|` literal en comandos dentro de tablas AsciiDoc
- **Listas + código**: SIEMPRE `+` entre item de lista y bloque `[source,bash]`

---

## Estructura del CER

```
README.adoc (master document)
├── vars/                              # Variables (cliente, producto, render)
├── locale/                            # Español es_US
├── content/
│   ├── aprobado-legalmente/           # NO TOCAR
│   ├── 000_vars.adoc                  # Bindings
│   ├── 020-070                        # Info proyecto (autor, participantes)
│   ├── 080_resumen-ejecutivo.adoc     # Resumen ejecutivo
│   ├── 090_sobre-el-cliente.adoc      # Contexto del cliente
│   ├── 100_documentos-dado-cliente.adoc  # EXCLUIR — no va en el CER
│   ├── 110_proposito-y-enfoque.adoc   # Propósito y enfoque
│   ├── 120_resumen-del-alcance.adoc   # EXCLUIR — alcance ya está en 080
│   ├── 140_architectura.adoc          # ARQUITECTURA TÉCNICA
│   ├── 150_implementacion.adoc        # PROCEDIMIENTO DE IMPLEMENTACIÓN
│   ├── 160_validacion.adoc            # VALIDACIÓN TÉCNICA
│   ├── 170_conocimiento.adoc          # Transferencia de conocimiento
│   ├── 180_problemas_resoluciones.adoc # Problemas y resoluciones
│   ├── 190_recomendaciones-tecnicales.adoc
│   ├── 200_recomendaciones-entrenamiento.adoc
│   ├── 210_otra-recomendaciones.adoc
│   └── 220-260 (apéndices opcionales)
```

**NO existe 130_diario.adoc**. El CER no es cronológico.

---

## Guía por Sección

### 080 — Resumen Ejecutivo

Estructura fija: Objetivo → Alcance (bullets) → Estado actual. Nada más.

```asciidoc
*Objetivo* — {cliente} contrató {rhconsulting} para <descripción del engagement>.

*Alcance* — <descripción breve del cluster/scope>.

* <Actividad 1 con datos concretos>
* <Actividad 2 con datos concretos>
* <Actividad 3 con datos concretos>

*Estado actual* — <estado del entregable>.
```

NO incluir: "Acciones pendientes del cliente", "Fuera de alcance", ni recomendaciones.
El resumen solo documenta lo que se hizo y el estado final. Conciso, máximo 1 página.

### 100 y 120 — EXCLUIR

- **100_documentos-dado-cliente**: NO incluir. Comentar en README.adoc.
- **120_resumen-del-alcance**: NO incluir. El alcance se documenta en el Resumen Ejecutivo (080).

Comentar en README.adoc con:
```asciidoc
// EXCLUIDO: Documentos entregados por {cust}
// include::content/100_documentos-dado-cliente.adoc[leveloffset=+3]
```

### 140 — Arquitectura (SECCIÓN PRINCIPAL)

Subsecciones (remover las que no aplican):

1. **Diagrama de alto nivel** — imagen + tabla de clústeres/ambientes
2. **Workloads** — tabla sizing: Componente / Descripción / CPU / RAM / Storage / Nodos
3. **Topología de nodos** — tabla: Nodo / IP / Rol / VLAN / vCPU / RAM
4. **Networking** — VLANs, load balancers, DNS, firewalls, puertos
5. **Storage** — StorageClasses, PVCs, backends
6. **Seguridad** — TLS, OAuth/LDAP, RBAC, SCC
7. **Monitoring y Logging** — stack, storage, alertas
8. **CI/CD** — pipelines, GitOps (si aplica)

Formato obligatorio para sizing:

```asciidoc
.Componentes — dimensionamiento
[cols="2,4,2,2,2,1",options="header"]
|===
|Componente |Descripción |CPU request |RAM request |Storage |Nodos
|*<nombre>* |<descripción técnica> |X vCPU |X GB |X GB (<tipo>) |<rol>
|===
```

Formato obligatorio para topología:

```asciidoc
.Topología de nodos
[cols="1,1,1,1,1,1",options="header"]
|===
|Nodo |IP |Rol |VLAN |vCPU |RAM
|<hostname> |<ip> |<rol> |<vlan> |<N> |<N> GB
|===
```

### 150 — Implementación (procedimiento técnico)

Estructura por fases:

1. **Fase 0 — Prerrequisitos** — tabla: # / Prerrequisito / Estado
2. **Fase 1 — Preparación** — tabla de parámetros + bloques `[source,bash]`
3. **Fase 2 — Configuración** — YAMLs documentados con `[source,yaml]`
4. **Fase 3 — Instalación** — comandos ejecutados
5. **Fase 4 — Day-2** — cada configuración con comando y verificación

Formato para prerrequisitos:

```asciidoc
.Checklist de prerequisitos
[cols="1,4,2",options="header"]
|===
|# |Prerequisito |Estado
|1 |<descripción> |[green]#Completado#
|2 |<descripción> |[green]#Completado#
|===
```

### 160 — Validación

Tablas de checklist con estado PASS/FAIL. Referencia al ATP si existe.

Formato para validaciones:

```asciidoc
.Validación post-instalación
[cols="1,4,2,1",options="header"]
|===
|# |Validación |Comando |Estado
|1 |<qué se valida> |`<comando oc>` |[green]#PASS#
|2 |<qué se valida> |`<comando oc>` |[green]#PASS#
|===
```

Para pendientes usar: `Acción requerida de {cust} — <detalle>`

Evidencias con:
```asciidoc
.Evidencia: <descripción>
image::../evidencias/<nombre>.png[width=100%,align=center]
```

### 180 — Problemas y Resoluciones

Tablas técnicas por categoría. Sin narrativa.

Formato para discrepancias:

```asciidoc
.Discrepancias documentales
[cols="1,3,3",options="header"]
|===
|ID |Problema |Resolución
|D1 |<qué se encontró> |<cómo se resolvió>
|===
```

Formato para problemas de infraestructura:

```asciidoc
.Problemas y resoluciones
[cols="2,2,3,1",options="header"]
|===
|Problema |Causa |Resolución |Estado
|<qué pasó> |<causa raíz> |<cómo se resolvió> |[green]#Resuelto#
|===
```

### 190 — Recomendaciones Técnicas

Tabla con justificación y referencia oficial.

```asciidoc
.Recomendaciones técnicas
[cols="2,4,2",options="header"]
|===
|Recomendación |Justificación |Documentación
|*<producto o acción>* |<por qué se recomienda> |<link a docs oficiales>
|===
```

---

## Variables de Producto Red Hat

| Variable | Expande a |
|----------|-----------|
| `{rh}` | Red Hat |
| `{rhconsulting}` | Red Hat Consulting |
| `{ocp}` / `{rhocp}` | OCP / Red Hat OpenShift Container Platform |
| `{rhel}` | Red Hat Enterprise Linux |
| `{rhamq}` | Red Hat AMQ Streams |
| `{rhacs}` | Red Hat Advanced Cluster Security |
| `{rhacm}` | Red Hat Advanced Cluster Management |
| `{rhodf}` | Red Hat OpenShift Data Foundation |
| `{rhaap}` | Red Hat Ansible Automation Platform |
| `{rhossm}` | Red Hat OpenShift Service Mesh |
| `{ocp_gitops}` | OCP GitOps |
| `{cliente}` / `{cust}` | Nombre del cliente (de customer-vars.adoc) |

---

## Workflow

1. **Bootstrap** — Clonar template o localizar CER existente
2. **Conectar** — Verificar acceso al cluster (`oc whoami` o SSH)
3. **Descubrir** — Extraer datos del cluster (nodos, versión, operadores, storage, networking)
4. **Variables** — Llenar `customer-vars.adoc` + `document-vars.adoc`
5. **080 Resumen** — Objetivo, alcance, estado, pendientes (conciso, máx 1 página)
6. **140 Arquitectura** — Tablas con datos reales del cluster (topología, sizing, networking, storage)
8. **150 Implementación** — Procedimiento con comandos reales ejecutados
9. **160 Validación** — Checklists PASS/FAIL verificadas en el cluster
10. **180 Problemas** — Tablas causa raíz + resolución
11. **190 Recomendaciones** — Tabla con referencia a docs oficiales
12. **Finalizar** — `grep -r "#TODO#" content/` = vacío, `:docstatus: final`, `./generate-pdf`
