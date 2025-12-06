<?php
include 'db.php';

if (isset($_POST['delete_product'])) {
    $productName = $_POST['product_name_delete'];

    try {
        // Start a transaction to ensure data integrity
        $pdo->beginTransaction();

        // Get the product ID from the products table based on the product name
        $getProductId = $pdo->prepare("SELECT id FROM products WHERE product_name = :product_name LIMIT 1");
        $getProductId->bindParam(':product_name', $productName);
        $getProductId->execute();
        
        $product = $getProductId->fetch(PDO::FETCH_ASSOC);
        
        if ($product) {
            // Store the product ID
            $productId = $product['id'];

            // Delete from the inventory table where the correct column name matches
            $deleteInventory = $pdo->prepare("DELETE FROM inventory WHERE id = :product_id");
            $deleteInventory->bindParam(':product_id', $productId);
            $deleteInventory->execute();

            // Delete from the suppliers table where the product_id matches
            $deleteSupplier = $pdo->prepare("DELETE FROM suppliers WHERE product_id = :product_id");
            $deleteSupplier->bindParam(':product_id', $productId);
            $deleteSupplier->execute();

            // Finally, delete the product from the products table
            $deleteProduct = $pdo->prepare("DELETE FROM products WHERE id = :product_id");
            $deleteProduct->bindParam(':product_id', $productId);
            $deleteProduct->execute();

            // Commit the transaction
            $pdo->commit();

            // Redirect back to the products page after deletion
            header('Location: index.php');
            exit;
        } else {
            echo "Product not found.";
        }
    } catch (Exception $e) {
        // Rollback the transaction in case of an error
        $pdo->rollBack();
        echo "Error occurred: " . $e->getMessage();
    }
}
?>
