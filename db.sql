CREATE DATABASE IF NOT EXISTS `proyecto`;    
USE `proyecto`;

CREATE USER IF NOT EXISTS 'AhorrApp'@'localhost' IDENTIFIED BY 'password';
GRANT ALL PRIVILEGES ON `proyecto`.* TO 'AhorrApp'@'localhost';
-- FLUSH PRIVILEGES;


-- ------------------------------------------------------------------------------------
-- TRABAJO FINAL – BASE DE DATOS AHORRAPP 25/11/2025
-- ------------------------------------------------------------------------------------

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



-- =======================
--     TABLA: historial
-- =======================


CREATE TABLE historial (
    ID_historial INT AUTO_INCREMENT PRIMARY KEY,
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
CREATE TABLE NOTIFICACIONES (
    ID_notificacion INT AUTO_INCREMENT PRIMARY KEY,   
    ID_usuario INT NOT NULL,                          
    ID_historial INT NOT NULL,                     
    Tipo ENUM('sistema','recordatorio','sugerencia') NOT NULL, 
    Mensaje TEXT NOT NULL,                          
    Fecha TIMESTAMP DEFAULT CURRENT_TIMESTAMP,       
    Leida BOOLEAN DEFAULT FALSE,                    
    Estado BOOLEAN DEFAULT TRUE,                    

    FOREIGN KEY (ID_usuario) REFERENCES USUARIOS(ID_usuario)
        ON DELETE CASCADE,
    FOREIGN KEY (ID_historial) REFERENCES HISTORIAL(ID_historial)
        ON DELETE CASCADE
);

-- /////////////////////////////////////////////////////////////////////////////
-- --------------------------
-- Módulos financieros y movimientos
-- --------------------------

CREATE TABLE Modulos_financieros (
    ID_modulo INT PRIMARY KEY,
    Nombre VARCHAR(100) NOT NULL,
    ID_usuario INT NOT NULL,
    FOREIGN KEY (ID_usuario) REFERENCES USUARIOS(ID_usuario)
);

CREATE TABLE MOVIMIENTOS (
    ID_movimiento INT AUTO_INCREMENT PRIMARY KEY,
    ID_modulo INT NOT NULL,
    Tipo ENUM('Entrada','Salida') NOT NULL,
    FOREIGN KEY (ID_modulo) REFERENCES MODULOS_FINANCIEROS(ID_modulo)
);


-- ==============================================
--     ENTRADA: Ahorros/Ingresos
-- ==============================================

CREATE TABLE ENTRADA (
    ID_entrada INT AUTO_INCREMENT PRIMARY KEY,
    ID_movimiento INT NOT NULL,
    FOREIGN KEY (ID_movimiento) REFERENCES MOVIMIENTOS(ID_movimiento)
);

-- --------------------------------------------------------------------------
CREATE TABLE AHORROS (
    ID_ahorros INT AUTO_INCREMENT PRIMARY KEY,
    ID_entrada INT NOT NULL,
    ID_categoria INT NOT NULL,
    Monto DECIMAL(15,2) NOT NULL,
    Descripcion VARCHAR(255),
    Meta VARCHAR(100),
    Fecha_registro DATE,
    Fecha_meta DATE,
    FOREIGN KEY (ID_entrada) REFERENCES ENTRADA(ID_entrada),
    FOREIGN KEY (ID_categoria) REFERENCES CATEGORIAS(ID_categoria)
);

CREATE TABLE INGRESOS (
    ID_ingresos INT AUTO_INCREMENT PRIMARY KEY,
    ID_entrada INT NOT NULL,
    ID_categoria INT NOT NULL,
    Monto DECIMAL(15,2) NOT NULL,
    Descripcion VARCHAR(255),
    Fuente VARCHAR(150),
    Fecha_registro DATE,
    FOREIGN KEY (ID_entrada) REFERENCES ENTRADA(ID_entrada),
    FOREIGN KEY (ID_categoria) REFERENCES CATEGORIAS(ID_categoria)
);

-- ==============================================
--    SALIDA: Gastos/Imprevistos/Deudas
-- ==============================================
CREATE TABLE SALIDA (
    ID_salida INT AUTO_INCREMENT PRIMARY KEY,
    ID_movimiento INT NOT NULL,
    FOREIGN KEY (ID_movimiento) REFERENCES MOVIMIENTOS(ID_movimiento)
);

-- --------------------------------------------------------------------------------
CREATE TABLE GASTOS (
    ID_gastos INT AUTO_INCREMENT PRIMARY KEY,
    ID_salida INT NOT NULL,
    ID_categoria INT NOT NULL,
    Monto DECIMAL(15,2) NOT NULL,
    Descripcion VARCHAR(255),
    Fecha_registro DATE,
    FOREIGN KEY (ID_salida) REFERENCES SALIDA(ID_salida),
    FOREIGN KEY (ID_categoria) REFERENCES CATEGORIAS(ID_categoria)
);

CREATE TABLE IMPREVISTOS (
    ID_imprevistos INT AUTO_INCREMENT PRIMARY KEY,
    ID_salida INT NOT NULL,
    ID_categoria INT NOT NULL,
    Monto DECIMAL(15,2) NOT NULL,
    Causa VARCHAR(255),
    Fecha_registro DATE,
    FOREIGN KEY (ID_salida) REFERENCES SALIDA(ID_salida),
    FOREIGN KEY (ID_categoria) REFERENCES CATEGORIAS(ID_categoria)
);

CREATE TABLE DEUDAS (
    ID_deudas INT AUTO_INCREMENT PRIMARY KEY,
    ID_salida INT NOT NULL,
    ID_categoria INT NOT NULL,
    Monto DECIMAL(15,2) NOT NULL,
    Fuente VARCHAR(150) NOT NULL,
    Descripcion VARCHAR(255),
    Fecha_inicio DATE,
    Fecha_fin DATE,
    Estado VARCHAR(50),
    FOREIGN KEY (ID_salida) REFERENCES SALIDA(ID_salida),
    FOREIGN KEY (ID_categoria) REFERENCES CATEGORIAS(ID_categoria)
);

-- =======================
--     TABLA: categorias
-- =======================

CREATE TABLE CATEGORIAS (
    ID_categoria INT AUTO_INCREMENT PRIMARY KEY,  
    Nombre VARCHAR(50) NOT NULL,                  
    Color CHAR(7),                                
    Icono VARCHAR(255)                           
);