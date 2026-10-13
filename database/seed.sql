
-- =====================================================
-- Phase 2: Sample Data
-- =====================================================

-- Projects
INSERT INTO projects (
    project_id, project_name, project_type, location,
    start_date, planned_end_date, progress_pct, project_status
)
VALUES
    ('P001', 'Green Heights', 'Residential', 'Nagpur',
     '2025-01-01', '2026-12-31', 65, 'IN_PROGRESS'),

    ('P002', 'Metro Business Park', 'Commercial', 'Pune',
     '2025-04-01', '2027-03-31', 40, 'IN_PROGRESS'),

    ('P003', 'Riverfront Villas', 'Residential', 'Nashik',
     '2025-07-01', '2026-09-30', 85, 'IN_PROGRESS')
ON CONFLICT (project_id) DO NOTHING;


-- Materials
INSERT INTO materials (
    material_id, material_name, category, unit, unit_cost,
    shelf_life_days, minimum_stock_level, lead_time_days
)
VALUES
    ('M001', 'Cement', 'Binding', 'bag', 380, 90, 100, 5),
    ('M002', 'Steel', 'Structural', 'ton', 62000, NULL, 10, 10),
    ('M003', 'Sand', 'Aggregate', 'ton', 1800, NULL, 20, 3),
    ('M004', 'Bricks', 'Masonry', 'piece', 12, NULL, 500, 4),
    ('M005', 'Aggregate', 'Aggregate', 'ton', 1400, NULL, 15, 3)
ON CONFLICT (material_id) DO NOTHING;


-- Suppliers
INSERT INTO suppliers (
    supplier_id, supplier_name, location,
    contact_email, supplier_rating, is_active
)
VALUES
    ('S001', 'BuildMart Supplies', 'Nagpur',
     'orders@buildmart.example', 4.50, TRUE),

    ('S002', 'Prime Construction Materials', 'Pune',
     'sales@prime.example', 4.20, TRUE),

    ('S003', 'Reliable Building Traders', 'Nashik',
     'contact@reliable.example', 4.00, TRUE)
ON CONFLICT (supplier_id) DO NOTHING;


-- Supplier-material offerings
INSERT INTO supplier_materials (
    supplier_id, material_id, supplier_unit_price,
    lead_time_days, minimum_order_qty, delivery_reliability
)
VALUES
    ('S001', 'M001', 375, 5, 50, 96),
    ('S002', 'M001', 370, 7, 100, 92),
    ('S001', 'M002', 61500, 10, 1, 96),
    ('S002', 'M002', 61000, 12, 2, 92),
    ('S003', 'M003', 1750, 3, 10, 95),
    ('S003', 'M004', 11.50, 4, 500, 94),
    ('S003', 'M005', 1350, 3, 10, 95)
ON CONFLICT (supplier_id, material_id) DO NOTHING;


-- Historical consumption
INSERT INTO material_consumption (
    project_id, material_id, consumption_date,
    quantity_consumed, activity_type
)
VALUES
    ('P001', 'M001', '2026-10-01', 80, 'Foundation'),
    ('P001', 'M001', '2026-10-02', 85, 'Foundation'),
    ('P001', 'M001', '2026-10-03', 78, 'Foundation'),
    ('P001', 'M002', '2026-10-01', 2.5, 'Reinforcement'),
    ('P001', 'M002', '2026-10-02', 3.0, 'Reinforcement'),
    ('P001', 'M002', '2026-10-03', 2.8, 'Reinforcement'),
    ('P002', 'M001', '2026-10-01', 60, 'Slab Work'),
    ('P002', 'M001', '2026-10-02', 65, 'Slab Work'),
    ('P003', 'M003', '2026-10-01', 12, 'Masonry'),
    ('P003', 'M003', '2026-10-02', 14, 'Masonry')
ON CONFLICT (
    project_id, material_id, consumption_date, activity_type
) DO NOTHING;


-- Inventory snapshots
INSERT INTO inventory (
    project_id, material_id, inventory_date,
    opening_stock, received_quantity, consumed_quantity, closing_stock
)
VALUES
    ('P001', 'M001', '2026-10-01', 500, 100, 80, 520),
    ('P001', 'M001', '2026-10-02', 520, 0, 85, 435),
    ('P001', 'M001', '2026-10-03', 435, 100, 78, 457),

    ('P001', 'M002', '2026-10-01', 20, 5, 2.5, 22.5),
    ('P001', 'M002', '2026-10-02', 22.5, 0, 3, 19.5),

    ('P002', 'M001', '2026-10-01', 300, 0, 60, 240),
    ('P002', 'M001', '2026-10-02', 240, 100, 65, 275)
ON CONFLICT (project_id, material_id, inventory_date) DO NOTHING;


-- Procurement orders
INSERT INTO procurement_orders (
    purchase_order_id, project_id, material_id, supplier_id,
    order_date, expected_delivery_date, actual_delivery_date,
    quantity, unit_price, order_status
)
VALUES
    ('PO001', 'P001', 'M001', 'S001',
     '2026-10-01', '2026-10-06', '2026-10-06',
     100, 375, 'DELIVERED'),

    ('PO002', 'P001', 'M002', 'S001',
     '2026-10-03', '2026-10-13', NULL,
     5, 61500, 'CONFIRMED'),

    ('PO003', 'P002', 'M001', 'S002',
     '2026-10-04', '2026-10-11', NULL,
     100, 370, 'PENDING')
ON CONFLICT (purchase_order_id) DO NOTHING;
