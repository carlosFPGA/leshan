# Cálculos de Transferencia de Firmware

## Configuración Actual

- **Timeout configurado:** 5 minutos (300 segundos)
- **Tamaño de bloque CoAP:** 1024 bytes (1 KB) - según código fuente
- **Protocolo:** CoAP con block-wise transfer

## Cálculo para Firmware de 4MB

### Parámetros:
- Tamaño del firmware: 4 MB = 4,194,304 bytes
- Bloques necesarios: 4,194,304 / 1024 = **4,096 bloques**

### Escenarios de Transferencia:

#### Escenario 1: Red Local (Baja Latencia) - Optimista
- Latencia por bloque: ~20-50ms
- Tiempo total: 4,096 bloques × 50ms = **~205 segundos (3.4 minutos)**
- ✅ **CABE en 5 minutos**

#### Escenario 2: Red Típica (Latencia Media) - Realista
- Latencia por bloque: ~50-100ms
- Tiempo total: 4,096 bloques × 100ms = **~410 segundos (6.8 minutos)**
- ⚠️ **EXCEDE los 5 minutos**

#### Escenario 3: Red Lenta/Alta Latencia - Conservador
- Latencia por bloque: ~100-200ms
- Tiempo total: 4,096 bloques × 200ms = **~819 segundos (13.7 minutos)**
- ❌ **MUY EXCEDE los 5 minutos**

## Tamaño Máximo Recomendado para 5 Minutos

### Cálculo Conservador (200ms por bloque):
- Tiempo disponible: 300 segundos
- Bloques máximos: 300 / 0.2 = **1,500 bloques**
- Tamaño máximo: 1,500 × 1024 = **1.5 MB**

### Cálculo Realista (100ms por bloque):
- Tiempo disponible: 300 segundos
- Bloques máximos: 300 / 0.1 = **3,000 bloques**
- Tamaño máximo: 3,000 × 1024 = **3 MB**

### Cálculo Optimista (50ms por bloque):
- Tiempo disponible: 300 segundos
- Bloques máximos: 300 / 0.05 = **6,000 bloques**
- Tamaño máximo: 6,000 × 1024 = **6 MB**

## Recomendaciones

### Para Firmware de 4MB:
1. **Aumentar timeout a 7-10 minutos** para mayor seguridad
2. **Optimizar red** (reducir latencia)
3. **Usar bloques más grandes** si el cliente lo soporta (BERT - Block-wise Transfer)

### Tamaño Máximo Seguro para 5 Minutos:
- **Recomendado:** **2-2.5 MB** (margen de seguridad)
- **Máximo teórico:** **3 MB** (en condiciones ideales)
- **Mínimo seguro:** **1.5 MB** (en condiciones adversas)

## Factores que Afectan la Velocidad

1. **Latencia de red (RTT):** Factor más importante
2. **Tamaño de bloque:** Bloques más grandes = menos round-trips
3. **Procesamiento del cliente:** Velocidad de escritura del firmware
4. **Carga del servidor:** Múltiples transferencias simultáneas
5. **Protocolo de seguridad:** DTLS/TLS añade overhead

## Solución Propuesta

Si necesitas transferir firmware de 4MB de manera confiable, considera:

1. **Aumentar timeout a 10 minutos** (600,000 ms)
2. **Monitorear logs** para medir tiempos reales
3. **Ajustar según resultados** de pruebas en tu entorno específico

