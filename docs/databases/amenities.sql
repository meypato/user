create table public.amenities (
  id uuid not null default gen_random_uuid (),
  name text not null,
  category text null,
  created_at timestamp with time zone not null default now(),
  updated_at timestamp with time zone not null default now(),
  constraint amenities_pkey primary key (id),
  constraint amenities_name_key unique (name),
  constraint amenities_category_check check (
    (
      length(
        TRIM(
          both
          from
            category
        )
      ) > 0
    )
  ),
  constraint amenities_name_check check (
    (
      length(
        TRIM(
          both
          from
            name
        )
      ) > 0
    )
  )
) TABLESPACE pg_default;

create index IF not exists amenities_name_idx on public.amenities using btree (name) TABLESPACE pg_default;

create index IF not exists amenities_category_idx on public.amenities using btree (category) TABLESPACE pg_default;