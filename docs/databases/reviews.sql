create table public.reviews (
  id uuid not null default gen_random_uuid (),
  building_id uuid not null,
  reviewer_id uuid not null,
  subscription_id uuid null,
  rating integer not null,
  review_text text null,
  photos_url text[] null,
  is_verified boolean not null default false,
  helpful_count integer not null default 0,
  created_at timestamp with time zone not null default now(),
  updated_at timestamp with time zone not null default now(),
  constraint reviews_pkey primary key (id),
  constraint reviews_building_id_fkey foreign KEY (building_id) references buildings (id) on delete CASCADE,
  constraint reviews_reviewer_id_fkey foreign KEY (reviewer_id) references profiles (id) on delete RESTRICT,
  constraint reviews_subscription_id_fkey foreign KEY (subscription_id) references subscriptions (id) on delete set null,
  constraint reviews_rating_check check (
    (
      (rating >= 1)
      and (rating <= 5)
    )
  )
) TABLESPACE pg_default;

create index IF not exists reviews_building_id_idx on public.reviews using btree (building_id) TABLESPACE pg_default;

create index IF not exists reviews_reviewer_id_idx on public.reviews using btree (reviewer_id) TABLESPACE pg_default;

create index IF not exists reviews_rating_idx on public.reviews using btree (rating) TABLESPACE pg_default;

create index IF not exists reviews_created_at_idx on public.reviews using btree (created_at) TABLESPACE pg_default;

create index IF not exists reviews_subscription_id_idx on public.reviews using btree (subscription_id) TABLESPACE pg_default;

create unique INDEX IF not exists reviews_building_id_reviewer_id_subscription_id_idx on public.reviews using btree (building_id, reviewer_id, subscription_id) TABLESPACE pg_default
where
  (subscription_id is not null);