# Catálogo ATP: Red Hat Quay

Pruebas para validar Quay Registry desplegado sobre OpenShift.
Comandos verificados contra docs oficiales Red Hat Quay 3.x.

## Fuentes oficiales
- [Quay Health Checks](https://docs.redhat.com/en/documentation/red_hat_quay/3.11/html/troubleshooting_red_hat_quay/health-check-quay)
- [Quay API Guide](https://docs.redhat.com/en/documentation/red_hat_quay/3/html-single/red_hat_quay_api_guide/index)

## FASE QUAY-1 — Instalación

### QUAY-1. QuayRegistry operativo

**Procedimiento**:
```
Paso 1: oc get quayregistry -n <namespace>
Paso 2: oc get pods -n <namespace> --no-headers
Paso 3: oc get route -n <namespace> -l quay-component=quay-app -o jsonpath='{.items[0].spec.host}'
```

**Resultado esperado**:
- Paso 1: QuayRegistry condition Available=True
- Paso 2: quay-app, quay-database, quay-redis, clair-app pods Running
- Paso 3: URL de acceso a Quay
- Criterios: [ ] Registry Available [ ] Todos pods Running [ ] Route accesible

---

### QUAY-2. Health check endpoints (oficial Red Hat)

**Procedimiento**:
```
Paso 1: curl -k -s https://<quay-route>/health/instance
Paso 2: curl -k -s https://<quay-route>/health/endtoend
```

**Resultado esperado**:
- Paso 1: JSON `{"data":{"services":{"auth":true,"database":true,"disk_space":true,"registry_gunicorn":true,"service_key":true,"web_gunicorn":true}},"status_code":200}`
  - `status_code: 200` = healthy
  - `status_code: 503` = issue
- Paso 2: JSON con status de end-to-end health
- Criterios: [ ] /health/instance = 200 [ ] auth=true [ ] database=true [ ] disk_space=true [ ] registry_gunicorn=true [ ] service_key=true [ ] web_gunicorn=true

Referencia oficial: Los servicios verificados son auth, database, disk_space, registry_gunicorn, service_key, web_gunicorn.

---

### QUAY-3. Clair scanning operativo

**Procedimiento**:
```
Paso 1: oc get pods -n <namespace> -l quay-component=clair-app --no-headers
Paso 2: oc get pods -n <namespace> -l quay-component=clair-postgres --no-headers
```

**Resultado esperado**:
- Paso 1: Clair pods Running
- Paso 2: Clair DB Running
- Criterios: [ ] Clair operativo [ ] DB healthy

---

### QUAY-4. Mirror workers (si aplica)

**Condición**: Solo si Quay se usa como mirror registry.

**Procedimiento**:
```
Paso 1: oc get pods -n <namespace> -l quay-component=quay-mirror --no-headers
```

**Resultado esperado**:
- Paso 1: Mirror worker pods Running
- Criterios: [ ] Mirror workers Running

---

## FASE QUAY-2 — Funcionalidad

### QUAY-5. Login, push y pull

**Procedimiento**:
```
Paso 1: podman login <quay-route> --tls-verify=false -u <user> -p <password>
Paso 2: podman pull registry.redhat.io/ubi9/ubi-minimal:latest
Paso 3: podman tag registry.redhat.io/ubi9/ubi-minimal:latest <quay-route>/<org>/test-atp:latest
Paso 4: podman push <quay-route>/<org>/test-atp:latest --tls-verify=false
Paso 5: podman rmi <quay-route>/<org>/test-atp:latest
Paso 6: podman pull <quay-route>/<org>/test-atp:latest --tls-verify=false
```

**Resultado esperado**:
- Paso 1: `Login Succeeded!`
- Paso 4: Push exitoso (layers uploaded)
- Paso 6: Pull exitoso (image descargada)
- Criterios: [ ] Login funcional [ ] Push exitoso [ ] Pull exitoso [ ] Round-trip completo

---

### QUAY-6. Vulnerability scan en imagen

**Procedimiento**:
```
Paso 1: Verificar en UI: Repository > test-atp > Security Scan tab
```

**Resultado esperado**:
- Paso 1: Scan completado, CVE count visible, severity breakdown
- Criterios: [ ] Scan ejecutado automáticamente [ ] CVEs reportados

---

### QUAY-7. Organizations y Robot Accounts

**Procedimiento**:
```
Paso 1: curl -sk -H "Authorization: Bearer <token>" https://<quay-route>/api/v1/superuser/organizations/
Paso 2: curl -sk -H "Authorization: Bearer <token>" https://<quay-route>/api/v1/organization/<org>/robots
```

**Resultado esperado**:
- Paso 1: Organizations del diseño presentes
- Paso 2: Robot accounts creados con permisos
- Criterios: [ ] Orgs creadas [ ] Robots configurados [ ] Permisos correctos

---

## FASE QUAY-3 — HA y Storage

### QUAY-8. Réplicas y distribución

**Procedimiento**:
```
Paso 1: oc get deploy -n <namespace> -l quay-component=quay-app -o wide
```

**Resultado esperado**:
- Paso 1: READY N/N, réplicas >= 2, distribuidas en diferentes nodos
- Criterios: [ ] Múltiples réplicas [ ] Distribuidas en nodos distintos

### QUAY-9. Object storage backend

**Procedimiento**:
```
Paso 1: oc get quayregistry <nombre> -n <namespace> -o jsonpath='{.spec.components}'
```

**Resultado esperado**:
- Paso 1: ObjectStorage component managed o unmanaged con config
- Criterios: [ ] Storage backend configurado [ ] Backend accesible
