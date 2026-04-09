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

## Filosofía: Documento Técnico, No Narrativo

El CER es un **reporte técnico de implementación**:
- Tablas con datos concretos (versiones, IPs, sizing, configuraciones)
- Procedimientos paso a paso con comandos y outputs
- Arquitectura documentada con diagramas y decisiones técnicas
- Problemas con causa raíz y resolución técnica
- Recomendaciones con justificación y referencia oficial

**NO es**: un diario, un blog, una narrativa cronológica, ni prosa descriptiva.

---

## Bootstrap

### Nuevo CER
```bash
git clone https://github.com/jeanlopezxyz/cer_template.git cer-<cliente>-<producto>-<año>
```

### CER existente
Antes de editar, leer: `vars/customer-vars.adoc`, `vars/redhat-vars.adoc`, y el archivo target.

---

## Reglas Críticas

- **NO modificar**: `content/aprobado-legalmente/`, `vars/render-vars.adoc`, `vars/redhat-vars.adoc`
- **Idioma**: Español (es_US), tono profesional técnico
- **Variables**: Usar `{rhocp}`, `{ocp}`, `{rhconsulting}`, etc. — no escribir nombres completos
- **#TODO#**: Reemplazar TODOS antes de finalizar
- **Pipes en tablas**: NUNCA usar `|` literal en comandos dentro de tablas AsciiDoc
- **Listas + código**: SIEMPRE `+` entre item de lista y bloque `[source,bash]`

---

## Estructura del CER (documento técnico)

```
README.adoc (master document)
├── vars/                              # Variables (cliente, producto, render)
├── locale/                            # Español es_US
├── content/
│   ├── aprobado-legalmente/           # NO TOCAR
│   ├── 000_vars.adoc                  # Bindings
│   ├── 020-070                        # Info proyecto (autor, participantes)
│   │
│   ├── 080_resumen-ejecutivo.adoc     # Resumen ejecutivo
│   ├── 090_sobre-el-cliente.adoc      # Contexto del cliente
│   ├── 100_documentos-dado-cliente.adoc
│   ├── 110_proposito-y-enfoque.adoc   # Propósito y enfoque
│   ├── 120_resumen-del-alcance.adoc   # Alcance (tabla actividades + estado)
│   │
│   ├── 140_architectura.adoc          # ARQUITECTURA TÉCNICA
│   ├── 150_implementacion.adoc        # PROCEDIMIENTO DE IMPLEMENTACIÓN
│   ├── 160_validacion.adoc            # VALIDACIÓN TÉCNICA
│   ├── 170_conocimiento.adoc          # Transferencia de conocimiento
│   ├── 180_problemas_resoluciones.adoc # Problemas y resoluciones
│   │
│   ├── 190_recomendaciones-tecnicales.adoc
│   ├── 200_recomendaciones-entrenamiento.adoc
│   ├── 210_otra-recomendaciones.adoc
│   └── 220-260 (apéndices opcionales)
```

**NOTA**: NO existe `130_diario.adoc`. El CER no es un diario cronológico.
El alcance se documenta en `120_resumen-del-alcance.adoc` (tabla de sprints).

---

## Guía por Sección

### 080 — Resumen Ejecutivo

Estructura: Objetivo → Alcance (bullets técnicos) → Estado actual → Acciones pendientes del cliente → Fuera de alcance

```asciidoc
*Objetivo* — {cliente} contrató {rhconsulting} para la implementación de {rhocp} 4.18...

*Alcance* — Fase 1: despliegue del clúster {ocp} para Dev y QA.

Las actividades realizadas incluyen:
* Instalación del clúster con N nodos: N masters, N infra, N workers
* Configuraciones Day-2: labels, taints, MCP, ingress, monitoring, LDAP...
* Instalación de operadores: {rhamq}, ArgoCD, Tekton...

*Estado actual* — Clúster *operativo*, N nodos `Ready`.

*Acciones pendientes de {cust}*
* Acción 1 con detalle técnico
* Acción 2 con detalle técnico

*Fuera de alcance de Fase N*
* Item con justificación técnica
```

**NO**: prosa narrativa. **SÍ**: bullets concretos con versiones, cantidades, nombres técnicos.

### 120 — Resumen del Alcance

Lista de actividades ejecutadas con estado. Sin formato de sprints ni cronológico.

```asciidoc
.Alcance del engagement
[cols="1,4,2",options="header"]
|===
|# |Actividad |Estado

|1
|Instalación del clúster {ocp} 4.18 (Agent-based Installer, 13 nodos)
|[green]#Completado#

|2
|Configuraciones Day-2 (infra nodes, ingress, monitoring, LDAP, NTP, backup)
|[green]#Completado#

|3
|Instalación de operadores ({rhamq}, ArgoCD, Tekton, Apicurio)
|[green]#Completado#

|4
|Transferencia de conocimiento (4 sesiones)
|[green]#Completado#

|5
|Logging centralizado (LokiStack + Vector)
|[red]#Pendiente# — requiere backend S3
|===
```

### 140 — Arquitectura (SECCIÓN PRINCIPAL TÉCNICA)

Subsecciones (remover las que no aplican):

1. **Diagrama de alto nivel** — imagen + tabla de clústeres
2. **Workloads sobre {ocp}** — tabla con cada operador/componente: descripción, CPU, RAM, storage, nodos
3. **Topología de nodos** — tabla Nodo/IP/Rol/VLAN/vCPU/RAM
4. **Networking** — VLANs, load balancers, DNS, firewalls, puertos
5. **Storage** — StorageClasses, PVCs, NFS/ODF/LSO
6. **Seguridad** — TLS, OAuth/LDAP, RBAC, SCC
7. **Monitoring y Logging** — stack, PVCs, alertas
8. **CI/CD** — pipelines, GitOps (si aplica)

**Formato**: SIEMPRE tablas con datos concretos. Ejemplo:

```asciidoc
.Operadores {rh} — dimensionamiento
[cols="2,4,1,1,2,2,2,1",options="header"]
|===
|Componente |Descripción |Dev |QA |CPU request |RAM request |Storage |Nodos
|*{rhamq} (Kafka)*
|3 brokers KRaft mode, retención 7 días
|SI |SI |3.7 vCPU |6.9 GB |15 GB (LSO) |Workers
|===
```

### 150 — Implementación (procedimiento técnico)

Estructura por fases con tablas de prerrequisitos y pasos:

1. **Fase 0 — Prerrequisitos** — tabla con # / Prerrequisito / Estado (`[green]#Completado#`)
2. **Fase 1 — Preparación del bastion** — tabla de parámetros + comandos
3. **Fase 2 — Generación del ISO** — install-config.yaml + agent-config.yaml
4. **Fase 3 — Instalación** — boot, wait-for, approve CSRs
5. **Fase 4 — Day-2** — cada configuración con comando y verificación

**Formato**: Procedimiento paso a paso con `[source,bash]` y outputs esperados.

### 160 — Validación

Resumen de las pruebas ejecutadas. Referencia al ATP si existe.

```asciidoc
Se ejecutaron N pruebas de aceptación cubriendo:
* Instalación: nodos, operators, etcd, MCP
* Day-2: infra nodes, ingress, monitoring, LDAP, backup
* Networking: DNS, multi-VLAN, OVN-Kubernetes
* Operadores: AMQ Streams, ArgoCD, Tekton

Resultado: todas las pruebas ejecutadas satisfactoriamente.
Ver documento ATP adjunto para detalle completo.
```

### 180 — Problemas y Resoluciones

Por CADA problema, estructura técnica:

```asciidoc
= Nombre del problema
== Desafío
Descripción técnica: qué ocurrió, impacto, causa raíz.
== Resolución
Pasos técnicos ejecutados para resolver. Comandos, configs, tickets.
== Recomendación
Fix permanente para evitar recurrencia.
```

### 190 — Recomendaciones Técnicas

Por CADA recomendación:

```asciidoc
== Nombre de la recomendación
=== Indicación
Qué se observó durante el engagement.
=== Recomendación
Qué recomienda {rhconsulting}. Incluir referencia a docs oficiales.
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
7. **160 Validación** — Resumen + referencia al ATP
8. **180 Problemas** — Causa raíz + resolución técnica
9. **190 Recomendaciones** — Con referencia a docs oficiales
10. **Finalizar** — `grep -r "#TODO#" content/` = vacío, `:docstatus: final`, `./generate-pdf`
