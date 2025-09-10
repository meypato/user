create table public.rooms (
  id uuid not null default gen_random_uuid (),
  building_id uuid not null,
  name text not null,
  room_number text not null,
  room_id text null,
  room_type public.room_type not null default 'single'::room_type,
  fee numeric(10, 2) not null,
  security_fee numeric(10, 2) null,
  maximum_occupancy integer not null default 1,
  availability_status public.room_availability not null default 'available'::room_availability,
  description text null,
  created_at timestamp with time zone not null default now(),
  updated_at timestamp with time zone not null default now(),
  photos jsonb null default '[]'::jsonb,
  created_by_agent_id uuid null,
  constraint rooms_pkey primary key (id),
  constraint rooms_building_id_room_number_key unique (building_id, room_number),
  constraint rooms_room_id_key unique (room_id),
  constraint rooms_building_id_fkey foreign KEY (building_id) references buildings (id) on delete CASCADE,
  constraint rooms_created_by_agent_id_fkey foreign KEY (created_by_agent_id) references profiles (id)
) TABLESPACE pg_default;

create index IF not exists rooms_building_id_idx on public.rooms using btree (building_id) TABLESPACE pg_default;

create index IF not exists rooms_room_id_idx on public.rooms using btree (room_id) TABLESPACE pg_default;

create index IF not exists rooms_room_type_idx on public.rooms using btree (room_type) TABLESPACE pg_default;

create index IF not exists rooms_availability_status_idx on public.rooms using btree (availability_status) TABLESPACE pg_default;

create index IF not exists rooms_fee_idx on public.rooms using btree (fee) TABLESPACE pg_default;

create index IF not exists rooms_photos_idx on public.rooms using gin (photos) TABLESPACE pg_default;

create trigger trigger_generate_room_id BEFORE INSERT
or
update on rooms for EACH row
execute FUNCTION generate_room_id ();