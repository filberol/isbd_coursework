drop table if exists repair_team_route_schedule cascade;
drop table if exists inspection_repair_site cascade;
drop table if exists site_fault_fixation cascade;
drop table if exists segment_fault cascade;
drop table if exists railway_segment cascade;
drop table if exists repair_team_route cascade;
drop table if exists repair_base cascade;
alter table repair_team
    drop constraint if exists repair_team_team_head_id_fkey cascade;
alter table repair_team
    drop constraint if exists check_head_exists cascade;
drop table if exists repair_team_member cascade;
drop table if exists repair_team cascade;
drop table if exists warehouse_resource_allocation cascade;
drop table if exists resource_transportation cascade;
drop table if exists warehouse cascade;
drop table if exists railway_station cascade;
drop table if exists company cascade;

drop function if exists delete_fault_with_fixation_trigger() cascade;
drop function if exists prevent_delete_route_schedule_trigger() cascade;
drop function if exists add_resources_to_warehouse_trigger() cascade;
drop function if exists cancel_add_resources_to_warehouse_trigger() cascade;
drop function if exists depart_resources_to_warehouse_trigger() cascade;
drop function if exists arrive_resources_to_warehouse_trigger() cascade;
drop function if exists cancel_transport_to_warehouse_trigger() cascade;
drop function if exists depart_repair_team_to_base_trigger() cascade;
drop function if exists arrive_repair_team_to_base_trigger() cascade;
drop function if exists cancel_team_route_trigger() cascade;

drop type if exists fault_class cascade;
drop type if exists fault_status cascade;
drop type if exists site_visit_type cascade;
