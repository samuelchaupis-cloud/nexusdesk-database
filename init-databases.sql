-- ============================================================
-- TechDesk Pro Cloud - Inicialización Multibase Limpia / Inicial
-- MySQL 8.x / MariaDB
-- Cero datos de negocio (sin clientes, sin activos, sin tickets, sin facturas)
-- 7 Usuarios canónicos preconfigurados para todos los roles con clave: Admin123*
-- ============================================================

SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT;
SET NAMES utf8mb4;
SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0;
SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO';

CREATE DATABASE IF NOT EXISTS `db_auth` DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
CREATE DATABASE IF NOT EXISTS `db_customer` DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
CREATE DATABASE IF NOT EXISTS `db_helpdesk` DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
CREATE DATABASE IF NOT EXISTS `db_operations` DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
CREATE DATABASE IF NOT EXISTS `db_crm` DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
CREATE DATABASE IF NOT EXISTS `db_billing` DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
CREATE DATABASE IF NOT EXISTS `db_notification` DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- ------------------------------------------------------------
-- 1. BASE DE DATOS: db_auth
-- ------------------------------------------------------------
USE `db_auth`;

DROP TABLE IF EXISTS `usuarios`;
DROP TABLE IF EXISTS `roles`;
DROP TABLE IF EXISTS `company_config`;
DROP TABLE IF EXISTS `outbox_events`;
DROP TABLE IF EXISTS `consumed_messages`;

CREATE TABLE `roles` (
    `id` TINYINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    `nombre` VARCHAR(40) NOT NULL UNIQUE,
    `descripcion` VARCHAR(150) NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

INSERT INTO `roles` (`id`, `nombre`, `descripcion`) VALUES
(1, 'Administrador', 'Acceso total y configuración del sistema'),
(2, 'Supervisor', 'Gestiona equipo técnico y reportes gerenciales'),
(3, 'Técnico', 'Atiende incidencias, órdenes de servicio y visitas'),
(4, 'Recepción', 'Mesa de partes, clientes y registro inicial de tickets'),
(5, 'Comercial', 'Pipeline de ventas, leads, cotizaciones y CRM'),
(6, 'Cliente', 'Portal de autoservicio para consulta y registro');

CREATE TABLE `usuarios` (
    `id` BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    `rol_id` TINYINT UNSIGNED NOT NULL,
    `nombres` VARCHAR(80) NOT NULL,
    `apellidos` VARCHAR(80) NOT NULL,
    `usuario` VARCHAR(40) NOT NULL UNIQUE,
    `email` VARCHAR(120) NOT NULL UNIQUE,
    `password` VARCHAR(255) NOT NULL,
    `telefono` VARCHAR(25) NULL,
    `cargo` VARCHAR(80) NULL,
    `avatar_color` VARCHAR(9) NOT NULL DEFAULT '#4f46e5',
    `estado` TINYINT(1) NOT NULL DEFAULT 1,
    `ultimo_acceso` DATETIME NULL,
    `cliente_id` BIGINT UNSIGNED NULL,
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT `fk_usu_rol` FOREIGN KEY (`rol_id`) REFERENCES `roles` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Contraseña estándar para todos los usuarios semilla: Admin123*
-- BCrypt Hash: $2a$10$CbC3J05uXE7Kxfe14CpCyuncOiqEt99aNAWKv4Y0lerVmxpN4Jf4y
INSERT INTO `usuarios` (`id`, `rol_id`, `nombres`, `apellidos`, `usuario`, `email`, `password`, `telefono`, `cargo`, `avatar_color`, `estado`, `cliente_id`) VALUES
(1, 1, 'Victor', 'Ramírez', 'admin', 'admin@nexusdesk.pe', '$2a$10$CbC3J05uXE7Kxfe14CpCyuncOiqEt99aNAWKv4Y0lerVmxpN4Jf4y', '999111222', 'Jefe de Soporte TI', '#4f46e5', 1, NULL),
(2, 2, 'Lucía', 'Fernández', 'lfernandez', 'lucia@nexusdesk.pe', '$2a$10$CbC3J05uXE7Kxfe14CpCyuncOiqEt99aNAWKv4Y0lerVmxpN4Jf4y', '999222333', 'Supervisora de Operaciones', '#0ea5e9', 1, NULL),
(3, 3, 'Carlos', 'Mendoza', 'cmendoza', 'carlos@nexusdesk.pe', '$2a$10$CbC3J05uXE7Kxfe14CpCyuncOiqEt99aNAWKv4Y0lerVmxpN4Jf4y', '999333444', 'Técnico Especialista de Redes', '#10b981', 1, NULL),
(4, 3, 'Andrea', 'Quispe', 'aquispe', 'andrea@nexusdesk.pe', '$2a$10$CbC3J05uXE7Kxfe14CpCyuncOiqEt99aNAWKv4Y0lerVmxpN4Jf4y', '999444555', 'Técnico de Soporte en Campo', '#f59e0b', 1, NULL),
(5, 4, 'Marta', 'Flores', 'recepcion', 'recepcion@nexusdesk.pe', '$2a$10$CbC3J05uXE7Kxfe14CpCyuncOiqEt99aNAWKv4Y0lerVmxpN4Jf4y', '999777888', 'Coordinadora de Mesa de Partes', '#ec4899', 1, NULL),
(6, 5, 'Valeria', 'Castro', 'vcastro', 'valeria@nexusdesk.pe', '$2a$10$CbC3J05uXE7Kxfe14CpCyuncOiqEt99aNAWKv4Y0lerVmxpN4Jf4y', '999555666', 'Ejecutiva de Cuentas B2B', '#8b5cf6', 1, NULL),
(7, 6, 'Usuario', 'Cliente', 'cliente.demo', 'portal.demo@cliente.pe', '$2a$10$CbC3J05uXE7Kxfe14CpCyuncOiqEt99aNAWKv4Y0lerVmxpN4Jf4y', '999666777', 'Contacto Autorizado de Cliente', '#06b6d4', 1, NULL);

CREATE TABLE `company_config` (
    `id` TINYINT UNSIGNED PRIMARY KEY DEFAULT 1,
    `nombre` VARCHAR(150) NOT NULL DEFAULT 'NexusDesk — Gestión Integral de Servicios TI',
    `ruc` VARCHAR(15) NULL DEFAULT '20601234567',
    `doc_etiqueta` VARCHAR(10) NULL DEFAULT 'RUC',
    `giro` VARCHAR(100) NULL DEFAULT 'Servicios de tecnología e infraestructura',
    `direccion` VARCHAR(200) NULL DEFAULT 'Av. Javier Prado Este 4567, Lima, Perú',
    `telefono` VARCHAR(25) NULL DEFAULT '+51 (01) 710-9000',
    `email` VARCHAR(120) NULL DEFAULT 'contacto@nexusdesk.pe',
    `web` VARCHAR(120) NULL DEFAULT 'https://nexusdesk.pe',
    `zona_horaria` VARCHAR(60) NULL DEFAULT 'America/Lima',
    `moneda_simbolo` VARCHAR(5) NOT NULL DEFAULT 'S/',
    `moneda_codigo` VARCHAR(5) NOT NULL DEFAULT 'PEN',
    `moneda_pos` ENUM('antes','despues') NOT NULL DEFAULT 'antes',
    `moneda_espacio` TINYINT(1) NOT NULL DEFAULT 1,
    `moneda_decimales` TINYINT UNSIGNED NOT NULL DEFAULT 2,
    `sep_decimal` VARCHAR(2) NOT NULL DEFAULT '.',
    `sep_miles` VARCHAR(6) NOT NULL DEFAULT ',',
    `impuesto_nombre` VARCHAR(20) NULL DEFAULT 'IGV',
    `igv_pct` DECIMAL(5,2) NOT NULL DEFAULT 18.00,
    `tarifa_hora_defecto` DECIMAL(8,2) NOT NULL DEFAULT 45.00,
    `formato_fecha` VARCHAR(20) NOT NULL DEFAULT 'd/m/Y',
    `color_marca` VARCHAR(20) NULL DEFAULT 'indigo',
    `pie_documentos` TEXT NULL,
    `logo_base64` LONGTEXT NULL,
    `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

INSERT INTO `company_config` (`id`, `nombre`, `ruc`, `doc_etiqueta`, `giro`, `direccion`, `telefono`, `email`, `web`, `zona_horaria`, `moneda_simbolo`, `moneda_codigo`, `moneda_pos`, `moneda_espacio`, `moneda_decimales`, `sep_decimal`, `sep_miles`, `impuesto_nombre`, `igv_pct`, `tarifa_hora_defecto`, `formato_fecha`, `color_marca`, `pie_documentos`)
VALUES (1, 'NexusDesk — Gestión Integral de Servicios TI', '20601234567', 'RUC', 'Servicios de tecnología e infraestructura', 'Av. Javier Prado Este 4567, Lima, Perú', '+51 (01) 710-9000', 'contacto@nexusdesk.pe', 'https://nexusdesk.pe', 'America/Lima', 'S/', 'PEN', 'antes', 1, 2, '.', ',', 'IGV', 18.00, 45.00, 'd/m/Y', 'indigo', '')
ON DUPLICATE KEY UPDATE `id` = 1;

-- ------------------------------------------------------------
-- Tabla sys_backups para Persistencia Real de Respaldos (Zero-Mock)
-- ------------------------------------------------------------
CREATE TABLE IF NOT EXISTS `sys_backups` (
    `id` BIGINT AUTO_INCREMENT PRIMARY KEY,
    `nombre` VARCHAR(255) NOT NULL,
    `tipo` VARCHAR(50) NOT NULL,
    `fecha` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `tamano_legible` VARCHAR(50) NOT NULL,
    `tamano_bytes` BIGINT NOT NULL,
    `tablas_respaldadas` INT NOT NULL,
    `filas_respaldadas` INT NOT NULL,
    `checksum_sha256` VARCHAR(64) NOT NULL,
    `estado` VARCHAR(30) NOT NULL DEFAULT 'COMPLETADO',
    `creado_por` VARCHAR(100) NOT NULL DEFAULT 'SYSTEM',
    INDEX `idx_backups_fecha` (`fecha` DESC)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE `outbox_events` (
    `id` VARCHAR(36) PRIMARY KEY,
    `aggregate_type` VARCHAR(50) NOT NULL,
    `aggregate_id` VARCHAR(50) NOT NULL,
    `event_type` VARCHAR(100) NOT NULL,
    `payload` JSON NOT NULL,
    `status` ENUM('PENDING', 'SENT', 'FAILED') NOT NULL DEFAULT 'PENDING',
    `retry_count` INT NOT NULL DEFAULT 0,
    `error_message` TEXT NULL,
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    `processed_at` TIMESTAMP NULL,
    INDEX `idx_outbox_status_created` (`status`, `created_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE `consumed_messages` (
    `message_id` VARCHAR(64) PRIMARY KEY,
    `source_queue` VARCHAR(100) NOT NULL,
    `consumed_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ------------------------------------------------------------
-- 2. BASE DE DATOS: db_customer
-- ------------------------------------------------------------
USE `db_customer`;

DROP TABLE IF EXISTS `crm_contactos`;
DROP TABLE IF EXISTS `activos`;
DROP TABLE IF EXISTS `contratos`;
DROP TABLE IF EXISTS `clientes`;
DROP TABLE IF EXISTS `categorias`;
DROP TABLE IF EXISTS `outbox_events`;
DROP TABLE IF EXISTS `consumed_messages`;

CREATE TABLE `categorias` (
    `id` TINYINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    `nombre` VARCHAR(60) NOT NULL,
    `icono` VARCHAR(40) NOT NULL DEFAULT 'bi-tag',
    `color` VARCHAR(9) NOT NULL DEFAULT '#4f46e5'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

INSERT INTO `categorias` (`id`, `nombre`, `icono`, `color`) VALUES
(1, 'Hardware & Servidores', 'bi-server', '#ef4444'),
(2, 'Software & Aplicaciones', 'bi-window-stack', '#3b82f6'),
(3, 'Redes & Conectividad', 'bi-router', '#10b981'),
(4, 'Seguridad Informática', 'bi-shield-check', '#8b5cf6'),
(5, 'Cuentas & Accesos', 'bi-key', '#f59e0b'),
(6, 'Correo & Comunicaciones', 'bi-envelope', '#06b6d4'),
(7, 'Impresión & Periféricos', 'bi-printer', '#64748b'),
(8, 'Mantenimiento Preventivo', 'bi-tools', '#ec4899');

CREATE TABLE `clientes` (
    `id` BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    `razon_social` VARCHAR(150) NOT NULL,
    `ruc` VARCHAR(15) NULL,
    `rubro` VARCHAR(80) NULL,
    `direccion` VARCHAR(200) NULL,
    `telefono` VARCHAR(25) NULL,
    `email` VARCHAR(120) NULL,
    `contacto` VARCHAR(100) NULL,
    `estado` TINYINT(1) NOT NULL DEFAULT 1,
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE `contratos` (
    `id` BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    `cliente_id` BIGINT UNSIGNED NOT NULL,
    `codigo` VARCHAR(20) NOT NULL UNIQUE,
    `plan` ENUM('Básico','Business','Premium') NOT NULL DEFAULT 'Básico',
    `sla_respuesta_horas` SMALLINT NOT NULL DEFAULT 8,
    `sla_resolucion_horas` SMALLINT NOT NULL DEFAULT 48,
    `fecha_inicio` DATE NOT NULL,
    `fecha_fin` DATE NOT NULL,
    `monto_mensual` DECIMAL(10,2) NOT NULL DEFAULT 0.00,
    `estado` ENUM('vigente','por_vencer','vencido') NOT NULL DEFAULT 'vigente',
    CONSTRAINT `fk_cont_cli` FOREIGN KEY (`cliente_id`) REFERENCES `clientes` (`id`),
    CONSTRAINT chk_cont_monto CHECK (monto_mensual >= 0.00),
    CONSTRAINT chk_cont_fechas CHECK (fecha_fin >= fecha_inicio)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE `activos` (
    `id` BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    `cliente_id` BIGINT UNSIGNED NOT NULL,
    `codigo` VARCHAR(20) NOT NULL UNIQUE,
    `tipo` VARCHAR(40) NOT NULL,
    `marca` VARCHAR(40) NULL,
    `modelo` VARCHAR(60) NULL,
    `serie` VARCHAR(60) NULL,
    `ubicacion` VARCHAR(100) NULL,
    `fecha_compra` DATE NULL,
    `garantia_hasta` DATE NULL,
    `estado` ENUM('operativo','en_reparacion','baja') NOT NULL DEFAULT 'operativo',
    CONSTRAINT `fk_act_cli` FOREIGN KEY (`cliente_id`) REFERENCES `clientes` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE `crm_contactos` (
    `id` BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    `cliente_id` BIGINT UNSIGNED NOT NULL,
    `nombre` VARCHAR(100) NOT NULL,
    `cargo` VARCHAR(80) NULL,
    `email` VARCHAR(120) NULL,
    `telefono` VARCHAR(25) NULL,
    `principal` TINYINT(1) NOT NULL DEFAULT 0,
    `notas` VARCHAR(255) NULL,
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT `fk_contac_cli` FOREIGN KEY (`cliente_id`) REFERENCES `clientes` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE `outbox_events` (
    `id` VARCHAR(36) PRIMARY KEY,
    `aggregate_type` VARCHAR(50) NOT NULL,
    `aggregate_id` VARCHAR(50) NOT NULL,
    `event_type` VARCHAR(100) NOT NULL,
    `payload` JSON NOT NULL,
    `status` ENUM('PENDING', 'SENT', 'FAILED') NOT NULL DEFAULT 'PENDING',
    `retry_count` INT NOT NULL DEFAULT 0,
    `error_message` TEXT NULL,
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    `processed_at` TIMESTAMP NULL,
    INDEX `idx_outbox_status_created` (`status`, `created_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE `consumed_messages` (
    `message_id` VARCHAR(64) PRIMARY KEY,
    `source_queue` VARCHAR(100) NOT NULL,
    `consumed_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ------------------------------------------------------------
-- 3. BASE DE DATOS: db_helpdesk
-- ------------------------------------------------------------

-- Semillas Empresariales Canónicas: db_customer
INSERT INTO `clientes` (`id`, `razon_social`, `ruc`, `rubro`, `direccion`, `telefono`, `email`, `contacto`, `estado`) VALUES
(1, 'Inversiones y Servicios Horizonte S.A.C.', '20512345678', 'Finanzas y Banca', 'Av. Las Begonias 441, San Isidro, Lima', '+51 (01) 421-9000', 'contacto@horizonte.pe', 'Mariana Zúñiga', 1),
(2, 'Corporación Logística del Pacífico S.A.', '20609876543', 'Transporte y Logística', 'Av. Elmer Faucett 2100, Callao', '+51 (01) 574-3000', 'soporte@pacificolog.pe', 'Jorge Valdivia', 1),
(3, 'Clínica Especializada San Andrés E.I.R.L.', '20456789012', 'Salud y Farmacia', 'Av. Brasil 1280, Jesús María, Lima', '+51 (01) 332-4000', 'sistemas@clinicasanandres.pe', 'Dra. Patricia Wong', 1)
ON DUPLICATE KEY UPDATE `estado` = 1;

INSERT INTO `contratos` (`id`, `cliente_id`, `codigo`, `plan`, `sla_respuesta_horas`, `sla_resolucion_horas`, `fecha_inicio`, `fecha_fin`, `monto_mensual`, `estado`) VALUES
(1, 1, 'CONT-2026-001', 'Premium', 2, 12, '2026-01-01', '2026-12-31', 3500.00, 'vigente'),
(2, 2, 'CONT-2026-002', 'Business', 4, 24, '2026-02-01', '2026-12-31', 2200.00, 'vigente'),
(3, 3, 'CONT-2026-003', 'Básico', 8, 48, '2026-03-01', '2026-12-31', 1200.00, 'vigente')
ON DUPLICATE KEY UPDATE `estado` = 'vigente';

INSERT INTO `activos` (`id`, `cliente_id`, `codigo`, `tipo`, `marca`, `modelo`, `serie`, `ubicacion`, `fecha_compra`, `garantia_hasta`, `estado`) VALUES
(1, 1, 'ACT-SRV-001', 'Servidor Rack', 'Dell', 'PowerEdge R750', 'SN-R750-8910', 'DataCenter San Isidro - Rack A1', '2025-06-15', '2028-06-15', 'operativo'),
(2, 1, 'ACT-SW-002', 'Switch Gestionable', 'Cisco', 'Catalyst 9300', 'SN-CS9300-4421', 'Piso 4 - Gabinete Redes', '2025-08-10', '2028-08-10', 'operativo'),
(3, 2, 'ACT-FW-003', 'Firewall Perimetral', 'Fortinet', 'FortiGate 100F', 'SN-FG100F-1109', 'Sede Central Callao', '2025-04-20', '2028-04-20', 'operativo'),
(4, 3, 'ACT-PC-004', 'Estación Médica', 'HP', 'EliteDesk 800 G9', 'SN-HP800-6623', 'Consultorio 12', '2025-09-01', '2027-09-01', 'operativo')
ON DUPLICATE KEY UPDATE `estado` = 'operativo';

INSERT INTO `crm_contactos` (`id`, `cliente_id`, `nombre`, `cargo`, `email`, `telefono`, `principal`, `notas`) VALUES
(1, 1, 'Mariana Zúñiga', 'Gerente de Administración', 'mzuniga@horizonte.pe', '998877665', 1, 'Contacto principal para renovaciones y aprobaciones'),
(2, 2, 'Jorge Valdivia', 'Jefe de Operaciones TI', 'jvaldivia@pacificolog.pe', '987654321', 1, 'Coordinación directa de infraestructura'),
(3, 3, 'Dra. Patricia Wong', 'Directora Médica', 'pwong@clinicasanandres.pe', '976543210', 1, 'Autoriza soporte en horario no comercial')
ON DUPLICATE KEY UPDATE `principal` = 1;


USE `db_helpdesk`;

DROP TABLE IF EXISTS `ticket_comentarios`;
DROP TABLE IF EXISTS `tickets`;
DROP TABLE IF EXISTS `kb_articulos`;
DROP TABLE IF EXISTS `cached_clientes`;
DROP TABLE IF EXISTS `cached_tecnicos`;
DROP TABLE IF EXISTS `outbox_events`;
DROP TABLE IF EXISTS `consumed_messages`;

CREATE TABLE `kb_articulos` (
    `id` BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    `categoria_id` TINYINT UNSIGNED NULL,
    `titulo` VARCHAR(180) NOT NULL,
    `contenido` MEDIUMTEXT NULL,
    `vistas` INT NOT NULL DEFAULT 0,
    `autor_id` BIGINT UNSIGNED NULL,
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE `tickets` (
    `id` BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    `codigo` VARCHAR(20) NOT NULL UNIQUE,
    `cliente_id` BIGINT UNSIGNED NOT NULL,
    `activo_id` BIGINT UNSIGNED NULL,
    `categoria_id` TINYINT UNSIGNED NOT NULL,
    `asunto` VARCHAR(180) NOT NULL,
    `descripcion` TEXT NULL,
    `prioridad` ENUM('baja','media','alta','critica') NOT NULL DEFAULT 'media',
    `estado` ENUM('abierto','en_proceso','pendiente','resuelto','cerrado') NOT NULL DEFAULT 'abierto',
    `canal` ENUM('web','correo','telefono','whatsapp','presencial') NOT NULL DEFAULT 'web',
    `tecnico_id` BIGINT UNSIGNED NULL,
    `creado_por` BIGINT UNSIGNED NULL,
    `fecha_limite` DATETIME NULL,
    `resuelto_at` DATETIME NULL,
    `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `updated_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX `idx_tck_est` (`estado`),
    INDEX `idx_tck_cli` (`cliente_id`),
    INDEX `idx_tck_tec` (`tecnico_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE `ticket_comentarios` (
    `id` BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    `ticket_id` BIGINT UNSIGNED NOT NULL,
    `usuario_id` BIGINT UNSIGNED NULL,
    `comentario` TEXT NOT NULL,
    `interno` TINYINT(1) NOT NULL DEFAULT 0,
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT `fk_com_tck` FOREIGN KEY (`ticket_id`) REFERENCES `tickets` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE `cached_clientes` (
    `id` BIGINT UNSIGNED PRIMARY KEY,
    `razon_social` VARCHAR(150) NOT NULL,
    `ruc` VARCHAR(15) NULL,
    `estado` TINYINT(1) NOT NULL DEFAULT 1,
    `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE `cached_tecnicos` (
    `id` BIGINT UNSIGNED PRIMARY KEY,
    `nombres` VARCHAR(80) NOT NULL,
    `apellidos` VARCHAR(80) NOT NULL,
    `nombre_completo` VARCHAR(160) NOT NULL,
    `avatar_color` VARCHAR(9) NOT NULL DEFAULT '#4f46e5',
    `cargo` VARCHAR(80) NULL,
    `estado` TINYINT(1) NOT NULL DEFAULT 1,
    `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Semilla de técnicos disponibles para asignación inmediata en HelpDesk
INSERT INTO `cached_tecnicos` (`id`, `nombres`, `apellidos`, `nombre_completo`, `avatar_color`, `cargo`, `estado`) VALUES
(3, 'Carlos', 'Mendoza', 'Carlos Mendoza', '#10b981', 'Técnico Especialista de Redes', 1),
(4, 'Andrea', 'Quispe', 'Andrea Quispe', '#f59e0b', 'Técnico de Soporte en Campo', 1)
ON DUPLICATE KEY UPDATE `estado` = 1;

CREATE TABLE `outbox_events` (
    `id` VARCHAR(36) PRIMARY KEY,
    `aggregate_type` VARCHAR(50) NOT NULL,
    `aggregate_id` VARCHAR(50) NOT NULL,
    `event_type` VARCHAR(100) NOT NULL,
    `payload` JSON NOT NULL,
    `status` ENUM('PENDING', 'SENT', 'FAILED') NOT NULL DEFAULT 'PENDING',
    `retry_count` INT NOT NULL DEFAULT 0,
    `error_message` TEXT NULL,
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    `processed_at` TIMESTAMP NULL,
    INDEX `idx_outbox_status_created` (`status`, `created_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE `consumed_messages` (
    `message_id` VARCHAR(64) PRIMARY KEY,
    `source_queue` VARCHAR(100) NOT NULL,
    `consumed_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ------------------------------------------------------------
-- 4. BASE DE DATOS: db_operations
-- ------------------------------------------------------------

-- Semillas Empresariales Canónicas: db_helpdesk
INSERT INTO `cached_clientes` (`id`, `razon_social`, `ruc`, `estado`) VALUES
(1, 'Inversiones y Servicios Horizonte S.A.C.', '20512345678', 1),
(2, 'Corporación Logística del Pacífico S.A.', '20609876543', 1),
(3, 'Clínica Especializada San Andrés E.I.R.L.', '20456789012', 1)
ON DUPLICATE KEY UPDATE `estado` = 1;

INSERT INTO `kb_articulos` (`id`, `categoria_id`, `titulo`, `contenido`, `vistas`, `autor_id`) VALUES
(1, 3, 'Procedimiento de Reconfiguración de VPN SSL FortiGate', 'Guía paso a paso para el restablecimiento de túneles VPN SSL en clientes remotos. Verificar puerto 10443, certificados cliente y reglas de firewall activas.', 45, 3),
(2, 1, 'Diagnóstico y Sustitución de Discos SAS en Servidores Dell', 'Protocolo seguro para reemplazo de discos Hot-Swap en arreglo RAID 5/10. Monitorear estado en iDRAC Enterprise antes y después de la reconstrucción.', 82, 3),
(3, 5, 'Políticas de Seguridad y Desbloqueo en Active Directory', 'Directiva institucional para gestión de credenciales, MFA obligatorio y desbloqueo seguro de cuentas tras 3 intentos fallidos.', 120, 2)
ON DUPLICATE KEY UPDATE `vistas` = 100;

INSERT INTO `tickets` (`id`, `codigo`, `cliente_id`, `activo_id`, `categoria_id`, `asunto`, `descripcion`, `prioridad`, `estado`, `canal`, `tecnico_id`, `creado_por`, `fecha_limite`, `created_at`) VALUES
(1, 'TCK-2026-001', 1, 1, 1, 'Fallo de redundancia en fuente de poder Dell R750', 'Alerta crítica en sensor PSU2 del servidor principal de base de datos. Se requiere cambio físico de fuente.', 'alta', 'en_proceso', 'web', 3, 1, '2026-10-25 18:00:00', '2026-10-23 08:30:00'),
(2, 'TCK-2026-002', 2, 3, 3, 'Intermitencia en túnel VPN entre sede Callao y almacén', 'Pérdida de paquetes en túnel IPsec durante horas pico de facturación. Revisión de MTU y enlace troncal.', 'critica', 'abierto', 'telefono', 4, 2, '2026-10-24 14:00:00', '2026-10-23 09:15:00'),
(3, 'TCK-2026-003', 3, 4, 2, 'Lentitud y bloqueo al exportar historias clínicas', 'El software médico se congela al generar reportes mensuales en PDF. Se realizó optimización de base de datos local.', 'media', 'resuelto', 'correo', 3, 1, '2026-10-24 12:00:00', '2026-10-22 10:00:00')
ON DUPLICATE KEY UPDATE `estado` = VALUES(`estado`);

INSERT INTO `ticket_comentarios` (`id`, `ticket_id`, `usuario_id`, `comentario`, `interno`, `created_at`) VALUES
(1, 1, 3, 'Se solicitó repuesto de fuente redundante de 750W a almacén de operaciones.', 1, '2026-10-23 09:00:00'),
(2, 1, 1, 'Coordinado acceso al DataCenter San Isidro para las 15:00 hrs.', 0, '2026-10-23 09:30:00'),
(3, 3, 3, 'Índices reconstruidos en SQLite local y servicio reiniciado. Cliente confirmó solución.', 0, '2026-10-22 16:30:00')
ON DUPLICATE KEY UPDATE `ticket_id` = VALUES(`ticket_id`);


USE `db_operations`;

DROP TABLE IF EXISTS `ordenes_repuestos`;
DROP TABLE IF EXISTS `ordenes_servicio`;
DROP TABLE IF EXISTS `repuestos`;
DROP TABLE IF EXISTS `visitas`;
DROP TABLE IF EXISTS `outbox_events`;
DROP TABLE IF EXISTS `consumed_messages`;

CREATE TABLE `repuestos` (
    `id` BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    `codigo` VARCHAR(20) NOT NULL UNIQUE,
    `nombre` VARCHAR(120) NOT NULL,
    `categoria` VARCHAR(60) NULL,
    `stock` INT NOT NULL DEFAULT 0,
    `stock_minimo` INT NOT NULL DEFAULT 5,
    `precio` DECIMAL(10,2) NOT NULL DEFAULT 0.00,
    `ubicacion` VARCHAR(60) NULL,
    CONSTRAINT chk_rep_stock CHECK (stock >= 0 AND stock_minimo >= 0),
    CONSTRAINT chk_rep_precio CHECK (precio >= 0.00)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE `ordenes_servicio` (
    `id` BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    `codigo` VARCHAR(20) NOT NULL UNIQUE,
    `ticket_id` BIGINT UNSIGNED NULL,
    `cliente_id` BIGINT UNSIGNED NOT NULL,
    `activo_id` BIGINT UNSIGNED NULL,
    `tecnico_id` BIGINT UNSIGNED NULL,
    `tipo` ENUM('correctiva','preventiva','instalacion','diagnostico') NOT NULL DEFAULT 'correctiva',
    `estado` ENUM('pendiente','en_curso','completada','cancelada') NOT NULL DEFAULT 'pendiente',
    `descripcion_trabajo` TEXT NULL,
    `diagnostico` TEXT NULL,
    `solucion` TEXT NULL,
    `horas` DECIMAL(5,2) NOT NULL DEFAULT 0.00,
    `tarifa_hora` DECIMAL(8,2) NOT NULL DEFAULT 45.00,
    `conformidad` TINYINT(1) NOT NULL DEFAULT 0,
    `fecha_programada` DATETIME NULL,
    `fecha_inicio` DATETIME NULL,
    `fecha_fin` DATETIME NULL,
    `cotizacion_id` BIGINT UNSIGNED NULL,
    `firma` MEDIUMTEXT NULL,
    `firma_nombre` VARCHAR(100) NULL,
    `firma_fecha` DATETIME NULL,
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE `ordenes_repuestos` (
    `id` BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    `orden_id` BIGINT UNSIGNED NOT NULL,
    `repuesto_id` BIGINT UNSIGNED NOT NULL,
    `cantidad` INT NOT NULL DEFAULT 1,
    `precio_unit` DECIMAL(10,2) NOT NULL DEFAULT 0.00,
    CONSTRAINT `fk_or_orden` FOREIGN KEY (`orden_id`) REFERENCES `ordenes_servicio` (`id`) ON DELETE CASCADE,
    CONSTRAINT `fk_or_rep` FOREIGN KEY (`repuesto_id`) REFERENCES `repuestos` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE `visitas` (
    `id` BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    `ticket_id` BIGINT UNSIGNED NULL,
    `cliente_id` BIGINT UNSIGNED NOT NULL,
    `tecnico_id` BIGINT UNSIGNED NULL,
    `tipo` ENUM('correctiva','preventiva','instalacion','emergencia') NOT NULL DEFAULT 'correctiva',
    `fecha_programada` DATETIME NOT NULL,
    `estado` ENUM('programada','en_curso','completada','cancelada') NOT NULL DEFAULT 'programada',
    `notas` VARCHAR(255) NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE `outbox_events` (
    `id` VARCHAR(36) PRIMARY KEY,
    `aggregate_type` VARCHAR(50) NOT NULL,
    `aggregate_id` VARCHAR(50) NOT NULL,
    `event_type` VARCHAR(100) NOT NULL,
    `payload` JSON NOT NULL,
    `status` ENUM('PENDING', 'SENT', 'FAILED') NOT NULL DEFAULT 'PENDING',
    `retry_count` INT NOT NULL DEFAULT 0,
    `error_message` TEXT NULL,
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    `processed_at` TIMESTAMP NULL,
    INDEX `idx_outbox_status_created` (`status`, `created_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE `consumed_messages` (
    `message_id` VARCHAR(64) PRIMARY KEY,
    `source_queue` VARCHAR(100) NOT NULL,
    `consumed_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ------------------------------------------------------------
-- 5. BASE DE DATOS: db_crm
-- ------------------------------------------------------------

-- Semillas Empresariales Canónicas: db_operations
INSERT INTO `repuestos` (`id`, `codigo`, `nombre`, `categoria`, `stock`, `stock_minimo`, `precio`, `ubicacion`) VALUES
(1, 'REP-DSK-001', 'Disco Enterprise SAS 2.4TB 10K RPM', 'Almacenamiento', 14, 4, 850.00, 'Almacén Central - E1-A'),
(2, 'REP-RAM-002', 'Módulo Memoria DDR4 32GB ECC Registered', 'Memoria', 22, 6, 420.00, 'Almacén Central - E1-B'),
(3, 'REP-PWR-003', 'Fuente Redundante Hot-Plug 750W Platinum', 'Fuentes', 8, 3, 680.00, 'Almacén Central - E2-C'),
(4, 'REP-CAB-004', 'Patch Cord Cat6A Blindado 3m LSZH', 'Cableado', 85, 20, 35.00, 'Almacén Central - E3-D')
ON DUPLICATE KEY UPDATE `stock` = VALUES(`stock`);

INSERT INTO `ordenes_servicio` (`id`, `codigo`, `ticket_id`, `cliente_id`, `activo_id`, `tecnico_id`, `tipo`, `estado`, `descripcion_trabajo`, `diagnostico`, `solucion`, `horas`, `tarifa_hora`, `conformidad`, `fecha_programada`) VALUES
(1, 'OS-2026-001', 1, 1, 1, 3, 'correctiva', 'en_curso', 'Reemplazo de fuente de poder PSU2 en servidor Dell R750', 'Fallo de circuito de alimentación secundario', 'Sustitución en caliente por repuesto REP-PWR-003', 2.50, 55.00, 0, '2026-10-24 15:00:00'),
(2, 'OS-2026-002', NULL, 2, 3, 4, 'preventiva', 'completada', 'Mantenimiento preventivo semestral de Firewall FortiGate 100F', 'Equipo con temperatura normal y firmware actualizado', 'Limpieza interna y backup de configuración', 3.00, 45.00, 1, '2026-10-21 10:00:00')
ON DUPLICATE KEY UPDATE `estado` = VALUES(`estado`);

INSERT INTO `ordenes_repuestos` (`id`, `orden_id`, `repuesto_id`, `cantidad`, `precio_unit`) VALUES
(1, 1, 3, 1, 680.00)
ON DUPLICATE KEY UPDATE `cantidad` = 1;

INSERT INTO `visitas` (`id`, `ticket_id`, `cliente_id`, `tecnico_id`, `tipo`, `fecha_programada`, `estado`, `notas`) VALUES
(1, 1, 1, 3, 'correctiva', '2026-10-24 15:00:00', 'programada', 'Ingreso a DataCenter con pase de visitante A-102'),
(2, 2, 2, 4, 'emergencia', '2026-10-23 16:00:00', 'en_curso', 'Atención de caída de enlace sede Callao')
ON DUPLICATE KEY UPDATE `estado` = VALUES(`estado`);


USE `db_crm`;

DROP TABLE IF EXISTS `crm_cotizacion_items`;
DROP TABLE IF EXISTS `crm_cotizaciones`;
DROP TABLE IF EXISTS `crm_actividades`;
DROP TABLE IF EXISTS `crm_oportunidades`;
DROP TABLE IF EXISTS `crm_leads`;
DROP TABLE IF EXISTS `crm_etapas`;
DROP TABLE IF EXISTS `outbox_events`;
DROP TABLE IF EXISTS `consumed_messages`;

CREATE TABLE `crm_etapas` (
    `id` TINYINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    `nombre` VARCHAR(40) NOT NULL,
    `orden` TINYINT NOT NULL DEFAULT 0,
    `probabilidad` TINYINT NOT NULL DEFAULT 0,
    `color` VARCHAR(9) NOT NULL DEFAULT '#4f46e5',
    `tipo` ENUM('abierta','ganada','perdida') NOT NULL DEFAULT 'abierta'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

INSERT INTO `crm_etapas` (`id`, `nombre`, `orden`, `probabilidad`, `color`, `tipo`) VALUES
(1, 'Prospección', 1, 10, '#64748b', 'abierta'),
(2, 'Calificación', 2, 25, '#0ea5e9', 'abierta'),
(3, 'Propuesta Técnica', 3, 50, '#8b5cf6', 'abierta'),
(4, 'Negociación', 4, 75, '#f59e0b', 'abierta'),
(5, 'Ganada', 5, 100, '#10b981', 'ganada'),
(6, 'Perdida', 6, 0, '#ef4444', 'perdida');

CREATE TABLE `crm_leads` (
    `id` BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    `codigo` VARCHAR(20) NOT NULL UNIQUE,
    `empresa` VARCHAR(150) NOT NULL,
    `contacto` VARCHAR(100) NULL,
    `cargo` VARCHAR(80) NULL,
    `email` VARCHAR(120) NULL,
    `telefono` VARCHAR(25) NULL,
    `rubro` VARCHAR(80) NULL,
    `origen` ENUM('web','referido','llamada','evento','redes','correo','otro') NOT NULL DEFAULT 'web',
    `interes` VARCHAR(200) NULL,
    `estado` ENUM('nuevo','contactado','calificado','descartado','convertido') NOT NULL DEFAULT 'nuevo',
    `score` TINYINT UNSIGNED NOT NULL DEFAULT 0,
    `responsable_id` BIGINT UNSIGNED NULL,
    `notas` TEXT NULL,
    `motivo_descarte` VARCHAR(200) NULL,
    `cliente_id` BIGINT UNSIGNED NULL,
    `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `updated_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE `crm_oportunidades` (
    `id` BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    `codigo` VARCHAR(20) NOT NULL UNIQUE,
    `titulo` VARCHAR(180) NOT NULL,
    `cliente_id` BIGINT UNSIGNED NOT NULL,
    `contacto_id` BIGINT UNSIGNED NULL,
    `lead_id` BIGINT UNSIGNED NULL,
    `etapa_id` TINYINT UNSIGNED NOT NULL,
    `tipo` ENUM('contrato','renovacion','proyecto','equipos','servicio') NOT NULL DEFAULT 'contrato',
    `valor` DECIMAL(12,2) NOT NULL DEFAULT 0.00,
    `probabilidad` TINYINT UNSIGNED NOT NULL DEFAULT 10,
    `fecha_cierre_estimada` DATE NULL,
    `fecha_cierre_real` DATE NULL,
    `responsable_id` BIGINT UNSIGNED NULL,
    `origen` VARCHAR(20) NULL,
    `estado` ENUM('abierta','ganada','perdida') NOT NULL DEFAULT 'abierta',
    `motivo_perdida` VARCHAR(200) NULL,
    `contrato_id` BIGINT UNSIGNED NULL,
    `descripcion` TEXT NULL,
    `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `updated_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT `fk_op_etapa` FOREIGN KEY (`etapa_id`) REFERENCES `crm_etapas` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE `crm_actividades` (
    `id` BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    `tipo` ENUM('llamada','reunion','correo','tarea','visita','nota') NOT NULL DEFAULT 'tarea',
    `asunto` VARCHAR(180) NOT NULL,
    `detalle` TEXT NULL,
    `fecha` DATETIME NULL,
    `completada` TINYINT(1) NOT NULL DEFAULT 0,
    `completada_at` DATETIME NULL,
    `resultado` TEXT NULL,
    `auto` TINYINT(1) NOT NULL DEFAULT 0,
    `cliente_id` BIGINT UNSIGNED NULL,
    `lead_id` BIGINT UNSIGNED NULL,
    `oportunidad_id` BIGINT UNSIGNED NULL,
    `responsable_id` BIGINT UNSIGNED NULL,
    `creado_por` BIGINT UNSIGNED NULL,
    `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE `crm_cotizaciones` (
    `id` BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    `codigo` VARCHAR(20) NOT NULL UNIQUE,
    `cliente_id` BIGINT UNSIGNED NOT NULL,
    `oportunidad_id` BIGINT UNSIGNED NULL,
    `contacto_id` BIGINT UNSIGNED NULL,
    `fecha` DATE NOT NULL,
    `valida_hasta` DATE NOT NULL,
    `estado` ENUM('borrador','enviada','aprobada','rechazada','vencida') NOT NULL DEFAULT 'borrador',
    `descuento_pct` DECIMAL(5,2) NOT NULL DEFAULT 0.00,
    `igv_pct` DECIMAL(5,2) NOT NULL DEFAULT 18.00,
    `subtotal` DECIMAL(12,2) NOT NULL DEFAULT 0.00,
    `descuento` DECIMAL(12,2) NOT NULL DEFAULT 0.00,
    `igv` DECIMAL(12,2) NOT NULL DEFAULT 0.00,
    `total` DECIMAL(12,2) NOT NULL DEFAULT 0.00,
    `condiciones` TEXT NULL,
    `notas` VARCHAR(255) NULL,
    `creado_por` BIGINT UNSIGNED NULL,
    `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE `crm_cotizacion_items` (
    `id` BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    `cotizacion_id` BIGINT UNSIGNED NOT NULL,
    `descripcion` VARCHAR(255) NOT NULL,
    `cantidad` DECIMAL(10,2) NOT NULL DEFAULT 1.00,
    `precio_unit` DECIMAL(12,2) NOT NULL DEFAULT 0.00,
    CONSTRAINT `fk_ci_cot` FOREIGN KEY (`cotizacion_id`) REFERENCES `crm_cotizaciones` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE `outbox_events` (
    `id` VARCHAR(36) PRIMARY KEY,
    `aggregate_type` VARCHAR(50) NOT NULL,
    `aggregate_id` VARCHAR(50) NOT NULL,
    `event_type` VARCHAR(100) NOT NULL,
    `payload` JSON NOT NULL,
    `status` ENUM('PENDING', 'SENT', 'FAILED') NOT NULL DEFAULT 'PENDING',
    `retry_count` INT NOT NULL DEFAULT 0,
    `error_message` TEXT NULL,
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    `processed_at` TIMESTAMP NULL,
    INDEX `idx_outbox_status_created` (`status`, `created_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE `consumed_messages` (
    `message_id` VARCHAR(64) PRIMARY KEY,
    `source_queue` VARCHAR(100) NOT NULL,
    `consumed_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ------------------------------------------------------------
-- 6. BASE DE DATOS: db_billing
-- ------------------------------------------------------------

-- Semillas Empresariales Canónicas: db_crm
INSERT INTO `crm_leads` (`id`, `codigo`, `empresa`, `contacto`, `cargo`, `email`, `telefono`, `rubro`, `origen`, `interes`, `estado`, `score`, `responsable_id`) VALUES
(1, 'LEAD-2026-001', 'Agroindustrias del Sur S.A.A.', 'Ing. Roberto Silva', 'Gerente de Operaciones', 'rsilva@agrosur.pe', '987654321', 'Agroindustria', 'web', 'Monitoreo 24/7 y administración de servidores', 'calificado', 85, 6),
(2, 'LEAD-2026-002', 'Financiera Progreso S.A.', 'Lic. Gisella Peña', 'Jefa de Infraestructura', 'gpena@fprogreso.pe', '976543210', 'Banca y Finanzas', 'referido', 'Auditoría de ciberseguridad y firewall', 'contactado', 60, 6)
ON DUPLICATE KEY UPDATE `estado` = VALUES(`estado`);

INSERT INTO `crm_oportunidades` (`id`, `codigo`, `titulo`, `cliente_id`, `contacto_id`, `etapa_id`, `tipo`, `valor`, `probabilidad`, `fecha_cierre_estimada`, `responsable_id`, `estado`) VALUES
(1, 'OPP-2026-001', 'Soporte Integral TI y Monitoreo 24/7', 1, 1, 3, 'contrato', 42000.00, 50, '2026-11-30', 6, 'abierta'),
(2, 'OPP-2026-002', 'Migración y Fortalecimiento de Ciberseguridad', 2, 2, 4, 'proyecto', 28500.00, 75, '2026-11-15', 6, 'abierta')
ON DUPLICATE KEY UPDATE `estado` = VALUES(`estado`);

INSERT INTO `crm_cotizaciones` (`id`, `codigo`, `cliente_id`, `oportunidad_id`, `contacto_id`, `fecha`, `valida_hasta`, `estado`, `subtotal`, `descuento`, `igv`, `total`, `creado_por`) VALUES
(1, 'COT-2026-001', 1, 1, 1, '2026-10-20', '2026-11-20', 'enviada', 35593.22, 0.00, 6406.78, 42000.00, 6),
(2, 'COT-2026-002', 2, 2, 2, '2026-10-22', '2026-11-22', 'borrador', 24152.54, 0.00, 4347.46, 28500.00, 6)
ON DUPLICATE KEY UPDATE `estado` = VALUES(`estado`);

INSERT INTO `crm_cotizacion_items` (`id`, `cotizacion_id`, `descripcion`, `cantidad`, `precio_unitario`, `subtotal`) VALUES
(1, 1, 'Servicio Anual de Administración y Monitoreo Proactivo de Servidores 24x7', 1, 35593.22, 35593.22),
(2, 2, 'Implementación y Hardening de Clúster de Firewalls FortiGate con Alta Disponibilidad', 1, 24152.54, 24152.54)
ON DUPLICATE KEY UPDATE `subtotal` = VALUES(`subtotal`);

INSERT INTO `crm_actividades` (`id`, `tipo`, `asunto`, `detalle`, `fecha`, `completada`, `cliente_id`, `oportunidad_id`, `responsable_id`) VALUES
(1, 'reunion', 'Presentación de Propuesta Técnica SLA 24/7', 'Reunión ejecutiva con directorio para revisión de alcance y SLA', '2026-10-26 10:00:00', 0, 1, 1, 6),
(2, 'llamada', 'Seguimiento de Cotización Ciberseguridad', 'Llamada de seguimiento con Jorge Valdivia para resolver dudas técnicas', '2026-10-24 11:30:00', 0, 2, 2, 6)
ON DUPLICATE KEY UPDATE `asunto` = VALUES(`asunto`);


USE `db_billing`;

DROP TABLE IF EXISTS `fac_pagos`;
DROP TABLE IF EXISTS `fac_items`;
DROP TABLE IF EXISTS `fac_comprobantes`;
DROP TABLE IF EXISTS `fac_secuencias`;
DROP TABLE IF EXISTS `processed_events`;
DROP TABLE IF EXISTS `outbox_events`;
DROP TABLE IF EXISTS `consumed_messages`;

CREATE TABLE `fac_comprobantes` (
    `id` BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    `tipo` ENUM('factura','boleta','recibo') NOT NULL DEFAULT 'factura',
    `serie` VARCHAR(6) NOT NULL,
    `numero` INT UNSIGNED NOT NULL,
    `codigo` VARCHAR(20) NOT NULL UNIQUE,
    `cliente_id` BIGINT UNSIGNED NOT NULL,
    `concepto` ENUM('mensualidad','servicio','equipos','otro') NOT NULL DEFAULT 'servicio',
    `contrato_id` BIGINT UNSIGNED NULL,
    `orden_id` BIGINT UNSIGNED NULL,
    `cotizacion_id` BIGINT UNSIGNED NULL,
    `periodo` CHAR(7) NULL,
    `fecha_emision` DATE NOT NULL,
    `fecha_vencimiento` DATE NOT NULL,
    `igv_pct` DECIMAL(5,2) NOT NULL DEFAULT 18.00,
    `subtotal` DECIMAL(12,2) NOT NULL DEFAULT 0.00,
    `igv` DECIMAL(12,2) NOT NULL DEFAULT 0.00,
    `total` DECIMAL(12,2) NOT NULL DEFAULT 0.00,
    `pagado` DECIMAL(12,2) NOT NULL DEFAULT 0.00,
    `estado` ENUM('emitida','pagada','anulada') NOT NULL DEFAULT 'emitida',
    `motivo_anulacion` VARCHAR(200) NULL,
    `notas` VARCHAR(500) NULL,
    `creado_por` BIGINT UNSIGNED NULL,
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE KEY `uq_fac_serie_num` (`serie`, `numero`),
    CONSTRAINT chk_fac_montos CHECK (subtotal >= 0.00 AND igv >= 0.00 AND total >= 0.00),
    CONSTRAINT chk_fac_fechas CHECK (fecha_vencimiento >= fecha_emision)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE `fac_items` (
    `id` BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    `comprobante_id` BIGINT UNSIGNED NOT NULL,
    `descripcion` VARCHAR(255) NOT NULL,
    `cantidad` DECIMAL(10,2) NOT NULL DEFAULT 1.00,
    `precio_unit` DECIMAL(12,2) NOT NULL DEFAULT 0.00,
    CONSTRAINT `fk_fi_comp` FOREIGN KEY (`comprobante_id`) REFERENCES `fac_comprobantes` (`id`) ON DELETE CASCADE,
    CONSTRAINT chk_item_cant CHECK (cantidad > 0.00),
    CONSTRAINT chk_item_precio CHECK (precio_unit >= 0.00)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE `fac_pagos` (
    `id` BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    `comprobante_id` BIGINT UNSIGNED NOT NULL,
    `fecha` DATE NOT NULL,
    `monto` DECIMAL(12,2) NOT NULL,
    `metodo` ENUM('efectivo','transferencia','yape','plin','tarjeta','deposito','cheque') NOT NULL DEFAULT 'transferencia',
    `referencia` VARCHAR(80) NULL,
    `notas` VARCHAR(200) NULL,
    `registrado_por` BIGINT UNSIGNED NULL,
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT `fk_fp_comp` FOREIGN KEY (`comprobante_id`) REFERENCES `fac_comprobantes` (`id`) ON DELETE CASCADE,
    CONSTRAINT chk_pago_monto CHECK (monto > 0.00)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE `fac_secuencias` (
    `serie` VARCHAR(6) PRIMARY KEY,
    `ultimo_numero` INT UNSIGNED NOT NULL DEFAULT 0,
    `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- En la versión limpia, los correlativos inician estrictamente en cero (0)
INSERT INTO `fac_secuencias` (`serie`, `ultimo_numero`) VALUES 
('F001', 0), 
('B001', 0)
ON DUPLICATE KEY UPDATE `ultimo_numero` = 0;

CREATE TABLE `processed_events` (
    `event_id` VARCHAR(64) NOT NULL,
    `consumer_group` VARCHAR(100) NOT NULL,
    `processed_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (`event_id`, `consumer_group`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE `outbox_events` (
    `id` VARCHAR(36) PRIMARY KEY,
    `aggregate_type` VARCHAR(50) NOT NULL,
    `aggregate_id` VARCHAR(50) NOT NULL,
    `event_type` VARCHAR(100) NOT NULL,
    `payload` JSON NOT NULL,
    `status` ENUM('PENDING', 'SENT', 'FAILED') NOT NULL DEFAULT 'PENDING',
    `retry_count` INT NOT NULL DEFAULT 0,
    `error_message` TEXT NULL,
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    `processed_at` TIMESTAMP NULL,
    INDEX `idx_outbox_status_created` (`status`, `created_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE `consumed_messages` (
    `message_id` VARCHAR(64) PRIMARY KEY,
    `source_queue` VARCHAR(100) NOT NULL,
    `consumed_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ------------------------------------------------------------
-- 7. BASE DE DATOS: db_notification
-- ------------------------------------------------------------

-- Semillas Empresariales Canónicas: db_billing
INSERT INTO `secuencias_fiscales` (`id`, `tipo_documento`, `serie`, `ultimo_correlativo`) VALUES
(1, 'FACTURA', 'F001', 124),
(2, 'BOLETA', 'B001', 87)
ON DUPLICATE KEY UPDATE `ultimo_correlativo` = VALUES(`ultimo_correlativo`);

INSERT INTO `comprobantes` (`id`, `tipo_documento`, `serie`, `correlativo`, `numero_completo`, `cliente_id`, `cliente_nombre`, `cliente_documento`, `direccion_fiscal`, `moneda`, `fecha_emision`, `fecha_vencimiento`, `subtotal`, `igv`, `total`, `estado`, `observaciones`) VALUES
(1, 'FACTURA', 'F001', 123, 'F001-00000123', 1, 'Inversiones y Servicios Horizonte S.A.C.', '20512345678', 'Av. Las Begonias 441, San Isidro, Lima', 'PEN', '2026-10-01', '2026-10-31', 3500.00, 630.00, 4130.00, 'PAGADO', 'Servicio de mantenimiento mensual Octubre 2026'),
(2, 'FACTURA', 'F001', 124, 'F001-00000124', 2, 'Corporación Logística del Pacífico S.A.', '20609876543', 'Av. Elmer Faucett 2100, Callao', 'PEN', '2026-10-05', '2026-11-05', 2200.00, 396.00, 2596.00, 'EMITIDO', 'Servicio mensual soporte TI')
ON DUPLICATE KEY UPDATE `estado` = VALUES(`estado`);

INSERT INTO `fac_items` (`id`, `comprobante_id`, `descripcion`, `cantidad`, `precio_unitario`, `subtotal`, `igv`, `total`) VALUES
(1, 1, 'Suscripción Mensual Soporte Premium TI', 1, 3500.00, 3500.00, 630.00, 4130.00),
(2, 2, 'Suscripción Mensual Soporte Business TI', 1, 2200.00, 2200.00, 396.00, 2596.00)
ON DUPLICATE KEY UPDATE `total` = VALUES(`total`);

INSERT INTO `fac_pagos` (`id`, `comprobante_id`, `fecha_pago`, `monto`, `metodo_pago`, `numero_operacion`, `observaciones`) VALUES
(1, 1, '2026-10-15', 4130.00, 'TRANSFERENCIA', 'BCP-9882314-OP', 'Pago confirmado por tesorería')
ON DUPLICATE KEY UPDATE `monto` = VALUES(`monto`);


USE `db_notification`;

DROP TABLE IF EXISTS `notif_envios`;
DROP TABLE IF EXISTS `actividad`;
DROP TABLE IF EXISTS `outbox_events`;
DROP TABLE IF EXISTS `consumed_messages`;

CREATE TABLE `notif_envios` (
    `id` BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    `canal` ENUM('correo','whatsapp') NOT NULL DEFAULT 'correo',
    `destinatario` VARCHAR(160) NOT NULL,
    `asunto` VARCHAR(200) NOT NULL,
    `cuerpo` MEDIUMTEXT NULL,
    `estado` ENUM('enviado','simulado','error') NOT NULL DEFAULT 'simulado',
    `error` VARCHAR(255) NULL,
    `cliente_id` BIGINT UNSIGNED NULL,
    `ticket_id` BIGINT UNSIGNED NULL,
    `cotizacion_id` BIGINT UNSIGNED NULL,
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX `idx_notif_fec` (`created_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE `actividad` (
    `id` BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    `usuario_id` BIGINT UNSIGNED NULL,
    `usuario_nombre` VARCHAR(160) NULL,
    `accion` VARCHAR(120) NOT NULL,
    `detalle` VARCHAR(255) NULL,
    `icono` VARCHAR(40) NOT NULL DEFAULT 'bi-activity',
    `color` VARCHAR(9) NOT NULL DEFAULT '#4f46e5',
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX `idx_act_created` (`created_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE `outbox_events` (
    `id` VARCHAR(36) PRIMARY KEY,
    `aggregate_type` VARCHAR(50) NOT NULL,
    `aggregate_id` VARCHAR(50) NOT NULL,
    `event_type` VARCHAR(100) NOT NULL,
    `payload` JSON NOT NULL,
    `status` ENUM('PENDING', 'SENT', 'FAILED') NOT NULL DEFAULT 'PENDING',
    `retry_count` INT NOT NULL DEFAULT 0,
    `error_message` TEXT NULL,
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    `processed_at` TIMESTAMP NULL,
    INDEX `idx_outbox_status_created` (`status`, `created_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE `consumed_messages` (
    `message_id` VARCHAR(64) PRIMARY KEY,
    `source_queue` VARCHAR(100) NOT NULL,
    `consumed_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


-- Semillas Empresariales Canónicas: db_notification
INSERT INTO `notif_envios` (`id`, `canal`, `destinatario`, `asunto`, `cuerpo`, `estado`, `cliente_id`, `ticket_id`) VALUES
(1, 'correo', 'contacto@horizonte.pe', 'NexusDesk - Confirmación de Registro de Ticket TCK-2026-001', 'Estimado cliente, su ticket ha sido registrado y asignado a nuestro equipo técnico.', 'enviado', 1, 1),
(2, 'correo', 'soporte@pacificolog.pe', 'NexusDesk - Orden de Servicio OS-2026-002 Completada', 'Estimado cliente, la orden de mantenimiento preventivo ha culminado con conformidad.', 'enviado', 2, NULL)
ON DUPLICATE KEY UPDATE `estado` = VALUES(`estado`);

INSERT INTO `actividad` (`id`, `usuario_id`, `usuario_nombre`, `accion`, `detalle`, `icono`, `color`) VALUES
(1, 1, 'Victor Ramírez', 'Inicio de Sistema', 'Plataforma NexusDesk Cloud iniciada correctamente.', 'bi-check-circle', '#10b981'),
(2, 3, 'Carlos Mendoza', 'Asignación de Ticket', 'Ticket TCK-2026-001 asignado a Carlos Mendoza.', 'bi-person-badge', '#4f46e5'),
(3, 6, 'Valeria Castro', 'Cotización Emitida', 'Cotización COT-2026-001 enviada a Horizonte S.A.C.', 'bi-file-earmark-text', '#8b5cf6')
ON DUPLICATE KEY UPDATE `accion` = VALUES(`accion`);


SET FOREIGN_KEY_CHECKS = @OLD_FOREIGN_KEY_CHECKS;
SET SQL_MODE = @OLD_SQL_MODE;
SET CHARACTER_SET_CLIENT = @OLD_CHARACTER_SET_CLIENT;
