CREATE TABLE Customer(
    id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    email VARCHAR(255) UNIQUE,
    phone VARCHAR(20),
    address TEXT
);

CREATE TABLE Products (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    supplier_id INT,
    category VARCHAR(100),
    stock_quantity INT DEFAULT 0,
    reorder_level INT DEFAULT 0,
    price DECIMAL(10, 2) NOT NULL,
    stored_location TEXT,
    FOREIGN KEY (supplier_id) REFERENCES Supplier(id)
);

CREATE TABLE Supplier (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    contact_name VARCHAR(255),
    phone VARCHAR(20),
    address TEXT
);

CREATE TABLE Sales (
    id SERIAL PRIMARY KEY,
    customer_id INT NOT NULL,
    date DATE NOT NULL,
    total_amount DECIMAL(10, 2),
    FOREIGN KEY (customer_id) REFERENCES Customer(id)
);

CREATE TABLE SalesDetails (
    id SERIAL PRIMARY KEY,
    sales_id INT NOT NULL,
    product_id INT NOT NULL,
    quantity INT NOT NULL,
    price DECIMAL(10, 2) NOT NULL,
    FOREIGN KEY (sales_id) REFERENCES Sales(id),
    FOREIGN KEY (product_id) REFERENCES Products(id)
);

CREATE TABLE Purchase (
    id SERIAL PRIMARY KEY,
    supplier_id INT NOT NULL,
    date DATE NOT NULL,
    total_amount DECIMAL(10, 2),
    FOREIGN KEY (supplier_id) REFERENCES Supplier(id)
);

CREATE TABLE PurchaseDetails (
    id SERIAL PRIMARY KEY,
    purchase_id INT NOT NULL,
    product_id INT NOT NULL,
    quantity INT NOT NULL,
    price DECIMAL(10, 2) NOT NULL,
    FOREIGN KEY (purchase_id) REFERENCES Purchase(id),
    FOREIGN KEY (product_id) REFERENCES Products(id)
);

CREATE TABLE InventoryAudit (
    id SERIAL PRIMARY KEY,
    product_id INT NOT NULL,
    change_type VARCHAR(50) NOT NULL,  --'SALE', 'PURCHASE', 'RESTOCK', 'MANUAL ADJUSTMENT'
    quantity_change INT NOT NULL,  --Positive for adding stock, negative for reducing stock
    updated_stock INT NOT NULL,  --The new stock level after the change
    date TIMESTAMP DEFAULT CURRENT_TIMESTAMP  -- When the change occurred
);
