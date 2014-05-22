-- Database: rubadi

-- DROP DATABASE rubadi;

CREATE DATABASE rubadi
  WITH OWNER = rubadi
       ENCODING = 'UTF8'
       TABLESPACE = pg_default
       LC_COLLATE = 'en_US.UTF-8'
       LC_CTYPE = 'en_US.UTF-8'
       CONNECTION LIMIT = -1;

-- Schema: rubadi

-- DROP SCHEMA rubadi;

CREATE SCHEMA rubadi
  AUTHORIZATION rubadi;

-- Table: rubadi.clicks

-- DROP TABLE rubadi.clicks;

CREATE TABLE rubadi.clicks
(
  click_id integer,
  banner_id integer,
  campaign_id integer,
  hour_slice smallint
)
WITH (
  OIDS=FALSE
);
ALTER TABLE rubadi.clicks
  OWNER TO rubadi;

-- Index: rubadi.idx_clicks_banner_id

-- DROP INDEX rubadi.idx_clicks_banner_id;

CREATE INDEX idx_clicks_banner_id
  ON rubadi.clicks
  USING btree
  (banner_id);

-- Index: rubadi.idx_clicks_campaign_id

-- DROP INDEX rubadi.idx_clicks_campaign_id;

CREATE INDEX idx_clicks_campaign_id
  ON rubadi.clicks
  USING btree
  (campaign_id);

-- Index: rubadi.idx_clicks_hour_slice

-- DROP INDEX rubadi.idx_clicks_hour_slice;

CREATE INDEX idx_clicks_hour_slice
  ON rubadi.clicks
  USING btree
  (hour_slice);

-- Index: rubadi.idx_clicks_hour_slice_campaign_id

-- DROP INDEX rubadi.idx_clicks_hour_slice_campaign_id;

CREATE INDEX idx_clicks_hour_slice_campaign_id
  ON rubadi.clicks
  USING btree
  (hour_slice, campaign_id);
  
-- Table: rubadi.conversions

-- DROP TABLE rubadi.conversions;

CREATE TABLE rubadi.conversions
(
  conversion_id integer,
  click_id integer,
  revenue numeric,
  hour_slice smallint
)
WITH (
  OIDS=FALSE
);
ALTER TABLE rubadi.conversions
  OWNER TO rubadi;

-- Index: rubadi.idx_conversion_click_id_hour_slice

-- DROP INDEX rubadi.idx_conversion_click_id_hour_slice;

CREATE INDEX idx_conversion_click_id_hour_slice
  ON rubadi.conversions
  USING btree
  (click_id, hour_slice);

-- Index: rubadi.idx_conversions_hour_slice

-- DROP INDEX rubadi.idx_conversions_hour_slice;

CREATE INDEX idx_conversions_hour_slice
  ON rubadi.conversions
  USING btree
  (hour_slice);


