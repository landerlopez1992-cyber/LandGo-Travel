#!/bin/bash

# 🔧 Script para compilar app con corrección de login persistente

echo "🔧 Compilando LandGo Travel con login persistente..."

# Navegar al directorio del proyecto
cd /Users/cubcolexpress/Desktop/land_go_travel

# Limpiar caché
echo "🧹 Limpiando caché..."
/Users/cubcolexpress/flutter/bin/flutter clean

# Obtener dependencias
echo "📦 Obteniendo dependencias..."
/Users/cubcolexpress/flutter/bin/flutter pub get

# Compilar APK con correcciones
echo "📱 Compilando APK..."
/Users/cubcolexpress/flutter/bin/flutter build apk --debug

# Instalar en dispositivo
echo "📲 Instalando en dispositivo..."
/Users/cubcolexpress/flutter/bin/flutter install

echo "✅ ¡Compilación completada!"
echo "🔑 Ahora el login debería persistir correctamente"
echo ""
echo "📋 Cambios aplicados:"
echo "  ✅ AuthFlowType.pkce para persistir sesiones"
echo "  ✅ SharedPreferencesLocalStorage para guardar tokens"
echo "  ✅ Verificación de sesión en inicio de app"
echo "  ✅ Auto-refresh de tokens expirados"
echo ""
echo "🧪 Para probar:"
echo "  1. Hacer login"
echo "  2. Cerrar app completamente"
echo "  3. Volver a abrir"
echo "  4. Debe mantener login automáticamente"
