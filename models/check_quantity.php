<?php
session_start();

// Set content type to JSON
header('Content-Type: application/json');

// Check if user is logged in
if (!isset($_SESSION['user_id'])) {
    http_response_code(401);
    echo json_encode(['error' => 'Unauthorized access']);
    exit;
}

require_once __DIR__ . '/../config/db.php';

try {
    // Validate input
    if (!isset($_GET['id']) || !is_numeric($_GET['id'])) {
        http_response_code(400);
        echo json_encode(['error' => 'Invalid product ID']);
        exit;
    }

    $productId = (int)$_GET['id'];
    
    // Fetch the product quantity from the inventory
    $stmt = $pdo->prepare("SELECT quantity FROM inventory WHERE id = :id");
    $stmt->execute([':id' => $productId]);
    $product = $stmt->fetch(PDO::FETCH_ASSOC);

    if ($product) {
        echo json_encode([
            'success' => true,
            'quantity' => (int)$product['quantity']
        ]);
    } else {
        echo json_encode([
            'success' => false,
            'message' => 'Product not found',
            'quantity' => 0
        ]);
    }
} catch (PDOException $e) {
    http_response_code(500);
    echo json_encode([
        'success' => false,
        'message' => 'Database error: ' . $e->getMessage()
    ]);
}
