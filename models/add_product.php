<?php
session_start();

// Set content type to JSON
header('Content-Type: application/json');

// Check if user is logged in and is admin
if (!isset($_SESSION['user_id']) || !isset($_SESSION['is_admin']) || !$_SESSION['is_admin']) {
    http_response_code(403);
    echo json_encode(['success' => false, 'message' => 'Unauthorized access']);
    exit;
}

require_once __DIR__ . '/../config/db.php';

// Get and validate input data
$data = json_decode(file_get_contents('php://input'), true);

if ($_SERVER['REQUEST_METHOD'] !== 'POST' || !$data) {
    http_response_code(400);
    echo json_encode(['success' => false, 'message' => 'Invalid request']);
    exit;
}

// Validate required fields
$required = ['product_name', 'price', 'quantity'];
foreach ($required as $field) {
    if (empty($data[$field])) {
        http_response_code(400);
        echo json_encode(['success' => false, 'message' => "Missing required field: $field"]);
        exit;
    }
}

// Sanitize input
$name = filter_var($data['product_name'], FILTER_SANITIZE_STRING);
$description = isset($data['description']) ? filter_var($data['description'], FILTER_SANITIZE_STRING) : '';
$price = filter_var($data['price'], FILTER_VALIDATE_FLOAT);
$quantity = filter_var($data['quantity'], FILTER_VALIDATE_INT);
$image = isset($data['image_url']) ? filter_var($data['image_url'], FILTER_SANITIZE_URL) : '';

// Validate data types
if ($price === false || $price <= 0) {
    http_response_code(400);
    echo json_encode(['success' => false, 'message' => 'Invalid price']);
    exit;
}

if ($quantity === false || $quantity < 0) {
    http_response_code(400);
    echo json_encode(['success' => false, 'message' => 'Invalid quantity']);
    exit;
}

try {
    $stmt = $pdo->prepare("INSERT INTO products (product_name, description, price, quantity, images) VALUES (:name, :description, :price, :quantity, :image)");
    $stmt->execute([
        ':name' => $name,
        ':description' => $description,
        ':price' => $price,
        ':quantity' => $quantity,
        ':image' => $image
    ]);

    echo json_encode([
        'success' => true,
        'message' => 'Product added successfully',
        'product_id' => $pdo->lastInsertId()
    ]);
} catch (PDOException $e) {
    http_response_code(500);
    echo json_encode([
        'success' => false,
        'message' => 'Database error: ' . $e->getMessage()
    ]);
}