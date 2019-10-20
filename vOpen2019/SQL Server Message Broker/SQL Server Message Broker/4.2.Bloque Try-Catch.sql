-- Cambiamos a nuestra base de datos
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
      ROLLBACK TRANSACTION;
      BREAK;
    END

	-- Ahora como estamos procesando el mensaje
	-- usaremos un bloque TRY/CATCH para manejo de errores y rollback de la 
	-- transaction para asegurarnos que no perdamos el mensaje debido a un error
	BEGIN TRY

	-- Manejar el HolaMundoMensaje
    IF @message_type_name = N'HolaMundoMensaje'
    BEGIN

		INSERT INTO dbo.MensajesProcesados (Nombre, Cuerpo) 
		VALUES ('DestinoQueue_ActivationProcedure', CAST(@message_body AS VARCHAR(MAX)));

		-- Extraer los datos para calcular el dividendo
		DECLARE @Numerador INT = @message_body.value('(HolaMundoMensaje/Numerador)[1]', 'int');
		DECLARE @Denominador INT = @message_body.value('(HolaMundoMensaje/Denominador)[1]', 'int');
		DECLARE @Resultado INT = @Numerador/@Denominador;
	
		-- Concatener el restulado dentro del HolaMundoReply
		-- Siempre usar ISNULL cuando estas concatenando!!!
		DECLARE @reply_message_body XML = N'<HolaMundoReply>El resultado de la divicion es: '+
							ISNULL(CAST(@Resultado AS VARCHAR), 'NULL')+'</HolaMundoReply>';

		SEND ON CONVERSATION @conversation_handle
				MESSAGE TYPE [HolaMundoReply] (@reply_message_body);
    END
	
	-- Si mensaje de fin de digalogo, finalizar el dialgo
    ELSE IF @message_type_name = N'http://schemas.microsoft.com/SQL/ServiceBroker/EndDialog'
    BEGIN
       END CONVERSATION @conversation_handle;
    END

	-- Si hay error, logearlo y finalizar la conversacion
    ELSE IF @message_type_name = N'http://schemas.microsoft.com/SQL/ServiceBroker/Error'
    BEGIN
		DECLARE @error INT;
		DECLARE @description NVARCHAR(4000);
		-- Obtener el error y su codigo del XML
		WITH XMLNAMESPACES ('http://schemas.microsoft.com/SQL/ServiceBroker/Error' AS ssb)
		SELECT
			@error = @message_body.value('(//ssb:Error/ssb:Code)[1]', 'INT'),
			@description = @message_body.value('(//ssb:Error/ssb:Description)[1]', 'NVARCHAR(4000)');
		
		RAISERROR(N'Error recibido, Codigo:%i Descripcion:"%s"', 16, 1, @error, @description) WITH LOG;
		-- Una vez manejado el error, limpiamos la convesacion
		END CONVERSATION @conversation_handle;
	END
    
	-- Si todo salio bien, hacemos commit de la transaction  
    COMMIT TRANSACTION;

	END TRY

	-- Si tuvimos un error, lo debemos manejar y enviar un error
	-- luego hacemos rollback de la transaction para devolver el mensaje a la queue
	BEGIN CATCH
		ROLLBACK TRANSACTION; -- Algo salio mal
		THROW
	END CATCH

  END
GO
-- Siempre prueba tus SP antes de entrar en produccion