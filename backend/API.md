# Alta Daily Backend API

Esta es la primera version del contrato API para conectar el frontend con un backend real.

## Principios

- Todas las rutas privadas requieren `Authorization: Bearer <token>`.
- Las respuestas deben estar filtradas por `user_id`; una usuaria nunca debe leer datos de otra.
- Las imagenes no se guardan como binarios en PostgreSQL; se guarda `image_url` y los archivos viven en storage.
- Las estadisticas del MVP se calculan desde `wear_history`, `garments`, `outfits` y `calendar_entries`.

## Auth

| Metodo | Ruta | Funcion |
| --- | --- | --- |
| POST | `/auth/register` | Crear usuario y perfil base |
| POST | `/auth/login` | Iniciar sesion |
| POST | `/auth/logout` | Cerrar sesion |
| GET | `/auth/me` | Obtener usuario autenticado |

## Perfil

| Metodo | Ruta | Funcion |
| --- | --- | --- |
| GET | `/profile` | Obtener perfil de estilo |
| PATCH | `/profile` | Actualizar preferencias |

## Categorias

| Metodo | Ruta | Funcion |
| --- | --- | --- |
| GET | `/categories` | Listar categorias globales |

## Prendas

| Metodo | Ruta | Funcion |
| --- | --- | --- |
| GET | `/garments` | Listar prendas con filtros |
| POST | `/garments` | Crear prenda |
| GET | `/garments/:id` | Ver detalle de prenda |
| PATCH | `/garments/:id` | Editar prenda |
| DELETE | `/garments/:id` | Archivar prenda |
| POST | `/garments/:id/tags` | Asociar etiquetas |

Filtros sugeridos para `GET /garments`:

- `category_id`
- `color`
- `season`
- `status`
- `tag`
- `q`

## Outfits

| Metodo | Ruta | Funcion |
| --- | --- | --- |
| GET | `/outfits` | Listar outfits |
| POST | `/outfits` | Crear outfit con prendas |
| GET | `/outfits/:id` | Ver detalle |
| PATCH | `/outfits/:id` | Editar metadatos o prendas |
| DELETE | `/outfits/:id` | Eliminar outfit |

## Calendario y uso

| Metodo | Ruta | Funcion |
| --- | --- | --- |
| GET | `/calendar?from=&to=` | Ver planificacion |
| POST | `/calendar` | Agendar outfit |
| PATCH | `/calendar/:id` | Cambiar estado o notas |
| POST | `/wear-history` | Marcar prenda u outfit como usado |
| GET | `/wear-history` | Ver historial |

## Favoritos

| Metodo | Ruta | Funcion |
| --- | --- | --- |
| GET | `/favorites` | Listar favoritos |
| POST | `/favorites` | Guardar favorito |
| DELETE | `/favorites/:id` | Quitar favorito |

## Eventos

| Metodo | Ruta | Funcion |
| --- | --- | --- |
| GET | `/events` | Listar eventos |
| POST | `/events` | Crear evento |
| PATCH | `/events/:id` | Editar evento |
| POST | `/events/:id/outfits` | Asociar outfit |

## Futuro

| Modulo | Rutas iniciales |
| --- | --- |
| Clima | `GET /weather/today`, `POST /weather/snapshots` |
| Recomendaciones | `GET /recommendations/today`, `POST /recommendations/:id/feedback` |
| Estadisticas | `GET /stats/closet-usage`, `GET /stats/forgotten-garments` |
| Lista de deseos | `GET/POST/PATCH /wishlist` |
| Viajes | `GET/POST /trips`, `POST /trips/:id/items` |
| Mantenimiento | `GET/POST /maintenance` |
| Inspiracion | `GET/POST /inspirations` |

## Ejemplo: crear prenda

```json
{
  "name": "Blazer lino marfil",
  "category_id": "uuid",
  "image_url": "https://storage.example/garments/blazer.png",
  "color": "marfil",
  "season": "todo el ano",
  "formality_level": 3,
  "tags": ["trabajo", "clasico", "cena"]
}
```

## Ejemplo: crear outfit

```json
{
  "name": "Viernes oficina chic",
  "occasion": "trabajo",
  "style": "clasico",
  "garments": [
    { "garment_id": "uuid", "position": "top", "sort_order": 1 },
    { "garment_id": "uuid", "position": "bottom", "sort_order": 2 },
    { "garment_id": "uuid", "position": "shoes", "sort_order": 3 }
  ]
}
```
