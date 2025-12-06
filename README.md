# CoffeeTown - Coffee Shop Management System

## Project Description
CoffeeTown is a comprehensive coffee shop management system designed to handle inventory, sales, and customer orders efficiently. The system provides an intuitive interface for both staff and administrators to manage products, process orders, and track inventory in real-time.

## Features

### 1. Product Management (CRUD)
- **Create**: Add new products with details like name, description, price, and images
- **Read**: View product listings with search and filter options
- **Update**: Modify product information and stock levels
- **Delete**: Remove products from the system

### 2. Order Processing
- Process customer orders with multiple items
- Handle different payment methods (Cash, Card)
- Generate digital receipts
- Track order status in real-time

### 3. Inventory Management
- Track product quantities
- Set low stock alerts
- Record stock movements
- Generate inventory reports

### 4. User Management
- Role-based access control (Admin, Staff)
- Secure authentication
- User activity logging

### 5. Sales & Reporting
- Daily, weekly, and monthly sales reports
- Best-selling products
- Revenue analytics

## Setup Instructions

### Prerequisites
- PHP 7.4 or higher
- MySQL 5.7 or higher
- Web server (Apache/Nginx)
- Composer (for dependency management)

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/yourusername/coffeetown.git
   cd coffeetown
   ```

2. **Install dependencies**
   ```bash
   composer install
   ```

3. **Configure the database**
   - Create a new MySQL database
   - Import the database schema from `database/coffeetown.sql`
   - Copy `.env.example` to `.env` and update database credentials

4. **Set up the application**
   ```bash
   php artisan key:generate
   php artisan migrate
   php artisan db:seed
   ```

5. **Start the development server**
   ```bash
   php artisan serve
   ```

6. **Access the application**
   Open your browser and visit: `http://localhost:8000`

## Screenshots

### Dashboard
![Dashboard](screenshots/dashboard.png)

### Sales Management
![Products](screenshots/sales.png)

### Order Processing
![Orders](screenshots/receipt.png)

### Reports
![Reports](screenshots/reports.png)

## Database Schema

The application uses the following main tables:
- `users` - User accounts and authentication
- `products` - Product information
- `categories` - Product categories
- `orders` - Customer orders
- `order_items` - Individual items within orders
- `inventory` - Stock management
- `transactions` - Payment records

## API Documentation

The system provides a RESTful API for integration with other systems. See the [API Documentation](API.md) for details.

## Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Support

For support, email support@coffeetown.com or open an issue in the GitHub repository.
