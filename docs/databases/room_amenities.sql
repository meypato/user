create table public.room_amenities (
  room_id uuid not null,
  amenity_id uuid not null,
  constraint room_amenities_pkey primary key (room_id, amenity_id),
  constraint room_amenities_amenity_id_fkey foreign KEY (amenity_id) references amenities (id) on delete RESTRICT,
  constraint room_amenities_room_id_fkey foreign KEY (room_id) references rooms (id) on delete CASCADE
) TABLESPACE pg_default;