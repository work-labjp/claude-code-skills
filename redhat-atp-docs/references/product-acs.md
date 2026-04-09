# Catálogo ATP: Red Hat Advanced Cluster Security (ACS / StackRox)

Pruebas para validar ACS desplegado sobre OpenShift.
Comandos verificados contra docs oficiales RHACS 4.x.

## Fuentes oficiales
- [ACS System Health Dashboard](https://docs.redhat.com/en/documentation/red_hat_advanced_cluster_security_for_kubernetes/4.7/html/operating/use-system-health-dashboard)
- [ACS Monitoring](https://docs.redhat.com/en/documentation/red_hat_advanced_cluster_security_for_kubernetes/4.9/html/configuring/monitor-acs)
- [roxctl CLI](https://docs.redhat.com/en/documentation/red_hat_advanced_cluster_security_for_kubernetes/4.0/html-single/roxctl_cli/index)

## FASE ACS-1 — Instalación

### ACS-1. Central operativo

**Procedimiento**:
```
Paso 1: oc get central -n stackrox
Paso 2: oc get pods -n stackrox -l app=central --no-headers
Paso 3: oc get pods -n stackrox -l app=scanner --no-headers
Paso 4: oc get pods -n stackrox -l app=scanner-db --no-headers
Paso 5: oc get route central -n stackrox -o jsonpath='{.spec.host}'
```

**Resultado esperado**:
- Paso 1: Central con conditions Ready
- Paso 2: central pod Running
- Paso 3: scanner pods Running (réplicas según config)
- Paso 4: scanner-db pod Running
- Paso 5: URL accesible
- Criterios: [ ] Central Ready [ ] Scanner Running [ ] Scanner DB Running [ ] UI accesible

---

### ACS-2. SecuredCluster y componentes

**Procedimiento**:
```
Paso 1: oc get securedcluster -n stackrox
Paso 2: oc get pods -n stackrox -l app=sensor --no-headers
Paso 3: oc get pods -n stackrox -l app=collector --no-headers
Paso 4: oc get pods -n stackrox -l app=admission-control --no-headers
```

**Resultado esperado**:
- Paso 1: SecuredCluster conditions Ready
- Paso 2: Sensor pod Running
- Paso 3: Collector pods Running en CADA nodo (DaemonSet)
- Paso 4: Admission control pods Running (si habilitado)
- Criterios: [ ] SecuredCluster Ready [ ] Sensor Running [ ] Collector en todos los nodos [ ] Admission Controller Running (si aplica)

---

### ACS-3. System Health Dashboard (API)

Referencia oficial: El dashboard muestra estado de Central, Scanner, Sensor, Collector, Admission Controller, vulnerability DB, integrations, notifiers, backup providers.

**Procedimiento**:
```
Paso 1: export ROX_CENTRAL_ADDRESS=<central-route>:443
Paso 2: export ROX_API_TOKEN=<token>
Paso 3: curl -sk -H "Authorization: Bearer $ROX_API_TOKEN" https://$ROX_CENTRAL_ADDRESS/v1/clusters
Paso 4: curl -sk -H "Authorization: Bearer $ROX_API_TOKEN" https://$ROX_CENTRAL_ADDRESS/v1/clusters/<cluster-id>/status
```

**Resultado esperado**:
- Paso 3: JSON con lista de clusters secured
- Paso 4: JSON con sensorHealthStatus, collectorHealthStatus, admissionControlHealthStatus
- Criterios: [ ] Cluster visible [ ] sensorHealthStatus=HEALTHY [ ] collectorHealthStatus=HEALTHY

---

### ACS-4. roxctl diagnostics

Referencia oficial: `roxctl` CLI para diagnosticar Central.

**Procedimiento**:
```
Paso 1: roxctl -e "$ROX_CENTRAL_ADDRESS" --token-file=<token-file> central debug log --level Info
Paso 2: roxctl -e "$ROX_CENTRAL_ADDRESS" --token-file=<token-file> central debug dump
```

**Resultado esperado**:
- Paso 1: Log level configurado, sin errores críticos
- Paso 2: Dump de diagnostico generado
- Criterios: [ ] Central respondiendo [ ] Sin errores críticos en logs

---

## FASE ACS-2 — Funcionalidad

### ACS-5. Image scanning

**Procedimiento**:
```
Paso 1: curl -sk -H "Authorization: Bearer $ROX_API_TOKEN" https://$ROX_CENTRAL_ADDRESS/v1/images/scan -X POST -d '{"imageName":"registry.redhat.io/ubi9/ubi-minimal:latest"}'
```

**Resultado esperado**:
- Paso 1: JSON con scan results, CVEs identificados, severity breakdown
- Criterios: [ ] Scan ejecutado [ ] CVEs reportados [ ] Scanner funcional

---

### ACS-6. Compliance reports

**Procedimiento**:
```
Paso 1: curl -sk -H "Authorization: Bearer $ROX_API_TOKEN" https://$ROX_CENTRAL_ADDRESS/v2/compliance/scan/configurations
```

**Resultado esperado**:
- Paso 1: Configurations de compliance existentes
- Criterios: [ ] Compliance configurado [ ] Standards evaluados (CIS, NIST, PCI)

---

### ACS-7. Security policies activas

**Procedimiento**:
```
Paso 1: curl -sk -H "Authorization: Bearer $ROX_API_TOKEN" "https://$ROX_CENTRAL_ADDRESS/v1/policies?query=Disabled%3Afalse"
```

**Resultado esperado**:
- Paso 1: Lista de policies activas (default + custom)
- Criterios: [ ] Default policies activas [ ] Custom policies según diseño

---

### ACS-8. Integrations (si aplica)

**Condición**: Solo si hay integraciones configuradas.

**Procedimiento**:
```
Paso 1: curl -sk -H "Authorization: Bearer $ROX_API_TOKEN" https://$ROX_CENTRAL_ADDRESS/v1/imageintegrations
Paso 2: curl -sk -H "Authorization: Bearer $ROX_API_TOKEN" https://$ROX_CENTRAL_ADDRESS/v1/notifiers
```

**Resultado esperado**:
- Paso 1: Registries integrados
- Paso 2: Notifiers configurados
- Criterios: [ ] Registries conectados [ ] Notifiers funcionales
