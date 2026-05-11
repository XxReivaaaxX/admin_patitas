import os
from functools import wraps
from typing import Any, Dict, Optional

import firebase_admin
import requests
from firebase_admin import auth, credentials, db
from flask import Flask, jsonify, request
from flask_cors import CORS


def _env(name: str, default: Optional[str] = None) -> str:
    value = os.getenv(name, default)
    if value is None or value == "":
        raise RuntimeError(f"Missing required environment variable: {name}")
    return value


def create_app() -> Flask:
    app = Flask(__name__)

    allowed_origins = os.getenv(
        "CORS_ALLOWED_ORIGINS",
        "http://localhost:3000,http://localhost:5000,http://localhost:8080",
    )
    CORS(
        app,
        resources={r"/*": {"origins": [origin.strip() for origin in allowed_origins.split(",")]}},
    )

    service_account_path = _env("FIREBASE_SERVICE_ACCOUNT_PATH")
    database_url = _env("FIREBASE_DATABASE_URL")

    if not firebase_admin._apps:
        cred = credentials.Certificate(service_account_path)
        firebase_admin.initialize_app(cred, {"databaseURL": database_url})

    def error_response(message: str, status: int = 400):
        return jsonify({"ok": False, "error": message}), status

    def success_response(data: Dict[str, Any], status: int = 200):
        payload = {"ok": True}
        payload.update(data)
        return jsonify(payload), status

    def get_bearer_token() -> Optional[str]:
        header = request.headers.get("Authorization", "")
        if not header.startswith("Bearer "):
            return None
        return header.split(" ", 1)[1].strip()

    def auth_required(fn):
        @wraps(fn)
        def wrapper(*args, **kwargs):
            token = get_bearer_token()
            if not token:
                return error_response("Missing Bearer token", 401)
            try:
                decoded = auth.verify_id_token(token)
                request.user = decoded
                return fn(*args, **kwargs)
            except Exception:
                return error_response("Invalid or expired token", 401)

        return wrapper

    def is_refugio_owner(refugio_id: str, user_id: str) -> bool:
        refugio = db.reference(f"refugios/{refugio_id}").get() or {}
        return refugio.get("id_usuario") == user_id

    def is_refugio_collaborator(refugio_id: str, user_id: str) -> bool:
        refugio = db.reference(f"refugios/{refugio_id}").get() or {}
        colaboradores = refugio.get("colaboradores") or {}
        return isinstance(colaboradores, dict) and user_id in colaboradores

    def can_manage_refugio(refugio_id: str, user_id: str) -> bool:
        return is_refugio_owner(refugio_id, user_id) or is_refugio_collaborator(
            refugio_id, user_id
        )

    @app.get("/health")
    def health():
        return success_response({"message": "API running"})

    @app.post("/login")
    def login():
        body = request.get_json(silent=True) or {}
        email = body.get("email")
        password = body.get("password")

        if not email or not password:
            return error_response("email and password are required", 400)

        api_key = os.getenv("FIREBASE_WEB_API_KEY")
        if not api_key:
            return error_response(
                "FIREBASE_WEB_API_KEY is not configured in backend environment", 501
            )

        endpoint = (
            "https://identitytoolkit.googleapis.com/v1/accounts:signInWithPassword"
            f"?key={api_key}"
        )
        response = requests.post(
            endpoint,
            json={"email": email, "password": password, "returnSecureToken": True},
            timeout=15,
        )
        if response.status_code != 200:
            return error_response("Invalid credentials", 401)

        payload = response.json()
        return success_response(
            {
                "token": payload.get("idToken"),
                "refreshToken": payload.get("refreshToken"),
                "userId": payload.get("localId"),
                "email": payload.get("email"),
            }
        )

    @app.post("/registro-refugio")
    @auth_required
    def registro_refugio():
        body = request.get_json(silent=True) or {}
        owner_uid = request.user.get("uid")

        nombre = body.get("nombre", "").strip()
        direccion = body.get("direccion", "").strip()
        telefono = body.get("telefono", "").strip()
        email_contacto = body.get("email_contacto", "").strip()

        if not nombre or not direccion:
            return error_response("nombre and direccion are required", 400)

        ref = db.reference("refugios").push()
        ref.set(
            {
                "id_usuario": owner_uid,
                "nombre": nombre,
                "direccion": direccion,
                "telefono": telefono,
                "email_contacto": email_contacto,
            }
        )
        return success_response({"message": "Refugio registrado", "refugioId": ref.key}, 201)

    @app.post("/registro-animal")
    @auth_required
    def registro_animal():
        body = request.get_json(silent=True) or {}
        refugio_id = body.get("id_refugio", "").strip()
        uid = request.user.get("uid")

        if not refugio_id:
            return error_response("id_refugio is required", 400)
        if not can_manage_refugio(refugio_id, uid):
            return error_response("Forbidden", 403)

        ref = db.reference(f"animales/{refugio_id}").push()
        ref.set(
            {
                "nombre": body.get("nombre", ""),
                "especie": body.get("especie", ""),
                "sexo": body.get("sexo", ""),
                "raza": body.get("raza", ""),
                "historial_medico_id": body.get("historial_medico_id", ""),
                "estado_salud": body.get("estado_salud", ""),
                "estado_adopcion": body.get("estado_adopcion", "disponible"),
                "fecha_ingreso": body.get("fecha_ingreso", ""),
                "imagenUrl": body.get("imagenUrl", ""),
            }
        )
        return success_response({"message": "Animal registrado", "animalId": ref.key}, 201)

    @app.post("/update-animal")
    @auth_required
    def update_animal():
        body = request.get_json(silent=True) or {}
        refugio_id = body.get("id_refugio", "").strip()
        animal_id = body.get("id_animal", "").strip()
        uid = request.user.get("uid")

        if not refugio_id or not animal_id:
            return error_response("id_refugio and id_animal are required", 400)
        if not can_manage_refugio(refugio_id, uid):
            return error_response("Forbidden", 403)

        db.reference(f"animales/{refugio_id}/{animal_id}").update(
            {
                "nombre": body.get("nombre", ""),
                "especie": body.get("especie", ""),
                "sexo": body.get("sexo", ""),
                "raza": body.get("raza", ""),
                "historial_medico_id": body.get("historial_medico_id", ""),
                "estado_salud": body.get("estado_salud", ""),
                "estado_adopcion": body.get("estado_adopcion", "disponible"),
                "fecha_ingreso": body.get("fecha_ingreso", ""),
                "imagenUrl": body.get("imagenUrl", ""),
            }
        )
        return success_response({"message": "Animal actualizado"})

    @app.post("/delete-animal")
    @auth_required
    def delete_animal():
        body = request.get_json(silent=True) or {}
        refugio_id = body.get("id_refugio", "").strip()
        animal_id = body.get("id_animal", "").strip()
        historial_id = body.get("historial_medico_id", "").strip()
        uid = request.user.get("uid")

        if not refugio_id or not animal_id:
            return error_response("id_refugio and id_animal are required", 400)
        if not can_manage_refugio(refugio_id, uid):
            return error_response("Forbidden", 403)

        db.reference(f"animales/{refugio_id}/{animal_id}").delete()
        if historial_id:
            db.reference(f"historialMedico/{historial_id}").delete()
        return success_response({"message": "Animal eliminado"})

    @app.post("/registro-historial-medico")
    @auth_required
    def registro_historial_medico():
        body = request.get_json(silent=True) or {}
        refugio_id = body.get("id_refugio", "").strip()
        animal_id = body.get("id_animal", "").strip()
        uid = request.user.get("uid")

        if not refugio_id or not animal_id:
            return error_response("id_refugio and id_animal are required", 400)
        if not can_manage_refugio(refugio_id, uid):
            return error_response("Forbidden", 403)

        historial_ref = db.reference("historialMedico").push()
        historial_ref.set(
            {
                "id_refugio": refugio_id,
                "id_animal": animal_id,
                "castrado": body.get("castrado", False),
                "fecha_revision": body.get("fecha_revision", ""),
                "peso": body.get("peso", ""),
                "enfermedades": body.get("enfermedades", ""),
                "tratamiento": body.get("tratamiento", ""),
            }
        )
        db.reference(f"animales/{refugio_id}/{animal_id}").update(
            {"historial_medico_id": historial_ref.key}
        )

        return success_response(
            {"message": "Historial médico registrado", "historialId": historial_ref.key},
            201,
        )

    @app.post("/update-historial-medico")
    @auth_required
    def update_historial_medico():
        body = request.get_json(silent=True) or {}
        historial_id = body.get("id_historial", "").strip()
        uid = request.user.get("uid")

        if not historial_id:
            return error_response("id_historial is required", 400)

        current = db.reference(f"historialMedico/{historial_id}").get() or {}
        refugio_id = current.get("id_refugio", "")
        if not refugio_id or not can_manage_refugio(refugio_id, uid):
            return error_response("Forbidden", 403)

        db.reference(f"historialMedico/{historial_id}").update(
            {
                "castrado": body.get("castrado", current.get("castrado")),
                "fecha_revision": body.get("fecha_revision", current.get("fecha_revision")),
                "peso": body.get("peso", current.get("peso")),
                "enfermedades": body.get("enfermedades", current.get("enfermedades")),
                "tratamiento": body.get("tratamiento", current.get("tratamiento")),
            }
        )
        return success_response({"message": "Historial médico actualizado"})

    @app.get("/animales/<string:refugio_id>")
    def obtener_animales(refugio_id: str):
        data = db.reference(f"animales/{refugio_id}").get() or {}
        return success_response({"items": data})

    @app.get("/animales/<string:refugio_id>/underweight")
    def animales_bajo_peso(refugio_id: str):
        data = db.reference(f"animales/{refugio_id}").get() or {}
        result = []
        for animal_id, animal in data.items():
            try:
                peso = float(animal.get("peso", 0))
            except Exception:
                peso = 0.0
            if peso < 8.0:
                result.append(
                    {
                        "id": animal_id,
                        "nombre": animal.get("nombre", ""),
                        "especie": animal.get("especie", ""),
                        "raza": animal.get("raza", ""),
                        "peso": peso,
                    }
                )
        return success_response({"items": result})

    @app.get("/refugios/<string:user_id>")
    @auth_required
    def obtener_refugios(user_id: str):
        if request.user.get("uid") != user_id:
            return error_response("Forbidden", 403)

        data = db.reference("refugios").get() or {}
        refugios_usuario = {
            refugio_id: refugio
            for refugio_id, refugio in data.items()
            if refugio.get("id_usuario") == user_id
        }
        return success_response({"items": refugios_usuario})

    @app.get("/usuarios/<string:user_id>")
    @auth_required
    def obtener_usuario(user_id: str):
        if request.user.get("uid") != user_id:
            return error_response("Forbidden", 403)

        usuario = auth.get_user(uid=user_id)
        return success_response(
            {
                "uid": usuario.uid,
                "email": usuario.email,
                "displayName": usuario.display_name,
            }
        )

    @app.get("/historial-medico/<string:historial_id>")
    @auth_required
    def historial_medico(historial_id: str):
        data = db.reference(f"historialMedico/{historial_id}").get()
        if not data:
            return error_response("Historial médico no encontrado", 404)

        refugio_id = data.get("id_refugio")
        if not refugio_id or not can_manage_refugio(refugio_id, request.user.get("uid")):
            return error_response("Forbidden", 403)

        return success_response({"item": data})

    @app.errorhandler(404)
    def not_found(_):
        return error_response("Endpoint not found", 404)

    @app.errorhandler(500)
    def internal_error(_):
        return error_response("Internal server error", 500)

    return app


app = create_app()


if __name__ == "__main__":
    debug = os.getenv("FLASK_DEBUG", "false").lower() == "true"
    app.run(host="0.0.0.0", port=int(os.getenv("PORT", "5000")), debug=debug)
