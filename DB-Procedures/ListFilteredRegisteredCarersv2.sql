USE [FStepChildCare_prod]
GO
/****** Object:  StoredProcedure [dbo].[ListFilteredRegisteredCarersv2]    Script Date: 30/12/2019 15:10:06 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		Daniel Gregory
-- Create date: 11/06/2018
-- Description:	List filtered Registered Carers
	--@ageFrom as int,
	--@ageTo as int,
-- 24/10/2018 updated for Additional details and show more
-- 12/07/2019 update for Out of School Clubs
-- 22/10/2019 updates for out of school clubs include Schemes in the output
-- =============================================
ALTER PROCEDURE [dbo].[ListFilteredRegisteredCarersv2] 
	@postcode as nvarchar(10),
	@minOfstedJudgeStr as varchar(5),
	@ofstedNew as nvarchar(5),
	@nearLoc as nvarchar(5),
	@nearlatStr as nvarchar(10),
	@nearlngStr as nvarchar(10),
	@distanceStr as nvarchar(10),
	@category as varchar(20),
	@scheme as varchar(20),
	@optionsFil as varchar(255)
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @nearPNT geography, 
			@distanceM decimal(7,3),
			@numRows as int,
			@loopCounter as int,
			@htmlOut as varchar(max),
			@heading as varchar(255),
			@contact as varchar(255),
			@url as varchar(500),
			@ageRange as varchar(255),
			@ofstead as varchar(255),
			@vacancies as varchar(255),
			@options as varchar(255),
			@optionsDis as varchar(1000),
			@rowCount as int,
			@idCarer as varchar(5),
			@lstIDsout as varchar(max),
			@schPickups as varchar(1000),
			@addInfo as varchar(1000),
			@nearlat as decimal(9,6),
			@nearlng as decimal(9,6),
			@distance as float,
			@minOfstedJudge as int,
			@avSchemes as varchar(1000),
			@idRec as varchar(5),
			@comma as varchar(5);
	
	CREATE TABLE #Temp(ID int identity(1,1) NOT NULL
			  ,[IDcarer] int NOT NULL
			  ,[toShow] varchar(20) NULL
			  ,[settingName] nvarchar(255) NULL
			  ,[URN] varchar(255) NULL
			  ,[phoneNo] nvarchar(255) NULL
			  ,[email] nvarchar(255) NULL
			  ,[postcode] nvarchar(10) NULL
			  ,[website] nvarchar(255) NULL
			  ,[ageFrom] int NULL
			  ,[ageTo] int NULL
			  ,[vacancies] nvarchar(5) NULL
			  ,[schoolPickups]  varchar(500) NULL
			  ,[score] varchar(25) NULL
			  ,[ofstedURL] varchar(255) NULL
			  ,[options] nvarchar(255) NULL
			  ,[schPickups] varchar(max) NULL
			  ,[addInformation] varchar(max) NULL
			  ,[calDist] decimal(7,3) NULL
			  ,[category] varchar(20) NULL
			  ,[address] nvarchar(500) NULL
			  ,[schemes] nvarchar(255) NULL)
			  
	
	SET @postcode = ISNULL(@postcode, '')
	SET @minOfstedJudge = NULLIF(@minOfstedJudgeStr, '')
	SET @ofstedNew = ISNULL(@ofstedNew, '')
	--SET @ageFrom = ISNULL(@ageFrom, '')
	--SET @ageTo = ISNULL(@ageTo, '')
	SET @nearLoc = ISNULL(@nearLoc, '')
	SET @nearlat = NULLIF(@nearlatStr, '')
	SET @nearlng = NULLIF(@nearlngStr, '')
	SET @distance = NULLIF(@distanceStr, '')
	SET @optionsFil = REPLACE(@optionsFil, ' ', '')
	SET @scheme = REPLACE(@scheme, ' ', '')

	IF @nearLoc = 'yes'
	BEGIN
		--SET @nearPNT = geography::STGeomFromText('POINT(' + convert(varchar,@nearlat) + ' ' + convert(varchar,@nearlng) + ')', 4326);
		SET @nearPNT = geography::Point(@nearlat,@nearlng,4326);
		SET @distanceM = @distance --* 1609.344;
		
		INSERT INTO #Temp([IDcarer]
						  ,[toShow]
						  ,[settingName]
						  ,[URN]
						  ,[phoneNo]
						  ,[email]
						  ,[postcode]
						  ,[website]
						  ,[ageFrom]
						  ,[ageTo]
						  ,[vacancies]
						  ,[schoolPickups]
						  ,[score]
						  ,[ofstedURL]
						  ,[options]
						  ,[schPickups]
						  ,[addInformation]
						  ,[calDist]
						  ,[category]
						  ,[address]
						  ,[schemes])
		SELECT [IDcarer]
			  ,[toShow]
			  ,[settingName]
			  ,[URN]
			  ,[phoneNo]
			  ,[email]
			  ,[postcode]
			  ,[website]
			  ,[ageFrom]
			  ,[ageTo]
			  ,[vacancies]
			  ,[schoolPickups]
			  ,[score]
			  ,[ofstedURL]
			  ,[options]
			  ,[schoolPickups]
			  ,[addInfo]
			  ,@nearPNT.STDistance([geoPoint]) as calDist
			  ,category
			  ,AddrTextArea
			  ,schemes
		  FROM [dbo].[RegisteredCarersV3]
		  LEFT JOIN dbo.CMofsted ON [overallOfstedJudgeID] = IDofstedScore
		 WHERE ([toShow] NOT LIKE '%hAl%' or [toShow] is null)
		   AND (@minOfstedJudge is null OR scoreValue >= @minOfstedJudge
				OR (scoreValue = 0 AND @ofstedNew = 'yes') )
		   AND (@optionsFil = '' OR dbo.inclusivematch(@optionsFil,REPLACE(options, ' ', '')) = 'yes')
		   --AND @ageFrom >= ageFrom AND @ageFrom <= ageTo
		   --AND @ageTo <= ageTo AND @ageTo >= ageFrom
		   --AND (@postcode = '' OR [postcode] like @postcode + '%')
		   --AND (@postcode = '' OR [postcode] like @postcode + '%')
		   AND (@category = '' OR category = @category)
		   AND (@scheme = '' OR dbo.inclusivematch(@scheme, REPLACE(schemes, ' ', '')) = 'yes')
		   AND @nearPNT.STDistance(geoPoint) <= @distance
		  ORDER BY calDist;
		   
	END
	ELSE
	BEGIN
		INSERT INTO #Temp([IDcarer]
						  ,[toShow]
						  ,[settingName]
						  ,[phoneNo]
						  ,[email]
						  ,[postcode]
						  ,[website]
						  ,[ageFrom]
						  ,[ageTo]
						  ,[vacancies]
						  ,[schoolPickups]
						  ,[score]
						  ,[ofstedURL]
						  ,[options]
						  ,[schPickups]
						  ,[addInformation]
						  ,[category]
						  ,[address]
						  ,[schemes])
		SELECT [IDcarer]
			  ,[toShow]
			  ,[settingName]
			  ,[phoneNo]
			  ,[email]
			  ,[postcode]
			  ,[website]
			  ,[ageFrom]
			  ,[ageTo]
			  ,[vacancies]
			  ,[schoolPickups]
			  ,[score]
			  ,[ofstedURL]
			  ,[options]
			  ,[schoolPickups]
			  ,[addInfo]
			  ,category
			  ,AddrTextArea
			  ,schemes
		  FROM [dbo].[RegisteredCarersV3]
		  LEFT JOIN dbo.CMofsted ON [overallOfstedJudgeID] = IDofstedScore
		 WHERE ([toShow] NOT LIKE '%hAl%' or [toShow] is null)
		   AND (@minOfstedJudge is null OR scoreValue >= @minOfstedJudge
				OR (scoreValue = 0 AND @ofstedNew = 'yes') )
		   AND (@optionsFil = '' OR dbo.inclusivematch(@optionsFil, REPLACE(options, ' ', '')) = 'yes')
		   --AND @ageFrom >= ageFrom AND @ageFrom <= ageTo
		   --AND @ageTo <= ageTo AND @ageTo >= ageFrom
		   AND (@postcode = '' OR [postcode] like @postcode + '%')
		   AND (@category = '' OR category = @category)
		   AND (@scheme = '' OR dbo.inclusivematch(@scheme, REPLACE(schemes, ' ', '')) = 'yes')
		  ORDER BY settingName;
	END
	
	SET @numRows = SCOPE_IDENTITY();
	SET @loopCounter = 1
	SET @rowCount = 1
	SET @htmlOut = ''
--####  loop through all the retrieved data	
	WHILE(@loopCounter <= @numRows)
	BEGIN
		SELECT @heading = CASE WHEN [toShow] Like '%hNm%' THEN
							  CASE WHEN isnull(website, '') = '' THEN
								'<h4>Ofsted URN ' + isnull(URN, '') + '</h4>'
							  ELSE
								'<h4><a target="_blank" href="' + isnull(website, '') + '">Ofsted URN ' + isnull(URN, '') + '</a></h4>'
							  END
						   ELSE
							  CASE WHEN isnull(website, '') = '' THEN
								'<h4>' + isnull(settingName, '') + '</h4>'
							  ELSE
								'<h4><a target="_blank" href="' + isnull(website, '') + '">' + isnull(settingName, '') + '</a></h4>'
							  END
						   END
			   ,@contact = '<p class="condensed">'
						 + CASE WHEN [toShow] Like '%hCn%' THEN
							   ''
						   ELSE
							   CASE WHEN isnull(phoneNo, '') = '' THEN
								'Telephone: '
							   ELSE
								'Telephone: <a target="_top" href="tel:' + isnull(phoneNo, '') + '">' + isnull(phoneNo, '') + '</a>'
							   END
						   END
						 + CASE WHEN [toShow] Like '%hEm%' THEN
							   ''
						   ELSE
							   CASE WHEN isnull(email, '') = '' THEN
								'<br />Email: ' + isnull(email, '') 
							   ELSE
								'<br />Email: <a target="_top" href="mailto:' + isnull(email, '') + '">' + isnull(email, '') + '</a>'
							   END
						   END
						 + '</p>'
			   ,@ageRange = CASE WHEN [category] = 'Out of School Club' THEN 
													  '<p class="condensed">' 
													ELSE
													  '<p class="condensed">Age from ' + isnull(convert(varchar(2),ageFrom), '') + ' to ' + isnull(convert(varchar(2),ageTo), '') + '&nbsp&nbsp&nbsp&nbsp&nbsp'END
			   ,@ofstead = CASE WHEN isnull(ofstedURL, '') = '' THEN
							'Ofsted grade: ' + isnull(score, '')
						   ELSE
							'Ofsted grade: <a target="_blank" href="' + isnull(ofstedURL, '') + '">' + isnull(score, '') + '</a>'
						   END
			   ,@vacancies = '<br />Vacancies: ' + (CASE vacancies
														WHEN 'no' THEN 'No'
														WHEN 'yes' THEN 'Yes'
														ELSE 'Contact Us'
													END) + '</p>'
			   ,@options = isnull(options, '')
			   ,@schPickups = ISNULL(schPickups, '')
			   ,@addInfo = ISNULL(addInformation, '')
			   ,@idCarer = CONVERT(varchar(5),IDcarer)
			   ,@avSchemes = ISNULL(schemes, '')
			   ,@idRec = ID
		FROM #Temp
		WHERE ID = @loopCounter;
--##### Build the options and additional info paragraphs
		
		IF @options != '' OR @schPickups != '' OR @addInfo != '' or @avSchemes != ''
		BEGIN
			SET @optionsDis = '<div><label class="moreInfo" for="toggler-id-' + @idRec + '">more info...</label><input type="checkbox" id="toggler-id-' + @idRec + '" class="toggler" /><div class="toggler-content"><p>'
			SET @comma = ''
			
			IF @options Like '%2YearFund%'
			BEGIN
				SET @optionsDis = @optionsDis + '2 year funding'
				SET @comma = ', '
			END
			
			IF @options Like '%3_4yearFund%'
			BEGIN
				SET @optionsDis = @optionsDis + @comma + '3 & 4 year universal'
				SET @comma = ', '
			END
			
			IF @options Like '%3_4yearExtend%'
			BEGIN
				SET @optionsDis = @optionsDis + @comma + '30 hour funding'
				SET @comma = ', '
			END
			
			IF @options Like '%taxFree%'
				SET @optionsDis = @optionsDis + @comma + 'Tax free childcare'
			
			-- Schemes available for the out of school clubs
			SET @comma = ''
			
			IF @avSchemes Like '%1%'
			BEGIN
				SET @optionsDis = @optionsDis  + 'Breakfast club'
				SET @comma = ', '
			END
			
			IF @avSchemes Like '%2%'
			BEGIN
				SET @optionsDis = @optionsDis + @comma  + 'After School club'
				SET @comma = ', '
			END
			
			IF @avSchemes Like '%3%'
				SET @optionsDis = @optionsDis + @comma  + 'Holiday playscheme'
			
			
			IF @schPickups != ''
			BEGIN
				IF LEN(@optionsDis) > 45
					SET @optionsDis = @optionsDis + '<br /><strong>School Pickups</strong><br />' + @schPickups
				ELSE
					SET @optionsDis = @optionsDis + '<strong>School Pickups</strong><br />' + @schPickups
			END
			
			IF @addInfo != ''
			BEGIN
				IF LEN(@optionsDis) > 45
					SET @optionsDis = @optionsDis + '<br /><strong>Additional information</strong><br />' + @addInfo
				ELSE
					SET @optionsDis = @optionsDis + '<strong>Additional information</strong><br />' + @addInfo
			END
			
			SET @optionsDis = @optionsDis + '</p></div></div>'
		END
		ELSE
			SET @optionsDis = ''
--###### add the paragraphs either as first or as subsequent panels		
		IF @rowCount = 1
		BEGIN
			SET @htmlOut = @htmlOut + '<div class="row"><div class="col-md-6"><div class="card"><div class="card-body">'
			SET @htmlOut = @htmlOut + @heading + @contact + @ageRange + @ofstead + @vacancies + @optionsDis + '</div></div></div>'
			SET @rowCount = 2;
		END
		ELSE
		BEGIN
			SET @htmlOut = @htmlOut + '<div class="col-md-6"><div class="card"><div class="card-body">'
			SET @htmlOut = @htmlOut + @heading + @contact + @ageRange + @ofstead + @vacancies  + @optionsDis + '</div></div></div></div>'
			SET @rowCount = 1;
		END
		IF @lstIDsout is null
			SET @lstIDsout = @idCarer
		ELSE
			SET @lstIDsout = @lstIDsout + ',' + @idCarer
		
		SET @loopCounter = @loopCounter + 1;
	END
	
	SET @htmlOut = '<div class="container-fluid"><div class="card-columns">' + @htmlOut + '</div></div>'
	
	SELECT @htmlOut as htmlSearchResults , @numRows as checkRows, @lstIDsout as listIDs
	
END

