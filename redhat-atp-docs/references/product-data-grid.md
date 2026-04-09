# Catálogo ATP: Red Hat Data Grid (Infinispan)

Pruebas para validar Data Grid / Infinispan desplegado sobre OpenShift.
Comandos verificados contra docs oficiales Data Grid 8.x.

## Fuentes oficiales
- [Data Grid Operator Guide 8.3](https://docs.redhat.com/en/documentation/red_hat_data_grid/8.3/html-single/data_grid_operator_guide/index)
- [Data Grid Health Check API](https://access.redhat.com/documentation/en-us/red_hat_data_grid/7.2/html/developer_guide/the_health_check_api)
- [Monitoring Data Grid](https://docs.redhat.com/en/documentation/red_hat_data_grid/8.3/html/data_grid_operator_guide/monitoring-services)

## FASE DG-1 — Instalación

### DG-1. Operator Data Grid

**Procedimiento**:
```
Paso 1: oc get csv -n <namespace> --no-headers
Paso 2: oc get pods -n <namespace> -l app.kubernetes.io/name=infinispan-operator --no-headers
```

**Resultado esperado**:
- Paso 1: CSV `datagrid-operator` PHASE=Succeeded
- Paso 2: Operator pod Running
- Criterios: [ ] CSV Succeeded [ ] Operator Running

---

### DG-2. Infinispan cluster operativo

**Procedimiento**:
```
Paso 1: oc get infinispan -n <namespace>
Paso 2: oc get infinispan <nombre> -n <namespace> -o jsonpath='{.status.conditions}'
Paso 3: oc get pods -n <namespace> -l app=infinispan-pod -o wide --no-headers
```

**Resultado esperado**:
- Paso 1: Infinispan listado con replicas
- Paso 2: Condition type=WellFormed, status=True
- Paso 3: Pods Running, distribuidos en nodos distintos
- Criterios: [ ] WellFormed=True [ ] Réplicas según diseño [ ] Pods Running [ ] Distribuidos

Referencia oficial: Health status puede ser HEALTHY, UNHEALTHY, o REBALANCING.

---

### DG-3. Expose service

**Condición**: Solo si se expone externamente.

**Procedimiento**:
```
Paso 1: oc get service -n <namespace> -l app=infinispan-pod
Paso 2: oc get route -n <namespace> -l app=infinispan-pod
```

**Resultado esperado**:
- Paso 1: Service expuesto
- Paso 2: Route disponible
- Criterios: [ ] Service accesible [ ] Endpoint correcto

---

## FASE DG-2 — Funcionalidad

### DG-4. REST API health check

Referencia oficial: La Health Check API retorna `getClusterHealth()` con: node count, node names, cluster name, health status (HEALTHY/UNHEALTHY/REBALANCING).

**Procedimiento**:
```
Paso 1: oc get route <nombre>-external -n <namespace> -o jsonpath='{.spec.host}'
Paso 2: curl -sk -u <user>:<password> https://<route>/rest/v2/cache-managers/default/health
Paso 3: curl -sk -u <user>:<password> https://<route>/rest/v2/server
```

**Resultado esperado**:
- Paso 1: URL del servicio
- Paso 2: JSON con `cluster_health.health_status: "HEALTHY"`, `cluster_health.number_of_nodes: N`, `cluster_health.node_names: [...]`
- Paso 3: JSON con version del servidor
- Criterios: [ ] health_status=HEALTHY [ ] number_of_nodes correcto [ ] Versión correcta

---

### DG-5. Cache CRUD operations

**Procedimiento**:
```
Paso 1: curl -sk -u <user>:<password> -X POST https://<route>/rest/v2/caches/test-atp -H "Content-Type: application/json" -d '{"distributed-cache":{"mode":"SYNC","owners":2}}'
Paso 2: curl -sk -u <user>:<password> -X PUT https://<route>/rest/v2/caches/test-atp/key1 -H "Content-Type: text/plain" -d 'value1'
Paso 3: curl -sk -u <user>:<password> https://<route>/rest/v2/caches/test-atp/key1
Paso 4: curl -sk -u <user>:<password> -X DELETE https://<route>/rest/v2/caches/test-atp
```

**Resultado esperado**:
- Paso 1: HTTP 200 (cache creado)
- Paso 2: HTTP 204 (entry insertado)
- Paso 3: Body = `value1` (entry leído)
- Paso 4: HTTP 200 (cache eliminado)
- Criterios: [ ] Create cache OK [ ] Put entry OK [ ] Get entry OK [ ] Delete cache OK

---

### DG-6. Cross-site replication (si aplica)

**Condición**: Solo si hay cross-site configurado.

**Procedimiento**:
```
Paso 1: oc get infinispan <nombre> -n <namespace> -o jsonpath='{.status.conditions}'
```

**Resultado esperado**:
- Paso 1: Condition CrossSiteViewFormed=True
- Criterios: [ ] Sites conectados [ ] Replicación funcional

---

## FASE DG-3 — Persistencia y Monitoreo

### DG-7. Persistent storage

**Procedimiento**:
```
Paso 1: oc get pvc -n <namespace> -l app=infinispan-pod
```

**Resultado esperado**:
- Paso 1: PVCs STATUS=Bound para cada pod
- Criterios: [ ] PVCs Bound [ ] StorageClass correcta

---

### DG-8. Monitoring

Referencia: Operator crea ServiceMonitor automáticamente cuando annotation monitoring=true (default).

**Procedimiento**:
```
Paso 1: oc get servicemonitor -n <namespace>
Paso 2: oc get infinispan <nombre> -n <namespace> -o jsonpath='{.metadata.annotations}'
```

**Resultado esperado**:
- Paso 1: ServiceMonitor existe
- Paso 2: Annotation `infinispan.org/monitoring: "true"` (default)
- Criterios: [ ] ServiceMonitor configurado [ ] Métricas en Prometheus
