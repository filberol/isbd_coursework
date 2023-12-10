-- �������� ����� ��������
create or replace function add_company(company_name varchar(50))
    returns void as
$$
BEGIN
    insert into company(name) values (company_name);
end
$$ language plpgsql;
-- �������� ����� ������� � railway_station �� id ���������
create or replace function add_railway_station(station_name varchar(50), owner integer)
    returns void as
$$
BEGIN
    insert into railway_station(name, owner_id) values (station_name, owner);
end
$$ language plpgsql;

-- �������� ����� ������� � railway_station �� ����� ���������
create or replace function add_railway_station(name varchar(50), owner varchar(50))
    returns void as
$$
BEGIN
    perform add_railway_station(name, (select id from company where company.name = owner));
end
$$ language plpgsql;


-- �������� ���������� � ������� � railway_segment �� id �������
create or replace function add_railway_segment(rs_from integer, rs_to integer, length integer)
    returns void as
$$
BEGIN
    insert into railway_segment(from_rs, to_rs, length_km) values (rs_from, rs_to, length);
end
$$ language plpgsql;

-- �������� ���������� � ������� � railway_segment �� ������ �������
create or replace function add_railway_segment(rs_from varchar(50), rs_to varchar(50), length integer)
    returns void as
$$
BEGIN
    perform add_railway_segment((select id from railway_station where name = rs_from),
                                (select id from railway_station where name = rs_to), length);
end
$$ language plpgsql;

-- ��������� ������� �����
create or replace function init_warehouse(station_name varchar(50))
    returns void as
$$
BEGIN
    insert into warehouse(station_id, resources_available_km)
    values ((select id
             from railway_station
             where name = station_name), 0);
end
$$ language plpgsql;
-- ��������� ������� repair_base
create or replace function init_repair_base(station_name varchar(50))
    returns void as
$$
BEGIN
    insert into repair_base(station_id, size_teams, curr_teams_hosted)
    values ((select id
             from railway_station
             where name = station_name), 0, 0);
end
$$ language plpgsql;

-- �������� ����� ������� � railway_segment �� id, ��������� ����� � repair_base
create or replace function add_railway_station_and_segment(name varchar(50), owner_id integer, rs_from integer,
                                                           rs_to integer, length integer)
    returns void as
$$
BEGIN
    perform add_railway_station(name, owner_id);
    perform add_railway_segment(rs_from, rs_to, length);
    perform init_warehouse(name);
    perform init_repair_base(name);
end
$$ language plpgsql;

-- �������� ����� ������� � railway_segment �� ������, ��������� ����� � repair_base
create or replace function add_railway_station_and_segment(name varchar(50), owner varchar(50), rs_from varchar(50),
                                                           rs_to varchar(50), length integer)
    returns void as
$$
BEGIN
    perform add_railway_station(name, (select id from company where company.name = owner));
    perform add_railway_segment((select id from railway_station where railway_station.name = rs_from),
                                (select id from railway_station where railway_station.name = rs_to), length);
    perform init_warehouse(name);
    perform init_repair_base(name);
end
$$ language plpgsql;

-- ������� ����� �������
create or replace function add_repair_team(owner integer)
    returns void as
$$
BEGIN
    insert into repair_team(owner_id) values (owner);
end
$$ language plpgsql;

--�������� ��������� � �������
create or replace function add_repair_team_member(team_id integer, member_name varchar(50))
    returns void as
$$
BEGIN
    insert into repair_team_member(name, repair_team_id) values (member_name, team_id);
end
$$ language plpgsql;

-- ������� ����� �������
create or replace function set_team_head(team_id integer, member_name integer)
    returns void as
$$
BEGIN
    update repair_team
    set team_head_id=(select id from repair_team_member where repair_team_id = team_id and name = member_name)
    where repair_team.id = team_id;
end
$$ language plpgsql;

-- ������ �������� �����
create or replace function new_warehouse_resource_allocation(station_name varchar(50), resources_km integer, allocated timestamp)
    returns void as
$$
BEGIN
    insert into warehouse_resource_allocation(warehouse_id, resources_allocated_km, allocated_at)
    values ((select id from warehouse where station_id = (select id from railway_station where name = station_name)),
            resources_km, allocated);
end
$$ language plpgsql;

-- ������ ��������������� ��������
create or replace function start_resource_transportation(from_station varchar(50), to_station varchar(50),
                                                         resource_km integer, start timestamp)
    returns void as
$$
BEGIN
    insert into resource_transportation(from_warehouse_id, to_warehouse_id, start_at, resources_transportation_km)
    values ((select id
             from warehouse
             where station_id = (select id
                                 from railway_station
                                 where name = from_station)), (select id
                                                               from warehouse
                                                               where station_id = (select id
                                                                                   from railway_station
                                                                                   where name = to_station)), start,
            resource_km);
end
$$ language plpgsql;

-- ��������� ��������������� ��������
create or replace function start_resource_transportation(transportation_id integer, finish timestamp)
    returns void as
$$
BEGIN
    update resource_transportation
    set finish_at = finish
    where id = transportation_id;
    update warehouse
    set resources_available_km = resources_available_km + (select resources_transportation_km
                                                          from resource_transportation
                                                          where id = transportation_id);
end
$$ language plpgsql;

-- ��������� ������� �������
create or replace function appoint_route_repair_team(team_id integer, from_station varchar(50), to_station varchar(50))
    returns void as
$$
BEGIN
    insert into repair_team_route(repair_team_id, from_base_id, to_base_id)
    values (team_id,
            (select id from repair_base where station_id = (select id from railway_station where name = from_station)),
            (select id from repair_base where station_id = (select id from railway_station where name = to_station)));
    update repair_base set size_teams=size_teams + 1;
end
$$ language plpgsql;

-- ���������������� �������
create or replace function add_new_fault(railway_seg_id integer, class fault_class, position_km integer, route integer,
                                         found timestamp,
                                         status fault_status)
    returns void as
$$
DECLARE
    seg_fault_id integer;
BEGIN
    seg_fault_id := add_segment_fault(railway_seg_id, class, position_km, status);
    select add_site_fault_fixation(seg_fault_id, route, found, class);
end
$$ language plpgsql;


-- �������� segment_fault
create or replace function add_segment_fault(railway_seg_id integer, class fault_class, position_km integer,
                                             status fault_status)
    returns integer as
$$
declare
    seg_fault_id integer;
begin
    insert into segment_fault
    values (default, railway_seg_id, class, position_km, status)
    returning segment_fault.id into seg_fault_id;
    return seg_fault_id;
end
$$ language plpgsql;
-- �������� segment_fault_fixation
create or replace function add_site_fault_fixation(seg_fault_id integer, route integer, found timestamp,
                                                   class fault_class)
    returns void as
$$

begin
    insert into site_fault_fixation values (default, seg_fault_id, route, found, class);
end
$$ language plpgsql;


-- ������ ������� �������
create or replace function start_fix_segment_fault(segment_fault_id integer)
    returns void as
$$
begin
    update segment_fault set fault_status='in_repair' where id = segment_fault_id;
end
$$ language plpgsql;

-- �������� ����������
create or replace function finish_fix_segment_fault(segment_fault_id integer)
    returns void as
$$
begin
    update segment_fault set fault_status='repaired' where id = segment_fault_id;
end
$$ language plpgsql;


-- ��������� � ��������
create or replace function add_site(route integer, rw_seg_id integer, position_km integer, arrived timestamp,
                                    type_site site_visit_type)
    returns void as
$$
begin
    insert into inspection_repair_site(route_id, railway_segment_id, position_point_km, arrived_at, type_site_action)
    values (route, rw_seg_id, position_km, arrived, type_site);
end
$$ language plpgsql;

-- �������� ��� �������� ����������� ������� � ��������� ����
create or replace function get_critical_not_repaired_fault()
    returns TABLE
            (
                rs_from           varchar(50),
                rs_to             varchar(50),
                position_point_km integer
            )
as
$$
begin
    return query select rw_station_from.name as rs_from, rw_station_to.name as rs_to, position_point_km
                 from railway_segment
                          join (select rw_seg_id, position_point_km
                                from segment_fault
                                where fault_status = 'not_repaired'
                                  and fault_class = 'critical') as seg_fault on railway_segment.id = seg_fault.rw_seg_id
                          join railway_station as rw_station_from on railway_segment.from_rs = rw_station_from.id
                          join railway_station as rw_station_to on railway_segment.to_rs = rw_station_to.id;
end
$$ language plpgsql;


-- �������� id ���� �������� ����������� �������
create or replace function get_id_critical_not_repaired_fault()
    returns TABLE
            (
                id integer
            )
as
$$
begin
    return query select id
                 from segment_fault
                 where fault_status = 'not_repaired'
                   and fault_class = 'critical';
end
$$ language plpgsql;

-- �������� id ���� ������� �� fault_status
create or replace function get_id_segment_fault(status fault_status)
    returns TABLE
            (
                id integer
            )
as
$$
begin
    return query select id
                 from segment_fault
                 where fault_status = status;
end
$$ language plpgsql;

-- �������� id ���� ������� �� fault_class
create or replace function get_id_segment_fault(class fault_class)
    returns TABLE
            (
                id integer
            )
as
$$
begin
    return query select id
                 from segment_fault
                 where fault_class = class;
end
$$ language plpgsql;


-- �������� id ���� ������� �� fault_class � fault_status
create or replace function get_id_segment_fault(class fault_class, status fault_status)
    returns TABLE
            (
                id integer
            )
as
$$
begin
    return query select id
                 from segment_fault
                 where fault_class = class
                   and fault_status = status;
end
$$ language plpgsql;

--  �������� ���������� ������� �� �����-�� � ����� �� ����������

create or replace function get_repair_team_schedule(team_id integer, start timestamp, finish timestamp)
    returns TABLE
            (
                planned_at timestamp
            )
as
$$
begin
    return query select planned_at
                 from repair_team_route_schedule
                          join repair_team_route rtr on repair_team_route_schedule.route_id = rtr.id
                          join repair_team rt on rtr.repair_team_id = rt.id
                 where planned_at >= start
                   and finish <= repair_team_route_schedule.planned_at
                   and rt = team_id
                 order by planned_at;
end
$$ language plpgsql;

-- ������ ���������� ��������
create or replace function start_repair_team_route(team_id integer, arrived timestamp)
    returns void as
$$
begin
    update repair_team_route_schedule
    set arrived_at= arrived
    where route_id = (select id from repair_team_route where repair_team_id = team_id);
end
$$ language plpgsql;

-- ��������� ���������� ��������
create or replace function finish_repair_team_route(team_id integer, departed timestamp)
    returns void as
$$
begin
    update repair_team_route_schedule
    set departed_at= departed
    where route_id = (select id from repair_team_route where repair_team_id = team_id);
end
$$ language plpgsql;