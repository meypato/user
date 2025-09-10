create table public.profiles (
  id uuid not null,
  full_name text not null,
  photo_url text null,
  role public.user_role not null default 'tenant'::user_role,
  identification_file_url text null,
  police_verification_file_url text null,
  age integer null,
  sex public.sex_type null,
  tribe_id uuid null,
  apst public.apst_status null,
  address_line1 text null,
  address_line2 text null,
  country text not null default 'India'::text,
  pincode text null,
  is_verified boolean not null default false,
  verification_state public.verification_status not null default 'unverified'::verification_status,
  profession_id uuid null,
  phone text null,
  email text null,
  emergency_contact_name text null,
  emergency_contact_phone text null,
  is_active boolean not null default true,
  created_at timestamp with time zone not null default now(),
  updated_at timestamp with time zone not null default now(),
  state_id uuid not null,
  city_id uuid not null,
  constraint profiles_pkey primary key (id),
  constraint profiles_email_key unique (email),
  constraint profiles_city_id_fkey foreign KEY (city_id) references cities (id),
  constraint profiles_tribe_id_fkey foreign KEY (tribe_id) references tribes (id) on delete set null,
  constraint profiles_id_fkey foreign KEY (id) references auth.users (id) on delete CASCADE,
  constraint profiles_state_id_fkey foreign KEY (state_id) references states (id),
  constraint profiles_profession_id_fkey foreign KEY (profession_id) references professions (id) on delete set null,
  constraint profiles_phone_check check ((phone ~ '^[+]?[0-9]{10,15}$'::text)),
  constraint profiles_email_check check (
    (
      email ~ '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$'::text
    )
  ),
  constraint profiles_emergency_contact_phone_check check (
    (
      emergency_contact_phone ~ '^[+]?[0-9]{10,15}$'::text
    )
  ),
  constraint profiles_age_check check (
    (
      (age is null)
      or (
        (age >= 18)
        and (age <= 120)
      )
    )
  ),
  constraint profiles_pincode_check check ((pincode ~ '^[0-9]{6}$'::text))
) TABLESPACE pg_default;

create index IF not exists profiles_role_idx on public.profiles using btree (role) TABLESPACE pg_default;

create index IF not exists profiles_tribe_id_idx on public.profiles using btree (tribe_id) TABLESPACE pg_default;

create index IF not exists profiles_profession_id_idx on public.profiles using btree (profession_id) TABLESPACE pg_default;

create index IF not exists profiles_verification_state_idx on public.profiles using btree (verification_state) TABLESPACE pg_default;

create index IF not exists profiles_state_city_idx on public.profiles using btree (state_id, city_id) TABLESPACE pg_default;