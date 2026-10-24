-- ============================================================================
-- NEXUSDESK PRO CLOUD — MASTER MEGA-ENRICHED PRODUCTION DATABASE SUITE (2026)
-- Arquitectura Multi-Database: Spring Boot 4.0.8 / Java 25 LTS & Angular 21 LTS
-- Evaluacion Academica CIBERTEC - DAW II (Ciclo 2026-I)
-- Coordinador General TI / Administrador: Jhonny Samuel Chaupis Alvarez
-- Integrantes: Carlos Hinojosa, Brayan Hurtado, Mathias Alayo
-- ============================================================================

SET @OLD_SQL_MODE=@@SQL_MODE;
SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS;
SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;
SET SQL_MODE = 'NO_AUTO_VALUE_ON_ZERO';

-- ----------------------------------------------------------------------------
-- 1. BASE DE DATOS: db_auth (Seguridad, Roles, Usuarios, Auditoría y Backups)
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
    `horario_atencion` VARCHAR(120) NULL DEFAULT 'Lunes a Viernes 08:00 - 19:00 | Mesa de Guardia 24/7',
    `ruc` VARCHAR(15) NULL DEFAULT '20601234567',
    `doc_etiqueta` VARCHAR(10) NULL DEFAULT 'RUC',
    `giro` VARCHAR(100) NULL DEFAULT 'Servicios integrales de infraestructura, nube híbrida y mesa de ayuda TI',
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
    `tarifa_hora_defecto` DECIMAL(8,2) NOT NULL DEFAULT 65.00,
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
    `smtp_nombre` VARCHAR(150) NULL DEFAULT 'NexusDesk Cloud Alerts & Notifications',
    `notif_copia` VARCHAR(150) NULL DEFAULT 'mesa@nexusdesk.pe',
    `notif_ticket_creado` TINYINT(1) NULL DEFAULT 1,
    `notif_ticket_estado` TINYINT(1) NULL DEFAULT 1,
    `notif_ticket_respuesta` TINYINT(1) NULL DEFAULT 1,
    `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

INSERT INTO `company_config` (`id`, `nombre`, `razon_social`, `eslogan`, `ciudad`, `pais`, `horario_atencion`, `ruc`, `doc_etiqueta`, `giro`, `direccion`, `telefono`, `email`, `web`, `zona_horaria`, `moneda_simbolo`, `moneda_codigo`, `moneda_pos`, `moneda_espacio`, `moneda_decimales`, `sep_decimal`, `sep_miles`, `impuesto_nombre`, `igv_pct`, `tarifa_hora_defecto`, `formato_fecha`, `color_marca`, `pie_documentos`, `cuentas_bancarias_json`, `detraccion_json`)
VALUES (1, 'NexusDesk — Gestión Integral de Servicios TI', 'NEXUSDESK SOLUTIONS PERU S.A.C.', 'Soporte TI de Misión Crítica & SLA 24/7 Cloud', 'Lima', 'Perú', 'Lunes a Viernes 08:00 - 19:00 | Mesa de Guardia 24/7', '20601234567', 'RUC', 'Servicios integrales de infraestructura, nube híbrida y mesa de ayuda TI', 'Av. Javier Prado Este 4567, San Isidro, Lima, Perú', '+51 (01) 710-9000', 'contacto@nexusdesk.pe', 'https://nexusdesk.pe', 'America/Lima', 'S/', 'PEN', 'antes', 1, 2, '.', ',', 'IGV', 18.00, 65.00, 'd/m/Y', 'indigo', 'NexusDesk Pro Cloud - Tecnología de Nivel Empresarial para Soporte de Misión Crítica', '[{"banco":"Banco de Crédito del Perú (BCP)","moneda":"PEN","tipo":"Corriente","numero":"193-2894102-0-45","cci":"002-193-002894102045-18","titular":"NEXUSDESK SOLUTIONS PERU S.A.C."},{"banco":"Banco de Crédito del Perú (BCP)","moneda":"USD","tipo":"Corriente","numero":"193-3981245-1-89","cci":"002-193-003981245189-12","titular":"NEXUSDESK SOLUTIONS PERU S.A.C."},{"banco":"BBVA Perú","moneda":"PEN","tipo":"Corriente","numero":"0011-0175-0100049281","cci":"011-175-000100049281-75","titular":"NEXUSDESK SOLUTIONS PERU S.A.C."},{"banco":"Interbank","moneda":"PEN","tipo":"Corriente","numero":"200-3001892451","cci":"003-200-003001892451-33","titular":"NEXUSDESK SOLUTIONS PERU S.A.C."}]', '{"banco":"Banco de la Nación","cuenta":"00-054-987654","tasa":12.0,"concepto":"Demás servicios empresariales de tecnología e información","titular":"NEXUSDESK SOLUTIONS PERU S.A.C."}')
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
(1, 'nexusdesk_backup_full_20261001_0300.sql', 'COMPLETO', '2026-10-01 03:00:00', '14.2 MB', 14890120, 25, 4200, '4a2b1c8d9e0f1a2b3c4d5e6f7a8b9c0d1e2f3a4b5c6d7e8f9a0b1c2d3e4f5a6b', 'COMPLETADO', 'Jhonny Samuel Chaupis Alvarez'),
(2, 'nexusdesk_backup_diff_20261008_0300.sql', 'DIFERENCIAL', '2026-10-08 03:00:00', '3.8 MB', 3984120, 18, 1150, '8f2e3d4c5b6a7f8e9d0c1b2a3f4e5d6c7b8a9f0e1d2c3b4a5f6e7d8c9b0a1f2e', 'COMPLETADO', 'Jhonny Samuel Chaupis Alvarez'),
(3, 'nexusdesk_backup_full_20261015_0300.sql', 'COMPLETO', '2026-10-15 03:00:00', '15.5 MB', 16254100, 25, 4680, '1c3a5b7d9e1f3a5b7d9e1f3a5b7d9e1f3a5b7d9e1f3a5b7d9e1f3a5b7d9e1f3a', 'COMPLETADO', 'Jhonny Samuel Chaupis Alvarez'),
(4, 'nexusdesk_backup_diff_20261020_0300.sql', 'DIFERENCIAL', '2026-10-20 03:00:00', '4.1 MB', 4301250, 19, 1340, 'e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855', 'COMPLETADO', 'Jhonny Samuel Chaupis Alvarez'),
(5, 'nexusdesk_backup_full_20261021_0300.sql', 'COMPLETO', '2026-10-21 03:00:00', '16.2 MB', 17012450, 25, 4910, '8f434346648f6b96df89dda901c5176b10a6d83961dd3c1ac88b59b2dc327aa4', 'COMPLETADO', 'Jhonny Samuel Chaupis Alvarez'),
(6, 'nexusdesk_backup_full_20261022_0300.sql', 'COMPLETO', '2026-10-22 03:00:00', '16.5 MB', 17350120, 25, 5034, 'a6c8e310065b98f2f9f8c0a876a4df9576a8b75f85e43a1a9e29a8837e31cb02', 'COMPLETADO', 'Jhonny Samuel Chaupis Alvarez'),
(7, 'nexusdesk_backup_enriquecido_20261023_2200.sql', 'COMPLETO', '2026-10-23 22:00:00', '18.1 MB', 18980145, 25, 5280, '7b2e1f8a49c3e1098df241ba087a912c45e89d10a3c4856f71290bb34e12fa78', 'COMPLETADO', 'Jhonny Samuel Chaupis Alvarez'),
(8, 'nexusdesk_backup_snapshot_pre_sustentacion_20261024_0000.sql', 'COMPLETO', '2026-10-24 00:00:00', '19.4 MB', 20340500, 25, 5650, 'c9d8e7f6a5b4c3d2e1f0a9b8c7d6e5f4a3b2c1d0e9f8a7b6c5d4e3f2a1b0c9d8', 'COMPLETADO', 'Jhonny Samuel Chaupis Alvarez');

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
(1, 1, 'Jhonny Samuel Chaupis Alvarez', 'Inicio de Sistema', 'Plataforma NexusDesk Cloud iniciada en clúster Docker con 12 microservicios.', 'bi-check-circle', '#10b981', '2026-10-01 08:00:00'),
(2, 2, 'Carlos Daniel Hinojosa Cano', 'Supervisión de Clientes', 'Revisión y actualización de contrato SLA Platinum con Clínica San Gabriel.', 'bi-shield-check', '#0ea5e9', '2026-10-02 08:45:00'),
(3, 3, 'Brayan Luis Hurtado Sernaque', 'Asignación de Ticket', 'Ticket TCK-0001 diagnosticado y asignado para resolución inmediata.', 'bi-ticket-detailed', '#10b981', '2026-10-03 09:15:00'),
(4, 6, 'Mathias Miller Alayo Oliveros', 'Cotización Emitida', 'Cotización COT-0002 de S/ 41,772.00 enviada a Distribuidora Andina S.A.C.', 'bi-file-earmark-text', '#8b5cf6', '2026-10-04 10:20:00'),
(5, 1, 'Jhonny Samuel Chaupis Alvarez', 'Configuración de Seguridad', 'Actualización de parámetros de autenticación JWT y políticas de acceso.', 'bi-lock', '#4f46e5', '2026-10-05 11:10:00'),
(6, 3, 'Brayan Luis Hurtado Sernaque', 'Cierre de Orden de Servicio', 'Orden OS-2026-001 completada con conformidad del cliente en sitio.', 'bi-tools', '#10b981', '2026-10-06 12:30:00'),
(7, 2, 'Carlos Daniel Hinojosa Cano', 'Auditoría de Activos', 'Inventario de 60 activos corporativos verificado contra red física.', 'bi-laptop', '#0ea5e9', '2026-10-07 14:00:00'),
(8, 6, 'Mathias Miller Alayo Oliveros', 'Seguimiento Comercial', 'Llamada de cierre con Roberto Salas para contrato de soporte anual.', 'bi-telephone', '#8b5cf6', '2026-10-08 15:30:00'),
(9, 1, 'Jhonny Samuel Chaupis Alvarez', 'Respaldo de Base de Datos', 'Generación de snapshot de consistencia transaccional multi-database.', 'bi-database-check', '#4f46e5', '2026-10-09 17:00:00'),
(10, 3, 'Brayan Luis Hurtado Sernaque', 'Resolución de Ticket Crítico', 'Restablecimiento de enlace redundante FortiGate en San Isidro.', 'bi-check-all', '#10b981', '2026-10-10 18:20:00'),
(11, 4, 'Andrea Quispe', 'Mantenimiento Preventivo', 'Limpieza y cambio de pasta térmica en 8 PCs de Estudio Contable Valdivia.', 'bi-cpu', '#f59e0b', '2026-10-12 10:00:00'),
(12, 5, 'Marta Flores', 'Registro de Mesa de Partes', 'Recepción y digitalización de solicitud formal de soporte de TransPerú.', 'bi-inbox', '#ec4899', '2026-10-13 11:15:00'),
(13, 6, 'Mathias Miller Alayo Oliveros', 'Oportunidad Ganada', 'Oportunidad OP-0023 de S/ 15,400.00 aprobada por Clínica San Gabriel.', 'bi-trophy', '#10b981', '2026-10-14 16:45:00'),
(14, 1, 'Jhonny Samuel Chaupis Alvarez', 'Auditoría de Logs Syslog-ng', 'Verificación de integridad de 45,000 eventos de red sin alertas de intrusión.', 'bi-shield-shaded', '#4f46e5', '2026-10-15 09:30:00'),
(15, 2, 'Carlos Daniel Hinojosa Cano', 'Validación de Interfaz UI/UX', 'Supervisión de métricas de accesibilidad WCAG 2.1 AA en módulo de clientes.', 'bi-eye', '#0ea5e9', '2026-10-16 14:10:00'),
(16, 3, 'Brayan Luis Hurtado Sernaque', 'Cambio en Caliente de Disco', 'Reemplazo de disco SAS en servidor HPE DL380 sin detención de operaciones.', 'bi-hdd-rack', '#10b981', '2026-10-17 11:20:00'),
(17, 4, 'Andrea Quispe', 'Instalación de Punto de Acceso', 'Despliegue de UniFi U6 Enterprise WiFi 6E en Colegio Santa Rosa.', 'bi-wifi', '#f59e0b', '2026-10-18 15:30:00'),
(18, 5, 'Marta Flores', 'Actualización de Datos de Cliente', 'Registro de nuevo contacto corporativo Dr. Paredes para Clínica San Gabriel.', 'bi-person-plus', '#ec4899', '2026-10-19 10:40:00'),
(19, 6, 'Mathias Miller Alayo Oliveros', 'Envío de Cotización COT-0009', 'Propuesta de soporte anual enviada a Financiera Progreso por S/ 90,000.00.', 'bi-file-earmark-spreadsheet', '#8b5cf6', '2026-10-20 12:15:00'),
(20, 1, 'Jhonny Samuel Chaupis Alvarez', 'Configuración de Reglas DMARC', 'Endurecimiento de políticas de correo electrónico corporativo a p=reject.', 'bi-envelope-check', '#4f46e5', '2026-10-21 08:50:00'),
(21, 3, 'Brayan Luis Hurtado Sernaque', 'Certificación de Enlace Cat6A', 'Medición de atenuación y NEXT con equipo Fluke en rack de distribución.', 'bi-patch-check', '#10b981', '2026-10-22 09:45:00'),
(22, 2, 'Carlos Daniel Hinojosa Cano', 'Aprobación de Conformidad', 'Validación de cierre de orden de servicio OS-2026-017 con firma de cliente.', 'bi-check2-circle', '#0ea5e9', '2026-10-22 14:00:00'),
(23, 4, 'Andrea Quispe', 'Mantenimiento de UPS 3000VA', 'Instalación de banco de baterías de reemplazo APC en servidor de IoT.', 'bi-battery-charging', '#f59e0b', '2026-10-23 16:30:00'),
(24, 6, 'Mathias Miller Alayo Oliveros', 'Cierre de Contrato Platino', 'Aprobación final de contrato de soporte 24/7 con Financiera Progreso.', 'bi-award', '#8b5cf6', '2026-10-23 17:45:00'),
(25, 1, 'Jhonny Samuel Chaupis Alvarez', 'Generación de Backup Snapshot', 'Copia de seguridad completa pre-sustentación ejecutada exitosamente.', 'bi-cloud-arrow-up', '#4f46e5', '2026-10-23 23:00:00'),
(26, 3, 'Brayan Luis Hurtado Sernaque', 'Atención en Sitio Especializada', 'Configuración de estación médica de alta resolución en Clínica Santa Elena.', 'bi-activity', '#10b981', '2026-10-24 08:30:00'),
(27, 2, 'Carlos Daniel Hinojosa Cano', 'Monitoreo de Cumplimiento SLA', 'SLA de tickets del mes de Octubre en 98.4%, cumpliendo metas institucionales.', 'bi-graph-up-arrow', '#0ea5e9', '2026-10-24 09:00:00'),
(28, 5, 'Marta Flores', 'Apertura de Ticket TCK-01242', 'Registro de consulta de software contable para Estudio Valdivia.', 'bi-headset', '#ec4899', '2026-10-24 09:15:00'),
(29, 6, 'Mathias Miller Alayo Oliveros', 'Actualización de Pipeline CRM', 'Pipeline comercial totaliza S/ 542,000.00 con 26 oportunidades activas.', 'bi-kanban', '#8b5cf6', '2026-10-24 09:30:00'),
(30, 1, 'Jhonny Samuel Chaupis Alvarez', 'Verificación Global de Clúster', 'Clúster Docker 100% operativo con 12 microservicios sincronizados en Eureka.', 'bi-shield-fill-check', '#10b981', '2026-10-24 10:00:00');

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

INSERT INTO `contratos` VALUES (2,2,'CT-2026-002','Business',4,36,'2025-12-09','2026-11-09',950.00,'por_vencer'),(3,3,'CT-2026-003','Básico',8,72,'2025-12-09','2027-03-24',420.00,'vigente'),(4,4,'CT-2026-004','Premium',2,24,'2025-12-09','2027-05-03',1800.00,'vigente'),(5,5,'CT-2026-005','Business',4,36,'2025-12-09','2027-06-12',950.00,'vigente'),(6,6,'CT-2026-006','Básico',8,72,'2025-12-09','2027-07-22',420.00,'vigente'),(7,7,'CT-2026-007','Premium',2,24,'2025-12-09','2027-08-31',1800.00,'vigente'),(8,8,'CT-2026-008','Business',4,36,'2025-12-09','2027-10-10',950.00,'vigente'),
(1, 1, 'CT-2026-001', 'Premium', 2, 8, '2026-01-01', '2026-12-31', 4500.00, 'vigente'),
(9, 9, 'CT-2026-009', 'Personalizado', 2, 12, '2026-04-15', '2027-04-14', 5800.00, 'vigente'),
(10, 10, 'CT-2026-010', 'Premium', 2, 8, '2026-05-01', '2027-04-30', 4900.00, 'vigente'),
(11, 1, 'CT-2025-001', 'Standard', 8, 48, '2025-01-01', '2025-12-31', 2500.00, 'vencido'),
(12, 2, 'CT-2026-012', 'Business', 4, 24, '2026-10-01', '2026-11-05', 3800.00, 'por_vencer');

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

INSERT INTO `activos` VALUES (2,1,'ACT-0002','Laptop','HP','ProBook 450 G9','EAF3A11DBE','Almacén','2026-06-13','2027-06-13','operativo'),(3,1,'ACT-0003','Impresora','Epson','L6270','508F5B9E53','Gerencia','2025-11-10','2027-11-10','operativo'),(4,1,'ACT-0004','PC Escritorio','Lenovo','ThinkCentre M70','5D27461186','Almacén','2026-04-06','2028-04-05','operativo'),(5,1,'ACT-0005','Servidor','Dell','PowerEdge R450','8CB13BA029','Almacén','2025-01-26','2027-01-26','operativo'),(6,1,'ACT-0006','PC Escritorio','Lenovo','ThinkCentre M70','5B7CDC9600','Oficina TI','2026-05-02','2028-05-01','operativo'),(7,2,'ACT-0007','Laptop','HP','ProBook 450 G9','2AC5FBB019','Sala de servidores','2026-02-23','2027-02-23','operativo'),(8,2,'ACT-0008','Firewall','Fortinet','FortiGate 60F','C3DDB25F53','Recepción','2025-09-02','2026-09-02','operativo'),(9,2,'ACT-0009','PC Escritorio','Lenovo','ThinkCentre M70','30D625DAD3','Gerencia','2025-08-14','2026-08-14','en_reparacion'),(10,2,'ACT-0010','Switch','Cisco','Catalyst 2960','2BADDAA696','Gerencia','2026-08-04','2028-08-03','operativo'),(11,2,'ACT-0011','Impresora','Epson','L6270','925F90C201','Oficina TI','2024-11-18','2026-11-18','operativo'),(12,2,'ACT-0012','Access Point','Ubiquiti','UniFi U6 Pro','C083722AF0','Oficina TI','2025-04-05','2027-04-05','operativo'),(13,3,'ACT-0013','Firewall','Fortinet','FortiGate 60F','64005B1F13','Almacén','2024-09-01','2026-09-01','operativo'),(14,3,'ACT-0014','Laptop','Dell','Latitude 5440','2786A3BA88','Sala de servidores','2026-04-20','2027-04-20','en_reparacion'),(15,3,'ACT-0015','Laptop','Dell','Latitude 5440','527EE6FF0F','Sala de servidores','2025-05-19','2027-05-19','operativo'),(16,3,'ACT-0016','Switch','Cisco','Catalyst 2960','FA20E9861D','Recepción','2025-04-02','2027-04-02','operativo'),(17,3,'ACT-0017','Access Point','Ubiquiti','UniFi U6 Pro','02928AB627','Almacén','2024-12-02','2025-12-02','operativo'),(18,3,'ACT-0018','Access Point','Ubiquiti','UniFi U6 Pro','806149E4E5','Almacén','2026-05-13','2028-05-12','operativo'),(19,4,'ACT-0019','Switch','Cisco','Catalyst 2960','74472DD62E','Recepción','2025-10-27','2026-10-27','operativo'),(20,4,'ACT-0020','PC Escritorio','Lenovo','ThinkCentre M70','C869156DB7','Oficina TI','2025-11-05','2026-11-05','operativo'),(21,4,'ACT-0021','Router','MikroTik','RB4011','AB30D45EC9','Gerencia','2026-08-03','2027-08-03','operativo'),(22,4,'ACT-0022','Servidor','Dell','PowerEdge R450','9577915412','Oficina TI','2025-10-16','2026-10-16','operativo'),(23,4,'ACT-0023','Access Point','Ubiquiti','UniFi U6 Pro','20741A64C8','Sala de servidores','2026-04-25','2027-04-25','operativo'),(24,4,'ACT-0024','Laptop','HP','ProBook 450 G9','97FE7F0399','Recepción','2025-01-26','2026-01-26','operativo'),(25,5,'ACT-0025','Servidor','Dell','PowerEdge R450','E5153BCF4A','Sala de servidores','2024-12-26','2025-12-26','operativo'),(26,5,'ACT-0026','Laptop','HP','ProBook 450 G9','B1CF9681DF','Almacén','2025-03-25','2026-03-25','en_reparacion'),(27,5,'ACT-0027','Servidor','Dell','PowerEdge R450','E3045BD705','Almacén','2026-01-05','2028-01-05','operativo'),(28,5,'ACT-0028','Switch','Cisco','Catalyst 2960','F0EDC1340A','Oficina TI','2024-10-01','2026-10-01','en_reparacion'),(29,5,'ACT-0029','PC Escritorio','Lenovo','ThinkCentre M70','126C5F4680','Oficina TI','2026-07-01','2028-06-30','operativo'),(30,5,'ACT-0030','Impresora','Epson','L6270','9DE2D17649','Sala de servidores','2025-04-18','2026-04-18','operativo'),(31,6,'ACT-0031','Router','MikroTik','RB4011','624DDABC8D','Oficina TI','2025-02-28','2026-02-28','en_reparacion'),(32,6,'ACT-0032','Router','MikroTik','RB4011','886055E9E7','Oficina TI','2025-01-09','2027-01-09','operativo'),(33,6,'ACT-0033','Laptop','HP','ProBook 450 G9','7E96925442','Oficina TI','2024-09-07','2026-09-07','operativo'),(34,6,'ACT-0034','Router','MikroTik','RB4011','35193ED7EC','Oficina TI','2025-10-13','2027-10-13','operativo'),(35,6,'ACT-0035','Laptop','HP','ProBook 450 G9','08B7BBC3A1','Almacén','2024-05-27','2025-05-27','operativo'),(36,6,'ACT-0036','Laptop','Dell','Latitude 5440','B54A34380B','Sala de servidores','2024-05-26','2026-05-26','operativo'),(37,7,'ACT-0037','PC Escritorio','Lenovo','ThinkCentre M70','2FFB2F78EC','Oficina TI','2025-04-10','2026-04-10','en_reparacion'),(38,7,'ACT-0038','Firewall','Fortinet','FortiGate 60F','B0DB7E59C2','Sala de servidores','2025-04-03','2026-04-03','operativo'),(39,7,'ACT-0039','Firewall','Fortinet','FortiGate 60F','098639D302','Gerencia','2025-09-23','2026-09-23','operativo'),(40,7,'ACT-0040','Switch','Cisco','Catalyst 2960','D75AB56235','Gerencia','2025-12-20','2026-12-20','operativo'),(41,7,'ACT-0041','Laptop','HP','ProBook 450 G9','A938081397','Almacén','2024-08-12','2026-08-12','operativo'),(42,7,'ACT-0042','Switch','Cisco','Catalyst 2960','EDD2040051','Almacén','2024-11-27','2025-11-27','en_reparacion'),(43,8,'ACT-0043','Laptop','HP','ProBook 450 G9','DE71B8498B','Gerencia','2024-05-03','2026-05-03','operativo'),(44,8,'ACT-0044','Laptop','Dell','Latitude 5440','6EE362EFE9','Almacén','2025-07-29','2027-07-29','operativo'),(45,8,'ACT-0045','Laptop','HP','ProBook 450 G9','E31CB99DF6','Oficina TI','2025-05-20','2027-05-20','operativo'),(46,8,'ACT-0046','Firewall','Fortinet','FortiGate 60F','D9EE229097','Oficina TI','2026-02-01','2027-02-01','operativo'),(47,8,'ACT-0047','Impresora','Epson','L6270','7EDBE1B577','Oficina TI','2025-01-30','2026-01-30','operativo'),(48,8,'ACT-0048','Router','MikroTik','RB4011','0366652995','Sala de servidores','2026-05-29','2028-05-28','operativo'),
(1, 1, 'ACT-0001', 'Servidor', 'Dell', 'PowerEdge R640 Core', 'SN-R640-1001', 'Datacenter Principal - Rack A1', '2025-06-15', '2028-06-15', 'operativo'),
(49, 1, 'ACT-0049', 'Switch', 'Cisco', 'Catalyst 9300-48P PoE+', 'SN-C9300-8812', 'Datacenter Principal - Rack A2', '2026-02-10', '2029-02-10', 'operativo'),
(50, 2, 'ACT-0050', 'Firewall', 'Fortinet', 'FortiGate 100F Dual WAN', 'FG-100F-77491', 'Sala de Comunicaciones Central', '2026-01-20', '2028-01-20', 'operativo'),
(51, 2, 'ACT-0051', 'Almacenamiento', 'Synology', 'DiskStation DS923+ 32TB', 'SN-SYN-55219', 'Sala de Servidores - Rack B', '2026-03-05', '2028-03-05', 'operativo'),
(52, 3, 'ACT-0052', 'Punto de Acceso', 'Ubiquiti', 'UniFi U6 Enterprise WiFi 6E', 'SN-U6ENT-1102', 'Pabellón de Aulas - Piso 2', '2026-02-18', '2027-02-18', 'operativo'),
(53, 3, 'ACT-0053', 'Punto de Acceso', 'Ubiquiti', 'UniFi U6 Enterprise WiFi 6E', 'SN-U6ENT-1103', 'Auditorio General', '2026-02-18', '2027-02-18', 'operativo'),
(54, 4, 'ACT-0054', 'Impresora', 'HP', 'LaserJet Enterprise M608dn', 'SN-HPM608-4421', 'Área de Contabilidad y Finanzas', '2026-01-25', '2027-01-25', 'operativo'),
(55, 5, 'ACT-0055', 'Laptop', 'Lenovo', 'ThinkPad P16s Gen 2 CAD', 'SN-TP16-99312', 'Oficina Técnica de Proyectos', '2026-04-10', '2029-04-10', 'operativo'),
(56, 6, 'ACT-0056', 'Conmutador', 'Aruba', 'CX 6100 24G PoE+ 370W', 'SN-ARUBA-2291', 'Gabinete Piso 3 - Huéspedes', '2026-03-12', '2029-03-12', 'operativo'),
(57, 7, 'ACT-0057', 'Servidor', 'HPE', 'ProLiant DL380 Gen10', 'SN-HPE380-6641', 'Centro de Despacho Logístico', '2026-02-05', '2029-02-05', 'operativo'),
(58, 8, 'ACT-0058', 'Terminal POS', 'Elo Touch', 'Touchscreen I-Series 4.0', 'SN-ELO-33812', 'Caja Principal Farmacia Vida', '2026-03-20', '2027-03-20', 'operativo'),
(59, 9, 'ACT-0059', 'UPS', 'APC', 'Smart-UPS RT 3000VA On-Line', 'SN-APC3000-881', 'Rack de Monitoreo IoT', '2026-01-30', '2028-01-30', 'operativo'),
(60, 10, 'ACT-0060', 'Estación de Trabajo', 'Dell', 'Precision 3660 Tower', 'SN-PREC-10294', 'Consultorios Médicos Piso 1', '2026-04-02', '2028-04-02', 'operativo');

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

INSERT INTO `crm_contactos` VALUES (2,1,'Roberto Salas','Gerente General','roberto.salas@clnica.pe','952082305',0,NULL,'2026-10-05 18:13:47'),(3,2,'Ing. Rojas','Contacto principal','ti@cliente2.pe','01 6560774',1,NULL,'2026-10-05 18:13:47'),(4,2,'Patricia Luna','Jefe de TI','patricia.luna@distribuidora.pe','962560774',0,NULL,'2026-10-05 18:13:47'),(5,3,'Prof. Linares','Contacto principal','ti@cliente3.pe','01 5871898',1,NULL,'2026-10-05 18:13:47'),(6,3,'Diego Paredes','Administrador','diego.paredes@colegio.pe','973871898',0,NULL,'2026-10-05 18:13:47'),(7,4,'CPC Valdivia','Contacto principal','ti@cliente4.pe','01 2273336',1,NULL,'2026-10-05 18:13:47'),(8,4,'Carmen Rojas','Gerente de Operaciones','carmen.rojas@estudio.pe','988273336',0,NULL,'2026-10-05 18:13:47'),(9,5,'Ing. Huamán','Contacto principal','ti@cliente5.pe','01 2617421',1,NULL,'2026-10-05 18:13:47'),(10,5,'Fernando Díaz','Contador','fernando.d\'iaz@constructora.pe','964617421',0,NULL,'2026-10-05 18:13:47'),(11,6,'Sr. Bendezú','Contacto principal','ti@cliente6.pe','01 3491917',1,NULL,'2026-10-05 18:13:47'),(12,6,'Silvia Mora','Gerente General','silvia.mora@hotel.pe','995491917',0,NULL,'2026-10-05 18:13:47'),(13,7,'Sra. Cárdenas','Contacto principal','ti@cliente7.pe','01 5818397',1,NULL,'2026-10-05 18:13:47'),(14,7,'Héctor Vega','Jefe de TI','h\'ector.vega@transportes.pe','931818397',0,NULL,'2026-10-05 18:13:47'),(15,8,'Q.F. Medina','Contacto principal','ti@cliente8.pe','01 2691060',1,NULL,'2026-10-05 18:13:47'),(16,8,'Lorena Campos','Administrador','lorena.campos@farmacias.pe','976691060',0,NULL,'2026-10-05 18:13:47'),
(1, 1, 'Dr. Roberto Paredes', 'Director Médico y de Operaciones', 'ti@cliente1.pe', '01 2082305', 1, 'Contacto principal para infraestructura clínica y sistemas PACS', '2026-10-05 13:32:11'),
(17, 1, 'Ing. Manuel Benavides', 'Coordinador de Infraestructura y Redes', 'mbenavides@cliente1.pe', '999888101', 0, 'Responsable técnico para enlaces de fibra óptica', '2026-10-06 08:30:00'),
(18, 2, 'Lic. Claudia Vargas', 'Gerente de Administración y Finanzas', 'cvargas@cliente2.pe', '999888102', 0, 'Aprobación de órdenes de compra y facturación electrónica', '2026-10-06 08:35:00'),
(19, 3, 'Prof. Ernesto Guzmán', 'Director de Tecnologías Educativas', 'eguzman@cliente3.pe', '999888103', 0, 'Coordinación de aulas de cómputo y plataformas virtuales', '2026-10-06 08:40:00'),
(20, 4, 'CPC Marita Solano', 'Auditora Senior de Sistemas', 'msolano@cliente4.pe', '999888104', 0, 'Supervisión de software contable y respaldos ERP', '2026-10-06 08:45:00'),
(21, 5, 'Arq. Fernando Delgado', 'Jefe de Oficina Técnica y BIM', 'fdelgado@cliente5.pe', '999888105', 0, 'Estaciones de trabajo de renderizado y licenciamiento Autodesk', '2026-10-06 08:50:00'),
(22, 6, 'Sr. Rodolfo Carrión', 'Gerente Residente y Operaciones', 'rcarrion@cliente6.pe', '999888106', 0, 'Sistemas hoteleros PMS y red WiFi de huéspedes', '2026-10-06 08:55:00'),
(23, 7, 'Ing. Patricia Osorio', 'Supervisora de Telemetría y Flota', 'posorio@cliente7.pe', '999888107', 0, 'Servidores de GPS y seguimiento satelital de camiones', '2026-10-06 09:00:00'),
(24, 8, 'Q.F. Javier Bustamante', 'Jefe de Abastecimiento y Farmacias', 'jbustamante@cliente8.pe', '999888108', 0, 'Terminales de cobro rápido e inventario en sucursales', '2026-10-06 09:05:00'),
(25, 9, 'Ing. Renato Alva', 'Director de Desarrollo Tecnológico', 'ralva@automatizado.pe', '999888109', 1, 'Contacto principal para proyectos de automatización cloud', '2026-10-06 09:10:00'),
(26, 10, 'Dra. Gabriela Ponce', 'Directora Médica de Operaciones', 'gponce@santaelena.pe', '999888110', 0, 'Historias clínicas electrónicas y alta disponibilidad', '2026-10-06 09:15:00');

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
(1, 1, 'Guía de Configuración Inicial de Red y VPN WireGuard / IPsec', '# Guía de Conectividad VPN Empresarial\n\n### 1. Resumen Ejecutivo\nEste procedimiento describe la interconexión segura de sedes remotas y teletrabajadores mediante túneles cifrados **WireGuard** y **IPsec IKEv2** con autenticación basada en certificados X.509.\n\n### 2. Parámetros Técnicos\n- **Cifrado de Fase 1:** AES-256-GCM / SHA-384 / DH Group 21.\n- **Keepalive:** 25 segundos para traversal de NAT.\n- **MTU Recomendado:** 1420 bytes para evitar fragmentación MSS.\n\n### 3. Procedimiento de Verificación\nEjecutar `wg show` en la terminal del concentrador para inspeccionar el handshake criptográfico y la tasa de transferencia en tiempo real.', 312, 1, '2026-10-01 09:00:00'),
(2, 2, 'Procedimiento Estándar de Mantenimiento Preventivo de Servidores Físicos', '# Mantenimiento Preventivo de Servidores de Misión Crítica\n\n### Checklist Técnico Semestral\n1. **Inspección Física:** Limpieza de filtros antipolvo frontales y verificación de revoluciones por minuto (RPM) en ventiladores redundantes.\n2. **Actualización de Firmware:** Aplicación de paquetes BIOS, CPLD y controladora RAID mediante consola fuera de banda (iDRAC / iLO).\n3. **Prueba de Autonomía:** Verificación de estado de la batería de caché RAID (BBU / SuperCapacitor).\n4. **Pasta Térmica:** Reemplazo periódico en procesadores con pasta de alta conductividad térmica (>= 8.5 W/mK).', 245, 3, '2026-10-02 11:30:00'),
(3, 3, 'Políticas de Respaldo y Recuperación ante Desastres (DRP / RPO / RTO)', '# Manual de Recuperación ante Desastres (DRP)\n\n### Objetivos de Continuidad Operativa\n- **RPO (Punto Objetivo de Recuperación):** Máximo 2 horas para bases de datos transaccionales.\n- **RTO (Tiempo Objetivo de Recuperación):** Máximo 4 horas para puesta en marcha de servicios críticos.\n\n### Estrategia de Respaldo 3-2-1 Inmutable\n- **3 copias** de los datos empresariales.\n- **2 medios diferentes** (Almacenamiento SAN local y repositorio S3 inmutable con Object Lock habilitado).\n- **1 copia fuera de sitio** (Región Cloud AWS us-east-1).', 189, 1, '2026-10-03 14:15:00'),
(4, 4, 'Resolución de Incidencias Frecuentes en Estaciones de Trabajo Windows 11', '# Troubleshooting Avanzado en Windows 11 Enterprise\n\n### 1. Cuello de Botella en Memoria y Paginación\nVerificar con `Get-Process | Sort-Object WorkingSet64 -Descending` el consumo de memoria en segundo plano. Comprobar que el tamaño del archivo `pagefile.sys` sea administrado dinámicamente por el sistema.\n\n### 2. Regeneración de Perfiles Dañados\nSi un usuario experimenta lentitud en el inicio de sesión, verificar el visor de eventos `Microsoft-Windows-User Profiles Service/Operational` y renombrar temporalmente la clave de registro `ProfileList`.', 420, 4, '2026-10-04 16:40:00'),
(5, 3, 'Diagnóstico y Mitigación de Bucles de Red con Spanning Tree (STP/RSTP)', '# Prevención de Tormentas de Broadcast en Redes Conmutadas\n\n### Arquitectura de STP\nLa topología debe implementar **Rapid Per-VLAN Spanning Tree Plus (PVRST+)** para garantizar tiempos de convergencia menores a 2 segundos frente a caídas de enlaces troncales.\n\n### Configuración de Seguridad en Puertos de Acceso\n- **PortFast:** Habilitado únicamente en puertos hacia hosts finales.\n- **BPDU Guard:** Configurado globalmente para desactivar (`err-disable`) cualquier puerto que reciba unidades BPDU no autorizadas.', 175, 3, '2026-10-05 08:30:00'),
(6, 5, 'Configuración de Registros de Seguridad de Correo: SPF, DKIM y DMARC', '# Seguridad de Correo Electrónico y Anti-Phishing\n\n### 1. Registro SPF (Sender Policy Framework)\nConfiguración en DNS: `v=spf1 include:spf.protection.outlook.com ip4:200.48.12.34 -all`. Evitar el uso de `~all` para impedir suplantación de identidad.\n\n### 2. Registro DKIM (DomainKeys Identified Mail)\nGeneración de claves criptográficas RSA de 2048 bits para firma digital de cabeceras.\n\n### 3. Política DMARC\n`v=DMARC1; p=reject; rua=mailto:dmarc-reports@nexusdesk.pe; pct=100` para bloqueo determinista de correos fraudulentos.', 280, 1, '2026-10-06 10:15:00'),
(7, 6, 'Solución de Problemas en Colas de Impresión Windows Server Spooler', '# Estabilización de Servicios de Impresión Corporativa\n\n### Flujo de Reinicio Seguro del Spooler\n1. Detener el servicio: `Stop-Service Spooler -Force`\n2. Purgar archivos de cola huérfanos: `Remove-Item C:\Windows\System32\spool\PRINTERS\*.* -Force`\n3. Iniciar el servicio: `Start-Service Spooler`\n\n### Aislamiento de Controladores (Driver Isolation)\nConfigurar el aislamiento en modo *Isolated* para evitar que un controlador de impresión de terceros provoque la caída de todo el servicio.', 195, 4, '2026-10-07 11:45:00'),
(8, 7, 'Endurecimiento de Endpoints contra Ransomware y Políticas EDR', '# Guía de Hardening de Endpoints y Protección EDR\n\n### Medidas Obligatorias de Seguridad\n1. **Deshabilitación de Protocolos Obsoletos:** Desactivar SMBv1 y NTLMv1 mediante directivas de grupo GPO.\n2. **Protección de Credenciales:** Habilitar Windows Defender Credential Guard con virtualización VBS.\n3. **Bloqueo de Macros de Office:** Restricción estricta de macros descargadas de Internet (Mark of the Web).\n4. **Monitoreo EDR:** Monitoreo activo de procesos hijos de PowerShell y conmutación a modo de contención inmediata.', 340, 1, '2026-10-08 14:00:00'),
(9, 8, 'Troncales SIP y Telefonía IP: Calidad de Servicio (QoS DSCP EF)', '# Calidad de Servicio (QoS) en Infraestructuras de Voz IP\n\n### Parámetros de Rendimiento Crítico\n- **Latencia Máxima:** < 150 ms (One-Way Delay).\n- **Jitter:** < 30 ms.\n- **Pérdida de Paquetes:** < 1%.\n\n### Clasificación de Tráfico en Switches y Routers\nMarcar los paquetes RTP de voz con **DSCP EF (Expedited Forwarding - 46)** y la señalización SIP con **DSCP CS3 (24)** para priorizarlos en las colas de hardware sobre el tráfico de datos convencional.', 158, 3, '2026-10-09 15:30:00'),
(10, 3, 'Segmentación de Redes Corporativas: Diseño e Implementación de VLANs', '# Estándar de Segmentación de Red IEEE 802.1Q\n\n### Esquema de VLANs Recomendado\n- **VLAN 10 - Gestión de Infraestructura:** Switches, Routers, PDUs (10.10.10.0/24).\n- **VLAN 20 - Servidores y Almacenamiento:** Servidores locales y NAS (10.10.20.0/24).\n- **VLAN 30 - Estaciones de Trabajo:** PCs y Laptops cableadas (10.10.30.0/23).\n- **VLAN 40 - Telefonía IP:** Teléfonos VoIP y Gateways SIP (10.10.40.0/24).\n- **VLAN 50 - Invitados / WiFi:** Aislamiento total de clientes (10.10.50.0/24).', 290, 3, '2026-10-10 09:20:00'),
(11, 4, 'Optimización y Respaldo en Caliente de Bases de Datos MySQL 8.4 Enterprise', '# Guía de Rendimiento y Consistencia Transaccional en MySQL\n\n### Parámetros de Memoria InnoDB\n- `innodb_buffer_pool_size`: Asignar entre el 60% y 75% de la memoria RAM del servidor.\n- `innodb_log_file_size`: Configurado en 1GB para soportar transacciones de escritura masiva.\n- `innodb_flush_log_at_trx_commit = 1`: Garantía ACID absoluta en discos SSD NVMe.\n\n### Respaldos Consistentes\nUso de `--single-transaction --quick --routines --triggers` para evitar bloqueos en tablas transaccionales.', 380, 1, '2026-10-11 11:10:00'),
(12, 1, 'Protocolo de Soporte Remoto Seguro con Doble Factor y Grabación de Sesión', '# Protocolo de Acceso Remoto Asistido\n\n### Requisitos de Cumplimiento Normativo\n1. **Consentimiento Expreso:** Todo acceso a la pantalla del usuario requiere confirmación previa mediante ventana emergente.\n2. **Trazabilidad:** Registro automático del hash de la sesión, IP origen, usuario técnico y duración en segundos.\n3. **Cierre Forzado:** Terminación de privilegios de elevación administrativa al finalizar la sesión de asistencia remota.', 210, 4, '2026-10-12 16:00:00'),
(13, 1, 'Monitoreo Proactivo de Infraestructura con Zabbix y Notificaciones en Tiempo Real', '# Monitoreo Proactivo de Salud de Servidores y Redes\n\n### Agentes y Plantillas de Monitoreo\nImplementación de **Zabbix Agent 2** con recolección de métricas activas cada 60 segundos:\n- Consumo de CPU por encima del 90% sostenido durante 5 minutos.\n- Espacio disponible en particiones `/` y `C:` por debajo del 15%.\n- Alertas tempranas SMART de sectores reasignados en discos duros.', 265, 3, '2026-10-13 08:40:00'),
(14, 3, 'Estándar de Cableado Estructurado ANSI/TIA-568-D y Certificación Fluke', '# Manual de Instalación y Certificación de Cableado Cat 6A\n\n### Reglas de Instalación\n- **Radio de Curvatura:** Mantener al menos 4 veces el diámetro exterior del cable para evitar pérdidas por inserción.\n- **Destrenzado Máximo:** No destrenzar más de 12 mm en el punto de remate del conector hembra RJ45.\n- **Margen NEXT:** Certificar un margen positivo mínimo de 3.0 dB en pruebas de diafonía con analizador Fluke DSX-8000.', 198, 4, '2026-10-14 14:20:00'),
(15, 1, 'Gestión del Ciclo de Vida de Equipos y Garantías de Fabricante (OEM)', '# Políticas de Renovación Tecnológica (Hardware Refresh)\n\n### Criterios de Obsolescencia\n- **Servidores y Firewalls:** Ciclo de vida máximo de 5 años con contratos de soporte extendido del fabricante 24x7x4h.\n- **Estaciones de Trabajo y Laptops:** Renovación a los 3 o 4 años según carga de trabajo del usuario.\n- **Disposición Segura de Activos:** Destrucción y borrado seguro de discos según estándar NIST SP 800-88 Rev. 1.', 140, 2, '2026-10-15 10:30:00'),
(16, 7, 'Auditoría Centralizada de Logs Syslog-ng y Cumplimiento Normativo ISO 27001', '# Recolección Centralizada de Trazas y Eventos de Seguridad\n\n### Configuración de Reenvío Seguro (TLS)\nConfiguración de servidores y equipos de red para transmitir logs a través de TCP puerto 6514 con cifrado mutuo mTLS.\n\n### Retención y Sellado de Tiempo\nAlmacenamiento de logs en volúmenes protegidos contra escritura con rotación automática semanal y retención mínima de 12 meses para auditoría legal.', 185, 1, '2026-10-16 17:15:00');

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
(5, 3, 3, 'Impresora configurada con IP estática en VLAN de contabilidad.', 0, '2026-10-06 14:00:00'),
(6, 4, 3, 'Se ejecutó diagnóstico de latencia en la controladora SAS. No se detectan sectores defectuosos.', 1, '2026-10-07 09:20:00'),
(7, 4, 1, 'Recomiendo programar ventana de mantenimiento para actualizar firmware del arreglo.', 1, '2026-10-07 10:00:00'),
(8, 4, 3, 'Cliente autoriza ventana de mantenimiento para el viernes a las 22:00 horas.', 0, '2026-10-07 14:30:00'),
(9, 5, 4, 'Se visitó la sede Miraflores. Se reemplazó el patch cord deteriorado en puesto 12.', 0, '2026-10-08 11:15:00'),
(10, 6, 3, 'Revisión remota de reglas de firewall. El puerto 443 estaba siendo bloqueado por política previa.', 1, '2026-10-08 15:40:00'),
(11, 6, 3, 'Regla corregida y validada. Acceso al portal médico restablecido.', 0, '2026-10-08 16:10:00'),
(12, 7, 4, 'Impresora configurada en red local con dirección IP estática 192.168.1.250.', 0, '2026-10-09 10:00:00'),
(13, 8, 3, 'Certificado SSL del servidor web expiró. Se procede con la instalación de certificado Let\'s Encrypt.', 1, '2026-10-09 14:15:00'),
(14, 8, 3, 'Certificado instalado con éxito. Redirección HTTPS funcionando correctamente.', 0, '2026-10-09 15:00:00'),
(15, 9, 4, 'Se limpió la cola de impresión y se reinstaló el controlador PCL6 en servidor de terminales.', 0, '2026-10-10 09:45:00'),
(16, 10, 3, 'Servidor de base de datos presentaba tablas bloqueadas por consulta no optimizada.', 1, '2026-10-10 11:30:00'),
(17, 10, 3, 'Proceso finalizado y consulta optimizada. El uso de CPU retornó al 12%.', 0, '2026-10-10 12:15:00'),
(18, 11, 4, 'Se configuró cliente VPN en laptop corporativa de gerencia.', 0, '2026-10-11 16:20:00'),
(19, 12, 3, 'Switch de piso 2 presentaba saturación de paquetes broadcast por bucle en oficina contable.', 1, '2026-10-12 10:00:00'),
(20, 12, 3, 'Se activó BPDU Guard en todos los puertos de acceso. Red estabilizada.', 0, '2026-10-12 11:30:00'),
(21, 13, 4, 'Antivirus corporativo bloqueó archivo sospechoso descargado desde correo externo.', 1, '2026-10-13 14:10:00'),
(22, 13, 4, 'Equipo desinfectado y analizado completamente. Sin propagación en la red.', 0, '2026-10-13 15:45:00'),
(23, 14, 3, 'Se creó nueva cuenta de usuario en Active Directory y buzón de correo Microsoft 365.', 0, '2026-10-14 09:15:00'),
(24, 15, 4, 'Teléfono IP Grandstream no registraba por error de contraseña SIP.', 1, '2026-10-14 11:30:00'),
(25, 15, 4, 'Extensión 104 restablecida y con llamadas de prueba satisfactorias.', 0, '2026-10-14 12:00:00'),
(26, 16, 3, 'Se amplió el tamaño de disco virtual de servidor de archivos en 200GB.', 0, '2026-10-15 16:30:00'),
(27, 17, 4, 'Punto de acceso WiFi presentaba reinicios por caída de voltaje en switch PoE.', 1, '2026-10-16 10:15:00'),
(28, 17, 4, 'Se conectó inyector PoE dedicado de 30W. Cobertura inalámbrica al 100%.', 0, '2026-10-16 11:45:00'),
(29, 18, 3, 'Se configuró sincronización de contraseñas entre Active Directory local y Microsoft Entra ID.', 1, '2026-10-17 14:00:00'),
(30, 19, 4, 'Se reemplazó cable HDMI dañado en sala de reuniones de directorio.', 0, '2026-10-18 09:30:00'),
(31, 20, 3, 'Se actualizó firmware de firewall perimetral a versión 7.2.8 recomendada por fabricante.', 1, '2026-10-19 23:00:00'),
(32, 21, 4, 'Se configuró impresora térmica de tickets para farmacia con emulación ESC/POS.', 0, '2026-10-20 10:45:00'),
(33, 22, 3, 'Se restableció servicio de base de datos PostgreSQL tras corte imprevisto de fluido eléctrico.', 1, '2026-10-21 08:30:00'),
(34, 23, 4, 'Mantenimiento físico y lubricación de ventiladores en estación de diseño gráfico.', 0, '2026-10-22 15:20:00'),
(35, 24, 3, 'Se implementaron reglas de filtrado de contenido web para navegación segura.', 1, '2026-10-23 11:00:00'),
(36, 25, 4, 'Se reemplazó teclado y mouse inalámbrico por batería sulfatada en puesto de recepción.', 0, '2026-10-23 14:15:00'),
(37, 26, 3, 'Se configuró copia de respaldo diferencial diaria hacia servidor NAS Synology.', 1, '2026-10-23 17:30:00'),
(38, 27, 3, 'Monitoreo de tráfico confirma que el enlace secundario WAN2 está en estado pasivo.', 1, '2026-10-24 08:45:00'),
(39, 28, 4, 'Se atendió consulta de usuario sobre exportación de reportes a formato Excel.', 0, '2026-10-24 09:30:00'),
(40, 29, 3, 'Se verificaron los logs de auditoría sin encontrar accesos sospechosos en las últimas 24 horas.', 1, '2026-10-24 10:15:00');

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

INSERT INTO `repuestos` VALUES (1,'REP-001','Disco SSD 480GB','Almacenamiento',3,8,185.00,NULL),(2,'REP-002','Memoria RAM DDR4 8GB','Memoria',14,6,95.00,NULL),(3,'REP-003','Fuente de poder 500W','Componentes',2,5,120.00,NULL),(4,'REP-004','Cable UTP Cat6 (caja 305m)','Redes',6,3,390.00,NULL),(5,'REP-005','Tóner HP 105A','Consumibles',4,6,260.00,NULL),(6,'REP-006','Batería laptop Dell','Baterías',9,4,210.00,NULL),(7,'REP-007','Switch 24p PoE','Redes',2,2,1450.00,NULL),(8,'REP-008','Pantalla LED 15.6\"','Pantallas',1,3,340.00,NULL),(9,'REP-009','Conector RJ45 (100u)','Redes',20,8,45.00,NULL),(10,'REP-010','Pasta térmica','Consumibles',12,5,22.00,NULL),
(11, 'REP-0011', 'Memoria RAM Kingston Server Premier 32GB DDR4 3200MHz ECC', 'Memorias', 8, 2, 450.00, 'Almacén Central - Gaveta M1'),
(12, 'REP-0012', 'Memoria RAM Kingston FURY 16GB DDR5 5600MHz Desktop', 'Memorias', 12, 3, 280.00, 'Almacén Central - Gaveta M2'),
(13, 'REP-0013', 'SSD NVMe M.2 Samsung 980 Pro 2TB PCIe 4.0', 'Discos', 6, 2, 620.00, 'Almacén Central - Gaveta D1'),
(14, 'REP-0014', 'SSD Enterprise Seagate Nytro 960GB SATA 2.5 pulg', 'Discos', 4, 2, 590.00, 'Almacén Central - Gaveta D2'),
(15, 'REP-0015', 'Módulo Transceiver SFP+ 10GBASE-SR LC 850nm Multimodo', 'Redes', 14, 4, 185.00, 'Almacén Redes - Estante R1'),
(16, 'REP-0016', 'Transceiver SFP 1000BASE-T RJ45 Gigabit Ethernet', 'Redes', 10, 3, 110.00, 'Almacén Redes - Estante R1'),
(17, 'REP-0017', 'Patch Cord Furukawa Gigalan Cat6A blindado S/FTP 2m azul', 'Cables', 45, 10, 35.00, 'Almacén Redes - Caja C1'),
(18, 'REP-0018', 'Patch Cord Furukawa Gigalan Cat6A blindado S/FTP 3m rojo', 'Cables', 30, 10, 42.00, 'Almacén Redes - Caja C1'),
(19, 'REP-0019', 'Fuente de Poder Corsair RM750e 750W 80 Plus Gold Modular', 'Fuentes', 5, 2, 490.00, 'Almacén Central - Estante F1'),
(20, 'REP-0020', 'Batería de Reemplazo para UPS APC RBC55 12V 9Ah', 'Energía', 3, 2, 380.00, 'Almacén Energía - Tarima E1'),
(21, 'REP-0021', 'Pasta Térmica Arctic MX-4 de Alto Rendimiento 4g', 'Consumibles', 18, 5, 45.00, 'Taller Técnico - Mesa 1'),
(22, 'REP-0022', 'Bobina de Cable UTP Cat6A 100% Cobre 305m Furukawa Azul', 'Cables', 2, 1, 950.00, 'Almacén Redes - Suelo R3'),
(23, 'REP-0023', 'Switch de Escritorio TP-Link 8 Puertos Gigabit PoE+ TL-SG1008P', 'Hardware', 4, 2, 320.00, 'Almacén Redes - Estante R2'),
(24, 'REP-0024', 'Tarjeta de Red Intel I350-T4 Quad Port Gigabit PCIe', 'Hardware', 3, 1, 480.00, 'Almacén Central - Gaveta H3'),
(25, 'REP-0025', 'PDU Rackeable Tripp Lite 1U con 8 Tomas NEMA 5-15R', 'Energía', 6, 2, 290.00, 'Almacén Energía - Estante E2');

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
    `tarifa_hora` DECIMAL(8,2) NOT NULL DEFAULT 65.00,
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

INSERT INTO `ordenes_servicio` VALUES (1,'OS-2026-001',NULL,1,NULL,3,'correctiva','completada','Reemplazo de disco duro y reinstalación del sistema','Se identificó el origen de la falla tras las pruebas en sitio.','Trabajo ejecutado y probado con el usuario. Equipo operativo.',2.20,45.00,1,'2026-08-28 09:00:00','2026-08-28 09:30:00','2026-08-28 11:42:00',NULL,NULL,NULL,NULL,'2026-10-05 17:50:21'),(2,'OS-2026-002',NULL,2,NULL,4,'preventiva','completada','Mantenimiento preventivo de equipos de oficina','Se identificó el origen de la falla tras las pruebas en sitio.','Trabajo ejecutado y probado con el usuario. Equipo operativo.',2.60,45.00,1,'2026-09-24 09:00:00','2026-09-24 09:30:00','2026-09-24 12:06:00',NULL,NULL,NULL,NULL,'2026-10-05 17:50:21'),(3,'OS-2026-003',NULL,3,NULL,5,'instalacion','completada','Instalación y configuración de switch PoE','Se identificó el origen de la falla tras las pruebas en sitio.','Trabajo ejecutado y probado con el usuario. Equipo operativo.',6.40,45.00,1,'2026-08-25 09:00:00','2026-08-25 09:30:00','2026-08-25 15:54:00',NULL,NULL,NULL,NULL,'2026-10-05 17:50:21'),(4,'OS-2026-004',NULL,4,NULL,6,'diagnostico','completada','Diagnóstico de lentitud en servidor de archivos','Se identificó el origen de la falla tras las pruebas en sitio.','Trabajo ejecutado y probado con el usuario. Equipo operativo.',2.30,45.00,1,'2026-08-06 09:00:00','2026-08-06 09:30:00','2026-08-06 11:48:00',NULL,NULL,NULL,NULL,'2026-10-05 17:50:21'),(5,'OS-2026-005',NULL,5,NULL,3,'correctiva','completada','Cambio de fuente de poder en estación de trabajo','Se identificó el origen de la falla tras las pruebas en sitio.','Trabajo ejecutado y probado con el usuario. Equipo operativo.',6.70,45.00,1,'2026-09-10 09:00:00','2026-09-10 09:30:00','2026-09-10 16:12:00',NULL,NULL,NULL,NULL,'2026-10-05 17:50:21'),(6,'OS-2026-006',NULL,6,NULL,4,'preventiva','completada','Configuración de punto de acceso WiFi','Se identificó el origen de la falla tras las pruebas en sitio.','Trabajo ejecutado y probado con el usuario. Equipo operativo.',4.10,45.00,1,'2026-08-26 09:00:00','2026-08-26 09:30:00','2026-08-26 13:35:59',NULL,NULL,NULL,NULL,'2026-10-05 17:50:21'),(7,'OS-2026-007',NULL,7,NULL,5,'instalacion','en_curso','Limpieza y mantenimiento de impresoras',NULL,NULL,0.00,45.00,0,'2026-10-04 09:00:00','2026-10-04 09:30:00',NULL,NULL,NULL,NULL,NULL,'2026-10-05 17:50:21'),(8,'OS-2026-008',NULL,8,NULL,6,'diagnostico','en_curso','Reubicación de puntos de red',NULL,NULL,0.00,45.00,1,'2026-10-04 09:00:00','2026-10-04 09:30:00',NULL,NULL,'data:image/png;base64,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','Ing. Carlos Benavides (DNI 45892301)','2026-10-11 19:57:00','2026-10-05 17:50:21'),(9,'OS-2026-009',NULL,1,NULL,3,'correctiva','pendiente','Reemplazo de disco duro y reinstalación del sistema',NULL,NULL,0.00,45.00,1,'2026-10-07 09:00:00',NULL,NULL,NULL,'data:image/png;base64,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','Ing. Carlos Benavides (DNI 45892301)','2026-10-11 13:59:35','2026-10-05 17:50:21'),(10,'OS-2026-010',NULL,2,NULL,4,'preventiva','pendiente','Mantenimiento preventivo de equipos de oficina',NULL,NULL,0.00,45.00,1,'2026-10-10 09:00:00',NULL,NULL,NULL,'data:image/png;base64,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','Ing. Carlos Benavides (DNI 45892301)','2026-10-11 13:50:45','2026-10-05 17:50:21'),(11,'OS-2026-011',NULL,3,NULL,5,'instalacion','pendiente','Instalación y configuración de switch PoE',NULL,NULL,0.00,45.00,1,'2026-10-08 09:00:00',NULL,NULL,NULL,'data:image/png;base64,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','Ing. Carlos Benavides (DNI 45892301)','2026-10-11 13:48:19','2026-10-05 17:50:21'),(12,'OS-2026-012',NULL,4,NULL,6,'diagnostico','cancelada','Diagnóstico de lentitud en servidor de archivos',NULL,NULL,0.00,45.00,1,'2026-10-05 09:00:00',NULL,NULL,NULL,'data:image/png;base64,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','Ing. Carlos Benavides (DNI 45892301)','2026-10-11 13:46:34','2026-10-05 17:50:21'),
(13, 'OS-2026-013', 13, 1, 49, 3, 'preventiva', 'completada', 'Mantenimiento semestral de servidor Dell R740xd en rack de producción', 'Chasis con acumulación moderada de polvo, firmware iDRAC desactualizado en 2 versiones.', 'Limpieza interna de ductos de aire, actualización segura de firmware iDRAC9 v6.10, verificación de integridad RAID 10.', 3.50, 65.00, 1, '2026-10-18 09:00:00', '2026-10-18 09:15:00', '2026-10-18 12:45:00', NULL, 'data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAJY...', 'Dr. Roberto Paredes', '2026-10-18 12:50:00', '2026-10-18 09:00:00'),
(14, 'OS-2026-014', 14, 2, 50, 3, 'correctiva', 'completada', 'Restablecimiento de enlace redundante FortiGate por conmutación fallida SD-WAN', 'Falla de handshake en túnel IPsec primario por expiración de certificado intermedio.', 'Renovación de certificado CA corporativo, reconfiguración de SLA probe en FortiGate con conmutación en menos de 200ms.', 2.50, 65.00, 1, '2026-10-19 14:00:00', '2026-10-19 14:10:00', '2026-10-19 16:40:00', NULL, 'data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAJY...', 'Ing. Carlos Rojas', '2026-10-19 16:45:00', '2026-10-19 14:00:00'),
(15, 'OS-2026-015', 15, 3, 52, 4, 'instalacion', 'completada', 'Montaje y comisionamiento de punto de acceso UniFi U6 Enterprise en aulas', 'Zona con sombra de señal WiFi de 5GHz en pabellón de laboratorios de cómputo.', 'Tirada de cable Cat6A de 45m, conectorización RJ45 blindado, adopción en consola UniFi Network y calibración de canales sin interferencias.', 4.00, 45.00, 1, '2026-10-20 10:00:00', '2026-10-20 10:15:00', '2026-10-20 14:15:00', NULL, 'data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAJY...', 'Prof. Manuel Linares', '2026-10-20 14:20:00', '2026-10-20 10:00:00'),
(16, 'OS-2026-016', 16, 4, 54, 4, 'correctiva', 'completada', 'Reemplazo de kit de arrastre de papel y rodillos en impresora multifuncional HP', 'Atasco recurrente de hojas bond en bandeja 2 durante impresión de balances contables.', 'Instalación de rodillos de alimentación originales HP, calibración de sensores ópticos y limpieza con alcohol isopropílico.', 1.50, 45.00, 1, '2026-10-21 11:00:00', '2026-10-21 11:05:00', '2026-10-21 12:35:00', NULL, 'data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAJY...', 'CPC César Valdivia', '2026-10-21 12:40:00', '2026-10-21 11:00:00'),
(17, 'OS-2026-017', 17, 5, 55, 3, 'diagnostico', 'completada', 'Auditoría de rendimiento térmico y throttling en workstation Lenovo CAD', 'Renderizado en Revit se detiene por sobrecalentamiento del CPU superando los 98C.', 'Desarme de disipador de cámara de vapor, remoción de pasta seca y aplicación de compuesto térmico Arctic MX-4. Temperatura máxima bajo carga estabilizada en 74C.', 2.00, 65.00, 1, '2026-10-22 09:30:00', '2026-10-22 09:40:00', '2026-10-22 11:40:00', NULL, 'data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAJY...', 'Ing. Walter Huamán', '2026-10-22 11:45:00', '2026-10-22 09:30:00'),
(18, 'OS-2026-018', 18, 6, 56, 3, 'preventiva', 'completada', 'Inspección de switch de distribución Aruba CX 6100 y balanceo de carga PoE', 'Monitoreo de tráfico y consumo energético de cámaras IP conectadas en piso 3.', 'Actualización de ArubaOS-CX a v10.12, habilitación de snooping DHCP y asignación de prioridades de alimentación PoE para cámaras críticas.', 3.00, 65.00, 1, '2026-10-22 15:00:00', '2026-10-22 15:10:00', '2026-10-22 18:10:00', NULL, 'data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAJY...', 'Sr. Alberto Bendezú', '2026-10-22 18:15:00', '2026-10-22 15:00:00'),
(19, 'OS-2026-019', 19, 7, 57, 4, 'correctiva', 'completada', 'Sustitución en caliente de disco SAS 600GB dañado en arreglo RAID 5 HPE', 'Led ámbar parpadeante en bahía 3 de almacenamiento, degraded status en Smart Array.', 'Hot-swap de disco defectuoso por unidad certificada HPE, reconstrucción automática (rebuild) completada en 2h 45min sin pérdida de datos.', 3.50, 45.00, 1, '2026-10-23 08:30:00', '2026-10-23 08:45:00', '2026-10-23 12:15:00', NULL, 'data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAJY...', 'Sra. Elena Cárdenas', '2026-10-23 12:20:00', '2026-10-23 08:30:00'),
(20, 'OS-2026-020', 20, 8, 58, 4, 'correctiva', 'completada', 'Diagnóstico y reemplazo de fuente de poder en punto de venta touch Elo', 'Equipo se apaga abruptamente al imprimir ticket fiscal de venta.', 'Falla de voltaje en línea de 12V de la fuente conmutada. Se instala reemplazo Corsair 750W y estabilizador electrónico.', 2.00, 45.00, 1, '2026-10-23 14:00:00', '2026-10-23 14:15:00', '2026-10-23 16:15:00', NULL, 'data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAJY...', 'Q.F. Ramón Medina', '2026-10-23 16:20:00', '2026-10-23 14:00:00'),
(21, 'OS-2026-021', 21, 9, 59, 3, 'preventiva', 'completada', 'Cambio programado de pack de baterías en Smart-UPS RT 3000VA On-Line', 'Prueba de autodiagnóstico notificó batería agotada con autonomía reducida a 4 minutos.', 'Reemplazo de celdas internas APC RBC55, calibración de runtime en tarjeta de gestión SNMP y prueba de descarga simulada satisfactoria.', 2.50, 65.00, 1, '2026-10-23 17:00:00', '2026-10-23 17:15:00', '2026-10-23 19:45:00', NULL, 'data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAJY...', 'Ing. Carlos Mendoza', '2026-10-23 19:50:00', '2026-10-23 17:00:00'),
(22, 'OS-2026-022', 22, 10, 60, 3, 'correctiva', 'en_curso', 'Actualización de suite de visualización médica DICOM y backup local en Dell Precision', 'Software PACS presenta latencia al cargar tomografías computarizadas de más de 2GB.', 'Instalación de unidad SSD NVMe Samsung 980 Pro 2TB para caché local de imágenes y migración de perfiles clínicos.', 3.00, 65.00, 0, '2026-10-24 09:00:00', '2026-10-24 09:10:00', NULL, NULL, NULL, NULL, NULL, '2026-10-24 08:30:00'),
(23, 'OS-2026-023', 23, 1, 49, 4, 'preventiva', 'en_curso', 'Reordenamiento de patch panel y certificación de enlaces Cat6A en Datacenter', 'Cables sin peinar interfieren con el flujo de ventilación del conmutador Cisco 9300.', 'Reemplazo de latiguillos por patch cords blindados Furukawa de 1m, rotulación según norma TIA-606-B y reporte de atenuación.', 4.00, 45.00, 0, '2026-10-24 10:30:00', '2026-10-24 10:45:00', NULL, NULL, NULL, NULL, NULL, '2026-10-24 09:00:00'),
(24, 'OS-2026-024', 24, 2, 51, 3, 'diagnostico', 'pendiente', 'Evaluación de plan de expansión de almacenamiento en Synology NAS a 64TB', 'Capacidad actual ocupada al 89%, requiriendo adición de bahías DX517.', 'Análisis de crecimiento de datos de los últimos 6 meses y propuesta técnica de arreglo SHR-2 con redundancia de doble disco.', 2.00, 65.00, 0, '2026-10-24 14:00:00', NULL, NULL, NULL, NULL, NULL, NULL, '2026-10-24 09:15:00'),
(25, 'OS-2026-025', 25, 3, 53, 4, 'instalacion', 'pendiente', 'Instalación de sistema de voceo IP y altavoces en patio principal de colegio', 'Mejora del sistema de avisos de emergencia integrado con la centralita FreePBX.', 'Tendido de cable exterior Cat6A, montaje de altavoces Grandstream SIP y programación de discado rápido.', 5.00, 45.00, 0, '2026-10-25 08:30:00', NULL, NULL, NULL, NULL, NULL, NULL, '2026-10-24 09:30:00'),
(26, 'OS-2026-026', 26, 4, 54, 4, 'preventiva', 'pendiente', 'Mantenimiento preventivo integral de 8 computadoras de escritorio en contabilidad', 'Limpieza física anual de polvo, optimización de inicio de Windows y actualización de antivirus.', 'Soplado con aire seco, cambio de pasta térmica en procesadores y escaneo completo con Microsoft Defender.', 6.00, 45.00, 0, '2026-10-25 10:00:00', NULL, NULL, NULL, NULL, NULL, NULL, '2026-10-24 10:00:00'),
(27, 'OS-2026-027', 27, 5, 55, 3, 'diagnostico', 'pendiente', 'Revisión de enlace satelital de contingencia en campamento de construcción', 'Pérdida de paquetes superior al 8% en horas de la tarde afectando videoconferencias.', 'Alineación de antena VSAT, verificación de LNB y ajuste de potencia de transmisión (BUC).', 3.00, 65.00, 0, '2026-10-26 09:00:00', NULL, NULL, NULL, NULL, NULL, NULL, '2026-10-24 10:15:00'),
(28, 'OS-2026-028', 28, 6, 56, 4, 'instalacion', 'pendiente', 'Despliegue de red WiFi para huéspedes en terraza y área de piscina', 'Cobertura deficiente en zonas abiertas del hotel según reseñas de clientes.', 'Montaje de 2 puntos de acceso UniFi Outdoor Mesh con alimentación PoE sobre mástil existente.', 4.50, 45.00, 0, '2026-10-26 14:00:00', NULL, NULL, NULL, NULL, NULL, NULL, '2026-10-24 10:30:00');

CREATE TABLE `ordenes_repuestos` (
    `id` BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    `orden_id` BIGINT UNSIGNED NOT NULL,
    `repuesto_id` BIGINT UNSIGNED NOT NULL,
    `cantidad` INT NOT NULL DEFAULT 1,
    `precio_unit` DECIMAL(10,2) NOT NULL DEFAULT 0.00,
    CONSTRAINT `fk_or_orden` FOREIGN KEY (`orden_id`) REFERENCES `ordenes_servicio` (`id`) ON DELETE CASCADE,
    CONSTRAINT `fk_or_rep` FOREIGN KEY (`repuesto_id`) REFERENCES `repuestos` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

INSERT INTO `ordenes_repuestos` VALUES (1,2,3,2,120.00),(2,3,2,1,95.00),(3,4,1,1,185.00),(4,5,2,1,95.00),(5,6,6,2,210.00),
(6, 13, 21, 1, 45.00),
(7, 14, 15, 2, 185.00),
(8, 15, 17, 1, 35.00),
(9, 16, 21, 1, 45.00),
(10, 17, 21, 1, 45.00),
(11, 18, 16, 2, 110.00),
(12, 19, 14, 1, 590.00),
(13, 20, 19, 1, 490.00),
(14, 21, 20, 1, 380.00),
(15, 22, 13, 1, 620.00),
(16, 23, 17, 4, 35.00),
(17, 24, 11, 2, 450.00),
(18, 28, 17, 2, 35.00);

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

INSERT INTO `visitas` VALUES (2,NULL,3,4,'emergencia','2026-10-06 16:00:00','programada','Visita programada de mantenimiento'),(3,NULL,1,4,'emergencia','2026-10-11 11:00:00','programada','Visita programada de mantenimiento'),(4,NULL,4,3,'correctiva','2026-10-09 16:00:00','programada','Visita programada de mantenimiento'),(5,NULL,1,6,'instalacion','2026-10-09 11:00:00','programada','Visita programada de mantenimiento'),(6,NULL,7,3,'instalacion','2026-10-10 11:00:00','programada','Visita programada de mantenimiento'),(7,NULL,8,4,'preventiva','2026-10-08 16:00:00','programada','Visita programada de mantenimiento'),(8,NULL,2,3,'instalacion','2026-10-07 14:00:00','programada','Visita programada de mantenimiento'),(9,NULL,2,5,'preventiva','2026-10-06 10:00:00','en_curso','Visita programada de mantenimiento'),
(1, 1, 1, 3, 'soporte', '2026-10-06 10:00:00', 'completada', 'Revisión técnica de switch core y enlace principal en Clínica San Gabriel.'),
(10, 10, 2, 3, 'soporte', '2026-10-19 14:00:00', 'completada', 'Revisión y configuración de reglas de firewall FortiGate en Lima.'),
(11, 11, 3, 4, 'instalacion', '2026-10-20 10:00:00', 'completada', 'Punto de acceso UniFi WiFi 6 instalado y operativo en aulas.'),
(12, 12, 4, 4, 'soporte', '2026-10-21 11:00:00', 'completada', 'Mantenimiento de impresora láser y cambio de rodillos en Miraflores.'),
(13, 13, 5, 3, 'diagnostico', '2026-10-22 09:30:00', 'completada', 'Diagnóstico térmico de estación de trabajo CAD en Callao.'),
(14, 14, 6, 3, 'preventiva', '2026-10-22 15:00:00', 'completada', 'Inspección de switch de piso en Hotel Mirador del Sol.'),
(15, 15, 7, 4, 'soporte', '2026-10-23 08:30:00', 'completada', 'Sustitución de disco SAS en servidor HPE en Breña.'),
(16, 16, 8, 4, 'soporte', '2026-10-23 14:00:00', 'completada', 'Cambio de fuente de poder en módulo de farmacia en Jesús María.'),
(17, 17, 9, 3, 'preventiva', '2026-10-23 17:00:00', 'completada', 'Reemplazo de baterías de Smart-UPS 3000VA en San Isidro.'),
(18, 18, 10, 3, 'soporte', '2026-10-24 09:00:00', 'en_curso', 'Atención en sitio: configuración de almacenamiento médico en Clínica Santa Elena.'),
(19, 19, 1, 4, 'instalacion', '2026-10-24 11:30:00', 'programada', 'Instalación y peinado de cableado en rack de comunicaciones.'),
(20, 20, 2, 3, 'diagnostico', '2026-10-24 15:00:00', 'programada', 'Relevamiento para expansión de storage NAS en Distribuidora Andina.'),
(21, 21, 3, 4, 'instalacion', '2026-10-25 09:00:00', 'programada', 'Comisionamiento de altavoces de voceo IP en Colegio Santa Rosa.'),
(22, 22, 4, 4, 'preventiva', '2026-10-25 11:30:00', 'programada', 'Mantenimiento preventivo anual de equipos en Estudio Valdivia.'),
(23, 23, 5, 3, 'soporte', '2026-10-26 09:30:00', 'programada', 'Ajuste de enlaces de contingencia en Constructora Pacífico.'),
(24, 24, 6, 4, 'instalacion', '2026-10-26 14:30:00', 'programada', 'Montaje de antenas WiFi outdoor en terraza de Hotel Mirador.');

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

INSERT INTO `crm_leads` VALUES (2,'LD-0002','Distribuidora Andina SAC','Marco Tello','Gerente de Logística','mtello@andina.pe','976543210','Comercio','web','Cotización de red WiFi para almacén','contactado',70,6,NULL,NULL,NULL,'2026-09-30 09:13:47','2026-10-05 13:13:47'),(3,'LD-0003','Colegio Nuevo Horizonte','Ana Beltrán','Directora','direccion@nuevohorizonte.edu.pe','965432109','Educación','evento','Laboratorio de cómputo 30 equipos','nuevo',65,7,NULL,NULL,NULL,'2026-10-04 05:13:47','2026-10-05 13:13:47'),(4,'LD-0004','Transportes Rápido Sur','Iván Cabrera','Jefe de TI','icabrera@rapidosur.pe','954321098','Transporte','llamada','Mantenimiento preventivo de flota de laptops','contactado',70,6,NULL,NULL,NULL,'2026-09-27 07:13:47','2026-10-05 13:13:47'),(5,'LD-0005','Hotel Mirador del Valle','Sonia Prado','Administradora','sprado@miradorvalle.pe','943210987','Turismo','redes','Cableado estructurado y WiFi para huéspedes','nuevo',40,6,NULL,NULL,NULL,'2026-10-05 08:13:47','2026-10-05 13:13:47'),(6,'LD-0006','Constructora Pilar','Raúl Gamarra','Gerente General','rgamarra@pilar.pe','932109876','Construcción','referido','Servidor de archivos y respaldo en la nube','calificado',95,7,NULL,NULL,NULL,'2026-09-24 08:13:47','2026-10-05 13:13:47'),(7,'LD-0007','Bodega El Roble','Julia Meza','Propietaria','julia@elroble.pe','921098765','Retail','correo','Punto de venta y red básica','descartado',55,6,NULL,'Ya cuenta con proveedor de TI',NULL,'2026-09-15 10:13:47','2026-10-05 13:13:47'),(8,'LD-0008','Notaría Villanueva','Dr. Pablo Villanueva','Notario','pvillanueva@notaria.pe','910987654','Servicios','web','Soporte mensual y ciberseguridad','nuevo',60,6,NULL,NULL,NULL,'2026-10-03 06:13:47','2026-10-05 13:13:47'),(9,'LD-0009','Prospecto Comercial SAC Test','Dra. Patricia Silva','Directora de Operaciones','contacto@automatizado.pe','991223344','Comercio','web','Implementación de mesa de ayuda en la nube','calificado',70,NULL,NULL,NULL,NULL,'2026-10-11 17:05:05','2026-10-11 17:05:05'),
(1, 'LD-0001', 'Grupo Corporativo Andino', 'Ing. Roberto Alarcón', 'Gerente General', 'ralarcon@grupoandino.pe', '999000111', 'Industrial', 'web', 'Soporte y virtualización cloud', 'calificado', 80, 6, 'Interesados en contrato de 24 meses.', NULL, NULL, '2026-10-01 10:00:00', '2026-10-05 11:00:00'),
(10, 'LD-0010', 'Laboratorios BioSalud del Perú', 'Dra. Verónica Campos', 'Directora de Operaciones', 'vcampos@biosalud.pe', '998112233', 'Salud', 'web', 'Soporte 24/7 y servidores para software de laboratorio clínico', 'calificado', 85, 6, 'Interés urgente por caída reciente de servidor de base de datos local.', NULL, NULL, '2026-10-15 10:00:00', '2026-10-20 11:30:00'),
(11, 'LD-0011', 'Inmobiliaria Los Álamos S.A.C.', 'Ing. Gustavo Peirano', 'Gerente de Proyectos', 'gpeirano@losalamos.pe', '998223344', 'Construcción', 'referido', 'Migración completa de correo corporativo a Microsoft 365 con backup en nube', 'contactado', 70, 6, 'Reunión inicial realizada. Requieren propuesta para 45 buzones empresariales.', NULL, NULL, '2026-10-16 11:15:00', '2026-10-21 14:00:00'),
(12, 'LD-0012', 'Importadora & Exportadora Marítima', 'Sr. Luis Barrenechea', 'Jefe de Sistemas', 'lbarrenechea@maritima.pe', '998334455', 'Comercio Exterior', 'llamada', 'Auditoría de seguridad perimetral y firewall FortiGate con doble enlace', 'calificado', 90, 6, 'Tienen auditoría de certificación BASC a fines de mes.', NULL, NULL, '2026-10-17 09:30:00', '2026-10-22 10:15:00'),
(13, 'LD-0013', 'Estudio Jurídico Morales & Abogados', 'Dra. Silvia Morales', 'Socia Administradora', 'smorales@moralesabogados.pe', '998445566', 'Servicios Legales', 'web', 'Plataforma de backup inmutable contra ransomware para expedientes confidenciales', 'nuevo', 60, 6, 'Descargaron brochure técnico desde portal web.', NULL, NULL, '2026-10-18 14:20:00', '2026-10-18 14:20:00'),
(14, 'LD-0014', 'Cadena de Restaurantes El Buen Sabor', 'Sr. Carlos Becerra', 'Gerente General', 'cbecerra@elbuensabor.pe', '998556677', 'Gastronomía', 'evento', 'Soporte de conectividad para puntos de venta en 8 locales comerciales', 'contactado', 65, 6, 'Contacto obtenido en feria de franquicias gastronómicas.', NULL, NULL, '2026-10-19 16:00:00', '2026-10-22 17:00:00'),
(15, 'LD-0015', 'Textil Andina Exportadora', 'Ing. Walter Quiroga', 'Jefe de Planta', 'wquiroga@textilandina.pe', '998667788', 'Manufactura', 'linkedin', 'Cableado estructurado y WiFi industrial para galpón de 2,500 m2', 'calificado', 80, 6, 'Visita técnica de relevamiento programada para el lunes.', NULL, NULL, '2026-10-20 08:45:00', '2026-10-23 09:30:00'),
(16, 'LD-0016', 'Agencia de Aduanas TransPacífico', 'Lic. Mónica Arrieta', 'Subgerente de TI', 'marrieta@transpacifico.pe', '998778899', 'Logística', 'referido', 'Contrato de mesa de ayuda nivel 1 y 2 para 60 usuarios remotos', 'nuevo', 55, 6, 'Referidos por cliente Transportes Inca Express.', NULL, NULL, '2026-10-21 12:10:00', '2026-10-21 12:10:00'),
(17, 'LD-0017', 'Consultora de Negocios GlobalBiz', 'Lic. Andrés Tello', 'Director Asociado', 'atello@globalbiz.pe', '998889900', 'Consultoría', 'web', 'Implementación de VPN corporativa y telefonía IP en la nube', 'contactado', 60, 6, 'Solicitaron cotización referencial por 20 extensiones SIP.', NULL, NULL, '2026-10-21 15:30:00', '2026-10-23 11:00:00'),
(18, 'LD-0018', 'Centro Odontológico DentalPlus', 'Dr. Enrique Zúñiga', 'Propietario', 'ezuniga@dentalplus.pe', '998990011', 'Salud', 'llamada', 'Mantenimiento de computadoras y red local', 'descartado', 30, 6, 'Presupuesto disponible no cubre SLA mínimo empresarial.', 'Presupuesto insuficiente para contrato corporativo', NULL, '2026-10-22 10:00:00', '2026-10-23 15:00:00'),
(19, 'LD-0019', 'Distribuidora Automotriz del Sur', 'Ing. Javier Neyra', 'Gerente de Operaciones', 'jneyra@autosur.pe', '997112233', 'Automotriz', 'linkedin', 'Servidores de base de datos para sistema de repuestos y facturación', 'calificado', 85, 6, 'Muy interesados en esquema de alta disponibilidad con réplica MySQL.', NULL, NULL, '2026-10-22 14:15:00', '2026-10-24 08:30:00'),
(20, 'LD-0020', 'Colegio Mayor San Marcos', 'Hna. Rosario Palomino', 'Administradora General', 'rpalomino@sanmarcos.edu.pe', '997223344', 'Educación', 'web', 'Filtrado de contenidos web y control de ancho de banda para estudiantes', 'nuevo', 65, 6, 'Requieren firewall con control de aplicaciones por horario escolar.', NULL, NULL, '2026-10-23 09:00:00', '2026-10-23 09:00:00'),
(21, 'LD-0021', 'Financiera Progreso Popular', 'CPC Dante Hurtado', 'Gerente de Administración', 'dhurtado@financieraprogreso.pe', '997334455', 'Financiero', 'referido', 'Soporte TI 24/7 y plan de contingencia ante desastres certificado', 'calificado', 95, 6, 'Contrato de alto valor (S/ 7,500/mes). Aprobado para emisión de cotización.', NULL, NULL, '2026-10-23 16:30:00', '2026-10-24 09:15:00');

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

INSERT INTO `crm_oportunidades` VALUES (2,'OP-0002','Migración de servidores a la nube',6,3,NULL,3,'proyecto',38500.00,50,'2026-10-30',NULL,6,'referido','abierta',NULL,NULL,'Oportunidad generada a partir de conversaciones con el cliente.','2026-08-03 13:13:47','2026-10-05 13:13:47'),(3,'OP-0003','Cableado estructurado sede nueva',3,5,NULL,3,'proyecto',14200.00,50,'2026-11-14',NULL,7,'web','abierta',NULL,NULL,'Oportunidad generada a partir de conversaciones con el cliente.','2026-08-05 13:13:47','2026-10-09 00:04:36'),(4,'OP-0004','Contrato Business · soporte mensual',4,7,NULL,3,'contrato',11400.00,50,'2026-10-23',NULL,6,'llamada','abierta',NULL,NULL,'Oportunidad generada a partir de conversaciones con el cliente.','2026-08-20 13:13:47','2026-10-05 13:13:47'),(5,'OP-0005','Venta de 15 laptops corporativas',5,9,NULL,4,'equipos',27800.00,75,'2026-10-12',NULL,6,'evento','abierta',NULL,NULL,'Oportunidad generada a partir de conversaciones con el cliente.','2026-08-21 13:13:47','2026-10-05 13:13:47'),(6,'OP-0006','Upgrade de seguridad perimetral',6,11,NULL,6,'proyecto',16900.00,10,'2026-11-29',NULL,7,'web','abierta',NULL,NULL,'Oportunidad generada a partir de conversaciones con el cliente.','2026-07-13 13:13:47','2026-10-05 13:13:47'),(7,'OP-0007','Contrato Premium 24/7',7,13,NULL,6,'contrato',21600.00,25,'2026-11-04',NULL,6,'redes','abierta',NULL,NULL,'Oportunidad generada a partir de conversaciones con el cliente.','2026-08-04 13:13:47','2026-10-05 13:13:47'),(8,'OP-0008','Renovación contrato Business',8,15,NULL,3,'renovacion',11400.00,50,'2026-10-15',NULL,6,'referido','abierta',NULL,NULL,'Oportunidad generada a partir de conversaciones con el cliente.','2026-08-24 13:13:47','2026-10-05 13:13:47'),(9,'OP-0009','Implementación de telefonía IP',6,1,NULL,6,'proyecto',9800.00,25,'2026-12-04',NULL,7,'correo','abierta',NULL,NULL,'Oportunidad generada a partir de conversaciones con el cliente.','2026-07-08 13:13:47','2026-10-12 00:05:27'),(10,'OP-0010','Mantenimiento preventivo anual',6,3,NULL,5,'servicio',8400.00,100,'2026-09-23','2026-09-23',6,'llamada','ganada',NULL,NULL,'Oportunidad generada a partir de conversaciones con el cliente.','2026-09-07 13:13:47','2026-10-05 13:13:47'),(11,'OP-0011','Servidor de archivos NAS',3,5,NULL,5,'equipos',12600.00,100,'2026-09-10','2026-09-10',6,'web','ganada',NULL,NULL,'Oportunidad generada a partir de conversaciones con el cliente.','2026-08-24 13:13:47','2026-10-05 13:13:47'),(12,'OP-0012','Contrato Básico soporte remoto',4,7,NULL,5,'contrato',5040.00,100,'2026-08-26','2026-08-26',7,'referido','ganada',NULL,NULL,'Oportunidad generada a partir de conversaciones con el cliente.','2026-07-18 13:13:47','2026-10-05 13:13:47'),(13,'OP-0013','Auditoría de red y licencias',5,9,NULL,6,'servicio',6500.00,0,'2026-09-17','2026-09-17',6,'web','perdida','Decidió postergar el proyecto',NULL,'Oportunidad generada a partir de conversaciones con el cliente.','2026-08-14 13:13:47','2026-10-05 13:13:47'),(14,'OP-0014','Cambio de switches core',6,11,NULL,6,'equipos',19800.00,0,'2026-09-02','2026-09-02',6,'evento','perdida','Precio superior a la competencia',NULL,'Oportunidad generada a partir de conversaciones con el cliente.','2026-08-04 13:13:47','2026-10-05 13:13:47'),(15,'OP-0015','Oportunidad - Clínica Santa Elena',10,NULL,6,1,'contrato',12000.00,10,'2026-11-25',NULL,6,'referido','abierta',NULL,NULL,NULL,'2026-10-11 17:05:05','2026-10-12 00:05:31'),
(1, 'OP-0001', 'Mantenimiento Preventivo Anual Grupo Andino', 1, 1, 1, 3, 'contrato', 32000.00, 60, '2026-11-30', NULL, 6, 'web', 'abierta', NULL, NULL, 'Contrato de soporte técnico preventivo para servidores y redes.', '2026-10-01 11:00:00', '2026-10-05 12:00:00'),
(16, 'OP-0016', 'Servicio de Respaldo Inmutable Cloud para BioSalud', 1, 1, 10, 3, 'servicio', 18500.00, 60, '2026-11-15', NULL, 6, 'web', 'abierta', NULL, NULL, 'Implementación de repositorio de backup inmutable en S3 con políticas de retención mensual.', '2026-10-20 11:30:00', '2026-10-23 10:00:00'),
(17, 'OP-0017', 'Migración Microsoft 365 y Backup Cloud Los Álamos', 5, 5, 11, 2, 'proyecto', 24800.00, 40, '2026-11-20', NULL, 6, 'referido', 'abierta', NULL, NULL, 'Migración de 45 casillas de correo de hosting local a Microsoft 365 Business Standard.', '2026-10-21 14:00:00', '2026-10-23 11:15:00'),
(18, 'OP-0018', 'Implementación Perimetral FortiGate 100F Marítima', 7, 7, 12, 4, 'equipos', 36500.00, 80, '2026-11-05', NULL, 6, 'llamada', 'abierta', NULL, NULL, 'Suministro de appliance FortiGate 100F con licenciamiento UTP por 1 año y configuración HA.', '2026-10-22 10:15:00', '2026-10-23 14:30:00'),
(19, 'OP-0019', 'Renovación de Infraestructura Wi-Fi 6E Colegio Santa Rosa', 3, 3, NULL, 3, 'proyecto', 28900.00, 60, '2026-11-10', NULL, 6, 'origen', 'abierta', NULL, NULL, 'Despliegue de 12 puntos de acceso UniFi U6 Enterprise para cubrir 3 pabellones de aulas.', '2026-10-22 12:00:00', '2026-10-23 16:00:00'),
(20, 'OP-0020', 'Contrato Soporte Platino 24/7 Financiera Progreso', 4, 4, 21, 4, 'contrato', 90000.00, 85, '2026-10-31', NULL, 6, 'referido', 'abierta', NULL, NULL, 'Contrato anual de soporte integral 24/7 a S/ 7,500/mes con SLA de 2h de atención presencial.', '2026-10-23 09:30:00', '2026-10-24 09:00:00'),
(21, 'OP-0021', 'Servidor de Base de Datos MySQL HA Autosur', 2, 2, 19, 3, 'equipos', 42000.00, 65, '2026-11-12', NULL, 6, 'linkedin', 'abierta', NULL, NULL, 'Servidor Dell PowerEdge R640 en configuración de réplica master-slave para ERP corporativo.', '2026-10-23 11:00:00', '2026-10-24 09:30:00'),
(22, 'OP-0022', 'Red de Cableado Cat6A para Galpón Textil Andina', 5, 5, 15, 2, 'proyecto', 31200.00, 45, '2026-11-25', NULL, 6, 'linkedin', 'abierta', NULL, NULL, 'Instalación de 48 puntos dobles de red Cat6A blindado y gabinetes intermedios con fibra.', '2026-10-23 13:45:00', '2026-10-24 10:00:00'),
(23, 'OP-0023', 'Renovación de Licenciamiento Antivirus EDR Clínica San Gabriel', 1, 1, NULL, 5, 'servicio', 15400.00, 100, '2026-10-20', '2026-10-20', 6, 'origen', 'ganada', NULL, 1, 'Protección de 80 puestos de trabajo con SentinelOne Singularity Control.', '2026-10-10 09:00:00', '2026-10-20 17:00:00'),
(24, 'OP-0024', 'Ampliación de Storage Synology Distribuidora Andina', 2, 2, NULL, 5, 'equipos', 19800.00, 100, '2026-10-22', '2026-10-22', 6, 'origen', 'ganada', NULL, 2, 'Suministro e instalación de unidad de expansión Synology DX517 con 5 discos Seagate IronWolf Pro.', '2026-10-12 11:30:00', '2026-10-22 18:00:00'),
(25, 'OP-0025', 'Telefonía IP y Troncal SIP Hotel Mirador del Sol', 6, 6, NULL, 5, 'proyecto', 22500.00, 100, '2026-10-23', '2026-10-23', 6, 'origen', 'ganada', NULL, 6, 'Centralita IP Grandstream UCM6304 con 60 teléfonos SIP para habitaciones y recepción.', '2026-10-05 10:00:00', '2026-10-23 16:30:00'),
(26, 'OP-0026', 'Consultoría de Seguridad ISO 27001 Clínica Santa Elena', 10, 10, NULL, 3, 'servicio', 28000.00, 50, '2026-11-30', NULL, 6, 'web', 'abierta', NULL, NULL, 'Auditoría de brechas de seguridad y plan de remediación conforme a norma ISO/IEC 27001.', '2026-10-23 15:00:00', '2026-10-24 10:15:00'),
(27, 'OP-0027', 'Soporte Nivel 1 Microempresa DentalPlus', 8, 8, 18, 6, 'servicio', 4500.00, 0, '2026-10-23', '2026-10-23', 6, 'llamada', 'perdida', 'Presupuesto fuera de alcance del cliente', NULL, 'Propuesta descartada por falta de presupuesto para contrato formal de soporte.', '2026-10-22 10:30:00', '2026-10-23 15:15:00');

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

INSERT INTO `crm_cotizaciones` VALUES (2,'COT-0002',2,2,3,'2026-09-30','2026-10-15','enviada',0.00,18.00,35400.00,0.00,6372.00,41772.00,'• Precios en soles (S/). Incluyen IGV.\n• Forma de pago: 50% al aceptar, 50% contra entrega.\n• Plazo de entrega/implementación: según cronograma acordado.\n• Garantía de 12 meses en equipos y 30 días en servicios.',NULL,1,'2026-10-05 13:13:47'),(3,'COT-0003',4,4,7,'2026-10-05','2026-10-20','borrador',0.00,18.00,11400.00,0.00,2052.00,13452.00,'• Precios en soles (S/). Incluyen IGV.\n• Forma de pago: 50% al aceptar, 50% contra entrega.\n• Plazo de entrega/implementación: según cronograma acordado.\n• Garantía de 12 meses en equipos y 30 días en servicios.',NULL,1,'2026-10-05 13:13:47'),(4,'COT-0004',3,11,5,'2026-09-05','2026-09-20','aprobada',0.00,18.00,11700.00,0.00,2106.00,13806.00,'• Precios en soles (S/). Incluyen IGV.\n• Forma de pago: 50% al aceptar, 50% contra entrega.\n• Plazo de entrega/implementación: según cronograma acordado.\n• Garantía de 12 meses en equipos y 30 días en servicios.',NULL,1,'2026-10-05 13:13:47'),(5,'COT-0005',5,13,9,'2026-09-15','2026-09-30','rechazada',0.00,18.00,5500.00,0.00,990.00,6490.00,'• Precios en soles (S/). Incluyen IGV.\n• Forma de pago: 50% al aceptar, 50% contra entrega.\n• Plazo de entrega/implementación: según cronograma acordado.\n• Garantía de 12 meses en equipos y 30 días en servicios.',NULL,1,'2026-10-05 13:13:47'),
(1, 'COT-0001', 1, 1, 1, '2026-10-02', '2026-11-02', 'aprobada', 0.00, 18.00, 27118.64, 0.00, 4881.36, 32000.00, 'Crédito a 30 días factura comercial.', 'Servicio de soporte anual con visitas preventivas mensuales.', 6, '2026-10-02 10:00:00'),
(6, 'COT-0006', 1, 16, 1, '2026-10-20', '2026-11-20', 'enviada', 0.00, 18.00, 15677.97, 0.00, 2822.03, 18500.00, '50% de adelanto a la firma, 50% al término de la migración y pruebas.', 'Incluye 12 meses de almacenamiento en la nube y configuración de políticas RPO 2h.', 6, '2026-10-20 14:00:00'),
(7, 'COT-0007', 7, 18, 7, '2026-10-22', '2026-11-22', 'enviada', 5.00, 18.00, 29605.93, 1480.30, 5062.61, 33188.24, '30 días de crédito previa orden de compra confirmada.', 'Appliance Fortinet original con soporte de fabricante 24x7 por 12 meses.', 6, '2026-10-22 11:30:00'),
(8, 'COT-0008', 3, 19, 3, '2026-10-22', '2026-11-22', 'enviada', 0.00, 18.00, 24491.53, 0.00, 4408.47, 28900.00, '40% adelanto, 60% contra acta de conformidad técnica firmada.', 'Incluye certificación Fluke de los 12 puntos de red de alta velocidad.', 6, '2026-10-22 16:00:00'),
(9, 'COT-0009', 4, 20, 4, '2026-10-23', '2026-11-23', 'aprobada', 0.00, 18.00, 76271.19, 0.00, 13728.81, 90000.00, 'Facturación mensual vencida de S/ 7,500.00 inc. IGV.', 'Contrato de soporte integral SLA Platinum 24/7 con 2 horas de respuesta.', 6, '2026-10-23 10:00:00'),
(10, 'COT-0010', 2, 24, 2, '2026-10-21', '2026-11-21', 'aprobada', 0.00, 18.00, 16779.66, 0.00, 3020.34, 19800.00, 'Contado contra entrega e instalación en sitio.', 'Garantía extendida de 3 años sobre los discos Seagate Enterprise.', 6, '2026-10-21 15:30:00'),
(11, 'COT-0011', 6, 25, 6, '2026-10-22', '2026-11-22', 'aprobada', 3.00, 18.00, 18495.76, 554.87, 3229.36, 21170.25, '50% adelanto, saldo a 30 días de la puesta en marcha.', 'Capacitación presencial al personal de recepción en el uso de la centralita IP.', 6, '2026-10-22 17:00:00');

CREATE TABLE `crm_cotizacion_items` (
    `id` BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    `cotizacion_id` BIGINT UNSIGNED NOT NULL,
    `descripcion` VARCHAR(255) NOT NULL,
    `cantidad` DECIMAL(10,2) NOT NULL DEFAULT 1.00,
    `precio_unit` DECIMAL(12,2) NOT NULL DEFAULT 0.00,
    CONSTRAINT `fk_ci_coti` FOREIGN KEY (`cotizacion_id`) REFERENCES `crm_cotizaciones` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

INSERT INTO `crm_cotizacion_items` VALUES (4,2,'Migración de servidores a nube híbrida',1.00,24000.00),(5,2,'Licenciamiento cloud (12 meses)',1.00,9600.00),(6,2,'Capacitación al personal TI',1.00,1800.00),(7,3,'Plan Business · soporte mensual (12 meses)',12.00,950.00),(8,4,'NAS 4 bahías 16 TB',1.00,7800.00),(9,4,'Instalación y configuración',1.00,1500.00),(10,4,'Backup remoto (12 meses)',1.00,2400.00),(11,5,'Auditoría de red y licencias',1.00,5500.00),
(1, 1, 'Servicio de Mantenimiento Preventivo Mensual Servidores', 12.00, 1800.00),
(2, 1, 'Horas de Consultoría Cloud Nivel 3', 20.00, 250.00),
(3, 1, 'Monitoreo 24/7 y Gestión de Copias de Respaldo', 12.00, 459.88),
(12, 6, 'Suscripción anual Repositorio Inmutable Cloud 5TB', 1.00, 8500.00),
(13, 6, 'Servicio de consultoría y configuración de políticas DRP', 1.00, 7177.97),
(14, 7, 'Firewall Fortinet FortiGate 100F Dual Power', 1.00, 21500.00),
(15, 7, 'Licencia FortiGuard Unified Threat Protection (UTP) 1 Año', 1.00, 8105.93),
(16, 8, 'Punto de Acceso UniFi U6 Enterprise WiFi 6E', 12.00, 1450.00),
(17, 8, 'Servicio de instalación, cableado Cat6A y certificación', 1.00, 7091.53),
(18, 9, 'Servicio de Soporte y Mantenimiento TI Anual Nivel Platino', 12.00, 6355.93),
(19, 10, 'Unidad de Expansión Synology DX517 5 Bahías', 1.00, 4800.00),
(20, 10, 'Disco Duro Seagate Exos 8TB Enterprise SATA 7200RPM', 5.00, 2395.93),
(21, 11, 'Central Telefónica IP Grandstream UCM6304 hasta 1000 usuarios', 1.00, 6500.00),
(22, 11, 'Teléfono IP Grandstream GRP2615 con pantalla a color', 20.00, 599.79);

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

INSERT INTO `crm_actividades` VALUES (2,'reunion','Reunión de presentación de propuesta',NULL,'2026-10-05 10:30:00',0,NULL,NULL,0,2,NULL,2,6,1,'2026-10-05 13:13:47'),(3,'correo','Enviar cotización actualizada',NULL,'2026-10-05 11:00:00',0,NULL,NULL,0,5,NULL,5,7,1,'2026-10-05 13:13:47'),(4,'tarea','Preparar demo de monitoreo 24/7',NULL,'2026-10-06 12:30:00',0,NULL,NULL,0,7,NULL,7,6,1,'2026-10-05 13:13:47'),(5,'visita','Visita técnica para levantamiento de cableado',NULL,'2026-10-07 13:00:00',0,NULL,NULL,0,3,NULL,3,6,1,'2026-10-05 13:13:47'),(6,'llamada','Seguimiento a renovación de contrato',NULL,'2026-10-04 14:30:00',0,NULL,NULL,0,1,NULL,1,7,1,'2026-10-05 13:13:47'),(7,'reunion','Negociación final de condiciones',NULL,'2026-10-08 15:00:00',0,NULL,NULL,0,5,NULL,5,6,1,'2026-10-05 13:13:47'),(8,'tarea','Revisar propuesta económica con gerencia',NULL,'2026-10-10 16:30:00',0,NULL,NULL,0,4,NULL,4,6,1,'2026-10-05 13:13:47'),(9,'llamada','Primer contacto con lead del evento',NULL,'2026-10-05 09:00:00',0,NULL,NULL,0,NULL,3,NULL,7,1,'2026-10-05 13:13:47'),(10,'correo','Enviar brochure de servicios',NULL,'2026-10-06 10:30:00',0,NULL,NULL,0,NULL,5,NULL,6,1,'2026-10-05 13:13:47'),(11,'llamada','Calificar necesidades del lead',NULL,'2026-10-02 11:00:00',0,NULL,NULL,0,NULL,2,NULL,6,1,'2026-10-05 13:13:47'),(12,'reunion','Reunión de kick-off',NULL,'2026-09-25 12:30:00',1,'2026-09-25 12:30:00','Reunión realizada. Cliente interesado, se acordó enviar propuesta.',0,2,NULL,10,7,1,'2026-10-05 13:13:47'),(13,'nota','Oportunidad ganada: Mantenimiento preventivo anual',NULL,'2026-09-25 13:13:47',1,'2026-09-07 13:13:47',NULL,1,2,NULL,10,NULL,1,'2026-10-05 13:13:47'),(14,'nota','Oportunidad ganada: Servidor de archivos NAS',NULL,'2026-09-25 13:13:47',1,'2026-08-24 13:13:47',NULL,1,3,NULL,11,NULL,2,'2026-10-05 13:13:47'),(15,'nota','Oportunidad ganada: Contrato Básico soporte remoto',NULL,'2026-09-25 13:13:47',1,'2026-07-18 13:13:47',NULL,1,4,NULL,12,NULL,7,'2026-10-05 13:13:47'),(16,'nota','Etapa: Calificación → Propuesta',NULL,'2026-10-09 00:04:36',1,'2026-10-09 00:04:36',NULL,1,3,NULL,3,6,1,'2026-10-09 00:04:36'),
(1, 'llamada', 'Contacto inicial de prospección Grupo Andino', 'Presentación de catálogo de servicios cloud.', '2026-10-01 10:30:00', 1, '2026-10-01 10:50:00', 'Cliente solicita reunión técnica presencial.', 0, 1, 1, 1, 6, 6, '2026-10-01 10:00:00'),
(17, 'llamada', 'Llamada inicial de calificación con BioSalud', 'Conversación con Dra. Verónica Campos para dimensionar requerimiento de almacenamiento.', '2026-10-18 10:00:00', 1, '2026-10-18 10:25:00', 'Cliente muy receptivo. Solicita propuesta técnica formal de backup.', 0, 1, 10, 16, 6, 6, '2026-10-18 09:30:00'),
(18, 'reunion', 'Presentación de propuesta técnica Microsoft 365', 'Videoconferencia por Microsoft Teams con Gerencia de Inmobiliaria Los Álamos.', '2026-10-21 15:00:00', 1, '2026-10-21 16:00:00', 'Propuesta aprobada conceptualmente. Pendiente visto bueno de directorio.', 0, 5, 11, 17, 6, 6, '2026-10-19 11:00:00'),
(19, 'visita', 'Relevamiento físico de rack y cableado Marítima', 'Inspección técnica de gabinete de comunicaciones en Callao con Brayan Hurtado.', '2026-10-22 09:30:00', 1, '2026-10-22 11:45:00', 'Espacio de 2U disponible en rack. Confirmada viabilidad de instalación FortiGate.', 0, 7, 12, 18, 6, 6, '2026-10-20 14:00:00'),
(20, 'reunion', 'Comité de Adquisiciones de TI Financiera Progreso', 'Reunión presencial de negociación de SLA y cláusulas de confidencialidad NDA.', '2026-10-23 11:00:00', 1, '2026-10-23 12:30:00', 'Acuerdo en monto y tiempos de respuesta. Aprobación final formalizada.', 0, 4, 21, 20, 6, 6, '2026-10-22 16:30:00'),
(21, 'correo', 'Envío de cotización formal COT-0008 a Colegio Santa Rosa', 'Envío de PDF de propuesta y ficha técnica de access points UniFi WiFi 6E.', '2026-10-22 16:30:00', 1, '2026-10-22 16:32:00', 'Confirmada recepción por Director de Tecnologías.', 1, 3, NULL, 19, 6, 6, '2026-10-22 16:30:00'),
(22, 'llamada', 'Seguimiento a Directorio de Los Álamos', 'Llamada de confirmación de aprobación para inicio de migración cloud.', '2026-10-24 10:30:00', 0, NULL, NULL, 0, 5, 11, 17, 6, 6, '2026-10-23 17:00:00'),
(23, 'reunion', 'Demo de consola de monitoreo Zabbix para Autosur', 'Sesión práctica de paneles en vivo y alertas automáticas por Telegram/Correo.', '2026-10-24 11:30:00', 0, NULL, NULL, 0, 2, 19, 21, 6, 6, '2026-10-23 17:15:00'),
(24, 'visita', 'Inspección de avance de cableado en galpón Textil Andina', 'Supervisión en planta textil para validación de rutas de bandejas portacables.', '2026-10-25 09:30:00', 0, NULL, NULL, 0, 5, 15, 22, 6, 6, '2026-10-23 17:30:00'),
(25, 'llamada', 'Coordinación de despacho de discos para Clínica San Gabriel', 'Llamada con proveedor mayorista Deltron para entrega de repuestos en fecha.', '2026-10-25 15:00:00', 0, NULL, NULL, 0, 1, NULL, 16, 6, 6, '2026-10-24 08:30:00'),
(26, 'correo', 'Envío de informe de métricas SLA de Octubre a clientes Premium', 'Distribución automatizada de reportes mensuales de cumplimiento de tickets.', '2026-10-26 08:00:00', 0, NULL, NULL, 1, 1, NULL, 23, 6, 6, '2026-10-24 08:45:00'),
(27, 'llamada', 'Contacto inicial con Inversiones Los Andes', 'Llamada de prospección sobre servicios de soporte gestionado.', '2026-10-26 10:00:00', 0, NULL, NULL, 0, 2, NULL, NULL, 6, 6, '2026-10-24 09:00:00'),
(28, 'reunion', 'Planificación de simulacro de recuperación DRP con Clínica San Gabriel', 'Reunión de coordinación técnica para prueba semestral de restauración de backups.', '2026-10-27 11:00:00', 0, NULL, NULL, 0, 1, NULL, NULL, 6, 6, '2026-10-24 09:15:00'),
(29, 'visita', 'Revisión final de instalación centralita telefónica Hotel Mirador', 'Verificación de llamadas entrantes, IVR de atención y tarificación por habitación.', '2026-10-27 15:30:00', 0, NULL, NULL, 0, 6, NULL, 25, 6, 6, '2026-10-24 09:30:00'),
(30, 'correo', 'Envío de acta de entrega y conformidad técnica a BioSalud', 'Documentación formal de cierre de proyecto de almacenamiento.', '2026-10-28 09:00:00', 0, NULL, NULL, 1, 1, 10, 16, 6, 6, '2026-10-24 09:45:00'),
(31, 'llamada', 'Encuesta de satisfacción de atención de tickets mes de Octubre', 'Llamada de control de calidad a usuarios clave de Farmacias Vida Plus.', '2026-10-28 14:00:00', 0, NULL, NULL, 0, 8, NULL, NULL, 6, 6, '2026-10-24 10:00:00'),
(32, 'reunion', 'Revisión trimestral de contrato con Constructora Pacífico', 'Evaluación de horas hombre consumidas y ajustes para siguiente trimestre.', '2026-10-29 10:30:00', 0, NULL, NULL, 0, 5, NULL, NULL, 6, 6, '2026-10-24 10:15:00'),
(33, 'visita', 'Demostración de terminales táctiles Elo en sede Jesús María', 'Prueba de estrés de impresión y velocidad de respuesta de pantalla.', '2026-10-29 16:00:00', 0, NULL, NULL, 0, 8, NULL, NULL, 6, 6, '2026-10-24 10:30:00'),
(34, 'correo', 'Aviso de vencimiento anticipado de contrato a Distribuidora Andina', 'Recordatorio de 30 días para renovación de servicio de soporte.', '2026-10-30 08:30:00', 0, NULL, NULL, 1, 2, NULL, NULL, 6, 6, '2026-10-24 10:45:00'),
(35, 'llamada', 'Coordinación con gerencia de Clínica Santa Elena', 'Alineación de fecha de inicio para auditoría de seguridad ISO 27001.', '2026-10-30 11:30:00', 0, NULL, NULL, 0, 10, NULL, 26, 6, 6, '2026-10-24 11:00:00'),
(36, 'reunion', 'Cierre comercial de mes y balance de ventas Q4 2026', 'Sesión de análisis de cumplimiento de cuota de ventas con Coordinación General TI.', '2026-10-30 17:00:00', 0, NULL, NULL, 0, 1, NULL, NULL, 6, 6, '2026-10-24 11:15:00');

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
-- 6. BASE DE DATOS: db_billing (Facturación, Secuencias, Comprobantes, Pagos)
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

INSERT INTO `fac_comprobantes` VALUES (1,'factura','F001',1,'F001-000001',1,'mensualidad',1,NULL,NULL,'2026-07','2026-07-05','2026-07-20',18.00,1800.00,324.00,2124.00,2124.00,'pagada',NULL,NULL,1,'2026-10-05 18:30:44'),(2,'factura','F001',2,'F001-000002',1,'mensualidad',1,NULL,NULL,'2026-08','2026-08-05','2026-08-20',18.00,1800.00,324.00,2124.00,0.00,'emitida',NULL,NULL,1,'2026-10-05 18:30:45'),(3,'factura','F001',3,'F001-000003',1,'mensualidad',1,NULL,NULL,'2026-09','2026-09-05','2026-09-20',18.00,1800.00,324.00,2124.00,0.00,'emitida',NULL,NULL,1,'2026-10-05 18:30:45'),(4,'factura','F001',4,'F001-000004',2,'mensualidad',2,NULL,NULL,'2026-07','2026-07-05','2026-07-20',18.00,950.00,171.00,1121.00,1121.00,'pagada',NULL,NULL,1,'2026-10-05 18:30:45'),(5,'factura','F001',5,'F001-000005',2,'mensualidad',2,NULL,NULL,'2026-08','2026-08-05','2026-08-20',18.00,950.00,171.00,1121.00,1121.00,'pagada',NULL,NULL,1,'2026-10-05 18:30:45'),(6,'factura','F001',6,'F001-000006',2,'mensualidad',2,NULL,NULL,'2026-09','2026-09-05','2026-09-20',18.00,950.00,171.00,1121.00,560.50,'emitida',NULL,NULL,1,'2026-10-05 18:30:45'),(7,'factura','F001',7,'F001-000007',3,'mensualidad',3,NULL,NULL,'2026-07','2026-07-05','2026-07-20',18.00,420.00,75.60,495.60,495.60,'pagada',NULL,NULL,1,'2026-10-05 18:30:45'),(8,'factura','F001',8,'F001-000008',3,'mensualidad',3,NULL,NULL,'2026-08','2026-08-05','2026-08-20',18.00,420.00,75.60,495.60,495.60,'pagada',NULL,NULL,1,'2026-10-05 18:30:45'),(9,'factura','F001',9,'F001-000009',3,'mensualidad',3,NULL,NULL,'2026-09','2026-09-05','2026-09-20',18.00,420.00,75.60,495.60,495.60,'pagada',NULL,NULL,1,'2026-10-05 18:30:45'),(10,'factura','F001',10,'F001-000010',4,'mensualidad',4,NULL,NULL,'2026-07','2026-07-05','2026-07-20',18.00,1800.00,324.00,2124.00,2124.00,'pagada',NULL,NULL,1,'2026-10-05 18:30:45'),(11,'factura','F001',11,'F001-000011',4,'mensualidad',4,NULL,NULL,'2026-08','2026-08-05','2026-08-20',18.00,1800.00,324.00,2124.00,2124.00,'pagada',NULL,NULL,1,'2026-10-05 18:30:45'),(12,'factura','F001',12,'F001-000012',4,'mensualidad',4,NULL,NULL,'2026-09','2026-09-05','2026-09-20',18.00,1800.00,324.00,2124.00,0.00,'emitida',NULL,NULL,1,'2026-10-05 18:30:45'),(13,'factura','F001',13,'F001-000013',5,'mensualidad',5,NULL,NULL,'2026-07','2026-07-05','2026-07-20',18.00,950.00,171.00,1121.00,1121.00,'pagada',NULL,NULL,1,'2026-10-05 18:30:45'),(14,'factura','F001',14,'F001-000014',5,'mensualidad',5,NULL,NULL,'2026-08','2026-08-05','2026-08-20',18.00,950.00,171.00,1121.00,0.00,'emitida',NULL,NULL,1,'2026-10-05 18:30:45'),(15,'factura','F001',15,'F001-000015',5,'mensualidad',5,NULL,NULL,'2026-09','2026-09-05','2026-09-20',18.00,950.00,171.00,1121.00,560.50,'emitida',NULL,NULL,1,'2026-10-05 18:30:45'),(16,'factura','F001',16,'F001-000016',6,'mensualidad',6,NULL,NULL,'2026-07','2026-07-05','2026-07-20',18.00,420.00,75.60,495.60,495.60,'pagada',NULL,NULL,1,'2026-10-05 18:30:45'),(17,'factura','F001',17,'F001-000017',6,'mensualidad',6,NULL,NULL,'2026-08','2026-08-05','2026-08-20',18.00,420.00,75.60,495.60,495.60,'pagada',NULL,NULL,1,'2026-10-05 18:30:45'),(18,'factura','F001',18,'F001-000018',6,'mensualidad',6,NULL,NULL,'2026-09','2026-09-05','2026-09-20',18.00,420.00,75.60,495.60,495.60,'pagada',NULL,NULL,1,'2026-10-05 18:30:45'),(19,'factura','F001',19,'F001-000019',7,'mensualidad',7,NULL,NULL,'2026-07','2026-07-05','2026-07-20',18.00,1800.00,324.00,2124.00,2124.00,'pagada',NULL,NULL,1,'2026-10-05 18:30:45'),(20,'factura','F001',20,'F001-000020',7,'mensualidad',7,NULL,NULL,'2026-08','2026-08-05','2026-08-20',18.00,1800.00,324.00,2124.00,2124.00,'pagada',NULL,NULL,1,'2026-10-05 18:30:45'),(21,'factura','F001',21,'F001-000021',7,'mensualidad',7,NULL,NULL,'2026-09','2026-09-05','2026-09-20',18.00,1800.00,324.00,2124.00,0.00,'emitida',NULL,NULL,1,'2026-10-05 18:30:45'),(22,'factura','F001',22,'F001-000022',8,'mensualidad',8,NULL,NULL,'2026-07','2026-07-05','2026-07-20',18.00,950.00,171.00,1121.00,1121.00,'pagada',NULL,NULL,1,'2026-10-05 18:30:45'),(23,'factura','F001',23,'F001-000023',8,'mensualidad',8,NULL,NULL,'2026-08','2026-08-05','2026-08-20',18.00,950.00,171.00,1121.00,1121.00,'pagada',NULL,NULL,1,'2026-10-05 18:30:45'),(24,'factura','F001',24,'F001-000024',8,'mensualidad',8,NULL,NULL,'2026-09','2026-09-05','2026-09-20',18.00,950.00,171.00,1121.00,560.50,'emitida',NULL,NULL,1,'2026-10-05 18:30:45'),(25,'factura','F001',25,'F001-000025',1,'servicio',NULL,1,NULL,NULL,'2026-08-28','2026-09-04',18.00,99.00,17.82,116.82,0.00,'emitida',NULL,NULL,1,'2026-10-05 18:30:45'),(26,'factura','F001',26,'F001-000026',2,'servicio',NULL,2,NULL,NULL,'2026-09-24','2026-10-01',18.00,357.00,64.26,421.26,421.26,'pagada',NULL,NULL,1,'2026-10-05 18:30:45'),(27,'factura','F001',27,'F001-000027',3,'servicio',NULL,3,NULL,NULL,'2026-08-25','2026-09-01',18.00,383.00,68.94,451.94,0.00,'emitida',NULL,NULL,1,'2026-10-05 18:30:45'),(28,'factura','F001',28,'F001-000028',4,'servicio',NULL,4,NULL,NULL,'2026-08-06','2026-08-13',18.00,288.50,51.93,340.43,340.43,'pagada',NULL,NULL,1,'2026-10-05 18:30:45'),(29,'factura','F001',29,'F001-000029',5,'servicio',NULL,5,NULL,NULL,'2026-09-10','2026-09-17',18.00,396.50,71.37,467.87,0.00,'emitida',NULL,NULL,1,'2026-10-05 18:30:45'),(30,'factura','F001',30,'F001-000030',6,'servicio',NULL,6,NULL,NULL,'2026-08-26','2026-09-02',18.00,604.50,108.81,713.31,713.31,'pagada',NULL,NULL,1,'2026-10-05 18:30:45'),(31,'factura','F001',31,'F001-000031',3,'equipos',NULL,NULL,4,NULL,'2026-09-07','2026-10-07',18.00,11700.00,2106.00,13806.00,13806.00,'pagada',NULL,NULL,1,'2026-10-05 18:30:45'),
(32, 'factura', 'F001', 32, 'F001-00000032', 1, 'servicio', 1, 13, NULL, '2026-10', '2026-10-18', '2026-11-18', 18.00, 227.50, 40.95, 268.45, 268.45, 'pagada', NULL, 'Mantenimiento semestral servidor Dell R740xd según OS-2026-013', 1, '2026-10-18 13:00:00'),
(33, 'factura', 'F001', 33, 'F001-00000033', 2, 'servicio', 2, 14, NULL, '2026-10', '2026-10-19', '2026-11-19', 18.00, 162.50, 29.25, 191.75, 191.75, 'pagada', NULL, 'Soporte correctivo de enlace redundante FortiGate OS-2026-014', 1, '2026-10-19 17:00:00'),
(34, 'factura', 'F001', 34, 'F001-00000034', 3, 'servicio', 3, 15, NULL, '2026-10', '2026-10-20', '2026-11-20', 18.00, 180.00, 32.40, 212.40, 212.40, 'pagada', NULL, 'Instalación y cableado de punto de acceso UniFi OS-2026-015', 1, '2026-10-20 15:00:00'),
(35, 'factura', 'F001', 35, 'F001-00000035', 4, 'servicio', 4, 16, NULL, '2026-10', '2026-10-21', '2026-11-21', 18.00, 67.50, 12.15, 79.65, 79.65, 'pagada', NULL, 'Mantenimiento de impresora multifuncional HP OS-2026-016', 1, '2026-10-21 13:00:00'),
(36, 'factura', 'F001', 36, 'F001-00000036', 5, 'servicio', 5, 17, NULL, '2026-10', '2026-10-22', '2026-11-22', 18.00, 130.00, 23.40, 153.40, 153.40, 'pagada', NULL, 'Diagnóstico térmico y mantenimiento en workstation CAD OS-2026-017', 1, '2026-10-22 12:00:00'),
(37, 'factura', 'F001', 37, 'F001-00000037', 6, 'servicio', 6, 18, NULL, '2026-10', '2026-10-22', '2026-11-22', 18.00, 195.00, 35.10, 230.10, 230.10, 'pagada', NULL, 'Configuración y mantenimiento de switch Aruba CX OS-2026-018', 1, '2026-10-22 18:30:00'),
(38, 'factura', 'F001', 38, 'F001-00000038', 7, 'servicio', 7, 19, NULL, '2026-10', '2026-10-23', '2026-11-23', 18.00, 157.50, 28.35, 185.85, 185.85, 'pagada', NULL, 'Sustitución de disco SAS en servidor HPE OS-2026-019', 1, '2026-10-23 12:45:00'),
(39, 'factura', 'F001', 39, 'F001-00000039', 8, 'servicio', 8, 20, NULL, '2026-10', '2026-10-23', '2026-11-23', 18.00, 90.00, 16.20, 106.20, 106.20, 'pagada', NULL, 'Reparación de punto de venta touch Elo OS-2026-020', 1, '2026-10-23 16:45:00'),
(40, 'factura', 'F001', 40, 'F001-00000040', 9, 'servicio', 9, 21, NULL, '2026-10', '2026-10-23', '2026-11-23', 18.00, 162.50, 29.25, 191.75, 191.75, 'pagada', NULL, 'Sustitución de baterías en Smart-UPS RT 3000VA OS-2026-021', 1, '2026-10-23 20:00:00'),
(41, 'factura', 'F001', 41, 'F001-00000041', 1, 'mensualidad', 1, NULL, NULL, '2026-10', '2026-10-01', '2026-10-31', 18.00, 3813.56, 686.44, 4500.00, 4500.00, 'pagada', NULL, 'Suscripción mensual SLA Platino Octubre 2026 Clínica San Gabriel', 1, '2026-10-01 08:00:00'),
(42, 'factura', 'F001', 42, 'F001-00000042', 2, 'mensualidad', 2, NULL, NULL, '2026-10', '2026-10-01', '2026-10-31', 18.00, 2966.10, 533.90, 3500.00, 3500.00, 'pagada', NULL, 'Suscripción mensual soporte corporativo Octubre 2026 Distribuidora Andina', 1, '2026-10-01 08:05:00'),
(43, 'factura', 'F001', 43, 'F001-00000043', 3, 'mensualidad', 3, NULL, NULL, '2026-10', '2026-10-01', '2026-10-31', 18.00, 2372.88, 427.12, 2800.00, 2800.00, 'pagada', NULL, 'Suscripción mensual soporte educativo Octubre 2026 Colegio Santa Rosa', 1, '2026-10-01 08:10:00'),
(44, 'factura', 'F001', 44, 'F001-00000044', 4, 'mensualidad', 4, NULL, NULL, '2026-10', '2026-10-01', '2026-10-31', 18.00, 1525.42, 274.58, 1800.00, 1800.00, 'pagada', NULL, 'Suscripción mensual soporte Octubre 2026 Estudio Valdivia', 1, '2026-10-01 08:15:00'),
(45, 'factura', 'F001', 45, 'F001-00000045', 10, 'mensualidad', 10, NULL, NULL, '2026-10', '2026-10-24', '2026-11-24', 18.00, 4152.54, 747.46, 4900.00, 0.00, 'emitida', NULL, 'Primera mensualidad suscripción Premium Clínica Santa Elena', 1, '2026-10-24 09:00:00');

CREATE TABLE `fac_items` (
    `id` BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    `comprobante_id` BIGINT UNSIGNED NOT NULL,
    `descripcion` VARCHAR(255) NOT NULL,
    `cantidad` DECIMAL(10,2) NOT NULL DEFAULT 1.00,
    `precio_unit` DECIMAL(12,2) NOT NULL DEFAULT 0.00,
    CONSTRAINT `fk_fi_comp` FOREIGN KEY (`comprobante_id`) REFERENCES `fac_comprobantes` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

INSERT INTO `fac_items` VALUES (1,1,'Soporte TI plan Premium · 2026-07',1.00,1800.00),(2,2,'Soporte TI plan Premium · 2026-08',1.00,1800.00),(3,3,'Soporte TI plan Premium · 2026-09',1.00,1800.00),(4,4,'Soporte TI plan Business · 2026-07',1.00,950.00),(5,5,'Soporte TI plan Business · 2026-08',1.00,950.00),(6,6,'Soporte TI plan Business · 2026-09',1.00,950.00),(7,7,'Soporte TI plan Básico · 2026-07',1.00,420.00),(8,8,'Soporte TI plan Básico · 2026-08',1.00,420.00),(9,9,'Soporte TI plan Básico · 2026-09',1.00,420.00),(10,10,'Soporte TI plan Premium · 2026-07',1.00,1800.00),(11,11,'Soporte TI plan Premium · 2026-08',1.00,1800.00),(12,12,'Soporte TI plan Premium · 2026-09',1.00,1800.00),(13,13,'Soporte TI plan Business · 2026-07',1.00,950.00),(14,14,'Soporte TI plan Business · 2026-08',1.00,950.00),(15,15,'Soporte TI plan Business · 2026-09',1.00,950.00),(16,16,'Soporte TI plan Básico · 2026-07',1.00,420.00),(17,17,'Soporte TI plan Básico · 2026-08',1.00,420.00),(18,18,'Soporte TI plan Básico · 2026-09',1.00,420.00),(19,19,'Soporte TI plan Premium · 2026-07',1.00,1800.00),(20,20,'Soporte TI plan Premium · 2026-08',1.00,1800.00),(21,21,'Soporte TI plan Premium · 2026-09',1.00,1800.00),(22,22,'Soporte TI plan Business · 2026-07',1.00,950.00),(23,23,'Soporte TI plan Business · 2026-08',1.00,950.00),(24,24,'Soporte TI plan Business · 2026-09',1.00,950.00),(25,25,'Mano de obra correctiva · OS-2026-001',2.20,45.00),(26,26,'Mano de obra preventiva · OS-2026-002',2.60,45.00),(27,26,'Fuente de poder 500W',2.00,120.00),(28,27,'Mano de obra instalacion · OS-2026-003',6.40,45.00),(29,27,'Memoria RAM DDR4 8GB',1.00,95.00),(30,28,'Mano de obra diagnostico · OS-2026-004',2.30,45.00),(31,28,'Disco SSD 480GB',1.00,185.00),(32,29,'Mano de obra correctiva · OS-2026-005',6.70,45.00),(33,29,'Memoria RAM DDR4 8GB',1.00,95.00),(34,30,'Mano de obra preventiva · OS-2026-006',4.10,45.00),(35,30,'Batería laptop Dell',2.00,210.00),(36,31,'NAS 4 bahías 16 TB',1.00,7800.00),(37,31,'Instalación y configuración',1.00,1500.00),(38,31,'Backup remoto (12 meses)',1.00,2400.00),
(39, 32, 'Mantenimiento semestral de servidor Dell PowerEdge R740xd', 3.50, 65.00),
(40, 33, 'Soporte correctivo y reconfiguración SD-WAN FortiGate', 2.50, 65.00),
(41, 34, 'Instalación física y tendido de cable Cat6A para WiFi UniFi', 4.00, 45.00),
(42, 35, 'Reemplazo de kit de arrastre y calibración impresora HP', 1.50, 45.00),
(43, 36, 'Diagnóstico térmico y mantenimiento en workstation CAD', 2.00, 65.00),
(44, 37, 'Configuración y monitoreo de tráfico en switch Aruba CX', 3.00, 65.00),
(45, 38, 'Sustitución en caliente de disco SAS 600GB en servidor HPE', 3.50, 45.00),
(46, 39, 'Diagnóstico y reparación de punto de venta Elo', 2.00, 45.00),
(47, 40, 'Reemplazo de baterías internas y calibración de UPS APC', 2.50, 65.00),
(48, 41, 'Servicio Mensual de Soporte TI y Mesa de Ayuda Nivel Platino', 1.00, 3813.56),
(49, 42, 'Servicio Mensual de Soporte TI Empresarial Nivel Business', 1.00, 2966.10),
(50, 43, 'Servicio Mensual de Soporte a Infraestructura Educativa', 1.00, 2372.88),
(51, 44, 'Servicio Mensual de Soporte TI Nivel Básico', 1.00, 1525.42),
(52, 45, 'Servicio Mensual de Soporte Hospitalario Alta Disponibilidad', 1.00, 4152.54);

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

INSERT INTO `fac_pagos` VALUES (1,1,'2026-07-16',2124.00,'transferencia','OP-4001',NULL,1,'2026-10-05 18:30:45'),(2,4,'2026-07-16',1121.00,'efectivo','OP-4004',NULL,1,'2026-10-05 18:30:45'),(3,5,'2026-08-16',1121.00,'plin','OP-4005',NULL,1,'2026-10-05 18:30:45'),(4,6,'2026-09-16',560.50,'transferencia','OP-4006',NULL,1,'2026-10-05 18:30:45'),(5,7,'2026-07-16',495.60,'transferencia','OP-4007',NULL,1,'2026-10-05 18:30:45'),(6,8,'2026-08-16',495.60,'yape','OP-4008',NULL,1,'2026-10-05 18:30:45'),(7,9,'2026-09-16',495.60,'deposito','OP-4009',NULL,1,'2026-10-05 18:30:45'),(8,10,'2026-07-16',2124.00,'efectivo','OP-4010',NULL,1,'2026-10-05 18:30:45'),(9,11,'2026-08-16',2124.00,'plin','OP-4011',NULL,1,'2026-10-05 18:30:45'),(10,13,'2026-07-16',1121.00,'transferencia','OP-4013',NULL,1,'2026-10-05 18:30:45'),(11,15,'2026-09-16',560.50,'deposito','OP-4015',NULL,1,'2026-10-05 18:30:45'),(12,16,'2026-07-16',495.60,'efectivo','OP-4016',NULL,1,'2026-10-05 18:30:45'),(13,17,'2026-08-16',495.60,'plin','OP-4017',NULL,1,'2026-10-05 18:30:45'),(14,18,'2026-09-16',495.60,'transferencia','OP-4018',NULL,1,'2026-10-05 18:30:45'),(15,19,'2026-07-16',2124.00,'transferencia','OP-4019',NULL,1,'2026-10-05 18:30:45'),(16,20,'2026-08-16',2124.00,'yape','OP-4020',NULL,1,'2026-10-05 18:30:45'),(17,22,'2026-07-16',1121.00,'efectivo','OP-4022',NULL,1,'2026-10-05 18:30:45'),(18,23,'2026-08-16',1121.00,'plin','OP-4023',NULL,1,'2026-10-05 18:30:45'),(19,24,'2026-09-16',560.50,'transferencia','OP-4024',NULL,1,'2026-10-05 18:30:45'),(20,26,'2026-09-27',421.26,'yape','OP-4026',NULL,1,'2026-10-05 18:30:45'),(21,28,'2026-08-09',340.43,'efectivo','OP-4028',NULL,1,'2026-10-05 18:30:45'),(22,30,'2026-08-29',713.31,'transferencia','OP-4030',NULL,1,'2026-10-05 18:30:45'),(23,31,'2026-10-11',13806.00,'transferencia','PAGO-APP-001',NULL,NULL,'2026-10-11 23:33:02'),
(24, 32, '2026-10-18', 268.45, 'transferencia', 'BCP-9884102-OP', 'Pago confirmado por tesorería Clínica San Gabriel', 1, '2026-10-18 14:00:00'),
(25, 33, '2026-10-19', 191.75, 'transferencia', 'BBVA-4410291-OP', 'Transferencia interbancaria Distribuidora Andina', 1, '2026-10-19 17:30:00'),
(26, 34, '2026-10-20', 212.40, 'deposito', 'BCP-AG-552194', 'Depósito en agente BCP Colegio Santa Rosa', 1, '2026-10-20 16:00:00'),
(27, 35, '2026-10-21', 79.65, 'yape', 'YAPE-881294', 'Abono digital inmediato Estudio Valdivia', 1, '2026-10-21 13:30:00'),
(28, 36, '2026-10-22', 153.40, 'transferencia', 'INTERBANK-110294', 'Pago neto de detracción Constructora Pacífico', 1, '2026-10-22 13:00:00'),
(29, 37, '2026-10-22', 230.10, 'tarjeta', 'VISA-POS-9941', 'Pago con tarjeta empresarial Hotel Mirador del Sol', 1, '2026-10-22 19:00:00'),
(30, 38, '2026-10-23', 185.85, 'transferencia', 'BCP-7749102-OP', 'Pago por reparación Transportes Inca Express', 1, '2026-10-23 13:30:00'),
(31, 39, '2026-10-23', 106.20, 'transferencia', 'BBVA-338192-OP', 'Pago de servicios Farmacias Vida Plus', 1, '2026-10-23 17:30:00'),
(32, 40, '2026-10-23', 191.75, 'transferencia', 'BCP-992140-OP', 'Transferencia bancaria Empresa Automatizada SAC', 1, '2026-10-23 20:30:00'),
(33, 41, '2026-10-05', 4500.00, 'transferencia', 'BCP-CORP-440192', 'Mensualidad Octubre 2026 conciliada con extracto bancario', 1, '2026-10-05 10:00:00'),
(34, 42, '2026-10-05', 3500.00, 'transferencia', 'BBVA-CORP-552194', 'Mensualidad Octubre 2026 conciliada con tesorería', 1, '2026-10-05 10:30:00'),
(35, 43, '2026-10-06', 2800.00, 'transferencia', 'INTERBANK-881920', 'Abono programado de soporte institucional mensual', 1, '2026-10-06 11:00:00'),
(36, 44, '2026-10-06', 1800.00, 'transferencia', 'BCP-8812941-OP', 'Pago por soporte mensual Estudio Valdivia', 1, '2026-10-06 11:30:00');

CREATE TABLE `fac_secuencias` (
    `serie` VARCHAR(6) PRIMARY KEY,
    `ultimo_numero` INT UNSIGNED NOT NULL DEFAULT 0,
    `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

INSERT INTO `fac_secuencias` (`serie`, `ultimo_numero`) VALUES 
('F001', 45), 
('B001', 10)
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
-- 7. BASE DE DATOS: db_notification (Envíos, Plantillas y Registro Asíncrono)
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
(1, 'correo', 'ti@cliente1.pe', 'Ticket Creado: TCK-0001 Enlace de red intermitente', 'Estimado cliente, su ticket ha sido registrado en NexusDesk Pro Cloud y asignado a nuestro equipo técnico.', 'enviado', NULL, 1, 1, NULL, '2026-10-06 09:05:00', NULL),
(2, 'whatsapp', '+51987654321', 'Notificación de Soporte: OS-0001 Programada', 'Se ha programado una visita técnica para el 08/10/2026 a las 10:00 AM con el especialista Brayan Hurtado.', 'enviado', NULL, 1, 1, NULL, '2026-10-06 10:00:00', 1),
(3, 'correo', 'ti@cliente2.pe', 'Cotización Emitida: COT-0002 Migración Cloud Híbrida', 'Adjuntamos propuesta comercial para la renovación y migración de su centro de cómputo.', 'enviado', NULL, 2, NULL, 2, '2026-10-07 14:30:00', NULL),
(4, 'correo', 'ti@cliente3.pe', 'Comprobante Electrónico F001-00000001', 'Su factura del periodo 2026-10 se encuentra disponible para descarga en el portal.', 'enviado', NULL, 3, NULL, NULL, '2026-10-08 08:00:00', NULL),
(5, 'correo', 'ti@cliente1.pe', 'Ticket Resuelto: TCK-0001 Enlace de red intermitente', 'El ticket ha sido marcado como RESUELTO tras confirmar estabilidad de la conexión.', 'enviado', NULL, 1, 1, NULL, '2026-10-08 17:00:00', NULL),
(6, 'whatsapp', '+51999222333', 'Alerta SLA: Ticket por vencer', 'Alerta interna para supervisión: Ticket TCK-0005 requiere seguimiento prioritario.', 'simulado', NULL, 2, 5, NULL, '2026-10-09 11:15:00', NULL),
(7, 'correo', 'contacto@automatizado.pe', 'Bienvenida a NexusDesk Pro Cloud', 'Su cuenta de acceso al portal de autoservicio ha sido activada correctamente.', 'enviado', NULL, 9, NULL, NULL, '2026-10-10 16:00:00', NULL),
(8, 'correo', 'mbenavides@cliente1.pe', 'Visita Técnica Programada OS-2026-013', 'Confirmamos visita para mantenimiento preventivo de servidor Dell R740xd el 18/10/2026 a las 09:00.', 'enviado', NULL, 1, 13, NULL, '2026-10-17 16:30:00', 13),
(9, 'whatsapp', '+51999888101', 'Confirmación de Arribo de Técnico', 'El especialista Brayan Hurtado ha ingresado a la sede San Isidro para atención de OS-2026-013.', 'enviado', NULL, 1, 13, NULL, '2026-10-18 09:10:00', 13),
(10, 'correo', 'cvargas@cliente2.pe', 'Incidencia Crítica Resuelta TCK-0014', 'Se ha restablecido el túnel IPsec secundario del firewall FortiGate con conmutación en menos de 200ms.', 'enviado', NULL, 2, 14, NULL, '2026-10-19 16:45:00', 14),
(11, 'correo', 'eguzman@cliente3.pe', 'Instalación Completada OS-2026-015', 'Punto de acceso WiFi 6E configurado y operando en pabellón de aulas con 120 Mbps de rendimiento.', 'enviado', NULL, 3, 15, NULL, '2026-10-20 14:20:00', 15),
(12, 'correo', 'msolano@cliente4.pe', 'Mantenimiento de Impresora Concluido', 'La impresora HP LaserJet M608dn ha sido reparada con rodillos de arrastre nuevos.', 'enviado', NULL, 4, 16, NULL, '2026-10-21 12:40:00', 16),
(13, 'whatsapp', '+51999888104', 'Conformidad de Servicio Registrada', 'Gracias por firmar digitalmente la orden OS-2026-016 en la aplicación móvil de NexusDesk.', 'enviado', NULL, 4, 16, NULL, '2026-10-21 12:45:00', 16),
(14, 'correo', 'fdelgado@cliente5.pe', 'Optimización Térmica Finalizada OS-2026-017', 'La workstation CAD Lenovo P16s opera ahora a 74C bajo renderizado continuo en Revit.', 'enviado', NULL, 5, 17, NULL, '2026-10-22 11:45:00', 17),
(15, 'correo', 'rcarrion@cliente6.pe', 'Reporte de Tráfico y Switch de Piso OS-2026-018', 'Switch Aruba CX 6100 actualizado con firmware v10.12 y distribución de PoE equilibrada.', 'enviado', NULL, 6, 18, NULL, '2026-10-22 18:20:00', 18),
(16, 'whatsapp', '+51999888107', 'Alerta de Disco Degraded Resuelta OS-2026-019', 'El disco SAS defectuoso en el servidor HPE fue reemplazado y el arreglo RAID 5 ha sido reconstruido.', 'enviado', NULL, 7, 19, NULL, '2026-10-23 12:20:00', 19),
(17, 'correo', 'jbustamante@cliente8.pe', 'Punto de Venta Operativo OS-2026-020', 'Terminal Elo Touch cuenta con nueva fuente de alimentación de 750W y estabilizador.', 'enviado', NULL, 8, 20, NULL, '2026-10-23 16:25:00', 20),
(18, 'correo', 'ralva@automatizado.pe', 'Autonomía de Smart-UPS Verificada OS-2026-021', 'Baterías reemplazadas. Tiempo de respaldo calculado ante corte de energía: 48 minutos.', 'enviado', NULL, 9, 21, NULL, '2026-10-23 19:55:00', 21),
(19, 'correo', 'gponce@santaelena.pe', 'Factura Electrónica Emitida F001-00000045', 'Estimado cliente, su comprobante por S/ 4,900.00 correspondiente a suscripción mensual ha sido emitido.', 'enviado', NULL, 10, NULL, 11, '2026-10-24 09:05:00', NULL),
(20, 'whatsapp', '+51999333444', 'Asignación de Visita Técnica para Hoy', 'Especialista Brayan Hurtado: Se ha asignado visita de relevamiento técnico en Clínica Santa Elena para las 15:00 hrs.', 'enviado', NULL, 10, 22, NULL, '2026-10-24 09:15:00', 22);

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
-- FIN DEL SCRIPT MAESTRO MEGA-ENRIQUECIDO DE NEXUSDESK PRO CLOUD
-- ============================================================================
