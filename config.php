<?php
// ==========================================
// CONFIGURATION & DATABASE CONNECTION
// Bale Ody Villa & Camping Ground Booking System
// Supports: Local MySQL, Production MySQL, & SQLite Local Fallback
// ==========================================

// Deteksi lingkungan: Local vs Production Server
$is_local = in_array($_SERVER['SERVER_NAME'] ?? '', ['localhost', '127.0.0.1'])
         || php_sapi_name() === 'cli-server'
         || (isset($_SERVER['REMOTE_ADDR']) && in_array($_SERVER['REMOTE_ADDR'], ['127.0.0.1', '::1']));

// Parameter MySQL Lokal (XAMPP / Laragon / Native MySQL)
$local_mysql_host = "127.0.0.1";
$local_mysql_name = "bald6243_u12345_baleody"; // Atau 'baleody_db'
$local_mysql_user = "root";
$local_mysql_pass = "";

// Parameter MySQL Server Hosting / Production
$prod_mysql_host  = "localhost";
$prod_mysql_name  = "bald6243_u12345_baleody";
$prod_mysql_user  = "bald6243_u12345_userody";
$prod_mysql_pass  = "JF2J!9=Lzv]+}@Wl";

$conn = null;
$active_driver = null;

if ($is_local) {
    // 1. Coba hubungkan ke MySQL lokal terlebih dahulu
    try {
        $conn = new PDO("mysql:host=$local_mysql_host;dbname=$local_mysql_name;charset=utf8mb4", $local_mysql_user, $local_mysql_pass);
        $conn->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
        $conn->setAttribute(PDO::ATTR_DEFAULT_FETCH_MODE, PDO::FETCH_ASSOC);
        $active_driver = "MySQL (Local: $local_mysql_host / $local_mysql_name)";
    } catch (PDOException $e) {
        // 2. Jika MySQL lokal tidak aktif/belum di-import, otomatis fallback ke SQLite lokal
        // agar simulasi aplikasi langsung bisa berjalan detik ini juga (Zero Config)
        $sqlite_dir = __DIR__ . DIRECTORY_SEPARATOR . 'data';
        if (!is_dir($sqlite_dir)) {
            mkdir($sqlite_dir, 0777, true);
        }
        $sqlite_file = $sqlite_dir . DIRECTORY_SEPARATOR . 'baleody.sqlite';
        $is_new_sqlite = !file_exists($sqlite_file);

        try {
            $conn = new PDO("sqlite:" . $sqlite_file);
            $conn->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
            $conn->setAttribute(PDO::ATTR_DEFAULT_FETCH_MODE, PDO::FETCH_ASSOC);
            $active_driver = "SQLite (Local Fallback: data/baleody.sqlite)";

            if ($is_new_sqlite) {
                init_sqlite_schema($conn);
            }
        } catch (PDOException $se) {
            echo json_encode([
                "status" => "error",
                "message" => "Gagal koneksi database lokal: " . $se->getMessage()
            ]);
            exit();
        }
    }
} else {
    // Lingkungan Production Hosting
    try {
        $conn = new PDO("mysql:host=$prod_mysql_host;dbname=$prod_mysql_name;charset=utf8", $prod_mysql_user, $prod_mysql_pass);
        $conn->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
        $conn->setAttribute(PDO::ATTR_DEFAULT_FETCH_MODE, PDO::FETCH_ASSOC);
        $active_driver = "MySQL (Production Server)";
    } catch (PDOException $e) {
        echo json_encode([
            "status" => "error",
            "message" => "Koneksi database MySQL hosting gagal: " . $e->getMessage()
        ]);
        exit();
    }
}

/**
 * Inisialisasi skema dan data awal untuk SQLite Local Simulation
 */
function init_sqlite_schema($conn) {
    $now = date('Y-m-d H:i:s');
    $today = date('Y-m-d');
    $plus2 = date('Y-m-d', strtotime('+2 days'));
    $plus3 = date('Y-m-d', strtotime('+3 days'));
    $plus5 = date('Y-m-d', strtotime('+5 days'));

    $conn->exec("
        CREATE TABLE IF NOT EXISTS accounts (
            id TEXT PRIMARY KEY,
            username TEXT UNIQUE,
            password TEXT,
            role TEXT DEFAULT 'Kasir'
        );
        CREATE TABLE IF NOT EXISTS villas (
            id TEXT PRIMARY KEY,
            name TEXT,
            price REAL DEFAULT 0,
            stock INTEGER DEFAULT 1
        );
        CREATE TABLE IF NOT EXISTS bookings (
            id TEXT PRIMARY KEY,
            customer_name TEXT,
            check_in TEXT,
            check_out TEXT,
            discount REAL DEFAULT 0,
            dp REAL DEFAULT 0,
            dp_payment_method TEXT DEFAULT 'None',
            lunas_payment_method TEXT DEFAULT 'None',
            total_price REAL DEFAULT 0,
            created_at TEXT
        );
        CREATE TABLE IF NOT EXISTS booking_items (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            booking_id TEXT,
            villa_id TEXT,
            qty INTEGER DEFAULT 1,
            price_paid REAL DEFAULT 0
        );
        CREATE TABLE IF NOT EXISTS booking_addons (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            booking_id TEXT,
            name TEXT,
            price REAL DEFAULT 0
        );
        CREATE TABLE IF NOT EXISTS settings (
            setting_key TEXT PRIMARY KEY,
            setting_value TEXT
        );

        INSERT OR IGNORE INTO accounts (id, username, password, role) VALUES
        ('u-admin', 'admin', 'admin123', 'Administrator'),
        ('u-kasir', 'kasir', 'kasir123', 'Kasir');

        INSERT OR IGNORE INTO villas (id, name, price, stock) VALUES
        ('v-lumbung', 'Villa Lumbung Tradisional', 750000.00, 4),
        ('v-glamping', 'Villa Glamping Deluxe', 950000.00, 3),
        ('v-suite', 'Family Suite Mountain View', 1500000.00, 2),
        ('v-camping', 'Tenda Camping VIP (Ground)', 350000.00, 8);

        INSERT OR IGNORE INTO settings (setting_key, setting_value) VALUES
        ('villaName', 'Bale Ody Villa & Camping Ground'),
        ('villaLogo', ''),
        ('villaFavicon', '');

        INSERT OR IGNORE INTO bookings (id, customer_name, check_in, check_out, discount, dp, dp_payment_method, lunas_payment_method, total_price, created_at) VALUES
        ('b-demo-01', 'Bpk. Hendra Gunawan', '$today', '$plus2', 50000.00, 1850000.00, 'Transfer BCA', 'Cash', 1850000.00, '$now'),
        ('b-demo-02', 'Ibu Maya Safitri', '$plus3', '$plus5', 0.00, 500000.00, 'QRIS', 'None', 1500000.00, '$now');

        INSERT OR IGNORE INTO booking_items (booking_id, villa_id, qty, price_paid) VALUES
        ('b-demo-01', 'v-glamping', 1, 950000.00),
        ('b-demo-02', 'v-lumbung', 1, 750000.00);

        INSERT OR IGNORE INTO booking_addons (booking_id, name, price) VALUES
        ('b-demo-01', 'Extra Bed', 100000.00),
        ('b-demo-01', 'Paket Api Unggun & Jagung Bakar', 150000.00);
    ");
}
