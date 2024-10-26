CALL add_purchase(
    1, -- Supplier ID
    '2024-5-22', -- Purchase date
    '[{"product_id": 1, "quantity": 10, "price": 90.00}, {"product_id": 2, "quantity": 5, "price": 180.00}]' -- JSON for products (with price)
);

CALL add_sale(
    1, -- Customer ID
    '2024-5-22', -- Sale date
    '[{"product_id": 11, "quantity": 22}, {"product_id": 12, "quantity": 50}]' -- JSON for products
);

CALL add_purchase(
    48, -- Supplier ID
    '2024-5-22', -- Purchase date
    '[{"product_id": 11, "quantity": 10, "price": 7400.00}, {"product_id": 12, "quantity": 5, "price": 7500.00}, {"product_id": 13, "quantity": 5, "price": 180.00}]' -- JSON for products (with price)
);

