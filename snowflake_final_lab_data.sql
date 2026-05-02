-- =========================================================
-- Snowflake Final Lab Dataset (L3 DEV - Maroc)
-- Objectif: KPI + fonctionnalités Snowflake avancées
-- =========================================================
-- IMPORTANT : Exécutez avec "Run All" (Ctrl+Shift+Enter)
-- Si erreur de privilège, vérifiez votre rôle :
--   USE ROLE SYSADMIN;  (ou ACCOUNTADMIN)
-- =========================================================

-- 0) Contexte
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
(1, 'Store Rabat-Agdal', 'Rabat', 'Rabat-Salé-Kénitra', '2024-03-01'),
(2, 'Store Casablanca-Sidi Maarouf', 'Casablanca', 'Casablanca-Settat', '2024-04-15'),
(3, 'Store Marrakech-Gueliz', 'Marrakech', 'Marrakech-Safi', '2024-05-20'),
(4, 'Store Fès-Centre', 'Fès', 'Fès-Meknès', '2024-06-18'),
(5, 'Store Tanger-Corniche', 'Tanger', 'Tanger-Tétouan-Al Hoceïma', '2024-07-11'),
(6, 'Store Oujda', 'Oujda', 'Oriental', '2024-08-05');

INSERT INTO PRODUCTS (product_id, product_name, category, cost_price, list_price) VALUES
(101, 'Laptop Atlas 14', 'Informatique', 4800, 6400),
(102, 'Smartphone Sahara X', 'Mobile', 1550, 2300),
(103, 'Casque Bluetooth Atlas', 'Accessoires', 110, 185),
(104, 'Écran 24 pouces', 'Informatique', 760, 1150),
(105, 'Souris Ergonomique', 'Accessoires', 45, 90),
(106, 'SSD 1To Atlas', 'Composants', 290, 490),
(107, 'Clavier Mécanique', 'Accessoires', 120, 210),
(108, 'Tablette Atlas S', 'Mobile', 980, 1460);

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
      WHEN 2 THEN 'instagram_ads'
      WHEN 3 THEN 'referral'
      ELSE 'organic'
    END AS campaign,
    CASE UNIFORM(1, 4, RANDOM())
      WHEN 1 THEN 'mobile'
      WHEN 2 THEN 'desktop'
      ELSE 'tablet'
    END AS device,
    CASE UNIFORM(1, 4, RANDOM())
      WHEN 1 THEN 'carte_bancaire'
      WHEN 2 THEN 'paiement_mobile'
      ELSE 'virement_bancaire'
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
('2026-01-01', 'Rabat-Salé-Kénitra', 6500000, 0.2800),
('2026-01-01', 'Casablanca-Settat', 5200000, 0.2600),
('2026-01-01', 'Marrakech-Safi', 4800000, 0.2500),
('2026-02-01', 'Rabat-Salé-Kénitra', 7000000, 0.2900),
('2026-02-01', 'Casablanca-Settat', 5500000, 0.2700),
('2026-02-01', 'Marrakech-Safi', 5000000, 0.2600),
('2026-03-01', 'Rabat-Salé-Kénitra', 7400000, 0.3000),
('2026-03-01', 'Casablanca-Settat', 5800000, 0.2800),
('2026-03-01', 'Marrakech-Safi', 5300000, 0.2700),
('2026-03-01', 'Fès-Meknès', 3000000, 0.2200),
('2026-03-01', 'Tanger-Tétouan-Al Hoceïma', 3400000, 0.2400);

-- Les vues, streams et tâches restent inchangés
