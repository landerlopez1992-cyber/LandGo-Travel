---
description: |
  **REGLAS OPERATIVAS OBLIGATORIAS - LANDGO TRAVEL FLUTTERFLOW**
  
  **PROTECCIÓN ABSOLUTA:**
  - NO eliminar pantallas existentes sin autorización explícita del usuario
  - NO eliminar archivos de datos sin autorización explícita del usuario
  - NO restaurar archivos desde Git sin autorización explícita del usuario
  - NO hacer `git restore` sin autorización explícita del usuario
  - NO eliminar funcionalidades implementadas sin autorización explícita del usuario
  - NO crear archivos duplicados (ej: flight_detail_simple_2.dart, flight_detail_simple_fixed.dart)
  - NO crear pantallas duplicadas sin autorización explícita del usuario
  
  **OBLIGATORIO SIEMPRE:**
  - Antes de eliminar CUALQUIER archivo, preguntar al usuario
  - Antes de restaurar CUALQUIER archivo, preguntar al usuario
  - Antes de hacer `git restore`, preguntar al usuario
  - Antes de eliminar CUALQUIER funcionalidad, preguntar al usuario
  - Antes de crear CUALQUIER archivo duplicado, preguntar al usuario
  - Preservar TODO el trabajo existente
  - Solo modificar/mejorar, nunca eliminar sin autorización
  - Verificar que NO existe un archivo similar antes de crear uno nuevo
  
  **PROTECCIÓN ESPECIAL PARA:**
  - Pantallas de vuelos (flight_*)
  - Pantallas de favoritos (favorite_*)
  - Pantallas de órdenes (order_*)
  - Archivos de modelos (models/*)
  - Archivos de servicios (services/*)
  - Cualquier archivo con funcionalidad implementada
  - Pantallas de reservas (booking_*)
  - Pantallas de pagos (payment_*)
  - Panel de administración (admin_*)
  - Sistema de membresías (membership_*)
  
  **EXCEPCIÓN:**
  - Solo se puede eliminar si el usuario dice EXPLÍCITAMENTE "elimina", "borra", "quita"
  - NUNCA asumir que se puede eliminar
  - SIEMPRE preguntar antes de eliminar
  
  **OBJETIVO:**
  - Preservar TODO el trabajo realizado
  - No perder horas de desarrollo
  - Mantener funcionalidades implementadas
  - Solo agregar/mejorar, nunca eliminar sin autorización
  - Trabajar exclusivamente en FlutterFlow/Dart
  - Respetar la paleta de colores oficial establecida
globs:
  - "**/*"
alwaysApply: true
---
