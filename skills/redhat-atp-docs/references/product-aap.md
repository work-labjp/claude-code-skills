# Catálogo ATP: Red Hat Ansible Automation Platform (AAP)

Pruebas para validar AAP desplegado sobre OpenShift.
Comandos verificados contra docs oficiales AAP 2.5/2.6.

## Fuentes oficiales
- [AAP 2.5 Installing on OCP](https://docs.redhat.com/en/documentation/red_hat_ansible_automation_platform/2.5/html-single/installing_on_openshift_container_platform/index)
- [AAP 2.6 Installing on OCP](https://docs.redhat.com/en/documentation/red_hat_ansible_automation_platform/2.6/html-single/installing_on_openshift_container_platform/index)

## Notas
- AAP 2.5+ usa gateway unificado (`AnsibleAutomationPlatform` CR en vez de CRs separados)
- Verificar si se desplegó con el CR unificado o con CRs individuales

## FASE AAP-1 — Instalación

### AAP-1. Gateway / Platform operativo

**Procedimiento**:
```
Paso 1: oc get ansibleautomationplatform -n <namespace> (AAP 2.5+)
Paso 2: oc get pods -n <namespace> --no-headers
Paso 3: oc get routes -n <namespace>
```

**Resultado esperado**:
- Paso 1: AnsibleAutomationPlatform status conditions Ready
- Paso 2: controller (web, task), hub (api, content, worker), gateway, redis, postgres pods Running
- Paso 3: Routes para controller, hub, gateway
- Criterios: [ ] Platform Ready [ ] Todos pods Running [ ] Routes accesibles

Referencia: Verificar que el operator muestra `Succeeded` en status.

---

### AAP-2. AutomationController (si CR individual)

**Condición**: Solo si se desplegó con CR individual (AAP < 2.5 o configuración custom).

**Procedimiento**:
```
Paso 1: oc get automationcontroller -n <namespace>
Paso 2: oc get pods -n <namespace> -l app.kubernetes.io/component=automationcontroller --no-headers
Paso 3: oc get route -n <namespace> -l app.kubernetes.io/component=automationcontroller -o jsonpath='{.items[0].spec.host}'
```

**Resultado esperado**:
- Paso 1: Status Running
- Paso 2: web, task, redis, postgres pods Running
- Paso 3: URL del Controller
- Criterios: [ ] Controller Running [ ] UI accesible

---

### AAP-3. AutomationHub (si aplica)

**Condición**: Solo si se desplegó Private Automation Hub.

**Procedimiento**:
```
Paso 1: oc get automationhub -n <namespace>
Paso 2: oc get pods -n <namespace> -l app.kubernetes.io/component=automationhub --no-headers
```

**Resultado esperado**:
- Paso 1: Status Running
- Paso 2: api, content, worker, redis pods Running
- Criterios: [ ] Hub Running [ ] API accesible

---

### AAP-4. EDA Controller (si aplica)

**Condición**: Solo si se desplegó Event-Driven Ansible.

**Procedimiento**:
```
Paso 1: oc get eda -n <namespace>
Paso 2: oc get pods -n <namespace> -l app.kubernetes.io/component=eda --no-headers
```

**Resultado esperado**:
- Paso 1: EDA Running
- Paso 2: activation-worker, api, scheduler pods Running
- Criterios: [ ] EDA Running [ ] Pods healthy

---

## FASE AAP-2 — Funcionalidad

### AAP-5. API health check

**Procedimiento**:
```
Paso 1: curl -sk -o /dev/null -w '%{http_code}' https://<controller-route>/api/v2/ping/
Paso 2: curl -sk -o /dev/null -w '%{http_code}' https://<hub-route>/api/galaxy/v3/
```

**Resultado esperado**:
- Paso 1: HTTP 200 (Controller API respondiendo)
- Paso 2: HTTP 200 o 403 (Hub API alcanzable)
- Criterios: [ ] Controller API up [ ] Hub API up

---

### AAP-6. Credenciales admin

**Procedimiento**:
```
Paso 1: oc get secret <platform-name>-admin-password -n <namespace> -o jsonpath='{.data.password}'
```

**Resultado esperado**:
- Paso 1: Secret existe, password en base64 decodificable
- Criterios: [ ] Admin password accesible [ ] Login funcional

---

### AAP-7. Execution Environments

**Procedimiento**:
```
Paso 1: Verificar en UI: Administration > Execution Environments
```

**Resultado esperado**:
- Paso 1: EE default disponible, Custom EEs si aplica
- Criterios: [ ] EE default configurado [ ] Pull funcional

---

### AAP-8. Job Template de prueba

**Procedimiento**:
```
Paso 1: Ejecutar Job Template de prueba en UI (ej: "Demo Job Template" o custom)
Paso 2: Verificar resultado en UI > Jobs
```

**Resultado esperado**:
- Paso 2: Status=Successful, output correcto
- Criterios: [ ] Job ejecutado [ ] Status Successful

---

## FASE AAP-3 — Integración

### AAP-9. LDAP/SSO (si aplica)

**Condición**: Solo si se configuró autenticación externa.

**Procedimiento**:
```
Paso 1: Verificar en UI: Settings > Authentication
Paso 2: Login con usuario LDAP/SSO
```

**Resultado esperado**:
- Criterios: [ ] Provider configurado [ ] Login externo funcional [ ] Roles mapeados
