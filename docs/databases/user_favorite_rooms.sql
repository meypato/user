CREATE TABLE public.user_favorite_rooms (
  user_id uuid NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  room_id uuid NOT NULL REFERENCES rooms(id) ON DELETE CASCADE,
  created_at timestamptz NOT NULL DEFAULT now(),
  PRIMARY KEY (user_id, room_id)
);

CREATE INDEX idx_user_favorite_rooms_user_id ON user_favorite_rooms(user_id);
CREATE INDEX idx_user_favorite_rooms_room_id ON user_favorite_rooms(room_id);
CREATE INDEX idx_user_favorite_rooms_created_at ON user_favorite_rooms(created_at DESC);
CREATE INDEX idx_user_favorite_rooms_user_date ON user_favorite_rooms(user_id, created_at DESC);