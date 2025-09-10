create table public.states (
  id uuid not null default gen_random_uuid (),
  name text not null,
  created_at timestamp with time zone not null default now(),
  updated_at timestamp with time zone not null default now(),
  constraint states_pkey primary key (id),
  constraint states_name_key unique (name)
) TABLESPACE pg_default;

create index IF not exists states_name_idx on public.states using btree (name) TABLESPACE pg_default;