create table public.payments (
  id uuid not null default gen_random_uuid (),
  subscription_id uuid not null,
  month_year date not null,
  amount_paid numeric(10, 2) not null,
  paid_date date not null default CURRENT_DATE,
  payment_method text null,
  transaction_reference text null,
  notes text null,
  created_at timestamp with time zone not null default now(),
  payment_group_id uuid null,
  is_last_payment boolean null default false,
  constraint payments_pkey primary key (id),
  constraint one_payment_per_month unique (subscription_id, month_year),
  constraint payments_subscription_id_fkey foreign KEY (subscription_id) references subscriptions (id) on delete CASCADE,
  constraint payments_amount_paid_check check ((amount_paid > (0)::numeric))
) TABLESPACE pg_default;

create index IF not exists idx_payments_subscription_id on public.payments using btree (subscription_id) TABLESPACE pg_default;

create index IF not exists idx_payments_month_year on public.payments using btree (month_year) TABLESPACE pg_default;

create index IF not exists idx_payments_paid_date on public.payments using btree (paid_date) TABLESPACE pg_default;

create index IF not exists idx_payments_group_id on public.payments using btree (payment_group_id) TABLESPACE pg_default;