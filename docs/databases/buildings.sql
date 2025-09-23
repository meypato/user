create table public.buildings (
  id uuid not null default gen_random_uuid (),
  owner_id uuid not null,
  name text not null,
  building_type public.building_type not null default 'apartment'::building_type,
  address_line1 text not null,
  address_line2 text null,
  country text not null default 'India'::text,
  pincode text null,
  latitude double precision null,
  longitude double precision null,
  contact_person_name text null,
  contact_person_phone text null,
  is_active boolean not null default true,
  building_id text null,
  created_at timestamp with time zone not null default now(),
  updated_at timestamp with time zone not null default now(),
  state_id uuid not null,
  city_id uuid not null,
  rules_file_url text null,
  photos jsonb null default '[]'::jsonb,
  created_by_agent_id uuid null,
  google_maps_link text null,
  is_featured boolean null default false,
  is_popular boolean null default false,
  featured_priority integer null default 0,
  constraint buildings_pkey primary key (id),
  constraint buildings_building_id_key unique (building_id),
  constraint buildings_created_by_agent_id_fkey foreign KEY (created_by_agent_id) references profiles (id),
  constraint buildings_owner_id_fkey foreign KEY (owner_id) references profiles (id) on delete RESTRICT,
  constraint buildings_state_id_fkey foreign KEY (state_id) references states (id),
  constraint buildings_city_id_fkey foreign KEY (city_id) references cities (id),
  constraint buildings_pincode_check check ((pincode ~ '^[0-9]{6}$'::text)),
  constraint buildings_contact_person_phone_check check (
    (contact_person_phone ~ '^[+]?[0-9]{10,15}$'::text)
  )
) TABLESPACE pg_default;

create index IF not exists buildings_owner_id_idx on public.buildings using btree (owner_id) TABLESPACE pg_default;

create index IF not exists buildings_building_type_idx on public.buildings using btree (building_type) TABLESPACE pg_default;

create index IF not exists buildings_is_active_idx on public.buildings using btree (is_active) TABLESPACE pg_default;

create index IF not exists buildings_state_city_idx on public.buildings using btree (state_id, city_id) TABLESPACE pg_default;

create index IF not exists buildings_featured_idx on public.buildings using btree (is_featured, featured_priority desc) TABLESPACE pg_default
where
  (is_featured = true);

create index IF not exists buildings_popular_idx on public.buildings using btree (is_popular) TABLESPACE pg_default
where
  (is_popular = true);

create trigger trigger_generate_building_id BEFORE INSERT on buildings for EACH row when (new.building_id is null)
execute FUNCTION generate_building_id ();