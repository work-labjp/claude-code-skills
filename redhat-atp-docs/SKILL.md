---
name: redhat-atp-docs
description: >
  This skill should be used when the user asks to "create an ATP", "acceptance test plan",
  "plan de pruebas", "plan de aceptación", "test plan", "ATP document", "pruebas de aceptación",
  "generar ATP", "crear ATP", "documento de pruebas", "validación del cluster",
  "validar day-2", "entrega de cluster", "validar ACM", "validar AAP", "validar ACS",
  "validar Quay", "validar Service Mesh", "validar Serverless", "validar AMQ Streams",
  "validar Data Grid", "validar GitOps", or needs to create/update an Acceptance Test Plan
  for any Red Hat product delivery. Multi-product: OCP, ACM, AAP, ACS, Quay, Service Mesh,
  Serverless, AMQ Streams, Data Grid, GitOps/ArgoCD, Satellite.
  Connects to the cluster, runs verification commands, validates results, and generates
  AsciiDoc (.adoc) + evidence script (.sh) + PDF with REAL data from the cluster.
  Do NOT use for CER/engagement reports (use redhat-cer-docs).
  ATP = executable test cases with pass/fail verified on the cluster.
user-invocable: true
argument-hint: "[productos] [cluster-info]"
allowed-tools: Read Glob Grep Edit Write Bash
---

# Red Hat ATP Documentation Skill v2

Genera **Plan de Pruebas de Aceptación (ATP)** para entrega de productos Red Hat.
Se **conecta al cluster**, ejecuta los comandos, valida los resultados, y genera
el documento con **datos reales** — no placeholders.

## Filosofía: Ejecutar → Validar → Documentar

El ATP NO es un documento teórico. Este skill:

1. **Se conecta** al cluster (via `oc` directo o `ssh` al bastion)
2. **Ejecuta** cada comando de verificación del catálogo
3. **Valida** que el output coincida con el resultado esperado
4. **Documenta** con los valores reales obtenidos del cluster
5. **Genera** `.adoc` + `.sh` + PDF con datos verificados

**NUNCA** generar un ATP sin haber ejecutado los comandos en el cluster.
**NUNCA** inventar datos — solo usar lo que el cluster reporta.

---

## Conexión al cluster

### Opción A: oc directo (si hay kubeconfig local)

Verificar acceso antes de empezar:
```bash
oc whoami
oc get nodes --no-headers | head -1
```

Si funciona, ejecutar comandos directamente con `oc`.

### Opción B: via SSH al bastion

Si el cluster solo es accesible desde un bastion:
```bash
ssh <user>@<bastion-ip> "oc whoami && oc get nodes --no-headers | head -1"
```

Todos los comandos `oc` se ejecutan via `ssh <user>@<bastion> "comando"`.

### Opción C: sin acceso al cluster

Si NO hay acceso al cluster, generar el ATP con placeholders y el script `.sh`
para que el usuario ejecute los comandos manualmente. Indicar claramente que
los resultados esperados son ESTIMADOS y deben verificarse.

---

## Productos soportados

Cada producto tiene su catálogo en `references/product-<nombre>.md`.

| Producto | Referencia | Tests |
|----------|-----------|-------|
| OCP (base) | `references/product-ocp.md` | 38 |
| ACM | `references/product-acm.md` | 8 |
| AAP | `references/product-aap.md` | 9 |
| ACS | `references/product-acs.md` | 8 |
| Quay | `references/product-quay.md` | 9 |
| Service Mesh | `references/product-service-mesh.md` | 8 |
| Serverless | `references/product-serverless.md` | 5 |
| AMQ Streams | `references/product-amq-streams.md` | 10 |
| Data Grid | `references/product-data-grid.md` | 8 |
| GitOps/Tekton | `references/product-gitops.md` | 10 |

---

## Formato del documento

**SIEMPRE** leer `references/format-banplus.md` antes de generar el ATP.
Contiene templates AsciiDoc obligatorios: header, secciones, caso de prueba, resumen, firmas.

### Estructura obligatoria

1. Header AsciiDoc (doctype, toc, pdf-theme, fonts, locale)
2. Información General — tabla metadata
3. Objetivo — párrafo referenciando el LLD
4. Datos del ambiente — tabla versiones e infra
5. Topología de nodos — tabla Nodo/IP/Rol/VLAN (OBLIGATORIA)
6. Plan de Pruebas — casos por fases, numerados secuencialmente
7. Resumen de Resultados — tabla agrupada por fases con `icon:square-o[]`
8. Aprobado por — bloque de firmas (3 columnas)

### Reglas críticas

- Tabla caso prueba: `[cols="1h,3",frame=all,grid=all]`
- Campos: Objetivo → Resultado esperado → Procedimiento → Observaciones → Evidencia → Estado
- `<<<` antes de cada caso. NUNCA pipes `|` en comandos dentro de tablas.
- Resumen: `[cols="1,8,1"]`, fases con `3+| *FASE N --`, estado `icon:square-o[]`

---

## Workflow: Ejecutar → Validar → Documentar

### Paso 1: Conectar y descubrir

```
1. Verificar acceso: oc whoami && oc version
2. Descubrir topología: oc get nodes -o wide
3. Descubrir productos: oc get csv -A --no-headers
4. Descubrir versión: oc get clusterversion
```

Con estos 4 comandos se determina:
- Cuántos nodos, roles, VLANs
- Qué productos están instalados (AMQ Streams, GitOps, etc.)
- Versión exacta de OCP
- Qué pruebas aplican y cuáles no

### Paso 2: Leer catálogos aplicables

Leer `references/format-banplus.md` + `references/product-<producto>.md` para cada producto detectado.

### Paso 3: Ejecutar pruebas en el cluster

Para CADA prueba del catálogo que aplique:

1. Ejecutar el comando del catálogo en el cluster
2. Capturar el output real
3. Comparar con el resultado esperado del catálogo
4. Determinar: PASA o FALLA
5. Si un comando no muestra lo necesario, AJUSTAR el comando (agregar `-o wide`, jsonpath, etc.)

**Regla crítica**: Si el comando del catálogo no muestra los datos necesarios para
verificar el resultado esperado, el comando está MAL. Ajustarlo hasta que el output
muestre exactamente lo que se necesita validar.

Ejemplo:
- Catálogo dice: "verificar que pods están en nodos infra"
- `oc get pods -n openshift-monitoring` NO muestra en qué nodo están
- CORRECTO: `oc get pods -n openshift-monitoring -o wide` (columna NODE)

### Paso 4: Generar el ATP con datos reales

Con los datos reales del cluster:

1. **Resultado esperado**: llenar con los valores REALES obtenidos
   - No "N nodos Ready" → "13 nodos Ready"
   - No "versión correcta" → "v1.31.14 (OCP 4.18.35)"
   - No "MCP Updated" → "MCP master: 3 nodos, MCP worker: 5 nodos, MCP infra: 5 nodos"

2. **Procedimiento**: los comandos exactos que se ejecutaron (pueden diferir del catálogo si se ajustaron)

3. **Observaciones**: anotar si hubo algo inesperado o relevante

### Paso 5: Generar script de evidencia

El `atp-comandos-evidencia.sh` contiene los MISMOS comandos que el `.adoc`,
verificados contra el cluster. Es ejecutable desde el bastion.

### Paso 6: Generar PDF

Copiar assets y ejecutar `./generate-pdf`.

---

## Validación de comandos

Antes de incluir un comando en el ATP, verificar que:

1. **Ejecuta sin error** — no `error: the server doesn't have a resource type`
2. **Muestra los datos necesarios** — si el resultado esperado dice "pods en nodos infra", el comando DEBE mostrar la columna NODE (`-o wide`)
3. **No requiere pipe `|`** — para el `.adoc` usar flags del comando (`-l`, `--field-selector`, `--no-headers`, `-o jsonpath`) en vez de `| grep`. El `.sh` puede usar pipes.
4. **Es reproducible** — el mismo comando debe dar el mismo resultado cada vez

Si un comando falla o no muestra lo necesario:
- Verificar namespace correcto
- Verificar que el recurso existe (`oc api-resources | grep <recurso>`)
- Ajustar el comando y documentar el ajuste

---

## Directorio de salida

```
<directorio-atp>/
├── ATP_<Producto>_<Alcance>_<Cliente>.adoc
├── atp-comandos-evidencia.sh
├── evidencias/
├── fonts/          # Copiar de CER/LLD del proyecto
├── locale/         # Copiar de CER/LLD del proyecto
├── styles/pdf/     # Copiar desde assets del skill
└── generate-pdf    # Copiar de scripts/generate-pdf.sh
```

**Theme PDF**: Copiar desde el asset del skill (mismo theme para CER, LLD y ATP):
```bash
cp ~/.claude/skills/redhat-atp-docs/assets/styles/pdf/redhat-theme.yml <atp-dir>/styles/pdf/redhat-theme.yml
```

Contiene: base 8.5pt (texto corrido), tablas 7pt, code 6pt Courier, admoniciones 7pt, headings absolutos (h1 19, h2 15.2, h3 12.8, h4 11.4, h5 10.4, h6 10), texto justificado, fuente RedHatText.

Assets (fonts, locale, images): copiar desde CER/LLD del mismo proyecto.
PDF: `scripts/generate-pdf.sh` con `quay.io/redhat-cop/ubi8-asciidoctor:v2.2.1`.

---

## Pruebas condicionales

Después de descubrir la topología (Paso 1), OMITIR pruebas que no aplican.
Renumerar secuencialmente. NO dejar "No Ejecutado".

---

## Resumen del flujo

```
¿Hay acceso al cluster?
  ├── SÍ → Conectar → Descubrir → Ejecutar → Validar → Documentar con datos reales
  └── NO → Generar con placeholders + script .sh para ejecución manual
```
