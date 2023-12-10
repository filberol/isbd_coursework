import random
from datetime import datetime, timedelta

# Company
company_count, company_names = 100, set()
# Railway station
railway_station_count, railway_station_names = 100, set()
# Railway segment
railway_segment_count, railway_segment_lengths = 500, []
railway_graph: list[list[tuple[int, int, int]]] = [[] for _ in range(railway_segment_count)]
#               from -> (to_bs, seg_id, length)
min_seg_len, max_seg_len = 15, 150
# Repair team members
people_count, people_names = 200, set()
# Repair teams
repair_team_count = 100
# Repair base
base_max_host = 20
# Warehouses
transportations_for_base_max = 5
# Warehouse resource allocation
allocations_for_base_max = 10
allocation_max_km = 400
# Team routes
team_routes_count = 1000
unfinished_routes = 10
inspections_for_route = 3
# Segment fault
segment_fault_ids: list[list[int]] = [[] for _ in range(railway_segment_count)]    # seg_id -> (fault_id, seg_ptr)

fault_classes = ['critical', 'non_critical']


# Utils
def generate_random_timestamp_and_offset(start_year, end_year):
    year = random.randint(start_year, end_year)
    month = random.randint(1, 12)
    day = random.randint(1, 28)  # Assuming all months have 28 days for simplicity
    diff_day = random.randint(1, 5)
    hour = random.randint(0, 23)
    diff_hour = random.randint(0, 23)
    minute = random.randint(0, 59)
    diff_minute = random.randint(0, 59)
    second = random.randint(0, 59)
    diff_second = random.randint(0, 56)
    timestamp = datetime(year, month, day, hour, minute, second)
    offset = timestamp + timedelta(days=diff_day, hours=diff_hour, minutes=diff_minute, seconds=diff_second)
    timestamp_string = timestamp.strftime("%Y-%m-%d %H:%M:%S")
    offset_string = offset.strftime("%Y-%m-%d %H:%M:%S")
    return timestamp_string, offset_string


def interpolate_timestamps(timestamp1: str, timestamp2: str, fraction: float):
    dt1 = datetime.strptime(timestamp1, '%Y-%m-%d %H:%M:%S')
    dt2 = datetime.strptime(timestamp2, '%Y-%m-%d %H:%M:%S')
    time_difference = dt2 - dt1
    interpolated_timestamp = dt1 + fraction * time_difference
    interpolated_timestamp_str = interpolated_timestamp.strftime('%Y-%m-%d %H:%M:%S')
    return interpolated_timestamp_str


def get_random_diff_ids(max_id):
    from_wh = random.randint(1, max_id)
    to_wh = 0
    while to_wh == 0 or to_wh == from_wh:
        to_wh = random.randint(1, max_id)
    return from_wh, to_wh


# Generate data for table company
def generate_companies(file):
    prefixes = ["Atlas", "Innovate", "Dynamo", "Aegis", "Liberty", "Strive", "Omega", "Catalyst", "Apex", "Vanguard"]
    suffixes = ["Industries", "Technologies", "Solutions", "Enterprises", "Dynamics", "Synergy", "Ventures", "Pinnacle",
                "Horizon", "Catalyst"]
    while len(company_names) < company_count:
        name = f"{random.choice(prefixes)} {random.choice(suffixes)}"
        company_names.add(name)
    for name in company_names:
        file.write(f"insert into company (name) values('ООО \"{name}\"');\n")
    return company_names


def generate_stations(file):
    prefixes = ["Central", "North", "South", "East", "West", "Mid", "Grand", "Sunset", "Moonlight", "Silver"]
    suffixes = ["Station", "Junction", "Terminal", "Hub", "Crossing", "Point", "Plaza", "Square", "Park", "Center"]
    while len(railway_station_names) < railway_station_count:
        name = f"{random.choice(prefixes)} {random.choice(suffixes)}"
        railway_station_names.add(name)
    for name in railway_station_names:
        owner_id = random.randint(1, company_count)
        file.write(f"insert into railway_station (name, owner_id) values('{name}', {owner_id});\n")


def generate_railway_segments(file):
    for index in range(railway_segment_count):
        length_km = random.randint(min_seg_len, max_seg_len)
        railway_segment_lengths.append(length_km)
        from_rs = random.randint(1, railway_station_count)
        to_rs = random.randint(1, railway_station_count)
        railway_graph[from_rs - 1].append((to_rs, index + 1, length_km))
        railway_graph[to_rs - 1].append((from_rs, index + 1, length_km))
        file.write(
            f"insert into railway_segment (from_rs, to_rs, length_km) values({from_rs}, {to_rs}, {length_km});\n"
        )


def create_people_names():
    prefixes = ["John", "Jane", "Alice", "Bob", "Eva", "Max", "Zara", "Xander", "Luna", "Quincy", "Olivia", "David",
                "Sophia", "Milo", "Aria"]
    suffixes = ["Smith", "Johnson", "Brown", "Garcia", "Lee", "Kumar", "Lopez", "Chang", "Nikolaev", "Strange",
                "Perez", "Walker", "Mikhu", "Cruz", "Bell", "Harrison", "Chernova"]
    while len(people_names) < people_count:
        name = f"{random.choice(prefixes)} {random.choice(suffixes)}"
        people_names.add(name)


def generate_teams_and_members(file):
    people_in_team = people_count // repair_team_count
    team_id = 0
    names_list = list(people_names)
    for base_index in range(1, people_count - 1, people_in_team):
        team_id += 1
        owner_id = random.randint(1, company_count)
        file.write(f"insert into repair_team (owner_id, team_head_id) values({owner_id}, null);\n")
        for person_index in range(base_index, base_index + people_in_team):
            name = names_list[person_index]
            file.write(f"insert into repair_team_member (name, repair_team_id) values(\'{name}\', {team_id});\n")
        file.write(f"update repair_team set team_head_id={base_index} where id={team_id};\n")


def generate_warehouses_and_repair_bases(file):
    ware_count, base_count = 0, 0
    for station_index in range(1, railway_station_count + 1):
        base_size = random.randint(1, base_max_host)
        if random.randint(1, 3) > 2:
            base_count += 1
            file.write(
                f"insert into repair_base (station_id, size_teams, curr_teams_hosted)"
                f" values({station_index}, {base_size}, 0);\n"
            )
        if random.randint(1, 3) > 1:
            ware_count += 1
            file.write(
                f"insert into warehouse (station_id, resources_available_km) values({station_index}, 0);\n"
            )
    return base_count, ware_count


def generate_resource_allocation(file, warehouses_count):
    for warehouse_id in range(1, warehouses_count + 1):
        allocations = random.randint(1, allocations_for_base_max)
        for i in range(allocations):
            alloc = random.randint(1, allocation_max_km)
            time = generate_random_timestamp_and_offset(1945, 1955)[0]
            file.write(f"insert into warehouse_resource_allocation "
                       f"(warehouse_id, resources_allocated_km, allocated_at) "
                       f"values({warehouse_id}, {alloc}, '{time}');\n")


def generate_resource_transportation(file, warehouses_count):
    for warehouse_id in range(1, warehouses_count + 1):
        transportations = random.randint(1, transportations_for_base_max)
        for i in range(transportations - 1):
            from_wh, to_wh = get_random_diff_ids(warehouses_count)
            time1, time2 = generate_random_timestamp_and_offset(1946, 1955)
            file.write(f"insert into resource_transportation "
                       f"(from_warehouse_id, to_warehouse_id, start_at, finish_at) "
                       f"values ({from_wh}, {to_wh}, '{time1}', '{time2}');\n")
        if random.randint(1, 3) > 1:
            from_wh, to_wh = get_random_diff_ids(warehouses_count)
            time1 = generate_random_timestamp_and_offset(1955, 1955)[0]
            file.write(f"insert into resource_transportation "
                       f"(from_warehouse_id, to_warehouse_id, start_at, finish_at) "
                       f"values ({from_wh}, {to_wh}, '{time1}', null);\n")


def generate_repair_team_routes(file, base_count):
    time_pairs = [generate_random_timestamp_and_offset(1946, 1955) for _ in range(team_routes_count)]
    time_pairs.sort(key=lambda x: x[0])
    curr_fault_id = 1
    for route_ind in range(team_routes_count - unfinished_routes):
        team_id = random.randint(1, repair_team_count - 1)
        from_bs, to_bs = get_random_diff_ids(base_count)
        time1, time2 = time_pairs[route_ind]
        dep_time: str = time1[:-1] + '0'
        # Add route and schedule
        file.write(f"insert into repair_team_route (repair_team_id, from_base_id, to_base_id) "
                   f"values ({team_id}, {from_bs}, {to_bs});\n")
        file.write(f"insert into repair_team_route_schedule (route_id, planned_at, departed_at, arrived_at) "
                   f"values ({route_ind + 1}, '{time1}', '{dep_time}', '{time2}');\n")
        # Add found faults
        try:
            _, seg_id, seg_length = next((x for x in railway_graph[from_bs] if x[0] == to_bs))
            real_inspections = random.randint(1, inspections_for_route)
            for fault_id in segment_fault_ids[seg_id - 1]:
                file.write(f"update segment_fault set fault_status='repaired' where id={fault_id};\n")
            segment_fault_ids[seg_id - 1] = []
            for inspect_ind in range(real_inspections):
                curr_fault_id += 1
                seg_point_km = random.randint(1, seg_length - 1)
                time = interpolate_timestamps(time1, time2, seg_point_km / seg_length)
                segment_fault_ids[seg_id - 1].append(curr_fault_id)
                file.write(f"insert into inspection_repair_site "
                           f"(route_id, railway_segment_id, position_point_km, arrived_at, type_site_action) "
                           f"values ({route_ind + 1}, {seg_id}, {seg_point_km}, '{time}', 'inspection');\n")
                fault_class = random.choice(fault_classes)
                file.write(f"insert into segment_fault (rw_seg_id, fault_class, position_point_km, fault_status) "
                           f"values ({seg_id}, '{fault_class}', {seg_point_km}, 'not_repaired');\n")
                file.write(f"insert into site_fault_fixation (segment_fault_id, route_id, found_at, fault_class) "
                           f"values ({curr_fault_id}, {route_ind + 1}, '{time}', '{fault_class}');\n")
        except StopIteration:
            pass
    for route_ind in range(unfinished_routes):
        team_id = random.randint(1, repair_team_count)
        from_bs, to_bs = get_random_diff_ids(base_count)
        route_id = team_routes_count - unfinished_routes + route_ind + 1
        time1, _ = time_pairs[route_id - 1]
        dep_time = time1[:-1] + '0'
        file.write(f"insert into repair_team_route (repair_team_id, from_base_id, to_base_id) "
                   f"values ({team_id}, {from_bs}, {to_bs});\n")
        file.write(f"insert into repair_team_route_schedule (route_id, planned_at, departed_at, arrived_at) "
                   f"values ({route_id}, '{time1}', '{dep_time}', null);\n")


def generate_data():
    output_file_name = 'data.sql'
    with open(output_file_name, 'w', encoding='UTF-8') as output_file:
        generate_companies(output_file)
        generate_stations(output_file)
        generate_railway_segments(output_file)
        create_people_names()
        generate_teams_and_members(output_file)
        repair_base_count, warehouses_count = generate_warehouses_and_repair_bases(output_file)
        generate_resource_allocation(output_file, warehouses_count)
        generate_resource_transportation(output_file, warehouses_count)
        generate_repair_team_routes(output_file, repair_base_count)


if __name__ == '__main__':
    generate_data()
