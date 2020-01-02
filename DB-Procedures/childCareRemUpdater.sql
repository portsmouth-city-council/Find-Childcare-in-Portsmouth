USE [FStepChildCare_prod]
GO
/****** Object:  StoredProcedure [dbo].[childCareRemUpdater]    Script Date: 30/12/2019 15:05:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Daniel Gregory
-- Create date: 21/10/2019
-- Description:	Remove a provider account from being able to update a provider.
-- =============================================
CREATE PROCEDURE [dbo].[childCareRemUpdater]
			@email as varchar(256)
			,@provID as int
AS
BEGIN
	SET NOCOUNT ON;

    DELETE FROM [dbo].[ProviderUpdaters]
      WHERE settingID = @provID
      and provEmail = @email

END
