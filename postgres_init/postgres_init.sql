--------------------------------------------------------
-- FACTORY TABLE
--------------------------------------------------------
CREATE TABLE IF NOT EXISTS factory (
    factory_id SERIAL PRIMARY KEY,
    factory_name VARCHAR(255) NOT NULL
);

--------------------------------------------------------
-- MACHINE TABLE
--------------------------------------------------------
CREATE TABLE IF NOT EXISTS machine (
    machine_id SERIAL PRIMARY KEY,
    machine_name VARCHAR(255) NOT NULL,
    factory_id INTEGER NOT NULL REFERENCES factory(factory_id) ON DELETE CASCADE
);

--------------------------------------------------------
-- MATERIAL TABLE
--------------------------------------------------------
CREATE TABLE IF NOT EXISTS material (
    material_id SERIAL PRIMARY KEY,
    material_name VARCHAR(255) NOT NULL
);

--------------------------------------------------------
-- PRODUCT TABLE  (updated with factory_id)
--------------------------------------------------------
CREATE TABLE IF NOT EXISTS product (
    product_id SERIAL PRIMARY KEY,
    product_name VARCHAR(255) NOT NULL,
    factory_id INTEGER REFERENCES factory(factory_id) ON DELETE SET NULL
);

--------------------------------------------------------
-- PRODUCT-MATERIAL RELATION TABLE
--------------------------------------------------------
CREATE TABLE IF NOT EXISTS product_material (
    id SERIAL PRIMARY KEY,
    product_id INTEGER NOT NULL REFERENCES product(product_id) ON DELETE CASCADE,
    material_id INTEGER NOT NULL REFERENCES material(material_id) ON DELETE CASCADE
);


--------------------------------------------------------
-- SAMPLE DATA
--------------------------------------------------------

-- FACTORY
INSERT INTO factory (factory_name)
SELECT 'Factory A'
WHERE NOT EXISTS (SELECT 1 FROM factory WHERE factory_name = 'Factory A');

INSERT INTO factory (factory_name)
SELECT 'Factory B'
WHERE NOT EXISTS (SELECT 1 FROM factory WHERE factory_name = 'Factory B');


--------------------------------------------------------
-- MATERIALS
--------------------------------------------------------
INSERT INTO material (material_name)
SELECT 'Plastic'
WHERE NOT EXISTS (SELECT 1 FROM material WHERE material_name = 'Plastic');

INSERT INTO material (material_name)
SELECT 'Metal'
WHERE NOT EXISTS (SELECT 1 FROM material WHERE material_name = 'Metal');

INSERT INTO material (material_name)
SELECT 'Glass'
WHERE NOT EXISTS (SELECT 1 FROM material WHERE material_name = 'Glass');

INSERT INTO material (material_name)
SELECT 'Rubber'
WHERE NOT EXISTS (SELECT 1 FROM material WHERE material_name = 'Rubber');


--------------------------------------------------------
-- PRODUCTS (now linked to factories)
--------------------------------------------------------
INSERT INTO product (product_name, factory_id)
SELECT 'Bottle', 1
WHERE NOT EXISTS (SELECT 1 FROM product WHERE product_name = 'Bottle');

INSERT INTO product (product_name, factory_id)
SELECT 'Thermos', 1
WHERE NOT EXISTS (SELECT 1 FROM product WHERE product_name = 'Thermos');

INSERT INTO product (product_name, factory_id)
SELECT 'Phone Case', 2
WHERE NOT EXISTS (SELECT 1 FROM product WHERE product_name = 'Phone Case');

INSERT INTO product (product_name, factory_id)
SELECT 'Glass Jar', 2
WHERE NOT EXISTS (SELECT 1 FROM product WHERE product_name = 'Glass Jar');


--------------------------------------------------------
-- PRODUCT ↔ MATERIAL RELATIONSHIPS
--------------------------------------------------------

-- Bottle → Plastic
INSERT INTO product_material (product_id, material_id)
SELECT 
    (SELECT product_id FROM product WHERE product_name = 'Bottle'),
    (SELECT material_id FROM material WHERE material_name = 'Plastic')
WHERE NOT EXISTS (
    SELECT 1 
    FROM product_material 
    WHERE product_id = (SELECT product_id FROM product WHERE product_name = 'Bottle')
      AND material_id = (SELECT material_id FROM material WHERE material_name = 'Plastic')
);


-- Thermos → Metal, Plastic, Rubber
INSERT INTO product_material (product_id, material_id)
SELECT 
    (SELECT product_id FROM product WHERE product_name = 'Thermos'),
    (SELECT material_id FROM material WHERE material_name = 'Metal')
WHERE NOT EXISTS (
    SELECT 1 FROM product_material WHERE product_id = 2 AND material_id = 2
);

INSERT INTO product_material (product_id, material_id)
SELECT 
    (SELECT product_id FROM product WHERE product_name = 'Thermos'),
    (SELECT material_id FROM material WHERE material_name = 'Plastic')
WHERE NOT EXISTS (
    SELECT 1 FROM product_material WHERE product_id = 2 AND material_id = 1
);

INSERT INTO product_material (product_id, material_id)
SELECT 
    (SELECT product_id FROM product WHERE product_name = 'Thermos'),
    (SELECT material_id FROM material WHERE material_name = 'Rubber')
WHERE NOT EXISTS (
    SELECT 1 FROM product_material WHERE product_id = 2 AND material_id = 4
);


-- Phone Case → Plastic, Rubber
INSERT INTO product_material (product_id, material_id)
SELECT 
    (SELECT product_id FROM product WHERE product_name = 'Phone Case'),
    (SELECT material_id FROM material WHERE material_name = 'Plastic')
WHERE NOT EXISTS (
    SELECT 1 FROM product_material WHERE product_id = 3 AND material_id = 1
);

INSERT INTO product_material (product_id, material_id)
SELECT 
    (SELECT product_id FROM product WHERE product_name = 'Phone Case'),
    (SELECT material_id FROM material WHERE material_name = 'Rubber')
WHERE NOT EXISTS (
    SELECT 1 FROM product_material WHERE product_id = 3 AND material_id = 4
);


-- Glass Jar → Glass, Metal
INSERT INTO product_material (product_id, material_id)
SELECT 
    (SELECT product_id FROM product WHERE product_name = 'Glass Jar'),
    (SELECT material_id FROM material WHERE material_name = 'Glass')
WHERE NOT EXISTS (
    SELECT 1 FROM product_material WHERE product_id = 4 AND material_id = 3
);

INSERT INTO product_material (product_id, material_id)
SELECT 
    (SELECT product_id FROM product WHERE product_name = 'Glass Jar'),
    (SELECT material_id FROM material WHERE material_name = 'Metal')
WHERE NOT EXISTS (
    SELECT 1 FROM product_material WHERE product_id = 4 AND material_id = 2
);
