\create table public.building_tribe_exceptions (
  building_id uuid not null,
  tribe_id uuid not null,
  constraint building_tribe_exceptions_pkey primary key (building_id, tribe_id),
  constraint building_tribe_exceptions_building_id_fkey foreign KEY (building_id) references buildings (id) on delete CASCADE,
  constraint building_tribe_exceptions_tribe_id_fkey foreign KEY (tribe_id) references tribes (id) on delete RESTRICT
) TABLESPACE pg_default;