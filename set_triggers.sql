-- При удалении регистрации должна удаляться поломка
create or replace function delete_fault_with_fixation_trigger()
    returns trigger as $$
begin
    delete from segment_fault where id = new.segment_fault_id;
    return new;
end $$ language plpgsql;

create trigger delete_fault_with_fixation
    after delete on site_fault_fixation for each row
    execute function delete_fault_with_fixation_trigger();


-- Нельзя удалить расписание у существующего маршрута
create or replace function prevent_delete_route_schedule_trigger()
    returns trigger as $$
begin
    if exists(select 1 from repair_team_route where id = new.route_id) then
        raise exception 'Cannot delete schedule for existing route';
    end if;
    return new;
end $$ language plpgsql;

create trigger prevent_delete_route_schedule
    before delete on repair_team_route_schedule for each row
    execute function prevent_delete_route_schedule_trigger();


-- warehouse.resources_available_km - вычисляемое поля
---- Warehouse resource allocation
-- (trigger on insert warehouse_resource_allocation)
create or replace function add_resources_to_warehouse_trigger()
    returns trigger as $$
begin
    update warehouse
    set resources_available_km = resources_available_km + new.resources_allocated_km
    where id = new.warehouse_id;
    return new;
end $$ language plpgsql;
-- (trigger to cancel resource allocation)
create or replace function cancel_add_resources_to_warehouse_trigger()
    returns trigger as $$
begin
    update warehouse
    set resources_available_km = resources_available_km - new.resources_allocated_km
    where id = new.warehouse_id;
    return new;
end $$ language plpgsql;

create trigger add_resources_to_warehouse
    after insert on warehouse_resource_allocation for each row
    execute function add_resources_to_warehouse_trigger();
create trigger cancel_add_resources_to_warehouse
    after delete on warehouse_resource_allocation for each row
    execute function cancel_add_resources_to_warehouse_trigger();

---- Warehouse resource transportation
-- (trigger to plan resource transportation)
create or replace function depart_resources_to_warehouse_trigger()
    returns trigger as $$
begin
    update warehouse
    set resources_available_km = warehouse.resources_available_km - 10
    where id = new.from_warehouse_id;
    return new;
end $$ language plpgsql;

-- (trigger to finish resource transportation)
create or replace function arrive_resources_to_warehouse_trigger()
    returns trigger as $$
begin
    if new.finish_at is not null then
        update warehouse
        set resources_available_km = warehouse.resources_available_km + 10
        where id = new.to_warehouse_id;
    end if;
    return new;
end $$ language plpgsql;

-- (trigger to cancel resource transportation)
create or replace function cancel_transport_to_warehouse_trigger()
    returns trigger as $$
begin
    -- return to new warehouse
    update warehouse
    set resources_available_km = warehouse.resources_available_km + 10
    where id = new.from_warehouse_id;
    -- if added to new then go back
    if new.finish_at is not null then
        update warehouse
        set resources_available_km = warehouse.resources_available_km - 10
        where id = new.to_warehouse_id;
    end if;
    return new;
end $$ language plpgsql;

create trigger depart_resources_to_warehouse
    after insert on resource_transportation for each row
    execute function depart_resources_to_warehouse_trigger();
create trigger arrive_resources_to_warehouse
    after update or insert on resource_transportation for each row
    execute function arrive_resources_to_warehouse_trigger();
create trigger cancel_transport_to_warehouse
    after delete on resource_transportation for each row
    execute function cancel_transport_to_warehouse_trigger();


-- repair_base.current_teams_hosted - вычисляемое поле
-- (trigger to plan team route)
create or replace function depart_repair_team_to_base_trigger()
    returns trigger as $$
begin
    update repair_base
    set curr_teams_hosted = curr_teams_hosted - 1
    where id = (
        select from_base_id from repair_team_route where id = new.route_id
            );
    return new;
end $$ language plpgsql;

-- (trigger to finish team route)
create or replace function arrive_repair_team_to_base_trigger()
    returns trigger as $$
begin
    if new.arrived_at is not null then
        update repair_base
        set curr_teams_hosted = curr_teams_hosted + 1
        where id = (
            select to_base_id from repair_team_route where id = new.route_id
            );
    end if;
    return new;
end $$ language plpgsql;

-- (trigger to cancel team route)
create or replace function cancel_team_route_trigger()
    returns trigger as $$
begin
    update repair_base
    set curr_teams_hosted = curr_teams_hosted + 1
    where id = (
        select from_base_id from repair_team_route where id = new.route_id
    );
    if new.arrived_at is not null then
        update repair_base
        set curr_teams_hosted = curr_teams_hosted - 1
        where id = (
            select to_base_id from repair_team_route where id = new.route_id
        );
    end if;
    return new;
end $$ language plpgsql;

create trigger depart_repair_team_to_base
    after insert on repair_team_route_schedule for each row
    execute function depart_repair_team_to_base_trigger();
create trigger arrive_repair_team_to_base
    after update or insert on repair_team_route_schedule for each row
    execute function arrive_repair_team_to_base_trigger();
create or replace trigger cancel_team_route
    after delete on repair_team_route_schedule for each row
    execute function cancel_team_route_trigger();
