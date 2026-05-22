CREATE EXTENSION IF NOT EXISTS pgcrypto;

CREATE TABLE users (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  email VARCHAR(255) UNIQUE NOT NULL,
  password_hash TEXT NOT NULL,
  full_name VARCHAR(120) NOT NULL,
  avatar_url TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE user_profiles (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID UNIQUE NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  preferred_style VARCHAR(80),
  lifestyle VARCHAR(80),
  favorite_colors TEXT[] NOT NULL DEFAULT '{}',
  disliked_colors TEXT[] NOT NULL DEFAULT '{}',
  style_goal TEXT,
  size_notes TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE categories (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name VARCHAR(80) NOT NULL,
  slug VARCHAR(80) UNIQUE NOT NULL,
  parent_id UUID REFERENCES categories(id) ON DELETE SET NULL,
  sort_order INTEGER NOT NULL DEFAULT 0,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE garments (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  category_id UUID REFERENCES categories(id) ON DELETE SET NULL,
  name VARCHAR(120) NOT NULL,
  image_url TEXT,
  color VARCHAR(80),
  secondary_colors TEXT[] NOT NULL DEFAULT '{}',
  brand VARCHAR(120),
  size VARCHAR(40),
  material VARCHAR(120),
  season VARCHAR(40),
  formality_level SMALLINT CHECK (formality_level BETWEEN 1 AND 5),
  status VARCHAR(40) NOT NULL DEFAULT 'active',
  notes TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE garment_tags (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  name VARCHAR(80) NOT NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  UNIQUE (user_id, name)
);

CREATE TABLE garment_tag_map (
  garment_id UUID NOT NULL REFERENCES garments(id) ON DELETE CASCADE,
  tag_id UUID NOT NULL REFERENCES garment_tags(id) ON DELETE CASCADE,
  PRIMARY KEY (garment_id, tag_id)
);

CREATE TABLE outfits (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  name VARCHAR(120) NOT NULL,
  description TEXT,
  cover_image_url TEXT,
  occasion VARCHAR(80),
  style VARCHAR(80),
  season VARCHAR(40),
  formality_level SMALLINT CHECK (formality_level BETWEEN 1 AND 5),
  created_by VARCHAR(40) NOT NULL DEFAULT 'user',
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE outfit_items (
  outfit_id UUID NOT NULL REFERENCES outfits(id) ON DELETE CASCADE,
  garment_id UUID NOT NULL REFERENCES garments(id) ON DELETE CASCADE,
  position VARCHAR(40),
  sort_order INTEGER NOT NULL DEFAULT 0,
  PRIMARY KEY (outfit_id, garment_id)
);

CREATE TABLE calendar_entries (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  outfit_id UUID REFERENCES outfits(id) ON DELETE SET NULL,
  planned_date DATE NOT NULL,
  status VARCHAR(40) NOT NULL DEFAULT 'planned',
  notes TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  UNIQUE (user_id, planned_date)
);

CREATE TABLE events (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  title VARCHAR(160) NOT NULL,
  event_type VARCHAR(80),
  location VARCHAR(160),
  starts_at TIMESTAMPTZ,
  ends_at TIMESTAMPTZ,
  dress_code VARCHAR(80),
  notes TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE event_outfits (
  event_id UUID NOT NULL REFERENCES events(id) ON DELETE CASCADE,
  outfit_id UUID NOT NULL REFERENCES outfits(id) ON DELETE CASCADE,
  PRIMARY KEY (event_id, outfit_id)
);

CREATE TABLE favorites (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  entity_type VARCHAR(40) NOT NULL,
  entity_id UUID NOT NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  UNIQUE (user_id, entity_type, entity_id)
);

CREATE TABLE wear_history (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  outfit_id UUID REFERENCES outfits(id) ON DELETE SET NULL,
  garment_id UUID REFERENCES garments(id) ON DELETE SET NULL,
  worn_date DATE NOT NULL,
  context VARCHAR(100),
  rating SMALLINT CHECK (rating BETWEEN 1 AND 5),
  notes TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  CHECK (outfit_id IS NOT NULL OR garment_id IS NOT NULL)
);

CREATE TABLE weather_snapshots (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES users(id) ON DELETE CASCADE,
  snapshot_date DATE NOT NULL,
  location VARCHAR(160),
  temperature_c NUMERIC(5,2),
  condition VARCHAR(80),
  humidity NUMERIC(5,2),
  rain_probability NUMERIC(5,2),
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE recommendations (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  outfit_id UUID REFERENCES outfits(id) ON DELETE SET NULL,
  recommendation_type VARCHAR(80) NOT NULL,
  reason TEXT,
  score NUMERIC(5,2),
  accepted BOOLEAN,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE wishlist_items (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  category_id UUID REFERENCES categories(id) ON DELETE SET NULL,
  name VARCHAR(160) NOT NULL,
  image_url TEXT,
  brand VARCHAR(120),
  price NUMERIC(10,2),
  url TEXT,
  priority SMALLINT CHECK (priority BETWEEN 1 AND 5),
  notes TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE trips (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  name VARCHAR(160) NOT NULL,
  destination VARCHAR(160),
  starts_on DATE,
  ends_on DATE,
  notes TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE trip_items (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  trip_id UUID NOT NULL REFERENCES trips(id) ON DELETE CASCADE,
  garment_id UUID REFERENCES garments(id) ON DELETE CASCADE,
  outfit_id UUID REFERENCES outfits(id) ON DELETE CASCADE,
  notes TEXT,
  CHECK (garment_id IS NOT NULL OR outfit_id IS NOT NULL)
);

CREATE TABLE garment_maintenance (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  garment_id UUID NOT NULL REFERENCES garments(id) ON DELETE CASCADE,
  maintenance_type VARCHAR(80) NOT NULL,
  due_date DATE,
  completed_at TIMESTAMPTZ,
  notes TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE inspirations (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  title VARCHAR(160),
  image_url TEXT NOT NULL,
  source_url TEXT,
  style VARCHAR(80),
  occasion VARCHAR(80),
  notes TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_user_profiles_user_id ON user_profiles(user_id);
CREATE INDEX idx_categories_parent_id ON categories(parent_id);
CREATE INDEX idx_garments_user_id ON garments(user_id);
CREATE INDEX idx_garments_category_id ON garments(category_id);
CREATE INDEX idx_garments_user_status ON garments(user_id, status);
CREATE INDEX idx_garment_tags_user_id ON garment_tags(user_id);
CREATE INDEX idx_outfits_user_id ON outfits(user_id);
CREATE INDEX idx_outfit_items_garment_id ON outfit_items(garment_id);
CREATE INDEX idx_calendar_user_date ON calendar_entries(user_id, planned_date);
CREATE INDEX idx_events_user_starts_at ON events(user_id, starts_at);
CREATE INDEX idx_favorites_user_entity ON favorites(user_id, entity_type, entity_id);
CREATE INDEX idx_wear_history_user_date ON wear_history(user_id, worn_date);
CREATE INDEX idx_weather_user_date ON weather_snapshots(user_id, snapshot_date);
CREATE INDEX idx_recommendations_user_type ON recommendations(user_id, recommendation_type);
CREATE INDEX idx_wishlist_user_id ON wishlist_items(user_id);
CREATE INDEX idx_trips_user_dates ON trips(user_id, starts_on, ends_on);
CREATE INDEX idx_maintenance_garment_due ON garment_maintenance(garment_id, due_date);
CREATE INDEX idx_inspirations_user_id ON inspirations(user_id);

INSERT INTO categories (name, slug, sort_order) VALUES
  ('Tops', 'tops', 10),
  ('Bottoms', 'bottoms', 20),
  ('Vestidos', 'vestidos', 30),
  ('Zapatos', 'zapatos', 40),
  ('Accesorios', 'accesorios', 50),
  ('Chaquetas', 'chaquetas', 60),
  ('Bolsos', 'bolsos', 70)
ON CONFLICT (slug) DO NOTHING;
