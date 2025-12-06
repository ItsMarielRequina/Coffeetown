<?php
session_start();

// Check if user is logged in
if (!isset($_SESSION['user_id'])) {
    header('Location: /Coffeetown/views/auth/login.php?redirect=' . urlencode($_SERVER['REQUEST_URI']));
    exit;
}

require_once __DIR__ . '/../../config/db.php';

// Fetch cart items with product details
function fetchCartItems($userId) {
    global $db;
    $stmt = $db->prepare("
        SELECT 
            ci.product_id, 
            p.product_name,
            ci.quantity, 
            p.price,
            (p.price * ci.quantity) as total_price
        FROM cart_items ci 
        JOIN products p ON ci.product_id = p.id 
        WHERE ci.user_id = ?
    ");
    $stmt->execute([$userId]);
    return $stmt->fetchAll(PDO::FETCH_ASSOC);
}

$userId = $_SESSION['user_id'];
$cartItems = fetchCartItems($userId);
$totalAmount = array_sum(array_column($cartItems, 'total_price'));
?>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Checkout - CoffeeTown</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <style>
        .checkout-container {
            max-width: 1000px;
            margin: 2rem auto;
            padding: 2rem;
            background: #fff;
            border-radius: 10px;
            box-shadow: 0 0 15px rgba(0,0,0,0.1);
        }
        .cart-summary {
            background: #f8f9fa;
            padding: 1.5rem;
            border-radius: 8px;
        }
        .cart-item {
            padding: 1rem 0;
            border-bottom: 1px solid #eee;
        }
    </style>
</head>
<body>
    <div class="container checkout-container">
        <h2 class="mb-4">Checkout</h2>
        
        <div class="row">
            <div class="col-md-7">
                <div class="card mb-4">
                    <div class="card-header">
                        <h5>Shipping Information</h5>
                    </div>
                    <div class="card-body">
                        <form id="checkoutForm" action="/Coffeetown/controllers/process_checkout.php" method="POST">
                            <input type="hidden" name="total_amount" value="<?php echo $totalAmount; ?>">
                            
                            <div class="mb-3">
                                <label for="name" class="form-label">Full Name</label>
                                <input type="text" class="form-control" id="name" name="customer_name" required>
                            </div>
                            
                            <div class="mb-3">
                                <label for="email" class="form-label">Email</label>
                                <input type="email" class="form-control" id="email" name="email" required>
                            </div>
                            
                            <div class="mb-3">
                                <label for="address" class="form-label">Shipping Address</label>
                                <textarea class="form-control" id="address" name="address" rows="3" required></textarea>
                            </div>
                            
                            <div class="mb-3">
                                <label for="phone" class="form-label">Phone Number</label>
                                <input type="tel" class="form-control" id="phone" name="phone" required>
                            </div>
                            
                            <div class="mb-3">
                                <label class="form-label">Payment Method</label>
                                <div class="form-check">
                                    <input class="form-check-input" type="radio" name="payment_method" id="cod" value="cod" checked>
                                    <label class="form-check-label" for="cod">
                                        Cash on Delivery (COD)
                                    </label>
                                </div>
                                <div class="form-check">
                                    <input class="form-check-input" type="radio" name="payment_method" id="card" value="card">
                                    <label class="form-check-label" for="card">
                                        Credit/Debit Card
                                    </label>
                                </div>
                            </div>
                            
                            <div id="cardDetails" class="mb-3 d-none">
                                <div class="mb-3">
                                    <label for="cardNumber" class="form-label">Card Number</label>
                                    <input type="text" class="form-control" id="cardNumber" name="card_number" placeholder="1234 5678 9012 3456">
                                </div>
                                <div class="row">
                                    <div class="col-md-6">
                                        <label for="expiry" class="form-label">Expiry Date</label>
                                        <input type="text" class="form-control" id="expiry" name="expiry" placeholder="MM/YY">
                                    </div>
                                    <div class="col-md-6">
                                        <label for="cvv" class="form-label">CVV</label>
                                        <input type="text" class="form-control" id="cvv" name="cvv" placeholder="123">
                                    </div>
                                </div>
                            </div>
                            
                            <div class="d-grid gap-2 mt-4">
                                <button type="submit" class="btn btn-primary btn-lg">Complete Order</button>
                                <a href="/Coffeetown/views/orders/order.php" class="btn btn-outline-secondary">Back to Cart</a>
                            </div>
                        </form>
                    </div>
                </div>
            </div>
            
            <div class="col-md-5">
                <div class="cart-summary">
                    <h5 class="mb-4">Order Summary</h5>
                    
                    <?php if (empty($cartItems)): ?>
                        <p>Your cart is empty.</p>
                        <a href="/Coffeetown/views/products/products.php" class="btn btn-primary">Continue Shopping</a>
                    <?php else: ?>
                        <?php foreach ($cartItems as $item): ?>
                            <div class="cart-item">
                                <div class="d-flex justify-content-between">
                                    <div>
                                        <h6><?php echo htmlspecialchars($item['product_name']); ?></h6>
                                        <small class="text-muted">Qty: <?php echo $item['quantity']; ?></small>
                                    </div>
                                    <div class="text-end">
                                        <div>₱<?php echo number_format($item['total_price'], 2); ?></div>
                                        <small class="text-muted">₱<?php echo number_format($item['price'], 2); ?> each</small>
                                    </div>
                                </div>
                            </div>
                        <?php endforeach; ?>
                        
                        <div class="border-top pt-3 mt-3">
                            <div class="d-flex justify-content-between fw-bold">
                                <span>Total:</span>
                                <span>₱<?php echo number_format($totalAmount, 2); ?></span>
                            </div>
                        </div>
                    <?php endif; ?>
                </div>
            </div>
        </div>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/js/bootstrap.bundle.min.js"></script>
    <script>
        // Toggle card details based on payment method
        document.querySelectorAll('input[name="payment_method"]').forEach(radio => {
            radio.addEventListener('change', function() {
                const cardDetails = document.getElementById('cardDetails');
                if (this.value === 'card') {
                    cardDetails.classList.remove('d-none');
                } else {
                    cardDetails.classList.add('d-none');
                }
            });
        });

        // Form submission
        document.getElementById('checkoutForm').addEventListener('submit', function(e) {
            const paymentMethod = document.querySelector('input[name="payment_method"]:checked').value;
            
            if (paymentMethod === 'card') {
                // Add client-side validation for card details if needed
                const cardNumber = document.getElementById('cardNumber').value;
                const expiry = document.getElementById('expiry').value;
                const cvv = document.getElementById('cvv').value;
                
                if (!cardNumber || !expiry || !cvv) {
                    e.preventDefault();
                    alert('Please fill in all card details');
                    return false;
                }
            }
            
            // Show loading state
            const submitBtn = this.querySelector('button[type="submit"]');
            submitBtn.disabled = true;
            submitBtn.innerHTML = '<span class="spinner-border spinner-border-sm" role="status" aria-hidden="true"></span> Processing...';
        });
    </script>
</body>
</html>
