# Authorization test matrix (manual/CI)

These checks validate that unauthorized users cannot mutate data:

1. `POST /registro-animal` without bearer token returns `401`.
2. `POST /registro-animal` with valid token from user outside refugio returns `403`.
3. `POST /update-animal` with admin/collaborator token returns `200`.
4. `POST /delete-animal` with outsider token returns `403`.
5. `GET /usuarios/<uid>` only allows same uid token.

Recommended automation:
- add integration tests with Flask test client + mocked `auth.verify_id_token`.
- run in CI before deployment.
