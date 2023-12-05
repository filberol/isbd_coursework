-- У компаний уникальные имена и они имеют ограничение на формат
alter table company
    add constraint check_regex_constraint
        check (company.name ~ '^ООО "([^"]+)"');

-- При удалении компании принадлежность станций и дорог обнуляется (on drop set null)
alter table railway_station
    add constraint check_owner_exists
        foreign key (owner_id) references company (id) on delete set null;

-- Но одну станцию может приходиться только одна ремонтная база и склад
alter table warehouse
    add constraint warehouse_unique_for_station
        unique (station_id);

alter table repair_base
    add constraint repair_base_unique_for_station
        unique (station_id);

-- При удалении станции должны удаляться доступные пути (on drop cascade)
alter table railway_segment
    add constraint existing_station_on_start
        foreign key (from_rs) references railway_station (id) on delete cascade,
    add constraint existing_station_on_end
        foreign key (to_rs) references railway_station (id) on delete cascade;

-- Нельзя удалить поломку при наличии ее регистрации (on delete restrict)
alter table site_fault_fixation
    add constraint segment_fault_unique
        unique (segment_fault_id),
    add constraint fault_has_fixation
        foreign key (segment_fault_id) references segment_fault (id) on delete restrict;

-- При удалении маршрута удаляются инспекции (on delete cascade)
alter table inspection_repair_site
    add constraint check_route_exists
        foreign key (route_id) references repair_team_route (id) on delete cascade;

-- При удалении пути удаляется расписание (on drop cascade)
alter table repair_team_route_schedule
    add constraint check_route_exists
        foreign key (route_id) references repair_team_route (id) on delete cascade;

-- arrived_at > departed_at
alter table repair_team_route_schedule
    add constraint timestamp_chronology
        check ( arrived_at > departed_at or arrived_at is null);

-- Нельзя перевезти ресурсы в тот же город, прибытие после отправления
alter table resource_transportation
    add constraint different_points
        check ( from_warehouse_id != to_warehouse_id );

-- Команда может остаться без главы (on delete set null)
alter table repair_team
    add constraint check_owner_exists
        foreign key (owner_id) references company (id) on delete set null,
    add constraint check_head_exists
        foreign key (team_head_id) references repair_team_member (id) on delete set null;
