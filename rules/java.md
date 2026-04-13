# Reglas para Java/Quarkus

- Java 21: usar records, sealed classes, pattern matching cuando aplique
- Quarkus: preferir CDI annotations (@Inject, @ApplicationScoped)
- Usar Optional en vez de null returns
- Logs con SLF4J, nunca System.out.println
- Tests con JUnit 5 + Mockito
- Maven wrapper (./mvnw) en vez de mvn global
