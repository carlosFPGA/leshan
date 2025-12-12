# Guía de Configuración de Logging en Docker

Esta guía explica cómo controlar el nivel de logging del servidor Leshan cuando se ejecuta en Docker.

## Opciones Disponibles

### Opción 1: Solo modificar docker-compose.yml (Recomendado - Más Simple) ⭐

**Ventajas:**
- ✅ **NO necesitas modificar el Dockerfile original**
- ✅ Fácil de cambiar sin reconstruir la imagen
- ✅ Puedes tener diferentes configuraciones para diferentes entornos
- ✅ El volumen montado sobrescribe cualquier archivo en el contenedor

**Pasos:**

1. Copia el archivo de configuración que necesites al servidor:
   ```bash
   # Para producción (mínimo logging)
   scp leshan-demo-server/logback-config-production.xml ubuntu@192.168.1.20:~/iot-thesis/
   
   # Para debug (logging completo)
   scp leshan-demo-server/logback-config-debug.xml ubuntu@192.168.1.20:~/iot-thesis/
   ```

2. **Solo modifica tu `docker-compose.yml`** (NO necesitas cambiar Dockerfile.server):
   ```yaml
   services:
     leshan_server:
       build:
         context: .
         dockerfile: Dockerfile.server  # <-- Tu Dockerfile original, sin cambios
       container_name: leshan_app
       restart: always
       ports:
         - "5683:5683/udp"
       volumes:
         # Monta el archivo de configuración - sobrescribe cualquier archivo en el contenedor
         - ./logback-config-production.xml:/opt/leshan/logback-config.xml:ro
       environment:
         # Indica a Java dónde encontrar el archivo
         - JAVA_OPTS=-Dlogback.configurationFile=/opt/leshan/logback-config.xml
   ```

3. Reinicia el contenedor:
   ```bash
   docker-compose down
   docker-compose up -d
   ```

**Nota importante:** El volumen montado (`./logback-config-production.xml:/opt/leshan/logback-config.xml`) sobrescribe cualquier archivo que pueda estar en esa ruta dentro del contenedor, así que no necesitas modificar el Dockerfile.

### Opción 2: Modificar Dockerfile + docker-compose.yml (Opcional)

**Cuándo usar:**
- Si quieres tener un archivo de configuración por defecto dentro de la imagen
- Si no quieres depender de montar un volumen siempre

**Nota:** Aunque modifiques el Dockerfile, el volumen montado en docker-compose.yml **siempre sobrescribirá** el archivo en el contenedor.

**Pasos:**

1. Usa el Dockerfile mejorado (`Dockerfile.server.logging`):
   ```bash
   # Copia el Dockerfile mejorado
   scp Dockerfile.server.logging ubuntu@192.168.1.20:~/iot-thesis/Dockerfile.server
   ```

2. Modifica tu `docker-compose.yml`:
   ```yaml
   services:
     leshan_server:
       build:
         context: .
         dockerfile: Dockerfile.server  # <-- Ahora usa el Dockerfile modificado
       container_name: leshan_app
       restart: always
       ports:
         - "5683:5683/udp"
       environment:
         - JAVA_OPTS=-Dlogback.configurationFile=/opt/leshan/logback-config.xml
       volumes:
         # El volumen sobrescribe el archivo copiado en el Dockerfile
         - ./logback-config-production.xml:/opt/leshan/logback-config.xml:ro
   ```

**Recomendación:** Usa la Opción 1 (solo docker-compose.yml) a menos que tengas una razón específica para modificar el Dockerfile.

## Configuraciones Disponibles

### `logback-config-production.xml` (Para mediciones de performance)
- **Root level:** WARN
- **ClientServlet:** WARN (solo timeouts y errores)
- **Impacto en performance:** Mínimo
- **Uso:** Cuando necesitas medir tiempos sin afectar el desempeño

### `logback-config-debug.xml` (Para troubleshooting)
- **Root level:** INFO
- **ClientServlet:** DEBUG (todos los logs)
- **Impacto en performance:** Bajo (gracias a los guards)
- **Uso:** Cuando necesitas diagnosticar problemas

### `logback-config.xml` (Por defecto)
- **Root level:** WARN
- **ClientServlet:** INFO (logs importantes)
- **Impacto en performance:** Bajo
- **Uso:** Configuración balanceada para uso normal

## Cambiar entre Configuraciones

Para cambiar entre configuraciones sin reconstruir:

```bash
# 1. Detener el contenedor
docker-compose down

# 2. Cambiar el archivo montado en docker-compose.yml
# Cambia: ./logback-config-production.xml
# Por:    ./logback-config-debug.xml

# 3. Reiniciar
docker-compose up -d

# 4. Ver logs
docker-compose logs -f leshan_server
```

## Verificar la Configuración

Para verificar qué nivel de logging está activo:

```bash
# Ver logs del contenedor
docker-compose logs leshan_server

# Si ves logs INFO/DEBUG, el nivel está en INFO/DEBUG
# Si solo ves WARN/ERROR, el nivel está en WARN
```

## Recomendación para Mediciones de Tiempo

Para mediciones de tiempo sin impacto en performance:

1. Usa `logback-config-production.xml`
2. O deshabilita temporalmente el logger de ClientServlet:
   ```xml
   <logger name="org.eclipse.leshan.demo.server.servlet.ClientServlet" level="OFF"/>
   ```

Los logs críticos (timeouts, errores) siempre se mostrarán en nivel WARN/ERROR.

