# Catálogo ATP: Red Hat Advanced Cluster Management (ACM)

Pruebas para validar ACM como hub de gestión multi-cluster.
Comandos verificados contra docs oficiales RHACM 2.12+.

## Fuentes oficiales
- [ACM 2.12 Documentation](https://docs.redhat.com/en/documentation/red_hat_advanced_cluster_management_for_kubernetes/2.12)
- [ACM 2.12 Support Matrix](https://access.redhat.com/articles/7086905)

## FASE ACM-1 — Instalación del Hub

### ACM-1. MultiClusterHub operativo

**Procedimiento**:
```
Paso 1: oc get multiclusterhub -n open-cluster-management
Paso 2: oc get multiclusterhub multiclusterhub -n open-cluster-management -o jsonpath='{.status.currentVersion}'
Paso 3: oc get multiclusterhub multiclusterhub -n open-cluster-management -o jsonpath='{.status.phase}'
Paso 4: oc get pods -n open-cluster-management --no-headers
```

**Resultado esperado**:
- Paso 1: MCH listado
- Paso 2: Versión actual correcta (ej: "2.12.x")
- Paso 3: Phase=`Running`
- Paso 4: Todos pods Running/Completed, 0 CrashLoopBackOff
- Criterios: [ ] MCH Running [ ] Versión correcta [ ] Todos pods healthy

Referencia: `currentVersion` y `desiredVersion` deben coincidir.

---

### ACM-2. Consola ACM accesible

**Procedimiento**:
```
Paso 1: oc get route multicloud-console -n open-cluster-management -o jsonpath='{.spec.host}'
Paso 2: oc get pods -n open-cluster-management -l app=console-chart-v2 --no-headers
```

**Resultado esperado**:
- Paso 1: URL de consola ACM
- Paso 2: Console pods Running
- Criterios: [ ] Consola accesible [ ] Login funcional

---

### ACM-3. Observability (si aplica)

**Condición**: Solo si se desplegó Observability.

**Procedimiento**:
```
Paso 1: oc get multiclusterobservability observability
Paso 2: oc get pods -n open-cluster-management-observability --no-headers
```

**Resultado esperado**:
- Paso 1: Status Ready
- Paso 2: Thanos, Grafana, Alertmanager pods Running
- Criterios: [ ] Observability Ready [ ] Object storage configurado [ ] Pods Running

---

## FASE ACM-2 — Managed Clusters

### ACM-4. Hub como local-cluster

**Procedimiento**:
```
Paso 1: oc get managedcluster local-cluster
Paso 2: oc get managedcluster local-cluster -o jsonpath='{.status.conditions}'
```

**Resultado esperado**:
- Paso 1: ManagedCluster existe, HUBACCEPTED=true, JOINED=True, AVAILABLE=True
- Paso 2: Conditions: ManagedClusterConditionAvailable=True, ManagedClusterJoined=True, HubAcceptedManagedCluster=True
- Criterios: [ ] local-cluster registrado [ ] Available=True [ ] Joined=True

---

### ACM-5. Managed clusters remotos (si aplica)

**Condición**: Solo si hay clusters remotos gestionados.

**Procedimiento**:
```
Paso 1: oc get managedcluster
Paso 2: oc get managedclusteraddon -A --no-headers
```

**Resultado esperado**:
- Paso 1: Todos los clusters: HUBACCEPTED=true, JOINED=True, AVAILABLE=True
- Paso 2: Addons en estado Available
- Criterios: [ ] Todos clusters Available [ ] Addons funcionales

---

## FASE ACM-3 — Governance y Policies

### ACM-6. Policies aplicadas (si aplica)

**Condición**: Solo si hay policies configuradas.

**Procedimiento**:
```
Paso 1: oc get policy -A
Paso 2: oc get placementrule -A
Paso 3: oc get placementbinding -A
```

**Resultado esperado**:
- Paso 1: Policies en estado Compliant (o NonCompliant con justificación documentada)
- Paso 2: PlacementRules con decisions
- Paso 3: PlacementBindings vinculando policies a placements
- Criterios: [ ] Policies aplicadas [ ] Compliance según diseño

---

## FASE ACM-4 — Application Lifecycle

### ACM-7. Applications vía ACM (si aplica)

**Condición**: Solo si hay apps gestionadas por ACM.

**Procedimiento**:
```
Paso 1: oc get application -n open-cluster-management
Paso 2: oc get subscription.apps.open-cluster-management.io -A
Paso 3: oc get channel -A
```

**Resultado esperado**:
- Paso 1: Applications listadas
- Paso 2: Subscriptions propagated
- Paso 3: Channels disponibles
- Criterios: [ ] Apps desplegadas [ ] Subscriptions activas

---

## FASE ACM-5 — Backup (si aplica)

### ACM-8. Backup hub configurado

**Condición**: Solo si se configuró backup del hub.

**Procedimiento**:
```
Paso 1: oc get backupschedule -n open-cluster-management-backup
Paso 2: oc get backup -n open-cluster-management-backup --sort-by=.metadata.creationTimestamp
```

**Resultado esperado**:
- Paso 1: BackupSchedule activo
- Paso 2: Último backup phase=Completed
- Criterios: [ ] Schedule activo [ ] Último backup exitoso [ ] Storage configurado
