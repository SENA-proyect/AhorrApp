CREATE DATABASE IF NOT EXISTS `SEproyectoNA`;    
USE `SEproyectoNA`;


CREATE USER IF NOT EXISTS 'AhorrApp'@'localhost' IDENTIFIED BY 'password';
GRANT ALL PRIVILEGES ON `SEproyectoNA`.* TO 'AhorrApp'@'localhost';
-- FLUSH PRIVILEGES;




-- ------------------------------------------------------------------------------------
-- TRABAJO FINAL – BASE DE DATOS AHORRAPP 25/11/2025
-- ------------------------------------------------------------------------------------


CREATE TABLE IF NOT EXISTS USUARIOS (
    ID_usuario  INT AUTO_INCREMENT PRIMARY KEY COMMENT 'Identificador único del usuario',
    Nombre VARCHAR(100) NOT NULL COMMENT 'Nombre del usuario',
    Apellido VARCHAR(100) COMMENT 'Apellido del usuario',
    Rol ENUM('Administrador','Usuario') NOT NULL COMMENT 'Rol del usuario dentro del sistema',
    Password_hash VARCHAR(255) NOT NULL COMMENT 'Hash de la contraseña del usuario',
    Email VARCHAR(150) UNIQUE NOT NULL COMMENT 'Correo electrónico del usuario'
);


-- =======================
--     TABLA: categorias
-- =======================


CREATE TABLE CATEGORIAS (
    ID_categoria INT AUTO_INCREMENT PRIMARY KEY COMMENT 'Identificador único de la categoría',
    Nombre VARCHAR(50) NOT NULL COMMENT 'Nombre de la categoría financiera',
    Color CHAR(7) COMMENT 'Color representativo de la categoría (formato HEX)',
    Icono VARCHAR(255) COMMENT 'Ruta o URL del icono de la categoría'


);


-- --------------------------
-- Módulos financieros y movimientos
-- --------------------------


CREATE TABLE MODULOS_FINANCIEROS (
    ID_modulo INT PRIMARY KEY AUTO_INCREMENT COMMENT 'Identificador único del módulo financiero',
    Nombre VARCHAR(100) NOT NULL COMMENT 'Nombre del módulo financiero',
    ID_usuario INT NOT NULL COMMENT 'Usuario propietario del módulo financiero',
    FOREIGN KEY (ID_usuario) REFERENCES USUARIOS(ID_usuario)
);




CREATE TABLE MOVIMIENTOS (
    ID_movimiento INT AUTO_INCREMENT PRIMARY KEY COMMENT 'Identificador único del movimiento financiero',
    ID_modulo INT NOT NULL COMMENT 'Módulo financiero al que pertenece el movimiento',
    Tipo ENUM('Entrada','Salida') NOT NULL COMMENT 'Tipo de movimiento: entrada o salida',
    FOREIGN KEY (ID_modulo) REFERENCES MODULOS_FINANCIEROS(ID_modulo)
);


-- ==============================================
--     ENTRADA: Ahorros/Ingresos
-- ==============================================


CREATE TABLE ENTRADA (
    ID_entrada INT AUTO_INCREMENT PRIMARY KEY COMMENT 'Identificador único de la entrada',
    ID_movimiento INT NOT NULL COMMENT 'Movimiento asociado a la entrada',
    FOREIGN KEY (ID_movimiento) REFERENCES MOVIMIENTOS(ID_movimiento)
);




CREATE TABLE AHORROS (
    ID_ahorros INT AUTO_INCREMENT PRIMARY KEY COMMENT 'Identificador único del ahorro',
    ID_entrada INT NOT NULL COMMENT 'Tabla de entrada financiera asociada al ahorro',
    ID_categoria INT NOT NULL COMMENT 'Categoría asociada al ahorro',
    Monto DECIMAL(15,2) NOT NULL CHECK (Monto >= 0) COMMENT 'Monto del ahorro',
    Descripcion VARCHAR(255) COMMENT 'Descripción del ahorro',
    Meta VARCHAR(100) COMMENT 'Meta u objetivo del ahorro',
    Fecha_registro DATE COMMENT 'Fecha de registro del ahorro',
    Fecha_meta DATE COMMENT 'Fecha objetivo para cumplir la meta',
    FOREIGN KEY (ID_entrada) REFERENCES ENTRADA(ID_entrada),
    FOREIGN KEY (ID_categoria) REFERENCES CATEGORIAS(ID_categoria)
);




CREATE TABLE INGRESOS (
    ID_ingresos INT AUTO_INCREMENT PRIMARY KEY COMMENT 'Identificador único del ingreso',
    ID_entrada INT NOT NULL COMMENT 'Tabla de entrada financiera asociada al ingreso',
    ID_categoria INT NOT NULL COMMENT 'Categoría asociada al ingreso',
    Monto DECIMAL(15,2) NOT NULL CHECK (Monto >= 0) COMMENT 'Monto del ingreso',
    Descripcion VARCHAR(255) COMMENT 'Descripción del ingreso',
    Fuente VARCHAR(150) COMMENT 'Fuente del ingreso',
    Fecha_registro DATE COMMENT 'Fecha de registro del ingreso',
    FOREIGN KEY (ID_entrada) REFERENCES ENTRADA(ID_entrada),
    FOREIGN KEY (ID_categoria) REFERENCES CATEGORIAS(ID_categoria)
);


-- ==============================================
--    SALIDA: Gastos/Imprevistos/Deudas
-- ==============================================


CREATE TABLE SALIDA (
    ID_salida INT AUTO_INCREMENT PRIMARY KEY COMMENT 'Identificador único de la salida',
    ID_movimiento INT NOT NULL COMMENT 'Movimiento asociado a la tabla de salida',
    FOREIGN KEY (ID_movimiento) REFERENCES MOVIMIENTOS(ID_movimiento)
);




CREATE TABLE GASTOS (
    ID_gastos INT AUTO_INCREMENT PRIMARY KEY COMMENT 'Identificador único del gasto',
    ID_salida INT NOT NULL COMMENT 'Salida financiera asociada al gasto',
    ID_categoria INT NOT NULL COMMENT 'Categoría asociada al gasto',
    Monto DECIMAL(15,2) NOT NULL CHECK (Monto >= 0) COMMENT 'Monto del gasto',
    Descripcion VARCHAR(255) COMMENT 'Descripción del gasto',
    Fecha_registro DATE COMMENT 'Fecha de registro del gasto',
    FOREIGN KEY (ID_salida) REFERENCES SALIDA(ID_salida),
    FOREIGN KEY (ID_categoria) REFERENCES CATEGORIAS(ID_categoria)
);




CREATE TABLE IMPREVISTOS (
    ID_imprevistos INT AUTO_INCREMENT PRIMARY KEY COMMENT 'Identificador único del imprevisto',
    ID_salida INT NOT NULL COMMENT 'Tabla de salida financiera asociada al imprevisto',
    ID_categoria INT NOT NULL COMMENT 'Categoría asociada al imprevisto',
    Monto DECIMAL(15,2) NOT NULL CHECK (Monto >= 0) COMMENT 'Monto del imprevisto',
    Causa VARCHAR(255) COMMENT 'Causa del gasto imprevisto',
    Fecha_registro DATE COMMENT 'Fecha de registro del imprevisto',
    FOREIGN KEY (ID_salida) REFERENCES SALIDA(ID_salida),
    FOREIGN KEY (ID_categoria) REFERENCES CATEGORIAS(ID_categoria)
);




CREATE TABLE DEUDAS (
    ID_deudas INT AUTO_INCREMENT PRIMARY KEY COMMENT 'Identificador único de la deuda',
    ID_salida INT NOT NULL COMMENT 'Tabla de salida financiera asociada a la deuda',
    ID_categoria INT NOT NULL COMMENT 'Categoría asociada a la deuda',
    Monto DECIMAL(15,2) NOT NULL CHECK (Monto >= 0) COMMENT 'Monto de la deuda',
    Fuente VARCHAR(150) NOT NULL COMMENT 'Fuente de la deuda',
    Descripcion VARCHAR(255) COMMENT 'Descripción de la deuda',
    Fecha_inicio DATE COMMENT 'Fecha de inicio de la deuda',
    Fecha_fin DATE COMMENT 'Fecha de finalización de la deuda',
    Estado ENUM('pendiente', 'pagada') COMMENT 'Estado actual de la deuda',
    FOREIGN KEY (ID_salida) REFERENCES SALIDA(ID_salida),
    FOREIGN KEY (ID_categoria) REFERENCES CATEGORIAS(ID_categoria)
);


-- =======================
--     TABLA: dependientes
-- =======================


CREATE TABLE DEPENDIENTES (
    ID_dependientes  INT AUTO_INCREMENT PRIMARY KEY COMMENT 'Identificador único del dependiente',
    Nombre VARCHAR(100) NOT NULL COMMENT 'Nombre del dependiente',
    Ocupacion VARCHAR(150) COMMENT 'Ocupación del dependiente',
    Edad INT COMMENT 'Edad del dependiente',
    Relacion VARCHAR(100) COMMENT 'Relación con el usuario',
    ID_usuario INT NOT NULL COMMENT 'Usuario al que pertenece el dependiente',
    FOREIGN KEY (ID_usuario) REFERENCES USUARIOS(ID_usuario)
);


-- =======================
--     TABLA: historial
-- =======================


CREATE TABLE historial (
    ID_historial INT AUTO_INCREMENT PRIMARY KEY COMMENT 'Identificador único del historial',
    ID_usuario INT NOT NULL COMMENT 'Usuario que realizó la acción',
    accion VARCHAR(200) NOT NULL COMMENT 'Acción realizada por el usuario',
    detalles TEXT COMMENT 'Detalles adicionales de la acción',
    fecha TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT 'Fecha y hora del registro',
    FOREIGN KEY (ID_usuario) REFERENCES USUARIOS(ID_usuario)
        ON DELETE CASCADE
);


-- =======================
--     TABLA: notificaciones
-- =======================


CREATE TABLE NOTIFICACIONES (
    ID_notificacion INT AUTO_INCREMENT PRIMARY KEY COMMENT 'Identificador único de la notificación',
    ID_usuario INT NOT NULL COMMENT 'Usuario destinatario de la notificación',
    ID_historial INT NOT NULL COMMENT 'Historial relacionado con la notificación',
    Tipo ENUM('sistema','recordatorio','sugerencia') NOT NULL COMMENT 'Tipo de notificación',
    Mensaje TEXT NOT NULL COMMENT 'Contenido de la notificación',
    Fecha TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT 'Fecha de creación de la notificación',
    Leida BOOLEAN DEFAULT FALSE COMMENT 'Indica si la notificación fue leída',
    Estado BOOLEAN DEFAULT TRUE COMMENT 'Estado activo o inactivo de la notificación',
    FOREIGN KEY (ID_usuario) REFERENCES USUARIOS(ID_usuario)
        ON DELETE CASCADE,
    FOREIGN KEY (ID_historial) REFERENCES HISTORIAL(ID_historial)
        ON DELETE CASCADE
);



