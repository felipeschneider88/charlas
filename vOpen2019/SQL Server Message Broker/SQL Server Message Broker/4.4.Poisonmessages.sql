-- Modificar la queue destino para remover el activador automático
ALTER QUEUE HolaMundo_DestinoQueue
    WITH ACTIVATION
    ( STATUS = OFF);
GO

-- Modifcar la queue destino para habilitarla
ALTER QUEUE HolaMundo_DestinoQueue
    WITH STATUS = ON;
GO

-- Vamos a ver el mensaje de la queue que está dando problemas
SELECT TOP 1
	conversation_handle,
	message_type_name,
	CAST(message_body AS XML) AS message_body_xml
FROM HolaMundo_DestinoQueue;
GO


-- Creamos una tabla para almacenar los mensajes envenenados
CREATE TABLE poisonMessages
(	RowID INT IDENTITY PRIMARY KEY,
	ConversationHandle UNIQUEIDENTIFIER,
	message_body XML,
	message_type_name sysname);
GO

-- Quitamos el mensaje malo de la queue y lo guardamos en la tabla
DECLARE @conversation_handle UNIQUEIDENTIFIER;
DECLARE @message_body XML;
DECLARE @message_type_name sysname;

BEGIN TRANSACTION

WAITFOR
(	RECEIVE TOP(1)
		@conversation_handle = conversation_handle,
		@message_body = message_body,
		@message_type_name = message_type_name
	FROM HolaMundo_DestinoQueue
), TIMEOUT 5000;
IF (@@ROWCOUNT = 0)
BEGIN
	ROLLBACK TRANSACTION;
END

INSERT INTO dbo.poisonMessages (ConversationHandle, message_body, message_type_name)
SELECT @conversation_handle, @message_body, @message_type_name;

COMMIT TRANSACTION;
GO

-- Modificar la queue de destino para volver a habilitar la activacion automática
ALTER QUEUE HolaMundo_DestinoQueue
    WITH ACTIVATION
    ( STATUS = ON);
GO

-- Vemos los mensajes procesados
SELECT * FROM [dbo].[MensajesProcesados];
GO

-- Se puede considerar este caso como uno particular del SP interno que se puede 
--ingresar en un bloque con CATCH para manejarlo apropiadamente

-- Se sugiere creare una alerta o un evento de notificacion cuando BROKER_QUEUE_DISABLED 
-- para que envie un email para detectar las queue desactivadas proactivamente
