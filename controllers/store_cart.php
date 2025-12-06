<?php
session_start();

require_once __DIR__ . '/../config/db.php'; // Include database connection

header('Content-Type: application/json');

// Check if the request method is POST and the JSON data is provided
if ($_SERVER['REQUEST_METHOD'] === 'POST') {

    // Get the raw JSON data from the request body
    $json = file_get_contents('php://input');
    $data = json_decode($json, true);

    // Check if cart data is available in the request
    if (isset($data['cart']) && is_array($data['cart'])) {
        // Store the cart data in the session
        $_SESSION['cart'] = $data['cart'];
        $purchaseId = 1; // Assuming a purchase ID is generated
        http_response_code(200);
        $redirectUrl = '/Coffeetown/views/receipts/generate_receipt.php?purchase_id=' . $purchaseId;
        echo json_encode(['success' => true, 'purchase_id' => $purchaseId, 'redirect' => $redirectUrl]);
    } else {
        echo json_encode(['status' => 'error', 'message' => 'Invalid cart data.']);
    }
} else {
    echo json_encode(['status' => 'error', 'message' => 'Invalid request method.']);
}
?>

