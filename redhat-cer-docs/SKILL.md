---
name: redhat-cer-docs
description: >
  This skill should be used when the user asks to "create a CER", "engagement report",
  "consulting report", "reporte de consultoría", "informe de implementación",
  "documento de entrega", "Red Hat CER", "AsciiDoc report", "generar PDF del CER",
  or needs to fill CER sections like resumen ejecutivo, arquitectura, implementación,
  diario, validación, recomendaciones, problemas y resoluciones. Generates Red Hat
  Consulting Engagement Reports in AsciiDoc/Spanish. Do NOT use for ATP/acceptance test
  plans (use redhat-atp-docs), "plan de pruebas", "pruebas de aceptación", general project
  documentation, READMEs, API docs, or non-CER Red Hat documentation.
  CER = consulting narrative. ATP = test cases with pass/fail results.
---

# Red Hat CER Documentation Skill

This skill generates Red Hat Consulting Engagement Reports (CER) using AsciiDoc format.
The CER is the primary consulting deliverable documenting architecture, implementation,
validation, knowledge transfer, and recommendations for Red Hat engagements.

## How This Skill Works

This skill is self-contained: it includes instructions AND bootstraps the full CER template
by cloning it from the official repo. No manual setup needed.

### Template Source
```
Repository: https://github.com/jeanlopezxyz/cer_template
```

### Bootstrap — New CER
When starting a new CER, clone the template first:
```bash
git clone https://github.com/jeanlopezxyz/cer_template.git cer-<customer-short>-<product>-<year>
cd cer-<customer-short>-<product>-<year>
```
Use a descriptive directory name: `cer-bnp-openshift-2026`, `cer-mpf-ansible-2026`

### Existing CER
If the user already has a CER directory, skip the clone. Before editing any file:
1. Read `README.adoc` to understand current assembly
2. Read `vars/customer-vars.adoc` to check what's filled
3. Read `vars/redhat-vars.adoc` for available product variables
4. Read the target `content/NNN_*.adoc` before overwriting it

---

## Critical Rules

### DO NOT Modify
- **Legally approved content** (`content/aprobado-legalmente/`): prefacio, soporte, subscripciones — NEVER rewrite.
- **Render variables** (`vars/render-vars.adoc`): PDF theme, fonts, icons
- **Red Hat product variables** (`vars/redhat-vars.adoc`): Use the defined abbreviations

### Language
- Default: **Spanish (es_US)** — professional, formal tone
- Locale: `locale/attributes-es_US.adoc` (or `en_US` if English requested)

### Format
- All content files: AsciiDoc (`.adoc`), numbered prefix `NNN_name.adoc` (000-260)
- Replace ALL `#TODO#` markers — none should remain in final document
- Use Red Hat product variables (e.g., `{rhocp}` not "Red Hat OpenShift Container Platform")
- ALWAYS read existing file before overwriting — preserve `////` comment blocks

### AsciiDoc inside tables — CRITICAL pipe errors

The `|` character is the cell separator in AsciiDoc tables. Inside `|===` blocks,
**NEVER** use literal `|` in any context:

1. **Inline code** (backticks) inside cells: NEVER `cmd | grep foo` — rewrite without pipe
2. **Code blocks** (`----`) inside `a|` cells: NEVER use `|` (pipe) — use command flags instead of piping to grep
3. **Free text** inside cells: NEVER write `cmd1 | cmd2` — rewrite as separate commands
4. **Multi-line scripts** (for/do/done) inside cells: Use a single representative command instead
5. Commands in tables are REFERENCE, not executable scripts. Prioritize PDF readability over completeness
6. **Numbered lists + code blocks**: When a list item (`. Step N:`) is followed by `[source,bash]`, ALWAYS add `+` on a separate line between them. Without this, AsciiDoc resets numbering to 1

---

## Template Structure

```
README.adoc (master document)
├── vars/render-vars.adoc          # PDF config (DO NOT MODIFY)
├── vars/document-vars.adoc        # Document metadata (subject, status)
├── vars/redhat-vars.adoc          # Product abbreviations (DO NOT MODIFY)
├── vars/customer-vars.adoc        # Customer info (name, contacts, GSS)
├── locale/attributes-es_US.adoc   # Spanish locale
├── content/000_vars.adoc          # Title/description bindings
├── [Prefacio — legally approved]
├── Información del Proyecto
│   ├── 020_autor.adoc / 030_propietario.adoc / 040_conveciones-documentos.adoc
│   ├── 050_copias-adicionales.adoc
│   ├── 060_participantes-red-hat.adoc   # RH team table
│   └── 070_participantes-clientes.adoc  # Customer team table
├── 080_resumen-ejecutivo.adoc      # Executive Summary
├── Visión General
│   ├── 090_sobre-el-cliente.adoc / 100_documentos-dado-cliente.adoc
│   ├── 110_proposito-y-enfoque.adoc / 120_resumen-del-alcance.adoc
├── Detalles de Implementación
│   ├── 130_diario.adoc / 140_architectura.adoc / 150_implementacion.adoc
│   ├── 160_validacion.adoc / 170_conocimiento.adoc / 180_problemas_resoluciones.adoc
├── Recomendaciones
│   ├── 190_recomendaciones-tecnicales.adoc / 200_recomendaciones-entrenamiento.adoc
│   └── 210_otra-recomendaciones.adoc
├── Appendices (OPTIONAL)
│   ├── 220_glosario.adoc / 230_apendice_adicionales.adoc / 240_enlaces-aplicable.adoc
│   ├── 250_declaracion-de-trabajo.adoc / 260_revisiones.adoc
├── [Subscripciones — legally approved]
└── [Soporte — legally approved]
```

---

## Section-by-Section Writing Guide

### customer-vars.adoc
```asciidoc
:description: Implementación de OpenShift Container Platform 4.x
:customer: Banco Nacional del Perú
:cust: BNP
:customerlogo: empty
:custprojectmanager: María García
:custgss: bnp-admin
:nogss: 12345678
```

### document-vars.adoc — `:docstatus:`
- `draft` — watermark, active work
- `in-progress` — no watermark, under review
- `final` — delivered to customer

### 080_resumen-ejecutivo.adoc
Structure: (1) Why RH was there, (2) What RH did + scope, (3) Obstacles, (4) KT, (5) Next steps
```asciidoc
{cliente} contrató los servicios de {rhconsulting} para asistirlo con la implementación
de {rhocp} 4.14 en su infraestructura on-premise. Se desplegaron tres clústeres de {ocp}
para Desarrollo, QA y Producción, con integración a {rhacs} y {rhossm}. Se realizaron
cuatro sesiones de transferencia de conocimiento. Como próximo paso, se recomienda {rhaap}
para automatizar Day-2 operations.
```

### 120_resumen-del-alcance.adoc — Sprint table
```asciidoc
.Resumen del alcance del proyecto
[cols=3*,cols="1,2,5",options="header"]
|===
| Sprint | Semana | Objetivos
.2+|1
|Feb 5 - 9
a|
- Revisión de arquitectura
- Preparación de infraestructura
|Feb 12 - 16
a|
- Despliegue de {ocp} en desarrollo
- Integración LDAP
|===
```

### 130_diario.adoc — Verbs: `iniciado` / `en progreso` / `completado` / `detectado` / `en curso` / `resuelto`
```asciidoc
[cols="1,5,5",options=header]
|===
|Fecha |Actividades |Obstáculos
| 02/05/2025
a|
- Revisión de arquitectura — completado
- Configuración de red — iniciado
a|
- Acceso VPN pendiente — detectado
|===
```

### 140_architectura.adoc — Subsections (remove if N/A)
```
= Diagrama de alto nivel
= Configuración del entorno
= Integración continua/Entrega continua
= Estrategia de calidad del servicio (HA, Failover, DR)
= Acuerdos de Nivel de Servicio y volumetría
= Solución de Logging y Monitoring
= Consideraciones de Seguridad
```

### 180_problemas_resoluciones.adoc — Per challenge
```asciidoc
= Nombre del desafío
== Desafío       // what happened, impact, cause
== Resolución inmediata   // workaround, tickets
== Recomendación para el futuro   // permanent fix
```

### 190_recomendaciones-tecnicales.adoc — Per recommendation
```asciidoc
== Nombre de la recomendación
=== Indicación       // what was observed
=== Recomendación    // what RH recommends + doc links
```

### 200_recomendaciones-entrenamiento.adoc — Uncomment relevant courses
- **Platform**: rh124, rh134, rh199, rh294, rh342, rh358, rh403, rh415
- **OpenShift**: do180, do188, do280, do288, do322, do370, do380, do480
- **Ansible**: do007, do457, do458
- **App Dev**: ad082, ad141, ad183, ad221, ad248, ad482, ad483
- **AI/ML**: ai067, ai252, ai253, ai267, ai296, ai500

---

## Red Hat Product Variables

| Variable | Expands To |
|----------|-----------|
| `{rh}` | Red Hat |
| `{rhconsulting}` | Red Hat Consulting |
| `{rhel}` | Red Hat Enterprise Linux |
| `{ocp}` / `{rhocp}` | OpenShift Container Platform / Red Hat OCP |
| `{aap}` / `{rhaap}` | Ansible Automation Platform / Red Hat AAP |
| `{rhacs}` | Red Hat Advanced Cluster Security |
| `{rhacm}` | Red Hat Advanced Cluster Management |
| `{rhodf}` | Red Hat OpenShift Data Foundation |
| `{rhossm}` | Red Hat OpenShift Service Mesh |
| `{rhoss}` | Red Hat OpenShift Serverless |
| `{rhsat}` | Red Hat Satellite |
| `{rhidm}` | Red Hat Identity Management |
| `{rhbk}` | Red Hat build of Keycloak |
| `{rhbq}` | Red Hat build of Quarkus |
| `{rhoai}` / `{rhoaifull}` | RHOAI / Red Hat OpenShift AI |
| `{ctlr}` / `{hub}` / `{mesh}` | Automation Controller / Hub / Mesh |
| `{ocp_gitops}` | OCP GitOps |
| `{pb}` / `{vm}` | Ansible Playbook / Virtual Machine |

---

## Flexible Section Management

Comment blocks in `README.adoc` to exclude optional sections:
```asciidoc
// EXCLUDED:
// <<<
// [appendix]
// == Enlaces aplicables
// include::content/240_enlaces-aplicable.adoc[leveloffset=+2]
```

| Section | Exclude When |
|---------|-------------|
| 100_documentos-dado-cliente | Customer provided no docs |
| CI/CD in 140 | No pipeline implemented |
| HA/Failover/DR in 140 | Single-environment engagement |
| 210_otra-recomendaciones | No non-technical recs |
| 230-250 appendices | Not needed for this engagement |
| subscripciones / soporte | Customer already knows these |

---

## Workflow

**Step 0 — Bootstrap**: `git clone https://github.com/jeanlopezxyz/cer_template.git cer-<cust>-<product>-<year>`
**Step 1 — Gather**: customer name, description, products, duration, teams
**Step 2 — Variables**: fill `customer-vars.adoc` + `document-vars.adoc`
**Step 3 — Core**: 080 → 090 → 110 → 120 → 130 → 140 → 150 → 160 → 170
**Step 4 — Support**: 180 → 190 → 200 (uncomment training) → 210 → 220
**Step 5 — Appendices**: include/exclude with user
**Step 6 — Finalize**: `grep -r "#TODO#" content/` must return empty, set `:docstatus: final`, run `./generate-pdf`

---

## AsciiDoc Quick Reference
```asciidoc
// Tables
[cols="3,5,2",options=header]
|===
|H1 |H2 |H3
|C  |C  |C
|===

// Code             // Admonitions           // Images
[source,bash]       NOTE: Info.              image::file.png[Desc,align=center]
----                TIP: Tip.
oc get pods         WARNING: Warning.        // Cross-ref
----                IMPORTANT: Critical.     <<participants,Ver Participantes>>

// Page break: <<<
```

## PDF Generation
```bash
./generate-pdf
# Or: podman run --rm -v $(pwd):/documents:Z quay.io/redhat-cop/ubi8-asciidoctor:v2.2.1 asciidoctor-pdf README.adoc -o output.pdf
```
