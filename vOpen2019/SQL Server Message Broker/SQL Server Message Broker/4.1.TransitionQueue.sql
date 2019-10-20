-- Cambiamos a nuestra base de datos
USE HolaMundo;
GO

--Deshabilitar la queue destino
ALTER QUEUE [dbo].[HolaMundo_InitiatorQueue] WITH STATUS = OFF;

-- Begin a conversation and send a request message
DECLARE @conversation_handle UNIQUEIDENTIFIER;
DECLARE @message_body XML;

BEGIN TRANSACTION;

BEGIN DIALOG @conversation_handle
     FROM SERVICE [HolaMundo_InitiatorService]
     TO SERVICE N'HolaMundo_DestinoService'
     ON CONTRACT [HolaMundoContrato]
     WITH ENCRYPTION = OFF;

select @message_body = N'
<HolaMundoMensaje>
	<idArt>1</idArt>
	<Vendidos>1</Vendidos>
</HolaMundoMensaje>';

SEND ON CONVERSATION @conversation_handle
     MESSAGE TYPE [HolaMundoMensaje]
     (@message_body);

SELECT @message_body AS SentMsg;

COMMIT TRANSACTION;
GO

-- Ver los mensajes en la queue destino
SELECT *, 
	CAST(message_body AS XML) AS message_body_xml
FROM HolaMundo_DestinoQueue;
GO

-- Ver los mensajes en la queue origen
SELECT *, 
	CAST(message_body AS XML) AS message_body_xml
FROM HolaMundo_InitiatorQueue;
GO

SELECT * FROM [dbo].[MensajesProcesados];
GO

SELECT * FROM sys.transmission_queue;
GO

--Habilitar nuestra queue origen
ALTER QUEUE [dbo].[HolaMundo_InitiatorQueue] WITH STATUS = ON;
GO

SELECT * FROM sys.transmission_queue;
GO

SELECT * FROM [dbo].[MensajesProcesados];
GO
