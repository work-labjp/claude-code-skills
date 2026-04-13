# Catálogo ATP: Red Hat AMQ Streams (Apache Kafka / Strimzi)

Pruebas para validar AMQ Streams desplegado sobre OpenShift.
Comandos verificados contra docs oficiales Streams for Apache Kafka 2.7+ y Strimzi 0.46+.

## Fuentes oficiales
- [Deploying AMQ Streams on OpenShift](https://docs.redhat.com/en/documentation/red_hat_streams_for_apache_kafka/2.7/html-single/deploying_and_managing_streams_for_apache_kafka_on_openshift/index)
- [Strimzi Deploying Guide](https://strimzi.io/docs/operators/latest/deploying)

## Notas importantes
- **Kafka 4.0+** corre exclusivamente en KRaft mode (sin ZooKeeper)
- **Strimzi 0.46+** removió soporte para clusters basados en ZooKeeper
- Verificar si el cluster usa KRaft o ZooKeeper antes de generar pruebas

## FASE KAFKA-1 — Instalación

### KAFKA-1. Operator AMQ Streams

**Procedimiento**:
```
Paso 1: oc get csv -n <namespace> --no-headers
Paso 2: oc get pods -n <namespace> -l strimzi.io/kind=cluster-operator --no-headers
```

**Resultado esperado**:
- Paso 1: CSV `amqstreams` PHASE=Succeeded, VERSION correcta
- Paso 2: strimzi-cluster-operator pod Running
- Criterios: [ ] CSV Succeeded [ ] Operator Running [ ] Versión correcta

---

### KAFKA-2. Kafka cluster operativo

**Procedimiento**:
```
Paso 1: oc get kafka -n <namespace>
Paso 2: oc get kafka <nombre> -n <namespace> -o jsonpath='{.status.conditions}' 
Paso 3: oc get pods -n <namespace> -l strimzi.io/kind=Kafka -o wide --no-headers
Paso 4: oc get pvc -n <namespace> -l strimzi.io/kind=Kafka
```

**Resultado esperado**:
- Paso 1: Kafka listado con DESIRED KAFKA REPLICAS y DESIRED ZK REPLICAS (o 0 si KRaft)
- Paso 2: Condition type=Ready, status=True
- Paso 3: N broker pods Running, distribuidos en nodos distintos (anti-affinity)
- Paso 4: PVCs Bound para cada broker
- Criterios: [ ] Kafka Ready=True [ ] Brokers Running [ ] PVCs Bound [ ] Anti-affinity respetada

Referencia: `oc get kafka <name> -o jsonpath='{.status}' | jq` para status completo.

---

### KAFKA-3. KRaft vs ZooKeeper

**Procedimiento (KRaft)**:
```
Paso 1: oc get kafka <nombre> -n <namespace> -o jsonpath='{.spec.kafka.metadataVersion}'
Paso 2: oc get kafkanodepool -n <namespace>
```

**Procedimiento (ZooKeeper legacy)**:
```
Paso 1: oc get pods -n <namespace> -l strimzi.io/name=<nombre>-zookeeper --no-headers
```

**Resultado esperado**:
- KRaft: metadataVersion presente (ej: "3.8-IV0"), KafkaNodePool resources existen
- ZooKeeper: N zookeeper pods Running
- Criterios: [ ] Modo correcto según diseño [ ] Pods correspondientes Running

---

### KAFKA-4. Listeners y bootstrap

**Procedimiento**:
```
Paso 1: oc get kafka <nombre> -n <namespace> -o jsonpath='{.status.listeners}'
```

**Resultado esperado**:
- Paso 1: JSON con listeners, cada uno con `addresses` y `bootstrapServers`. Tipos: plain (9092), tls (9093), external (si aplica)
- Criterios: [ ] Listeners según diseño [ ] Bootstrap addresses correctos [ ] Puertos abiertos

Referencia: Los bootstrap addresses NO indican estado Ready del cluster. Verificar conditions separadamente.

---

## FASE KAFKA-2 — Funcionalidad

### KAFKA-5. Topics management

**Procedimiento**:
```
Paso 1: oc get kafkatopic -n <namespace>
```

**Resultado esperado**:
- Paso 1: Topics listados con Ready=True, PARTITIONS y REPLICATION FACTOR correctos
- Criterios: [ ] Topics Ready=True [ ] Partitions según diseño [ ] Replication factor >= 2

Referencia: Topic Operator mantiene KafkaTopic CR y Kafka topics sincronizados.

---

### KAFKA-6. Produce/Consume test

**Procedimiento**:
```
Paso 1: oc run kafka-producer-test -n <namespace> --image=<kafka-image> --rm -i --restart=Never -- bin/kafka-console-producer.sh --bootstrap-server <bootstrap>:9092 --topic test-atp
Paso 2: oc run kafka-consumer-test -n <namespace> --image=<kafka-image> --rm -i --restart=Never -- bin/kafka-console-consumer.sh --bootstrap-server <bootstrap>:9092 --topic test-atp --from-beginning --max-messages 1 --timeout-ms 30000
```

**Resultado esperado**:
- Paso 1: Mensaje producido sin errores
- Paso 2: Mensaje consumido = mensaje producido
- Criterios: [ ] Produce exitoso [ ] Consume exitoso [ ] Latencia aceptable

---

### KAFKA-7. KafkaUser y ACLs (si aplica)

**Condición**: Solo si hay autenticación configurada.

**Procedimiento**:
```
Paso 1: oc get kafkauser -n <namespace>
```

**Resultado esperado**:
- Paso 1: KafkaUsers con Ready=True, authentication (scram-sha-512/tls) y authorization configurados
- Criterios: [ ] Users Ready=True [ ] ACLs aplicadas

---

### KAFKA-8. KafkaConnect (si aplica)

**Condición**: Solo si hay Kafka Connect.

**Procedimiento**:
```
Paso 1: oc get kafkaconnect -n <namespace>
Paso 2: oc get pods -n <namespace> -l strimzi.io/kind=KafkaConnect --no-headers
```

**Resultado esperado**:
- Paso 1: KafkaConnect Ready=True
- Paso 2: Pods Running
- Criterios: [ ] Connect Ready [ ] Connectors configurados

---

### KAFKA-9. KafkaBridge HTTP (si aplica)

**Condición**: Solo si hay HTTP Bridge.

**Procedimiento**:
```
Paso 1: oc get kafkabridge -n <namespace>
Paso 2: curl -s http://<bridge-service>:8080/healthy
```

**Resultado esperado**:
- Paso 1: KafkaBridge Ready=True
- Paso 2: HTTP 200
- Criterios: [ ] Bridge Ready [ ] API accesible

---

## FASE KAFKA-3 — Monitoreo

### KAFKA-10. Métricas en Prometheus

**Procedimiento**:
```
Paso 1: oc get podmonitor -n <namespace> -l strimzi.io/cluster=<nombre>
```

**Resultado esperado**:
- Paso 1: PodMonitor existe para Kafka brokers
- Criterios: [ ] PodMonitor configurado [ ] Métricas visibles en Prometheus

Referencia: Métricas JMX clave: `kafka_server_brokertopicmetrics_messagesin_total`, `kafka_server_replicamanager_underreplicatedpartitions`.
