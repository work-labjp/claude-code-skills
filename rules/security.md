# Reglas de Seguridad

- Nunca escribir passwords, API keys, tokens o secrets en archivos de código
- Usar variables de entorno para toda configuración sensible
- No exponer stack traces o errores internos en respuestas HTTP
- Validar todo input del usuario (SQL injection, XSS, command injection)
- Usar HTTPS siempre, nunca HTTP para APIs externas
- No usar eval() ni equivalentes dinámicos
