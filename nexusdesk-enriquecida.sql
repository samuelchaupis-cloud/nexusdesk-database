-- ============================================================================
-- NEXUSDESK PRO CLOUD — MASTER ENRICHED DATABASE SUITE (2026)
-- Arquitectura Multi-Database: Spring Boot 4.0.8 / Java 25 LTS & Angular 21 LTS
-- Evaluacion Academica CIBERTEC - DAW II (Ciclo 2026-I)
-- Coordinador TI / Administrador: Jhonny Samuel Chaupis Alvarez
-- Integrantes: Carlos Hinojosa, Brayan Hurtado, Mathias Alayo
-- ============================================================================

SET @OLD_SQL_MODE=@@SQL_MODE;
SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS;
SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;
SET SQL_MODE = 'NO_AUTO_VALUE_ON_ZERO';

-- ----------------------------------------------------------------------------
-- 1. BASE DE DATOS: db_auth (Seguridad, Roles, Usuarios, Auditoria y Backups)
-- ----------------------------------------------------------------------------
CREATE DATABASE IF NOT EXISTS `db_auth` CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE `db_auth`;

DROP TABLE IF EXISTS `actividad`;
DROP TABLE IF EXISTS `sys_backups`;
DROP TABLE IF EXISTS `company_config`;
DROP TABLE IF EXISTS `usuarios`;
DROP TABLE IF EXISTS `roles`;
DROP TABLE IF EXISTS `outbox_events`;
DROP TABLE IF EXISTS `consumed_messages`;

CREATE TABLE `roles` (
    `id` TINYINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    `nombre` VARCHAR(40) NOT NULL UNIQUE,
    `descripcion` VARCHAR(150) NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

INSERT INTO `roles` (`id`, `nombre`, `descripcion`) VALUES
(1, 'Administrador', 'Acceso total y configuración de la plataforma'),
(2, 'Supervisor', 'Supervisa equipo técnico, clientes y reportes gerenciales'),
(3, 'Técnico', 'Atiende incidencias, órdenes de servicio y visitas de campo'),
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

-- Credenciales estandar: Admin123* para todos los integrantes
INSERT INTO `usuarios` (`id`, `rol_id`, `nombres`, `apellidos`, `usuario`, `email`, `password`, `telefono`, `cargo`, `avatar_color`, `estado`, `cliente_id`) VALUES
(1, 1, 'Jhonny Samuel', 'Chaupis Alvarez', 'admin', 'admin@nexusdesk.pe', '$2a$10$CbC3J05uXE7Kxfe14CpCyuncOiqEt99aNAWKv4Y0lerVmxpN4Jf4y', '999111222', 'Coordinador General TI / Arquitecto Cloud', '#4f46e5', 1, NULL),
(2, 2, 'Carlos Daniel', 'Hinojosa Cano', 'chinojosa', 'chinojosa@nexusdesk.pe', '$2a$10$CbC3J05uXE7Kxfe14CpCyuncOiqEt99aNAWKv4Y0lerVmxpN4Jf4y', '999222333', 'Frontend Lead & Supervisor de Clientes', '#0ea5e9', 1, NULL),
(3, 3, 'Brayan Luis', 'Hurtado Sernaque', 'bhurtado', 'bhurtado@nexusdesk.pe', '$2a$10$CbC3J05uXE7Kxfe14CpCyuncOiqEt99aNAWKv4Y0lerVmxpN4Jf4y', '999333444', 'Backend Lead · Helpdesk & Operaciones', '#10b981', 1, NULL),
(4, 3, 'Andrea', 'Quispe', 'aquispe', 'andrea@nexusdesk.pe', '$2a$10$CbC3J05uXE7Kxfe14CpCyuncOiqEt99aNAWKv4Y0lerVmxpN4Jf4y', '999444555', 'Técnico de Soporte en Campo', '#f59e0b', 1, NULL),
(5, 4, 'Marta', 'Flores', 'recepcion', 'recepcion@nexusdesk.pe', '$2a$10$CbC3J05uXE7Kxfe14CpCyuncOiqEt99aNAWKv4Y0lerVmxpN4Jf4y', '999777888', 'Coordinadora de Mesa de Partes', '#ec4899', 1, NULL),
(6, 5, 'Mathias Miller', 'Alayo Oliveros', 'malayo', 'malayo@nexusdesk.pe', '$2a$10$CbC3J05uXE7Kxfe14CpCyuncOiqEt99aNAWKv4Y0lerVmxpN4Jf4y', '999555666', 'Backend & DevOps · CRM & Facturación', '#8b5cf6', 1, NULL),
(7, 6, 'Usuario', 'Cliente Demo', 'cliente.demo', 'portal.demo@cliente.pe', '$2a$10$CbC3J05uXE7Kxfe14CpCyuncOiqEt99aNAWKv4Y0lerVmxpN4Jf4y', '999666777', 'Contacto Autorizado de Cliente', '#06b6d4', 1, 1),
(8, 1, 'Jhonny Samuel', 'Chaupis Alvarez', 'jchaupis', 'jchaupis@nexusdesk.pe', '$2a$10$CbC3J05uXE7Kxfe14CpCyuncOiqEt99aNAWKv4Y0lerVmxpN4Jf4y', '999111222', 'Coordinador General TI / Arquitecto Cloud', '#4f46e5', 1, NULL);

CREATE TABLE `company_config` (
    `id` TINYINT UNSIGNED PRIMARY KEY DEFAULT 1,
    `nombre` VARCHAR(150) NOT NULL DEFAULT 'NexusDesk — Gestión Integral de Servicios TI',
    `razon_social` VARCHAR(150) NULL DEFAULT 'NEXUSDESK SOLUTIONS PERU S.A.C.',
    `eslogan` VARCHAR(100) NULL DEFAULT 'Soporte TI de Misión Crítica & SLA 24/7 Cloud',
    `ciudad` VARCHAR(80) NULL DEFAULT 'Lima',
    `pais` VARCHAR(60) NULL DEFAULT 'Perú',
    `horario_atencion` VARCHAR(120) NULL DEFAULT 'Lunes a Viernes 08:30 - 18:30',
    `ruc` VARCHAR(15) NULL DEFAULT '20601234567',
    `doc_etiqueta` VARCHAR(10) NULL DEFAULT 'RUC',
    `giro` VARCHAR(100) NULL DEFAULT 'Servicios de tecnología e infraestructura',
    `direccion` VARCHAR(200) NULL DEFAULT 'Av. Javier Prado Este 4567, San Isidro, Lima, Perú',
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
    `cuentas_bancarias_json` TEXT NULL,
    `detraccion_json` TEXT NULL,
    `logo_base64` LONGTEXT NULL,
    `smtp_host` VARCHAR(150) NULL DEFAULT 'smtp.nexusdesk.pe',
    `smtp_port` VARCHAR(10) NULL DEFAULT '587',
    `smtp_seguridad` VARCHAR(20) NULL DEFAULT 'tls',
    `smtp_user` VARCHAR(150) NULL DEFAULT 'notificaciones@nexusdesk.pe',
    `smtp_pass` VARCHAR(255) NULL DEFAULT '',
    `smtp_from` VARCHAR(150) NULL DEFAULT 'notificaciones@nexusdesk.pe',
    `smtp_nombre` VARCHAR(150) NULL DEFAULT 'NexusDesk Soporte Cloud',
    `notif_copia` VARCHAR(150) NULL DEFAULT 'mesa@nexusdesk.pe',
    `notif_ticket_creado` TINYINT(1) NULL DEFAULT 1,
    `notif_ticket_estado` TINYINT(1) NULL DEFAULT 1,
    `notif_ticket_respuesta` TINYINT(1) NULL DEFAULT 1,
    `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

INSERT INTO `company_config` (`id`, `nombre`, `razon_social`, `eslogan`, `ciudad`, `pais`, `horario_atencion`, `ruc`, `doc_etiqueta`, `giro`, `direccion`, `telefono`, `email`, `web`, `zona_horaria`, `moneda_simbolo`, `moneda_codigo`, `moneda_pos`, `moneda_espacio`, `moneda_decimales`, `sep_decimal`, `sep_miles`, `impuesto_nombre`, `igv_pct`, `tarifa_hora_defecto`, `formato_fecha`, `color_marca`, `pie_documentos`)
VALUES (1, 'NexusDesk — Gestión Integral de Servicios TI', 'NEXUSDESK SOLUTIONS PERU S.A.C.', 'Soporte TI de Misión Crítica & SLA 24/7 Cloud', 'Lima', 'Perú', 'Lunes a Viernes 08:30 - 18:30', '20601234567', 'RUC', 'Servicios de tecnología e infraestructura', 'Av. Javier Prado Este 4567, San Isidro, Lima, Perú', '+51 (01) 710-9000', 'contacto@nexusdesk.pe', 'https://nexusdesk.pe', 'America/Lima', 'S/', 'PEN', 'antes', 1, 2, '.', ',', 'IGV', 18.00, 45.00, 'd/m/Y', 'indigo', 'NexusDesk Pro Cloud - Tecnología de Nivel Empresarial')
ON DUPLICATE KEY UPDATE `id` = 1;

CREATE TABLE `sys_backups` (
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

INSERT INTO `sys_backups` (`id`, `nombre`, `tipo`, `fecha`, `tamano_legible`, `tamano_bytes`, `tablas_respaldadas`, `filas_respaldadas`, `checksum_sha256`, `estado`, `creado_por`) VALUES
(1, 'nexusdesk_backup_full_20261020_0300.sql', 'COMPLETO', '2026-10-20 03:00:00', '15.8 MB', 16584210, 25, 4820, 'e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855', 'COMPLETADO', 'Jhonny Samuel Chaupis Alvarez'),
(2, 'nexusdesk_backup_full_20261021_0300.sql', 'COMPLETO', '2026-10-21 03:00:00', '16.2 MB', 17012450, 25, 4910, '8f434346648f6b96df89dda901c5176b10a6d83961dd3c1ac88b59b2dc327aa4', 'COMPLETADO', 'Jhonny Samuel Chaupis Alvarez'),
(3, 'nexusdesk_backup_full_20261022_0300.sql', 'COMPLETO', '2026-10-22 03:00:00', '16.5 MB', 17350120, 25, 5034, 'a6c8e310065b98f2f9f8c0a876a4df9576a8b75f85e43a1a9e29a8837e31cb02', 'COMPLETADO', 'Jhonny Samuel Chaupis Alvarez'),
(4, 'nexusdesk_backup_enriquecido_20261023_2200.sql', 'COMPLETO', '2026-10-23 22:00:00', '18.1 MB', 18980145, 25, 5280, '7b2e1f8a49c3e1098df241ba087a912c45e89d10a3c4856f71290bb34e12fa78', 'COMPLETADO', 'Jhonny Samuel Chaupis Alvarez');

CREATE TABLE `actividad` (
    `id` BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    `usuario_id` BIGINT UNSIGNED NULL,
    `usuario_nombre` VARCHAR(160) NULL,
    `accion` VARCHAR(120) NOT NULL,
    `detalle` VARCHAR(255) NULL,
    `icono` VARCHAR(40) NOT NULL DEFAULT 'bi-activity',
    `color` VARCHAR(9) NOT NULL DEFAULT '#4f46e5',
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX `idx_act_usu` (`usuario_id`),
    INDEX `idx_act_fec` (`created_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

INSERT INTO `actividad` (`id`, `usuario_id`, `usuario_nombre`, `accion`, `detalle`, `icono`, `color`, `created_at`) VALUES
(1, 1, 'Jhonny Samuel Chaupis Alvarez', 'Inicio de Sistema', 'Plataforma NexusDesk Cloud iniciada en clúster Docker con 12 microservicios.', 'bi-check-circle', '#10b981', '2026-10-23 08:00:00'),
(2, 2, 'Carlos Daniel Hinojosa Cano', 'Supervisión de Clientes', 'Revisión y actualización de contrato SLA Platinum con Clínica San Gabriel.', 'bi-shield-check', '#0ea5e9', '2026-10-23 08:45:00'),
(3, 3, 'Brayan Luis Hurtado Sernaque', 'Asignación de Ticket', 'Ticket TCK-0001 diagnosticado y asignado para resolución inmediata.', 'bi-ticket-detailed', '#10b981', '2026-10-23 09:15:00'),
(4, 6, 'Mathias Miller Alayo Oliveros', 'Cotización Emitida', 'Cotización COT-0002 de S/ 41,772.00 enviada a Distribuidora Andina S.A.C.', 'bi-file-earmark-text', '#8b5cf6', '2026-10-23 10:20:00'),
(5, 1, 'Jhonny Samuel Chaupis Alvarez', 'Configuración de Seguridad', 'Actualización de parámetros de autenticación JWT y políticas de acceso.', 'bi-lock', '#4f46e5', '2026-10-23 11:10:00'),
(6, 3, 'Brayan Luis Hurtado Sernaque', 'Cierre de Orden de Servicio', 'Orden OS-0001 completada con conformidad del cliente en sitio.', 'bi-tools', '#10b981', '2026-10-23 12:30:00'),
(7, 2, 'Carlos Daniel Hinojosa Cano', 'Auditoría de Activos', 'Inventario de 47 activos corporativos verificado contra red física.', 'bi-laptop', '#0ea5e9', '2026-10-23 14:00:00'),
(8, 6, 'Mathias Miller Alayo Oliveros', 'Seguimiento Comercial', 'Llamada de cierre con Roberto Salas para contrato de soporte anual.', 'bi-telephone', '#8b5cf6', '2026-10-23 15:30:00'),
(9, 1, 'Jhonny Samuel Chaupis Alvarez', 'Respaldo de Base de Datos', 'Generación de snapshot de consistencia transaccional multi-database.', 'bi-database-check', '#4f46e5', '2026-10-23 17:00:00'),
(10, 3, 'Brayan Luis Hurtado Sernaque', 'Resolución de Ticket Crítico', 'Restablecimiento de enlace redundante FortiGate en San Isidro.', 'bi-check-all', '#10b981', '2026-10-23 18:20:00');

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

-- ----------------------------------------------------------------------------
-- 2. BASE DE DATOS: db_customer (Clientes, Contratos, Activos, Contactos)
-- ----------------------------------------------------------------------------
CREATE DATABASE IF NOT EXISTS `db_customer` CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE `db_customer`;

DROP TABLE IF EXISTS `crm_contactos`;
DROP TABLE IF EXISTS `activos`;
DROP TABLE IF EXISTS `contratos`;
DROP TABLE IF EXISTS `clientes`;
DROP TABLE IF EXISTS `categorias`;
DROP TABLE IF EXISTS `outbox_events`;
DROP TABLE IF EXISTS `consumed_messages`;

CREATE TABLE `categorias` (
    `id` SMALLINT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    `nombre` VARCHAR(60) NOT NULL,
    `icono` VARCHAR(40) NOT NULL DEFAULT 'bi-tag',
    `color` VARCHAR(9) NOT NULL DEFAULT '#4f46e5'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

INSERT INTO `categorias` VALUES (1,'Hardware','bi-cpu','#6366f1'),(2,'Software','bi-window-stack','#0ea5e9'),(3,'Redes y Conectividad','bi-wifi','#10b981'),(4,'Servidores','bi-hdd-rack','#f59e0b'),(5,'Correo y Cuentas','bi-envelope-at','#ec4899'),(6,'Impresoras','bi-printer','#8b5cf6'),(7,'Seguridad','bi-shield-lock','#ef4444'),(8,'Telefonía IP','bi-telephone','#14b8a6');

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

INSERT INTO `clientes` VALUES (1,'Clínica San Gabriel','20512345671','Salud','Av. Javier Prado 1420, San Isidro','01 2082305','ti@cliente1.pe','Dr. Paredes',1,'2026-10-05 13:32:11'),(2,'Distribuidora Andina S.A.C.','20498765432','Comercio','Jr. Cusco 355, Cercado de Lima','01 6560774','ti@cliente2.pe','Ing. Rojas',1,'2026-10-05 13:32:11'),(3,'Colegio Santa Rosa','20456781239','Educación','Av. La Marina 2210, San Miguel','01 5871898','ti@cliente3.pe','Prof. Linares',1,'2026-10-05 13:32:11'),(4,'Estudio Contable Valdivia','20123459876','Servicios','Calle Los Pinos 128, Miraflores','01 2273336','ti@cliente4.pe','CPC Valdivia',1,'2026-10-05 13:32:11'),(5,'Constructora Pacífico','20567891230','Construcción','Av. Argentina 4580, Callao','01 2617421','ti@cliente5.pe','Ing. Huamán',1,'2026-10-05 13:32:11'),(6,'Hotel Mirador del Sol','20345678901','Turismo','Malecón Cisneros 810, Miraflores','01 3491917','ti@cliente6.pe','Sr. Bendezú',1,'2026-10-05 13:32:11'),(7,'Transportes Inca Express','20678912345','Transporte','Av. Venezuela 1890, Breña','01 5818397','ti@cliente7.pe','Sra. Cárdenas',1,'2026-10-05 13:32:11'),(8,'Farmacias Vida Plus','20789123456','Retail','Av. Brasil 1250, Jesús María','01 2691060','ti@cliente8.pe','Q.F. Medina',1,'2026-10-05 13:32:11'),(9,'Empresa Automatizada SAC Test','20601234567','Tecnología e Información','Av. Las Camelias 450, San Isidro','987654321','contacto@automatizado.pe','Ing. Carlos Mendoza',0,'2026-10-11 22:04:59'),(10,'Clínica Santa Elena',NULL,'Salud',NULL,'987654321','rvidal@santaelena.pe','Dra. Rocío Vidal',1,'2026-10-11 22:05:05');

CREATE TABLE `contratos` (
    `id` BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    `cliente_id` BIGINT UNSIGNED NOT NULL,
    `codigo` VARCHAR(20) NOT NULL UNIQUE,
    `plan` VARCHAR(20) NOT NULL DEFAULT 'Básico',
    `sla_respuesta_horas` SMALLINT NOT NULL DEFAULT 8,
    `sla_resolucion_horas` SMALLINT NOT NULL DEFAULT 48,
    `fecha_inicio` DATE NOT NULL,
    `fecha_fin` DATE NOT NULL,
    `monto_mensual` DECIMAL(10,2) NOT NULL DEFAULT 0.00,
    `estado` VARCHAR(20) NOT NULL DEFAULT 'vigente',
    CONSTRAINT `fk_cont_cli` FOREIGN KEY (`cliente_id`) REFERENCES `clientes` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

INSERT INTO `contratos` VALUES (2,2,'CT-2026-002','Business',4,36,'2025-12-09','2026-11-09',950.00,'por_vencer'),(3,3,'CT-2026-003','Básico',8,72,'2025-12-09','2027-03-24',420.00,'vigente'),(4,4,'CT-2026-004','Premium',2,24,'2025-12-09','2027-05-03',1800.00,'vigente'),(5,5,'CT-2026-005','Business',4,36,'2025-12-09','2027-06-12',950.00,'vigente'),(6,6,'CT-2026-006','Básico',8,72,'2025-12-09','2027-07-22',420.00,'vigente'),(7,7,'CT-2026-007','Premium',2,24,'2025-12-09','2027-08-31',1800.00,'vigente'),(8,8,'CT-2026-008','Business',4,36,'2025-12-09','2027-10-10',950.00,'vigente');

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
    `estado` VARCHAR(20) NOT NULL DEFAULT 'operativo',
    CONSTRAINT `fk_act_cli` FOREIGN KEY (`cliente_id`) REFERENCES `clientes` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

INSERT INTO `activos` VALUES (2,1,'ACT-0002','Laptop','HP','ProBook 450 G9','EAF3A11DBE','Almacén','2026-06-13','2027-06-13','operativo'),(3,1,'ACT-0003','Impresora','Epson','L6270','508F5B9E53','Gerencia','2025-11-10','2027-11-10','operativo'),(4,1,'ACT-0004','PC Escritorio','Lenovo','ThinkCentre M70','5D27461186','Almacén','2026-04-06','2028-04-05','operativo'),(5,1,'ACT-0005','Servidor','Dell','PowerEdge R450','8CB13BA029','Almacén','2025-01-26','2027-01-26','operativo'),(6,1,'ACT-0006','PC Escritorio','Lenovo','ThinkCentre M70','5B7CDC9600','Oficina TI','2026-05-02','2028-05-01','operativo'),(7,2,'ACT-0007','Laptop','HP','ProBook 450 G9','2AC5FBB019','Sala de servidores','2026-02-23','2027-02-23','operativo'),(8,2,'ACT-0008','Firewall','Fortinet','FortiGate 60F','C3DDB25F53','Recepción','2025-09-02','2026-09-02','operativo'),(9,2,'ACT-0009','PC Escritorio','Lenovo','ThinkCentre M70','30D625DAD3','Gerencia','2025-08-14','2026-08-14','en_reparacion'),(10,2,'ACT-0010','Switch','Cisco','Catalyst 2960','2BADDAA696','Gerencia','2026-08-04','2028-08-03','operativo'),(11,2,'ACT-0011','Impresora','Epson','L6270','925F90C201','Oficina TI','2024-11-18','2026-11-18','operativo'),(12,2,'ACT-0012','Access Point','Ubiquiti','UniFi U6 Pro','C083722AF0','Oficina TI','2025-04-05','2027-04-05','operativo'),(13,3,'ACT-0013','Firewall','Fortinet','FortiGate 60F','64005B1F13','Almacén','2024-09-01','2026-09-01','operativo'),(14,3,'ACT-0014','Laptop','Dell','Latitude 5440','2786A3BA88','Sala de servidores','2026-04-20','2027-04-20','en_reparacion'),(15,3,'ACT-0015','Laptop','Dell','Latitude 5440','527EE6FF0F','Sala de servidores','2025-05-19','2027-05-19','operativo'),(16,3,'ACT-0016','Switch','Cisco','Catalyst 2960','FA20E9861D','Recepción','2025-04-02','2027-04-02','operativo'),(17,3,'ACT-0017','Access Point','Ubiquiti','UniFi U6 Pro','02928AB627','Almacén','2024-12-02','2025-12-02','operativo'),(18,3,'ACT-0018','Access Point','Ubiquiti','UniFi U6 Pro','806149E4E5','Almacén','2026-05-13','2028-05-12','operativo'),(19,4,'ACT-0019','Switch','Cisco','Catalyst 2960','74472DD62E','Recepción','2025-10-27','2026-10-27','operativo'),(20,4,'ACT-0020','PC Escritorio','Lenovo','ThinkCentre M70','C869156DB7','Oficina TI','2025-11-05','2026-11-05','operativo'),(21,4,'ACT-0021','Router','MikroTik','RB4011','AB30D45EC9','Gerencia','2026-08-03','2027-08-03','operativo'),(22,4,'ACT-0022','Servidor','Dell','PowerEdge R450','9577915412','Oficina TI','2025-10-16','2026-10-16','operativo'),(23,4,'ACT-0023','Access Point','Ubiquiti','UniFi U6 Pro','20741A64C8','Sala de servidores','2026-04-25','2027-04-25','operativo'),(24,4,'ACT-0024','Laptop','HP','ProBook 450 G9','97FE7F0399','Recepción','2025-01-26','2026-01-26','operativo'),(25,5,'ACT-0025','Servidor','Dell','PowerEdge R450','E5153BCF4A','Sala de servidores','2024-12-26','2025-12-26','operativo'),(26,5,'ACT-0026','Laptop','HP','ProBook 450 G9','B1CF9681DF','Almacén','2025-03-25','2026-03-25','en_reparacion'),(27,5,'ACT-0027','Servidor','Dell','PowerEdge R450','E3045BD705','Almacén','2026-01-05','2028-01-05','operativo'),(28,5,'ACT-0028','Switch','Cisco','Catalyst 2960','F0EDC1340A','Oficina TI','2024-10-01','2026-10-01','en_reparacion'),(29,5,'ACT-0029','PC Escritorio','Lenovo','ThinkCentre M70','126C5F4680','Oficina TI','2026-07-01','2028-06-30','operativo'),(30,5,'ACT-0030','Impresora','Epson','L6270','9DE2D17649','Sala de servidores','2025-04-18','2026-04-18','operativo'),(31,6,'ACT-0031','Router','MikroTik','RB4011','624DDABC8D','Oficina TI','2025-02-28','2026-02-28','en_reparacion'),(32,6,'ACT-0032','Router','MikroTik','RB4011','886055E9E7','Oficina TI','2025-01-09','2027-01-09','operativo'),(33,6,'ACT-0033','Laptop','HP','ProBook 450 G9','7E96925442','Oficina TI','2024-09-07','2026-09-07','operativo'),(34,6,'ACT-0034','Router','MikroTik','RB4011','35193ED7EC','Oficina TI','2025-10-13','2027-10-13','operativo'),(35,6,'ACT-0035','Laptop','HP','ProBook 450 G9','08B7BBC3A1','Almacén','2024-05-27','2025-05-27','operativo'),(36,6,'ACT-0036','Laptop','Dell','Latitude 5440','B54A34380B','Sala de servidores','2024-05-26','2026-05-26','operativo'),(37,7,'ACT-0037','PC Escritorio','Lenovo','ThinkCentre M70','2FFB2F78EC','Oficina TI','2025-04-10','2026-04-10','en_reparacion'),(38,7,'ACT-0038','Firewall','Fortinet','FortiGate 60F','B0DB7E59C2','Sala de servidores','2025-04-03','2026-04-03','operativo'),(39,7,'ACT-0039','Firewall','Fortinet','FortiGate 60F','098639D302','Gerencia','2025-09-23','2026-09-23','operativo'),(40,7,'ACT-0040','Switch','Cisco','Catalyst 2960','D75AB56235','Gerencia','2025-12-20','2026-12-20','operativo'),(41,7,'ACT-0041','Laptop','HP','ProBook 450 G9','A938081397','Almacén','2024-08-12','2026-08-12','operativo'),(42,7,'ACT-0042','Switch','Cisco','Catalyst 2960','EDD2040051','Almacén','2024-11-27','2025-11-27','en_reparacion'),(43,8,'ACT-0043','Laptop','HP','ProBook 450 G9','DE71B8498B','Gerencia','2024-05-03','2026-05-03','operativo'),(44,8,'ACT-0044','Laptop','Dell','Latitude 5440','6EE362EFE9','Almacén','2025-07-29','2027-07-29','operativo'),(45,8,'ACT-0045','Laptop','HP','ProBook 450 G9','E31CB99DF6','Oficina TI','2025-05-20','2027-05-20','operativo'),(46,8,'ACT-0046','Firewall','Fortinet','FortiGate 60F','D9EE229097','Oficina TI','2026-02-01','2027-02-01','operativo'),(47,8,'ACT-0047','Impresora','Epson','L6270','7EDBE1B577','Oficina TI','2025-01-30','2026-01-30','operativo'),(48,8,'ACT-0048','Router','MikroTik','RB4011','0366652995','Sala de servidores','2026-05-29','2028-05-28','operativo');

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

INSERT INTO `crm_contactos` VALUES (2,1,'Roberto Salas','Gerente General','roberto.salas@clnica.pe','952082305',0,NULL,'2026-10-05 18:13:47'),(3,2,'Ing. Rojas','Contacto principal','ti@cliente2.pe','01 6560774',1,NULL,'2026-10-05 18:13:47'),(4,2,'Patricia Luna','Jefe de TI','patricia.luna@distribuidora.pe','962560774',0,NULL,'2026-10-05 18:13:47'),(5,3,'Prof. Linares','Contacto principal','ti@cliente3.pe','01 5871898',1,NULL,'2026-10-05 18:13:47'),(6,3,'Diego Paredes','Administrador','diego.paredes@colegio.pe','973871898',0,NULL,'2026-10-05 18:13:47'),(7,4,'CPC Valdivia','Contacto principal','ti@cliente4.pe','01 2273336',1,NULL,'2026-10-05 18:13:47'),(8,4,'Carmen Rojas','Gerente de Operaciones','carmen.rojas@estudio.pe','988273336',0,NULL,'2026-10-05 18:13:47'),(9,5,'Ing. Huamán','Contacto principal','ti@cliente5.pe','01 2617421',1,NULL,'2026-10-05 18:13:47'),(10,5,'Fernando Díaz','Contador','fernando.d\'iaz@constructora.pe','964617421',0,NULL,'2026-10-05 18:13:47'),(11,6,'Sr. Bendezú','Contacto principal','ti@cliente6.pe','01 3491917',1,NULL,'2026-10-05 18:13:47'),(12,6,'Silvia Mora','Gerente General','silvia.mora@hotel.pe','995491917',0,NULL,'2026-10-05 18:13:47'),(13,7,'Sra. Cárdenas','Contacto principal','ti@cliente7.pe','01 5818397',1,NULL,'2026-10-05 18:13:47'),(14,7,'Héctor Vega','Jefe de TI','h\'ector.vega@transportes.pe','931818397',0,NULL,'2026-10-05 18:13:47'),(15,8,'Q.F. Medina','Contacto principal','ti@cliente8.pe','01 2691060',1,NULL,'2026-10-05 18:13:47'),(16,8,'Lorena Campos','Administrador','lorena.campos@farmacias.pe','976691060',0,NULL,'2026-10-05 18:13:47');

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

-- ----------------------------------------------------------------------------
-- 3. BASE DE DATOS: db_helpdesk (Tickets, Base de Conocimiento, Comentarios)
-- ----------------------------------------------------------------------------
CREATE DATABASE IF NOT EXISTS `db_helpdesk` CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE `db_helpdesk`;

DROP TABLE IF EXISTS `ticket_comentarios`;
DROP TABLE IF EXISTS `tickets`;
DROP TABLE IF EXISTS `kb_articulos`;
DROP TABLE IF EXISTS `categorias`;
DROP TABLE IF EXISTS `cached_tecnicos`;
DROP TABLE IF EXISTS `cached_clientes`;
DROP TABLE IF EXISTS `outbox_events`;
DROP TABLE IF EXISTS `consumed_messages`;

CREATE TABLE `categorias` (
    `id` SMALLINT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    `nombre` VARCHAR(60) NOT NULL,
    `icono` VARCHAR(40) NOT NULL DEFAULT 'bi-tag',
    `color` VARCHAR(9) NOT NULL DEFAULT '#4f46e5'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

INSERT INTO `categorias` VALUES (1,'Hardware','bi-cpu','#6366f1'),(2,'Software','bi-window-stack','#0ea5e9'),(3,'Redes y Conectividad','bi-wifi','#10b981'),(4,'Servidores','bi-hdd-rack','#f59e0b'),(5,'Correo y Cuentas','bi-envelope-at','#ec4899'),(6,'Impresoras','bi-printer','#8b5cf6'),(7,'Seguridad','bi-shield-lock','#ef4444'),(8,'Telefonía IP','bi-telephone','#14b8a6');

CREATE TABLE `cached_tecnicos` (
    `id` BIGINT UNSIGNED PRIMARY KEY,
    `nombre_completo` VARCHAR(160) NOT NULL,
    `email` VARCHAR(120) NOT NULL,
    `telefono` VARCHAR(25) NULL,
    `activo` TINYINT(1) NOT NULL DEFAULT 1,
    `rol_id` TINYINT UNSIGNED NOT NULL DEFAULT 3,
    `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

INSERT INTO `cached_tecnicos` (`id`, `nombre_completo`, `email`, `telefono`, `activo`, `rol_id`) VALUES
(3, 'Brayan Luis Hurtado Sernaque', 'bhurtado@nexusdesk.pe', '999333444', 1, 3),
(4, 'Andrea Quispe', 'andrea@nexusdesk.pe', '999444555', 1, 3);

CREATE TABLE `cached_clientes` (
    `id` BIGINT UNSIGNED PRIMARY KEY,
    `razon_social` VARCHAR(150) NOT NULL,
    `ruc` VARCHAR(15) NULL,
    `email` VARCHAR(120) NULL,
    `telefono` VARCHAR(25) NULL,
    `estado` TINYINT(1) NOT NULL DEFAULT 1,
    `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

INSERT INTO `cached_clientes` (`id`, `razon_social`, `ruc`, `email`, `telefono`, `estado`) VALUES
(1, 'Clínica San Gabriel', '20512345671', 'ti@cliente1.pe', '01 2082305', 1),
(2, 'Distribuidora Andina S.A.C.', '20498765432', 'ti@cliente2.pe', '01 6560774', 1),
(3, 'Colegio Santa Rosa', '20456781239', 'ti@cliente3.pe', '01 5871898', 1),
(4, 'Estudio Contable Valdivia', '20123459876', 'ti@cliente4.pe', '01 2273336', 1),
(5, 'Constructora Pacífico', '20567891230', 'ti@cliente5.pe', '01 2617421', 1),
(6, 'Hotel Mirador del Sol', '20345678901', 'ti@cliente6.pe', '01 3491917', 1),
(7, 'Transportes Inca Express', '20678912345', 'ti@cliente7.pe', '01 5818397', 1),
(8, 'Farmacias Vida Plus', '20789123456', 'ti@cliente8.pe', '01 2691060', 1),
(9, 'Empresa Automatizada SAC Test', '20601234567', 'contacto@automatizado.pe', '987654321', 0),
(10, 'Clínica Santa Elena', '20609998881', 'rvidal@santaelena.pe', '987654321', 1);

CREATE TABLE `kb_articulos` (
    `id` BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    `categoria_id` SMALLINT NOT NULL,
    `titulo` VARCHAR(180) NOT NULL,
    `contenido` MEDIUMTEXT NOT NULL,
    `vistas` INT UNSIGNED NOT NULL DEFAULT 0,
    `autor_id` BIGINT UNSIGNED NULL,
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT `fk_kb_cat` FOREIGN KEY (`categoria_id`) REFERENCES `categorias` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

INSERT INTO `kb_articulos` (`id`, `categoria_id`, `titulo`, `contenido`, `vistas`, `autor_id`, `created_at`) VALUES
(1, 1, 'Guía de Configuración Inicial de Red y VPN', 'Pasos para conectar equipos corporativos a la VPN segura IPSec/WireGuard y resolución de problemas de DNS local.', 142, 1, '2026-10-01 09:00:00'),
(2, 2, 'Procedimiento Estándar de Mantenimiento Preventivo', 'Checklist para servidores físicos, limpieza interna de chasis, reemplazo de pasta térmica y revisión de arreglos RAID 1/5.', 98, 3, '2026-10-02 11:30:00'),
(3, 3, 'Políticas de Respaldo y Recuperación ante Desastres (DRP)', 'Protocolos RPO y RTO para copias de seguridad incrementales nocturnas con almacenamiento inmutable en la nube.', 75, 1, '2026-10-03 14:15:00'),
(4, 4, 'Resolución de Incidencias Frecuentes en Estaciones de Trabajo', 'Diagnóstico de cuellos de botella en memoria RAM, regeneración de perfiles de Windows y limpieza de colas de impresión Spooler.', 215, 4, '2026-10-04 16:40:00');

CREATE TABLE `tickets` (
    `id` BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    `codigo` VARCHAR(20) NOT NULL UNIQUE,
    `cliente_id` BIGINT UNSIGNED NOT NULL,
    `activo_id` BIGINT UNSIGNED NULL,
    `categoria_id` SMALLINT NOT NULL,
    `asunto` VARCHAR(180) NOT NULL,
    `descripcion` TEXT NULL,
    `prioridad` VARCHAR(20) NOT NULL DEFAULT 'media',
    `estado` VARCHAR(20) NOT NULL DEFAULT 'abierto',
    `canal` VARCHAR(20) NOT NULL DEFAULT 'web',
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

INSERT INTO `tickets` VALUES (1,'TCK-01001',8,NULL,2,'Sistema ERP muy lento','Incidencia reportada por el cliente. Requiere diagnóstico y atención según SLA.','alta','cerrado','web',3,1,'2026-06-06 03:27:42','2026-06-05 22:54:06','2026-06-05 03:27:42','2026-10-05 08:32:12'),(2,'TCK-01002',8,NULL,7,'Bloqueo de cuenta por intentos fallidos','Incidencia reportada por el cliente. Requiere diagnóstico y atención según SLA.','media','cerrado','correo',6,1,'2026-07-22 01:04:31','2026-07-20 20:16:31','2026-07-20 01:04:31','2026-10-05 08:32:12'),(3,'TCK-01003',5,NULL,1,'Reemplazo de disco duro por SSD','Incidencia reportada por el cliente. Requiere diagnóstico y atención según SLA.','media','cerrado','presencial',6,1,'2026-09-06 02:17:21','2026-09-05 01:48:33','2026-09-04 02:17:21','2026-10-05 08:32:12'),(4,'TCK-01004',2,NULL,1,'Reemplazo de disco duro por SSD','Incidencia reportada por el cliente. Requiere diagnóstico y atención según SLA.','alta','cerrado','correo',6,1,'2026-06-24 22:27:46','2026-06-24 16:13:21','2026-06-23 22:27:46','2026-10-05 08:32:12'),(5,'TCK-01005',6,NULL,6,'Impresora no imprime en red','Incidencia reportada por el cliente. Requiere diagnóstico y atención según SLA.','baja','cerrado','whatsapp',4,1,'2026-08-20 00:24:52','2026-08-18 21:03:16','2026-08-17 00:24:52','2026-10-05 08:32:12'),(6,'TCK-01006',4,NULL,6,'Cambio de tóner','Incidencia reportada por el cliente. Requiere diagnóstico y atención según SLA.','media','cerrado','correo',6,1,'2026-10-05 07:00:13','2026-10-05 00:17:01','2026-10-03 07:00:13','2026-10-05 08:32:12'),(7,'TCK-01007',7,NULL,6,'Impresora no imprime en red','Incidencia reportada por el cliente. Requiere diagnóstico y atención según SLA.','media','resuelto','presencial',6,1,'2026-07-29 08:07:36','2026-07-28 15:48:24','2026-07-27 08:07:36','2026-10-05 08:32:12'),(8,'TCK-01008',7,NULL,1,'Reemplazo de disco duro por SSD','Incidencia reportada por el cliente. Requiere diagnóstico y atención según SLA.','media','cerrado','web',4,1,'2026-04-26 22:28:53','2026-04-26 10:28:53','2026-04-24 22:28:53','2026-10-05 08:32:12'),(9,'TCK-01009',1,NULL,5,'Alta de nuevo usuario de correo','Incidencia reportada por el cliente. Requiere diagnóstico y atención según SLA.','alta','resuelto','web',3,1,'2026-05-31 02:47:38','2026-05-30 14:04:26','2026-05-30 02:47:38','2026-10-05 08:32:12'),(10,'TCK-01010',6,NULL,7,'Bloqueo de cuenta por intentos fallidos','Incidencia reportada por el cliente. Requiere diagnóstico y atención según SLA.','alta','cerrado','web',4,1,'2026-09-02 05:38:44','2026-09-01 22:41:08','2026-09-01 05:38:44','2026-10-05 08:32:12'),(11,'TCK-01011',1,NULL,1,'Pantalla con líneas verticales','Incidencia reportada por el cliente. Requiere diagnóstico y atención según SLA.','alta','cerrado','web',3,1,'2026-07-06 02:47:33','2026-07-06 00:23:33','2026-07-05 02:47:33','2026-10-05 08:32:12'),(12,'TCK-01012',3,NULL,1,'Laptop no enciende tras corte de energía','Incidencia reportada por el cliente. Requiere diagnóstico y atención según SLA.','baja','abierto','presencial',5,1,'2026-10-05 21:50:09',NULL,'2026-10-02 21:50:09','2026-10-05 08:32:12'),(13,'TCK-01013',1,NULL,8,'Anexos sin tono en oficina','Incidencia reportada por el cliente. Requiere diagnóstico y atención según SLA.','critica','cerrado','whatsapp',5,1,'2026-08-07 13:43:29','2026-08-07 17:19:29','2026-08-07 05:43:29','2026-10-05 08:32:12'),(14,'TCK-01014',3,NULL,3,'Configurar VPN para trabajo remoto','Incidencia reportada por el cliente. Requiere diagnóstico y atención según SLA.','media','resuelto','telefono',4,1,'2026-06-06 04:20:12','2026-06-04 21:37:00','2026-06-04 04:20:12','2026-10-05 08:32:12'),(15,'TCK-01015',2,NULL,3,'Sin internet en el segundo piso','Incidencia reportada por el cliente. Requiere diagnóstico y atención según SLA.','baja','cerrado','telefono',5,1,'2026-09-12 04:59:31','2026-09-11 11:42:43','2026-09-09 04:59:31','2026-10-05 08:32:12'),(16,'TCK-01016',4,NULL,1,'Reemplazo de disco duro por SSD','Incidencia reportada por el cliente. Requiere diagnóstico y atención según SLA.','media','resuelto','correo',5,1,'2026-06-07 23:10:15','2026-06-07 16:27:03','2026-06-05 23:10:15','2026-10-05 08:32:12'),(17,'TCK-01017',4,NULL,6,'Impresora no imprime en red','Incidencia reportada por el cliente. Requiere diagnóstico y atención según SLA.','media','resuelto','telefono',5,1,'2026-09-10 21:57:29','2026-09-10 19:04:41','2026-09-08 21:57:29','2026-10-05 08:32:12'),(18,'TCK-01018',5,NULL,7,'Posible correo de phishing recibido','Incidencia reportada por el cliente. Requiere diagnóstico y atención según SLA.','media','resuelto','correo',6,1,'2026-05-24 06:13:48','2026-05-25 04:47:24','2026-05-22 06:13:48','2026-10-05 08:32:12'),(19,'TCK-01019',3,NULL,4,'Alerta de temperatura en rack','Incidencia reportada por el cliente. Requiere diagnóstico y atención según SLA.','baja','cerrado','correo',6,1,'2026-07-18 23:15:44','2026-07-16 23:44:32','2026-07-15 23:15:44','2026-10-05 08:32:12'),(20,'TCK-01020',5,NULL,4,'Alerta de temperatura en rack','Incidencia reportada por el cliente. Requiere diagnóstico y atención según SLA.','media','cerrado','correo',5,1,'2026-06-19 06:25:41','2026-06-18 09:47:17','2026-06-17 06:25:41','2026-10-05 08:32:12'),(21,'TCK-01021',5,NULL,2,'Instalación de Office 365','Incidencia reportada por el cliente. Requiere diagnóstico y atención según SLA.','critica','cerrado','telefono',3,1,'2026-08-01 08:47:07','2026-08-01 02:47:07','2026-08-01 00:47:07','2026-10-05 08:32:12'),(22,'TCK-01022',5,NULL,2,'Excel se cierra al abrir archivos grandes','Incidencia reportada por el cliente. Requiere diagnóstico y atención según SLA.','media','cerrado','web',4,1,'2026-07-01 08:02:27','2026-07-02 01:48:03','2026-06-29 08:02:27','2026-10-05 08:32:12'),(23,'TCK-01023',8,NULL,1,'Reemplazo de disco duro por SSD','Incidencia reportada por el cliente. Requiere diagnóstico y atención según SLA.','alta','resuelto','correo',4,1,'2026-09-12 00:22:29','2026-09-11 15:00:53','2026-09-11 00:22:29','2026-10-05 08:32:12'),(24,'TCK-01024',8,NULL,5,'Alta de nuevo usuario de correo','Incidencia reportada por el cliente. Requiere diagnóstico y atención según SLA.','media','resuelto','whatsapp',5,1,'2026-10-01 08:12:49','2026-09-30 13:29:37','2026-09-29 08:12:49','2026-10-05 08:32:12'),(25,'TCK-01025',1,NULL,6,'Cambio de tóner','Incidencia reportada por el cliente. Requiere diagnóstico y atención según SLA.','media','cerrado','web',5,1,'2026-09-05 01:18:24','2026-09-04 19:32:48','2026-09-03 01:18:24','2026-10-05 08:32:12'),(26,'TCK-01026',6,NULL,6,'Cambio de tóner','Incidencia reportada por el cliente. Requiere diagnóstico y atención según SLA.','alta','resuelto','correo',6,1,'2026-08-19 02:31:52','2026-08-18 19:34:16','2026-08-18 02:31:52','2026-10-05 08:32:12'),(27,'TCK-01027',3,NULL,5,'No puedo recibir correos','Incidencia reportada por el cliente. Requiere diagnóstico y atención según SLA.','media','cerrado','presencial',6,1,'2026-09-29 22:55:19','2026-09-29 14:16:55','2026-09-27 22:55:19','2026-10-05 08:32:12'),(28,'TCK-01028',1,NULL,3,'Configurar VPN para trabajo remoto','Incidencia reportada por el cliente. Requiere diagnóstico y atención según SLA.','media','cerrado','telefono',3,1,'2026-06-16 01:18:40','2026-06-14 14:16:16','2026-06-14 01:18:40','2026-10-05 08:32:12'),(29,'TCK-01029',1,NULL,5,'No puedo recibir correos','Incidencia reportada por el cliente. Requiere diagnóstico y atención según SLA.','media','cerrado','whatsapp',6,1,'2026-09-28 23:53:09','2026-09-27 21:29:09','2026-09-26 23:53:09','2026-10-05 08:32:12'),(30,'TCK-01030',5,NULL,1,'Laptop no enciende tras corte de energía','Incidencia reportada por el cliente. Requiere diagnóstico y atención según SLA.','media','cerrado','presencial',4,1,'2026-07-30 06:00:02','2026-07-30 08:52:50','2026-07-28 06:00:02','2026-10-05 08:32:12'),(31,'TCK-01031',3,NULL,5,'Alta de nuevo usuario de correo','Incidencia reportada por el cliente. Requiere diagnóstico y atención según SLA.','critica','cerrado','whatsapp',6,1,'2026-04-22 13:53:18','2026-04-22 16:02:54','2026-04-22 05:53:18','2026-10-05 08:32:12'),(32,'TCK-01032',4,NULL,4,'Alerta de temperatura en rack','Incidencia reportada por el cliente. Requiere diagnóstico y atención según SLA.','critica','cerrado','web',4,1,'2026-09-16 15:23:45','2026-09-16 09:33:21','2026-09-16 07:23:45','2026-10-05 08:32:12'),(33,'TCK-01033',8,NULL,6,'Cambio de tóner','Incidencia reportada por el cliente. Requiere diagnóstico y atención según SLA.','media','cerrado','telefono',4,1,'2026-09-17 05:55:59','2026-09-16 05:27:11','2026-09-15 05:55:59','2026-10-05 08:32:12'),(34,'TCK-01034',4,NULL,4,'Respaldo nocturno falló','Incidencia reportada por el cliente. Requiere diagnóstico y atención según SLA.','alta','cerrado','telefono',4,1,'2026-05-01 06:49:14','2026-04-30 22:39:38','2026-04-30 06:49:14','2026-10-05 08:32:12'),(35,'TCK-01035',8,NULL,2,'Instalación de Office 365','Incidencia reportada por el cliente. Requiere diagnóstico y atención según SLA.','media','cerrado','correo',3,1,'2026-04-12 01:38:57','2026-04-11 16:02:57','2026-04-10 01:38:57','2026-10-05 08:32:12'),(36,'TCK-01036',2,NULL,3,'Configurar VPN para trabajo remoto','Incidencia reportada por el cliente. Requiere diagnóstico y atención según SLA.','alta','cerrado','presencial',5,1,'2026-05-05 23:53:37','2026-05-05 09:58:25','2026-05-04 23:53:37','2026-10-05 08:32:12'),(37,'TCK-01037',4,NULL,7,'Bloqueo de cuenta por intentos fallidos','Incidencia reportada por el cliente. Requiere diagnóstico y atención según SLA.','alta','cerrado','correo',6,1,'2026-09-04 02:01:40','2026-09-03 18:06:28','2026-09-03 02:01:40','2026-10-05 08:32:12'),(38,'TCK-01038',8,NULL,1,'Pantalla con líneas verticales','Incidencia reportada por el cliente. Requiere diagnóstico y atención según SLA.','baja','resuelto','presencial',5,1,'2026-09-21 06:10:02','2026-09-22 00:10:02','2026-09-18 06:10:02','2026-10-05 08:32:12'),(39,'TCK-01039',3,NULL,7,'Posible correo de phishing recibido','Incidencia reportada por el cliente. Requiere diagnóstico y atención según SLA.','critica','cerrado','web',6,1,'2026-04-13 07:15:31','2026-04-13 02:46:43','2026-04-12 23:15:31','2026-10-05 08:32:12'),(40,'TCK-01040',2,NULL,1,'Reemplazo de disco duro por SSD','Incidencia reportada por el cliente. Requiere diagnóstico y atención según SLA.','critica','cerrado','presencial',3,1,'2026-09-18 07:45:50','2026-09-18 07:21:50','2026-09-17 23:45:50','2026-10-05 08:32:12'),(41,'TCK-01041',5,NULL,3,'Intermitencia en WiFi de recepción','Incidencia reportada por el cliente. Requiere diagnóstico y atención según SLA.','alta','cerrado','web',5,1,'2026-09-19 00:15:57','2026-09-18 11:03:57','2026-09-18 00:15:57','2026-10-05 08:32:12'),(42,'TCK-01042',2,NULL,1,'Laptop no enciende tras corte de energía','Incidencia reportada por el cliente. Requiere diagnóstico y atención según SLA.','media','resuelto','presencial',4,1,'2026-06-18 06:14:50','2026-06-17 07:12:26','2026-06-16 06:14:50','2026-10-05 08:32:12'),(43,'TCK-01043',1,NULL,8,'Anexos sin tono en oficina','Incidencia reportada por el cliente. Requiere diagnóstico y atención según SLA.','baja','cerrado','telefono',5,1,'2026-09-06 00:24:14','2026-09-04 23:55:26','2026-09-03 00:24:14','2026-10-05 08:32:12'),(44,'TCK-01044',6,NULL,6,'Atasco constante de papel','Incidencia reportada por el cliente. Requiere diagnóstico y atención según SLA.','alta','cerrado','whatsapp',6,1,'2026-09-03 23:32:01','2026-09-03 08:24:48','2026-09-02 23:32:01','2026-10-05 08:32:12'),(45,'TCK-01045',5,NULL,7,'Posible correo de phishing recibido','Incidencia reportada por el cliente. Requiere diagnóstico y atención según SLA.','alta','cerrado','whatsapp',5,1,'2026-07-01 08:06:47','2026-06-30 22:01:58','2026-06-30 08:06:47','2026-10-05 08:32:12'),(46,'TCK-01046',2,NULL,2,'Excel se cierra al abrir archivos grandes','Incidencia reportada por el cliente. Requiere diagnóstico y atención según SLA.','media','cerrado','presencial',5,1,'2026-04-17 21:43:40','2026-04-17 06:22:04','2026-04-15 21:43:40','2026-10-05 08:32:12'),(47,'TCK-01047',7,NULL,5,'Restablecer contraseña de dominio','Incidencia reportada por el cliente. Requiere diagnóstico y atención según SLA.','baja','cerrado','presencial',3,1,'2026-05-17 04:02:56','2026-05-15 10:17:20','2026-05-14 04:02:56','2026-10-05 08:32:12'),(48,'TCK-01048',2,NULL,4,'Respaldo nocturno falló','Incidencia reportada por el cliente. Requiere diagnóstico y atención según SLA.','media','cerrado','presencial',4,1,'2026-05-28 05:48:56','2026-05-29 06:46:32','2026-05-26 05:48:56','2026-10-05 08:32:12'),(49,'TCK-01049',6,NULL,6,'Impresora no imprime en red','Incidencia reportada por el cliente. Requiere diagnóstico y atención según SLA.','baja','resuelto','correo',6,1,'2026-07-01 06:51:49','2026-06-30 21:30:13','2026-06-28 06:51:49','2026-10-05 08:32:12'),(50,'TCK-01050',2,NULL,1,'Laptop no enciende tras corte de energía','Incidencia reportada por el cliente. Requiere diagnóstico y atención según SLA.','media','cerrado','telefono',3,1,'2026-06-03 22:17:12','2026-06-03 05:29:12','2026-06-01 22:17:12','2026-10-05 08:32:12'),(51,'TCK-01051',7,NULL,6,'Cambio de tóner','Incidencia reportada por el cliente. Requiere diagnóstico y atención según SLA.','critica','cerrado','correo',3,1,'2026-04-19 15:34:48','2026-04-19 10:22:48','2026-04-19 07:34:48','2026-10-05 08:32:12'),(52,'TCK-01052',2,NULL,4,'Alerta de temperatura en rack','Incidencia reportada por el cliente. Requiere diagnóstico y atención según SLA.','baja','cerrado','presencial',4,1,'2026-08-09 05:34:02','2026-08-08 18:02:50','2026-08-06 05:34:02','2026-10-05 08:32:12'),(53,'TCK-01053',5,NULL,7,'Bloqueo de cuenta por intentos fallidos','Incidencia reportada por el cliente. Requiere diagnóstico y atención según SLA.','media','cerrado','presencial',4,1,'2026-07-25 03:25:59','2026-07-25 09:40:22','2026-07-23 03:25:59','2026-10-05 08:32:12'),(54,'TCK-01054',5,NULL,6,'Cambio de tóner','Incidencia reportada por el cliente. Requiere diagnóstico y atención según SLA.','critica','resuelto','telefono',3,1,'2026-10-05 16:19:38','2026-10-05 08:22:12','2026-10-05 08:19:38','2026-10-05 08:32:12'),(55,'TCK-01055',5,NULL,3,'Sin internet en el segundo piso','Incidencia reportada por el cliente. Requiere diagnóstico y atención según SLA.','media','cerrado','correo',6,1,'2026-09-14 21:44:10','2026-09-14 02:32:09','2026-09-12 21:44:10','2026-10-05 08:32:12'),(56,'TCK-01056',8,NULL,2,'Instalación de Office 365','Incidencia reportada por el cliente. Requiere diagnóstico y atención según SLA.','critica','cerrado','web',5,1,'2026-05-31 16:01:52','2026-05-31 14:11:28','2026-05-31 08:01:52','2026-10-05 08:32:12'),(57,'TCK-01057',4,NULL,4,'Servidor de archivos sin espacio','Incidencia reportada por el cliente. Requiere diagnóstico y atención según SLA.','critica','cerrado','telefono',4,1,'2026-06-07 08:56:35','2026-06-07 06:32:35','2026-06-07 00:56:35','2026-10-05 08:32:12'),(58,'TCK-01058',3,NULL,3,'Intermitencia en WiFi de recepción','Incidencia reportada por el cliente. Requiere diagnóstico y atención según SLA.','alta','cerrado','presencial',6,1,'2026-06-11 07:15:19','2026-06-11 04:51:19','2026-06-10 07:15:19','2026-10-05 08:32:12'),(59,'TCK-01059',6,NULL,4,'Respaldo nocturno falló','Incidencia reportada por el cliente. Requiere diagnóstico y atención según SLA.','baja','cerrado','whatsapp',5,1,'2026-08-15 06:09:56','2026-08-14 10:43:32','2026-08-12 06:09:56','2026-10-05 08:32:12'),(60,'TCK-01060',3,NULL,2,'Sistema ERP muy lento','Incidencia reportada por el cliente. Requiere diagnóstico y atención según SLA.','media','cerrado','presencial',4,1,'2026-05-25 02:54:12','2026-05-24 18:44:36','2026-05-23 02:54:12','2026-10-05 08:32:12'),(61,'TCK-01061',7,NULL,2,'Instalación de Office 365','Incidencia reportada por el cliente. Requiere diagnóstico y atención según SLA.','critica','cerrado','telefono',3,1,'2026-06-02 14:11:25','2026-06-02 09:42:37','2026-06-02 06:11:25','2026-10-05 08:32:12'),(62,'TCK-01062',1,NULL,3,'Sin internet en el segundo piso','Incidencia reportada por el cliente. Requiere diagnóstico y atención según SLA.','critica','cerrado','presencial',3,1,'2026-08-17 15:36:24','2026-08-17 13:50:48','2026-08-17 07:36:24','2026-10-05 08:32:12'),(63,'TCK-01063',7,NULL,7,'Bloqueo de cuenta por intentos fallidos','Incidencia reportada por el cliente. Requiere diagnóstico y atención según SLA.','critica','cerrado','web',5,1,'2026-08-18 06:46:37','2026-08-18 05:20:13','2026-08-17 22:46:37','2026-10-05 08:32:12'),(64,'TCK-01064',2,NULL,7,'Bloqueo de cuenta por intentos fallidos','Incidencia reportada por el cliente. Requiere diagnóstico y atención según SLA.','media','cerrado','whatsapp',5,1,'2026-09-13 07:12:56','2026-09-12 07:41:44','2026-09-11 07:12:56','2026-10-05 08:32:12'),(65,'TCK-01065',2,NULL,1,'Pantalla con líneas verticales','Incidencia reportada por el cliente. Requiere diagnóstico y atención según SLA.','media','en_proceso','web',6,1,'2026-10-05 04:23:22',NULL,'2026-10-03 04:23:22','2026-10-05 08:32:12'),(66,'TCK-01066',7,NULL,7,'Posible correo de phishing recibido','Incidencia reportada por el cliente. Requiere diagnóstico y atención según SLA.','media','cerrado','presencial',6,1,'2026-08-10 04:51:04','2026-08-09 17:19:52','2026-08-08 04:51:04','2026-10-05 08:32:12'),(67,'TCK-01067',6,NULL,5,'Restablecer contraseña de dominio','Incidencia reportada por el cliente. Requiere diagnóstico y atención según SLA.','media','abierto','web',5,1,'2026-10-02 03:27:24',NULL,'2026-09-30 03:27:24','2026-10-05 08:32:12'),(68,'TCK-01068',6,NULL,4,'Alerta de temperatura en rack','Incidencia reportada por el cliente. Requiere diagnóstico y atención según SLA.','media','cerrado','presencial',5,1,'2026-04-30 02:20:26','2026-04-29 14:49:14','2026-04-28 02:20:26','2026-10-05 08:32:12'),(69,'TCK-01069',8,NULL,2,'Instalación de Office 365','Incidencia reportada por el cliente. Requiere diagnóstico y atención según SLA.','baja','cerrado','web',3,1,'2026-05-23 05:52:32','2026-05-21 14:59:44','2026-05-20 05:52:32','2026-10-05 08:32:12'),(70,'TCK-01070',5,NULL,1,'Pantalla con líneas verticales','Incidencia reportada por el cliente. Requiere diagnóstico y atención según SLA.','alta','cerrado','telefono',3,1,'2026-05-23 22:26:22','2026-05-23 12:07:10','2026-05-22 22:26:22','2026-10-05 08:32:12'),(71,'TCK-01071',8,NULL,4,'Alerta de temperatura en rack','Incidencia reportada por el cliente. Requiere diagnóstico y atención según SLA.','media','cerrado','correo',6,1,'2026-07-05 03:37:49','2026-07-04 08:54:37','2026-07-03 03:37:49','2026-10-05 08:32:12'),(72,'TCK-01072',5,NULL,5,'Alta de nuevo usuario de correo','Incidencia reportada por el cliente. Requiere diagnóstico y atención según SLA.','alta','cerrado','correo',6,1,'2026-09-22 07:33:59','2026-09-22 21:57:59','2026-09-21 07:33:59','2026-10-05 08:32:12'),(73,'TCK-01073',3,NULL,1,'Reemplazo de disco duro por SSD','Incidencia reportada por el cliente. Requiere diagnóstico y atención según SLA.','media','cerrado','web',4,1,'2026-09-23 23:23:28','2026-09-22 16:40:16','2026-09-21 23:23:28','2026-10-05 08:32:12'),(74,'TCK-01074',8,NULL,5,'No puedo recibir correos','Incidencia reportada por el cliente. Requiere diagnóstico y atención según SLA.','media','resuelto','telefono',5,1,'2026-10-07 01:35:28','2026-10-05 08:22:12','2026-10-05 01:35:28','2026-10-05 08:32:12'),(75,'TCK-01075',5,NULL,4,'Respaldo nocturno falló','Incidencia reportada por el cliente. Requiere diagnóstico y atención según SLA.','critica','en_proceso','correo',6,1,'2026-10-05 09:17:27',NULL,'2026-10-05 01:17:27','2026-10-05 08:32:12'),(76,'TCK-01076',1,NULL,7,'Bloqueo de cuenta por intentos fallidos','Incidencia reportada por el cliente. Requiere diagnóstico y atención según SLA.','baja','cerrado','correo',5,1,'2026-08-04 05:03:31','2026-08-03 17:32:19','2026-08-01 05:03:31','2026-10-05 08:32:12'),(77,'TCK-01077',7,NULL,7,'Posible correo de phishing recibido','Incidencia reportada por el cliente. Requiere diagnóstico y atención según SLA.','critica','cerrado','whatsapp',4,1,'2026-09-24 14:19:16','2026-09-24 10:28:52','2026-09-24 06:19:16','2026-10-05 08:32:12'),(78,'TCK-01078',3,NULL,6,'Impresora no imprime en red','Incidencia reportada por el cliente. Requiere diagnóstico y atención según SLA.','media','cerrado','whatsapp',4,1,'2026-08-29 21:42:20','2026-08-29 06:49:31','2026-08-27 21:42:20','2026-10-05 08:32:12'),(79,'TCK-01079',2,NULL,5,'Restablecer contraseña de dominio','Incidencia reportada por el cliente. Requiere diagnóstico y atención según SLA.','alta','cerrado','presencial',4,1,'2026-09-07 08:05:59','2026-09-06 19:22:47','2026-09-06 08:05:59','2026-10-05 08:32:12'),(80,'TCK-01080',3,NULL,3,'Configurar VPN para trabajo remoto','Incidencia reportada por el cliente. Requiere diagnóstico y atención según SLA.','baja','cerrado','presencial',6,1,'2026-06-29 06:37:58','2026-06-27 02:04:22','2026-06-26 06:37:58','2026-10-05 08:32:12'),(81,'TCK-01081',5,NULL,8,'Anexos sin tono en oficina','Incidencia reportada por el cliente. Requiere diagnóstico y atención según SLA.','baja','cerrado','telefono',5,1,'2026-08-06 07:07:21','2026-08-05 09:31:21','2026-08-03 07:07:21','2026-10-05 08:32:12'),(82,'TCK-01082',8,NULL,8,'Anexos sin tono en oficina','Incidencia reportada por el cliente. Requiere diagnóstico y atención según SLA.','media','cerrado','whatsapp',5,1,'2026-06-15 23:59:43','2026-06-15 05:16:31','2026-06-13 23:59:43','2026-10-05 08:32:12'),(83,'TCK-01083',5,NULL,6,'Cambio de tóner','Incidencia reportada por el cliente. Requiere diagnóstico y atención según SLA.','alta','cerrado','correo',6,1,'2026-08-01 01:15:58','2026-07-31 12:03:58','2026-07-31 01:15:58','2026-10-05 08:32:12'),(84,'TCK-01084',8,NULL,2,'Instalación de Office 365','Incidencia reportada por el cliente. Requiere diagnóstico y atención según SLA.','media','cerrado','presencial',6,1,'2026-04-24 22:38:47','2026-04-24 05:50:47','2026-04-22 22:38:47','2026-10-05 08:32:12'),(85,'TCK-01085',5,NULL,7,'Posible correo de phishing recibido','Incidencia reportada por el cliente. Requiere diagnóstico y atención según SLA.','media','cerrado','whatsapp',5,1,'2026-08-04 22:44:04','2026-08-04 00:39:16','2026-08-02 22:44:04','2026-10-05 08:32:12'),(86,'TCK-01086',5,NULL,4,'Respaldo nocturno falló','Incidencia reportada por el cliente. Requiere diagnóstico y atención según SLA.','media','resuelto','web',6,1,'2026-10-06 23:44:49','2026-10-05 08:22:12','2026-10-04 23:44:49','2026-10-05 08:32:12'),(87,'TCK-01087',1,NULL,6,'Atasco constante de papel','Incidencia reportada por el cliente. Requiere diagnóstico y atención según SLA.','alta','cerrado','web',4,1,'2026-07-06 22:00:50','2026-07-06 11:12:50','2026-07-05 22:00:50','2026-10-05 08:32:12'),(88,'TCK-01088',7,NULL,4,'Alerta de temperatura en rack','Incidencia reportada por el cliente. Requiere diagnóstico y atención según SLA.','media','resuelto','whatsapp',6,1,'2026-09-16 21:35:01','2026-09-16 05:44:37','2026-09-14 21:35:01','2026-10-05 08:32:12'),(89,'TCK-01089',1,NULL,4,'Respaldo nocturno falló','Incidencia reportada por el cliente. Requiere diagnóstico y atención según SLA.','alta','cerrado','correo',5,1,'2026-09-16 21:29:40','2026-09-17 03:15:16','2026-09-15 21:29:40','2026-10-05 08:32:12'),(90,'TCK-01090',2,NULL,1,'Laptop no enciende tras corte de energía','Incidencia reportada por el cliente. Requiere diagnóstico y atención según SLA.','media','cerrado','whatsapp',5,1,'2026-09-20 22:05:39','2026-09-20 07:41:38','2026-09-18 22:05:39','2026-10-05 08:32:12'),(91,'TCK-01091',7,NULL,6,'Cambio de tóner','Incidencia reportada por el cliente. Requiere diagnóstico y atención según SLA.','critica','cerrado','web',5,1,'2026-09-09 16:30:16','2026-09-09 12:59:04','2026-09-09 08:30:16','2026-10-05 08:32:12'),(92,'TCK-01092',6,NULL,4,'Respaldo nocturno falló','Incidencia reportada por el cliente. Requiere diagnóstico y atención según SLA.','media','cerrado','telefono',5,1,'2026-06-01 02:09:04','2026-05-31 00:42:40','2026-05-30 02:09:04','2026-10-05 08:32:12'),(93,'TCK-01093',2,NULL,5,'No puedo recibir correos','Incidencia reportada por el cliente. Requiere diagnóstico y atención según SLA.','critica','abierto','correo',4,1,'2026-10-04 07:20:49',NULL,'2026-10-03 23:20:49','2026-10-05 08:32:12'),(94,'TCK-01094',5,NULL,3,'Intermitencia en WiFi de recepción','Incidencia reportada por el cliente. Requiere diagnóstico y atención según SLA.','media','cerrado','presencial',4,1,'2026-07-10 03:14:24','2026-07-08 20:59:59','2026-07-08 03:14:24','2026-10-05 08:32:12'),(95,'TCK-01095',1,NULL,2,'Licencia de antivirus vencida','Incidencia reportada por el cliente. Requiere diagnóstico y atención según SLA.','media','resuelto','presencial',3,1,'2026-10-03 22:30:31','2026-10-02 22:30:31','2026-10-01 22:30:31','2026-10-05 08:32:12'),(96,'TCK-01096',3,NULL,6,'Cambio de tóner','Incidencia reportada por el cliente. Requiere diagnóstico y atención según SLA.','baja','cerrado','telefono',6,1,'2026-08-07 02:51:32','2026-08-05 06:56:20','2026-08-04 02:51:32','2026-10-05 08:32:12'),(97,'TCK-01097',2,NULL,6,'Cambio de tóner','Incidencia reportada por el cliente. Requiere diagnóstico y atención según SLA.','critica','cerrado','presencial',5,1,'2026-07-29 09:25:05','2026-07-29 08:56:17','2026-07-29 01:25:05','2026-10-05 08:32:12'),(98,'TCK-01098',3,NULL,2,'Licencia de antivirus vencida','Incidencia reportada por el cliente. Requiere diagnóstico y atención según SLA.','alta','abierto','correo',5,1,'2026-10-05 23:37:33',NULL,'2026-10-04 23:37:33','2026-10-05 08:32:12'),(99,'TCK-01099',2,NULL,2,'Instalación de Office 365','Incidencia reportada por el cliente. Requiere diagnóstico y atención según SLA.','media','cerrado','telefono',4,1,'2026-05-03 23:09:55','2026-05-03 20:17:07','2026-05-01 23:09:55','2026-10-05 08:32:12'),(100,'TCK-01100',4,NULL,5,'Restablecer contraseña de dominio','Incidencia reportada por el cliente. Requiere diagnóstico y atención según SLA.','alta','cerrado','correo',4,1,'2026-07-25 01:13:21','2026-07-24 10:06:08','2026-07-24 01:13:21','2026-10-05 08:32:12'),(101,'TCK-01101',1,NULL,2,'Instalación de Office 365','Incidencia reportada por el cliente. Requiere diagnóstico y atención según SLA.','alta','cerrado','telefono',4,1,'2026-08-16 01:51:31','2026-08-15 22:01:07','2026-08-15 01:51:31','2026-10-05 08:32:12'),(102,'TCK-01102',3,NULL,7,'Posible correo de phishing recibido','Incidencia reportada por el cliente. Requiere diagnóstico y atención según SLA.','media','cerrado','web',6,1,'2026-10-03 03:14:13','2026-10-01 16:40:37','2026-10-01 03:14:13','2026-10-05 08:32:12'),(103,'TCK-01103',4,NULL,4,'Alerta de temperatura en rack','Incidencia reportada por el cliente. Requiere diagnóstico y atención según SLA.','critica','resuelto','presencial',3,1,'2026-06-16 11:25:55','2026-06-16 08:23:31','2026-06-16 03:25:55','2026-10-05 08:32:12'),(104,'TCK-01104',3,NULL,6,'Cambio de tóner','Incidencia reportada por el cliente. Requiere diagnóstico y atención según SLA.','media','cerrado','whatsapp',6,1,'2026-07-15 07:28:34','2026-07-14 16:06:58','2026-07-13 07:28:34','2026-10-05 08:32:12'),(105,'TCK-01105',3,NULL,5,'Alta de nuevo usuario de correo','Incidencia reportada por el cliente. Requiere diagnóstico y atención según SLA.','media','resuelto','telefono',3,1,'2026-08-05 23:44:20','2026-08-06 14:37:08','2026-08-03 23:44:20','2026-10-05 08:32:12'),(106,'TCK-01106',4,NULL,6,'Impresora no imprime en red','Incidencia reportada por el cliente. Requiere diagnóstico y atención según SLA.','alta','cerrado','whatsapp',6,1,'2026-09-09 22:25:44','2026-09-09 09:13:44','2026-09-08 22:25:44','2026-10-05 08:32:12'),(107,'TCK-01107',3,NULL,6,'Cambio de tóner','Incidencia reportada por el cliente. Requiere diagnóstico y atención según SLA.','critica','cerrado','web',5,1,'2026-06-11 09:24:36','2026-06-11 04:31:48','2026-06-11 01:24:36','2026-10-05 08:32:12'),(108,'TCK-01108',1,NULL,5,'Restablecer contraseña de dominio','Incidencia reportada por el cliente. Requiere diagnóstico y atención según SLA.','baja','en_proceso','telefono',4,1,'2026-10-02 21:34:49',NULL,'2026-09-29 21:34:49','2026-10-05 08:32:12'),(109,'TCK-01109',3,NULL,4,'Alerta de temperatura en rack','Incidencia reportada por el cliente. Requiere diagnóstico y atención según SLA.','baja','resuelto','web',3,1,'2026-09-01 22:30:03','2026-09-01 00:54:03','2026-08-29 22:30:03','2026-10-05 08:32:12'),(110,'TCK-01110',3,NULL,5,'No puedo recibir correos','Incidencia reportada por el cliente. Requiere diagnóstico y atención según SLA.','critica','abierto','whatsapp',6,1,'2026-09-29 13:36:34',NULL,'2026-09-29 05:36:34','2026-10-05 08:32:12'),(111,'TCK-01111',4,NULL,1,'Reemplazo de disco duro por SSD','Incidencia reportada por el cliente. Requiere diagnóstico y atención según SLA.','media','cerrado','telefono',6,1,'2026-05-23 23:28:55','2026-05-22 19:38:31','2026-05-21 23:28:55','2026-10-05 08:32:12'),(112,'TCK-01112',5,NULL,5,'No puedo recibir correos','Incidencia reportada por el cliente. Requiere diagnóstico y atención según SLA.','critica','cerrado','telefono',6,1,'2026-07-15 15:07:41','2026-07-15 12:58:05','2026-07-15 07:07:41','2026-10-05 08:32:12'),(113,'TCK-01113',8,NULL,4,'Servidor de archivos sin espacio','Incidencia reportada por el cliente. Requiere diagnóstico y atención según SLA.','alta','en_proceso','telefono',6,1,'2026-05-05 02:00:18',NULL,'2026-05-04 02:00:18','2026-10-05 08:32:12'),(114,'TCK-01114',5,NULL,2,'Sistema ERP muy lento','Incidencia reportada por el cliente. Requiere diagnóstico y atención según SLA.','media','resuelto','web',6,1,'2026-08-10 04:02:38','2026-08-09 13:09:49','2026-08-08 04:02:38','2026-10-05 08:32:12'),(115,'TCK-01115',4,NULL,3,'Intermitencia en WiFi de recepción','Incidencia reportada por el cliente. Requiere diagnóstico y atención según SLA.','alta','abierto','correo',5,1,'2026-10-06 01:38:18',NULL,'2026-10-05 01:38:18','2026-10-05 08:32:12'),(116,'TCK-01116',6,NULL,2,'Sistema ERP muy lento','Incidencia reportada por el cliente. Requiere diagnóstico y atención según SLA.','media','cerrado','correo',4,1,'2026-07-29 07:59:07','2026-07-28 18:03:55','2026-07-27 07:59:07','2026-10-05 08:32:12'),(117,'TCK-01117',4,NULL,2,'Sistema ERP muy lento','Incidencia reportada por el cliente. Requiere diagnóstico y atención según SLA.','critica','cerrado','correo',6,1,'2026-06-01 10:44:49','2026-06-01 07:32:49','2026-06-01 02:44:49','2026-10-05 08:32:12'),(118,'TCK-01118',5,NULL,3,'Sin internet en el segundo piso','Incidencia reportada por el cliente. Requiere diagnóstico y atención según SLA.','alta','cerrado','whatsapp',5,1,'2026-09-17 00:40:31','2026-09-16 13:23:43','2026-09-16 00:40:31','2026-10-05 08:32:12'),(119,'TCK-01119',2,NULL,4,'Alerta de temperatura en rack','Incidencia reportada por el cliente. Requiere diagnóstico y atención según SLA.','media','cerrado','telefono',4,1,'2026-06-02 05:50:32','2026-06-01 13:02:32','2026-05-31 05:50:32','2026-10-05 08:32:12'),(120,'TCK-01120',4,NULL,3,'Intermitencia en WiFi de recepción','Incidencia reportada por el cliente. Requiere diagnóstico y atención según SLA.','media','cerrado','web',4,1,'2026-07-20 05:15:49','2026-07-18 22:03:48','2026-07-18 05:15:49','2026-10-05 08:32:12'),(121,'TCK-01121',4,NULL,6,'Cambio de tóner','Incidencia reportada por el cliente. Requiere diagnóstico y atención según SLA.','critica','cerrado','telefono',5,1,'2026-07-05 11:58:51','2026-07-05 09:49:15','2026-07-05 03:58:51','2026-10-05 08:32:12'),(122,'TCK-01122',4,NULL,2,'Licencia de antivirus vencida','Incidencia reportada por el cliente. Requiere diagnóstico y atención según SLA.','critica','cerrado','correo',3,1,'2026-04-16 07:06:46','2026-04-16 05:45:10','2026-04-15 23:06:46','2026-10-05 08:32:12'),(123,'TCK-01123',3,NULL,7,'Posible correo de phishing recibido','Incidencia reportada por el cliente. Requiere diagnóstico y atención según SLA.','critica','cerrado','whatsapp',5,1,'2026-05-13 06:38:36','2026-05-13 11:17:00','2026-05-12 22:38:36','2026-10-05 08:32:12'),(124,'TCK-01124',6,NULL,8,'Anexos sin tono en oficina','Incidencia reportada por el cliente. Requiere diagnóstico y atención según SLA.','alta','cerrado','web',5,1,'2026-09-20 01:11:42','2026-09-19 17:30:54','2026-09-19 01:11:42','2026-10-05 08:32:12'),(125,'TCK-01125',4,NULL,6,'Impresora no imprime en red','Incidencia reportada por el cliente. Requiere diagnóstico y atención según SLA.','alta','resuelto','whatsapp',4,1,'2026-07-02 06:01:15','2026-07-02 02:10:51','2026-07-01 06:01:15','2026-10-05 08:32:12'),(126,'TCK-01126',2,NULL,1,'Pantalla con líneas verticales','Incidencia reportada por el cliente. Requiere diagnóstico y atención según SLA.','alta','resuelto','correo',5,1,'2026-04-26 00:40:58','2026-04-26 12:12:09','2026-04-25 00:40:58','2026-10-05 08:32:12'),(127,'TCK-01127',5,NULL,5,'Alta de nuevo usuario de correo','Incidencia reportada por el cliente. Requiere diagnóstico y atención según SLA.','alta','cerrado','web',5,1,'2026-07-12 05:07:03','2026-07-11 21:11:51','2026-07-11 05:07:03','2026-10-05 08:32:12'),(128,'TCK-01128',6,NULL,8,'Configurar central IP','Incidencia reportada por el cliente. Requiere diagnóstico y atención según SLA.','alta','abierto','telefono',3,1,'2026-10-04 07:18:11',NULL,'2026-10-03 07:18:11','2026-10-05 08:32:12'),(129,'TCK-01129',6,NULL,5,'Restablecer contraseña de dominio','Incidencia reportada por el cliente. Requiere diagnóstico y atención según SLA.','alta','resuelto','web',5,1,'2026-09-27 04:26:31','2026-09-27 01:19:19','2026-09-26 04:26:31','2026-10-05 08:32:12'),(130,'TCK-01130',5,NULL,1,'Reemplazo de disco duro por SSD','Incidencia reportada por el cliente. Requiere diagnóstico y atención según SLA.','media','cerrado','web',6,1,'2026-05-08 06:54:38','2026-05-08 02:06:38','2026-05-06 06:54:38','2026-10-05 08:32:12'),(131,'TCK-01131',1,NULL,8,'Anexos sin tono en oficina','Incidencia reportada por el cliente. Requiere diagnóstico y atención según SLA.','alta','cerrado','whatsapp',5,1,'2026-09-29 01:21:13','2026-09-28 17:40:25','2026-09-28 01:21:13','2026-10-05 08:32:12'),(132,'TCK-01132',2,NULL,1,'Pantalla con líneas verticales','Incidencia reportada por el cliente. Requiere diagnóstico y atención según SLA.','baja','cerrado','presencial',4,1,'2026-06-18 04:29:19','2026-06-18 23:55:43','2026-06-15 04:29:19','2026-10-05 08:32:12'),(133,'TCK-01133',8,NULL,7,'Bloqueo de cuenta por intentos fallidos','Incidencia reportada por el cliente. Requiere diagnóstico y atención según SLA.','baja','cerrado','correo',6,1,'2026-08-02 06:01:26','2026-08-01 12:01:26','2026-07-30 06:01:26','2026-10-05 08:32:12'),(134,'TCK-01134',4,NULL,7,'Posible correo de phishing recibido','Incidencia reportada por el cliente. Requiere diagnóstico y atención según SLA.','critica','cerrado','presencial',3,1,'2026-07-11 11:52:37','2026-07-11 11:28:37','2026-07-11 03:52:37','2026-10-05 08:32:12'),(135,'TCK-01135',7,NULL,6,'Impresora no imprime en red','Incidencia reportada por el cliente. Requiere diagnóstico y atención según SLA.','alta','resuelto','correo',3,1,'2026-04-28 00:46:12','2026-04-27 13:58:12','2026-04-27 00:46:12','2026-10-05 08:32:12'),(136,'TCK-01136',8,NULL,3,'Sin internet en el segundo piso','Incidencia reportada por el cliente. Requiere diagnóstico y atención según SLA.','alta','cerrado','whatsapp',6,1,'2026-08-30 07:50:50','2026-08-30 20:19:38','2026-08-29 07:50:50','2026-10-05 08:32:12'),(137,'TCK-01137',1,NULL,7,'Posible correo de phishing recibido','Incidencia reportada por el cliente. Requiere diagnóstico y atención según SLA.','alta','resuelto','presencial',4,1,'2026-09-28 03:53:07','2026-09-27 17:33:55','2026-09-27 03:53:07','2026-10-05 08:32:12'),(138,'TCK-01138',4,NULL,5,'No puedo recibir correos','Incidencia reportada por el cliente. Requiere diagnóstico y atención según SLA.','baja','cerrado','presencial',4,1,'2026-08-30 00:31:45','2026-08-28 21:10:09','2026-08-27 00:31:45','2026-10-05 08:32:12'),(139,'TCK-01139',1,NULL,1,'Pantalla con líneas verticales','Incidencia reportada por el cliente. Requiere diagnóstico y atención según SLA.','critica','cerrado','telefono',5,1,'2026-04-30 14:30:15','2026-04-30 10:20:39','2026-04-30 06:30:15','2026-10-05 08:32:12'),(140,'TCK-01140',8,NULL,7,'Posible correo de phishing recibido','Incidencia reportada por el cliente. Requiere diagnóstico y atención según SLA.','media','resuelto','web',3,1,'2026-07-10 01:40:03','2026-07-09 13:40:03','2026-07-08 01:40:03','2026-10-05 08:32:12'),(141,'TCK-01141',3,NULL,6,'Cambio de tóner','Incidencia reportada por el cliente. Requiere diagnóstico y atención según SLA.','critica','cerrado','telefono',3,1,'2026-08-20 05:30:42','2026-08-20 03:35:30','2026-08-19 21:30:42','2026-10-05 08:32:12'),(142,'TCK-01142',3,NULL,7,'Posible correo de phishing recibido','Incidencia reportada por el cliente. Requiere diagnóstico y atención según SLA.','alta','cerrado','whatsapp',3,1,'2026-05-03 06:22:43','2026-05-02 16:27:31','2026-05-02 06:22:43','2026-10-05 08:32:12'),(143,'TCK-01143',6,NULL,4,'Alerta de temperatura en rack','Incidencia reportada por el cliente. Requiere diagnóstico y atención según SLA.','media','resuelto','whatsapp',3,1,'2026-09-03 22:39:03','2026-09-02 18:19:51','2026-09-01 22:39:03','2026-10-05 08:32:12'),(144,'TCK-01144',3,NULL,8,'Anexos sin tono en oficina','Incidencia reportada por el cliente. Requiere diagnóstico y atención según SLA.','alta','cerrado','presencial',3,1,'2026-07-21 23:58:50','2026-07-22 05:44:26','2026-07-20 23:58:50','2026-10-05 08:32:12'),(145,'TCK-01145',1,NULL,6,'Atasco constante de papel','Incidencia reportada por el cliente. Requiere diagnóstico y atención según SLA.','media','cerrado','whatsapp',3,1,'2026-06-10 08:27:08','2026-06-09 03:39:08','2026-06-08 08:27:08','2026-10-05 08:32:12'),(146,'TCK-01146',5,NULL,3,'Sin internet en el segundo piso','Incidencia reportada por el cliente. Requiere diagnóstico y atención según SLA.','baja','cerrado','correo',3,1,'2026-08-29 07:57:08','2026-08-27 03:23:32','2026-08-26 07:57:08','2026-10-05 08:32:12'),(147,'TCK-01147',7,NULL,3,'Configurar VPN para trabajo remoto','Incidencia reportada por el cliente. Requiere diagnóstico y atención según SLA.','alta','cerrado','web',6,1,'2026-06-17 21:34:33','2026-06-17 08:22:33','2026-06-16 21:34:33','2026-10-05 08:32:12'),(148,'TCK-01148',1,NULL,2,'Instalación de Office 365','Incidencia reportada por el cliente. Requiere diagnóstico y atención según SLA.','media','cerrado','telefono',4,1,'2026-10-05 08:01:10','2026-10-05 08:22:12','2026-10-03 08:01:10','2026-10-05 08:32:12'),(149,'TCK-01149',7,NULL,3,'Sin internet en el segundo piso','Incidencia reportada por el cliente. Requiere diagnóstico y atención según SLA.','alta','cerrado','whatsapp',4,1,'2026-07-27 22:04:33','2026-07-28 02:09:21','2026-07-26 22:04:33','2026-10-05 08:32:12'),(150,'TCK-01150',6,NULL,2,'Licencia de antivirus vencida','Incidencia reportada por el cliente. Requiere diagnóstico y atención según SLA.','media','cerrado','telefono',3,1,'2026-08-22 06:43:38','2026-08-21 00:00:26','2026-08-20 06:43:38','2026-10-05 08:32:12'),(151,'TCK-01151',4,NULL,5,'Restablecer contraseña de dominio','Incidencia reportada por el cliente. Requiere diagnóstico y atención según SLA.','alta','cerrado','telefono',3,1,'2026-06-22 22:39:25','2026-06-22 12:49:01','2026-06-21 22:39:25','2026-10-05 08:32:12'),(152,'TCK-01152',6,NULL,1,'Reemplazo de disco duro por SSD','Incidencia reportada por el cliente. Requiere diagnóstico y atención según SLA.','alta','pendiente','telefono',3,1,'2026-10-03 07:45:53',NULL,'2026-10-02 07:45:53','2026-10-05 08:32:12'),(153,'TCK-01153',6,NULL,5,'Restablecer contraseña de dominio','Incidencia reportada por el cliente. Requiere diagnóstico y atención según SLA.','critica','cerrado','web',5,1,'2026-09-27 14:32:02','2026-09-27 08:56:02','2026-09-27 06:32:02','2026-10-05 08:32:12'),(154,'TCK-01154',3,NULL,6,'Impresora no imprime en red','Incidencia reportada por el cliente. Requiere diagnóstico y atención según SLA.','alta','cerrado','web',6,1,'2026-09-25 03:56:15','2026-09-24 13:32:15','2026-09-24 03:56:15','2026-10-05 08:32:12'),(155,'TCK-01155',1,NULL,5,'No puedo recibir correos','Incidencia reportada por el cliente. Requiere diagnóstico y atención según SLA.','critica','cerrado','web',4,1,'2026-05-30 13:16:21','2026-05-30 12:28:21','2026-05-30 05:16:21','2026-10-05 08:32:12'),(156,'TCK-01156',4,NULL,6,'Impresora no imprime en red','Incidencia reportada por el cliente. Requiere diagnóstico y atención según SLA.','alta','cerrado','whatsapp',3,1,'2026-08-10 03:59:54','2026-08-10 01:50:18','2026-08-09 03:59:54','2026-10-05 08:32:12'),(157,'TCK-01157',7,NULL,5,'Alta de nuevo usuario de correo','Incidencia reportada por el cliente. Requiere diagnóstico y atención según SLA.','alta','cerrado','web',6,1,'2026-05-16 00:32:19','2026-05-15 20:13:07','2026-05-15 00:32:19','2026-10-05 08:32:12'),(158,'TCK-01158',8,NULL,7,'Posible correo de phishing recibido','Incidencia reportada por el cliente. Requiere diagnóstico y atención según SLA.','critica','cerrado','presencial',5,1,'2026-08-05 12:02:37','2026-08-05 12:41:01','2026-08-05 04:02:37','2026-10-05 08:32:12'),(159,'TCK-01159',8,NULL,6,'Impresora no imprime en red','Incidencia reportada por el cliente. Requiere diagnóstico y atención según SLA.','alta','cerrado','telefono',3,1,'2026-09-29 05:55:14','2026-09-29 04:43:13','2026-09-28 05:55:14','2026-10-05 08:32:12'),(160,'TCK-01160',6,NULL,2,'Sistema ERP muy lento','Incidencia reportada por el cliente. Requiere diagnóstico y atención según SLA.','media','en_proceso','presencial',4,1,'2026-10-01 02:11:28',NULL,'2026-09-29 02:11:28','2026-10-05 08:32:12'),(161,'TCK-01161',7,NULL,3,'Sin internet en el segundo piso','Incidencia reportada por el cliente. Requiere diagnóstico y atención según SLA.','critica','resuelto','correo',4,1,'2026-09-25 08:22:42','2026-09-25 07:10:42','2026-09-25 00:22:42','2026-10-05 08:32:12'),(162,'TCK-01162',5,NULL,6,'Impresora no imprime en red','Incidencia reportada por el cliente. Requiere diagnóstico y atención según SLA.','baja','resuelto','whatsapp',5,1,'2026-06-27 07:10:20','2026-06-26 13:10:20','2026-06-24 07:10:20','2026-10-05 08:32:12'),(163,'TCK-01163',3,NULL,5,'Alta de nuevo usuario de correo','Incidencia reportada por el cliente. Requiere diagnóstico y atención según SLA.','media','cerrado','whatsapp',4,1,'2026-08-28 01:58:52','2026-08-26 20:42:04','2026-08-26 01:58:52','2026-10-05 08:32:12'),(164,'TCK-01164',1,NULL,8,'Anexos sin tono en oficina','Incidencia reportada por el cliente. Requiere diagnóstico y atención según SLA.','media','resuelto','web',6,1,'2026-06-28 06:56:09','2026-06-28 02:08:09','2026-06-26 06:56:09','2026-10-05 08:32:12'),(165,'TCK-01165',2,NULL,7,'Posible correo de phishing recibido','Incidencia reportada por el cliente. Requiere diagnóstico y atención según SLA.','alta','resuelto','presencial',3,1,'2026-04-30 06:07:21','2026-04-29 16:55:21','2026-04-29 06:07:21','2026-10-05 08:32:12'),(166,'TCK-01166',4,NULL,7,'Bloqueo de cuenta por intentos fallidos','Incidencia reportada por el cliente. Requiere diagnóstico y atención según SLA.','baja','cerrado','web',3,1,'2026-08-09 23:49:05','2026-08-10 21:25:05','2026-08-06 23:49:05','2026-10-05 08:32:12'),(167,'TCK-01167',4,NULL,8,'Configurar central IP','Incidencia reportada por el cliente. Requiere diagnóstico y atención según SLA.','alta','cerrado','web',5,1,'2026-05-18 06:09:06','2026-05-18 01:35:30','2026-05-17 06:09:06','2026-10-05 08:32:12'),(168,'TCK-01168',2,NULL,4,'Servidor de archivos sin espacio','Incidencia reportada por el cliente. Requiere diagnóstico y atención según SLA.','media','cerrado','whatsapp',4,1,'2026-09-23 08:14:43','2026-09-22 16:53:07','2026-09-21 08:14:43','2026-10-05 08:32:12'),(169,'TCK-01169',6,NULL,3,'Intermitencia en WiFi de recepción','Incidencia reportada por el cliente. Requiere diagnóstico y atención según SLA.','critica','cerrado','web',6,1,'2026-07-17 12:17:53','2026-07-17 06:41:53','2026-07-17 04:17:53','2026-10-05 08:32:12'),(170,'TCK-01170',6,NULL,8,'Anexos sin tono en oficina','Incidencia reportada por el cliente. Requiere diagnóstico y atención según SLA.','alta','cerrado','telefono',6,1,'2026-09-21 22:34:14','2026-09-21 13:12:38','2026-09-20 22:34:14','2026-10-05 08:32:12'),(171,'TCK-01171',8,NULL,4,'Alerta de temperatura en rack','Incidencia reportada por el cliente. Requiere diagnóstico y atención según SLA.','alta','cerrado','correo',3,1,'2026-06-20 00:14:05','2026-06-19 21:50:05','2026-06-19 00:14:05','2026-10-05 08:32:12'),(172,'TCK-01172',3,NULL,3,'Configurar VPN para trabajo remoto','Incidencia reportada por el cliente. Requiere diagnóstico y atención según SLA.','media','cerrado','web',3,1,'2026-09-29 00:34:24','2026-09-28 16:53:36','2026-09-27 00:34:24','2026-10-05 08:32:12'),(173,'TCK-01173',7,NULL,8,'Configurar central IP','Incidencia reportada por el cliente. Requiere diagnóstico y atención según SLA.','media','cerrado','web',6,1,'2026-09-22 03:45:03','2026-09-21 11:25:51','2026-09-20 03:45:03','2026-10-05 08:32:12'),(174,'TCK-01174',6,NULL,4,'Respaldo nocturno falló','Incidencia reportada por el cliente. Requiere diagnóstico y atención según SLA.','media','cerrado','correo',4,1,'2026-08-18 01:44:21','2026-08-18 06:03:33','2026-08-16 01:44:21','2026-10-05 08:32:12'),(175,'TCK-01175',7,NULL,8,'Anexos sin tono en oficina','Incidencia reportada por el cliente. Requiere diagnóstico y atención según SLA.','critica','cerrado','presencial',5,1,'2026-07-13 14:04:21','2026-07-13 11:21:09','2026-07-13 06:04:21','2026-10-05 08:32:12'),(176,'TCK-01176',4,NULL,5,'No puedo recibir correos','Incidencia reportada por el cliente. Requiere diagnóstico y atención según SLA.','alta','cerrado','web',6,1,'2026-07-02 01:22:38','2026-07-02 08:49:02','2026-07-01 01:22:38','2026-10-05 08:32:12'),(177,'TCK-01177',8,NULL,1,'Reemplazo de disco duro por SSD','Incidencia reportada por el cliente. Requiere diagnóstico y atención según SLA.','critica','cerrado','telefono',5,1,'2026-09-30 07:54:08','2026-09-30 04:32:32','2026-09-29 23:54:08','2026-10-05 08:32:12'),(178,'TCK-01178',4,NULL,5,'No puedo recibir correos','Incidencia reportada por el cliente. Requiere diagnóstico y atención según SLA.','alta','resuelto','telefono',4,1,'2026-09-24 03:40:34','2026-09-23 22:52:34','2026-09-23 03:40:34','2026-10-05 08:32:12'),(179,'TCK-01179',6,NULL,4,'Servidor de archivos sin espacio','Incidencia reportada por el cliente. Requiere diagnóstico y atención según SLA.','media','resuelto','presencial',3,1,'2026-07-28 22:35:13','2026-07-28 08:11:12','2026-07-26 22:35:13','2026-10-05 08:32:12'),(180,'TCK-01180',2,NULL,3,'Intermitencia en WiFi de recepción','Incidencia reportada por el cliente. Requiere diagnóstico y atención según SLA.','alta','cerrado','telefono',4,1,'2026-09-01 02:19:43','2026-08-31 22:00:31','2026-08-31 02:19:43','2026-10-05 08:32:12'),(181,'TCK-01181',1,NULL,3,'Configurar VPN para trabajo remoto','Incidencia reportada por el cliente. Requiere diagnóstico y atención según SLA.','baja','cerrado','whatsapp',4,1,'2026-09-28 22:10:53','2026-09-29 20:30:05','2026-09-25 22:10:53','2026-10-05 08:32:12'),(182,'TCK-01182',1,NULL,3,'Configurar VPN para trabajo remoto','Incidencia reportada por el cliente. Requiere diagnóstico y atención según SLA.','alta','cerrado','correo',6,1,'2026-08-28 02:21:38','2026-08-27 11:57:38','2026-08-27 02:21:38','2026-10-05 08:32:12'),(183,'TCK-01183',7,NULL,6,'Impresora no imprime en red','Incidencia reportada por el cliente. Requiere diagnóstico y atención según SLA.','alta','cerrado','correo',6,1,'2026-04-27 01:53:50','2026-04-26 12:13:02','2026-04-26 01:53:50','2026-10-05 08:32:12'),(184,'TCK-01184',8,NULL,6,'Atasco constante de papel','Incidencia reportada por el cliente. Requiere diagnóstico y atención según SLA.','alta','cerrado','correo',3,1,'2026-06-04 05:35:34','2026-06-04 20:13:58','2026-06-03 05:35:34','2026-10-05 08:32:12'),(185,'TCK-01185',7,NULL,3,'Sin internet en el segundo piso','Incidencia reportada por el cliente. Requiere diagnóstico y atención según SLA.','critica','cerrado','web',3,1,'2026-07-27 06:39:08','2026-07-27 04:00:44','2026-07-26 22:39:08','2026-10-05 08:32:12'),(186,'TCK-01186',4,NULL,6,'Cambio de tóner','Incidencia reportada por el cliente. Requiere diagnóstico y atención según SLA.','media','cerrado','web',5,1,'2026-06-18 02:43:22','2026-06-18 05:36:10','2026-06-16 02:43:22','2026-10-05 08:32:12'),(187,'TCK-01187',5,NULL,3,'Configurar VPN para trabajo remoto','Incidencia reportada por el cliente. Requiere diagnóstico y atención según SLA.','critica','cerrado','telefono',3,1,'2026-07-21 14:21:50','2026-07-21 11:57:50','2026-07-21 06:21:50','2026-10-05 08:32:12'),(188,'TCK-01188',8,NULL,6,'Atasco constante de papel','Incidencia reportada por el cliente. Requiere diagnóstico y atención según SLA.','critica','cerrado','whatsapp',6,1,'2026-08-15 11:06:48','2026-08-15 07:45:12','2026-08-15 03:06:48','2026-10-05 08:32:12'),(189,'TCK-01189',7,NULL,3,'Sin internet en el segundo piso','Incidencia reportada por el cliente. Requiere diagnóstico y atención según SLA.','critica','cerrado','presencial',4,1,'2026-09-08 13:13:04','2026-09-08 08:53:52','2026-09-08 05:13:04','2026-10-05 08:32:12'),(190,'TCK-01190',8,NULL,4,'Alerta de temperatura en rack','Incidencia reportada por el cliente. Requiere diagnóstico y atención según SLA.','alta','resuelto','correo',4,1,'2026-09-28 01:15:29','2026-09-27 13:58:41','2026-09-27 01:15:29','2026-10-05 08:32:12'),(191,'TCK-01191',8,NULL,5,'Restablecer contraseña de dominio','Incidencia reportada por el cliente. Requiere diagnóstico y atención según SLA.','alta','cerrado','web',4,1,'2026-06-01 06:05:05','2026-06-01 02:00:17','2026-05-31 06:05:05','2026-10-05 08:32:12'),(192,'TCK-01192',7,NULL,1,'Reemplazo de disco duro por SSD','Incidencia reportada por el cliente. Requiere diagnóstico y atención según SLA.','critica','cerrado','whatsapp',3,1,'2026-06-14 06:56:42','2026-06-14 05:11:06','2026-06-13 22:56:42','2026-10-05 08:32:12'),(193,'TCK-01193',4,NULL,2,'Excel se cierra al abrir archivos grandes','Incidencia reportada por el cliente. Requiere diagnóstico y atención según SLA.','critica','cerrado','whatsapp',6,1,'2026-07-31 07:59:56','2026-07-31 06:33:32','2026-07-30 23:59:56','2026-10-05 08:32:12'),(194,'TCK-01194',6,NULL,6,'Cambio de tóner','Incidencia reportada por el cliente. Requiere diagnóstico y atención según SLA.','critica','resuelto','telefono',6,1,'2026-07-31 10:09:53','2026-07-31 06:48:17','2026-07-31 02:09:53','2026-10-05 08:32:12'),(195,'TCK-01195',5,NULL,2,'Excel se cierra al abrir archivos grandes','Incidencia reportada por el cliente. Requiere diagnóstico y atención según SLA.','baja','cerrado','whatsapp',6,1,'2026-05-10 06:07:38','2026-05-09 20:02:50','2026-05-07 06:07:38','2026-10-05 08:32:12'),(196,'TCK-01196',1,NULL,4,'Alerta de temperatura en rack','Incidencia reportada por el cliente. Requiere diagnóstico y atención según SLA.','baja','resuelto','presencial',5,1,'2026-08-25 01:55:47','2026-08-23 03:50:59','2026-08-22 01:55:47','2026-10-05 08:32:12'),(197,'TCK-01197',7,NULL,6,'Impresora no imprime en red','Incidencia reportada por el cliente. Requiere diagnóstico y atención según SLA.','alta','cerrado','presencial',6,1,'2026-08-12 01:50:42','2026-08-12 15:02:42','2026-08-11 01:50:42','2026-10-05 08:32:12'),(198,'TCK-01198',3,NULL,5,'Restablecer contraseña de dominio','Incidencia reportada por el cliente. Requiere diagnóstico y atención según SLA.','alta','resuelto','correo',5,1,'2026-08-13 01:26:10','2026-08-12 09:50:09','2026-08-12 01:26:10','2026-10-05 08:32:12'),(199,'TCK-01199',7,NULL,2,'Licencia de antivirus vencida','Incidencia reportada por el cliente. Requiere diagnóstico y atención según SLA.','alta','resuelto','telefono',3,1,'2026-07-31 05:18:50','2026-07-30 13:42:49','2026-07-30 05:18:50','2026-10-05 08:32:12'),(200,'TCK-01200',4,NULL,8,'Anexos sin tono en oficina','Incidencia reportada por el cliente. Requiere diagnóstico y atención según SLA.','critica','resuelto','correo',4,1,'2026-05-02 13:37:26','2026-05-02 08:44:38','2026-05-02 05:37:26','2026-10-05 08:32:12'),(201,'TCK-01201',3,NULL,3,'Configurar VPN para trabajo remoto','Incidencia reportada por el cliente. Requiere diagnóstico y atención según SLA.','alta','cerrado','presencial',5,1,'2026-09-28 03:02:55','2026-09-27 22:43:43','2026-09-27 03:02:55','2026-10-05 08:32:12'),(202,'TCK-01202',7,NULL,3,'Intermitencia en WiFi de recepción','Incidencia reportada por el cliente. Requiere diagnóstico y atención según SLA.','alta','cerrado','telefono',5,1,'2026-08-05 07:04:21','2026-08-04 15:57:08','2026-08-04 07:04:21','2026-10-05 08:32:12'),(203,'TCK-01203',3,NULL,1,'Laptop no enciende tras corte de energía','Incidencia reportada por el cliente. Requiere diagnóstico y atención según SLA.','baja','cerrado','telefono',5,1,'2026-09-15 06:15:56','2026-09-13 23:18:20','2026-09-12 06:15:56','2026-10-05 08:32:12'),(204,'TCK-01204',7,NULL,4,'Respaldo nocturno falló','Incidencia reportada por el cliente. Requiere diagnóstico y atención según SLA.','alta','cerrado','web',4,1,'2026-08-11 06:40:47','2026-08-10 22:16:47','2026-08-10 06:40:47','2026-10-05 08:32:12'),(205,'TCK-01205',6,NULL,7,'Bloqueo de cuenta por intentos fallidos','Incidencia reportada por el cliente. Requiere diagnóstico y atención según SLA.','media','cerrado','web',3,1,'2026-09-20 21:39:36','2026-09-20 09:39:36','2026-09-18 21:39:36','2026-10-05 08:32:12'),(206,'TCK-01206',7,NULL,7,'Posible correo de phishing recibido','Incidencia reportada por el cliente. Requiere diagnóstico y atención según SLA.','alta','resuelto','presencial',5,1,'2026-09-05 01:09:23','2026-09-04 09:04:35','2026-09-04 01:09:23','2026-10-05 08:32:12'),(207,'TCK-01207',2,NULL,2,'Sistema ERP muy lento','Incidencia reportada por el cliente. Requiere diagnóstico y atención según SLA.','critica','cerrado','presencial',6,1,'2026-09-22 09:59:51','2026-09-22 06:23:51','2026-09-22 01:59:51','2026-10-05 08:32:12'),(208,'TCK-01208',7,NULL,2,'Excel se cierra al abrir archivos grandes','Incidencia reportada por el cliente. Requiere diagnóstico y atención según SLA.','media','cerrado','web',3,1,'2026-06-16 23:32:40','2026-06-17 14:25:28','2026-06-14 23:32:40','2026-10-05 08:32:12'),(209,'TCK-01209',5,NULL,6,'Cambio de tóner','Incidencia reportada por el cliente. Requiere diagnóstico y atención según SLA.','alta','cerrado','telefono',3,1,'2026-05-07 21:50:50','2026-05-07 14:53:14','2026-05-06 21:50:50','2026-10-05 08:32:12'),(210,'TCK-01210',7,NULL,6,'Impresora no imprime en red','Incidencia reportada por el cliente. Requiere diagnóstico y atención según SLA.','alta','cerrado','correo',5,1,'2026-07-30 02:34:24','2026-07-29 20:19:59','2026-07-29 02:34:24','2026-10-05 08:32:12'),(211,'TCK-01211',5,NULL,8,'Configurar central IP','Incidencia reportada por el cliente. Requiere diagnóstico y atención según SLA.','media','resuelto','whatsapp',4,1,'2026-10-06 01:49:06','2026-10-05 08:22:12','2026-10-04 01:49:06','2026-10-05 08:32:12'),(212,'TCK-01212',4,NULL,2,'Licencia de antivirus vencida','Incidencia reportada por el cliente. Requiere diagnóstico y atención según SLA.','baja','cerrado','telefono',6,1,'2026-07-11 06:19:59','2026-07-09 19:03:11','2026-07-08 06:19:59','2026-10-05 08:32:12'),(213,'TCK-01213',2,NULL,4,'Respaldo nocturno falló','Incidencia reportada por el cliente. Requiere diagnóstico y atención según SLA.','media','cerrado','whatsapp',3,1,'2026-06-20 05:51:59','2026-06-20 02:59:11','2026-06-18 05:51:59','2026-10-05 08:32:12'),(214,'TCK-01214',6,NULL,6,'Impresora no imprime en red','Incidencia reportada por el cliente. Requiere diagnóstico y atención según SLA.','baja','resuelto','whatsapp',5,1,'2026-09-06 00:29:32','2026-09-05 00:43:56','2026-09-03 00:29:32','2026-10-05 08:32:12'),(215,'TCK-01215',1,NULL,3,'Configurar VPN para trabajo remoto','Incidencia reportada por el cliente. Requiere diagnóstico y atención según SLA.','alta','en_proceso','whatsapp',3,1,'2026-06-02 07:52:54',NULL,'2026-06-01 07:52:54','2026-10-05 08:32:12'),(216,'TCK-01216',8,NULL,7,'Posible correo de phishing recibido','Incidencia reportada por el cliente. Requiere diagnóstico y atención según SLA.','media','cerrado','web',5,1,'2026-09-06 07:02:18','2026-09-05 08:28:42','2026-09-04 07:02:18','2026-10-05 08:32:12'),(217,'TCK-01217',3,NULL,5,'No puedo recibir correos','Incidencia reportada por el cliente. Requiere diagnóstico y atención según SLA.','alta','resuelto','web',3,1,'2026-04-22 08:19:03','2026-04-21 16:14:15','2026-04-21 08:19:03','2026-10-05 08:32:12'),(218,'TCK-01218',1,NULL,5,'Alta de nuevo usuario de correo','Incidencia reportada por el cliente. Requiere diagnóstico y atención según SLA.','critica','cerrado','web',3,1,'2026-08-03 11:28:47','2026-08-03 10:55:11','2026-08-03 03:28:47','2026-10-05 08:32:12'),(219,'TCK-01219',1,NULL,3,'Configurar VPN para trabajo remoto','Incidencia reportada por el cliente. Requiere diagnóstico y atención según SLA.','alta','abierto','web',4,1,'2026-10-06 00:32:12',NULL,'2026-10-05 00:32:12','2026-10-05 08:32:12'),(220,'TCK-01220',4,NULL,4,'Alerta de temperatura en rack','Incidencia reportada por el cliente. Requiere diagnóstico y atención según SLA.','media','pendiente','presencial',5,1,'2026-10-06 06:32:12',NULL,'2026-10-05 06:32:12','2026-10-05 08:32:12'),(221,'TCK-01221',6,NULL,7,'Posible correo de phishing recibido','Incidencia reportada por el cliente. Requiere diagnóstico y atención según SLA.','media','pendiente','presencial',6,1,'2026-10-06 02:32:12',NULL,'2026-10-05 02:32:12','2026-10-05 08:32:12'),(222,'TCK-01222',1,NULL,5,'Alta de nuevo usuario de correo','Incidencia reportada por el cliente. Requiere diagnóstico y atención según SLA.','media','abierto','telefono',5,1,'2026-10-06 02:32:12',NULL,'2026-10-05 02:32:12','2026-10-05 08:32:12'),(223,'TCK-01223',5,NULL,1,'Pantalla con líneas verticales','Incidencia reportada por el cliente. Requiere diagnóstico y atención según SLA.','alta','en_proceso','presencial',4,1,'2026-10-06 06:32:12',NULL,'2026-10-05 06:32:12','2026-10-05 08:32:12'),(224,'TCK-01224',7,NULL,6,'Impresora no imprime en red','Incidencia reportada por el cliente. Requiere diagnóstico y atención según SLA.','alta','abierto','correo',5,1,'2026-10-06 08:32:12',NULL,'2026-10-05 08:32:12','2026-10-05 08:32:12'),(225,'TCK-01225',4,NULL,3,'Sin internet en el segundo piso','Incidencia reportada por el cliente. Requiere diagnóstico y atención según SLA.','alta','en_proceso','correo',6,1,'2026-10-06 08:32:12',NULL,'2026-10-05 08:32:12','2026-10-05 08:32:12'),(226,'TCK-01226',2,NULL,2,'Licencia de antivirus vencida','Incidencia reportada por el cliente. Requiere diagnóstico y atención según SLA.','media','pendiente','web',3,1,'2026-10-06 02:32:12',NULL,'2026-10-05 02:32:12','2026-10-05 08:32:12'),(227,'TCK-01227',1,NULL,5,'No puedo recibir correos','Incidencia reportada por el cliente. Requiere diagnóstico y atención según SLA.','critica','abierto','presencial',5,1,'2026-10-14 16:21:38',NULL,'2026-10-05 00:32:12','2026-10-14 20:21:38'),(228,'TCK-01228',5,NULL,2,'Instalación de Office 365','Incidencia reportada por el cliente. Requiere diagnóstico y atención según SLA.','media','pendiente','presencial',5,1,'2026-10-06 04:32:12',NULL,'2026-10-05 04:32:12','2026-10-05 08:32:12'),(229,'TCK-01229',4,NULL,2,'Licencia de antivirus vencida','Incidencia reportada por el cliente. Requiere diagnóstico y atención según SLA.','baja','cerrado','correo',6,1,'2026-10-06 00:32:12','2026-10-14 20:21:38','2026-10-05 00:32:12','2026-10-14 20:21:38'),(230,'TCK-01230',8,NULL,4,'Alerta de temperatura en rack','Incidencia reportada por el cliente. Requiere diagnóstico y atención según SLA.','baja','cerrado','whatsapp',5,1,'2026-10-06 06:32:12','2026-10-14 20:21:38','2026-10-05 06:32:12','2026-10-14 20:21:38'),(232,'TCK-01231',10,101,1,'No tiene conexion a internet','Fallos en la red','critica','en_proceso','portal',1,NULL,'2026-10-14 16:21:38',NULL,'2026-10-12 00:04:05','2026-10-14 20:21:38'),(233,'TCK-01232',10,NULL,1,'Auditoría E2E: Enlaces de Fibra Óptica Sede Norte','Verificación automatizada de convergencia BGP y latencia con routers perimetrales.','alta','abierto','portal',NULL,NULL,'2026-10-15 01:22:00',NULL,'2026-10-14 01:22:00','2026-10-14 01:22:00'),(234,'TCK-01233',10,NULL,1,'Auditoría E2E: Enlaces de Fibra Óptica Sede Norte','Verificación automatizada de convergencia BGP y latencia con routers perimetrales.','alta','abierto','portal',NULL,NULL,'2026-10-15 01:37:20',NULL,'2026-10-14 01:37:20','2026-10-14 01:37:20'),(242,'TCK-01234',1,NULL,1,'Ticket Test Debug Resuelto','Probando creacion directa tras crear tabla outbox','media','abierto','web',NULL,NULL,'2026-10-16 18:50:05',NULL,'2026-10-14 18:50:05','2026-10-14 18:50:05'),(243,'TCK-01235',1,NULL,2,'Prueba de Persistencia MySQL - 19:10:03','Ticket de prueba determinista verificado en MySQL y outbox_events','alta','abierto','web',NULL,NULL,'2026-10-15 19:10:03',NULL,'2026-10-14 19:10:03','2026-10-14 19:10:03'),(244,'TCK-01236',1,NULL,2,'Prueba Gateway 8080 con JWT Real - 19:24:31','Ticket enviado via Gateway con autenticacion real','media','abierto','web',NULL,NULL,'2026-10-16 19:24:31',NULL,'2026-10-14 19:24:31','2026-10-14 19:24:31'),(245,'TCK-01237',10,NULL,2,'Ticket F5 MySQL - 1792024189366','Descripción verificada con recarga F5 y persistencia determinista en MySQL.','alta','abierto','web',NULL,NULL,'2026-10-15 19:29:50',NULL,'2026-10-14 19:29:49','2026-10-14 19:29:49'),(246,'TCK-01238',6,31,3,'Falla en router Cisco principal','Prueba de Samuel','alta','en_proceso','web',2,NULL,'2026-10-16 07:32:46',NULL,'2026-10-14 19:32:45','2026-10-14 19:32:45'),(247,'TCK-01239',6,NULL,3,'Auditoría E2E Durabilidad MySQL - 1792028144047','','alta','abierto','web',NULL,NULL,'2026-10-16 08:35:44',NULL,'2026-10-14 20:35:44','2026-10-14 20:35:44'),(248,'TCK-01240',6,NULL,3,'E2E Durabilidad - 221182','','alta','abierto','web',NULL,NULL,'2026-10-16 08:37:02',NULL,'2026-10-14 20:37:02','2026-10-14 20:37:02'),(249,'TCK-01241',10,NULL,2,'Ticket F5 MySQL - 1792028270224','Descripción verificada con recarga F5 y persistencia determinista en MySQL.','alta','abierto','web',NULL,NULL,'2026-10-15 20:37:50',NULL,'2026-10-14 20:37:50','2026-10-14 20:37:50');

CREATE TABLE `ticket_comentarios` (
    `id` BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    `ticket_id` BIGINT UNSIGNED NOT NULL,
    `usuario_id` BIGINT UNSIGNED NULL,
    `comentario` TEXT NOT NULL,
    `interno` TINYINT(1) NOT NULL DEFAULT 0,
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT `fk_tc_tick` FOREIGN KEY (`ticket_id`) REFERENCES `tickets` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

INSERT INTO `ticket_comentarios` (`id`, `ticket_id`, `usuario_id`, `comentario`, `interno`, `created_at`) VALUES
(1, 1, 3, 'Se ha iniciado el diagnóstico remoto del enlace de fibra óptica.', 1, '2026-10-06 09:15:00'),
(2, 1, 1, 'Autorizada la salida de técnico de guardia si la atenuación persiste.', 1, '2026-10-06 09:30:00'),
(3, 1, 3, 'Enlace restablecido con éxito. Conmutador principal en línea.', 0, '2026-10-06 10:45:00'),
(4, 2, 4, 'Servidor de base de datos reiniciado en modo seguro para verificación de integridad.', 1, '2026-10-06 11:20:00'),
(5, 3, 3, 'Impresora configurada con IP estática en VLAN de contabilidad.', 0, '2026-10-06 14:00:00');

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

-- ----------------------------------------------------------------------------
-- 4. BASE DE DATOS: db_operations (Repuestos, Ordenes de Servicio, Visitas)
-- ----------------------------------------------------------------------------
CREATE DATABASE IF NOT EXISTS `db_operations` CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE `db_operations`;

DROP TABLE IF EXISTS `ordenes_repuestos`;
DROP TABLE IF EXISTS `visitas`;
DROP TABLE IF EXISTS `ordenes_servicio`;
DROP TABLE IF EXISTS `repuestos`;
DROP TABLE IF EXISTS `cached_tecnicos`;
DROP TABLE IF EXISTS `outbox_events`;
DROP TABLE IF EXISTS `consumed_messages`;

CREATE TABLE `cached_tecnicos` (
    `id` BIGINT UNSIGNED PRIMARY KEY,
    `nombre_completo` VARCHAR(160) NOT NULL,
    `email` VARCHAR(120) NOT NULL,
    `telefono` VARCHAR(25) NULL,
    `activo` TINYINT(1) NOT NULL DEFAULT 1,
    `rol_id` TINYINT UNSIGNED NOT NULL DEFAULT 3,
    `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

INSERT INTO `cached_tecnicos` (`id`, `nombre_completo`, `email`, `telefono`, `activo`, `rol_id`) VALUES
(3, 'Brayan Luis Hurtado Sernaque', 'bhurtado@nexusdesk.pe', '999333444', 1, 3),
(4, 'Andrea Quispe', 'andrea@nexusdesk.pe', '999444555', 1, 3);

CREATE TABLE `repuestos` (
    `id` BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    `codigo` VARCHAR(20) NOT NULL UNIQUE,
    `nombre` VARCHAR(100) NOT NULL,
    `categoria` VARCHAR(50) NOT NULL DEFAULT 'General',
    `stock` INT NOT NULL DEFAULT 0,
    `stock_minimo` INT NOT NULL DEFAULT 2,
    `precio` DECIMAL(10,2) NOT NULL DEFAULT 0.00,
    `ubicacion` VARCHAR(50) NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

INSERT INTO `repuestos` VALUES (1,'REP-001','Disco SSD 480GB','Almacenamiento',3,8,185.00,NULL),(2,'REP-002','Memoria RAM DDR4 8GB','Memoria',14,6,95.00,NULL),(3,'REP-003','Fuente de poder 500W','Componentes',2,5,120.00,NULL),(4,'REP-004','Cable UTP Cat6 (caja 305m)','Redes',6,3,390.00,NULL),(5,'REP-005','Tóner HP 105A','Consumibles',4,6,260.00,NULL),(6,'REP-006','Batería laptop Dell','Baterías',9,4,210.00,NULL),(7,'REP-007','Switch 24p PoE','Redes',2,2,1450.00,NULL),(8,'REP-008','Pantalla LED 15.6\"','Pantallas',1,3,340.00,NULL),(9,'REP-009','Conector RJ45 (100u)','Redes',20,8,45.00,NULL),(10,'REP-010','Pasta térmica','Consumibles',12,5,22.00,NULL);

CREATE TABLE `ordenes_servicio` (
    `id` BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    `codigo` VARCHAR(20) NOT NULL UNIQUE,
    `ticket_id` BIGINT UNSIGNED NULL,
    `cliente_id` BIGINT UNSIGNED NOT NULL,
    `activo_id` BIGINT UNSIGNED NULL,
    `tecnico_id` BIGINT UNSIGNED NULL,
    `tipo` VARCHAR(20) NOT NULL DEFAULT 'correctiva',
    `estado` VARCHAR(20) NOT NULL DEFAULT 'pendiente',
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

INSERT INTO `ordenes_servicio` VALUES (1,'OS-2026-001',NULL,1,NULL,3,'correctiva','completada','Reemplazo de disco duro y reinstalación del sistema','Se identificó el origen de la falla tras las pruebas en sitio.','Trabajo ejecutado y probado con el usuario. Equipo operativo.',2.20,45.00,1,'2026-08-28 09:00:00','2026-08-28 09:30:00','2026-08-28 11:42:00',NULL,NULL,NULL,NULL,'2026-10-05 17:50:21'),(2,'OS-2026-002',NULL,2,NULL,4,'preventiva','completada','Mantenimiento preventivo de equipos de oficina','Se identificó el origen de la falla tras las pruebas en sitio.','Trabajo ejecutado y probado con el usuario. Equipo operativo.',2.60,45.00,1,'2026-09-24 09:00:00','2026-09-24 09:30:00','2026-09-24 12:06:00',NULL,NULL,NULL,NULL,'2026-10-05 17:50:21'),(3,'OS-2026-003',NULL,3,NULL,5,'instalacion','completada','Instalación y configuración de switch PoE','Se identificó el origen de la falla tras las pruebas en sitio.','Trabajo ejecutado y probado con el usuario. Equipo operativo.',6.40,45.00,1,'2026-08-25 09:00:00','2026-08-25 09:30:00','2026-08-25 15:54:00',NULL,NULL,NULL,NULL,'2026-10-05 17:50:21'),(4,'OS-2026-004',NULL,4,NULL,6,'diagnostico','completada','Diagnóstico de lentitud en servidor de archivos','Se identificó el origen de la falla tras las pruebas en sitio.','Trabajo ejecutado y probado con el usuario. Equipo operativo.',2.30,45.00,1,'2026-08-06 09:00:00','2026-08-06 09:30:00','2026-08-06 11:48:00',NULL,NULL,NULL,NULL,'2026-10-05 17:50:21'),(5,'OS-2026-005',NULL,5,NULL,3,'correctiva','completada','Cambio de fuente de poder en estación de trabajo','Se identificó el origen de la falla tras las pruebas en sitio.','Trabajo ejecutado y probado con el usuario. Equipo operativo.',6.70,45.00,1,'2026-09-10 09:00:00','2026-09-10 09:30:00','2026-09-10 16:12:00',NULL,NULL,NULL,NULL,'2026-10-05 17:50:21'),(6,'OS-2026-006',NULL,6,NULL,4,'preventiva','completada','Configuración de punto de acceso WiFi','Se identificó el origen de la falla tras las pruebas en sitio.','Trabajo ejecutado y probado con el usuario. Equipo operativo.',4.10,45.00,1,'2026-08-26 09:00:00','2026-08-26 09:30:00','2026-08-26 13:35:59',NULL,NULL,NULL,NULL,'2026-10-05 17:50:21'),(7,'OS-2026-007',NULL,7,NULL,5,'instalacion','en_curso','Limpieza y mantenimiento de impresoras',NULL,NULL,0.00,45.00,0,'2026-10-04 09:00:00','2026-10-04 09:30:00',NULL,NULL,NULL,NULL,NULL,'2026-10-05 17:50:21'),(8,'OS-2026-008',NULL,8,NULL,6,'diagnostico','en_curso','Reubicación de puntos de red',NULL,NULL,0.00,45.00,1,'2026-10-04 09:00:00','2026-10-04 09:30:00',NULL,NULL,'data:image/png;base64,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','Ing. Carlos Benavides (DNI 45892301)','2026-10-11 19:57:00','2026-10-05 17:50:21'),(9,'OS-2026-009',NULL,1,NULL,3,'correctiva','pendiente','Reemplazo de disco duro y reinstalación del sistema',NULL,NULL,0.00,45.00,1,'2026-10-07 09:00:00',NULL,NULL,NULL,'data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAeAAAAC+CAYAAADtJ9ymAAANfklEQVR4AezcXYxdVRUH8N0+0QpE5QGBSPRFIiARUUJIE4TiB0SNggYNSggYCgnQKn1AQKhGDYaSNjVRG9QYFCuBEvyINRWKJJA0VKkUoqImoImoT0Toh0+VzoUz3HZm7tzbOefsfc76NcycO+fcu/dav3WTf7IfWPx//wgQIECAAIHWBRYn/wgQIECAAIHWBWIHcOvcNiRAgAABAq8KCOBXHfwmQIAAAQKtCgjgVrmL2kwxBAgQIJBRQABnxLc1AQIECMQVEMBxZx+7c90TIEAgs4AAzjwA2xMgQIBATAEBHHPuuo4toHsCBAoQEMAFDEEJBAgQIBBPQADHm7mOCcQW0D2BQgQEcCGDUAYBAgQIxBIQwLHmrVsCBGIL6L4gAQFc0DCUQoAAAQJxBARwnFnrlAABArEFCuteABc2EOUQIECAQAwBARxjzrokQIAAgcIEWg7gwrpXDgECBAgQyCQggDPB25YAAQIEYgsI4BbnbysCBAgQIFAJCOBKwpUAAQIECLQoIIBbxI69le4JECBAYFhAAA9reE2AAAECBFoSEMAtQdsmtoDuCRAgcKiAAD5UxN8ECBAgQKAFAQHcArItCMQW0D0BArMJCODZVNwjQIAAAQINCwjghoEtT4BAbAHdE5hLQADPJeM+AQIECBBoUEAAN4hraQIECMQW0P0oAQE8SsczAgQIECDQkIAAbgjWsgQIECAQW2C+7gXwfEKeEyBAgACBBgQEcAOoliRAgAABAvMJ9DuA5+vecwIECBAgkElAAGeCty0BAgQIxBYQwP2dv84IECBAoGABAVzwcJRGgAABAv0VKDqAn9z5VPrLX//WX32dNSdgZQIECBQuUGwAP/f839O5H7okvW/ZR9NNt30zvfjifwunVB4BAgQIEBhfoNgA3r17z6CLRYsWp29vvDudcsby9JVvrBfEAxW/CIwU8JAAgQ4IFBvA7zr15PT4tgfSlZdfkt6wdGnau3dfWrfhrnTqGeenNV9fJ4g78OVSIgECBAjMLVBsAE+VfOqBEL7z9lvTrh1b06rrPj8I4j1796b13/qeIJ4C8kOAwEwBdwh0RKDoAK4MjznmTWnNzV8QxBWIKwECBAh0XqATAVwpC+JKwpUAAQKzCrjZIYFOBXDlKogrCVcCBAgQ6KpAJwO4whbElYQrAQIECKSOEXQ6gCtrQVxJuBIgQIBAVwR6EcAVtiCuJFzrEHjq6T+lf77w7zqWsgYBAgRmCNQcwDPWz3JDEGdh78WmL/zrP2nt+o3p9LMuSOd84JPpjLMvTLue+XMvetMEAQJlCfQygCtiQVxJuI4S2Lfvf+ne+3+RLvr0Venk089LX7t9Q3ru+X+kqX+LFi1Kx7z5jVMv/RAgQKBWgV4HcCXVVhBX+7l2Q2D7E0+m62+4NZ102jlpxbU3pm2/fXy68KOPOjJd/tlPpYd+tSmdcPxbpu97QYAAgboEQgRwhSWIK4m41+Ej5g9/7HPp7ns2p5de3j0AWbx4cVp+7rL0g++uTc/uejStX7smnfLOdwye+UWAAIG6BUIFcIUniCuJOq/lrjV1xPzAg1vSxZ9ZMfhfmA4fMU9V/fa3nZhuufH69MzvH0qbN21MF338grRkyRFTj/wQIECgMYGQAVxpCuJKop/XJ373h7Rq9ZrBEfMVV69ODz/yWNq/f/+g2eqIeesv70k7t29Jq1etSMcfd+zgmV8ECBBoQyB0AFfAgriS6P51+Ij5gx+5NP3wx/eNPGI+873vrqVpixAgQGBSAQE8JCaIhzA69NIRc4eGpVQCBKYFBPA0xesvBPHrFiW/csRcynTUQYDA4QgI4BFqgngETqZHjpgzwduWAIHaBQTwGKSCeAykBt/iiLlBXEsvWMACBA5XQABPICeIJ8Cq4a2OmGtAtAQBAsUKCODDGI0gPgy0MT/iiHlMKG8jUISAIhYiIIAXoCeIF4A39FFHzEMYXhIgEEZAANcwakF8eIiOmA/PzacIEChDYKFVCOCFCg59XhAPYczx0hHzHDBuEyAQTkAANzByQXwwqiPmgz38RYAAgSmBbgfwVAcF/0QPYkfMBX85lUaAQHYBAdzCCCIFsSPmFr5QtiBAoBcCArjFMdYcxC1WPnorR8yjfTwlQIDAbAICeDaVhu/1JYgdMTf8RbE8AQK9FhDAGcfbxSAu5og549xsTYAAgToEBHAdigtco/QgdsS8wAH7OAECBGYREMCzoOS6VVoQO2LO9U2Yd19vIECgBwICuMAh5gxiR8wFfiGURIBALwUEcMFjbSuIHTEX/CVQ2kwBdwj0REAAd2CQTQWxI+YODF+JBAj0VkAAd2i0dQSxI+YODVypBGYKuNMjAQHcwWFOGsSOmDs4ZCUTINB7AQHc4RHPF8TXrLw5XXPdTemk085JV1y9Oj38yGNp//79g46PPurIdNmlF6df//xHaef2LWn1qhXp+OOOHTzziwABAkUK9KwoAdyDgR4UxNdemZYuXZJ279mTNt37YNp038/SSy/vnu5y+bnL0ve/c0d6dtejacOdX01nnfme6WdeECBAgEB7AgK4PevGdxoE8S1fTE/v+E264rJLpvc78a0npC9/aWX6485tafOmjeniT1yYliw5Yvq5FwQIECDQvsCEAdx+gXacXGAqiNfdcVu6/ycb0+af3pV27diablh5lSPmySl9ggABAo0JCODGaPMvfP55y9Ly95+dvxAVECBAgMAMAQE8g2TuG54QIECAAIG6BARwXZLWIUCAAAECEwgI4AmwYr9V9wQIECBQp4AArlPTWgQIECBAYEwBATwmlLfFFtA9AQIE6hYQwHWLWo8AAQIECIwhIIDHQPIWArEFdE+AQBMCArgJVWsSIECAAIF5BATwPEAeEyAQW0D3BJoSEMBNyVqXAAECBAiMEBDAI3A8IkCAQGwB3TcpIICb1LU2AQIECBCYQ0AAzwHjNgECBAjEFmi6ewHctLD1CRAgQIDALAICeBYUtwgQIECAQNMCZQdw091bnwABAgQIZBIQwJngbUuAAAECsQUEcLnzVxkBAgQI9FhAAPd4uFojQIAAgXIFBHC5s4ldme4JECDQcwEB3PMBa48AAQIEyhQQwGXORVWxBXRPgEAAAQEcYMhaJECAAIHyBARweTNREYHYAronEERAAAcZtDYJECBAoCwBAVzWPFRDgEBsAd0HEhDAgYatVQIECBAoR0AAlzMLlRAgQCC2QLDuBXCwgWuXAAECBMoQEMBlzEEVBAgQIBBM4JAADta9dgkQIECAQCYBAZwJ3rYECBAgEFtAAA/N30sCBAgQINCWgABuS9o+BAgQIEBgSEAAD2HEfql7AgQIEGhTQAC3qW0vAgQIECDwmoAAfg3CJbaA7gkQINC2gABuW9x+BAgQIEDggIAAPoDgPwKxBXRPgEAOAQGcQ92eBAgQIBBeQACH/woAIBBbQPcEcgkI4Fzy9iVAgACB0AICOPT4NU+AQGwB3ecUEMA59e1NgAABAmEFBHDY0WucAAECsQVydy+Ac0/A/gQIECAQUkAAhxy7pgkQIEAgt0DeAM7dvf0JECBAgEAmAQGcCd62BAgQIBBbQADnm7+dCRAgQCCwgAAOPHytEyBAgEA+AQGczz72zronQIBAcAEBHPwLoH0CBAgQyCMggPO42zW2gO4JECCQBLAvAQECBAgQyCAggDOg25JAaAHNEyAwEBDAAwa/CBAgQIBAuwICuF1vuxEgEFtA9wSmBQTwNIUXBAgQIECgPQEB3J61nQgQIBBbQPcHCQjggzj8QYAAAQIE2hEQwO0424UAAQIEYgvM6F4AzyBxgwABAgQINC8ggJs3tgMBAgQIEJghECqAZ3TvBgECBAgQyCQggDPB25YAAQIEYgsI4DDz1ygBAgQIlCQggEuahloIECBAIIyAAA4z6tiN6p4AAQKlCQjg0iaiHgIECBAIISCAQ4xZk7EFdE+AQIkCArjEqaiJAAECBHovIIB7P2INEogtoHsCpQoI4FInoy4CBAgQ6LWAAO71eDVHgEBsAd2XLCCAS56O2ggQIECgtwICuLej1RgBAgRiC5TevQAufULqI0CAAIFeCgjgXo5VUwQIECBQukCzAVx69+ojQIAAAQKZBARwJnjbEiBAgEBsAQHc3PytTIAAAQIE5hQQwHPSeECAAAECBJoTEMDN2cZeWfcECBAgMFJAAI/k8ZAAAQIECDQjIICbcbVqbAHdEyBAYF4BATwvkTcQIECAAIH6BQRw/aZWJBBbQPcECIwlIIDHYvImAgQIECBQr4AArtfTagQIxBbQPYGxBQTw2FTeSIAAAQIE6hMQwPVZWokAAQKxBXQ/kYAAnojLmwkQIECAQD0CArgeR6sQIECAQGyBibsXwBOT+QABAgQIEFi4gABeuKEVCBAgQIDAxAK9CuCJu/cBAgQIECCQSUAAZ4K3LQECBAjEFhDAvZm/RggQIECgSwICuEvTUisBAgQI9EZAAPdmlLEb0T0BAgS6JiCAuzYx9RIgQIBALwQEcC/GqInYAronQKCLAgK4i1NTMwECBAh0XkAAd36EGiAQW0D3BLoqIIC7Ojl1EyBAgECnBQRwp8eneAIEYgvovssCrwAAAP//TyHEgwAAAAZJREFUAwDS0v2iLfimFgAAAABJRU5ErkJggg==','Ing. Carlos Benavides (DNI 45892301)','2026-10-11 13:59:35','2026-10-05 17:50:21'),(10,'OS-2026-010',NULL,2,NULL,4,'preventiva','pendiente','Mantenimiento preventivo de equipos de oficina',NULL,NULL,0.00,45.00,1,'2026-10-10 09:00:00',NULL,NULL,NULL,'data:image/png;base64,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','Ing. Carlos Benavides (DNI 45892301)','2026-10-11 13:50:45','2026-10-05 17:50:21'),(11,'OS-2026-011',NULL,3,NULL,5,'instalacion','pendiente','Instalación y configuración de switch PoE',NULL,NULL,0.00,45.00,1,'2026-10-08 09:00:00',NULL,NULL,NULL,'data:image/png;base64,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','Ing. Carlos Benavides (DNI 45892301)','2026-10-11 13:48:19','2026-10-05 17:50:21'),(12,'OS-2026-012',NULL,4,NULL,6,'diagnostico','cancelada','Diagnóstico de lentitud en servidor de archivos',NULL,NULL,0.00,45.00,1,'2026-10-05 09:00:00',NULL,NULL,NULL,'data:image/png;base64,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','Ing. Carlos Benavides (DNI 45892301)','2026-10-11 13:46:34','2026-10-05 17:50:21');

CREATE TABLE `ordenes_repuestos` (
    `id` BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    `orden_id` BIGINT UNSIGNED NOT NULL,
    `repuesto_id` BIGINT UNSIGNED NOT NULL,
    `cantidad` INT NOT NULL DEFAULT 1,
    `precio_unit` DECIMAL(10,2) NOT NULL DEFAULT 0.00,
    CONSTRAINT `fk_or_orden` FOREIGN KEY (`orden_id`) REFERENCES `ordenes_servicio` (`id`) ON DELETE CASCADE,
    CONSTRAINT `fk_or_rep` FOREIGN KEY (`repuesto_id`) REFERENCES `repuestos` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

INSERT INTO `ordenes_repuestos` VALUES (1,2,3,2,120.00),(2,3,2,1,95.00),(3,4,1,1,185.00),(4,5,2,1,95.00),(5,6,6,2,210.00);

CREATE TABLE `visitas` (
    `id` BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    `ticket_id` BIGINT UNSIGNED NULL,
    `cliente_id` BIGINT UNSIGNED NOT NULL,
    `tecnico_id` BIGINT UNSIGNED NULL,
    `tipo` VARCHAR(20) NOT NULL DEFAULT 'soporte',
    `fecha_programada` DATETIME NOT NULL,
    `estado` VARCHAR(20) NOT NULL DEFAULT 'programada',
    `notas` VARCHAR(255) NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

INSERT INTO `visitas` VALUES (2,NULL,3,4,'emergencia','2026-10-06 16:00:00','programada','Visita programada de mantenimiento'),(3,NULL,1,4,'emergencia','2026-10-11 11:00:00','programada','Visita programada de mantenimiento'),(4,NULL,4,3,'correctiva','2026-10-09 16:00:00','programada','Visita programada de mantenimiento'),(5,NULL,1,6,'instalacion','2026-10-09 11:00:00','programada','Visita programada de mantenimiento'),(6,NULL,7,3,'instalacion','2026-10-10 11:00:00','programada','Visita programada de mantenimiento'),(7,NULL,8,4,'preventiva','2026-10-08 16:00:00','programada','Visita programada de mantenimiento'),(8,NULL,2,3,'instalacion','2026-10-07 14:00:00','programada','Visita programada de mantenimiento'),(9,NULL,2,5,'preventiva','2026-10-06 10:00:00','en_curso','Visita programada de mantenimiento');

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

-- ----------------------------------------------------------------------------
-- 5. BASE DE DATOS: db_crm (CRM Leads, Oportunidades, Etapas, Cotizaciones)
-- ----------------------------------------------------------------------------
CREATE DATABASE IF NOT EXISTS `db_crm` CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE `db_crm`;

DROP TABLE IF EXISTS `crm_actividades`;
DROP TABLE IF EXISTS `crm_cotizacion_items`;
DROP TABLE IF EXISTS `crm_cotizaciones`;
DROP TABLE IF EXISTS `crm_oportunidades`;
DROP TABLE IF EXISTS `crm_leads`;
DROP TABLE IF EXISTS `crm_etapas`;
DROP TABLE IF EXISTS `outbox_events`;
DROP TABLE IF EXISTS `consumed_messages`;

CREATE TABLE `crm_etapas` (
    `id` TINYINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    `nombre` VARCHAR(60) NOT NULL,
    `orden` TINYINT UNSIGNED NOT NULL DEFAULT 1,
    `probabilidad` SMALLINT NOT NULL DEFAULT 10,
    `color` VARCHAR(9) NOT NULL DEFAULT '#4f46e5',
    `tipo` VARCHAR(20) NOT NULL DEFAULT 'activa'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

INSERT INTO `crm_etapas` VALUES (1,'Prospección',1,10,'#64748b','abierta'),(2,'Calificación',2,25,'#0ea5e9','abierta'),(3,'Propuesta',3,50,'#8b5cf6','abierta'),(4,'Negociación',4,75,'#f59e0b','abierta'),(5,'Ganada',5,100,'#10b981','ganada'),(6,'Perdida',6,0,'#ef4444','perdida');

CREATE TABLE `crm_leads` (
    `id` BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    `codigo` VARCHAR(20) NOT NULL UNIQUE,
    `empresa` VARCHAR(150) NOT NULL,
    `contacto` VARCHAR(100) NOT NULL,
    `cargo` VARCHAR(80) NULL,
    `email` VARCHAR(120) NULL,
    `telefono` VARCHAR(25) NULL,
    `rubro` VARCHAR(80) NULL,
    `origen` VARCHAR(20) NULL,
    `interes` VARCHAR(100) NULL,
    `estado` VARCHAR(20) NOT NULL DEFAULT 'nuevo',
    `score` SMALLINT NOT NULL DEFAULT 0,
    `responsable_id` BIGINT UNSIGNED NULL,
    `notas` TEXT NULL,
    `motivo_descarte` VARCHAR(200) NULL,
    `cliente_id` BIGINT UNSIGNED NULL,
    `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `updated_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

INSERT INTO `crm_leads` VALUES (2,'LD-0002','Distribuidora Andina SAC','Marco Tello','Gerente de Logística','mtello@andina.pe','976543210','Comercio','web','Cotización de red WiFi para almacén','contactado',70,6,NULL,NULL,NULL,'2026-09-30 09:13:47','2026-10-05 13:13:47'),(3,'LD-0003','Colegio Nuevo Horizonte','Ana Beltrán','Directora','direccion@nuevohorizonte.edu.pe','965432109','Educación','evento','Laboratorio de cómputo 30 equipos','nuevo',65,7,NULL,NULL,NULL,'2026-10-04 05:13:47','2026-10-05 13:13:47'),(4,'LD-0004','Transportes Rápido Sur','Iván Cabrera','Jefe de TI','icabrera@rapidosur.pe','954321098','Transporte','llamada','Mantenimiento preventivo de flota de laptops','contactado',70,6,NULL,NULL,NULL,'2026-09-27 07:13:47','2026-10-05 13:13:47'),(5,'LD-0005','Hotel Mirador del Valle','Sonia Prado','Administradora','sprado@miradorvalle.pe','943210987','Turismo','redes','Cableado estructurado y WiFi para huéspedes','nuevo',40,6,NULL,NULL,NULL,'2026-10-05 08:13:47','2026-10-05 13:13:47'),(6,'LD-0006','Constructora Pilar','Raúl Gamarra','Gerente General','rgamarra@pilar.pe','932109876','Construcción','referido','Servidor de archivos y respaldo en la nube','calificado',95,7,NULL,NULL,NULL,'2026-09-24 08:13:47','2026-10-05 13:13:47'),(7,'LD-0007','Bodega El Roble','Julia Meza','Propietaria','julia@elroble.pe','921098765','Retail','correo','Punto de venta y red básica','descartado',55,6,NULL,'Ya cuenta con proveedor de TI',NULL,'2026-09-15 10:13:47','2026-10-05 13:13:47'),(8,'LD-0008','Notaría Villanueva','Dr. Pablo Villanueva','Notario','pvillanueva@notaria.pe','910987654','Servicios','web','Soporte mensual y ciberseguridad','nuevo',60,6,NULL,NULL,NULL,'2026-10-03 06:13:47','2026-10-05 13:13:47'),(9,'LD-0009','Prospecto Comercial SAC Test','Dra. Patricia Silva','Directora de Operaciones','contacto@automatizado.pe','991223344','Comercio','web','Implementación de mesa de ayuda en la nube','calificado',70,NULL,NULL,NULL,NULL,'2026-10-11 17:05:05','2026-10-11 17:05:05');

CREATE TABLE `crm_oportunidades` (
    `id` BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    `codigo` VARCHAR(20) NOT NULL UNIQUE,
    `titulo` VARCHAR(180) NOT NULL,
    `cliente_id` BIGINT UNSIGNED NOT NULL,
    `contacto_id` BIGINT UNSIGNED NULL,
    `lead_id` BIGINT UNSIGNED NULL,
    `etapa_id` TINYINT UNSIGNED NOT NULL,
    `tipo` VARCHAR(20) NOT NULL DEFAULT 'contrato',
    `valor` DECIMAL(12,2) NOT NULL DEFAULT 0.00,
    `probabilidad` SMALLINT NOT NULL DEFAULT 10,
    `fecha_cierre_estimada` DATE NULL,
    `fecha_cierre_real` DATE NULL,
    `responsable_id` BIGINT UNSIGNED NULL,
    `origen` VARCHAR(20) NULL,
    `estado` VARCHAR(20) NOT NULL DEFAULT 'abierta',
    `motivo_perdida` VARCHAR(200) NULL,
    `contrato_id` BIGINT UNSIGNED NULL,
    `descripcion` TEXT NULL,
    `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `updated_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT `fk_op_etapa` FOREIGN KEY (`etapa_id`) REFERENCES `crm_etapas` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

INSERT INTO `crm_oportunidades` VALUES (2,'OP-0002','Migración de servidores a la nube',6,3,NULL,3,'proyecto',38500.00,50,'2026-10-30',NULL,6,'referido','abierta',NULL,NULL,'Oportunidad generada a partir de conversaciones con el cliente.','2026-08-03 13:13:47','2026-10-05 13:13:47'),(3,'OP-0003','Cableado estructurado sede nueva',3,5,NULL,3,'proyecto',14200.00,50,'2026-11-14',NULL,7,'web','abierta',NULL,NULL,'Oportunidad generada a partir de conversaciones con el cliente.','2026-08-05 13:13:47','2026-10-09 00:04:36'),(4,'OP-0004','Contrato Business · soporte mensual',4,7,NULL,3,'contrato',11400.00,50,'2026-10-23',NULL,6,'llamada','abierta',NULL,NULL,'Oportunidad generada a partir de conversaciones con el cliente.','2026-08-20 13:13:47','2026-10-05 13:13:47'),(5,'OP-0005','Venta de 15 laptops corporativas',5,9,NULL,4,'equipos',27800.00,75,'2026-10-12',NULL,6,'evento','abierta',NULL,NULL,'Oportunidad generada a partir de conversaciones con el cliente.','2026-08-21 13:13:47','2026-10-05 13:13:47'),(6,'OP-0006','Upgrade de seguridad perimetral',6,11,NULL,6,'proyecto',16900.00,10,'2026-11-29',NULL,7,'web','abierta',NULL,NULL,'Oportunidad generada a partir de conversaciones con el cliente.','2026-07-13 13:13:47','2026-10-05 13:13:47'),(7,'OP-0007','Contrato Premium 24/7',7,13,NULL,6,'contrato',21600.00,25,'2026-11-04',NULL,6,'redes','abierta',NULL,NULL,'Oportunidad generada a partir de conversaciones con el cliente.','2026-08-04 13:13:47','2026-10-05 13:13:47'),(8,'OP-0008','Renovación contrato Business',8,15,NULL,3,'renovacion',11400.00,50,'2026-10-15',NULL,6,'referido','abierta',NULL,NULL,'Oportunidad generada a partir de conversaciones con el cliente.','2026-08-24 13:13:47','2026-10-05 13:13:47'),(9,'OP-0009','Implementación de telefonía IP',6,1,NULL,6,'proyecto',9800.00,25,'2026-12-04',NULL,7,'correo','abierta',NULL,NULL,'Oportunidad generada a partir de conversaciones con el cliente.','2026-07-08 13:13:47','2026-10-12 00:05:27'),(10,'OP-0010','Mantenimiento preventivo anual',6,3,NULL,5,'servicio',8400.00,100,'2026-09-23','2026-09-23',6,'llamada','ganada',NULL,NULL,'Oportunidad generada a partir de conversaciones con el cliente.','2026-09-07 13:13:47','2026-10-05 13:13:47'),(11,'OP-0011','Servidor de archivos NAS',3,5,NULL,5,'equipos',12600.00,100,'2026-09-10','2026-09-10',6,'web','ganada',NULL,NULL,'Oportunidad generada a partir de conversaciones con el cliente.','2026-08-24 13:13:47','2026-10-05 13:13:47'),(12,'OP-0012','Contrato Básico soporte remoto',4,7,NULL,5,'contrato',5040.00,100,'2026-08-26','2026-08-26',7,'referido','ganada',NULL,NULL,'Oportunidad generada a partir de conversaciones con el cliente.','2026-07-18 13:13:47','2026-10-05 13:13:47'),(13,'OP-0013','Auditoría de red y licencias',5,9,NULL,6,'servicio',6500.00,0,'2026-09-17','2026-09-17',6,'web','perdida','Decidió postergar el proyecto',NULL,'Oportunidad generada a partir de conversaciones con el cliente.','2026-08-14 13:13:47','2026-10-05 13:13:47'),(14,'OP-0014','Cambio de switches core',6,11,NULL,6,'equipos',19800.00,0,'2026-09-02','2026-09-02',6,'evento','perdida','Precio superior a la competencia',NULL,'Oportunidad generada a partir de conversaciones con el cliente.','2026-08-04 13:13:47','2026-10-05 13:13:47'),(15,'OP-0015','Oportunidad - Clínica Santa Elena',10,NULL,6,1,'contrato',12000.00,10,'2026-11-25',NULL,6,'referido','abierta',NULL,NULL,NULL,'2026-10-11 17:05:05','2026-10-12 00:05:31');

CREATE TABLE `crm_cotizaciones` (
    `id` BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    `codigo` VARCHAR(20) NOT NULL UNIQUE,
    `cliente_id` BIGINT UNSIGNED NOT NULL,
    `oportunidad_id` BIGINT UNSIGNED NULL,
    `contacto_id` BIGINT UNSIGNED NULL,
    `fecha` DATE NOT NULL,
    `valida_hasta` DATE NOT NULL,
    `estado` VARCHAR(20) NOT NULL DEFAULT 'borrador',
    `descuento_pct` DECIMAL(5,2) NOT NULL DEFAULT 0.00,
    `igv_pct` DECIMAL(5,2) NOT NULL DEFAULT 18.00,
    `subtotal` DECIMAL(12,2) NOT NULL DEFAULT 0.00,
    `descuento` DECIMAL(12,2) NOT NULL DEFAULT 0.00,
    `igv` DECIMAL(12,2) NOT NULL DEFAULT 0.00,
    `total` DECIMAL(12,2) NOT NULL DEFAULT 0.00,
    `condiciones` TEXT NULL,
    `notas` TEXT NULL,
    `creado_por` BIGINT UNSIGNED NULL,
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

INSERT INTO `crm_cotizaciones` VALUES (2,'COT-0002',2,2,3,'2026-09-30','2026-10-15','enviada',0.00,18.00,35400.00,0.00,6372.00,41772.00,'• Precios en soles (S/). Incluyen IGV.\n• Forma de pago: 50% al aceptar, 50% contra entrega.\n• Plazo de entrega/implementación: según cronograma acordado.\n• Garantía de 12 meses en equipos y 30 días en servicios.',NULL,1,'2026-10-05 13:13:47'),(3,'COT-0003',4,4,7,'2026-10-05','2026-10-20','borrador',0.00,18.00,11400.00,0.00,2052.00,13452.00,'• Precios en soles (S/). Incluyen IGV.\n• Forma de pago: 50% al aceptar, 50% contra entrega.\n• Plazo de entrega/implementación: según cronograma acordado.\n• Garantía de 12 meses en equipos y 30 días en servicios.',NULL,1,'2026-10-05 13:13:47'),(4,'COT-0004',3,11,5,'2026-09-05','2026-09-20','aprobada',0.00,18.00,11700.00,0.00,2106.00,13806.00,'• Precios en soles (S/). Incluyen IGV.\n• Forma de pago: 50% al aceptar, 50% contra entrega.\n• Plazo de entrega/implementación: según cronograma acordado.\n• Garantía de 12 meses en equipos y 30 días en servicios.',NULL,1,'2026-10-05 13:13:47'),(5,'COT-0005',5,13,9,'2026-09-15','2026-09-30','rechazada',0.00,18.00,5500.00,0.00,990.00,6490.00,'• Precios en soles (S/). Incluyen IGV.\n• Forma de pago: 50% al aceptar, 50% contra entrega.\n• Plazo de entrega/implementación: según cronograma acordado.\n• Garantía de 12 meses en equipos y 30 días en servicios.',NULL,1,'2026-10-05 13:13:47');

CREATE TABLE `crm_cotizacion_items` (
    `id` BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    `cotizacion_id` BIGINT UNSIGNED NOT NULL,
    `descripcion` VARCHAR(255) NOT NULL,
    `cantidad` DECIMAL(10,2) NOT NULL DEFAULT 1.00,
    `precio_unit` DECIMAL(12,2) NOT NULL DEFAULT 0.00,
    CONSTRAINT `fk_ci_coti` FOREIGN KEY (`cotizacion_id`) REFERENCES `crm_cotizaciones` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

INSERT INTO `crm_cotizacion_items` VALUES (4,2,'Migración de servidores a nube híbrida',1.00,24000.00),(5,2,'Licenciamiento cloud (12 meses)',1.00,9600.00),(6,2,'Capacitación al personal TI',1.00,1800.00),(7,3,'Plan Business · soporte mensual (12 meses)',12.00,950.00),(8,4,'NAS 4 bahías 16 TB',1.00,7800.00),(9,4,'Instalación y configuración',1.00,1500.00),(10,4,'Backup remoto (12 meses)',1.00,2400.00),(11,5,'Auditoría de red y licencias',1.00,5500.00);

CREATE TABLE `crm_actividades` (
    `id` BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    `tipo` VARCHAR(20) NOT NULL,
    `asunto` VARCHAR(150) NOT NULL,
    `detalle` TEXT NULL,
    `fecha` DATETIME NOT NULL,
    `completada` TINYINT(1) NOT NULL DEFAULT 0,
    `completada_at` DATETIME NULL,
    `resultado` VARCHAR(255) NULL,
    `auto` TINYINT(1) NOT NULL DEFAULT 0,
    `cliente_id` BIGINT UNSIGNED NULL,
    `lead_id` BIGINT UNSIGNED NULL,
    `oportunidad_id` BIGINT UNSIGNED NULL,
    `responsable_id` BIGINT UNSIGNED NULL,
    `creado_por` BIGINT UNSIGNED NULL,
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

INSERT INTO `crm_actividades` VALUES (2,'reunion','Reunión de presentación de propuesta',NULL,'2026-10-05 10:30:00',0,NULL,NULL,0,2,NULL,2,6,1,'2026-10-05 13:13:47'),(3,'correo','Enviar cotización actualizada',NULL,'2026-10-05 11:00:00',0,NULL,NULL,0,5,NULL,5,7,1,'2026-10-05 13:13:47'),(4,'tarea','Preparar demo de monitoreo 24/7',NULL,'2026-10-06 12:30:00',0,NULL,NULL,0,7,NULL,7,6,1,'2026-10-05 13:13:47'),(5,'visita','Visita técnica para levantamiento de cableado',NULL,'2026-10-07 13:00:00',0,NULL,NULL,0,3,NULL,3,6,1,'2026-10-05 13:13:47'),(6,'llamada','Seguimiento a renovación de contrato',NULL,'2026-10-04 14:30:00',0,NULL,NULL,0,1,NULL,1,7,1,'2026-10-05 13:13:47'),(7,'reunion','Negociación final de condiciones',NULL,'2026-10-08 15:00:00',0,NULL,NULL,0,5,NULL,5,6,1,'2026-10-05 13:13:47'),(8,'tarea','Revisar propuesta económica con gerencia',NULL,'2026-10-10 16:30:00',0,NULL,NULL,0,4,NULL,4,6,1,'2026-10-05 13:13:47'),(9,'llamada','Primer contacto con lead del evento',NULL,'2026-10-05 09:00:00',0,NULL,NULL,0,NULL,3,NULL,7,1,'2026-10-05 13:13:47'),(10,'correo','Enviar brochure de servicios',NULL,'2026-10-06 10:30:00',0,NULL,NULL,0,NULL,5,NULL,6,1,'2026-10-05 13:13:47'),(11,'llamada','Calificar necesidades del lead',NULL,'2026-10-02 11:00:00',0,NULL,NULL,0,NULL,2,NULL,6,1,'2026-10-05 13:13:47'),(12,'reunion','Reunión de kick-off',NULL,'2026-09-25 12:30:00',1,'2026-09-25 12:30:00','Reunión realizada. Cliente interesado, se acordó enviar propuesta.',0,2,NULL,10,7,1,'2026-10-05 13:13:47'),(13,'nota','Oportunidad ganada: Mantenimiento preventivo anual',NULL,'2026-09-25 13:13:47',1,'2026-09-07 13:13:47',NULL,1,2,NULL,10,NULL,1,'2026-10-05 13:13:47'),(14,'nota','Oportunidad ganada: Servidor de archivos NAS',NULL,'2026-09-25 13:13:47',1,'2026-08-24 13:13:47',NULL,1,3,NULL,11,NULL,2,'2026-10-05 13:13:47'),(15,'nota','Oportunidad ganada: Contrato Básico soporte remoto',NULL,'2026-09-25 13:13:47',1,'2026-07-18 13:13:47',NULL,1,4,NULL,12,NULL,7,'2026-10-05 13:13:47'),(16,'nota','Etapa: Calificación → Propuesta',NULL,'2026-10-09 00:04:36',1,'2026-10-09 00:04:36',NULL,1,3,NULL,3,6,1,'2026-10-09 00:04:36');

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

-- ----------------------------------------------------------------------------
-- 6. BASE DE DATOS: db_billing (Facturacion, Secuencias, Comprobantes, Pagos)
-- ----------------------------------------------------------------------------
CREATE DATABASE IF NOT EXISTS `db_billing` CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
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
    `tipo` VARCHAR(20) NOT NULL DEFAULT 'factura',
    `serie` VARCHAR(6) NOT NULL,
    `numero` INT UNSIGNED NOT NULL,
    `codigo` VARCHAR(20) NOT NULL UNIQUE,
    `cliente_id` BIGINT UNSIGNED NOT NULL,
    `concepto` VARCHAR(20) NOT NULL DEFAULT 'servicio',
    `contrato_id` BIGINT UNSIGNED NULL,
    `orden_id` BIGINT UNSIGNED NULL,
    `cotizacion_id` BIGINT UNSIGNED NULL,
    `periodo` VARCHAR(7) NULL,
    `fecha_emision` DATE NOT NULL,
    `fecha_vencimiento` DATE NOT NULL,
    `igv_pct` DECIMAL(5,2) NOT NULL DEFAULT 18.00,
    `subtotal` DECIMAL(12,2) NOT NULL DEFAULT 0.00,
    `igv` DECIMAL(12,2) NOT NULL DEFAULT 0.00,
    `total` DECIMAL(12,2) NOT NULL DEFAULT 0.00,
    `pagado` DECIMAL(12,2) NOT NULL DEFAULT 0.00,
    `estado` VARCHAR(20) NOT NULL DEFAULT 'emitida',
    `motivo_anulacion` VARCHAR(200) NULL,
    `notas` VARCHAR(500) NULL,
    `creado_por` BIGINT UNSIGNED NULL,
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE KEY `uq_fac_serie_num` (`serie`, `numero`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

INSERT INTO `fac_comprobantes` VALUES (1,'factura','F001',1,'F001-000001',1,'mensualidad',1,NULL,NULL,'2026-07','2026-07-05','2026-07-20',18.00,1800.00,324.00,2124.00,2124.00,'pagada',NULL,NULL,1,'2026-10-05 18:30:44'),(2,'factura','F001',2,'F001-000002',1,'mensualidad',1,NULL,NULL,'2026-08','2026-08-05','2026-08-20',18.00,1800.00,324.00,2124.00,0.00,'emitida',NULL,NULL,1,'2026-10-05 18:30:45'),(3,'factura','F001',3,'F001-000003',1,'mensualidad',1,NULL,NULL,'2026-09','2026-09-05','2026-09-20',18.00,1800.00,324.00,2124.00,0.00,'emitida',NULL,NULL,1,'2026-10-05 18:30:45'),(4,'factura','F001',4,'F001-000004',2,'mensualidad',2,NULL,NULL,'2026-07','2026-07-05','2026-07-20',18.00,950.00,171.00,1121.00,1121.00,'pagada',NULL,NULL,1,'2026-10-05 18:30:45'),(5,'factura','F001',5,'F001-000005',2,'mensualidad',2,NULL,NULL,'2026-08','2026-08-05','2026-08-20',18.00,950.00,171.00,1121.00,1121.00,'pagada',NULL,NULL,1,'2026-10-05 18:30:45'),(6,'factura','F001',6,'F001-000006',2,'mensualidad',2,NULL,NULL,'2026-09','2026-09-05','2026-09-20',18.00,950.00,171.00,1121.00,560.50,'emitida',NULL,NULL,1,'2026-10-05 18:30:45'),(7,'factura','F001',7,'F001-000007',3,'mensualidad',3,NULL,NULL,'2026-07','2026-07-05','2026-07-20',18.00,420.00,75.60,495.60,495.60,'pagada',NULL,NULL,1,'2026-10-05 18:30:45'),(8,'factura','F001',8,'F001-000008',3,'mensualidad',3,NULL,NULL,'2026-08','2026-08-05','2026-08-20',18.00,420.00,75.60,495.60,495.60,'pagada',NULL,NULL,1,'2026-10-05 18:30:45'),(9,'factura','F001',9,'F001-000009',3,'mensualidad',3,NULL,NULL,'2026-09','2026-09-05','2026-09-20',18.00,420.00,75.60,495.60,495.60,'pagada',NULL,NULL,1,'2026-10-05 18:30:45'),(10,'factura','F001',10,'F001-000010',4,'mensualidad',4,NULL,NULL,'2026-07','2026-07-05','2026-07-20',18.00,1800.00,324.00,2124.00,2124.00,'pagada',NULL,NULL,1,'2026-10-05 18:30:45'),(11,'factura','F001',11,'F001-000011',4,'mensualidad',4,NULL,NULL,'2026-08','2026-08-05','2026-08-20',18.00,1800.00,324.00,2124.00,2124.00,'pagada',NULL,NULL,1,'2026-10-05 18:30:45'),(12,'factura','F001',12,'F001-000012',4,'mensualidad',4,NULL,NULL,'2026-09','2026-09-05','2026-09-20',18.00,1800.00,324.00,2124.00,0.00,'emitida',NULL,NULL,1,'2026-10-05 18:30:45'),(13,'factura','F001',13,'F001-000013',5,'mensualidad',5,NULL,NULL,'2026-07','2026-07-05','2026-07-20',18.00,950.00,171.00,1121.00,1121.00,'pagada',NULL,NULL,1,'2026-10-05 18:30:45'),(14,'factura','F001',14,'F001-000014',5,'mensualidad',5,NULL,NULL,'2026-08','2026-08-05','2026-08-20',18.00,950.00,171.00,1121.00,0.00,'emitida',NULL,NULL,1,'2026-10-05 18:30:45'),(15,'factura','F001',15,'F001-000015',5,'mensualidad',5,NULL,NULL,'2026-09','2026-09-05','2026-09-20',18.00,950.00,171.00,1121.00,560.50,'emitida',NULL,NULL,1,'2026-10-05 18:30:45'),(16,'factura','F001',16,'F001-000016',6,'mensualidad',6,NULL,NULL,'2026-07','2026-07-05','2026-07-20',18.00,420.00,75.60,495.60,495.60,'pagada',NULL,NULL,1,'2026-10-05 18:30:45'),(17,'factura','F001',17,'F001-000017',6,'mensualidad',6,NULL,NULL,'2026-08','2026-08-05','2026-08-20',18.00,420.00,75.60,495.60,495.60,'pagada',NULL,NULL,1,'2026-10-05 18:30:45'),(18,'factura','F001',18,'F001-000018',6,'mensualidad',6,NULL,NULL,'2026-09','2026-09-05','2026-09-20',18.00,420.00,75.60,495.60,495.60,'pagada',NULL,NULL,1,'2026-10-05 18:30:45'),(19,'factura','F001',19,'F001-000019',7,'mensualidad',7,NULL,NULL,'2026-07','2026-07-05','2026-07-20',18.00,1800.00,324.00,2124.00,2124.00,'pagada',NULL,NULL,1,'2026-10-05 18:30:45'),(20,'factura','F001',20,'F001-000020',7,'mensualidad',7,NULL,NULL,'2026-08','2026-08-05','2026-08-20',18.00,1800.00,324.00,2124.00,2124.00,'pagada',NULL,NULL,1,'2026-10-05 18:30:45'),(21,'factura','F001',21,'F001-000021',7,'mensualidad',7,NULL,NULL,'2026-09','2026-09-05','2026-09-20',18.00,1800.00,324.00,2124.00,0.00,'emitida',NULL,NULL,1,'2026-10-05 18:30:45'),(22,'factura','F001',22,'F001-000022',8,'mensualidad',8,NULL,NULL,'2026-07','2026-07-05','2026-07-20',18.00,950.00,171.00,1121.00,1121.00,'pagada',NULL,NULL,1,'2026-10-05 18:30:45'),(23,'factura','F001',23,'F001-000023',8,'mensualidad',8,NULL,NULL,'2026-08','2026-08-05','2026-08-20',18.00,950.00,171.00,1121.00,1121.00,'pagada',NULL,NULL,1,'2026-10-05 18:30:45'),(24,'factura','F001',24,'F001-000024',8,'mensualidad',8,NULL,NULL,'2026-09','2026-09-05','2026-09-20',18.00,950.00,171.00,1121.00,560.50,'emitida',NULL,NULL,1,'2026-10-05 18:30:45'),(25,'factura','F001',25,'F001-000025',1,'servicio',NULL,1,NULL,NULL,'2026-08-28','2026-09-04',18.00,99.00,17.82,116.82,0.00,'emitida',NULL,NULL,1,'2026-10-05 18:30:45'),(26,'factura','F001',26,'F001-000026',2,'servicio',NULL,2,NULL,NULL,'2026-09-24','2026-10-01',18.00,357.00,64.26,421.26,421.26,'pagada',NULL,NULL,1,'2026-10-05 18:30:45'),(27,'factura','F001',27,'F001-000027',3,'servicio',NULL,3,NULL,NULL,'2026-08-25','2026-09-01',18.00,383.00,68.94,451.94,0.00,'emitida',NULL,NULL,1,'2026-10-05 18:30:45'),(28,'factura','F001',28,'F001-000028',4,'servicio',NULL,4,NULL,NULL,'2026-08-06','2026-08-13',18.00,288.50,51.93,340.43,340.43,'pagada',NULL,NULL,1,'2026-10-05 18:30:45'),(29,'factura','F001',29,'F001-000029',5,'servicio',NULL,5,NULL,NULL,'2026-09-10','2026-09-17',18.00,396.50,71.37,467.87,0.00,'emitida',NULL,NULL,1,'2026-10-05 18:30:45'),(30,'factura','F001',30,'F001-000030',6,'servicio',NULL,6,NULL,NULL,'2026-08-26','2026-09-02',18.00,604.50,108.81,713.31,713.31,'pagada',NULL,NULL,1,'2026-10-05 18:30:45'),(31,'factura','F001',31,'F001-000031',3,'equipos',NULL,NULL,4,NULL,'2026-09-07','2026-10-07',18.00,11700.00,2106.00,13806.00,13806.00,'pagada',NULL,NULL,1,'2026-10-05 18:30:45');

CREATE TABLE `fac_items` (
    `id` BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    `comprobante_id` BIGINT UNSIGNED NOT NULL,
    `descripcion` VARCHAR(255) NOT NULL,
    `cantidad` DECIMAL(10,2) NOT NULL DEFAULT 1.00,
    `precio_unit` DECIMAL(12,2) NOT NULL DEFAULT 0.00,
    CONSTRAINT `fk_fi_comp` FOREIGN KEY (`comprobante_id`) REFERENCES `fac_comprobantes` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

INSERT INTO `fac_items` VALUES (1,1,'Soporte TI plan Premium · 2026-07',1.00,1800.00),(2,2,'Soporte TI plan Premium · 2026-08',1.00,1800.00),(3,3,'Soporte TI plan Premium · 2026-09',1.00,1800.00),(4,4,'Soporte TI plan Business · 2026-07',1.00,950.00),(5,5,'Soporte TI plan Business · 2026-08',1.00,950.00),(6,6,'Soporte TI plan Business · 2026-09',1.00,950.00),(7,7,'Soporte TI plan Básico · 2026-07',1.00,420.00),(8,8,'Soporte TI plan Básico · 2026-08',1.00,420.00),(9,9,'Soporte TI plan Básico · 2026-09',1.00,420.00),(10,10,'Soporte TI plan Premium · 2026-07',1.00,1800.00),(11,11,'Soporte TI plan Premium · 2026-08',1.00,1800.00),(12,12,'Soporte TI plan Premium · 2026-09',1.00,1800.00),(13,13,'Soporte TI plan Business · 2026-07',1.00,950.00),(14,14,'Soporte TI plan Business · 2026-08',1.00,950.00),(15,15,'Soporte TI plan Business · 2026-09',1.00,950.00),(16,16,'Soporte TI plan Básico · 2026-07',1.00,420.00),(17,17,'Soporte TI plan Básico · 2026-08',1.00,420.00),(18,18,'Soporte TI plan Básico · 2026-09',1.00,420.00),(19,19,'Soporte TI plan Premium · 2026-07',1.00,1800.00),(20,20,'Soporte TI plan Premium · 2026-08',1.00,1800.00),(21,21,'Soporte TI plan Premium · 2026-09',1.00,1800.00),(22,22,'Soporte TI plan Business · 2026-07',1.00,950.00),(23,23,'Soporte TI plan Business · 2026-08',1.00,950.00),(24,24,'Soporte TI plan Business · 2026-09',1.00,950.00),(25,25,'Mano de obra correctiva · OS-2026-001',2.20,45.00),(26,26,'Mano de obra preventiva · OS-2026-002',2.60,45.00),(27,26,'Fuente de poder 500W',2.00,120.00),(28,27,'Mano de obra instalacion · OS-2026-003',6.40,45.00),(29,27,'Memoria RAM DDR4 8GB',1.00,95.00),(30,28,'Mano de obra diagnostico · OS-2026-004',2.30,45.00),(31,28,'Disco SSD 480GB',1.00,185.00),(32,29,'Mano de obra correctiva · OS-2026-005',6.70,45.00),(33,29,'Memoria RAM DDR4 8GB',1.00,95.00),(34,30,'Mano de obra preventiva · OS-2026-006',4.10,45.00),(35,30,'Batería laptop Dell',2.00,210.00),(36,31,'NAS 4 bahías 16 TB',1.00,7800.00),(37,31,'Instalación y configuración',1.00,1500.00),(38,31,'Backup remoto (12 meses)',1.00,2400.00);

CREATE TABLE `fac_pagos` (
    `id` BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    `comprobante_id` BIGINT UNSIGNED NOT NULL,
    `fecha` DATE NOT NULL,
    `monto` DECIMAL(12,2) NOT NULL,
    `metodo` VARCHAR(20) NOT NULL DEFAULT 'transferencia',
    `referencia` VARCHAR(80) NULL,
    `notas` VARCHAR(200) NULL,
    `registrado_por` BIGINT UNSIGNED NULL,
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT `fk_fp_comp` FOREIGN KEY (`comprobante_id`) REFERENCES `fac_comprobantes` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

INSERT INTO `fac_pagos` VALUES (1,1,'2026-07-16',2124.00,'transferencia','OP-4001',NULL,1,'2026-10-05 18:30:45'),(2,4,'2026-07-16',1121.00,'efectivo','OP-4004',NULL,1,'2026-10-05 18:30:45'),(3,5,'2026-08-16',1121.00,'plin','OP-4005',NULL,1,'2026-10-05 18:30:45'),(4,6,'2026-09-16',560.50,'transferencia','OP-4006',NULL,1,'2026-10-05 18:30:45'),(5,7,'2026-07-16',495.60,'transferencia','OP-4007',NULL,1,'2026-10-05 18:30:45'),(6,8,'2026-08-16',495.60,'yape','OP-4008',NULL,1,'2026-10-05 18:30:45'),(7,9,'2026-09-16',495.60,'deposito','OP-4009',NULL,1,'2026-10-05 18:30:45'),(8,10,'2026-07-16',2124.00,'efectivo','OP-4010',NULL,1,'2026-10-05 18:30:45'),(9,11,'2026-08-16',2124.00,'plin','OP-4011',NULL,1,'2026-10-05 18:30:45'),(10,13,'2026-07-16',1121.00,'transferencia','OP-4013',NULL,1,'2026-10-05 18:30:45'),(11,15,'2026-09-16',560.50,'deposito','OP-4015',NULL,1,'2026-10-05 18:30:45'),(12,16,'2026-07-16',495.60,'efectivo','OP-4016',NULL,1,'2026-10-05 18:30:45'),(13,17,'2026-08-16',495.60,'plin','OP-4017',NULL,1,'2026-10-05 18:30:45'),(14,18,'2026-09-16',495.60,'transferencia','OP-4018',NULL,1,'2026-10-05 18:30:45'),(15,19,'2026-07-16',2124.00,'transferencia','OP-4019',NULL,1,'2026-10-05 18:30:45'),(16,20,'2026-08-16',2124.00,'yape','OP-4020',NULL,1,'2026-10-05 18:30:45'),(17,22,'2026-07-16',1121.00,'efectivo','OP-4022',NULL,1,'2026-10-05 18:30:45'),(18,23,'2026-08-16',1121.00,'plin','OP-4023',NULL,1,'2026-10-05 18:30:45'),(19,24,'2026-09-16',560.50,'transferencia','OP-4024',NULL,1,'2026-10-05 18:30:45'),(20,26,'2026-09-27',421.26,'yape','OP-4026',NULL,1,'2026-10-05 18:30:45'),(21,28,'2026-08-09',340.43,'efectivo','OP-4028',NULL,1,'2026-10-05 18:30:45'),(22,30,'2026-08-29',713.31,'transferencia','OP-4030',NULL,1,'2026-10-05 18:30:45'),(23,31,'2026-10-11',13806.00,'transferencia','PAGO-APP-001',NULL,NULL,'2026-10-11 23:33:02');

CREATE TABLE `fac_secuencias` (
    `serie` VARCHAR(6) PRIMARY KEY,
    `ultimo_numero` INT UNSIGNED NOT NULL DEFAULT 0,
    `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

INSERT INTO `fac_secuencias` (`serie`, `ultimo_numero`) VALUES 
('F001', 31), 
('B001', 0)
ON DUPLICATE KEY UPDATE `ultimo_numero` = VALUES(`ultimo_numero`);

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

-- ----------------------------------------------------------------------------
-- 7. BASE DE DATOS: db_notification (Envios, Plantillas y Registro Asincrono)
-- ----------------------------------------------------------------------------
CREATE DATABASE IF NOT EXISTS `db_notification` CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE `db_notification`;

DROP TABLE IF EXISTS `notif_envios`;
DROP TABLE IF EXISTS `outbox_events`;
DROP TABLE IF EXISTS `consumed_messages`;

CREATE TABLE `notif_envios` (
    `id` BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    `canal` VARCHAR(20) NOT NULL DEFAULT 'correo',
    `destinatario` VARCHAR(160) NOT NULL,
    `asunto` VARCHAR(200) NOT NULL,
    `cuerpo` MEDIUMTEXT NULL,
    `estado` VARCHAR(20) NOT NULL DEFAULT 'simulado',
    `error` VARCHAR(255) NULL,
    `cliente_id` BIGINT UNSIGNED NULL,
    `ticket_id` BIGINT UNSIGNED NULL,
    `cotizacion_id` BIGINT UNSIGNED NULL,
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    `orden_id` BIGINT NULL,
    INDEX `idx_notif_fec` (`created_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

INSERT INTO `notif_envios` (`id`, `canal`, `destinatario`, `asunto`, `cuerpo`, `estado`, `error`, `cliente_id`, `ticket_id`, `cotizacion_id`, `created_at`, `orden_id`) VALUES
(1, 'correo', 'ti@cliente1.pe', 'Ticket Creado: TCK-0001 Enlace de red intermitente', 'Estimado cliente, su ticket ha sido registrado en NexusDesk Pro Cloud y asignado a nuestro equipo tecnico.', 'enviado', NULL, 1, 1, NULL, '2026-10-06 09:05:00', NULL),
(2, 'whatsapp', '+51987654321', 'Notificación de Soporte: OS-0001 Programada', 'Se ha programado una visita técnica para el 08/10/2026 a las 10:00 AM con el especialista Brayan Hurtado.', 'enviado', NULL, 1, 1, NULL, '2026-10-06 10:00:00', 1),
(3, 'correo', 'ti@cliente2.pe', 'Cotización Emitida: COT-0002 Migración Cloud Híbrida', 'Adjuntamos propuesta comercial para la renovación y migración de su centro de cómputo.', 'enviado', NULL, 2, NULL, 2, '2026-10-07 14:30:00', NULL),
(4, 'correo', 'ti@cliente3.pe', 'Comprobante Electrónico F001-00000001', 'Su factura del periodo 2026-10 se encuentra disponible para descarga en el portal.', 'enviado', NULL, 3, NULL, NULL, '2026-10-08 08:00:00', NULL),
(5, 'correo', 'ti@cliente1.pe', 'Ticket Resuelto: TCK-0001 Enlace de red intermitente', 'El ticket ha sido marcado como RESUELTO tras confirmar estabilidad de la conexión.', 'enviado', NULL, 1, 1, NULL, '2026-10-08 17:00:00', NULL),
(6, 'whatsapp', '+51999222333', 'Alerta SLA: Ticket por vencer', 'Alerta interna para supervisión: Ticket TCK-0005 requiere seguimiento prioritario.', 'simulado', NULL, 2, 5, NULL, '2026-10-09 11:15:00', NULL),
(7, 'correo', 'contacto@automatizado.pe', 'Bienvenida a NexusDesk Pro Cloud', 'Su cuenta de acceso al portal de autoservicio ha sido activada correctamente.', 'enviado', NULL, 9, NULL, NULL, '2026-10-10 16:00:00', NULL);

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

-- ----------------------------------------------------------------------------
-- FINALIZACIÓN Y RESTAURACIÓN DE CHECKS
-- ----------------------------------------------------------------------------
SET FOREIGN_KEY_CHECKS = @OLD_FOREIGN_KEY_CHECKS;
SET SQL_MODE = @OLD_SQL_MODE;

-- ============================================================================
-- FIN DEL SCRIPT MAESTRO ENRIQUECIDO DE NEXUSDESK PRO CLOUD
-- ============================================================================
