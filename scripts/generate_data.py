import random
from datetime import datetime

# Company
company_count, company_names = 100, set()
# Railway station
railway_station_count, railway_station_names = 100, set()
# Railway segment
railway_segment_count, railway_segment_lengths = 500, []
min_seg_len, max_seg_len = 15, 150
# Repair team members
people_count, people_names = 200, set()
# Repair teams
repair_team_count = 100
# Repair base
base_max_host = 20
# Warehouses
warehouses_count = 0
# Warehouse resource allocation
allocations_for_base_max = 10
allocation_max_km = 400


# Utils
def generate_random_timestamp(start_year, end_year):
    # Generate a random year between start_year and end_year
    year = random.randint(start_year, end_year)
    # Generate a random month and day
    month = random.randint(1, 12)
    day = random.randint(1, 28)  # Assuming all months have 28 days for simplicity
    # Generate a random hour, minute, and second
    hour = random.randint(0, 23)
    minute = random.randint(0, 59)
    second = random.randint(0, 59)
    # Create a datetime object with the generated values
    timestamp = datetime(year, month, day, hour, minute, second)
    # Format the timestamp as an SQL-compatible string
    timestamp_string = timestamp.strftime("%Y-%m-%d %H:%M:%S")
    return timestamp_string


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
    for _ in range(railway_segment_count):
        length_km = random.randint(min_seg_len, max_seg_len)
        railway_segment_lengths.append(length_km)
        from_rs = random.randint(1, railway_station_count)
        to_rs = random.randint(1, railway_station_count)
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


def generate_warehouses_and_repair_bases(file, ware_count):
    for station_index in range(1, railway_station_count + 1):
        base_size = random.randint(1, base_max_host)
        if random.randint(1, 3) > 1:
            file.write(
                f"insert into repair_base (station_id, size_teams, curr_teams_hosted)"
                f" values({station_index}, {base_size}, 0);\n"
            )
        if random.randint(1, 3) > 2:
            ware_count += 1
            file.write(
                f"insert into warehouse (station_id, resources_available_km) values({station_index}, 0);\n"
            )


def generate_resource_allocation(file):
    for warehouse_id in range(1, warehouses_count + 1):
        allocations = random.randint(1, allocations_for_base_max)
        for i in range(allocations):
            alloc = random.randint(1, allocation_max_km)
            time = generate_random_timestamp(2000, 2010)
            file.write(f"insert into warehouse_resource_allocation "
                       f"(warehouse_id, resources_allocated_km, allocated_at) "
                       f"values({warehouse_id}, {alloc}), {time};\n")


def generate_data():
    output_file_name = 'data.sql'
    with open(output_file_name, 'w', encoding='UTF-8') as output_file:
        generate_companies(output_file)
        generate_stations(output_file)
        generate_railway_segments(output_file)
        create_people_names()
        generate_teams_and_members(output_file)
        generate_warehouses_and_repair_bases(output_file, warehouses_count)


if __name__ == '__main__':
    generate_data()
