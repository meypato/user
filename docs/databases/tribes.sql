create table public.tribes (
  id uuid not null default gen_random_uuid (),
  name text not null,
  created_at timestamp with time zone not null default now(),
  updated_at timestamp with time zone not null default now(),
  constraint tribes_pkey primary key (id),
  constraint tribes_name_key unique (name)
) TABLESPACE pg_default;

create index IF not exists tribes_name_idx on public.tribes using btree (name) TABLESPACE pg_default;