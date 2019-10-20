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




-- Cambiar a la base de datos
USE HolaMundo;
GO

IF OBJECT_ID('DestinoQueue_ActivationProcedure') IS NOT NULL
BEGIN
	DROP PROCEDURE DestinoQueue_ActivationProcedure;
END
GO

CREATE PROCEDURE DestinoQueue_ActivationProcedure
AS
  DECLARE @conversation_handle UNIQUEIDENTIFIER;
  DECLARE @message_body XML;
  DECLARE @message_type_name sysname;
  --Ya se, no es la forma mas feliz de hacer un loop, 
  --pero de esta forma procesamos todos los mensajes en la Queue y mejoramos la performace y solo cuando no haya más,
  --espera 5000ms y se cierra
  WHILE (1=1)
  BEGIN
    BEGIN TRANSACTION;
    WAITFOR
    ( RECEIVE TOP(1)
        @conversation_handle = conversation_handle,
        @message_body = message_body,
        @message_type_name = message_type_name
      FROM HolaMundo_DestinoQueue
    ), TIMEOUT 5000;
    IF (@@ROWCOUNT = 0)
    BEGIN
      ROLLBACK TRANSACTION;
      BREAK;
    END
	--Procemos mi mensaje particular
    IF @message_type_name = N'HolaMundoMensaje'
    BEGIN
		--Agregamos la info en la auditoria
	   INSERT INTO dbo.MensajesProcesados (Nombre, Cuerpo) 
	   VALUES ('DestinoQueue_ActivationProcedure', CAST(@message_body AS VARCHAR(MAX)));
	   
	   -- Obtener los datos de la venta para actualziar el stock
		DECLARE @idArt INT = @message_body.value('(HolaMundoMensaje/idArt)[1]', 'int');
		DECLARE @Vendidos INT = @message_body.value('(HolaMundoMensaje/Vendidos)[1]', 'int');
	--Hacemos la actualizacion del stock, positivos son equipos vendidos, negativos son equipos devueltos (anuliaciones)
		update Articulos
			set Stock = Stock - @Vendidos
			where idArt = @idArt
		--Acá habria que validar que si el articulo no existe, enviar mensaje de error para validar
		DECLARE @artNombre varchar(100)
		select @artNombre= Nombre from articulos where idArt = @idArt
		DECLARE @reply_message_body XML = N'<HolaMundoReply>El stock de '+
							ISNULL(@artNombre, 'NULL')+' fue actualizado!</HolaMundoReply>';

       SEND ON CONVERSATION @conversation_handle
              MESSAGE TYPE [HolaMundoReply] (@reply_message_body);
    END
	-- Si llega un mensaje de fin de dialog, cierro de forma correcta el mismo
    ELSE IF @message_type_name = N'http://schemas.microsoft.com/SQL/ServiceBroker/EndDialog'
    BEGIN
       END CONVERSATION @conversation_handle;
    END
	-- Si hay error, los guardo y cierro la convesacion
    ELSE IF @message_type_name = N'http://schemas.microsoft.com/SQL/ServiceBroker/Error'
    BEGIN
		DECLARE @error INT;
		DECLARE @description NVARCHAR(4000);
		-- Obtener el error y su codigo del XML
		WITH XMLNAMESPACES ('http://schemas.microsoft.com/SQL/ServiceBroker/Error' AS ssb)
		SELECT
			@error = @message_body.value('(//ssb:Error/ssb:Code)[1]', 'INT'),
			@description = @message_body.value('(//ssb:Error/ssb:Description)[1]', 'NVARCHAR(4000)');
		
		RAISERROR(N'Received error Code:%i Description:"%s"', 16, 1, @error, @description) WITH LOG;
		-- Una vez manejado el error, limpiamos la convesacion
		END CONVERSATION @conversation_handle;
	END
      
    COMMIT TRANSACTION;
  END
GO
-- Siempre prueba tus SP antes de entrar en produccion

-- Cambiar a la base de datos
USE HolaMundo;
GO

IF OBJECT_ID('InitiatorQueue_ActivationProcedure') IS NOT NULL
BEGIN
	DROP PROCEDURE InitiatorQueue_ActivationProcedure;
END
GO

CREATE PROCEDURE InitiatorQueue_ActivationProcedure
AS

  DECLARE @conversation_handle UNIQUEIDENTIFIER;
  DECLARE @message_body XML;
  DECLARE @message_type_name SYSNAME;
  --Ya se, no es la forma mas feliz de hacer un loop, 
  --pero de esta forma procesamos todos los mensajes en la Queue y mejoramos la performace y solo cuando no haya más,
  --espera 5000ms y se cierra
  WHILE (1=1)
  BEGIN

    BEGIN TRANSACTION;

    WAITFOR
    ( RECEIVE TOP(1)
        @conversation_handle = conversation_handle,
        @message_body = message_body,
        @message_type_name = message_type_name
      FROM HolaMundo_InitiatorQueue
    ), TIMEOUT 5000;

    IF (@@ROWCOUNT = 0)
    BEGIN
      ROLLBACK TRANSACTION;
      BREAK;
    END

	--Procemos mi mensaje particular
    IF @message_type_name = N'HolaMundoReply'
    BEGIN

	   INSERT INTO dbo.MensajesProcesados (Nombre, Cuerpo) 
	   VALUES ('InitiatorQueue_ActivationProcedure', CAST(@message_body AS VARCHAR(MAX)));

       END CONVERSATION @conversation_handle;
    END

	-- Si llega un mensaje de fin de dialog, cierro de forma correcta el mismo
    ELSE IF @message_type_name = N'http://schemas.microsoft.com/SQL/ServiceBroker/EndDialog'
    BEGIN
       END CONVERSATION @conversation_handle;
    END

	-- Si hay error, los guardo y cierro la convesacion
    ELSE IF @message_type_name = N'http://schemas.microsoft.com/SQL/ServiceBroker/Error'
    BEGIN
		DECLARE @error INT;
		DECLARE @description NVARCHAR(4000);

		-- Obtener el error y su codigo del XML
		WITH XMLNAMESPACES ('http://schemas.microsoft.com/SQL/ServiceBroker/Error' AS ssb)
		SELECT
			@error = @message_body.value('(//ssb:Error/ssb:Code)[1]', 'INT'),
			@description = @message_body.value('(//ssb:Error/ssb:Description)[1]', 'NVARCHAR(4000)');
		
		RAISERROR(N'Error recibido, Codigo:%i Descripcion:"%s"', 16, 1, @error, @description) WITH LOG;
		-- Una vez manejado el error, limpiamos la convesacion
		END CONVERSATION @conversation_handle;
	END
      
    COMMIT TRANSACTION;

  END
GO
-- Siempre prueba tus SP antes de entrar en produccion


-- Cambiar a la base de datos
USE HolaMundo;
GO

-- Modificar la queue destino para especificar la activacion interna
ALTER QUEUE HolaMundo_DestinoQueue
    WITH ACTIVATION
    ( STATUS = ON,
      PROCEDURE_NAME = DestinoQueue_ActivationProcedure,
      MAX_QUEUE_READERS = 10,
      EXECUTE AS SELF
    );
GO

-- Modificar la queue origen para especificar la activacion interna
ALTER QUEUE HolaMundo_InitiatorQueue
    WITH ACTIVATION
    ( STATUS = ON,
      PROCEDURE_NAME = InitiatorQueue_ActivationProcedure,
      MAX_QUEUE_READERS = 10,
      EXECUTE AS SELF
    );
GO