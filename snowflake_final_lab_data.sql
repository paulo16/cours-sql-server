-- =========================================================
-- Snowflake Final Lab Dataset (L3 DEV)
-- Objectif: KPI + fonctionnalités Snowflake avancées
-- =========================================================
-- IMPORTANT : Exécutez avec "Run All" (Ctrl+Shift+Enter)
-- Si erreur de privilège, vérifiez votre rôle :
--   USE ROLE SYSADMIN;  (ou ACCOUNTADMIN)
-- =========================================================

-- 0) Contexte (adaptez si besoin selon vos droits)
CREATE WAREHOUSE IF NOT EXISTS WH_L3_FINAL
  WAREHOUSE_SIZE = 'XSMALL'
  AUTO_SUSPEND = 60
  AUTO_RESUME = TRUE
  INITIALLY_SUSPENDED = TRUE;

CREATE OR REPLACE DATABASE L3_SNOWFLAKE_FINAL;
USE DATABASE L3_SNOWFLAKE_FINAL;

CREATE OR REPLACE SCHEMA LAB;
USE WAREHOUSE WH_L3_FINAL;
USE SCHEMA LAB;

-- 1) Tables de référence
-- (on répète USE pour garantir le contexte)
USE DATABASE L3_SNOWFLAKE_FINAL;
USE SCHEMA LAB;

CREATE OR REPLACE TABLE STORES (
  store_id INT,
  store_name STRING,
  city STRING,
  region STRING,
  opened_at DATE
);

CREATE OR REPLACE TABLE PRODUCTS (
  product_id INT,
  product_name STRING,
  category STRING,
  cost_price NUMBER(10,2),
  list_price NUMBER(10,2)
);

CREATE OR REPLACE TABLE ORDERS_RAW (
  order_id INT,
  order_ts TIMESTAMP_NTZ,
  store_id INT,
  product_id INT,
  quantity INT,
  unit_price NUMBER(10,2),
  discount_pct NUMBER(5,2),
  channel STRING,
  metadata VARIANT
);

CREATE OR REPLACE TABLE KPI_TARGETS (
  month_key DATE,
  region STRING,
  revenue_target NUMBER(12,2),
  margin_target_pct NUMBER(6,4)
);

-- 2) Données fixes
USE DATABASE L3_SNOWFLAKE_FINAL;
USE SCHEMA LAB;

INSERT INTO STORES (store_id, store_name, city, region, opened_at) VALUES
(1, 'Store Douala-Akwa', 'Douala', 'Littoral', '2024-03-01'),
(2, 'Store Yaounde-Centre', 'Yaounde', 'Centre', '2024-04-15'),
(3, 'Store Bafoussam', 'Bafoussam', 'Ouest', '2024-05-20'),
(4, 'Store Garoua', 'Garoua', 'Nord', '2024-06-18'),
(5, 'Store Limbe', 'Limbe', 'Sud-Ouest', '2024-07-11'),
(6, 'Store Dschang', 'Dschang', 'Ouest', '2024-08-05');

INSERT INTO PRODUCTS (product_id, product_name, category, cost_price, list_price) VALUES
(101, 'Laptop Pro 14', 'Informatique', 480000, 640000),
(102, 'Smartphone X', 'Mobile', 155000, 230000),
(103, 'Casque BT', 'Accessoires', 11000, 18500),
(104, 'Ecran 24', 'Informatique', 76000, 115000),
(105, 'Souris Pro', 'Accessoires', 4500, 9000),
(106, 'SSD 1To', 'Composants', 29000, 49000),
(107, 'Clavier Mecha', 'Accessoires', 12000, 21000),
(108, 'Tablette S', 'Mobile', 98000, 146000);

-- 3) Génération de commandes (1200 lignes)
USE DATABASE L3_SNOWFLAKE_FINAL;
USE SCHEMA LAB;

INSERT INTO ORDERS_RAW
WITH gen AS (
  SELECT
    SEQ4() + 1 AS n,
    DATEADD(hour, UNIFORM(0, 24*90, RANDOM()), '2026-01-01'::TIMESTAMP_NTZ) AS order_ts,
    UNIFORM(1, 6, RANDOM()) AS store_id,
    101 + UNIFORM(0, 7, RANDOM()) AS product_id,
    UNIFORM(1, 6, RANDOM()) AS quantity,
    CASE UNIFORM(1, 4, RANDOM())
      WHEN 1 THEN 'STORE'
      WHEN 2 THEN 'WEB'
      ELSE 'PARTNER'
    END AS channel,
    CASE UNIFORM(1, 6, RANDOM())
      WHEN 1 THEN 0.00
      WHEN 2 THEN 0.05
      WHEN 3 THEN 0.10
      WHEN 4 THEN 0.15
      ELSE 0.20
    END AS discount_pct,
    CASE UNIFORM(1, 5, RANDOM())
      WHEN 1 THEN 'facebook_ads'
      WHEN 2 THEN 'tiktok_ads'
      WHEN 3 THEN 'referral'
      ELSE 'organic'
    END AS campaign,
    CASE UNIFORM(1, 4, RANDOM())
      WHEN 1 THEN 'mobile'
      WHEN 2 THEN 'desktop'
      ELSE 'tablet'
    END AS device,
    CASE UNIFORM(1, 4, RANDOM())
      WHEN 1 THEN 'card'
      WHEN 2 THEN 'mobile_money'
      ELSE 'bank_transfer'
    END AS payment_method,
    UNIFORM(20, 181, RANDOM()) AS delivery_minutes
  FROM TABLE(GENERATOR(ROWCOUNT => 1200))
)
SELECT
  n AS order_id,
  g.order_ts,
  g.store_id,
  g.product_id,
  g.quantity,
  p.list_price AS unit_price,
  g.discount_pct,
  g.channel,
  OBJECT_CONSTRUCT(
    'campaign', g.campaign,
    'device', g.device,
    'payment_method', g.payment_method,
    'delivery_minutes', g.delivery_minutes
  ) AS metadata
FROM gen g
JOIN PRODUCTS p ON p.product_id = g.product_id;

-- 4) Targets KPI
INSERT INTO KPI_TARGETS (month_key, region, revenue_target, margin_target_pct) VALUES
('2026-01-01', 'Littoral', 65000000, 0.2800),
('2026-01-01', 'Centre', 52000000, 0.2600),
('2026-01-01', 'Ouest', 48000000, 0.2500),
('2026-02-01', 'Littoral', 70000000, 0.2900),
('2026-02-01', 'Centre', 55000000, 0.2700),
('2026-02-01', 'Ouest', 50000000, 0.2600),
('2026-03-01', 'Littoral', 74000000, 0.3000),
('2026-03-01', 'Centre', 58000000, 0.2800),
('2026-03-01', 'Ouest', 53000000, 0.2700),
('2026-03-01', 'Nord', 30000000, 0.2200),
('2026-03-01', 'Sud-Ouest', 34000000, 0.2400);

-- 5) Vues KPI
USE DATABASE L3_SNOWFLAKE_FINAL;
USE SCHEMA LAB;

CREATE OR REPLACE VIEW V_KPI_DAILY AS
SELECT
  DATE_TRUNC('DAY', o.order_ts) AS day_key,
  SUM(o.quantity * o.unit_price * (1 - o.discount_pct)) AS revenue,
  SUM(o.quantity * p.cost_price) AS cost_amount,
  SUM(o.quantity * o.unit_price * (1 - o.discount_pct)) - SUM(o.quantity * p.cost_price) AS margin,
  (SUM(o.quantity * o.unit_price * (1 - o.discount_pct)) - SUM(o.quantity * p.cost_price))
    / NULLIF(SUM(o.quantity * o.unit_price * (1 - o.discount_pct)), 0) AS margin_rate
FROM ORDERS_RAW o
JOIN PRODUCTS p ON p.product_id = o.product_id
GROUP BY 1;

CREATE OR REPLACE VIEW V_KPI_MONTHLY_REGION AS
SELECT
  DATE_TRUNC('MONTH', o.order_ts) AS month_key,
  s.region,
  SUM(o.quantity * o.unit_price * (1 - o.discount_pct)) AS revenue,
  SUM(o.quantity * p.cost_price) AS cost_amount,
  SUM(o.quantity * o.unit_price * (1 - o.discount_pct)) - SUM(o.quantity * p.cost_price) AS margin,
  (SUM(o.quantity * o.unit_price * (1 - o.discount_pct)) - SUM(o.quantity * p.cost_price))
    / NULLIF(SUM(o.quantity * o.unit_price * (1 - o.discount_pct)), 0) AS margin_rate
FROM ORDERS_RAW o
JOIN PRODUCTS p ON p.product_id = o.product_id
JOIN STORES s ON s.store_id = o.store_id
GROUP BY 1, 2;

-- 6) Stream + table de CDC
USE DATABASE L3_SNOWFLAKE_FINAL;
USE SCHEMA LAB;

CREATE OR REPLACE TABLE FACT_ORDERS_CDC LIKE ORDERS_RAW;
CREATE OR REPLACE STREAM ORDERS_RAW_STREAM ON TABLE ORDERS_RAW APPEND_ONLY = TRUE;

-- Optionnel (si autorisé dans votre compte)
CREATE OR REPLACE TASK TASK_APPLY_ORDERS_CDC
  WAREHOUSE = WH_L3_FINAL
  SCHEDULE = 'USING CRON 0 * * * * UTC'
AS
INSERT INTO FACT_ORDERS_CDC
SELECT * FROM ORDERS_RAW_STREAM;

-- ALTER TASK TASK_APPLY_ORDERS_CDC RESUME;

-- 7) Vérifications rapides
USE DATABASE L3_SNOWFLAKE_FINAL;
USE SCHEMA LAB;

SELECT COUNT(*) AS nb_stores FROM STORES;
SELECT COUNT(*) AS nb_products FROM PRODUCTS;
SELECT COUNT(*) AS nb_orders FROM ORDERS_RAW;
SELECT COUNT(*) AS nb_targets FROM KPI_TARGETS;

SELECT * FROM V_KPI_DAILY ORDER BY day_key DESC LIMIT 10;
SELECT * FROM V_KPI_MONTHLY_REGION ORDER BY month_key, region;

SELECT
  metadata:campaign::STRING AS campaign,
  COUNT(*) AS nb_lignes,
  AVG(metadata:delivery_minutes::NUMBER) AS avg_delivery_minutes
FROM ORDERS_RAW
GROUP BY 1
ORDER BY nb_lignes DESC;
