-- Hapus dan buat database
DROP DATABASE IF EXISTS apotek_db;
CREATE DATABASE apotek_db CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE apotek_db;

ALTER DATABASE apotek_db CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- Tabel pengguna untuk autentikasi
CREATE TABLE pengguna (
    id VARCHAR(36) NOT NULL PRIMARY KEY,
    username VARCHAR(50) NOT NULL UNIQUE,
    password VARCHAR(255) NOT NULL,
    nama VARCHAR(100) NOT NULL,
    role ENUM('admin', 'kasir') NOT NULL,
    email VARCHAR(100) NULL UNIQUE,
    telepon VARCHAR(15) NULL,
    foto_profile VARCHAR(255) NULL,
    is_aktif BOOLEAN NOT NULL DEFAULT true,
    last_login TIMESTAMP NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- Tabel kategori produk
CREATE TABLE kategori (
    id VARCHAR(36) PRIMARY KEY,
    nama VARCHAR(50) NOT NULL,
    deskripsi TEXT,
    is_aktif BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- Tabel produk
CREATE TABLE produk (
    id VARCHAR(36) PRIMARY KEY,
    kode VARCHAR(20) UNIQUE NOT NULL,
    barcode VARCHAR(50) UNIQUE,
    nama VARCHAR(100) NOT NULL,
    deskripsi TEXT,
    kategori_id VARCHAR(36),
    harga_beli DECIMAL(12,2) NOT NULL,
    harga_jual DECIMAL(12,2) NOT NULL,
    stok INT NOT NULL DEFAULT 0,
    min_stok INT DEFAULT 0,
    is_aktif BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (kategori_id) REFERENCES kategori(id)
);

-- Tabel transaksi
CREATE TABLE transaksi (
    id VARCHAR(36) PRIMARY KEY,
    no_transaksi VARCHAR(20) UNIQUE NOT NULL,
    tanggal TIMESTAMP NOT NULL,
    total DECIMAL(12,2) NOT NULL,
    bayar DECIMAL(12,2) NOT NULL,
    kembalian DECIMAL(12,2) NOT NULL,
    kasir_id VARCHAR(36),
    status ENUM('pending', 'completed', 'cancelled') DEFAULT 'pending',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (kasir_id) REFERENCES pengguna(id)
);

-- Tabel detail transaksi
CREATE TABLE detail_transaksi (
    id VARCHAR(36) PRIMARY KEY,
    transaksi_id VARCHAR(36),
    produk_id VARCHAR(36),
    jumlah INT NOT NULL,
    harga DECIMAL(12,2) NOT NULL,
    diskon DECIMAL(12,2) DEFAULT 0,
    subtotal DECIMAL(12,2) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (transaksi_id) REFERENCES transaksi(id),
    FOREIGN KEY (produk_id) REFERENCES produk(id)
);

-- Tabel log stok untuk tracking perubahan stok
CREATE TABLE log_stok (
    id VARCHAR(36) PRIMARY KEY,
    produk_id VARCHAR(36),
    jenis_perubahan ENUM('penjualan', 'pembelian', 'opname', 'retur', 'penyesuaian') NOT NULL,
    jumlah INT NOT NULL,
    stok_sebelum INT NOT NULL,
    stok_sesudah INT NOT NULL,
    keterangan TEXT,
    petugas_id VARCHAR(36),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (produk_id) REFERENCES produk(id),
    FOREIGN KEY (petugas_id) REFERENCES pengguna(id)
);

-- Tabel laporan keuangan
CREATE TABLE laporan_keuangan (
    id VARCHAR(36) PRIMARY KEY,
    tanggal DATE NOT NULL,
    jenis ENUM('pemasukan', 'pengeluaran') NOT NULL,
    kategori VARCHAR(50) NOT NULL,
    jumlah DECIMAL(12,2) NOT NULL,
    keterangan TEXT,
    bukti_transaksi VARCHAR(255),
    created_by VARCHAR(36),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (created_by) REFERENCES pengguna(id)
);

-- Insert data default
INSERT INTO pengguna (id, username, password, nama, role, email) VALUES
('1', 'admin', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'Administrator', 'admin', 'admin@apotek.com'),
('2', 'kasir1', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'Kasir 1', 'kasir', 'kasir1@apotek.com');

INSERT INTO kategori (id, nama, deskripsi) VALUES
('1', 'Obat Bebas', 'Obat yang dapat dibeli tanpa resep dokter'),
('2', 'Obat Bebas Terbatas', 'Obat yang dapat dibeli dengan pengawasan farmasis'),
('3', 'Obat Keras', 'Obat yang hanya dapat dibeli dengan resep dokter'),
('4', 'Alat Kesehatan', 'Peralatan medis dan kesehatan');

-- Trigger untuk update stok otomatis
DELIMITER //
CREATE TRIGGER after_detail_transaksi_insert
AFTER INSERT ON detail_transaksi
FOR EACH ROW
BEGIN
    -- Update stok produk
    UPDATE produk 
    SET stok = stok - NEW.jumlah
    WHERE id = NEW.produk_id;
    
    -- Catat log perubahan stok
    INSERT INTO log_stok (
        id, produk_id, jenis_perubahan,
        jumlah, stok_sebelum, stok_sesudah,
        keterangan, petugas_id
    )
    SELECT 
        UUID(), NEW.produk_id, 'penjualan',
        NEW.jumlah, p.stok + NEW.jumlah, p.stok,
        CONCAT('Penjualan: ', NEW.transaksi_id),
        t.kasir_id
    FROM produk p
    JOIN transaksi t ON t.id = NEW.transaksi_id
    WHERE p.id = NEW.produk_id;
END//

-- Trigger untuk mengembalikan stok saat transaksi dibatalkan
CREATE TRIGGER after_transaksi_cancelled
AFTER UPDATE ON transaksi
FOR EACH ROW 
BEGIN
    IF NEW.status = 'cancelled' AND OLD.status != 'cancelled' THEN
        UPDATE produk p
        INNER JOIN detail_transaksi dt ON dt.produk_id = p.id
        SET p.stok = p.stok + dt.jumlah
        WHERE dt.transaksi_id = NEW.id;
        
        -- Catat log pengembalian stok
        INSERT INTO log_stok (
            id, produk_id, jenis_perubahan,
            jumlah, stok_sebelum, stok_sesudah,
            keterangan, petugas_id
        )
        SELECT 
            UUID(), dt.produk_id, 'penyesuaian',
            dt.jumlah, p.stok - dt.jumlah, p.stok,
            CONCAT('Pembatalan transaksi: ', NEW.id),
            NEW.kasir_id
        FROM detail_transaksi dt
        JOIN produk p ON p.id = dt.produk_id
        WHERE dt.transaksi_id = NEW.id;
    END IF;
END//

DELIMITER ; 