-- Cambiar a la base de datos
USE HolaMundo;
GO


IF OBJECT_ID('InitiatorQueue_ActivationProcedure') IS NOT NULL
BEGIN
	DROP PROCEDURE InitiatorQueue_ActivationProcedure;
END
GO

CREATE PROCEDURE InitiatorQueue_ActivationProcedure
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
      FROM HolaMundo_InitiatorQueue
    ), TIMEOUT 5000;

    IF (@@ROWCOUNT = 0)
    BEGIN
      ROLLBACK TRANSACTION;
      BREAK;
    END

    IF @message_type_name = N'HolaMundoReply'
    BEGIN

	   INSERT INTO dbo.MensajesProcesados (Nombre, Cuerpo) 
	   VALUES ('InitiatorQueue_ActivationProcedure', CAST(@message_body AS VARCHAR(MAX)));

       END CONVERSATION @conversation_handle;
    END

    COMMIT TRANSACTION;

  END
GO
