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

-- Crear la queue de origen y su servicio
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

--Tabla para auditorias
CREATE TABLE dbo.MensajesProcesados
(	RowID INT IDENTITY PRIMARY KEY,
	Nombre VARCHAR(128) NOT NULL,
	Cuerpo VARCHAR(MAX) NULL,
	Fecha DATETIME DEFAULT (CURRENT_TIMESTAMP))
	

--Tabla de Articulos
CREATE TABLE [dbo].[Articulos](
	[idArt] [int] NOT NULL,
	[Nombre] [varchar](100) NULL,
	[PrecioCompra] [numeric](14, 2) NULL,
	[PrecioVenta] [numeric](14, 2) NULL,
	[Stock] [int] NULL,
	CONSTRAINT  [PK_Articulos] PRIMARY KEY CLUSTERED ([idArt]),
) ON [PRIMARY]
GO

--Cargamos algunos articulos
INSERT INTO [dbo].[Articulos] VALUES(1,'MP3 MOD. AX100',1200,1500,300)
INSERT INTO [dbo].[Articulos] VALUES(2,'MICROCOMPONENTES AIGUA 4000',5100,6300,300)
INSERT INTO [dbo].[Articulos] VALUES (3,'TV LCD 22' ,7000,85000,50)
INSERT INTO [dbo].[Articulos] VALUES (4,'TV LCD 32' ,10000,13000,50)
INSERT INTO [dbo].[Articulos] VALUES (5,'TV LCD 40' ,12000,16000,100)
GO

--Vemos los articulos ingresados
select * from dbo.Articulos



