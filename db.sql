CREATE DATABASE IF NOT EXISTS `proyecto`;    
USE `proyecto`;

CREATE USER IF NOT EXISTS 'AhorrApp'@'localhost' IDENTIFIED BY 'password';
GRANT ALL PRIVILEGES ON `proyecto`.* TO 'AhorrApp'@'localhost';
-- FLUSH PRIVILEGES;


-- =======================
--     TABLA: categorias

CREATE TABLE TIPOS_CATEGORIA (
    ID_tipo INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(50) NOT NULL UNIQUE,
    descripcion TEXT
);

CREATE TABLE CATEGORIAS (
    ID_categorias INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(50) NOT NULL,
    descripcion TEXT,
    etiqueta ENUM('salida','entrada') NOT NULL,  
    ID_tipo INT NULL,                             
    color CHAR(7),
    icono VARCHAR(255),
    origen ENUM('base','personalizada') NOT NULL DEFAULT 'base', 
    FOREIGN KEY (ID_tipo) REFERENCES TIPOS_CATEGORIA(ID_tipo)
);

-- ------------------------------------------------------------------------------------
-- TRABAJO FINAL – BASE DE DATOS AHORRAPP 25/11/2025
-- ------------------------------------------------------------------------------------
-- /////////////////////////////////////////////////////////////////////////////

CREATE TABLE USUARIOS (
    ID_usuario  INT AUTO_INCREMENT PRIMARY KEY,
    Nombre VARCHAR(100) NOT NULL,
    Apellido VARCHAR(100) NOT NULL,
    Rol VARCHAR(50) NOT NULL,
    Contraseña VARCHAR(255) NOT NULL,
    Email VARCHAR(150) UNIQUE NOT NULL
);

CREATE TABLE DEPENDIENTES (
    ID_dependientes  INT AUTO_INCREMENT PRIMARY KEY,
    Nombre VARCHAR(100) NOT NULL,
    Ocupacion VARCHAR(150),
    Edad INT,
    Relacion VARCHAR(100),
    ID_usuario INT NOT NULL,
    FOREIGN KEY (ID_usuario) REFERENCES USUARIOS(ID_usuario)
);

-- /////////////////////////////////////////////////////////////////////////////
-- --------------------------
-- Módulos y Submódulos
-- --------------------------

CREATE TABLE Modulos_financieros (
    ID_modulo INT PRIMARY KEY,
    Nombre VARCHAR(100) NOT NULL,
    ID_usuario INT NOT NULL,
    FOREIGN KEY (ID_usuario) REFERENCES USUARIOS(ID_usuario)
);

CREATE TABLE MOVIMIENTOS (
    ID_movimiento INT PRIMARY KEY,
    Nombre VARCHAR(100) NOT NULL,
    ID_modulo INT NOT NULL,
    FOREIGN KEY (ID_modulo) REFERENCES Modulos_financieros(ID_modulo)
);

-- --------------------------
-- Transacciones de Ingresos/Ahorros
-- --------------------------

CREATE TABLE AHORROS (
    ID_ahorros INT PRIMARY KEY,
    ID_categorias INT NOT NULL,
    descripcion VARCHAR(255),
    monto DECIMAL(15,2) NOT NULL,
    meta VARCHAR(100),
    fecha_registro DATE,
    fecha_meta DATE,
    FOREIGN KEY (ID_categorias) REFERENCES CATEGORIAS(ID_categorias)
);


CREATE TABLE INGRESOS (
    ID_ingresos INT PRIMARY KEY,
    ID_categorias INT NOT NULL,
    descripcion VARCHAR(255),
    monto DECIMAL(15,2) NOT NULL,
    fuente VARCHAR(150),
    fecha_registro DATE,
    FOREIGN KEY (ID_categorias) REFERENCES CATEGORIAS(ID_categorias)
);

CREATE TABLE ENTRADA (
    ID_entrada INT PRIMARY KEY,
    ID_ahorro INT NOT NULL,
    ID_ingresos INT NOT NULL,
    ID_movimiento INT NOT NULL,
    FOREIGN KEY (ID_ahorro) REFERENCES AHORROS(ID_ahorros),
    FOREIGN KEY (ID_ingresos) REFERENCES INGRESOS(ID_ingresos),
    FOREIGN KEY (ID_movimiento) REFERENCES MOVIMIENTOS(ID_movimiento)
);

-- --------------------------
-- Transacciones de Gastos/Imprevistos
-- --------------------------

CREATE TABLE GASTOS (
    ID_gastos INT PRIMARY KEY,
    ID_categorias INT NOT NULL,
    descripcion VARCHAR(255),
    monto DECIMAL(15,2) NOT NULL,
    fecha_registro DATE,
    FOREIGN KEY (ID_categorias) REFERENCES CATEGORIAS(ID_categorias)
);


CREATE TABLE IMPREVISTOS (
    ID_imprevistos INT PRIMARY KEY,
    ID_categorias INT NOT NULL,
    causa VARCHAR(255),
    monto DECIMAL(15,2) NOT NULL,
    fecha_registro DATE,
    FOREIGN KEY (ID_categorias) REFERENCES CATEGORIAS(ID_categorias)
);

-- --------------------------
-- Deudas
-- --------------------------

CREATE TABLE DEUDAS (
    ID_deudas INT PRIMARY KEY,
    ID_categorias INT NOT NULL,
    fuente VARCHAR(150) NOT NULL,
    descripcion VARCHAR(255),
    monto DECIMAL(15,2) NOT NULL,
    fecha_inicio DATE,
    fecha_fin DATE,
    estado VARCHAR(50),
    FOREIGN KEY (ID_categorias) REFERENCES CATEGORIAS(ID_categorias)
);


-- --------------------------
-- Salida
-- --------------------------

CREATE TABLE SALIDA (
    ID_salida INT PRIMARY KEY,
    ID_gastos INT NOT NULL,
    ID_imprevistos INT NOT NULL,
    ID_deudas INT NOT NULL,
    ID_movimiento INT NOT NULL,
    FOREIGN KEY (ID_gastos) REFERENCES GASTOS(ID_gastos),
    FOREIGN KEY (ID_imprevistos) REFERENCES IMPREVISTOS(ID_imprevistos),
    FOREIGN KEY (ID_deudas) REFERENCES DEUDAS(ID_deudas),
    FOREIGN KEY (ID_movimiento) REFERENCES MOVIMIENTOS(ID_movimiento)
);

-- ///////////////////////////////////////////////////////////////////////
-- =======================
--     TABLA: historial
-- =======================


CREATE TABLE historial (
    id INT AUTO_INCREMENT PRIMARY KEY,
    ID_usuario INT NOT NULL,
    accion VARCHAR(200) NOT NULL,    
    detalles TEXT,               
    fecha TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    FOREIGN KEY (ID_usuario) REFERENCES USUARIOS(ID_usuario)
        ON DELETE CASCADE
);


-- =======================
--     TABLA: notificaciones
-- =======================
CREATE TABLE notificaciones (
    id INT AUTO_INCREMENT PRIMARY KEY,
    usuario_id INT NOT NULL,
    historial_id INT NOT NULL,        
    tipo ENUM('sistema','recordatorio','sugerencia') NOT NULL,
    mensaje TEXT NOT NULL,
    fecha TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    leida BOOLEAN DEFAULT FALSE,
    estado BOOLEAN DEFAULT TRUE,

    FOREIGN KEY (historial_id) REFERENCES historial(id)
        ON DELETE CASCADE
);