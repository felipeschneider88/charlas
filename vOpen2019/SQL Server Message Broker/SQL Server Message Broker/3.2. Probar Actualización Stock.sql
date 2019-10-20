SELECT  * FROM [dbo].[Articulos];
-- Iniciar una conversacion y enviar un mensaje inicial
DECLARE @conversation_handle UNIQUEIDENTIFIER;
DECLARE @message_body xml;--NVARCHAR(2000);

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

-- Vemos la conversacion que recien creamos
SELECT *
FROM sys.conversation_groups;
GO

-- Ver el mensaje en la queue de destino
SELECT *, 
	CAST(message_body AS XML) AS message_body_xml
FROM HolaMundo_DestinoQueue;
GO

-- Ver el mensaje en la queue de origen
SELECT *, 
	CAST(message_body AS XML) AS message_body_xml
FROM HolaMundo_InitiatorQueue;
GO

SELECT * FROM [dbo].[MensajesProcesados];
GO

SELECT  * FROM [dbo].[Articulos];
