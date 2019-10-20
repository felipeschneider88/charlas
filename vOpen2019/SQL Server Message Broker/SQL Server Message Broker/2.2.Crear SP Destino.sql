-- Cambiar a la base de datos
USE HolaMundo;
GO

IF OBJECT_ID('DestinoQueue_ActivationProcedure') IS NOT NULL
BEGIN
	DROP PROCEDURE DestinoQueue_ActivationProcedure;
END
GO

CREATE PROCEDURE DestinoQueue_ActivationProcedure
AS
  DECLARE @conversation_handle UNIQUEIDENTIFIER;
  DECLARE @message_body XML;
  DECLARE @message_type_name sysname;
  --Ya se, no es la forma mas feliz de hacer un loop, 
  --pero de esta forma procesamos todos los mensajes en la Queue y mejoramos la performace y solo cuando no haya más,
  --espera 5000ms y se cierra
  WHILE (1=1)
  BEGIN
    BEGIN TRANSACTION;
    WAITFOR
    ( RECEIVE TOP(1)
        @conversation_handle = conversation_handle,
        @message_body = message_body,
        @message_type_name = message_type_name
      FROM HolaMundo_DestinoQueue
    ), TIMEOUT 5000;
    IF (@@ROWCOUNT = 0)
    BEGIN
		--Sale si no encontró ningun elemento en la cola
      ROLLBACK TRANSACTION;
      BREAK;
    END

    IF @message_type_name = N'HolaMundoMensaje'
    BEGIN

	   INSERT INTO dbo.MensajesProcesados (Nombre, Cuerpo) 
	   VALUES ('DestinoQueue_ActivationProcedure', CAST(@message_body AS VARCHAR(MAX)));

       DECLARE @reply_message_body XML = N'<HolaMundoReply>Mensaje recibido!</HolaMundoReply>';
 
       SEND ON CONVERSATION @conversation_handle
              MESSAGE TYPE [HolaMundoReply] (@reply_message_body);
    END

    COMMIT TRANSACTION;
  END
GO

-- Siempre prueba tus SP antes de entrar en produccion
