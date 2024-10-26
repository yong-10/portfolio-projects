--Sales Entry
-- Step 1: Create the Stored Procedure
CREATE OR REPLACE PROCEDURE add_sale(
    p_customer_id INT,
    p_sale_date DATE,
    p_products JSON -- JSON containing product_id and quantity only
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_sale_id INT; -- Variable to store the new sale ID
    product RECORD; -- Variable to hold individual product data from JSON
    v_price DECIMAL(10, 2); -- Variable to store the product's price
    v_total_amount DECIMAL(10, 2) := 0; -- Variable to calculate total amount
BEGIN
    -- Step 2: Loop through the JSON array to calculate the total amount
    FOR product IN SELECT * FROM json_to_recordset(p_products) AS (
        product_id INT, 
        quantity INT
    )
    LOOP
        -- Fetch the price of the product from the Products table
        SELECT price INTO v_price
        FROM Products
        WHERE id = product.product_id;

        -- Calculate total amount for the sale
        v_total_amount := v_total_amount + (v_price * product.quantity);
    END LOOP;

    -- Step 3: Insert a new sale into the Sales table with calculated total amount
    INSERT INTO Sales (customer_id, date, total_amount)
    VALUES (p_customer_id, p_sale_date, v_total_amount)
    RETURNING id INTO v_sale_id;  -- Get the new sale ID

    -- Step 4: Insert each product's details into SalesDetails table
    FOR product IN SELECT * FROM json_to_recordset(p_products) AS (
        product_id INT, 
        quantity INT
    )
    LOOP
        -- Fetch the price again for each product
        SELECT price INTO v_price
        FROM Products
        WHERE id = product.product_id;

        -- Insert into SalesDetails table
        INSERT INTO SalesDetails (sales_id, product_id, quantity, price)
        VALUES (v_sale_id, product.product_id, product.quantity, v_price);
    END LOOP;

END $$;

--Purchase Entry
--Create the Stored Procedure for Purchases with Specified Prices
CREATE OR REPLACE PROCEDURE add_purchase(
    p_supplier_id INT,
    p_purchase_date DATE,
    p_products JSON -- JSON containing product_id, quantity, and price
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_purchase_id INT; -- Variable to store the new purchase ID
    product RECORD; -- Variable to hold individual product data from JSON
    v_total_amount DECIMAL(10, 2) := 0; -- Variable to calculate total amount
BEGIN
    --Loop through the JSON array to calculate the total amount
    FOR product IN SELECT * FROM json_to_recordset(p_products) AS (
        product_id INT, 
        quantity INT,
        price DECIMAL(10, 2)
    )
    LOOP
        -- Calculate total amount for the purchase
        v_total_amount := v_total_amount + (product.price * product.quantity);
    END LOOP;

    -- Step 3: Insert a new purchase into the Purchase table with calculated total amount
    INSERT INTO Purchase (supplier_id, date, total_amount)
    VALUES (p_supplier_id, p_purchase_date, v_total_amount)
    RETURNING id INTO v_purchase_id;  -- Get the new purchase ID

    -- Step 4: Insert each product's details into PurchaseDetails table
    FOR product IN SELECT * FROM json_to_recordset(p_products) AS (
        product_id INT, 
        quantity INT,
        price DECIMAL(10, 2)
    )
    LOOP
        -- Insert into PurchaseDetails table with provided price
        INSERT INTO PurchaseDetails (purchase_id, product_id, quantity, price)
        VALUES (v_purchase_id, product.product_id, product.quantity, product.price);
    END LOOP;

END $$;
