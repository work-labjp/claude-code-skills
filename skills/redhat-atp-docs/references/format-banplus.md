# Formato Banplus — Templates AsciiDoc para ATP

Este archivo contiene los templates AsciiDoc exactos para generar ATPs.
SIEMPRE leer este archivo antes de generar cualquier ATP.

## Header del documento

```asciidoc
// ATP - Plan de Pruebas de Aceptacion
// <Producto> - <Cliente> - <Alcance>

:doctype: book
:toc: macro
:toclevels: 3
:numbered:
:chapter-label:
:icons: font
:pdf-page-size: A4
:pdf-theme: redhat
:pdf-themesdir: styles/pdf/
:pdf-fontsdir: fonts/
:imagesdir: .
:evidenciasdir: evidencias/

ifdef::backend-pdf[]
:source-highlighter: rouge
:rouge-style: github
:autofit-option:
endif::[]

include::locale/attributes-es_US.adoc[]

= Plan de Pruebas de Aceptacion (ATP): <Cliente> - <Producto> <Alcance>

<<<
toc::[]
```

## Información General

```asciidoc
<<<
== Informacion General

[cols="1,3",options="header"]
|===
| Campo | Detalle

| *Proyecto*
| <Nombre del proyecto>

| *Cliente*
| <Nombre>

| *Fecha de ejecucion*
| YYYY-MM-DD

| *Ejecutado por*
| Red Hat Consulting

| *Ambiente*
| <Produccion / Dev / QA / Contingencia>

| *Cluster*
| <nombre-cluster> - `api.<cluster>.<domain>:6443`

| *Consola Web*
| `https://console-openshift-console.apps.<cluster>.<domain>`

| *Bastion*
| <hostname> (<IP>)
|===
```

Agregar filas adicionales según contexto (VPN, proxy, etc).

## Objetivo

```asciidoc
=== Objetivo

Validar la instalacion y configuracion Day-2 del cluster OpenShift <nombre-cluster>
desplegado sobre <infraestructura> en la infraestructura de <Cliente>, verificando que todos
los componentes operan segun los requerimientos definidos en el diseno de bajo nivel (LLD).
```

## Datos del ambiente

```asciidoc
=== Datos del ambiente

[cols="1,3",options="header"]
|===
| Campo | Valor

| *Producto*
| Red Hat OpenShift Container Platform <version>

| *Infraestructura*
| <VMware / Bare Metal / Hyper-V / AWS / Azure>

| *Metodo de instalacion*
| <Agent-based / UPI / IPI>

| *SDN*
| <OVN-Kubernetes / OpenShift SDN>

| *Storage*
| <ODF / NFS / vSphere CSI / etc.>

| *Sistema Operativo*
| RHCOS <version>

| *Nodos*
| N masters, N infra, N workers + 1 bastion = N total

| *Load Balancer*
| <tipo y modelo>
|===
```

## Topología de nodos (OBLIGATORIA)

```asciidoc
=== Topologia de nodos

[cols="1,1,1,1",options="header"]
|===
| Nodo | IP | Rol | VLAN

| hostname1 | 10.0.0.1 | master-0 | VLAN X
| hostname2 | 10.0.0.2 | master-1 | VLAN X
| hostname3 | 10.0.0.3 | infra-0 | VLAN X
| hostname4 | 10.0.0.4 | worker-0 | VLAN X
|===
```

Listar TODOS los nodos del cluster con hostname, IP, rol y VLAN.

## Caso de prueba (formato obligatorio)

```asciidoc
<<<
=== N. Nombre de la Prueba

[cols="1h,3",frame=all,grid=all]
|===

| *Objetivo*
| *Descripción concisa con datos concretos del cluster.*

| *Resultado esperado*
a|
Texto introductorio que contextualiza lo que se espera:

- Punto 1 con valor concreto (ej: `13 nodos en estado Ready`)
- Punto 2 con valor concreto (ej: `Available=True`, `Progressing=False`)
- Punto 3 si aplica

| *Procedimiento*
a|
*Paso 1:* Descripción de qué hace el comando:

[source,bash]
----
oc get <recurso> -o wide
----

*Paso 2:* Descripción del siguiente paso:

[source,bash]
----
oc get <otro-recurso>
----

NOTE: Notas relevantes si aplica.

| *Observaciones*
|

| *Evidencia*
|

| *Estado*
| icon:square-o[] Aprobado  icon:square-o[] Falla


|===
```

### Reglas del caso de prueba

1. Tabla: `[cols="1h,3",frame=all,grid=all]` — SIEMPRE. `1h` = negrita columna izquierda
2. Objetivo: en **negrita** (asteriscos). Datos concretos del cluster
3. Resultado esperado: celda `a|`, texto intro + bullets con valores CONCRETOS
4. Procedimiento: celda `a|`, `*Paso N:*` + descripción + `[source,bash]` con `----`
5. Observaciones: vacío `|` (se llena durante ejecución)
6. Evidencia: vacío `|` (se llena con screenshots)
7. Estado: `icon:square-o[] Aprobado  icon:square-o[] Falla` — SIEMPRE
8. `<<<` ANTES de cada caso
9. Línea vacía antes de `|===` de cierre

### Correspondencia Procedimiento ↔ Resultado Esperado

Para CADA comando en Procedimiento, el Resultado esperado describe qué output se espera.
Valores concretos, NUNCA genéricos.

## Resumen de Resultados

```asciidoc
<<<
== Resumen de Resultados

[cols="1,8,1",options="header"]
|===
| # | Prueba | Estado

3+| *FASE 1 -- Validacion de Instalacion
| 1 | Nodos del cluster (N nodos Ready, vX.XX) | icon:square-o[]
| 2 | Cluster Operators (N/N Available) | icon:square-o[]

3+| *FASE 2 -- Validacion Day-2
| 3 | Labels, Taints y Zonas infra (N nodos) | icon:square-o[]
...
|===

*Total:* N pruebas. +
*Fecha de ejecucion:* YYYY-MM-DD.
```

Reglas:
- Columnas `[cols="1,8,1"]` — número, prueba ancha, estado
- Fases con `3+| *FASE N -- Nombre` (span 3 cols, negrita)
- Cada prueba: `| N | descripción breve (datos) | icon:square-o[]`
- Total y fecha al final con `+` para line break

## Aprobado por

```asciidoc
<<<
== Aprobado por

[cols="1,1,1",frame=none,grid=none]
|===

a|
{empty} +
{empty} +
{empty} +
{empty} +
&#95;&#95;&#95;&#95;&#95;&#95;&#95;&#95;&#95;&#95;&#95;&#95;&#95;&#95;&#95;&#95;&#95;&#95;&#95;&#95;&#95;&#95;&#95;&#95;&#95;&#95; +
<Contacto Cliente 1> +
<Cargo> +
<Cliente> +
Fecha:

a|
{empty} +
{empty} +
{empty} +
{empty} +
&#95;&#95;&#95;&#95;&#95;&#95;&#95;&#95;&#95;&#95;&#95;&#95;&#95;&#95;&#95;&#95;&#95;&#95;&#95;&#95;&#95;&#95;&#95;&#95;&#95;&#95; +
<Contacto Cliente 2> +
<Cargo> +
<Cliente> +
Fecha:

a|
{empty} +
{empty} +
{empty} +
{empty} +
&#95;&#95;&#95;&#95;&#95;&#95;&#95;&#95;&#95;&#95;&#95;&#95;&#95;&#95;&#95;&#95;&#95;&#95;&#95;&#95;&#95;&#95;&#95;&#95;&#95;&#95; +
<Consultor> +
Senior Consultant +
Red Hat Consulting +
Fecha:

|===
```

## Assets requeridos

Copiar desde CER/LLD del mismo proyecto:
```bash
cp -r ../cer/fonts/ ../cer/styles/ ../cer/locale/ .
```

**fonts/**: RedHatText-Regular.ttf, Bold.ttf, Italic.ttf, BoldItalic.ttf
**styles/pdf/redhat-theme.yml**: Font RedHatText 9pt, margins 25/15/28/15mm, dark code blocks #2D2D2D, table header #CCCCCC
**styles/pdf/**: redhatConsulting.png (title page bg), Logo-Red_Hat-Consulting-A-Standard-RGB.png (header logo)
**locale/attributes-es_US.adoc**: toc-title=Tabla de Contenido, note-caption=Nota, etc.

## Script de evidencia

Junto con el `.adoc`, SIEMPRE generar `atp-comandos-evidencia.sh`:

```bash
#!/bin/bash
run_test() { echo "================================================================================"; echo "  $1"; echo "================================================================================"; echo ""; }
run_step() { echo "  $1"; echo "  --------------------------------------------------------------------------------"; }

echo "================================================================================"
echo "  ATP <PRODUCTO> <CLIENTE> — EVIDENCIAS"
echo "  Cluster: <cluster> | Bastion: <bastion> | $(date +%Y-%m-%d)"
echo "================================================================================"
echo ""

run_test "TEST 1. Nombre de la prueba"
  run_step "Paso 1: oc get <recurso>"
  oc get <recurso> 2>&1 | sed "s/^/  /"; echo ""
# ...continua para cada test

echo "================================================================================"
echo "  FIN — N tests ejecutados"
echo "================================================================================"
```

El script DEBE:
- `run_test` + `run_step` por cada paso de cada prueba
- Exactamente los mismos comandos que el `.adoc`
- Capturar stderr con `2>&1`
- Indentar output con `sed "s/^/  /"`
- Terminar con conteo total de tests

## AsciiDoc en tablas — ERRORES a evitar

El `|` es separador de celdas. Dentro de tablas (`|===`):

1. NUNCA usar `|` literal en comandos dentro de celdas
2. Reescribir sin pipe: `oc get pods --no-headers -l app=foo` en vez de `oc get pods | grep foo`
3. Si necesitas pipe, usar celda `a|` con bloque `[source,bash]` y `----`
4. Listas numeradas + bloques de código: SIEMPRE `+` entre item y bloque
