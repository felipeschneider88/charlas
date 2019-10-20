-- Nos pasamos a la DB HolaMundo
USE HolaMundo;
GO

-- Recicbimos el End Dialog y dejamos todo ordenado
DECLARE @conversation_handle UNIQUEIDENTIFIER;
DECLARE @message_body XML;
DECLARE @message_type_name sysname;

BEGIN TRANSACTION;

WAITFOR
( RECEIVE TOP(1)
    @conversation_handle = conversation_handle,
    @message_body = CAST(message_body AS XML),
    @message_type_name = message_type_name
  FROM HolaMundo_DestinoQueue
), TIMEOUT 1000;
-- Recordar limbiar los dialogos manejando el mensaje de EndDialog 
IF (@message_type_name = N'http://schemas.microsoft.com/SQL/ServiceBroker/EndDialog')
BEGIN
	 SELECT 'Handling EndDialog message';
     END CONVERSATION @conversation_handle;
END

COMMIT TRANSACTION;
GO

-- Comprobamos los mensajes en la queue destino
SELECT *, 
	CAST(message_body AS XML) AS message_body_xml
FROM HolaMundo_DestinoQueue;
GO

-- Comprobamos los mensajes en la queue initiator
SELECT *, 
	CAST(message_body AS XML) AS message_body_xml
FROM HolaMundo_InitiatorQueue;
GO

-- Comprobamos la conversacion que creamos
SELECT *
FROM sys.conversation_groups;
GO