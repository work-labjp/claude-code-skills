---
name: redhat-drawio-diagrams
description: >
  This skill should be used when the user asks to "draw.io diagram", "OCP diagram",
  "OpenShift diagram", "diagrama de arquitectura OCP", "topologia del cluster",
  "network diagram", "diagrama de red", "diagrama de nodos", "cluster topology",
  "generar drawio", "diagrama de infraestructura", or needs to generate draw.io XML
  files for Red Hat OpenShift architecture diagrams using official Red Hat brand icons
  and colors. PRIORITY RULE: If the request mentions Red Hat, OpenShift, cluster, nodes,
  topology, VLANs, infrastructure, or network architecture -> use THIS skill.
  Do NOT use for Mermaid diagrams (use beautiful-mermaid), flowcharts, sequence diagrams,
  class diagrams, ER diagrams, component-level software architecture, or non-Red Hat diagrams.
---

# Red Hat draw.io Architecture Diagrams

Genera diagramas de arquitectura en formato `.drawio` (XML) usando iconos y colores
oficiales de Red Hat. Los archivos se abren en VS Code (extension draw.io) o en
app.diagrams.net.

## Cuando usar este Skill

- Diagramas de topologia de cluster OCP (nodos, roles, VLANs)
- Diagramas de red (overlay, ingress, DMZ, F5)
- Diagramas de storage (ODF/Ceph, PVs)
- Arquitectura multi-cluster (ACM, PRD, DEV, CNT)
- Flujo de trafico (F5 -> IngressController -> pods)

## Fuente de Assets

- **Iconos SVG**: `@rhds/icons` -- https://github.com/RedHat-UX/red-hat-icons
- **Colores**: `@rhds/tokens` -- https://github.com/RedHat-UX/red-hat-design-tokens
- **Referencia visual**: https://red-hat-icons.netlify.app

---

## CRITICAL: Z-Order Rule

**Containers MUST be defined BEFORE nodes in the XML.** draw.io renders elements in
document order. If a container (VLAN box, DMZ box) is defined after the nodes it
contains, it will draw ON TOP and hide all nodes inside it.

Correct order in `<root>`:
1. `<mxCell id="0"/>` and `<mxCell id="1" parent="0"/>`
2. Container backgrounds: VLAN Interna, VLAN DMZ
3. Left panel containers: VMware box, Servicios Externos box
4. Detail cells inside containers (vCenter info, NTP, DNS, etc.)
5. Bastion, Legend box, legend items
6. F5 bar, cluster title bar
7. **Nodes** (masters, infra, storage, workers, DMZ nodes)
8. Row labels (right-side text labels)
9. Info bars (Day-2, StorageClasses, IngressController)
10. Firewall bar (between VLAN Interna and DMZ)

**Rule: background/container elements first, then content on top.**

---

## Paleta de Colores Final

### CRITICAL: NO BORDERS rule

Use `strokeColor=none` on ALL elements EXCEPT the firewall bar. No element should
have a visible border/stroke except the firewall warning bar.

### Colores por componente

| Componente | Fill | Text/Font Color | Notes |
|------------|------|-----------------|-------|
| F5 BIG-IP | `#003B5C` | `#FFFFFF` | Official F5 dark blue |
| VMware box | `#717074` | `#FFFFFF` | Official VMware gray |
| OpenShift title bar | `#EE0000` | `#FFFFFF` | Red Hat red |
| VLAN Interna bg | `#F0F0F0` | default | No border |
| VLAN DMZ bg | `#DAEAF8` | default | No border |
| Servicios Externos bg | `#EAEAEA` | default | No border |
| Bastion | `#D8D8D8` | default | No border |
| Firewall bar | `#FCDEDE` | `#A60000` | **ONLY element with border**: `strokeColor=#EE0000;strokeWidth=2` |
| NTP blocked | `#FCDEDE` | `#A60000` | Warning color, bold text |
| Internet/allowlist | `#D4EDFC` | default | Light blue info |

### Colores por rol de nodo OCP

| Rol | Fill Hex | strokeColor |
|-----|----------|-------------|
| Master/Control Plane | `#FCDEDE` | `none` |
| Infra | `#D4EDFC` | `none` |
| Storage | `#E8D5F5` | `none` |
| Worker | `#D5EDDB` | `none` |
| Infra DMZ | `#C9E0F5` | `none` |
| Worker DMZ | `#D5EDDB` | `none` (same as Worker) |
| Bastion | `#D8D8D8` | `none` |

### Colores para labels de fila (right-side text)

| Rol | fontColor |
|-----|-----------|
| Control Plane | `#A60000` |
| Infra | `#004D99` |
| Storage | `#6753AC` |
| Worker | `#3E8635` |
| IngressController DMZ | `#0066CC` |

---

## Layout Structure

The diagram uses a two-panel layout:

### LEFT PANEL (x=10, w=180)

From top to bottom:
1. **Infraestructura VMware** -- gray box with vCenter details, ESXi hosts, datastores
2. **Servicios Externos** -- external services ONLY:
   - NTP servers (with blocked warning if applicable)
   - DNS servers
   - Gateway IPs (internal + DMZ)
   - AD/LDAP
   - Internet allowlist
3. **Bastion** -- single node box
4. **Legend** -- color-coded pairs

**What does NOT go in Servicios Externos:**
- chrony MachineConfig details (goes in Day-2 info bar)
- Wildcard certificate details (goes in Day-2 info bar)
- IngressController config (goes in IC info bar)
- StorageClass details (goes in SC info bar)

### RIGHT PANEL (x=200, w=760+)

From top to bottom:
1. **F5 BIG-IP** bar -- entry point of traffic (MUST be at TOP, represents hierarchy)
2. **Cluster title** bar -- red background, cluster FQDN + OCP version + SDN + environment
3. **VLAN Interna** container -- contains:
   - Masters row (3 columns)
   - Infra row (3 columns)
   - Storage row (3 columns)
   - Workers row (variable columns)
   - Day-2 info bar (dashed border)
   - StorageClasses info bar
   - IngressController info bar
4. **Firewall bar** -- warning about Geneve/inter-VLAN restrictions
5. **VLAN DMZ** container -- contains:
   - Infra DMZ row (separate from Workers)
   - Worker DMZ row (on its own row below Infra DMZ)

### Node layout details

- Nodes arranged in **3 columns** with consistent spacing
- Column positions: x=220, x=400, x=580 (gap of 180px between starts)
- **Row labels** on the right side (x=760) describing the role
- **Worker DMZ on separate row** from Infra DMZ (different purpose/role)
- VMware is a **small box on the left** panel, NOT a container wrapping the cluster

---

## Node Formatting Rules

1. **Uniform sizing**: All nodes must have the same width (**160px**) and similar height (24-34px)
2. **HTML bold hostnames**: Node values use `<b>hostname</b>` for the hostname:
   ```
   value="&lt;b&gt;ctmast1001&lt;/b&gt;&#10;10.60.8.140&#10;control-plane &#8212; 4vCPU/16GB"
   ```
3. **Node content** (3 lines): hostname (bold), IP, role + resources
4. **strokeColor=none** on all nodes
5. **fontSize=6**, fontFamily=Red Hat Text, align=center
6. **rounded=0** (sharp corners, not rounded)

---

## Legend Layout

Legend uses paired columns that semantically match:

| Left column (x=15, w=82) | Right column (x=105, w=82) |
|---------------------------|----------------------------|
| Master | Storage |
| Infra | Infra DMZ |
| Worker | Worker DMZ |
| Bastion/Ext | Bloqueado (warning) |

Bottom of legend: node count summary (e.g., "13 nodos: 3M+3I+3S+1W+2I-DMZ+1W-DMZ")

---

## Iconos SVG de Red Hat para draw.io

**IMPORTANT: draw.io desktop does NOT render inline SVG icons** (neither base64,
URL-encoded, nor local file paths). Colors are the PRIMARY visual identification
method. Do not rely on SVG icons for distinguishing node types.

SVGs are available in `references/icons/` for manual use (drag & drop in draw.io)
or for other formats (web, Figma, presentations).

### Iconos principales para OCP

| Icono | Archivo SVG | Uso |
|-------|-------------|-----|
| Kubernetes Pod | `kubernetes-pod.svg` | Pods |
| Cluster | `cluster.svg` | Cluster OCP |
| Container | `container.svg` | Contenedores |
| Container Registry | `container-registry.svg` | Image Registry |
| Server | `server.svg` | Nodo generico |
| Server Stack | `server-stack.svg` | Grupo de nodos |
| Virtual Server | `virtual-server.svg` | VM |
| Storage | `storage.svg` | Storage generico |
| Storage Classes | `storage-classes.svg` | StorageClasses |
| Cloud | `cloud.svg` | Cloud/externo |
| Router LB | `router-load-balancer.svg` | F5/HAProxy |
| Platform | `platform.svg` | Plataforma OCP |
| Firewall | `firewall-a.svg` | Firewall |
| Shield | `shield.svg` | Seguridad |
| Network | `network-automation.svg` | Red |
| App | `app.svg` | Aplicacion |
| Padlock | `padlock-locked.svg` | TLS/Certs |

### Ubicacion de SVGs
Si se clono el repo: `/tmp/red-hat-icons/src/standard/<icon>.svg`
O descargar de: `https://raw.githubusercontent.com/RedHat-UX/red-hat-icons/main/src/standard/<icon>.svg`

---

## Estructura de un archivo .drawio

```xml
<mxfile host="app.diagrams.net" type="device">
  <diagram id="id1" name="Nombre del diagrama">
    <mxGraphModel dx="980" dy="410" grid="1" gridSize="5" guides="1"
                  tooltips="1" connect="1" arrows="1" fold="1" page="1"
                  pageScale="1" pageWidth="980" pageHeight="410" math="0"
                  shadow="0">
      <root>
        <mxCell id="0"/>
        <mxCell id="1" parent="0"/>

        <!-- 1. CONTAINERS FIRST (z-order) -->
        <mxCell id="vlan" value="VLAN Interna ..." style="...fillColor=#F0F0F0;strokeColor=none;..." />
        <mxCell id="dmz" value="VLAN DMZ ..." style="...fillColor=#DAEAF8;strokeColor=none;..." />

        <!-- 2. LEFT PANEL -->
        <mxCell id="vmw" ... />  <!-- VMware box -->
        <mxCell id="ext" ... />  <!-- Servicios Externos -->
        <mxCell id="bast" ... /> <!-- Bastion -->
        <mxCell id="leg" ... />  <!-- Legend -->

        <!-- 3. RIGHT PANEL header -->
        <mxCell id="f5" ... />     <!-- F5 bar -->
        <mxCell id="title" ... />  <!-- Cluster title -->

        <!-- 4. NODES (on top of containers) -->
        <mxCell id="m1" ... />  <!-- Masters -->
        <mxCell id="i1" ... />  <!-- Infra -->
        <mxCell id="s1" ... />  <!-- Storage -->
        <mxCell id="w1" ... />  <!-- Workers -->
        <mxCell id="d4" ... />  <!-- Infra DMZ -->
        <mxCell id="dw" ... />  <!-- Worker DMZ -->

        <!-- 5. INFO BARS -->
        <mxCell id="day2" ... />
        <mxCell id="sc" ... />
        <mxCell id="ic" ... />
        <mxCell id="fw" ... />  <!-- Firewall bar -->

      </root>
    </mxGraphModel>
  </diagram>
</mxfile>
```

### Estilos de celdas comunes

#### Container de zona (VLAN, no border)
```
style="rounded=0;html=1;fillColor=#F0F0F0;strokeColor=none;fontSize=7;
       fontFamily=Red Hat Display;verticalAlign=top;fontStyle=1;spacingTop=4;"
```

#### Nodo (server/VM, no border)
```
style="rounded=0;html=1;fillColor=#FCDEDE;strokeColor=none;fontSize=6;
       fontFamily=Red Hat Text;align=center;"
```

#### F5 bar
```
style="rounded=0;html=1;fillColor=#003B5C;strokeColor=none;fontSize=7;
       fontFamily=Red Hat Text;align=center;fontStyle=1;fontColor=#FFFFFF;"
```

#### Cluster title bar
```
style="text;html=1;fillColor=#EE0000;fontColor=#FFFFFF;align=center;
       verticalAlign=middle;rounded=0;fontSize=8;fontFamily=Red Hat Display;fontStyle=1;"
```

#### Firewall bar (ONLY element with visible border)
```
style="rounded=0;html=1;fillColor=#FCDEDE;strokeColor=#EE0000;strokeWidth=2;
       fontSize=6;fontFamily=Red Hat Display;fontStyle=1;fontColor=#A60000;align=center;"
```

#### Row label (right side)
```
style="text;html=1;fontSize=8;fontFamily=Red Hat Display;fontStyle=1;
       fontColor=#A60000;align=left;"
```

#### Day-2 info bar (dashed)
```
style="rounded=0;html=1;fillColor=#FFFFFF;strokeColor=#D2D2D2;strokeWidth=1;
       dashed=1;dashPattern=4 4;fontSize=5;fontFamily=Red Hat Text;align=center;"
```

#### Flecha de conexion
```
style="edgeStyle=orthogonalEdgeStyle;rounded=1;orthogonalLoop=1;jettySize=auto;
       html=1;strokeColor=#6A6E73;strokeWidth=1;fontSize=10;fontFamily=Red Hat Text;"
```

---

## Programmatic Generation

For diagrams with many nodes, **use a Python script** to calculate positions
mathematically instead of hand-coding XML coordinates. This avoids manual
positioning errors and ensures consistent spacing.

### Recommended pattern

```python
#!/usr/bin/env python3
"""Generate draw.io XML for OCP cluster topology."""

# Layout constants
LEFT_X = 10
LEFT_W = 180
RIGHT_X = 200
RIGHT_W = 760
NODE_W = 160
COL_GAP = 180  # distance between column start positions
COLS = [220, 400, 580]  # x positions for 3-column layout
LABEL_X = 760  # x position for row labels

# Row heights
ROW_H_MASTER = 32
ROW_H_NORMAL = 28
ROW_H_COMPACT = 24
ROW_GAP = 10

def node_cell(id, hostname, ip, role_desc, fill, x, y, h=28):
    """Generate XML for a single node."""
    return (
        f'<mxCell id="{id}" '
        f'value="&lt;b&gt;{hostname}&lt;/b&gt;&#10;{ip}&#10;{role_desc}" '
        f'style="rounded=0;html=1;fillColor={fill};strokeColor=none;'
        f'fontSize=6;fontFamily=Red Hat Text;align=center;" '
        f'vertex="1" parent="1">'
        f'<mxGeometry x="{x}" y="{y}" width="{NODE_W}" height="{h}" '
        f'as="geometry" /></mxCell>'
    )

# Calculate Y positions incrementally
y = 10  # Start
f5_y = y; y += 34
title_y = y; y += 20
vlan_y = y
# ... continue calculating positions
```

### Benefits
- Consistent spacing across all clusters (CNT, PRD, DEV, ACM)
- Easy to adjust when node counts differ between environments
- No manual pixel-counting errors
- Can parameterize per-cluster data (hostnames, IPs, resource specs)

---

## Templates de Diagramas

### Template 1: Topologia de Cluster OCP (recommended layout)

```
LEFT PANEL                    RIGHT PANEL
+------------------+  +------------------------------------------------+
| Infra VMware     |  | F5 BIG-IP -- Load Balancer Externo             |
| vCenter, ESXi,   |  +------------------------------------------------+
| Datastores       |  | Cluster FQDN -- OCP 4.20 -- OVN-K -- ENV       |
+------------------+  +------------------------------------------------+
| Servicios Ext.   |  | VLAN Interna -- subnet -- VLAN ID              |
| NTP (blocked!)   |  |  [Master1]    [Master2]    [Master3]   label   |
| DNS              |  |  [Infra1]     [Infra2]     [Infra3]    label   |
| GW               |  |  [Stor1]      [Stor2]      [Stor3]     label   |
| AD/LDAP          |  |  [Worker1]    [Worker2]                label   |
| Internet         |  |  Day-2 config info bar                         |
+------------------+  |  StorageClasses info bar                       |
| Bastion          |  |  IngressController info bar                    |
+------------------+  +------------------------------------------------+
| Legend            |  | FIREWALL WARNING BAR                           |
| Master | Storage  |  +------------------------------------------------+
| Infra  | InfDMZ   |  | VLAN DMZ -- subnet -- VLAN ID                 |
| Worker | WrkDMZ   |  |  [InfraDMZ1]  [InfraDMZ2]             label   |
| Bast   | Blocked  |  |  [WorkerDMZ1]                          label   |
| node count        |  +------------------------------------------------+
+------------------+
```

### Template 2: Flujo de Trafico Ingress

```
[Usuario] -> [F5 VIP .155] -> [IngressController PROD]
                                  |-> [Router Pod infr1001]
                                  |-> [Router Pod infr1002]
                                  |-> [Router Pod infr1003]
                                       |
                              [Service ClusterIP]
                                       |
                              [Pod Aplicacion]

[Usuario DMZ] -> [F5 VIP DMZ] -> [IngressController DMZ]
                                     |-> [Router Pod infr1004]
                                     |-> [Router Pod infr1005]
```

### Template 3: Arquitectura ODF/Storage

```
+-- ODF Cluster ---------------------+
|  [Mon a]  [Mon b]  [Mon c]        |
|  [OSD 0]  [OSD 1]  [OSD 2]        |
|  [MDS]    [MGR]    [RGW]           |
|  [NooBaa Core]  [NooBaa Operator]  |
+------------------------------------|
     |            |           |
[SC: cephfs] [SC: rbd]  [SC: noobaa]
     |            |           |
  [PVC RWX]   [PVC RWO]   [OBC S3]
```

### Template 4: Multi-Cluster (ACM Hub + Spokes)

```
         [ACM Hub]
        /    |    \
       /     |     \
[PRD]    [DEV]    [CNT]
```

---

## Workflow

1. **Gather** -- preguntar: que cluster, que tipo de diagrama, que incluir
2. **Read context** -- leer datos confirmados del cluster (IPs, hostnames, resources)
3. **Generate** -- crear el XML `.drawio` respetando z-order y layout rules
4. **Apply colors** -- usar paleta oficial por rol de nodo (NO borders except firewall)
5. **Verify** -- validar que containers come before nodes in XML order
6. **Save** -- guardar como `<nombre>.drawio` junto a la documentacion
7. **Open** -- `xdg-open <archivo>.drawio` o abrir en VS Code

---

## Reglas

1. **Z-ORDER**: Containers (VLAN, DMZ backgrounds) MUST be defined BEFORE nodes in the XML
2. **NO BORDERS**: Use `strokeColor=none` on everything EXCEPT the firewall bar
3. **Uniform node size**: All nodes = 160px width, 24-34px height
4. **HTML bold hostnames**: Use `<b>hostname</b>` in node value attributes
5. **Colors = identity**: Colors are the PRIMARY way to identify node roles (SVG icons don't render in draw.io desktop)
6. Usar SIEMPRE los colores de la paleta final (no inventar colores)
7. Font family: `Red Hat Display` for titles, `Red Hat Text` for content
8. Los nodos deben mostrar: hostname (bold), IP, role + resources
9. Las zonas de red deben tener label con VLAN/subnet
10. Generar XML valido -- verificable abriendolo en VS Code o diagrams.net
11. Page size should match content (use gridSize=5 for precision)
12. Un diagrama por archivo `.drawio` (puede tener multiples tabs/pages)
13. **F5 at TOP**: F5 is the entry point of traffic, must be the first element in the right panel
14. **VMware on the left**: Small box, NOT a container wrapping the cluster
15. **Servicios Externos**: ONLY external services (NTP, DNS, GW, AD/LDAP, Internet). NOT internal config like chrony MachineConfig or wildcard cert details
16. **Worker DMZ separate row**: Worker DMZ nodes go on their own row below Infra DMZ
17. **Programmatic generation recommended**: Use Python script for calculating positions when dealing with many nodes
