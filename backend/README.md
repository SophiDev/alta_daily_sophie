# Backend Alta Daily

Esta carpeta define el diseno inicial del backend para Alta Daily.

## Stack recomendado

Para el MVP recomiendo:

- API: Node.js con Express o NestJS.
- Base de datos: PostgreSQL.
- Auth: JWT + `password_hash` con bcrypt/argon2.
- Storage de imagenes: Supabase Storage, S3 o Cloudinary.
- Migraciones: Prisma, Drizzle, Knex o SQL versionado.

## Base local con Docker

1. Copia `.env.example` a `.env`.
2. Ajusta credenciales si quieres.
3. Levanta PostgreSQL:

```bash
docker compose --env-file .env up -d
```

El contenedor ejecuta `schema.sql` al crear el volumen por primera vez.

## Modulos backend MVP

1. Auth
2. Usuarios y perfil
3. Categorias
4. Prendas
5. Outfits
6. Calendario
7. Favoritos
8. Historial de uso
9. Estadisticas basicas

## Separacion de responsabilidades

```text
Frontend
  -> API HTTP
    -> Servicios de negocio
      -> Repositorios / queries
        -> PostgreSQL
    -> Storage de imagenes
```

## Reglas de negocio iniciales

- Cada prenda pertenece a una sola usuaria.
- Las categorias son globales; las etiquetas son por usuaria.
- Un outfit puede tener muchas prendas.
- Un calendario guarda un outfit por fecha por usuaria en el MVP.
- Marcar un outfit como usado debe crear registros en `wear_history`.
- Favoritos usa una tabla flexible para prendas, outfits e inspiraciones.
- Las recomendaciones se pueden guardar aunque al inicio sean basadas en reglas.

## Orden sugerido de implementacion

1. Crear proyecto backend.
2. Conectar PostgreSQL.
3. Ejecutar `schema.sql`.
4. Implementar auth real.
5. Migrar el login actual de `localStorage` a `/auth/register` y `/auth/login`.
6. Implementar prendas y categorias.
7. Implementar outfits.
8. Implementar calendario e historial.

## Archivos

- `schema.sql`: esquema relacional PostgreSQL.
- `API.md`: contrato inicial de endpoints.
- `docker-compose.yml`: PostgreSQL local para desarrollo.
- `.env.example`: variables base para backend y base de datos.
