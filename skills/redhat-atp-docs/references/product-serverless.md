# Catálogo ATP: Red Hat OpenShift Serverless (Knative)

Pruebas para validar Serverless sobre OpenShift.
Comandos verificados contra docs oficiales Serverless 1.33+.

## Fuentes oficiales
- [Installing Knative Serving](https://docs.redhat.com/en/documentation/red_hat_openshift_serverless/1.35/html/installing_openshift_serverless/installing-knative-serving)
- [Installing Knative Eventing](https://docs.redhat.com/en/documentation/red_hat_openshift_serverless/1.34/html/installing_openshift_serverless/installing-knative-eventing)

## FASE SLS-1 — Instalación

### SLS-1. KnativeServing operativo

**Procedimiento**:
```
Paso 1: oc get knativeserving.operator.knative.dev/knative-serving -n knative-serving --template='{{range .status.conditions}}{{printf "%s=%s\n" .type .status}}{{end}}'
Paso 2: oc get pods -n knative-serving --no-headers
```

**Resultado esperado**:
- Paso 1: Todas las conditions con status=True:
  - `DependenciesInstalled=True`
  - `DeploymentsAvailable=True`
  - `InstallSucceeded=True`
  - `Ready=True`
  - `VersionMigrationEligible=True`
- Paso 2: activator, autoscaler, controller, webhook, domain-mapping pods Running
- Criterios: [ ] Ready=True [ ] InstallSucceeded=True [ ] Pods core Running

Referencia oficial: "If the conditions have a status of Unknown or False, wait a few moments and then check again."

---

### SLS-2. KnativeEventing operativo (si aplica)

**Condición**: Solo si se desplegó Eventing.

**Procedimiento**:
```
Paso 1: oc get knativeeventing.operator.knative.dev/knative-eventing -n knative-eventing --template='{{range .status.conditions}}{{printf "%s=%s\n" .type .status}}{{end}}'
Paso 2: oc get pods -n knative-eventing --no-headers
```

**Resultado esperado**:
- Paso 1: Todas conditions True (DependenciesInstalled, DeploymentsAvailable, InstallSucceeded, Ready)
- Paso 2: eventing-controller, eventing-webhook, imc-controller, broker-controller pods Running
- Criterios: [ ] Ready=True [ ] Pods Running

---

### SLS-3. KnativeKafka (si aplica)

**Condición**: Solo si se usa Kafka como broker/source.

**Procedimiento**:
```
Paso 1: oc get knativekafka knative-kafka -n knative-eventing
```

**Resultado esperado**:
- Paso 1: Ready=True
- Criterios: [ ] KnativeKafka Ready

---

## FASE SLS-2 — Funcionalidad

### SLS-4. Knative Service scale-to-zero

**Procedimiento**:
```
Paso 1: kn service create test-atp --image=registry.redhat.io/ubi9/httpd-24 -n <namespace>
Paso 2: kn service list -n <namespace>
Paso 3: curl -sk https://<ksvc-url>
Paso 4: sleep 90 && oc get pods -n <namespace> -l serving.knative.dev/service=test-atp --no-headers
Paso 5: kn service delete test-atp -n <namespace>
```

**Resultado esperado**:
- Paso 1: Service creado exitosamente
- Paso 2: READY=True, URL asignada
- Paso 3: HTTP 200 (cold start, pod escala de 0 a 1)
- Paso 4: 0 pods (scale-to-zero funcional después de idle timeout)
- Paso 5: Service eliminado
- Criterios: [ ] KSVC Ready [ ] Scale-up funcional [ ] Scale-to-zero funcional [ ] Cold start aceptable

---

### SLS-5. Broker y Trigger (si Eventing)

**Condición**: Solo si hay Eventing configurado.

**Procedimiento**:
```
Paso 1: oc get broker -n <namespace>
Paso 2: oc get trigger -n <namespace>
```

**Resultado esperado**:
- Paso 1: Broker Ready=True, URL asignada
- Paso 2: Triggers con subscriber configurado, Ready=True
- Criterios: [ ] Broker Ready [ ] Triggers configurados [ ] Subscribers correctos
