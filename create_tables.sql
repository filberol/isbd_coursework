CREATE TYPE fault_class AS ENUM (
  'critical',
  'non_critical'
);

CREATE TYPE fault_status AS ENUM (
  'not_repaired',
  'in_repair',
  'repaired'
);

CREATE TYPE site_visit_type AS ENUM (
  'inspection',
  'repair'
);

CREATE TABLE company
(
    id   serial PRIMARY KEY,
    name varchar(50) UNIQUE
);

CREATE TABLE railway_station
(
    id       serial PRIMARY KEY,
    name     varchar(50) UNIQUE,
    owner_id integer NOT NULL
);

CREATE TABLE railway_segment
(
    id        serial PRIMARY KEY,
    from_rs   integer NOT NULL,
    to_rs     integer NOT NULL,
    length_km integer
);

CREATE TABLE warehouse
(
    id                     serial PRIMARY KEY,
    station_id             integer,
    resources_available_km integer
);

CREATE TABLE repair_base
(
    id                serial PRIMARY KEY,
    station_id        integer,
    size_teams        integer NOT NULL,
    curr_teams_hosted integer NOT NULL
);

CREATE TABLE segment_fault
(
    id                serial PRIMARY KEY,
    rw_seg_id         integer,
    fault_class       fault_class NOT NULL,
    position_point_km integer,
    fault_status      fault_status NOT NULL
);

CREATE TABLE repair_team_route
(
    id             serial PRIMARY KEY,
    repair_team_id integer,
    from_base_id   integer,
    to_base_id     integer
);

CREATE TABLE repair_team_route_schedule
(
    id          serial PRIMARY KEY,
    route_id    integer,
    planned_at  timestamp NOT NULL,
    departed_at timestamp DEFAULT null,
    arrived_at  timestamp DEFAULT null
);

CREATE TABLE inspection_repair_site
(
    id                 serial PRIMARY KEY,
    route_id           integer,
    railway_segment_id integer,
    position_point_km  integer NOT NULL,
    arrived_at         timestamp DEFAULT null,
    type_site_action   site_visit_type
);

CREATE TABLE site_fault_fixation
(
    id               serial PRIMARY KEY,
    segment_fault_id integer   NOT NULL,
    route_id         integer,
    found_at         timestamp NOT NULL,
    fault_class      fault_class
);

CREATE TABLE repair_team
(
    id           serial PRIMARY KEY,
    owner_id     integer,
    team_head_id integer UNIQUE
);

CREATE TABLE repair_team_member
(
    id             serial PRIMARY KEY,
    name           varchar(50),
    repair_team_id integer
);

CREATE TABLE warehouse_resource_allocation
(
    id                     serial PRIMARY KEY,
    warehouse_id           integer,
    resources_allocated_km integer NOT NULL,
    allocated_at           timestamp
);

CREATE TABLE resource_transportation
(
    id                serial PRIMARY KEY,
    from_warehouse_id integer,
    to_warehouse_id   integer,
    start_at          timestamp,
    finish_at         timestamp DEFAULT null,
    resources_transportation_km integer
);