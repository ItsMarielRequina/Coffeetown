<?php
session_start();
include 'db.php'; // Include your database connection

// Sample products data (could be fetched from the database)
$products = [
    ['id' => 1, 'name' => 'Classic Milk Tea', 'price' => 100.00, 'image' => 'images/milk_tea.jpg'],
    ['id' => 2, 'name' => 'Brown Sugar Milk Tea', 'price' => 120.00, 'image' => 'images/brown_sugar_milk_tea.jpg'],
    ['id' => 3, 'name' => 'Taro Milk Tea', 'price' => 110.00, 'image' => 'images/taro_milk_tea.jpg'],
    ['id' => 4, 'name' => 'Wintermelon Milk Tea', 'price' => 115.00, 'image' => 'images/wintermelon_milk_tea.jpg'],
    ['id' => 5, 'name' => 'Matcha Milk Tea', 'price' => 130.00, 'image' => 'images/matcha_milk_tea.jpg'],
    ['id' => 11, 'name' => 'Espresso', 'price' => 80.00, 'image' => 'images/espresso.jpg'],
    ['id' => 12, 'name' => 'Americano', 'price' => 90.00, 'image' => 'images/americano.jpg'],
    // Add other products here
];
?>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Products</title>
    <style>
        body {
            font-family: 'Poppins', sans-serif;
            margin: 0;
            padding: 20px;
            background-color: #f4f4f4;
        }
        .product {
            border: 1px solid #ddd;
            border-radius: 10px;
            padding: 10px;
            margin-bottom: 20px;
            background-color: white;
            text-align: center;
        }
        img {
            max-width: 100%;
            height: auto;
            border-radius: 10px;
        }
        button {
            background-color: #006241;
            color: white;
            border: none;
            padding: 10px 15px;
            border-radius: 5px;
            cursor: pointer;
        }
        button:hover {
            background-color: #004f2d;
        }
    </style>
</head>
<body>
    <h1>Products</h1>
    <?php foreach ($products as $product): ?>
        <div class="product">
            <img src="<?php echo $product['image']; ?>" alt="<?php echo htmlspecialchars($product['name']); ?>">
            <h2><?php echo htmlspecialchars($product['name']); ?></h2>
            <p>₱<?php echo number_format($product['price'], 2); ?></p>
            <form method="POST" action="cart.php" class="add-to-cart-form">
                <input type="hidden" name="name" value="<?php echo htmlspecialchars($product['name']); ?>">
                <input type="hidden" name="price" value="<?php echo $product['price']; ?>">
                <input type="hidden" name="action" value="add">
                <button type="submit">Add to Cart</button>
            </form>
        </div>
    <?php endforeach; ?>
</body>
</html>
