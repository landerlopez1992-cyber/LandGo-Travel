# 🚀 Render Setup Guide - LandGo Travel

## 📋 Configuración completa para landgotravel.com

### PASO 1: GitHub Repository
1. Abrir GitHub Desktop
2. File → Add Local Repository
3. Seleccionar: `/Users/cubcolexpress/Desktop/land_go_travel`
4. Publish repository → landgo-travel-web
5. Make public ✅

### PASO 2: Render.com Setup
**URL:** https://render.com

**Configuración del proyecto:**
```
Repository: tu-usuario/landgo-travel-web
Branch: main
Root Directory: (leave blank)

Build Command:
curl -fsSL https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_3.24.5-stable.tar.xz | tar xJ && 
export PATH="$PATH:$PWD/flutter/bin" && 
flutter config --enable-web && 
flutter pub get && 
flutter build web --release --dart-define=FLUTTER_WEB_USE_SKIA=true

Publish Directory: build/web
```

### PASO 3: Variables de Entorno (Environment)
```
FLUTTER_VERSION=3.24.5
NODE_VERSION=18
```

### PASO 4: Custom Domain Setup
**En Render Dashboard:**
1. Settings → Custom Domains
2. Add Domain: `landgotravel.com`
3. Add Domain: `www.landgotravel.com`

### PASO 5: DNS Configuration
**En tu proveedor de dominio:**

#### Para CNAME (Recomendado):
```
Type: CNAME
Name: @
Value: landgo-travel-web.onrender.com
TTL: 3600

Type: CNAME  
Name: www
Value: landgo-travel-web.onrender.com
TTL: 3600
```

#### Para A Records (Alternativo):
```
Type: A
Name: @  
Value: 216.24.57.1
TTL: 3600

Type: A
Name: www
Value: 216.24.57.1  
TTL: 3600
```

### PASO 6: Headers Configuration
**En render.yaml (ya creado):**
```yaml
headers:
  - path: /*
    name: X-Frame-Options
    value: DENY
  - path: /*
    name: X-Content-Type-Options
    value: nosniff
  - path: /assets/*
    name: Cache-Control
    value: public, max-age=31536000
```

## 🎯 RESULTADO FINAL:

### URLs que funcionarán:
- ✅ https://landgotravel.com
- ✅ https://www.landgotravel.com
- ✅ Automáticamente con SSL/HTTPS
- ✅ CDN global (carga rápida mundial)
- ✅ Auto-deploy cuando hagas cambios

### Funcionalidades disponibles:
- ✅ Sistema de wallet completo
- ✅ Métodos de pago (Stripe web)
- ✅ Membresías con descuentos
- ✅ Responsive design
- ✅ PWA installable

## 💡 TIEMPO ESTIMADO:
- ⏱️ **Setup inicial**: 15-20 minutos
- ⏱️ **Propagación DNS**: 1-24 horas
- ⏱️ **SSL activation**: Automático
- ⏱️ **Primera build**: 5-10 minutos

## 🆘 TROUBLESHOOTING:

### Si el build falla:
1. Verificar que render.yaml está en la raíz
2. Check build logs en Render dashboard
3. Verificar que pubspec.yaml es válido

### Si el dominio no funciona:
1. Verificar DNS con: https://dnschecker.org
2. Esperar propagación (hasta 24h)
3. Check Render dashboard → Domains

### Deploy automático:
- ✅ Cada push a GitHub → Auto deploy
- ✅ Build logs visibles en Render
- ✅ Rollback automático si falla
