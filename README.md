# NexusDesk Database — Clúster de Datos Multi-Esquema 2026

Repositorio oficial del módulo de persistencia y base de datos para **NexusDesk Pro Cloud** (Evaluación Académica CIBERTEC - DAW II, Ciclo 2026-I).

## Integrantes del Proyecto
- **Chaupis Alvarez, Jhonny Samuel** (`admin` / `jchaupis`): Coordinador General TI / Arquitecto Cloud (Administrador)
- **Hinojosa Cano, Carlos Daniel** (`chinojosa`): Frontend Lead & Supervisor de Clientes (Supervisor)
- **Hurtado Sernaque, Brayan Luis** (`bhurtado`): Backend Lead · Helpdesk & Operaciones (Técnico)
- **Alayo Oliveros, Mathias Miller** (`malayo`): Backend & DevOps · CRM & Facturación (Comercial)

---

## Archivos de Base de Datos Disponibles
1. **`init-databases.sql`**: Script DDL de inicialización multi-esquema con datos mega-enriquecidos listos para el encendido automático del contenedor Docker MySQL (`/docker-entrypoint-initdb.d/`).
2. **`nexusdesk-enriquecida.sql`**: Backup enriquecido de producción para demostración completa en vivo, sustentación docente y pruebas con datos reales en todos los módulos.

---

## Estructura de Micro-Bases de Datos (7 Esquemas Aislados)

| Base de Datos | Microservicio | Entidades Principales | Registros de Producción Verificados |
|---|---|---|---|
| `db_auth` | Auth Service (:8081) | `roles`, `usuarios`, `company_config`, `sys_backups`, `actividad` | 8 usuarios, 8 backups SHA-256, 33 auditorías, configuración corporativa JSON |
| `db_customer` | Customer Service (:8082) | `clientes`, `contratos`, `activos`, `crm_contactos`, `categorias` | 10 clientes, 12 contratos de servicio, 60 activos TI, 26 contactos, 8 categorías |
| `db_helpdesk` | Helpdesk Service (:8083) | `tickets`, `ticket_comentarios`, `kb_articulos`, `cached_tecnicos` | 241 tickets SLA, 16 artículos KB técnicos completos en Markdown, 40 comentarios cruzados |
| `db_operations` | Operations Service (:8084) | `ordenes_servicio`, `repuestos`, `visitas`, `ordenes_repuestos` | 28 órdenes de servicio, 25 repuestos de inventario, 24 visitas técnicas, 18 repuestos por orden |
| `db_crm` | CRM Service (:8085) | `crm_etapas`, `crm_leads`, `crm_oportunidades`, `crm_cotizaciones`, `crm_actividades` | 21 leads comerciales, 27 oportunidades pipeline, 11 cotizaciones con 22 líneas, 36 actividades |
| `db_billing` | Billing Service (:8086) | `fac_comprobantes`, `fac_items`, `fac_pagos`, `fac_secuencias` | 45 facturas/boletas electrónicas, 52 ítems detallados, 36 pagos bancarios conciliados |
| `db_notification` | Notification Service (:8087) | `notif_envios`, `consumed_messages` | 20 registros de logs de mensajería (Email / WhatsApp) |

---

## Credenciales y Acceso
- **Host Local Docker:** `localhost:3307` (Mapeado a puerto interno `3306` dentro del contenedor)
- **Usuario Root MySQL:** `root`
- **Contraseña Root:** `root`
- **Contraseña Universal de Usuarios:** `Admin123*`

### Cuentas de Acceso según Roles:
- **Administrador:** `admin@nexusdesk.pe` / `Admin123*` (Jhonny Samuel Chaupis Alvarez)
- **Supervisor:** `chinojosa@nexusdesk.pe` / `Admin123*` (Carlos Daniel Hinojosa Cano)
- **Técnico:** `bhurtado@nexusdesk.pe` / `Admin123*` (Brayan Luis Hurtado Sernaque)
- **Comercial:** `malayo@nexusdesk.pe` / `Admin123*` (Mathias Miller Alayo Oliveros)
- **Recepción:** `recepcion@nexusdesk.pe` / `Admin123*` (Mesa de Partes / Atención Presencial)
- **Cliente:** `portal.demo@cliente.pe` / `Admin123*` (Acceso Portal Clientes / BCP)
