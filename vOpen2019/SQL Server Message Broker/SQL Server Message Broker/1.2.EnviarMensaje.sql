-- Nos pasamos a la DB HolaMundo
USE HolaMundo;
GO

-- Comenzamos una conversasion y enviamos un mensaje
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

COMMIT TRANSACTION;
GO

-- Ver la convesacion que creamos
SELECT *
FROM sys.conversation_groups;
GO

-- Ver el mensaje en la queue de destino
SELECT *, 
	CAST(message_body AS XML) AS message_body_xml
FROM HolaMundo_DestinoQueue;
GO
