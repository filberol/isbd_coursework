create index idx_railway_station_name on railway_station using hash (name);

create index idx_company_name on company using hash (name);

create index idx_repair_team_member_name on repair_team_member using hash (name);

create index idx_site_fault_fixation_found_at on site_fault_fixation using btree (found_at);

create index idx_repair_team_route_schedule_planned_At on repair_team_route_schedule using btree (planned_at);

create index idx_segment_fault_fault_class on segment_fault using hash (fault_class);

create index idx_segment_fault_fault_status on segment_fault using hash (fault_status);

create index idx_site_fault_fixation_segment_fault_id on site_fault_fixation using hash (segment_fault_id);

create index idx_railway_segment_from_rs on railway_segment using hash (from_rs);

create index idx_railway_segment_to_rs on railway_segment using hash (to_rs);
