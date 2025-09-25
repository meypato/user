create table public.contacts (
  id uuid not null default gen_random_uuid(),
  phone text null,
  email text null,
  whatsapp text null,
  instagram text null,
  facebook text null,
  youtube text null,
  is_active boolean not null default true,
  created_at timestamp with time zone not null default now(),
  updated_at timestamp with time zone not null default now(),
  constraint contacts_pkey primary key (id)
);

create index contacts_is_active_idx on public.contacts using btree (is_active);