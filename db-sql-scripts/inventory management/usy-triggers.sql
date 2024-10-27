--Deducts stock_quantity in Products table for every sale
CREATE OR REPLACE FUNCTION update_stock_on_sale()
RETURNS TRIGGER AS $$
BEGIN
    IF (SELECT stock_quantity FROM Products WHERE id = NEW.product_id) < NEW.quantity THEN
        --If not enough stock, raise an error to prevent the sale
        RAISE EXCEPTION 'Not enough stock for product id %', NEW.product_id;
    ELSE
        UPDATE Products
        SET stock_quantity = stock_quantity - NEW.quantity
        WHERE id = NEW.product_id;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_update_stock_on_sale
BEFORE INSERT ON SalesDetails
FOR EACH ROW
EXECUTE FUNCTION update_stock_on_sale();

--Adds stock_quantity in Products table for every purchase
CREATE OR REPLACE FUNCTION update_stock_on_purchase()
RETURNS TRIGGER AS $$
BEGIN
    -- Update the stock quantity by adding the purchased quantity
    UPDATE Products
    SET stock_quantity = stock_quantity + NEW.quantity
    WHERE id = NEW.product_id;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_update_stock_on_purchase
AFTER INSERT ON PurchaseDetails
FOR EACH ROW
EXECUTE FUNCTION update_stock_on_purchase();


--Adds records to InventoryAudit for every Sale / Purchase
CREATE OR REPLACE FUNCTION log_inventory_change()
RETURNS TRIGGER AS $$
DECLARE
    v_quantity_change INT;
BEGIN
    --Calculate the quantity change
    v_quantity_change := NEW.stock_quantity - OLD.stock_quantity;

    --Insert record into the InventoryAudit table
    INSERT INTO InventoryAudit (
        product_id,
        change_type,
        quantity_change,
        updated_stock,
        date
    )
    VALUES (
        NEW.id,
        CASE
            WHEN v_quantity_change > 0 THEN 'PURCHASE'
            WHEN v_quantity_change < 0 THEN 'SALE'
            ELSE 'MANUAL ADJUSTMENT'
        END,  -- The change type
        v_quantity_change,  --Quantity change (positive for addition, negative for reduction)
        NEW.stock_quantity,  --Updated stock level
        CURRENT_TIMESTAMP
    );

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_log_inventory_change
AFTER UPDATE OF stock_quantity ON Products
FOR EACH ROW
WHEN (OLD.stock_quantity IS DISTINCT FROM NEW.stock_quantity)
EXECUTE FUNCTION log_inventory_change();


--##############################################################################################################################