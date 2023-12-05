-- При удалении регистрации должна удаляться поломка
create or replace function delete_fault_with_fixation_trigger()
    returns trigger as $$
begin
    delete from segment_fault where id = old.segment_fault_id;
    return old;
end; $$ language plpgsql;

create trigger delete_fault_with_fixation
    after delete on site_fault_fixation for each row
    execute function delete_fault_with_fixation_trigger();

-- Нельзя удалить расписание у существующего маршрута
create or replace function prevent_delete_route_schedule_trigger()
    returns trigger as $$
begin
    if exists(select 1 from repair_team_route where id = old.route_id) then
        raise exception 'Cannot delete schedule for existing route';
    end if;
    return old;
end; $$ language plpgsql;

create trigger prevent_delete_route_schedule
    before delete on repair_team_route_schedule for each row
    execute function prevent_delete_route_schedule_trigger();

-- warehouse.resources_available_km - вычисляемое поля
-- (trigger on insert warehouse_resource_allocation)
-- (trigger on update resource transportation)
create or replace function add_resources_to_warehouse_trigger()
    returns trigger as $$
begin
    update warehouse
    set resources_available_km = resources_available_km + old.resources_allocated_km
    where id = old.warehouse_id;
end; $$ language plpgsql;

-- Adds resources to certain warehouse
create trigger add_resources_to_warehouse
    after insert on warehouse_resource_allocation for each row
    execute function add_resources_to_warehouse_trigger();

create or replace function depart_resources_to_warehouse_trigger()
    returns trigger as $$
begin
    update warehouse
    set resources_available_km = warehouse.resources_available_km - 10
    where id = old.from_warehouse_id;
end; $$ language plpgsql;

-- Removes resources when the route is planned
create trigger depart_resources_to_warehouse
    after insert on resource_transportation for each row
execute function depart_resources_to_warehouse_trigger();

create or replace function arrive_resources_to_warehouse_trigger()
    returns trigger as $$
begin
    if old.finish_at is not null then
        update warehouse
        set resources_available_km = warehouse.resources_available_km + 10
        where id = old.to_warehouse_id;
    end if;
end; $$ language plpgsql;

-- Adds resources when the route is ended
create trigger arrive_resources_to_warehouse
    after update on resource_transportation for each row
execute function arrive_resources_to_warehouse_trigger();

-- repair_base.current_teams_hosted - вычисляемое поле
-- (trigger on update repair_team_route_schedule)
create or replace function depart_repair_team_to_base_trigger()
    returns trigger as $$
begin
    update repair_base
    set curr_teams_hosted = curr_teams_hosted - 1
    where id = (
        select from_base_id from repair_team_route where id = old.route_id
            );
end; $$ language plpgsql;

-- Removes team from available when the route is planned
create trigger depart_repair_team_to_base
    after insert on repair_team_route_schedule for each row
execute function depart_repair_team_to_base_trigger();

create or replace function arrive_repair_team_to_base_trigger()
    returns trigger as $$
begin
    if old.arrived_at is not null then
        update repair_base
        set curr_teams_hosted = curr_teams_hosted + 1
        where id = (
            select to_base_id from repair_team_route where id = old.route_id
            );
    end if;
end; $$ language plpgsql;

-- Adds team to available when the route is ended
create trigger arrive_repair_team_to_base
    after update on repair_team_route_schedule for each row
execute function arrive_repair_team_to_base_trigger();
