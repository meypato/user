create table public.professions (
  id uuid not null default gen_random_uuid (),
  name text not null,
  created_at timestamp with time zone not null default now(),
  updated_at timestamp with time zone not null default now(),
  constraint professions_pkey primary key (id),
  constraint professions_name_key unique (name)
) TABLESPACE pg_default;

create index IF not exists professions_name_idx on public.professions using btree (name) TABLESPACE pg_default;