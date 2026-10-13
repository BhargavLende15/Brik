
-- =====================================================
-- Construction Material Demand & Procurement Forecasting
-- Phase 2: Database Schema
-- Database: PostgreSQL
-- =====================================================

-- 1. PROJECTS
CREATE TABLE IF NOT EXISTS projects (
    project_id       VARCHAR(20) PRIMARY KEY,
    project_name     VARCHAR(150) NOT NULL,
    project_type     VARCHAR(50) NOT NULL,
    location         VARCHAR(150),
    start_date       DATE NOT NULL,
    planned_end_date DATE NOT NULL,
    progress_pct     NUMERIC(5,2) NOT NULL DEFAULT 0,
    project_status   VARCHAR(20) NOT NULL DEFAULT 'PLANNED',

    CONSTRAINT chk_project_dates
        CHECK (planned_end_date >= start_date),

    CONSTRAINT chk_project_progress
        CHECK (progress_pct BETWEEN 0 AND 100),

    CONSTRAINT chk_project_status
        CHECK (project_status IN
            ('PLANNED', 'IN_PROGRESS', 'COMPLETED', 'ON_HOLD'))
);


-- 2. MATERIALS
CREATE TABLE IF NOT EXISTS materials (
    material_id        VARCHAR(20) PRIMARY KEY,
    material_name      VARCHAR(100) NOT NULL UNIQUE,
    category           VARCHAR(50) NOT NULL,
    unit               VARCHAR(20) NOT NULL,
    unit_cost          NUMERIC(12,2) NOT NULL,
    shelf_life_days    INTEGER,
    minimum_stock_level NUMERIC(14,3) NOT NULL DEFAULT 0,
    lead_time_days     INTEGER NOT NULL DEFAULT 7,

    CONSTRAINT chk_material_cost
        CHECK (unit_cost >= 0),

    CONSTRAINT chk_material_min_stock
        CHECK (minimum_stock_level >= 0),

    CONSTRAINT chk_material_lead_time
        CHECK (lead_time_days >= 0),

    CONSTRAINT chk_material_shelf_life
        CHECK (shelf_life_days IS NULL OR shelf_life_days > 0)
);


-- 3. SUPPLIERS
CREATE TABLE IF NOT EXISTS suppliers (
    supplier_id       VARCHAR(20) PRIMARY KEY,
    supplier_name     VARCHAR(150) NOT NULL,
    location          VARCHAR(150),
    contact_email     VARCHAR(150),
    supplier_rating   NUMERIC(3,2),
    is_active         BOOLEAN NOT NULL DEFAULT TRUE,

    CONSTRAINT chk_supplier_rating
        CHECK (
            supplier_rating IS NULL
            OR supplier_rating BETWEEN 0 AND 5
        )
);


-- 4. SUPPLIER-MATERIAL RELATIONSHIP
-- One supplier may supply multiple materials.
-- One material may have multiple suppliers.

CREATE TABLE IF NOT EXISTS supplier_materials (
    supplier_id          VARCHAR(20) NOT NULL,
    material_id          VARCHAR(20) NOT NULL,
    supplier_unit_price  NUMERIC(12,2) NOT NULL,
    lead_time_days       INTEGER NOT NULL,
    minimum_order_qty    NUMERIC(14,3) NOT NULL DEFAULT 1,
    delivery_reliability NUMERIC(5,2),

    PRIMARY KEY (supplier_id, material_id),

    FOREIGN KEY (supplier_id)
        REFERENCES suppliers(supplier_id),

    FOREIGN KEY (material_id)
        REFERENCES materials(material_id),

    CONSTRAINT chk_supplier_material_price
        CHECK (supplier_unit_price >= 0),

    CONSTRAINT chk_supplier_material_lead_time
        CHECK (lead_time_days >= 0),

    CONSTRAINT chk_minimum_order
        CHECK (minimum_order_qty > 0),

    CONSTRAINT chk_delivery_reliability
        CHECK (
            delivery_reliability IS NULL
            OR delivery_reliability BETWEEN 0 AND 100
        )
);


-- 5. INVENTORY SNAPSHOTS
-- Each row represents a project's material stock on a date.

CREATE TABLE IF NOT EXISTS inventory (
    inventory_id       BIGINT GENERATED ALWAYS AS IDENTITY
                       PRIMARY KEY,
    project_id         VARCHAR(20) NOT NULL,
    material_id        VARCHAR(20) NOT NULL,
    inventory_date     DATE NOT NULL,
    opening_stock      NUMERIC(14,3) NOT NULL,
    received_quantity  NUMERIC(14,3) NOT NULL DEFAULT 0,
    consumed_quantity  NUMERIC(14,3) NOT NULL DEFAULT 0,
    closing_stock      NUMERIC(14,3) NOT NULL,

    FOREIGN KEY (project_id)
        REFERENCES projects(project_id),

    FOREIGN KEY (material_id)
        REFERENCES materials(material_id),

    CONSTRAINT uq_inventory_snapshot
        UNIQUE (project_id, material_id, inventory_date),

    CONSTRAINT chk_inventory_quantities
        CHECK (
            opening_stock >= 0
            AND received_quantity >= 0
            AND consumed_quantity >= 0
            AND closing_stock >= 0
        ),

    CONSTRAINT chk_inventory_balance
        CHECK (
            closing_stock =
            opening_stock + received_quantity - consumed_quantity
        )
);


-- 6. MATERIAL CONSUMPTION HISTORY
-- Historical observations used for demand forecasting.

CREATE TABLE IF NOT EXISTS material_consumption (
    consumption_id BIGINT GENERATED ALWAYS AS IDENTITY
                   PRIMARY KEY,
    project_id     VARCHAR(20) NOT NULL,
    material_id    VARCHAR(20) NOT NULL,
    consumption_date DATE NOT NULL,
    quantity_consumed NUMERIC(14,3) NOT NULL,
    activity_type  VARCHAR(100),

    FOREIGN KEY (project_id)
        REFERENCES projects(project_id),

    FOREIGN KEY (material_id)
        REFERENCES materials(material_id),

    CONSTRAINT uq_consumption_record
        UNIQUE (project_id, material_id, consumption_date, activity_type),

    CONSTRAINT chk_consumption_quantity
        CHECK (quantity_consumed >= 0)
);


-- 7. PROCUREMENT ORDERS

CREATE TABLE IF NOT EXISTS procurement_orders (
    purchase_order_id VARCHAR(30) PRIMARY KEY,
    project_id        VARCHAR(20) NOT NULL,
    material_id       VARCHAR(20) NOT NULL,
    supplier_id       VARCHAR(20) NOT NULL,
    order_date        DATE NOT NULL,
    expected_delivery_date DATE NOT NULL,
    actual_delivery_date   DATE,
    quantity          NUMERIC(14,3) NOT NULL,
    unit_price        NUMERIC(12,2) NOT NULL,
    order_status      VARCHAR(20) NOT NULL DEFAULT 'PENDING',

    FOREIGN KEY (project_id)
        REFERENCES projects(project_id),

    FOREIGN KEY (material_id)
        REFERENCES materials(material_id),

    FOREIGN KEY (supplier_id, material_id)
        REFERENCES supplier_materials(supplier_id, material_id),

    CONSTRAINT chk_order_quantity
        CHECK (quantity > 0),

    CONSTRAINT chk_order_price
        CHECK (unit_price >= 0),

    CONSTRAINT chk_expected_delivery
        CHECK (expected_delivery_date >= order_date),

    CONSTRAINT chk_actual_delivery
        CHECK (
            actual_delivery_date IS NULL
            OR actual_delivery_date >= order_date
        ),

    CONSTRAINT chk_order_status
        CHECK (order_status IN
            ('PENDING', 'CONFIRMED', 'SHIPPED', 'DELIVERED', 'CANCELLED'))
);


-- 8. INDEXES FOR COMMON QUERIES

CREATE INDEX IF NOT EXISTS idx_inventory_project_material_date
    ON inventory (project_id, material_id, inventory_date);

CREATE INDEX IF NOT EXISTS idx_consumption_project_material_date
    ON material_consumption
        (project_id, material_id, consumption_date);

CREATE INDEX IF NOT EXISTS idx_orders_project_status
    ON procurement_orders (project_id, order_status);

CREATE INDEX IF NOT EXISTS idx_orders_expected_delivery
    ON procurement_orders (expected_delivery_date);

CREATE INDEX IF NOT EXISTS idx_material_category
    ON materials (category);
