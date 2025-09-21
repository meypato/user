CREATE TABLE public.user_favorite_buildings (
  user_id uuid NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  building_id uuid NOT NULL REFERENCES buildings(id) ON DELETE CASCADE,
  created_at timestamptz NOT NULL DEFAULT now(),
  PRIMARY KEY (user_id, building_id)
);

CREATE INDEX idx_user_favorite_buildings_user_id ON user_favorite_buildings(user_id);
CREATE INDEX idx_user_favorite_buildings_building_id ON user_favorite_buildings(building_id);
CREATE INDEX idx_user_favorite_buildings_created_at ON user_favorite_buildings(created_at DESC);
CREATE INDEX idx_user_favorite_buildings_user_date ON user_favorite_buildings(user_id, created_at DESC);