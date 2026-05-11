# PetFlow Admin Patitas

Plataforma para gestión de refugios y adopciones con Flutter + Firebase, incluyendo:
- gestión de refugios y colaboradores,
- registro de animales e historial médico,
- flujo de adopción pública,
- notificaciones internas.

## Arquitectura

- `lib/`: app Flutter multi-plataforma (web/mobile/desktop).
- Firebase Realtime Database: datos operativos (`refugios`, `animales`, `historialMedico`, `solicitudes_adopcion`).
- Firebase Auth: autenticación principal.
- `backend/`: API Flask para operaciones administrativas seguras con validación de token Firebase.

## Flujo funcional principal

1. Usuario de refugio inicia sesión y gestiona su refugio.
2. Registra/actualiza animales y su historial médico.
3. Usuario externo consulta adopciones públicas y envía solicitud.
4. Refugio gestiona solicitudes y notifica resultado.

## Seguridad y mitigaciones implementadas

- Eliminación de credenciales hardcodeadas del backend en el repositorio.
- Backend con autorización por `Bearer token` (Firebase ID token) para endpoints sensibles.
- CORS restringible por variable de entorno (`CORS_ALLOWED_ORIGINS`).
- Reglas de Realtime Database endurecidas por ownership/rol.
- `debug` desactivado por defecto en backend (`FLASK_DEBUG=false`).

## Backend seguro (Flask)

Ubicación: `backend/`

Variables requeridas:
- `FIREBASE_SERVICE_ACCOUNT_PATH`
- `FIREBASE_DATABASE_URL`
- `FIREBASE_WEB_API_KEY`
- `CORS_ALLOWED_ORIGINS` (opcional, con default local)
- `PORT` (opcional)

Ejemplo:

```bash
cd backend
pip install -r requirements.txt
cp .env.example .env
python app.py
```

## Calidad y pruebas

- Pruebas Flutter de humo:
  - `test/widget_test.dart` (rutas críticas)
  - `test/smoke_screens_test.dart` (login/registro)
- Diseño de pruebas de autorización backend:
  - `backend/tests/test_authorization_design.md`

Comandos:

```bash
flutter pub get
flutter test
flutter analyze
```

## Riesgos abiertos / recomendaciones

- Rotar inmediatamente cualquier credencial que haya sido expuesta en commits anteriores.
- Agregar pruebas de integración automáticas para backend con mocks de Firebase Auth.
- Seguir refactorizando pantallas grandes en capas (`viewmodel/service/widget`) para mejor mantenibilidad.
