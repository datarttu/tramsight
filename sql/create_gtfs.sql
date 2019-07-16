/*
Create tables and related entities
of the gtfs schema.

The tables are formatted according to
the current HSL gtfs data model.

author: Arttu Kosonen 7/2019
*/

\c hfpdev;

-- omit agency

CREATE TABLE gtfs.calendar_dates (
  service_id     text         PRIMARY KEY,
  date           date         NOT NULL,
  exception_type smallint     NOT NULL,
  modified       timestamptz  DEFAULT CURRENT_TIMESTAMP
);
-- TODO: UPSERT trigger

CREATE TABLE gtfs.calendar (
  service_id     text         PRIMARY KEY,
  monday         boolean      NOT NULL,
  tuesday        boolean      NOT NULL,
  wednesday      boolean      NOT NULL,
  thursday       boolean      NOT NULL,
  friday         boolean      NOT NULL,
  saturday       boolean      NOT NULL,
  sunday         boolean      NOT NULL,
  start_date     date         NOT NULL,
  end_date       date         NOT NULL,
  modified       timestamptz  DEFAULT CURRENT_TIMESTAMP
);
-- TODO: UPSERT trigger

-- omit call_line_phone_numbers
-- omit fare_attributes
-- omit fare_rules
-- omit feed_info

CREATE TABLE gtfs.routes (
  route_id          text        PRIMARY KEY,
  agency_id         text,
  route_short_name  text,
  route_long_name   text,
  route_desc        text,
  route_type        smallint    NOT NULL,
  route_url         text,
  modified          timestamptz DEFAULT CURRENT_TIMESTAMP
);
-- TODO: UPSERT trigger

CREATE TABLE gtfs.shapes (
  shape_id            text          NOT NULL,
  shape_pt_lat        numeric(8, 6) NOT NULL,
  shape_pt_lon        numeric(8, 6) NOT NULL,
  shape_pt_sequence   integer       NOT NULL,
  shape_dist_traveled real,
  geom                geometry(POINT, 4326) DEFAULT ST_MakePoint(shape_pt_lon, shape_pt_lat),
  modified            timestamptz DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (shape_id, shape_pt_sequence)
);
-- TODO: UPSERT trigger with geom creation

CREATE TABLE gtfs.stops (
  stop_id             integer       PRIMARY KEY,
  stop_code           text,
  stop_name           text,
  stop_desc           text,
  stop_lat            numeric(8, 6) NOT NULL,
  stop_lon            numeric(8, 6) NOT NULL,
  zone_id             text,
  stop_url            text,
  location_type       smallint,
  parent_station      smallint,
  wheelchair_boarding smallint,
  platform_code       text,
  vehicle_type        smallint, -- NOTE: non-standard attribute by HSL
  geom                geometry(POINT, 4326) DEFAULT ST_MakePoint(stop_lon, stop_lat),
  modified            timestamptz DEFAULT CURRENT_TIMESTAMP
);
-- TODO: UPSERT trigger with geom

-- omit translations

CREATE TABLE gtfs.trips (
  route_id            text      REFERENCES gtfs.routes (route_id),
  service_id          text      NOT NULL,  -- refers to calendar. OR calendar_date.service_id!
  trip_id             text      PRIMARY KEY,
  trip_headsign       text,
  direction_id        smallint,
  shape_id            text      REFERENCES gtfs.shapes (shape_id),
  wheelchair_accesible  smallint  DEFAULT 0,
  bikes_allowed       smallint  DEFAULT 0,
  max_delay           smallint, -- NOTE: non-standard attribute by HSL
  modified            timestamptz DEFAULT CURRENT_TIMESTAMP
);
-- TODO: UPSERT trigger

CREATE TABLE gtfs.stop_times (
  trip_id             text      REFERENCES gtfs.trips (trip_id),
  arrival_time        interval  NOT NULL,
  departure_time      interval  NOT NULL,
  stop_id             integer   REFERENCES gtfs.stops (stop_id),
  stop_sequence       smallint  NOT NULL,
  stop_headsign       text,
  pickup_type         smallint  DEFAULT 0,
  drop_off_type       smallint  DEFAULT 0,
  shape_dist_traveled real,
  timepoint           smallint  DEFAULT 1,
  modified            timestamptz DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (trip_id, stop_sequence)
);
-- TODO: UPSERT trigger
