select add_company('ООО "Trik Synergy"');
select add_company('ООО "Rik Synergy"');

select add_railway_station('Monday Station', 'ООО "Trik Synergy"');
select add_railway_station('Tuesday Station', 'ООО "Trik Synergy"');

-- select add_railway_segment('Monday Station', 'Tuesday Station', 100);

select init_warehouse('Tuesday Station');

select init_repair_base('Tuesday Station');

-- select add_railway_station_and_segment('Saturday Station', 'ООО "Rik Synergy', 23, 320);

select add_repair_team('ООО "Trik Synergy"');

select add_repair_team_member(1, 'Dagni Tagarat');

select change_team_affiliation(1, 'Dagni Tagarat');


select set_team_head(1, 'Ken Bort');

select new_warehouse_resource_allocation('Saturday Station', 40, '1947-10-10 17:23:06.000000');

select start_resource_transportation('Monday Station', 'Saturday Station', 30, '1947-10-11 17:23:06.000000');

select get_critical_not_repaired_fault();

select get_id_critical_not_repaired_fault();

select get_id_segment_fault('in_repair');


