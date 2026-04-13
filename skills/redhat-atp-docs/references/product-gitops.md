# Catálogo ATP: Red Hat OpenShift GitOps (ArgoCD) + Pipelines (Tekton)

Pruebas para validar GitOps y Pipelines sobre OpenShift.
Comandos verificados contra docs oficiales GitOps 1.10+ y Pipelines.

## Fuentes oficiales
- [OpenShift GitOps](https://docs.redhat.com/en/documentation/red_hat_openshift_gitops/1.10/html/understanding_openshift_gitops/about-redhat-openshift-gitops)
- [OCP CI/CD Pipelines](https://docs.redhat.com/en/documentation/openshift_container_platform/4.9/html/cicd/pipelines)

## Notas
- ArgoCD compara estado declarado en Git vs estado live en cluster. Drift = diferencia.
- Tekton Chains firma task runs y artefactos OCI con cosign/in-toto.

## FASE GITOPS-1 — ArgoCD

### GITOPS-1. ArgoCD Server operativo

**Procedimiento**:
```
Paso 1: oc get argocd -n openshift-gitops
Paso 2: oc get pods -n openshift-gitops --no-headers
Paso 3: oc get route -n openshift-gitops -l app.kubernetes.io/name=openshift-gitops-server -o jsonpath='{.items[0].spec.host}'
```

**Resultado esperado**:
- Paso 1: ArgoCD CR listado con status
- Paso 2: server, repo-server, redis, applicationset-controller, dex-server pods Running
- Paso 3: URL de ArgoCD UI
- Criterios: [ ] ArgoCD CR Ready [ ] Todos pods Running [ ] UI accesible [ ] Login funcional

Referencia: ArgoCD monitorea definiciones en Git y compara con estado live. Si hay drift, reporta OutOfSync.

---

### GITOPS-2. Instancias ArgoCD adicionales (si aplica)

**Condición**: Solo si hay instancias para equipos.

**Procedimiento**:
```
Paso 1: oc get argocd -A
Paso 2: oc get pods -n <team-namespace> -l app.kubernetes.io/part-of=argocd --no-headers
```

**Resultado esperado**:
- Paso 1: Instancias listadas por namespace
- Paso 2: Pods Running para cada instancia
- Criterios: [ ] Instancias según diseño [ ] Pods healthy

---

### GITOPS-3. Applications sincronizadas

**Procedimiento**:
```
Paso 1: oc get application -n openshift-gitops
Paso 2: oc get application -n openshift-gitops -o jsonpath='{range .items[*]}{.metadata.name}{"\t"}{.status.sync.status}{"\t"}{.status.health.status}{"\n"}{end}'
```

**Resultado esperado**:
- Paso 1: Applications listadas
- Paso 2: Cada app: Sync=`Synced`, Health=`Healthy`
- Criterios: [ ] Todas Synced [ ] Todas Healthy [ ] 0 en OutOfSync [ ] 0 en Degraded

---

### GITOPS-4. AppProjects (si aplica)

**Condición**: Solo si hay AppProjects.

**Procedimiento**:
```
Paso 1: oc get appproject -n openshift-gitops
```

**Resultado esperado**:
- Paso 1: AppProjects con sourceRepos y destinations restringidos según diseño
- Criterios: [ ] Projects según diseño [ ] RBAC restricciones aplicadas

---

### GITOPS-5. Repositorios conectados

**Procedimiento**:
```
Paso 1: oc get secret -n openshift-gitops -l argocd.argoproj.io/secret-type=repository --no-headers
```

**Resultado esperado**:
- Paso 1: Secrets de repos presentes
- Criterios: [ ] Repos configurados [ ] Conexión verificada (ver ArgoCD UI > Settings > Repositories)

---

## FASE GITOPS-2 — Tekton Pipelines

### GITOPS-6. Tekton operativo

**Procedimiento**:
```
Paso 1: oc get tektonconfig config -o jsonpath='{.status.conditions[?(@.type=="Ready")].status}'
Paso 2: oc get pods -n openshift-pipelines --no-headers
```

**Resultado esperado**:
- Paso 1: `True`
- Paso 2: tekton-pipelines-controller, tekton-triggers-controller, tekton-chains-controller, webhook pods Running
- Criterios: [ ] TektonConfig Ready=True [ ] Pods Running

Referencia: Tekton Chains monitorea task runs, firma snapshots, convierte a payloads estándar (in-toto), almacena en OCI.

---

### GITOPS-7. ClusterTasks disponibles

**Procedimiento**:
```
Paso 1: oc get clustertask --no-headers
```

**Resultado esperado**:
- Paso 1: ClusterTasks estándar presentes: git-clone, buildah, s2i-*, openshift-client, tkn
- Criterios: [ ] ClusterTasks core disponibles

---

### GITOPS-8. Pipeline de prueba (si aplica)

**Condición**: Solo si hay pipelines.

**Procedimiento**:
```
Paso 1: oc get pipeline -n <namespace>
Paso 2: oc get pipelinerun -n <namespace> --sort-by=.metadata.creationTimestamp
```

**Resultado esperado**:
- Paso 1: Pipelines definidos
- Paso 2: Último PipelineRun status.conditions type=Succeeded, status=True
- Criterios: [ ] Pipelines definidos [ ] Último run Succeeded

---

### GITOPS-9. EventListeners y Triggers (si aplica)

**Condición**: Solo si hay triggers para webhooks.

**Procedimiento**:
```
Paso 1: oc get eventlistener -n <namespace>
Paso 2: oc get service -n <namespace> -l app.kubernetes.io/managed-by=EventListener
```

**Resultado esperado**:
- Paso 1: EventListeners con status Available
- Paso 2: Service endpoints disponibles para webhook
- Criterios: [ ] EventListener Running [ ] Webhook endpoint accesible

---

### GITOPS-10. PVC para workspaces

**Procedimiento**:
```
Paso 1: oc get pvc -n <namespace>
```

**Resultado esperado**:
- Paso 1: PVCs Bound para pipeline workspaces
- Criterios: [ ] PVCs disponibles [ ] StorageClass correcta
