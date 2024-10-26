CREATE TABLE Products (
    product_id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    description TEXT,
    price NUMERIC(10, 2) NOT NULL,
    stock_quantity INTEGER DEFAULT 0
);
CREATE TABLE Suppliers (
    supplier_id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    contact_info TEXT,
    address TEXT
);
CREATE TABLE Purchases (
    purchase_id SERIAL PRIMARY KEY,
    supplier_id INTEGER REFERENCES Suppliers(supplier_id),
    product_id INTEGER REFERENCES Products(product_id),
    quantity INTEGER NOT NULL,
    purchase_date DATE NOT NULL,
    price NUMERIC(10, 2) NOT NULL
);
CREATE TABLE Sales (
    sale_id SERIAL PRIMARY KEY,
    product_id INTEGER REFERENCES Products(product_id),
    quantity INTEGER NOT NULL,
    sale_date DATE NOT NULL,
    sale_price NUMERIC(10, 2) NOT NULL
);

--Triggers
CREATE TRIGGER update_stock_after_purchase
AFTER INSERT ON Purchases
FOR EACH ROW
BEGIN
    UPDATE Products
    SET stock_quantity = stock_quantity + NEW.quantity
    WHERE product_id = NEW.product_id;
END;

CREATE TRIGGER update_stock_after_sale
AFTER INSERT ON Sales
FOR EACH ROW
BEGIN
	-- Check if there is enough stock to fulfill the sale
	IF (SELECT stock_quantity FROM Products WHERE product_id = NEW.product_id) < NEW.quantity THEN
        RAISE EXCEPTION 'Insufficient stock for product_id: %', NEW.product_id;
    ELSE
    	UPDATE Products
    	SET stock_quantity = stock_quantity - NEW.quantity
    	WHERE product_id = NEW.product_id;
END;

--retrieve the product’s price and use it as the sale price during each sale insertion
CREATE OR REPLACE FUNCTION set_sale_price()
RETURNS TRIGGER AS $$
BEGIN
    -- Retrieve the product's price and assign it to the sale price
    SELECT price INTO NEW.sale_price
    FROM Products
    WHERE product_id = NEW.product_id;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER purchase_stock_update
AFTER INSERT ON Purchases
FOR EACH ROW
EXECUTE FUNCTION update_stock_after_purchase();

CREATE TRIGGER sale_stock_update
AFTER INSERT ON Sales
FOR EACH ROW
EXECUTE FUNCTION update_stock_after_sale();

CREATE TRIGGER set_price_before_insert
BEFORE INSERT ON Sales
FOR EACH ROW
WHEN (NEW.sale_price IS NULL) -- Only if sale_price is not provided
EXECUTE FUNCTION set_sale_price();

--Procedures
-- Alerts if product stocks < 10
CREATE OR REPLACE PROCEDURE restocking_alert()
LANGUAGE plpgsql
AS $$
DECLARE
    rec RECORD;
BEGIN
    FOR rec IN
        SELECT product_id, name, stock_quantity
        FROM Products
        WHERE stock_quantity < 10
    LOOP
        RAISE NOTICE 'Product ID: %, Name: %, Stock Quantity: %', rec.product_id, rec.name, rec.stock_quantity;
    END LOOP;
END;
$$;
-- Sales Report of Month
CREATE OR REPLACE PROCEDURE monthly_sales_report(report_date DATE)
LANGUAGE plpgsql
AS $$
BEGIN
    SELECT product_id, SUM(quantity) AS total_quantity, SUM(quantity * sale_price) AS total_sales
    FROM Sales
    WHERE sale_date BETWEEN report_date AND report_date + INTERVAL '1 month' - INTERVAL '1 day'
    GROUP BY product_id;
END;
$$;
