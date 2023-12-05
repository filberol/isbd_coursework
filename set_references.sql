COMMENT ON TABLE "railway_segment" IS 'Road connecting two points';

ALTER TABLE "railway_station"
    ADD FOREIGN KEY ("owner_id") REFERENCES "company" ("id");

ALTER TABLE "railway_segment"
    ADD FOREIGN KEY ("from_rs") REFERENCES "railway_station" ("id");

ALTER TABLE "railway_segment"
    ADD FOREIGN KEY ("to_rs") REFERENCES "railway_station" ("id");

ALTER TABLE "warehouse"
    ADD FOREIGN KEY ("station_id") REFERENCES "railway_station" ("id");

ALTER TABLE "repair_base"
    ADD FOREIGN KEY ("station_id") REFERENCES "railway_station" ("id");

ALTER TABLE "segment_fault"
    ADD FOREIGN KEY ("rw_seg_id") REFERENCES "railway_segment" ("id");

ALTER TABLE "repair_team_route"
    ADD FOREIGN KEY ("repair_team_id") REFERENCES "repair_team" ("id");

ALTER TABLE "repair_team_route"
    ADD FOREIGN KEY ("from_base_id") REFERENCES "repair_base" ("id");

ALTER TABLE "repair_team_route"
    ADD FOREIGN KEY ("to_base_id") REFERENCES "repair_base" ("id");

ALTER TABLE "repair_team_route_schedule"
    ADD FOREIGN KEY ("route_id") REFERENCES "repair_team_route" ("id");

ALTER TABLE "inspection_repair_site"
    ADD FOREIGN KEY ("route_id") REFERENCES "repair_team_route" ("id");

ALTER TABLE "inspection_repair_site"
    ADD FOREIGN KEY ("railway_segment_id") REFERENCES "railway_segment" ("id");

ALTER TABLE "site_fault_fixation"
    ADD FOREIGN KEY ("segment_fault_id") REFERENCES "segment_fault" ("id");

ALTER TABLE "site_fault_fixation"
    ADD FOREIGN KEY ("route_id") REFERENCES "repair_team_route" ("id");

ALTER TABLE "repair_team"
    ADD FOREIGN KEY ("owner_id") REFERENCES "company" ("id");

ALTER TABLE "repair_team"
    ADD FOREIGN KEY ("team_head_id") REFERENCES "repair_team_member" ("id");

ALTER TABLE "repair_team_member"
    ADD FOREIGN KEY ("repair_team_id") REFERENCES "repair_team" ("id");

ALTER TABLE "warehouse_resource_allocation"
    ADD FOREIGN KEY ("warehouse_id") REFERENCES "warehouse" ("id");

ALTER TABLE "resource_transportation"
    ADD FOREIGN KEY ("from_warehouse_id") REFERENCES "warehouse" ("id");

ALTER TABLE "resource_transportation"
    ADD FOREIGN KEY ("to_warehouse_id") REFERENCES "warehouse" ("id");