# TJ Sims Backend API

A robust Express.js backend API for the TJ Sims autoparts management system, built with MySQL database integration.

## 📋 Table of Contents

- [Features](#features)
- [Tech Stack](#tech-stack)
- [Prerequisites](#prerequisites)
- [Installation](#installation)
- [Configuration](#configuration)
- [Database Setup](#database-setup)
- [Usage](#usage)
- [API Endpoints](#api-endpoints)
- [Project Structure](#project-structure)
- [Development](#development)

## ✨ Features

- **Product Management**: Full CRUD operations for autoparts products
- **Database Integration**: MySQL with connection pooling
- **Security**: Helmet security headers, rate limiting, CORS
- **Error Handling**: Comprehensive error handling middleware
- **Environment Configuration**: Flexible configuration management
- **Graceful Shutdown**: Proper cleanup on application termination
- **Health Monitoring**: Built-in health check endpoint

## 🛠 Tech Stack

- **Runtime**: Node.js
- **Framework**: Express.js
- **Database**: MySQL
- **ORM**: Raw SQL queries with mysql2
- **Security**: Helmet, CORS, Rate Limiting
- **Environment**: dotenv
- **Development**: nodemon

## 📋 Prerequisites

- Node.js (v16 or higher)
- MySQL (v8.0 or higher)
- npm or yarn package manager

## 🚀 Installation

1. **Navigate to backend directory:**
   ```bash
   cd backend
   ```

2. **Install dependencies:**
   ```bash
   npm install
   ```

3. **Set up environment variables:**
   ```bash
   cp .env.example .env
   ```

4. **Configure your `.env` file with your database credentials**

## ⚙️ Configuration

Create a `.env` file in the backend root directory:

```env
# Server Configuration
PORT=5000
NODE_ENV=development

# Database Configuration
DB_HOST=localhost
DB_PORT=3306
DB_NAME=tjsims_db
DB_USER=root
DB_PASSWORD=your_mysql_password

# JWT Configuration (for future auth features)
JWT_SECRET=your_super_secret_jwt_key_here
JWT_EXPIRE=7d

# File Upload Configuration
MAX_FILE_SIZE=5242880
UPLOAD_DIR=uploads/

# CORS Configuration
FRONTEND_URL=http://localhost:5173
```

## 🗄️ Database Setup

1. **Create the database:**
   ```sql
   CREATE DATABASE tjsims_db;
   ```

2. **Run the database setup script:**
   ```bash
   mysql -u root -p tjsims_db < database_setup.sql
   ```

   Or import the `database_setup.sql` file through your MySQL client.

## 🎯 Usage

### Development Mode
```bash
npm run dev
```

### Production Mode
```bash
npm start
```

The server will start on `http://localhost:5000`

## 📡 API Endpoints

### Health Check
- **GET** `/health` - Check API status

### Products
- **GET** `/api/products` - Get all products (with optional filtering)
- **GET** `/api/products/categories` - Get all categories
- **GET** `/api/products/brands` - Get all brands
- **GET** `/api/products/:id` - Get product by ID
- **POST** `/api/products` - Create new product
- **PUT** `/api/products/:id` - Update product
- **DELETE** `/api/products/:id` - Delete product

### Query Parameters for Products
- `search` - Search in product name, ID, or brand
- `category` - Filter by category
- `brand` - Filter by brand
- `status` - Filter by status (Active/Inactive)
- `page` - Page number for pagination
- `limit` - Items per page (default: 10)

## 📁 Project Structure

```
backend/
├── src/
│   ├── config/
│   │   └── database.js          # Database connection setup
│   ├── controllers/
│   │   └── ProductController.js # Product business logic
│   ├── middleware/
│   │   └── index.js             # CORS, security, error handling
│   ├── models/
│   │   └── Product.js           # Product data model
│   ├── routes/
│   │   ├── index.js             # Main routes aggregator
│   │   └── api/
│   │       └── products.js      # Product API routes
│   └── server.js                # Main application file
├── database_setup.sql           # Database schema and sample data
├── .env                         # Environment variables
├── .env.example                 # Environment template
├── nodemon.json                 # Development configuration
└── package.json                 # Dependencies and scripts
```

## 🔧 Development

### Available Scripts

- `npm run dev` - Start development server with nodemon
- `npm start` - Start production server
- `npm test` - Run tests (placeholder)

### Database Models

The Product model supports:
- Full CRUD operations
- Filtering and searching
- Category and brand management
- Status management

### Error Handling

The API includes comprehensive error handling:
- 404 for not found resources
- 500 for server errors
- Validation errors
- Database connection errors

## 🔒 Security Features

- **Helmet**: Security headers
- **CORS**: Cross-origin resource sharing
- **Rate Limiting**: Prevents abuse (100 requests per 15 minutes)
- **Input Validation**: SQL injection prevention
- **Environment Variables**: Secure configuration

## 🚀 Next Steps

Future enhancements you might consider:
- User authentication and authorization
- File upload handling for product images
- Advanced search and filtering
- Inventory management
- Order management
- API documentation with Swagger
- Unit and integration tests
- Logging with Winston
- Caching with Redis

## 📞 Support

For issues or questions regarding the backend setup, refer to:
- Express.js documentation
- MySQL documentation
- The provided source code comments

---

**Happy coding!** 🎉
