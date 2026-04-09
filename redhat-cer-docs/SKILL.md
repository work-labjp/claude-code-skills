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
---

# Red Hat CER Documentation Skill

Genera **Consulting Engagement Reports (CER)** como documentos técnicos con tablas,
procedimientos, configuraciones y datos concretos. **NO es un diario de actividades.**

## Filosofía: Documento Técnico de Ejecución

El CER documenta **qué se hizo y cómo**, no cuándo:
- Tablas con datos concretos (versiones, IPs, sizing, configuraciones)
- Procedimientos paso a paso con comandos reales
- Validaciones con estado PASS/FAIL
- Problemas con causa raíz y resolución técnica
- Recomendaciones con justificación y referencia oficial

**NO es**: un diario, cronología, blog, ni narrativa. **Sin fechas** en el contenido técnico.

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
- **#TODO#**: Reemplazar TODOS antes de finalizar
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
│   ├── 100_documentos-dado-cliente.adoc
│   ├── 110_proposito-y-enfoque.adoc   # Propósito y enfoque
│   ├── 120_resumen-del-alcance.adoc   # Alcance (tabla actividades + estado)
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

Estructura fija: Objetivo → Alcance → Estado actual → Pendientes del cliente → Fuera de alcance

```asciidoc
*Objetivo* — {cliente} contrató {rhconsulting} para <descripción del engagement>.

*Alcance* — <Fase/scope>: <descripción>.

Las actividades realizadas incluyen:
* <Actividad 1 con datos concretos>
* <Actividad 2 con datos concretos>
* <Actividad 3 con datos concretos>

*Estado actual* — <estado del entregable>.

*Acciones pendientes de {cust}*
* <Acción con detalle técnico>

*Fuera de alcance*
* <Item con justificación técnica>
```

Usar bullets concretos con versiones y cantidades. Sin prosa narrativa. Sin fechas.

### 120 — Resumen del Alcance

Tabla de actividades ejecutadas con estado. Sin cronología.

```asciidoc
.Alcance del engagement
[cols="1,4,2",options="header"]
|===
|# |Actividad |Estado

|1 |<Actividad ejecutada> |[green]#Completado#
|2 |<Actividad ejecutada> |[green]#Completado#
|3 |<Actividad pendiente> |[red]#Pendiente# — <razón>
|===
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
2. **Variables** — Llenar `customer-vars.adoc` + `document-vars.adoc`
3. **080 Resumen** — Objetivo, alcance, estado, pendientes
4. **120 Alcance** — Tabla de actividades con estado
5. **140 Arquitectura** — Tablas de sizing, topología, networking, storage
6. **150 Implementación** — Procedimiento paso a paso con comandos
7. **160 Validación** — Checklists PASS/FAIL + evidencias
8. **180 Problemas** — Tablas causa raíz + resolución
9. **190 Recomendaciones** — Tabla con referencia a docs oficiales
10. **Finalizar** — `grep -r "#TODO#" content/` = vacío, `:docstatus: final`, `./generate-pdf`
