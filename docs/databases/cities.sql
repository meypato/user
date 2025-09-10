create table public.cities (
  id uuid not null default gen_random_uuid (),
  state_id uuid not null,
  name text not null,
  created_at timestamp with time zone not null default now(),
  updated_at timestamp with time zone not null default now(),
  constraint cities_pkey primary key (id),
  constraint cities_state_id_name_key unique (state_id, name),
  constraint cities_state_id_fkey foreign KEY (state_id) references states (id) on delete CASCADE
) TABLESPACE pg_default;

create index IF not exists cities_state_id_idx on public.cities using btree (state_id) TABLESPACE pg_default;

create index IF not exists cities_name_idx on public.cities using btree (name) TABLESPACE pg_default;