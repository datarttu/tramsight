/*
Create roles, database, extensions and schemata.
author: Arttu Kosonen 7/2019
*/
CREATE ROLE hfpadmin LOGIN CREATEDB CREATEROLE;
\password hfpadmin;

SET ROLE hfpadmin;

-- TODO: other roles

CREATE DATABASE hfpdev;    -- Change this for prod version, for example

\c hfpdev;

SET ROLE hfpadmin;

CREATE EXTENSION postgis;
CREATE EXTENSION pgrouting;
CREATE EXTENSION timescaledb;

CREATE SCHEMA gtfs;
CREATE SCHEMA hfp;
-- TODO: other schemata
