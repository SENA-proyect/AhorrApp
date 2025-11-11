CREATE DATABASE IF NOT EXISTS `proyecto`;    
USE `proyecto`;

CREATE USER IF NOT EXISTS 'AhorrApp'@'localhost' IDENTIFIED BY 'password';
GRANT ALL PRIVILEGES ON `proyecto`.* TO 'AhorrApp'@'localhost';
FLUSH PRIVILEGES;

-- CREATE TABLE IF NOT EXISTS usuarios (
--     id INT AUTO_INCREMENT PRIMARY KEY,
--     nombre VARCHAR(255) NOT NULL,
--     email VARCHAR(255) NOT NULL UNIQUE,
--     contrasena VARCHAR(200) NOT NULL
-- );

CREATE TABLE IF NOT EXISTS usuarios (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(255) NOT NULL,
    email VARCHAR(255) NOT NULL UNIQUE,
    contrasena VARCHAR(200) NOT NULL,
    rol ENUM('usuario', 'admin') DEFAULT 'usuario',
    dependientes BOOLEAN DEFAULT FALSE,
    fecha_creacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);


CREATE TABLE IF NOT EXISTS dependientes (
    id INT AUTO_INCREMENT PRIMARY KEY,
    usuario_id INT NOT NULL,
    nombre VARCHAR(255) NOT NULL,
    edad INT NOT NULL,
    relacion VARCHAR(100),
    ocupacion VARCHAR(255),
    FOREIGN KEY (usuario_id) REFERENCES usuarios(id) ON DELETE CASCADE
);


CREATE TABLE IF NOT EXISTS ingresos (
    id INT AUTO_INCREMENT PRIMARY KEY,
    usuario_id INT NOT NULL,
    fuente VARCHAR(255) NOT NULL,
    monto DECIMAL(12,2) NOT NULL,
    fecha DATE NOT NULL,
    FOREIGN KEY (usuario_id) REFERENCES usuarios(id) ON DELETE CASCADE
);


CREATE TABLE IF NOT EXISTS ahorros (
    id INT AUTO_INCREMENT PRIMARY KEY,
    usuario_id INT NOT NULL,
    ingreso_id INT,
    categoria VARCHAR(255) NOT NULL,
    monto DECIMAL(12,2) NOT NULL,
    fecha TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (usuario_id) REFERENCES usuarios(id) ON DELETE CASCADE,
    FOREIGN KEY (ingreso_id) REFERENCES ingresos(id) ON DELETE SET NULL
);


CREATE TABLE IF NOT EXISTS gastos (
    id INT AUTO_INCREMENT PRIMARY KEY,
    usuario_id INT NOT NULL,
    ingreso_id INT,
    categoria VARCHAR(255) NOT NULL,
    monto DECIMAL(12,2) NOT NULL,
    descripcion TEXT,
    fecha TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (usuario_id) REFERENCES usuarios(id) ON DELETE CASCADE,
    FOREIGN KEY (ingreso_id) REFERENCES ingresos(id) ON DELETE SET NULL
);


CREATE TABLE IF NOT EXISTS imprevistos (
    id INT AUTO_INCREMENT PRIMARY KEY,
    usuario_id INT NOT NULL,
    ingreso_id INT,
    categoria VARCHAR(255) NOT NULL,
    monto DECIMAL(12,2) NOT NULL,
    descripcion TEXT,
    fecha TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (usuario_id) REFERENCES usuarios(id) ON DELETE CASCADE,
    FOREIGN KEY (ingreso_id) REFERENCES ingresos(id) ON DELETE SET NULL
);


CREATE TABLE IF NOT EXISTS deudas (
    id INT AUTO_INCREMENT PRIMARY KEY,
    usuario_id INT NOT NULL,
    ingreso_id INT,
    acreedor VARCHAR(255) NOT NULL,
    monto DECIMAL(12,2) NOT NULL,
    estado ENUM('pendiente', 'pagada', 'en curso') DEFAULT 'pendiente',
    fecha TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (usuario_id) REFERENCES usuarios(id) ON DELETE CASCADE,
    FOREIGN KEY (ingreso_id) REFERENCES ingresos(id) ON DELETE SET NULL
);


CREATE TABLE IF NOT EXISTS modulos_personalizados (
    id INT AUTO_INCREMENT PRIMARY KEY,
    usuario_id INT NOT NULL,
    ingreso_id INT,
    nombre VARCHAR(255) NOT NULL,
    tema_sugerido VARCHAR(255),
    descripcion TEXT,
    riesgo ENUM('alto', 'medio', 'bajo') DEFAULT 'medio',
    fecha_creacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (usuario_id) REFERENCES usuarios(id) ON DELETE CASCADE,
    FOREIGN KEY (ingreso_id) REFERENCES ingresos(id) ON DELETE SET NULL
);


CREATE TABLE IF NOT EXISTS modulos_usuarios (
    id INT AUTO_INCREMENT PRIMARY KEY,
    usuario_id INT NOT NULL,
    nombre_modulo VARCHAR(100) NOT NULL,
    estado ENUM('activo', 'inactivo') DEFAULT 'activo',
    porcentaje_asignado DECIMAL(5,2) DEFAULT 0.00,
    fecha_configuracion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (usuario_id) REFERENCES usuarios(id) ON DELETE CASCADE
);


CREATE TABLE IF NOT EXISTS movimientos_modulos (
    id INT AUTO_INCREMENT PRIMARY KEY,
    usuario_id INT NOT NULL,
    modulo VARCHAR(100) NOT NULL,
    tipo ENUM('entrada', 'salida') NOT NULL,
    monto DECIMAL(12,2) NOT NULL,
    descripcion TEXT,
    fecha TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (usuario_id) REFERENCES usuarios(id) ON DELETE CASCADE
);


CREATE TABLE IF NOT EXISTS historial_acciones (
    id INT AUTO_INCREMENT PRIMARY KEY,
    usuario_id INT NOT NULL,
    accion VARCHAR(255) NOT NULL,
    descripcion TEXT,
    fecha TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (usuario_id) REFERENCES usuarios(id) ON DELETE CASCADE
);


CREATE TABLE IF NOT EXISTS notificaciones (
    id INT AUTO_INCREMENT PRIMARY KEY,
    usuario_id INT NOT NULL,
    historial_id INT DEFAULT NULL,
    tipo ENUM('sugerencia', 'alerta', 'recuperacion', 'otra') DEFAULT 'otra',
    mensaje TEXT NOT NULL,
    estado ENUM('enviada', 'pendiente', 'leida') DEFAULT 'pendiente',
    fecha_envio TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (usuario_id) REFERENCES usuarios(id) ON DELETE CASCADE,
    FOREIGN KEY (historial_id) REFERENCES historial_acciones(id) ON DELETE SET NULL
);

CREATE TABLE IF NOT EXISTS reportes (
    id INT AUTO_INCREMENT PRIMARY KEY,
    usuario_id INT NOT NULL,
    historial_id INT DEFAULT NULL,
    notificacion_id INT DEFAULT NULL,
    tipo ENUM('mensual', 'anual', 'personalizado') DEFAULT 'mensual',
    periodo_inicio DATE,
    periodo_fin DATE,
    resumen TEXT,
    fecha_generacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (usuario_id) REFERENCES usuarios(id) ON DELETE CASCADE,
    FOREIGN KEY (historial_id) REFERENCES historial_acciones(id) ON DELETE SET NULL,
    FOREIGN KEY (notificacion_id) REFERENCES notificaciones(id) ON DELETE SET NULL
);

CREATE TABLE IF NOT EXISTS configuraciones_sistema (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(255) NOT NULL,
    valor VARCHAR(255) NOT NULL,
    descripcion TEXT,
    ultima_actualizacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
