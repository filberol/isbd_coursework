select railway_station.id, railway_station.name, company.name as owner
from railway_station join company on railway_station.owner_id = company.id
where railway_station.name like 'M%';

select repair_team_route.id, repair_team_route.repair_team_id, repair_team_route_schedule.planned_at
from repair_team_route join repair_team_route_schedule on
    repair_team_route.id = repair_team_route_schedule.route_id
where planned_at > '1950-01-01 00:00:00' and planned_at < '1950-02-01 00:00:00';

select fault_status, count(*) from segment_fault
where rw_seg_id = 28 group by fault_status;

select rs.name as from_name, rs2.name as to_name from railway_segment
join railway_station rs on railway_segment.from_rs = rs.id
join railway_station rs2 on railway_segment.to_rs = rs2.id
where rs.name like 'North Plaza';
