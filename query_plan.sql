explain select * from railway_station where name = 'Sunset-East Center Terminal';

explain select * from company where company.name = 'ООО "Omega Dynamics"';

explain select * from repair_team_route_schedule where planned_at = '1946-01-04 10:37:27.000000';

explain select count(*) from segment_fault where fault_class = 'critical';

explain select * from site_fault_fixation where segment_fault_id = 12;