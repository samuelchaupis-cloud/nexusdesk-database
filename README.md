# NexusDesk Database — Clúster de Datos Multi-Esquema 2026

Repositorio oficial del módulo de persistencia y base de datos para **NexusDesk Pro Cloud** (Evaluación Académica CIBERTEC - DAW II, Ciclo 2026-I).

## Integrantes del Proyecto
- **Chaupis Alvarez, Jhonny Samuel** (`admin` / `jchaupis`): Coordinador General TI / Arquitecto Cloud (Administrador)
- **Hinojosa Cano, Carlos Daniel** (`chinojosa`): Frontend Lead & Supervisor de Clientes (Supervisor)
- **Hurtado Sernaque, Brayan Luis** (`bhurtado`): Backend Lead · Helpdesk & Operaciones (Técnico)
- **Alayo Oliveros, Mathias Miller** (`malayo`): Backend & DevOps · CRM & Facturación (Comercial)

---

## Archivos de Base de Datos Disponibles
1. **`init-databases.sql`**: Script DDL de inicialización multi-esquema con datos enriquecidos canónicos listos para el encendido del contenedor Docker MySQL (`/docker-entrypoint-initdb.d/`).
2. **`nexusdesk-enriquecida.sql`**: Backup enriquecido completo para restauración o demostración en vivo con volumen poblado de producción.

---

## Estructura de Micro-Bases de Datos (7 Esquemas Aislados)

| Base de Datos | Microservicio | Entidades Principales | Registros de Producción |
|---|---|---|---|
| `db_auth` | Auth Service (:8081) | `roles`, `usuarios`, `company_config`, `sys_backups`, `actividad` | 8 usuarios, 4 backups, 11 logs |
| `db_customer` | Customer Service (:8082) | `clientes`, `contratos`, `activos`, `crm_contactos`, `categorias` | 10 clientes, 7 contratos, 47 activos |
| `db_helpdesk` | Helpdesk Service (:8083) | `tickets`, `ticket_comentarios`, `kb_articulos`, `cached_tecnicos` | 241 tickets, 4 artículos KB, 5 comentarios |
| `db_operations` | Operations Service (:8084) | `ordenes_servicio`, `repuestos`, `visitas`, `ordenes_repuestos` | 12 órdenes, 10 repuestos, 8 visitas |
| `db_crm` | CRM Service (:8085) | `crm_etapas`, `crm_leads`, `crm_oportunidades`, `crm_cotizaciones` | 8 leads, 14 oportunidades, 4 cotizaciones |
| `db_billing` | Billing Service (:8086) | `fac_comprobantes`, `fac_items`, `fac_pagos`, `fac_secuencias` | 31 facturas/boletas, 38 items, 23 pagos |
| `db_notification` | Notification Service (:8087) | `notif_envios`, `consumed_messages` | 7 envíos registrados |

---

## Credenciales y Acceso
- **Host Local:** `localhost:3307` (Mapeado a `3306` dentro del contenedor)
- **Usuario Root:** `root`
- **Contraseña:** `root`
- **Contraseña de Usuarios de Aplicación:** `Admin123*`
