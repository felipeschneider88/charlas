-- Nos pasamos a la DB HolaMundo
USE HolaMundo;
GO

-- Recibir la respuesta y finalizamos la conversacion
DECLARE @message_body XML;
DECLARE @conversation_handle UNIQUEIDENTIFIER;
DECLARE @message_type_name sysname;

BEGIN TRANSACTION;

WAITFOR
( RECEIVE TOP(1)
    @conversation_handle = conversation_handle,
    @message_body = CAST(message_body AS XML),
	@message_type_name = message_type_name
  FROM HolaMundo_InitiatorQueue
), TIMEOUT 1000;

IF (@message_type_name = N'HolaMundoReply')
BEGIN
	END CONVERSATION @conversation_handle;
END

SELECT @message_body AS RecibidoHolaMundoReply;

COMMIT TRANSACTION;
GO

-- Comprobar los mensajes en la queue destino
SELECT *, 
	CAST(message_body AS XML) AS message_body_xml
FROM HolaMundo_DestinoQueue;
GO

-- Comprobar los mensajes en la queue initiator 
SELECT *, 
	CAST(message_body AS XML) AS message_body_xml
FROM HolaMundo_InitiatorQueue;
GO
