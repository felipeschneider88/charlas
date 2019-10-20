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



-- Iniciar una conversacion y enviar un mensaje inicial
DECLARE @conversation_handle UNIQUEIDENTIFIER;
DECLARE @message_body NVARCHAR(100);

BEGIN TRANSACTION;

BEGIN DIALOG @conversation_handle
     FROM SERVICE [HolaMundo_InitiatorService]
     TO SERVICE N'HolaMundo_DestinoService'
     ON CONTRACT [HolaMundoContrato]
     WITH ENCRYPTION = OFF;

SELECT @message_body = N'<HolaMundoMensaje>Hola Mundo completo!</HolaMundoMensaje>';

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
