const mysql = require('mysql2/promise');
require('dotenv').config();

// MySQL bağlantı havuzu
const pool = mysql.createPool({
  host: process.env.DB_HOST,
  user: process.env.DB_USER,
  password: process.env.DB_PASSWORD,
  database: process.env.DB_NAME,
  port: parseInt(process.env.DB_PORT) || 3306,
  waitForConnections: true,
  connectionLimit: 10,
  queueLimit: 0
});

// Migrate: tabloları oluştur
async function migrate() {
  const conn = await pool.getConnection();
  try {
    await conn.query(`
      CREATE TABLE IF NOT EXISTS institutions (
        id               INT AUTO_INCREMENT PRIMARY KEY,
        name             VARCHAR(255) NOT NULL,
        institution_code VARCHAR(50)  NOT NULL UNIQUE,
        password         VARCHAR(255) DEFAULT NULL,
        email            VARCHAR(255) DEFAULT NULL,
        responsible_name VARCHAR(255) NOT NULL,
        phone            VARCHAR(50)  NOT NULL,
        ulke_adi         VARCHAR(100) DEFAULT NULL,
        il_adi           VARCHAR(100) DEFAULT NULL,
        il_kodu          VARCHAR(20)  DEFAULT NULL,
        ilce_adi         VARCHAR(100) DEFAULT NULL,
        ilce_kodu        VARCHAR(20)  DEFAULT NULL,
        tip              VARCHAR(50)  DEFAULT NULL,
        website          VARCHAR(500) DEFAULT NULL,
        email_link       VARCHAR(500) DEFAULT NULL,
        is_verified      TINYINT(1)  DEFAULT 0,
        created_at       TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      )
    `);


    await conn.query(`
      CREATE TABLE IF NOT EXISTS users (
        id                   INT AUTO_INCREMENT PRIMARY KEY,
        email                VARCHAR(255) NOT NULL UNIQUE,
        phone                VARCHAR(50)  NOT NULL UNIQUE,
        institution_id       INT          NOT NULL,
        subject              VARCHAR(255),
        password             VARCHAR(255) NOT NULL,
        has_unlock_permission TINYINT(1)  DEFAULT 0,
        created_at           TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (institution_id) REFERENCES institutions(id)
      )
    `);
    console.log('[DB] Tablolar hazır.');
  } finally {
    conn.release();
  }
}

// Bağlantıyı test et
async function checkConnection() {
  const conn = await pool.getConnection();
  conn.release();
  console.log('[DB] Bağlantı başarılı.');
}

module.exports = { pool, migrate, checkConnection };
