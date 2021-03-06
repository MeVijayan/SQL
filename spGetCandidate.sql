USE [SoleoReference]
GO


CREATE PROCEDURE [mdm].[spGetCandidate] (
	@WorkerWorkdayId VARCHAR(200)
	,@WorkdayEmployeeNumber VARCHAR(50)
	,@SCEmployeeNumber INT
	,@FirstName VARCHAR(100)
	,@LastName VARCHAR(100)
	,@PreferredName VARCHAR(200)
	,@ADUserName VARCHAR(100)
	,@ADAccountCreateDateFrom DATETIME2(7)
	,@ADAccountCreateDateTo DATETIME2(7)
	,@PositionTitle VARCHAR(250)
	,@BusinessTitle VARCHAR(250)
	,@EmailAddress VARCHAR(100)
	,@EmployeeType VARCHAR(100)
	,@FullOrPartTime VARCHAR(20)
	,@StartDateFrom DATETIME2(7)
	,@StartDateTo DATETIME2(7)
	,@DepartmentName VARCHAR(100)
	,@OfficeName VARCHAR(100)
	,@ManagerName VARCHAR(200)
	,@ManagerEmployeeNumber INT
	,
	--@IsContractorConversion                  bit,
	@IsRehire BIT
	,@IsRescind BIT
	,@WorkdayUpdateStatus INT
	,@WorkdayUpdateDateFrom DATETIME2(7)
	,@WorkdayUpdateDateTo DATETIME2(7)
	,@IsADCreated BIT
	,@IsSCEmployeeNumberCreated BIT
	,@SortExpression VARCHAR(255)
	,@SortOrder BIT
	,@RowsPerPage BIGINT
	,@PageNumber BIGINT
	)
AS
WITH QueryResult
AS (
	SELECT a.WorkdayCandidateId
		,a.WorkerWorkdayId
		,a.WorkdayEmployeeNumber
		,a.SCEmployeeNumber
		,a.FirstName
		,a.LastName
		,a.MiddleName
		,a.PreferredName
		,a.ADUserName
		,a.ADAccountCreateDate
		,a.PositionTitle
		,a.BusinessTitle
		,a.JobCode
		,a.EmailAddress
		,a.EmployeeType
		,a.FullOrPartTime
		,a.StartDate
		,a.DepartmentName
		,a.DepartmentID
		,a.OfficeName
		,a.OfficeID
		,a.ManagerName
		,a.ManagerEmployeeNumber
		,a.Company
		,a.STATE
		,a.PhysicalDeliveryLocation
		,a.IsRehire
		,a.IsRescind
		,a.ADLoggedInDate
		,a.WorkdayUpdateStatus
		,a.WorkdayUpdateDate
		,a.IsADCreated
		,a.IsActive
		,a.CreateBy
		,a.CreateDate
		,a.ModifyBy
		,a.ModifyDate
		,CASE 
			WHEN (
					SELECT Count(*)
					FROM (
						SELECT a.FirstName + a.LastName AS NAME
						FROM mdm.WorkdayCandidate b WITH (NOLOCK)
						WHERE a.FirstName + a.LastName = b.FirstName + b.LastName
							AND a.WorkerWorkdayId != b.WorkerWorkdayId
						
						UNION ALL
						
						SELECT se.FirstName + se.LastName AS NAME
						FROM dbo.Employee se WITH (NOLOCK)
						WHERE se.FirstName + se.LastName = a.FirstName + a.LastName
						) tmpDuplicate
					GROUP BY NAME
					) > 1
				THEN 1
			ELSE 0
			END AS IsDuplicate
		,e.DistinguishedName
		,COUNT(1) OVER () MyCount
		,ROW_NUMBER() OVER (
			ORDER BY CASE @SortExpression
					WHEN 'WorkdayEmployeeNumber'
						THEN a.WorkdayEmployeeNumber
					WHEN 'FirstName'
						THEN a.FirstName
					WHEN 'LastName'
						THEN a.LastName
					WHEN 'PreferredName'
						THEN a.PreferredName
					WHEN 'ADUserName'
						THEN a.ADUserName
					WHEN 'PositionTitle'
						THEN a.PositionTitle
					WHEN 'BusinessTitle'
						THEN a.BusinessTitle
					WHEN 'JobCode'
						THEN a.JobCode
					WHEN 'EmailAddress'
						THEN a.EmailAddress
					WHEN 'EmployeeType'
						THEN a.EmployeeType
					WHEN 'DepartmentName'
						THEN a.DepartmentName
					WHEN 'OfficeName'
						THEN a.OfficeName
					WHEN 'ManagerName'
						THEN a.ManagerName
					WHEN 'Company'
						THEN a.Company
					WHEN 'State'
						THEN a.STATE
					WHEN 'PhysicalDeliveryLocation'
						THEN a.PhysicalDeliveryLocation
					END
				,CASE @SortExpression
					WHEN 'SCEmployeeNumber'
						THEN a.SCEmployeeNumber
					WHEN 'DepartmentID'
						THEN a.DepartmentID
					WHEN 'OfficeID'
						THEN a.OfficeID
					WHEN 'ManagerEmployeeNumber'
						THEN a.ManagerEmployeeNumber
					END
				,CASE @SortExpression
					WHEN 'ADAccountCreateDate'
						THEN a.ADAccountCreateDate
					WHEN 'StartDate'
						THEN a.StartDate
					WHEN 'ADLoggedInDate'
						THEN a.ADLoggedInDate
					WHEN 'WorkdayUpdateDate'
						THEN a.WorkdayUpdateDate
					END
			) AS SortRowNum
	FROM mdm.WorkdayCandidate a
	LEFT JOIN dbo.Employee e WITH (NOLOCK) ON a.SCEmployeeNumber = e.EmployeeNumber
	WHERE (
			a.WorkerWorkdayId = @WorkerWorkdayId
			OR @WorkerWorkdayId IS NULL
			)
		AND (
			a.WorkdayEmployeeNumber = @WorkdayEmployeeNumber
			OR @WorkdayEmployeeNumber IS NULL
			)
		AND (
			a.SCEmployeeNumber = @SCEmployeeNumber
			OR @SCEmployeeNumber IS NULL
			)
		AND (
			a.FirstName LIKE '%' + @FirstName + '%'
			OR @FirstName IS NULL
			)
		AND (
			a.LastName LIKE '%' + @LastName + '%'
			OR @LastName IS NULL
			)
		AND (
			a.PreferredName LIKE '%' + @PreferredName + '%'
			OR @PreferredName IS NULL
			)
		AND (
			a.ADUserName LIKE '%' + @ADUserName + '%'
			OR @ADUserName IS NULL
			)
		AND (
			a.ADAccountCreateDate >= @ADAccountCreateDateFrom
			OR @ADAccountCreateDateFrom IS NULL
			)
		AND (
			a.ADAccountCreateDate <= @ADAccountCreateDateTo
			OR @ADAccountCreateDateTo IS NULL
			)
		AND (
			a.PositionTitle LIKE '%' + @PositionTitle + '%'
			OR @PositionTitle IS NULL
			)
		AND (
			a.BusinessTitle LIKE '%' + @BusinessTitle + '%'
			OR @BusinessTitle IS NULL
			)
		AND (
			a.EmailAddress LIKE '%' + @EmailAddress + '%'
			OR @EmailAddress IS NULL
			)
		AND (
			a.EmployeeType = @EmployeeType
			OR @EmployeeType IS NULL
			)
		AND (
			a.FullOrPartTime = @FullOrPartTime
			OR @FullOrPartTime IS NULL
			)
		AND (
			a.StartDate >= @StartDateFrom
			OR @StartDateFrom IS NULL
			)
		AND (
			a.StartDate <= @StartDateTo
			OR @StartDateTo IS NULL
			)
		AND (
			a.DepartmentName LIKE '%' + @DepartmentName + '%'
			OR @DepartmentName IS NULL
			)
		AND (
			a.OfficeName LIKE '%' + @OfficeName + '%'
			OR @OfficeName IS NULL
			)
		AND (
			a.ManagerName LIKE '%' + @ManagerName + '%'
			OR @ManagerName IS NULL
			)
		AND (
			a.ManagerEmployeeNumber = @ManagerEmployeeNumber
			OR @ManagerEmployeeNumber IS NULL
			)
		--AND (IsContractorConversion = @IsContractorConversion OR @IsContractorConversion IS NULL)
		AND (
			a.IsRehire = @IsRehire
			OR @IsRehire IS NULL
			)
		AND (
			a.IsRescind = @IsRescind
			OR @IsRescind IS NULL
			)
		AND (
			a.WorkdayUpdateStatus = @WorkdayUpdateStatus
			OR @WorkdayUpdateStatus IS NULL
			)
		AND (
			a.WorkdayUpdateDate >= @WorkdayUpdateDateFrom
			OR @WorkdayUpdateDateFrom IS NULL
			)
		AND (
			a.WorkdayUpdateDate <= @WorkdayUpdateDateTo
			OR @WorkdayUpdateDateTo IS NULL
			)
		AND (
			a.IsADCreated = @IsADCreated
			OR @IsADCreated IS NULL
			)
		AND (
			(
				CASE 
					WHEN a.SCEmployeeNumber IS NOT NULL
						THEN 1
					WHEN a.SCEmployeeNumber IS NULL
						THEN 0
					END
				) = @IsSCEmployeeNumberCreated
			OR @IsSCEmployeeNumberCreated IS NULL
			)
	)
	,QueryResultSorted
AS (
	SELECT CASE @SortOrder
			WHEN 0
				THEN SortRowNum
			ELSE MyCount + 1 - SortRowNum
			END AS MyRowNum
		,QueryResult.*
	FROM QueryResult
	)
SELECT *
FROM QueryResultSorted
WHERE (
		@RowsPerPage = 0
		OR MyRownum BETWEEN (@PageNumber - 1) * @RowsPerPage + 1
			AND @PageNumber * @RowsPerPage
		OR MyCount = 0
		OR (
			@RowsPerPage IS NULL
			AND @PageNumber IS NULL
			)
		)
ORDER BY QueryResultSorted.MyRowNum

RETURN 0