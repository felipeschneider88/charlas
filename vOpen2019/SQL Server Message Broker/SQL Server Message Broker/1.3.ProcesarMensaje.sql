-- Nos pasamos a la DB HolaMundo
USE HolaMundo;
GO

-- Recibimos el mensaje y enviamos una respuesta
DECLARE @conversation_handle UNIQUEIDENTIFIER;
DECLARE @message_body XML;
DECLARE @message_type_name sysname;

BEGIN TRANSACTION;

WAITFOR
( RECEIVE TOP(1)
    @conversation_handle = conversation_handle,
    @message_body = message_body,
    @message_type_name = message_type_name
  FROM HolaMundo_DestinoQueue
), TIMEOUT 1000;

SELECT @message_body AS ReceivedRequestMsg;

IF (@message_type_name = N'HolaMundoMensaje')
BEGIN
     DECLARE @reply_message_body XML;
	 
	 SELECT @reply_message_body = N'<HolaMundoReply>ACK!</HolaMundoReply>';
 
     SEND ON CONVERSATION @conversation_handle
          MESSAGE TYPE [HolaMundoReply]
     (@reply_message_body);
END

SELECT @reply_message_body AS EnviarHolaMundoReply;

COMMIT TRANSACTION;
GO

-- Comprobar el mensaje este en la queue de destino
SELECT *, 
	CAST(message_body AS XML) AS message_body_xml
FROM HolaMundo_DestinoQueue;
GO

-- Check for the reply message in the initiator queue
SELECT *, 
	CAST(message_body AS XML) AS message_body_xml
FROM HolaMundo_InitiatorQueue;
GO
