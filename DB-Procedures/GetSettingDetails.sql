USE [FStepChildCare_prod]
GO
/****** Object:  StoredProcedure [dbo].[GetSettingDetails]    Script Date: 31/12/2019 13:41:48 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Daniel Gregory
-- Create date: 02/05/2018
-- Description:	Retrieve details for Registered Carer
-- 23/10/2018 updated for Additional Information field
-- =============================================
ALTER PROCEDURE [dbo].[GetSettingDetails] 
	@carerID as int
AS
BEGIN
	SET NOCOUNT ON;

    SELECT [IDcarer]
		  ,[toShow]
		  ,[typeID]
		  ,[URN]
		  ,[settingName]
		  ,[phoneNo]
		  ,[mobile]
		  ,[phone2]
		  ,[phone3]
		  ,[contactName]
		  ,[email]
		  ,[pccEmail1]
		  ,[pccEmail2]
		  ,[addrTextArea]
		  ,[postcode]
		  ,[locality]
		  ,[linkedOfficer]
		  ,[idaciCode] as idaci
		  ,[website]
		  ,[ageFrom]
		  ,[ageTo]
		  ,[vacancies]
		  ,[overallOfstedJudgeID]
		  ,[ofstedDate]
		  ,[ofstedURL] as ofstedLink
		  ,[options]
		  ,[schoolPickups]
		  ,[addInfo] as addInformation
		  ,[notes]
		  ,[lat]
		  ,[lng]
		  ,[category]
		  ,[otherURNs]
		  ,[numberPlaces]
		  ,[openHrsFeesTextArea]
		  ,[schemes]
		  ,[toShow] as toShow1
		  ,[typeID] as typeID1
		  ,[URN] as URN1
		  ,[settingName] as settingName1
		  ,[phoneNo] as phoneNo1
		  ,[mobile] as mobile1
		  ,[phone2] as phone21
		  ,[phone3] as phone31
		  ,[contactName] as contactName1
		  ,[email] as email1
		  ,[pccEmail1] as pccEmail11
		  ,[pccEmail2] as pccEmail21
		  ,[addrTextArea] as addrTextArea1
		  ,[postcode] as postcode1
		  ,[locality] as locality1
		  ,[linkedOfficer] as linkedOfficer1
		  ,[idaciCode] as idaci1
		  ,[website] as website1
		  ,[ageFrom] as ageFrom1
		  ,[ageTo] as ageTo1
		  ,[vacancies] as vacancies1
		  ,[overallOfstedJudgeID] as overallOfstedJudgeID1
		  ,[ofstedDate] as ofstedDate1
		  ,[ofstedURL] as ofstedLink1
		  ,[options] as options1
		  ,[schoolPickups] as schoolPickups1
		  ,[addInfo] as addInformation1
		  ,[notes] as notes1
		  ,[lat] as lat1
		  ,[lng] as lng1
		  ,[category] as category1
		  ,[otherURNs] as otherURNs1
		  ,[numberPlaces] as numberPlaces1
		  ,[openHrsFeesTextArea] as openHrsFeesTextArea1
		  ,[schemes] as schemes1
		  ,'' as updateLoc
		  ,'' as newRecord
		  --,'' as defaultSelectProvi
	  FROM [dbo].[RegisteredCarersV3]
	  WHERE [IDcarer] = @carerID
  
END
