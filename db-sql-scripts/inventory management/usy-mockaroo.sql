CREATE TABLE Customer(
    CustomerID SERIAL PRIMARY KEY,
    Name VARCHAR(255) NOT NULL,
    Email VARCHAR(255) UNIQUE,
    Phone VARCHAR(20),
    Address TEXT,
    MarketingPreferences TEXT
);

CREATE TABLE Product (
    ProductID SERIAL PRIMARY KEY,
    ProductName VARCHAR(255) NOT NULL,
    Category VARCHAR(100),
    Price DECIMAL(10, 2) NOT NULL,
    SupplierID INT
);

CREATE TABLE Inventory (
    InventoryID SERIAL PRIMARY KEY,
    ProductID INT NOT NULL,
    WarehouseLocation VARCHAR(255),
    QuantityInStock INT DEFAULT 0,
    ReorderLevel INT DEFAULT 0,
    FOREIGN KEY (ProductID) REFERENCES Product(ProductID)
);

CREATE TABLE Sales (
    SaleID SERIAL PRIMARY KEY,
    CustomerID INT NOT NULL,
    SaleDate DATE NOT NULL,
    TotalAmount DECIMAL(10, 2),
    FOREIGN KEY (CustomerID) REFERENCES Customer(CustomerID)
);

CREATE TABLE SalesDetails (
    SaleDetailID SERIAL PRIMARY KEY,
    SaleID INT NOT NULL,
    ProductID INT NOT NULL,
    Quantity INT NOT NULL,
    Price DECIMAL(10, 2) NOT NULL,
    FOREIGN KEY (SaleID) REFERENCES Sales(SaleID),
    FOREIGN KEY (ProductID) REFERENCES Product(ProductID)
);

CREATE TABLE Supplier (
    SupplierID SERIAL PRIMARY KEY,
    SupplierName VARCHAR(255) NOT NULL,
    ContactName VARCHAR(255),
    Phone VARCHAR(20),
    Address TEXT
);

CREATE TABLE Distribution (
    DistributionID SERIAL PRIMARY KEY,
    SaleID INT NOT NULL,
    ShippingDate DATE,
    DeliveryDate DATE,
    LogisticsPartner VARCHAR(255),
    TrackingNumber VARCHAR(50),
    FOREIGN KEY (SaleID) REFERENCES Sales(SaleID)
);

CREATE TABLE MarketingCampaign (
    CampaignID SERIAL PRIMARY KEY,
    CampaignName VARCHAR(255) NOT NULL,
    StartDate DATE,
    EndDate DATE,
    Channel VARCHAR(100),
    Budget DECIMAL(10, 2)
);
