<?php
header('Content-Type: application/json');
require_once __DIR__ . '/../config/db.php';

try {
    // Check if product ID is provided
    if (!isset($_GET['id'])) {
        throw new Exception('Product ID is required');
    }

    // Validate and sanitize the product ID
    $productId = filter_var($_GET['id'], FILTER_VALIDATE_INT);
    if ($productId === false || $productId <= 0) {
        throw new Exception('Invalid product ID');
    }

    // Prepare and execute the query
    $stmt = $pdo->prepare("
        SELECT 
            id, 
            product_name, 
            description,
            price, 
            quantity,
            images,
            created_at,
            updated_at
        FROM products 
        WHERE id = :id 
        AND is_active = 1
    ");
    
    $stmt->execute([':id' => $productId]);
    $product = $stmt->fetch(PDO::FETCH_ASSOC);
    
    // Check if product was found
    (!$product) {
        throw new Exception('Product not found', 404);
    }

    // Format the response
    $response = [
        'success' => true,
        'data' => [
            'id' => (int)$product['id'],
            'name' => $product['product_name'],
            'description' => $product['description'] ?? '',
            'price' => (float)$product['price'],
            'quantity' => (int)$product['quantity'],
            'in_stock' => $product['quantity'] > 0,
            'images' => $product['images'] ? json_decode($product['images'], true) : [],
            'created_at' => $product['created_at'],
            'updated_at' => $product['updated_at']
        ]
    ];

    // Cache control headers
    header('Cache-Control: public, max-age=3600'); // Cache for 1 hour
    header('ETag: "' . md5(json_encode($response)) . '"');
    
    echo json_encode($response, JSON_PRETTY_PRINT | JSON_UNESCAPED_UNICODE);
    
} catch (PDOException $e) {
    // Handle database errors
    http_response_code(500);
    echo json_encode([
        'success' => false,
        'error' => [
            'code' => 'DATABASE_ERROR',
            'message' => 'Failed to retrieve product information'
        ]
    ], JSON_PRETTY_PRINT);
    
} catch (Exception $e) {
    // Handle other errors
    $statusCode = $e->getCode() ?: 400;
    http_response_code($statusCode);
    
    echo json_encode([
        'success' => false,
        'error' => [
            'code' => 'PRODUCT_ERROR',
            'message' => $e->getMessage()
        ]
    ], JSON_PRETTY_PRINT);
}
?>
