# Catálogo ATP: Red Hat OpenShift Service Mesh (Istio)

Pruebas para validar Service Mesh sobre OpenShift.
Comandos verificados contra docs oficiales OSSM 2.x/3.0.

## Fuentes oficiales
- [OSSM 3.0 Installing](https://docs.redhat.com/en/documentation/red_hat_openshift_service_mesh/3.0/html/installing/ossm-installing-service-mesh)
- [OCP Service Mesh Troubleshooting](https://docs.openshift.com/dedicated/service_mesh/v2x/ossm-troubleshooting-istio.html)

## Notas
- Shorthand: `smcp` = ServiceMeshControlPlane, `smmr` = ServiceMeshMemberRoll
- OSSM 3.0 usa Sail Operator (Istio upstream). OSSM 2.x usa Maistra.
- Verificar versión antes de generar pruebas.

## FASE SM-1 — Instalación

### SM-1. ServiceMeshControlPlane operativo

**Procedimiento**:
```
Paso 1: oc get smcp -n istio-system
Paso 2: oc get pods -n istio-system --no-headers
```

**Resultado esperado**:
- Paso 1: SMCP STATUS=`ComponentsReady` (OSSM 2.x) o Ready=True (OSSM 3.0)
- Paso 2: istiod, istio-ingressgateway, istio-egressgateway, jaeger, kiali, prometheus pods Running
- Criterios: [ ] SMCP Ready/ComponentsReady [ ] istiod Running [ ] Gateways Running [ ] Versión correcta

Referencia oficial: "The installation has finished successfully when the STATUS column is ComponentsReady."

---

### SM-2. ServiceMeshMemberRoll

**Procedimiento**:
```
Paso 1: oc get smmr default -n istio-system -o jsonpath='{.status.configuredMembers}'
Paso 2: oc describe smmr default -n istio-system
```

**Resultado esperado**:
- Paso 1: Lista de namespaces miembros del mesh
- Paso 2: Status muestra configuredMembers y pendingMembers (debe ser vacío)
- Criterios: [ ] Namespaces según diseño [ ] 0 pendingMembers

---

### SM-3. Kiali dashboard

**Procedimiento**:
```
Paso 1: oc get route kiali -n istio-system -o jsonpath='{.spec.host}'
Paso 2: oc get pods -n istio-system -l app=kiali --no-headers
```

**Resultado esperado**:
- Paso 1: URL de Kiali
- Paso 2: Pod Running
- Criterios: [ ] Kiali accesible [ ] Service graph visible

Referencia oficial: Kiali valida configuraciones Istio (gateways, destination rules, virtual services, mesh policies).

---

### SM-4. Jaeger/Tempo tracing (si aplica)

**Condición**: Solo si se configuró distributed tracing.

**Procedimiento**:
```
Paso 1: oc get jaeger -n istio-system (OSSM 2.x) o oc get tempostack -n <namespace> (OSSM 3.0)
Paso 2: oc get route jaeger -n istio-system -o jsonpath='{.spec.host}'
```

**Resultado esperado**:
- Paso 1: Jaeger/Tempo Running
- Paso 2: UI accesible
- Criterios: [ ] Tracing operativo [ ] Traces visibles

---

## FASE SM-2 — Funcionalidad

### SM-5. Sidecar injection

**Procedimiento**:
```
Paso 1: Desplegar app de prueba en namespace miembro del mesh
Paso 2: oc get pods -n <namespace> -o jsonpath='{range .items[*]}{.metadata.name}{"\t"}{.spec.containers[*].name}{"\n"}{end}'
```

**Resultado esperado**:
- Paso 2: Cada pod tiene container `istio-proxy` además del app container
- Criterios: [ ] Sidecar inyectado [ ] istio-proxy Running

---

### SM-6. mTLS entre servicios

**Procedimiento**:
```
Paso 1: oc get peerauthentication -A
Paso 2: oc get destinationrule -A
```

**Resultado esperado**:
- Paso 1: PeerAuthentication con mode STRICT o PERMISSIVE según diseño
- Paso 2: DestinationRules con tls.mode ISTIO_MUTUAL
- Criterios: [ ] mTLS configurado según diseño [ ] Tráfico encriptado

---

### SM-7. Traffic management (si aplica)

**Condición**: Solo si hay VirtualServices configurados.

**Procedimiento**:
```
Paso 1: oc get virtualservice -A
Paso 2: oc get gateway -A
Paso 3: oc get destinationrule -A
```

**Resultado esperado**:
- VirtualServices, Gateways, DestinationRules según diseño
- Criterios: [ ] Routing configurado [ ] Gateways funcionales

---

### SM-8. Acceso externo via Gateway

**Procedimiento**:
```
Paso 1: oc get route -n istio-system -l istio=ingressgateway
Paso 2: curl -sk https://<gateway-host>/<path>
```

**Resultado esperado**:
- Paso 1: Route del ingress gateway
- Paso 2: Respuesta del servicio backend (HTTP 200)
- Criterios: [ ] Gateway funcional [ ] Routing correcto
