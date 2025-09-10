create table public.subscriptions (
  id uuid not null default gen_random_uuid (),
  room_id uuid not null,
  tenant_id uuid not null,
  monthly_rent numeric(10, 2) not null,
  security_deposit numeric(10, 2) null default 0,
  start_date date not null default CURRENT_DATE,
  is_active boolean null default true,
  agreement_file_url text null,
  notes text null,
  created_at timestamp with time zone not null default now(),
  updated_at timestamp with time zone not null default now(),
  termination_date date null,
  terminated_by_agent_id uuid null,
  termination_reason text null,
  status character varying(20) null default 'active'::character varying,
  constraint subscriptions_pkey primary key (id),
  constraint subscriptions_room_id_fkey foreign KEY (room_id) references rooms (id) on delete RESTRICT,
  constraint subscriptions_tenant_id_fkey foreign KEY (tenant_id) references profiles (id) on delete RESTRICT,
  constraint subscriptions_terminated_by_agent_id_fkey foreign KEY (terminated_by_agent_id) references profiles (id),
  constraint subscriptions_security_deposit_check check ((security_deposit >= (0)::numeric)),
  constraint subscriptions_monthly_rent_check check ((monthly_rent > (0)::numeric)),
  constraint subscriptions_status_check check (
    (
      (status)::text = any (
        (
          array[
            'active'::character varying,
            'pending_termination'::character varying,
            'terminated'::character varying
          ]
        )::text[]
      )
    )
  )
) TABLESPACE pg_default;

create unique INDEX IF not exists one_active_subscription_per_room on public.subscriptions using btree (room_id) TABLESPACE pg_default
where
  (is_active = true);

create index IF not exists idx_subscriptions_room_id on public.subscriptions using btree (room_id) TABLESPACE pg_default;

create index IF not exists idx_subscriptions_tenant_id on public.subscriptions using btree (tenant_id) TABLESPACE pg_default;

create index IF not exists idx_subscriptions_active on public.subscriptions using btree (is_active) TABLESPACE pg_default
where
  (is_active = true);