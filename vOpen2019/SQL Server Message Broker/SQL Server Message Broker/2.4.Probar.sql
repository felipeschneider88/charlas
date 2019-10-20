-- Cambiar a la base de datos
USE HolaMundo;
GO


-- Comenzar una conversacion y enviar un mensaje 
DECLARE @conversation_handle UNIQUEIDENTIFIER;
DECLARE @message_body XML;

BEGIN TRANSACTION;

BEGIN DIALOG @conversation_handle
     FROM SERVICE [HolaMundo_InitiatorService]
     TO SERVICE N'HolaMundo_DestinoService'
     ON CONTRACT [HolaMundoContrato]
     WITH ENCRYPTION = OFF;

SELECT @message_body = N'<HolaMundoMensaje>Hola Mundo!</HolaMundoMensaje>';

SEND ON CONVERSATION @conversation_handle
     MESSAGE TYPE [HolaMundoMensaje]
     (@message_body);

SELECT @message_body AS SentMsg;

COMMIT TRANSACTION;
GO

-- Vemos la conversacion que recien creamos
SELECT *
FROM sys.conversation_groups;
GO

-- Vemos el mensaje en la cola de destino
SELECT *, 
	CAST(message_body AS XML) AS message_body_xml
FROM HolaMundo_DestinoQueue;
GO

-- Probamos el SP de activacion
EXECUTE dbo.DestinoQueue_ActivationProcedure;
GO


-- Comprobamos que el mensaje ya no esta queue de destino
SELECT *, 
	CAST(message_body AS XML) AS message_body_xml
FROM HolaMundo_DestinoQueue;
GO

-- Comprobamos que la respuesta está en la queue de Origen
SELECT *, 
	CAST(message_body AS XML) AS message_body_xml
FROM HolaMundo_InitiatorQueue;
GO

SELECT * FROM [dbo].[MensajesProcesados];
GO

-- Test the activation Procedure
EXECUTE dbo.InitiatorQueue_ActivationProcedure;
GO

-- Comprobamos que el llego el mensaje de cerrar conversacion en la queue de destino
SELECT *, 
	CAST(message_body AS XML) AS message_body_xml
FROM HolaMundo_DestinoQueue;
GO

-- Comprobamos que el mensaje ya no está en la queue de Origen
SELECT *, 
	CAST(message_body AS XML) AS message_body_xml
FROM HolaMundo_InitiatorQueue;
GO

SELECT * FROM [dbo].[MensajesProcesados];
GO

-- Test activation Procedure, para cerrar el dialogo
EXECUTE dbo.DestinoQueue_ActivationProcedure;
GO


-- Vemos que ya no hay mensajes en la queue de destino
SELECT *, 
	CAST(message_body AS XML) AS message_body_xml
FROM HolaMundo_DestinoQueue;
GO

-- Vemos que tampoco quedaron mensajes sin procesar en la queue de origen
SELECT *, 
	CAST(message_body AS XML) AS message_body_xml
FROM HolaMundo_InitiatorQueue;
GO

SELECT * FROM [dbo].[MensajesProcesados];
GO