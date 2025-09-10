create table public.building_profession_exceptions (
  building_id uuid not null,
  profession_id uuid not null,
  constraint building_profession_exceptions_pkey primary key (building_id, profession_id),
  constraint building_profession_exceptions_building_id_fkey foreign KEY (building_id) references buildings (id) on delete CASCADE,
  constraint building_profession_exceptions_profession_id_fkey foreign KEY (profession_id) references professions (id) on delete RESTRICT
) TABLESPACE pg_default;