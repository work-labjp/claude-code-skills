# Catálogo ATP: OpenShift Container Platform (OCP)

Base obligatoria para todo cluster OpenShift. Comandos verificados contra docs oficiales de Red Hat.

## Fuentes oficiales
- [OCP 4.18 Installation Overview](https://docs.redhat.com/en/documentation/openshift_container_platform/4.18/html-single/installation_overview/index)
- [Infrastructure Nodes](https://github.com/openshift/openshift-docs/blob/main/machine_management/creating-infrastructure-machinesets.adoc)
- [Monitoring on Infra](https://github.com/openshift/openshift-docs/blob/main/modules/infrastructure-moving-monitoring.adoc)

## Pruebas condicionales

| Condición | Pruebas que aplican |
|-----------|-------------------|
| **Siempre** | FASE 1 completa, FASE 2 core, FASE 6 alertas |
| **Si hay nodos infra** | Labels/taints infra, MCP infra, IC infra, monitoring infra |
| **Si hay nodos DMZ / multi-VLAN** | IngressController DMZ, FASE 4 multi-VLAN |
| **Si hay ODF/OCS** | FASE 3 storage ODF |
| **Si hay NFS** | NFS provisioner, PVC NFS |
| **Si hay certificado wildcard** | Certificado TLS custom |
| **Si hay LDAP/OIDC** | OAuth provider, group sync, RBAC grupos |

---

## FASE 1 — Validación de Instalación

### 1. Nodos del cluster

**Objetivo**: Verificar que todos los nodos están en estado Ready con roles correctos.

**Procedimiento**:
```
Paso 1: oc get nodes -o wide
Paso 2: oc wait clusteroperators --all --for=condition=Progressing=false --timeout=60s
```

**Resultado esperado**:
- Paso 1: N nodos STATUS=`Ready`. Columnas: NAME, STATUS, ROLES, AGE, VERSION, INTERNAL-IP, EXTERNAL-IP, OS-IMAGE, KERNEL-VERSION, CONTAINER-RUNTIME
  - Roles: `control-plane,master` (3), `infra` (N), `worker` (N)
  - VERSION: `v1.31.x` (corresponde a OCP 4.18.x)
- Paso 2: Todos los cluster operators han terminado de progresar (exit 0)
- Criterios: [ ] Todos los nodos Ready [ ] Roles correctos [ ] Versión K8s correcta [ ] IPs en VLAN correcta

**Restauración**: Verificar kubelet, aprobar CSRs: `oc get csr --no-headers | grep Pending` → `oc adm certificate approve <csr-name>`.

---

### 2. Cluster Operators

**Objetivo**: Verificar que todos los ClusterOperators están Available y no Degraded.

**Procedimiento**:
```
Paso 1: oc get co
Paso 2: oc get co -o jsonpath='{range .items[*]}{.metadata.name}{"\t"}{.status.conditions[?(@.type=="Available")].status}{"\t"}{.status.conditions[?(@.type=="Progressing")].status}{"\t"}{.status.conditions[?(@.type=="Degraded")].status}{"\n"}{end}'
```

**Resultado esperado**:
- Paso 1: Tabla con columnas NAME, VERSION, AVAILABLE, PROGRESSING, DEGRADED, SINCE, MESSAGE
- Paso 2: Cada operator: Available=True, Progressing=False, Degraded=False
- Criterios: [ ] 0 operators Degraded=True [ ] 0 operators Available=False [ ] Versión consistente en todos

**Restauración**: `oc describe co <nombre>` → revisar `.status.conditions` y logs del pod operator.

---

### 3. Machine Config Pools

**Objetivo**: Verificar que todos los MCP están Updated y no Degraded.

**Procedimiento**:
```
Paso 1: oc get mcp
```

**Resultado esperado**:
- Paso 1: Cada MCP muestra: CONFIG (nombre MC actual), UPDATED=True, UPDATING=False, DEGRADED=False, MACHINECOUNT=N, READYMACHINECOUNT=N, UPDATEDMACHINECOUNT=N
- Criterios: [ ] Todos MCP Updated=True [ ] Ningún MCP Degraded [ ] MACHINECOUNT == READYMACHINECOUNT para cada MCP

**Restauración**: `oc describe mcp <nombre>` → identificar nodo/MC problemático.

---

### 4. etcd Health

**Objetivo**: Verificar salud del cluster etcd (quorum y miembros).

**Procedimiento**:
```
Paso 1: oc get co etcd
Paso 2: oc get etcd -o=jsonpath='{range .items[0].status.conditions[?(@.type=="EtcdMembersAvailable")]}{.message}{end}'
Paso 3: oc get pods -n openshift-etcd -l k8s-app=etcd --no-headers
```

**Resultado esperado**:
- Paso 1: etcd Available=True, Progressing=False, Degraded=False
- Paso 2: Mensaje indica N miembros healthy (ej: "3 members are available")
- Paso 3: 3 pods etcd Running con todas las containers ready
- Criterios: [ ] etcd Available [ ] 3 miembros en quorum [ ] 0 learners [ ] Pods Running

**Restauración**: Verificar conectividad TCP 2379/2380 entre masters.

---

### 5. Versión del cluster y canal

**Objetivo**: Documentar versión exacta y canal de actualización.

**Procedimiento**:
```
Paso 1: oc get clusterversion
Paso 2: oc get clusterversion version -o jsonpath='{.spec.channel}'
Paso 3: oc get clusterversion version -o jsonpath='{.status.desired.version}'
```

**Resultado esperado**:
- Paso 1: VERSION correcta, AVAILABLE=True, PROGRESSING=False
- Paso 2: Canal esperado (ej: `stable-4.18`, `eus-4.18`)
- Paso 3: Versión deseada = versión actual
- Criterios: [ ] Versión acordada [ ] Canal correcto [ ] Sin upgrades pendientes

---

### 6. CSRs pendientes

**Objetivo**: Verificar que no hay Certificate Signing Requests pendientes.

**Procedimiento**:
```
Paso 1: oc get csr --no-headers
```

**Resultado esperado**:
- Paso 1: 0 CSRs en estado Pending. Todos Approved o Issued
- Criterios: [ ] 0 CSRs Pending

**Restauración**: `oc adm certificate approve <csr-name>` para CSRs legítimos.

---

## FASE 2 — Validación de Day-2

### 7. Labels, Taints y Roles de nodos infra

**Condición**: Solo si hay nodos infra dedicados.

**Procedimiento**:
```
Paso 1: oc get nodes -l node-role.kubernetes.io/infra -L topology.kubernetes.io/zone
Paso 2: oc get nodes -l node-role.kubernetes.io/infra -o jsonpath='{range .items[*]}{.metadata.name}{"\t"}{.spec.taints}{"\n"}{end}'
```

**Resultado esperado**:
- Paso 1: N nodos infra listados, zone label si aplica
- Paso 2: Cada nodo tiene taint `{"key":"node-role.kubernetes.io/infra","value":"reserved","effect":"NoSchedule"}`
- Criterios: [ ] Label `node-role.kubernetes.io/infra=""` presente [ ] Taint NoSchedule aplicado [ ] Zones correctas (si aplica)

**Restauración**: `oc label node <nodo> node-role.kubernetes.io/infra=""` y `oc adm taint nodes <nodo> node-role.kubernetes.io/infra=reserved:NoSchedule`.

---

### 8. MachineConfigPool Infra

**Condición**: Solo si hay MCP infra separado.

**Procedimiento**:
```
Paso 1: oc get mcp infra
Paso 2: oc get nodes -l node-role.kubernetes.io/infra --no-headers
```

**Resultado esperado**:
- Paso 1: MCP `infra` UPDATED=True, DEGRADED=False, MACHINECOUNT=N
- Paso 2: Cantidad de nodos = MACHINECOUNT del MCP
- Criterios: [ ] MCP Updated [ ] Conteo correcto [ ] No Degraded

---

### 9. Scheduler (mastersSchedulable)

**Procedimiento**:
```
Paso 1: oc get scheduler cluster -o jsonpath='{.spec.mastersSchedulable}'
```

**Resultado esperado**:
- Paso 1: Output = `false`
- Criterios: [ ] mastersSchedulable=false

**Restauración**: `oc patch scheduler cluster --type=merge -p '{"spec":{"mastersSchedulable":false}}'`

---

### 10. IngressController default en nodos infra

**Condición**: Solo si hay nodos infra.

**Procedimiento**:
```
Paso 1: oc get ingresscontroller default -n openshift-ingress-operator -o jsonpath='{.spec.nodePlacement}'
Paso 2: oc get pods -n openshift-ingress -l ingresscontroller.operator.openshift.io/deployment-ingresscontroller=default -o wide
```

**Resultado esperado**:
- Paso 1: JSON con `nodeSelector: {"node-role.kubernetes.io/infra":""}` y tolerations
- Paso 2: Router pods STATUS=Running en nodos infra (columna NODE)
- Criterios: [ ] nodeSelector apunta a infra [ ] Tolerations presentes [ ] Pods en nodos infra [ ] Réplicas correctas

---

### 11. IngressController DMZ

**Condición**: Solo si hay nodos DMZ / multi-VLAN.

**Procedimiento**:
```
Paso 1: oc get ingresscontroller -n openshift-ingress-operator
Paso 2: oc get ingresscontroller dmz -n openshift-ingress-operator -o jsonpath='{.spec}'
Paso 3: oc get pods -n openshift-ingress -l ingresscontroller.operator.openshift.io/deployment-ingresscontroller=dmz -o wide
```

**Resultado esperado**:
- Paso 1: IngressController `dmz` listado además del `default`
- Paso 2: spec muestra nodeSelector DMZ, routeSelector, domain
- Paso 3: Router pods Running en nodos DMZ
- Criterios: [ ] IC DMZ existe [ ] nodeSelector DMZ [ ] routeSelector configurado [ ] domain correcto [ ] Pods en nodos DMZ

---

### 12. Image Registry

**Procedimiento**:
```
Paso 1: oc get configs.imageregistry.operator.openshift.io cluster -o jsonpath='{.spec.managementState}'
Paso 2: oc get configs.imageregistry.operator.openshift.io cluster -o jsonpath='{.spec.storage}'
Paso 3: oc get pvc -n openshift-image-registry
Paso 4: oc get pods -n openshift-image-registry -l docker-registry=default -o wide
```

**Resultado esperado**:
- Paso 1: `Managed`
- Paso 2: Storage configurado (PVC o emptyDir)
- Paso 3: PVC Bound (si usa PVC)
- Paso 4: Pods Running en nodos infra (si aplica)
- Criterios: [ ] managementState=Managed [ ] Storage persistente [ ] Pods Running [ ] En nodos infra

Referencia oficial: nodeSelector para registry usa `spec.nodePlacement.nodeSelector` con `node-role.kubernetes.io/infra: ""`.

---

### 13. Monitoring Stack en nodos infra

**Condición**: Solo si hay nodos infra.

**Procedimiento**:
```
Paso 1: oc get pods -n openshift-monitoring -o wide --no-headers -l app.kubernetes.io/name=prometheus
Paso 2: oc get pods -n openshift-monitoring -o wide --no-headers -l app.kubernetes.io/name=alertmanager
Paso 3: oc get configmap cluster-monitoring-config -n openshift-monitoring -o jsonpath='{.data.config\.yaml}'
```

**Resultado esperado**:
- Paso 1: prometheus-k8s pods Running en nodos infra
- Paso 2: alertmanager-main pods Running en nodos infra
- Paso 3: YAML con nodeSelector `node-role.kubernetes.io/infra: ""` para prometheusK8s, alertmanagerMain, prometheusOperator, kubeStateMetrics, telemeterClient, openshiftStateMetrics, thanosQuerier, monitoringPlugin, metricsServer
- Criterios: [ ] Prometheus en infra [ ] Alertmanager en infra [ ] ConfigMap con nodeSelector completo

Referencia oficial: `cluster-monitoring-config` ConfigMap requiere nodeSelector + tolerations para 9 componentes.

---

### 14. User Workload Monitoring

**Procedimiento**:
```
Paso 1: oc get configmap cluster-monitoring-config -n openshift-monitoring -o jsonpath='{.data.config\.yaml}'
Paso 2: oc get pods -n openshift-user-workload-monitoring
```

**Resultado esperado**:
- Paso 1: Contiene `enableUserWorkload: true`
- Paso 2: Pods prometheus-user-workload y thanos-ruler Running
- Criterios: [ ] enableUserWorkload=true [ ] Namespace existe [ ] Pods Running

---

### 15. Chrony / NTP

**Procedimiento**:
```
Paso 1: oc get mc 99-worker-chrony 99-master-chrony
```

**Resultado esperado**:
- Paso 1: MachineConfigs existen con generatedByController no vacío
- Criterios: [ ] MC chrony para workers [ ] MC chrony para masters

**Restauración**: Crear MachineConfig con chrony.conf apuntando a servidores NTP del cliente.

---

### 16. OAuth / Autenticación

**Procedimiento**:
```
Paso 1: oc get oauth cluster -o jsonpath='{.spec.identityProviders}'
Paso 2: oc get users --no-headers
Paso 3: oc get groups --no-headers
```

**Resultado esperado**:
- Paso 1: JSON con identityProviders configurados (LDAP, HTPasswd, OIDC según diseño)
- Paso 2: Usuarios autenticados existen
- Paso 3: Grupos sincronizados (si LDAP)
- Criterios: [ ] Provider configurado [ ] Login funcional [ ] Grupos presentes (si LDAP)

---

### 17. LDAP Group Sync CronJob

**Condición**: Solo si hay LDAP.

**Procedimiento**:
```
Paso 1: oc get cronjob ldap-group-sync -n openshift-config
Paso 2: oc get groups --no-headers
Paso 3: oc get job -n openshift-config --sort-by=.metadata.creationTimestamp
```

**Resultado esperado**:
- Paso 1: CronJob activo con SCHEDULE configurado, SUSPEND=False
- Paso 2: Grupos LDAP presentes en OCP
- Paso 3: Último job STATUS=Complete
- Criterios: [ ] CronJob activo [ ] Grupos sincronizados [ ] Último job exitoso

---

### 18. RBAC para grupos

**Procedimiento**:
```
Paso 1: oc get clusterrolebinding -o custom-columns="NAME:.metadata.name,ROLE:.roleRef.name,SUBJECTS:.subjects[*].name"
```

**Resultado esperado**:
- Paso 1: Grupos del cliente asignados a roles correctos según matriz de accesos
- Criterios: [ ] Roles asignados según diseño [ ] Sin cluster-admin innecesarios

---

### 19. Eliminación de kubeadmin

**Procedimiento**:
```
Paso 1: oc get secret kubeadmin -n kube-system
```

**Resultado esperado**:
- Paso 1: Error `Error from server (NotFound): secrets "kubeadmin" not found`
- Criterios: [ ] kubeadmin eliminado

**Restauración**: `oc delete secret kubeadmin -n kube-system` (solo después de verificar admin alternativo).

---

### 20. DNS (api + *.apps)

**Procedimiento**:
```
Paso 1: host api.<cluster>.<domain> <dns-server>
Paso 2: host test.apps.<cluster>.<domain> <dns-server>
```

**Resultado esperado**:
- Paso 1: Resuelve a VIP del API load balancer
- Paso 2: Resuelve a VIP del ingress load balancer
- Criterios: [ ] API resuelve a IP correcta [ ] *.apps resuelve a IP correcta

---

### 21. OVN-Kubernetes SDN health

Referencia: OVN-Kubernetes usa Geneve UDP port 6081 por defecto.

**Procedimiento**:
```
Paso 1: oc get pods -n openshift-ovn-kubernetes --no-headers
Paso 2: oc get co network
```

**Resultado esperado**:
- Paso 1: Todos pods Running/Completed, ovnkube-node DaemonSet en cada nodo
- Paso 2: network operator Available=True, Degraded=False
- Criterios: [ ] 0 pods en CrashLoopBackOff [ ] ovnkube-node en cada nodo [ ] CO network Available

---

### 22. StorageClasses y PVs

**Procedimiento**:
```
Paso 1: oc get sc
Paso 2: oc get pv --no-headers
```

**Resultado esperado**:
- Paso 1: StorageClasses del diseño presentes, una marcada como default (`(default)`)
- Paso 2: PVs en estado Bound o Available
- Criterios: [ ] SC default configurada [ ] SCs según diseño presentes

---

### 23. Image Pruner

**Procedimiento**:
```
Paso 1: oc get imagepruner cluster -o jsonpath='{.spec}'
```

**Resultado esperado**:
- Paso 1: JSON con `schedule` configurado, `suspend: false`
- Criterios: [ ] Pruner activo [ ] Schedule configurado [ ] suspend=false

---

### 24. etcd Backup CronJob

**Procedimiento**:
```
Paso 1: oc get cronjob -n openshift-etcd-backup
Paso 2: oc get pvc -n openshift-etcd-backup
Paso 3: oc get job -n openshift-etcd-backup --sort-by=.metadata.creationTimestamp
```

**Resultado esperado**:
- Paso 1: CronJob activo con SCHEDULE, SUSPEND=False
- Paso 2: PVC Bound para backups
- Paso 3: Último job STATUS=Complete
- Criterios: [ ] CronJob activo [ ] PVC Bound [ ] Último backup exitoso

---

### 25. Operadores instalados (CSVs)

**Procedimiento**:
```
Paso 1: oc get csv -A --no-headers
```

**Resultado esperado**:
- Paso 1: Todos CSVs DISPLAY=nombre, VERSION=correcta, PHASE=Succeeded
- Criterios: [ ] Todos Succeeded [ ] Versiones según diseño [ ] 0 en estado Failed

---

### 26. Registry push/pull funcional

**Procedimiento**:
```
Paso 1: oc import-image test-atp:latest --from=registry.redhat.io/ubi9/ubi-minimal:latest --confirm -n default
Paso 2: oc get istag test-atp:latest -n default
Paso 3: oc delete is test-atp -n default
```

**Resultado esperado**:
- Paso 1: Import exitoso, ImageStream creado
- Paso 2: ImageStreamTag existe con referencia al registry interno
- Paso 3: Limpieza exitosa
- Criterios: [ ] Import exitoso [ ] Tag disponible [ ] Registry funcional

---

### 27. Acceso a Internet desde nodos

**Condición**: Solo si cluster con salida a Internet.

**Procedimiento**:
```
Paso 1: curl -sk --connect-timeout 5 -o /dev/null -w '%{http_code}' https://registry.redhat.io/v2/
```

**Resultado esperado**:
- Paso 1: HTTP 401 (registry alcanzable, autenticación requerida)
- Criterios: [ ] Registry Red Hat alcanzable

---

## FASE 3 — Storage ODF (CONDICIONAL)

### StorageCluster / Ceph Health

**Procedimiento**:
```
Paso 1: oc get storagecluster -n openshift-storage
Paso 2: oc exec -n openshift-storage deploy/rook-ceph-tools -- ceph status
Paso 3: oc exec -n openshift-storage deploy/rook-ceph-tools -- ceph osd status
```

**Resultado esperado**:
- Paso 1: StorageCluster Phase=Ready
- Paso 2: HEALTH_OK, N mons in quorum, N OSDs up+in, PGs active+clean
- Paso 3: Todos OSDs up+in
- Criterios: [ ] HEALTH_OK [ ] Quorum completo [ ] OSDs up+in [ ] PGs clean

### StorageClasses ODF

**Procedimiento**:
```
Paso 1: oc get sc
```

**Resultado esperado**:
- Paso 1: `ocs-storagecluster-cephfs` (RWX), `ocs-storagecluster-ceph-rbd` (RWO), `openshift-storage.noobaa.io` (S3)
- Criterios: [ ] 3 SCs de ODF disponibles

### PVC Provisioning Test

**Procedimiento**:
```
Paso 1: Crear PVC test con cada StorageClass
Paso 2: oc get pvc -n <test-ns>
Paso 3: Eliminar PVCs test
```

**Resultado esperado**:
- Paso 2: PVCs STATUS=Bound, PVs creados automáticamente
- Criterios: [ ] Dynamic provisioning funcional para cada SC

---

## FASE 4 — Multi-VLAN (CONDICIONAL)

### Comunicación bidireccional entre VLANs

**Procedimiento**:
```
Paso 1: ping -c 2 <ip-nodo-otra-vlan>
Paso 2: curl -sk --connect-timeout 3 -o /dev/null -w '%{http_code}' https://<vip-apps>:443
Paso 3: curl -sk --connect-timeout 3 -o /dev/null -w '%{http_code}' https://<vip-api>:6443/healthz
```

**Resultado esperado**:
- Paso 1: 0% packet loss
- Paso 2: HTTP respuesta (200/503 = alcanzable)
- Paso 3: HTTP 200 con body `ok`
- Criterios: [ ] Ping cross-VLAN exitoso [ ] API alcanzable [ ] Apps alcanzable

### Certificado TLS custom

**Condición**: Solo si el cliente provee certificado.

**Procedimiento**:
```
Paso 1: oc get ingresscontroller <nombre> -n openshift-ingress-operator -o jsonpath='{.spec.defaultCertificate}'
Paso 2: oc get secret <nombre-secret> -n openshift-ingress
Paso 3: oc get secret <nombre-secret> -n openshift-ingress -o jsonpath='{.data.tls\.crt}' (decode y verificar con openssl x509)
```

**Resultado esperado**:
- Paso 1: `{"name":"<secret-name>"}`
- Paso 2: Secret tipo kubernetes.io/tls existe
- Paso 3: Subject, Issuer, dates, SANs correctos, no expirado
- Criterios: [ ] Cert válido [ ] No expirado [ ] SANs correctos [ ] Chain completa

### Segmentación de rutas DMZ vs interno

**Procedimiento**:
```
Paso 1: oc get ingresscontroller dmz -n openshift-ingress-operator -o jsonpath='{.spec.routeSelector}'
Paso 2: oc get routes -A -o custom-columns='NAMESPACE:.metadata.namespace,NAME:.metadata.name,HOST:.spec.host,ROUTER:.status.ingress[*].routerName'
```

**Resultado esperado**:
- Paso 1: routeSelector con matchLabels (ej: `router: dmz`)
- Paso 2: Rutas DMZ servidas por router `dmz`, rutas internas por `default`
- Criterios: [ ] Segmentación correcta [ ] Sin rutas en router incorrecto

---

## FASE 5 — Scheduling y Workloads

### Scheduling de pods en workers

**Procedimiento**:
```
Paso 1: oc new-app --name=hello-atp --image=registry.redhat.io/ubi9/httpd-24 -n default
Paso 2: oc get pods -n default -l app=hello-atp -o custom-columns="NAME:.metadata.name,NODE:.spec.nodeName" --no-headers
Paso 3: oc delete all -l app=hello-atp -n default
```

**Resultado esperado**:
- Paso 2: Pod en nodo worker (no master, no infra)
- Criterios: [ ] Pod en worker [ ] Taints masters/infra respetados

---

## FASE 6 — Alertas y Salud

### Alertas del cluster

**Procedimiento**:
```
Paso 1: oc exec -n openshift-monitoring -c prometheus prometheus-k8s-0 -- curl -s 'http://localhost:9090/api/v1/alerts'
```

**Resultado esperado**:
- Paso 1: Solo alerta `Watchdog` en state=firing (es normal). 0 alertas severity=critical
- Criterios: [ ] 0 Critical [ ] Solo Watchdog firing [ ] 0 Warning inesperados

### Alertmanager receivers

**Procedimiento**:
```
Paso 1: oc get secret alertmanager-main -n openshift-monitoring -o jsonpath='{.data.alertmanager\.yaml}'
```

**Resultado esperado**:
- Paso 1: Base64 decode muestra al menos un receiver configurado (email, webhook, PagerDuty)
- Criterios: [ ] Receiver configurado [ ] Route definida

### Consola Web accesible

**Procedimiento**:
```
Paso 1: oc get route console -n openshift-console -o jsonpath='{.spec.host}'
Paso 2: oc get pods -n openshift-console --no-headers
```

**Resultado esperado**:
- Paso 1: URL de consola (ej: `console-openshift-console.apps.<cluster>.<domain>`)
- Paso 2: Pods console Running
- Criterios: [ ] URL accesible [ ] Pods Running [ ] Login funcional

### Cluster health summary

**Procedimiento**:
```
Paso 1: oc get csr --no-headers
Paso 2: oc get co --no-headers
Paso 3: oc get nodes --no-headers
```

**Resultado esperado**:
- Paso 1: 0 CSRs Pending
- Paso 2: 0 operators Degraded
- Paso 3: 0 nodos NotReady
- Criterios: [ ] 0 CSR pending [ ] 0 CO degraded [ ] 0 nodos NotReady
