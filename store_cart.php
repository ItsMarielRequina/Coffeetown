<?php
session_start();

header('Content-Type: application/json');

// Check if the request method is POST and the JSON data is provided
if ($_SERVER['REQUEST_METHOD'] === 'POST') {

    header('Location: receipt.php?purchase_id=' . $purchaseId);
    // Get the raw JSON data from the request body
    $json = file_get_contents('php://input');
    $data = json_decode($json, true);

    // Check if cart data is available in the request
    if (isset($data['cart']) && is_array($data['cart'])) {
        // Store the cart data in the session
        $_SESSION['cart'] = $data['cart'];
        echo json_encode(['status' => 'success', 'message' => 'Cart saved successfully.']);
    } else {
        echo json_encode(['status' => 'error', 'message' => 'Invalid cart data.']);
    }
} else {
    echo json_encode(['status' => 'error', 'message' => 'Invalid request method.']);
}
?>

