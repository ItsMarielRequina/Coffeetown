<?php
session_start();
include 'db.php'; // Include your database connection

// Handle login form submission
if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $username = $_POST['username'];
    $password = $_POST['password'];
    
    // Query to validate user
    $stmt = $pdo->prepare("SELECT id, password FROM staff WHERE username = :username");
    $stmt->execute(['username' => $username]);
    $user = $stmt->fetch(PDO::FETCH_ASSOC);
    
    if ($user && password_verify($password, $user['password'])) {
        $_SESSION['user_id'] = $user['id']; // Set session user_id

        // Record login in login_logs table
        $stmt = $pdo->prepare("INSERT INTO login_logs (user_id) VALUES (:user_id)");
        $stmt->execute(['user_id' => $user['id']]);

        header("Location: index.php"); // Redirect to the main page
        exit;
    } else {
        $error = "Invalid username or password!";
    }
}
?>

<!DOCTYPE html>
<html lang="en">
<head>
<link rel="icon" href="images/favicon.ico" type="image/x-icon">
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Login - Coffee Town</title>
    <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;600&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0-beta3/css/all.min.css">
    
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }

        body {
            font-family: 'Poppins', sans-serif;
            background: linear-gradient(130deg, #ffddcc, #f0f0f0, #004f2d);
            background-size: 300% 300%;
            animation: gradientBG 10s ease infinite;
            height: 100vh;
            display: flex;
            justify-content: center;
            align-items: center;
        }

        @keyframes gradientBG {
            0% { background-position: 0% 50%; }
            50% { background-position: 100% 50%; }
            100% { background-position: 0% 50%; }
        }

        .login-container {
            background: rgba(255, 255, 255, 0.1);
            backdrop-filter: blur(10px);
            border-radius: 20px;
            padding: 60px 40px;
            box-shadow: 0 10px 25px rgba(0, 0, 0, 0.2);
            width: 400px;
            text-align: center;
            position: relative;
        }

        .login-container:before, .login-container:after {
            content: '';
            position: absolute;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
            border-radius: 20px;
            pointer-events: none;
            background: linear-gradient(45deg, #ff9a9e 0%, #fad0c4 100%);
            opacity: 0.1;
            z-index: -1;
        }

        .login-container h1 {
            font-size: 36px;
            color: #006241;
            margin-bottom: 20px;
            position: relative;
        }

        .login-container h1::after {
            content: '';
            position: absolute;
            bottom: -5px;
            left: 50%;
            transform: translateX(-50%);
            width: 70px;
            height: 4px;
            background-color: #006241;
            border-radius: 2px;
            animation: titleUnderline 1.5s infinite alternate ease-in-out;
        }

        @keyframes titleUnderline {
            from { width: 0; }
            to { width: 70px; }
        }

        .login-container .icon {
            font-size: 70px;
            color: #006241;
            margin-bottom: 10px;
            animation: iconBounce 2s infinite ease-in-out;
        }

        @keyframes iconBounce {
            0%, 100% { transform: translateY(0); }
            50% { transform: translateY(-10px); }
        }

        .login-container input {
            width: 100%;
            padding: 15px;
            margin: 15px 0;
            border: none;
            border-radius: 50px;
            background: #f7f7f7;
            box-shadow: inset 4px 4px 8px rgba(0, 0, 0, 0.1), inset -4px -4px 8px rgba(255, 255, 255, 0.7);
            font-size: 16px;
            transition: all 0.3s ease;
        }

        .login-container input:focus {
            outline: none;
            box-shadow: inset 4px 4px 10px rgba(0, 0, 0, 0.15), inset -4px -4px 10px rgba(255, 255, 255, 0.9);
        }

        .login-container button {
            width: 100%;
            padding: 15px;
            border: none;
            border-radius: 50px;
            background-color: #006241;
            color: white;
            font-size: 18px;
            cursor: pointer;
            box-shadow: 0 5px 15px rgba(0, 0, 0, 0.1);
            transition: background-color 0.3s ease, transform 0.3s ease;
        }

        .login-container button:hover {
            background-color: #004f2d;
            transform: translateY(-2px);
        }

        .login-container button:active {
            transform: translateY(2px);
        }

        .error {
            color: #d32f2f;
            margin-top: 15px;
            font-size: 16px;
        }

        .link {
            margin-top: 30px;
            display: block;
            color: #006241;
            font-size: 14px;
            text-decoration: none;
            transition: color 0.3s;
        }

        .link:hover {
            color: #004f2d;
            text-decoration: underline;
        }
    </style>
</head>
<body>
    <div class="login-container">
        <i class="fas fa-coffee icon"></i>
        <h1>Login</h1>
        <?php if (isset($error)): ?>
            <p class="error"><?php echo $error; ?></p>
        <?php endif; ?>
        <form method="POST">
            <input type="text" name="username" placeholder="Username" required>
            <input type="password" name="password" placeholder="Password" required>
            <button type="submit">Login</button>
            <a href="signup.php" class="link">Don't have an account? Sign up</a>
        </form>
    </div>
</body>
</html>
