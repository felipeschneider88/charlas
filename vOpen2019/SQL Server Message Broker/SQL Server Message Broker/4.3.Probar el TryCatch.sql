-- Cambiamos a nuestra base de datos
USE HolaMundo;
GO

-- Comenzar una conversacicion enviando un mensaje
DECLARE @conversation_handle UNIQUEIDENTIFIER;
DECLARE @message_body XML;

BEGIN TRANSACTION;

BEGIN DIALOG @conversation_handle
     FROM SERVICE [HolaMundo_InitiatorService]
     TO SERVICE N'HolaMundo_DestinoService'
     ON CONTRACT [HolaMundoContrato]
     WITH ENCRYPTION = OFF;

SELECT @message_body = N'
<HolaMundoMensaje>
	<Numerador>10</Numerador>
	<Denominador>10</Denominador>
</HolaMundoMensaje>';

SEND ON CONVERSATION @conversation_handle
     MESSAGE TYPE [HolaMundoMensaje]
     (@message_body);

COMMIT TRANSACTION;
GO

-- Check that the messages processed
SELECT * FROM [dbo].[MensajesProcesados];
GO




-- Generar un mensaje probelmantico
DECLARE @conversation_handle UNIQUEIDENTIFIER;
DECLARE @message_body XML;

BEGIN TRANSACTION;

BEGIN DIALOG @conversation_handle
     FROM SERVICE [HolaMundo_InitiatorService]
     TO SERVICE N'HolaMundo_DestinoService'
     ON CONTRACT [HolaMundoContrato]
     WITH ENCRYPTION = OFF;

SELECT @message_body = N'
<HolaMundoMensaje>
	<Numerador>10</Numerador>
	<Denominador>0</Denominador>
</HolaMundoMensaje>';

SEND ON CONVERSATION @conversation_handle
     MESSAGE TYPE [HolaMundoMensaje]
     (@message_body);


COMMIT TRANSACTION;
GO

-- Comprobar que el mensaje no fue proecsado
SELECT * FROM [dbo].[MensajesProcesados];
GO


-- Comenzar una conversacicion enviando un mensaje
DECLARE @conversation_handle UNIQUEIDENTIFIER;
DECLARE @message_body XML;

BEGIN TRANSACTION;

BEGIN DIALOG @conversation_handle
     FROM SERVICE [HolaMundo_InitiatorService]
     TO SERVICE N'HolaMundo_DestinoService'
     ON CONTRACT [HolaMundoContrato]
     WITH ENCRYPTION = OFF;

SELECT @message_body = N'
<HolaMundoMensaje>
	<Numerador>10</Numerador>
	<Denominador>10</Denominador>
</HolaMundoMensaje>';

SEND ON CONVERSATION @conversation_handle
     MESSAGE TYPE [HolaMundoMensaje]
     (@message_body);

COMMIT TRANSACTION;
GO

-- Comprobar los mensajes procesados
SELECT * FROM [dbo].[MensajesProcesados];
GO


-- Ver los mensajes en la queue destino
SELECT *, 
	CAST(message_body AS XML) AS message_body_xml
FROM HolaMundo_DestinoQueue;
GO

-- Comprobar el estado de la queue
SELECT is_receive_enabled, is_enqueue_enabled, is_activation_enabled 
FROM sys.service_queues
WHERE name = N'HolaMundo_DestinoQueue';

-- Comorobar la transmission queue
SELECT * 
FROM sys.transmission_queue;


-- Modificar la queue destino para deshabilitar la activacion automatica
ALTER QUEUE HolaMundo_DestinoQueue
    WITH ACTIVATION
    ( STATUS = OFF);
GO

-- Ejecutar manualmente el SP
EXECUTE dbo.DestinoQueue_ActivationProcedure;
GO

-- Modificar la queue destino para habilitarla
ALTER QUEUE HolaMundo_DestinoQueue
    WITH STATUS = ON;
GO

-- Comprobar el estado de la queue
SELECT is_receive_enabled, is_enqueue_enabled, is_activation_enabled 
FROM sys.service_queues
WHERE name = N'HolaMundo_DestinoQueue';

-- Ver los mensajes en la queue destino
SELECT *, 
	CAST(message_body AS XML) AS message_body_xml
FROM HolaMundo_DestinoQueue;
GO

-- Comprobar la transmission queue
SELECT * 
FROM sys.transmission_queue;

-- Ejecutar manualmente el SP
EXECUTE dbo.DestinoQueue_ActivationProcedure;
GO


