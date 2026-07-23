# 📱 SIBU (Smart Inventory Butik)

**SIBU (Smart Inventory Butik)** is a mobile-based inventory management application developed as part of our Project Based Learning (PBL). This application helps small boutique owners, particularly **Butik Syar'i Asnayeni**, manage product inventory, record sales transactions, monitor stock levels, and generate reports more efficiently. 🎯

We developed this application to solve the challenges faced by small businesses that still rely on manual bookkeeping, which often leads to inaccurate stock records, inefficient inventory monitoring, and time-consuming sales reporting.

## 🧠 Why We Built This Application

- Boutique owners still rely on manual notebooks to record stock and transactions.
- Real-time stock monitoring is unavailable, increasing the risk of stock shortages or overstock.
- Sales reports must be compiled manually, making the process inefficient.
- There is no automatic notification when stock reaches the minimum threshold.

---

## 👨‍💻 Development Team

| Full Name | Student ID |
|-----------|------------|
| Hanifah Dwi Cahayarani | 3312401019 |
| Melanie Putri | 3312401075 |

---

## 📬 Contact Information

If you have any questions, feedback, or suggestions regarding this project, please feel free to contact us.

- **Email:** hanifahdwicahayarani@gmail.com

---

## 📌 Key Features

### Seller (Admin)

- Login & Logout
- Product Management (Create, Read, Update, Delete)
- Sales Transaction Recording
- Transaction History
- Minimum Stock Notification (Rule-Based System)
- Best-Selling Product Analysis
- Sales Charts (Daily, Weekly, Monthly)
- Stock Replenishment Recommendations (Rule-Based System)
- Sales Report Export (PDF & Excel)
- Period Management for Stock Recommendation

### Buyer (Guest)

- Browse Product Catalog
- View Product Details (Name, Price, Stock)
- Product Recommendations (Category, Price, Newest)
- Contact Seller via WhatsApp

---

## 🔗 Important Links

| Description | Link |
|-------------|------|
| 📄 PBL Report | [Click here](https://drive.google.com/drive/folders/1HvZtNWechJ-B-ngG55QgOZZ1mywoUKUB?usp=sharing) |
| 🎥 Demo Video | [Click here](https://youtu.be/4ManwmsxMpY?si=Qt3fh6xkyWu4e0Gk) |

---

## 📥 How to Download the Report

1. Click one of the links above.
2. The document will open in your browser.
3. Click the **Download** button.
4. Open the downloaded PDF using your preferred PDF reader.

---

# ⚙️ System Requirements

## Backend (Laravel)

- PHP >= 8.1
- Composer
- MySQL or MariaDB
- Git (Optional)

## Frontend (Flutter)

- Flutter SDK >= 3.0
- Android Studio or Visual Studio Code
- Android SDK
- Git (Optional)

---

# 🚀 Installation Guide

## 1. Clone Repository

```bash
git clone https://github.com/hanifah-3312401019/SIBU.git
cd SIBU
```

---

# 2. Backend Setup (Laravel)

## Install Dependencies

```bash
cd backend
composer install
```

## Copy Environment File

```bash
cp .env.example .env
```

## Generate Application Key

```bash
php artisan key:generate
```

## Configure Database

Open the `.env` file and configure the following:

```env
DB_CONNECTION=mysql
DB_HOST=127.0.0.1
DB_PORT=3306
DB_DATABASE=sibu_db
DB_USERNAME=root
DB_PASSWORD=
```

## Run Database Migration & Seeder

```bash
php artisan migrate --seed
```

## Start Laravel Server

```bash
php artisan serve
```

The backend will run at:

```text
http://localhost:8000
```

---

# 3. Frontend Setup (Flutter)

## Navigate to Frontend Folder

```bash
cd ../frontend
```

## Install Flutter Dependencies

```bash
flutter pub get
```

## Configure API URL

For **Android Emulator**, use:

```dart
const String baseUrl = 'http://10.0.2.2:8000/api';
```

For a **Physical Device**, use your local IP address:

```dart
const String baseUrl = 'http://YOUR_LOCAL_IP:8000/api';
```

Example:

```dart
const String baseUrl = 'http://192.168.1.8:8000/api';
```

## Run the Application

```bash
flutter run
```

---

# 📦 Build APK

## Build Release APK

```bash
flutter build apk --release
```

APK output:

```text
frontend/build/app/outputs/flutter-apk/app-release.apk
```

---

## Build Split APK (Per ABI)

```bash
flutter build apk --split-per-abi
```

APK output:

```text
frontend/build/app/outputs/apk/release/
```

---

## Install APK to Connected Device

```bash
flutter install
```

---

# 🧪 Testing

## Backend (Laravel)

| Test Type | Location | Command |
|-----------|----------|----------|
| Unit Test | `backend/tests/Unit/` | `php artisan test` |
| Feature Test | `backend/tests/Feature/` | `php artisan test` |

---

## Frontend (Flutter)

| Test Type | Location | Command |
|-----------|----------|----------|
| Unit Test | `frontend/test/unit/` | `flutter test` |
| Widget Test | `frontend/test/widget_test.dart` | `flutter test` |

---

# 📊 Testing Results

| Test Type | Result |
|-----------|--------|
| ✅ System Testing | **33/33 Test Cases Passed (100%)** |
| ✅ User Acceptance Testing (UAT) | **100% Approved** |
| ⭐ Usability Testing (SUS) | **Score: 88.4 (Excellent)** |

> **SIBU is declared READY FOR PRODUCTION.** 🎉

---