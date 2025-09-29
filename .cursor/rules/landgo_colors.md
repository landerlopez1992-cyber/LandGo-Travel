---
description: |
  **COLORES OFICIALES LANDGO TRAVEL - FLUTTERFLOW**
  
  **PALETA PRINCIPAL:**
  - Primary: Color(0xFF007BFF) // Azul vibrante
  - Secondary: Color(0xFF6C757D) // Gris medio
  - Tertiary: Color(0xFF28A745) // Verde brillante
  - Alternate: Color(0xFFFFC107) // Amarillo/Naranja brillante
  
  **COLORES DE TEXTO:**
  - Primary Text: Color(0xFF11191F) // Gris muy oscuro/negro
  - Secondary Text: Color(0xFF6C757D) // Gris medio
  
  **COLORES DE FONDO:**
  - Primary Background: Color(0xFFF8F9FA) // Blanco muy claro
  - Secondary Background: Color(0xFFE9ECEF) // Gris claro
  
  **COLORES DE ACENTO:**
  - Accent 1: Color(0xFF17A2B8) // Teal/Cian
  - Accent 2: Color(0xFFDC3545) // Rojo brillante
  - Accent 3: Color(0xFFFFC107) // Amarillo/Naranja brillante
  - Accent 4: Color(0xFF6F42C1) // Púrpura profundo
  
  **COLORES SEMÁNTICOS:**
  - Success: Color(0xFF28A745) // Verde brillante
  - Error: Color(0xFFDC3545) // Rojo brillante
  - Warning: Color(0xFFFFC107) // Amarillo/Naranja brillante
  - Info: Color(0xFF17A2B8) // Teal/Cian
  
  **CÓDIGO TEMPLATE OBLIGATORIO:**
  ```dart
  // COLORES LANDGO TRAVEL - USAR SIEMPRE
  Container(
    color: Color(0xFF007BFF), // Primary
    child: Text(
      'LandGo Travel',
      style: TextStyle(
        color: Color(0xFF11191F), // Primary Text
        fontSize: 16,
      ),
    ),
  )
  ```
  
  **PROHIBIDO:**
  - Colors.blue, Colors.green (usar códigos específicos)
  - Cualquier color que no esté en esta lista
  - Crear colores personalizados sin autorización
  
  **OBLIGATORIO:** Cada pantalla nueva DEBE usar exactamente estos colores para mantener identidad visual consistente de LandGo Travel.
globs:
  - "**/*"
alwaysApply: true
---
