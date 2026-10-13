
-- 1. View all projects
SELECT *
FROM projects;


-- 2. List all materials and their units
SELECT
    material_id,
    material_name,
    category,
    unit,
    unit_cost
FROM materials
ORDER BY material_name;


-- 3. Show material consumption with project and material names
SELECT
    p.project_name,
    m.material_name,
    m.unit,
    c.consumption_date,
    c.quantity_consumed
FROM material_consumption c
JOIN projects p
    ON c.project_id = p.project_id
JOIN materials m
    ON c.material_id = m.material_id
ORDER BY c.consumption_date;


-- 4. Total consumption by project and material
SELECT
    p.project_name,
    m.material_name,
    m.unit,
    SUM(c.quantity_consumed) AS total_consumed
FROM material_consumption c
JOIN projects p
    ON c.project_id = p.project_id
JOIN materials m
    ON c.material_id = m.material_id
GROUP BY
    p.project_name,
    m.material_name,
    m.unit
ORDER BY total_consumed DESC;


-- 5. Latest inventory snapshot for each project-material pair
SELECT DISTINCT ON (i.project_id, i.material_id)
    p.project_name,
    m.material_name,
    m.unit,
    i.inventory_date,
    i.closing_stock
FROM inventory i
JOIN projects p
    ON i.project_id = p.project_id
JOIN materials m
    ON i.material_id = m.material_id
ORDER BY
    i.project_id,
    i.material_id,
    i.inventory_date DESC;


-- 6. Show orders with supplier and material details
SELECT
    po.purchase_order_id,
    p.project_name,
    m.material_name,
    s.supplier_name,
    po.quantity,
    po.unit_price,
    po.quantity * po.unit_price AS order_value,
    po.order_status
FROM procurement_orders po
JOIN projects p
    ON po.project_id = p.project_id
JOIN materials m
    ON po.material_id = m.material_id
JOIN suppliers s
    ON po.supplier_id = s.supplier_id
ORDER BY po.order_date;


-- 7. Compare supplier prices for cement
SELECT
    s.supplier_name,
    sm.supplier_unit_price,
    sm.lead_time_days,
    sm.minimum_order_qty,
    sm.delivery_reliability
FROM supplier_materials sm
JOIN suppliers s
    ON sm.supplier_id = s.supplier_id
WHERE sm.material_id = 'M001'
ORDER BY sm.supplier_unit_price;


-- 8. Calculate total procurement spending by project
SELECT
    p.project_name,
    SUM(po.quantity * po.unit_price) AS total_order_value
FROM procurement_orders po
JOIN projects p
    ON po.project_id = p.project_id
WHERE po.order_status <> 'CANCELLED'
GROUP BY p.project_name
ORDER BY total_order_value DESC;
