#!/bin/bash
# Script para cambiar fácilmente la configuración de logging en Docker
# Uso: ./switch-logging.sh [production|debug|default]

CONFIG_TYPE=${1:-production}

case $CONFIG_TYPE in
  production)
    CONFIG_FILE="logback-config-production.xml"
    echo "✅ Cambiando a configuración de PRODUCCIÓN (WARN/ERROR only - mínimo impacto en performance)"
    ;;
  debug)
    CONFIG_FILE="logback-config-debug.xml"
    echo "✅ Cambiando a configuración de DEBUG (INFO/DEBUG - para troubleshooting)"
    ;;
  default)
    CONFIG_FILE="logback-config.xml"
    echo "✅ Cambiando a configuración por DEFECTO (INFO - balanceada)"
    ;;
  *)
    echo "❌ Opción inválida: $CONFIG_TYPE"
    echo "Uso: $0 [production|debug|default]"
    exit 1
    ;;
esac

# Verificar que el archivo existe
if [ ! -f "$CONFIG_FILE" ]; then
    echo "❌ Error: Archivo $CONFIG_FILE no encontrado"
    exit 1
fi

# Actualizar docker-compose.yml
if [ -f "docker-compose.yml" ]; then
    # Crear backup
    cp docker-compose.yml docker-compose.yml.backup
    
    # Actualizar el volumen en docker-compose.yml
    # Esto es una actualización simple - puedes necesitar ajustar según tu estructura
    sed -i.tmp "s|./logback-config.*xml|./$CONFIG_FILE|g" docker-compose.yml
    rm -f docker-compose.yml.tmp
    
    echo "✅ docker-compose.yml actualizado"
    echo ""
    echo "📋 Próximos pasos:"
    echo "   1. Revisa docker-compose.yml para confirmar el cambio"
    echo "   2. Ejecuta: docker-compose down"
    echo "   3. Ejecuta: docker-compose up -d"
    echo "   4. Verifica: docker-compose logs -f leshan_server"
else
    echo "⚠️  docker-compose.yml no encontrado en el directorio actual"
    echo "   Actualiza manualmente el volumen a: ./$CONFIG_FILE"
fi

