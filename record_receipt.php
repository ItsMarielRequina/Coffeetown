<?php
session_start();
include 'db.php'; // Include your database connection

if (!isset($_SESSION['customer_id'])) {
    header('Location: login.php'); // Redirect if no customer ID is found
    exit;
}

// Get the customer ID
$customer_id = $_SESSION['customer_id'];

// Assuming purchases come from a POST request (from a form)
$purchases = $_POST['purchases']; // This should be an array of purchases

if (!empty($purchases) && is_array($purchases)) {
    try {
        // Begin a transaction
        $pdo->beginTransaction();

        // Prepare statement to save receipt
        $stmt = $pdo->prepare("
            INSERT INTO receipts (customerID, item_name, quantity, price, total_amount)
            VALUES (:customerID, :item_name, :quantity, :price, :total_amount)
        ");

        // Loop through each purchase item and save it
        foreach ($purchases as $purchase) {
            // Validate input (ensure all required keys are present)
            if (
                isset($purchase['item_name'], $purchase['quantity'], $purchase['price'], $purchase['total_amount']) &&
                is_numeric($purchase['quantity']) && 
                is_numeric($purchase['price']) && 
                is_numeric($purchase['total_amount'])
            ) {
                // Execute the insert statement
                $stmt->execute([
                    'customerID' => $customer_id,
                    'item_name' => $purchase['item_name'],
                    'quantity' => (int)$purchase['quantity'], // Cast to int
                    'price' => (float)$purchase['price'],     // Cast to float
                    'total_amount' => (float)$purchase['total_amount'] // Cast to float
                ]);
            } else {
                // Handle missing or invalid data
                throw new Exception("Invalid purchase data.");
            }
        }

        // Commit the transaction
        $pdo->commit();

        // After saving, redirect to the transaction page
        header('Location: transaction.php'); // Redirect to view the receipts
        exit;

    } catch (Exception $e) {
        // Rollback the transaction in case of error
        $pdo->rollBack();
        // Log error or display message
        echo "Failed to record receipts: " . htmlspecialchars($e->getMessage());
    }
} else {
    echo "No purchases found.";
}
?>
