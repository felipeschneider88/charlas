-- Enable Service Broker and switch to the database
USE master;
GO
IF DB_ID('HolaMundo') IS NOT NULL
BEGIN
	ALTER DATABASE HolaMundo SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
	DROP DATABASE HolaMundo;
END
GO
CREATE DATABASE HolaMundo;
GO
ALTER DATABASE HolaMundo
      SET ENABLE_BROKER;
GO
USE HolaMundo;
GO
-- Crear los mensajes
CREATE MESSAGE TYPE
       [HolaMundoMensaje]
       VALIDATION = WELL_FORMED_XML;
CREATE MESSAGE TYPE
       [HolaMundoReply]
       VALIDATION = WELL_FORMED_XML;
GO

-- Ver los mensajes que creamos
SELECT * 
FROM sys.service_message_types
WHERE message_type_id > 65535;
GO

-- Ver los mensajes de sistem
SELECT * 
FROM sys.service_message_types
WHERE message_type_id <= 65535;
GO

-- Crear el contrato
CREATE CONTRACT [HolaMundoContrato]
      ([HolaMundoMensaje]
       SENT BY INITIATOR,
       [HolaMundoReply]
       SENT BY TARGET
      );
GO

-- Ver el contrato que creamos
SELECT *
FROM sys.service_contracts
WHERE service_contract_id > 65535;
GO

-- Ver los contratos del sistema
SELECT *
FROM sys.service_contracts
WHERE service_contract_id <= 65535;
GO

-- Crear la queue de destino y su servicio
CREATE QUEUE HolaMundo_DestinoQueue;
GO

-- Comprobar nuestras queue
SELECT * 
FROM sys.service_queues
WHERE is_ms_shipped = 0;
GO

-- Ver las queue del sistema
SELECT * 
FROM sys.service_queues
WHERE is_ms_shipped = 1;
GO

CREATE SERVICE
       [HolaMundo_DestinoService]
       ON QUEUE HolaMundo_DestinoQueue
       ([HolaMundoContrato]);
GO

-- Ver nustros servicios
SELECT *
FROM sys.services
WHERE service_id > 65535;
GO

-- Mostrar los servicios del sistema
SELECT *
FROM sys.services
WHERE service_id <= 65535;
GO

-- Create the initiator queue and service
CREATE QUEUE HolaMundo_InitiatorQueue;
GO

-- Comprobar nuestras queue
SELECT * 
FROM sys.service_queues
WHERE is_ms_shipped = 0;
GO

CREATE SERVICE
       [HolaMundo_InitiatorService]
       ON QUEUE HolaMundo_InitiatorQueue;
GO

-- Comprobar nuestros servicios
SELECT *
FROM sys.services
WHERE service_id > 65535;
GO