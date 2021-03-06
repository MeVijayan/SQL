USE [SoleoReference]
GO

/****** Object:  StoredProcedure [mdm].[spInsertWorkdayCandidate]    Script Date: 8/18/2016 11:56:53 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [mdm].[spInsertCandidate] (@ttWorkdayCandidate mdm.ttWorkdayCandidate READONLY)
AS
BEGIN
	MERGE mdm.WorkdayCandidate AS TARGET
	USING (
		SELECT a.WorkerWorkdayId
			,a.WorkdayEmployeeNumber
			,a.SCEmployeeNumber
			,a.FirstName
			,a.LastName
			,a.MiddleName
			,a.PreferredName
			,b.DomainUserName AS ADUserName
			,b.createDate AS ADAccountCreateDate
			,a.PositionTitle
			,a.BusinessTitle
			,a.JobCode
			,b.Email AS EmailAddress
			,a.EmployeeType
			,a.FullOrPartTime
			,a.StartDate
			,a.DepartmentName
			,a.DepartmentID
			,a.OfficeName
			,c.OfficeID
			,a.LocationHierarchyCode
			,a.ManagerName
			,a.ManagerEmployeeNumber
			,a.Company
			,a.STATE
			,a.PhysicalDeliveryLocation
			,a.IsRehire
			,a.IsRescind
			,a.IsADCreated
			,b.LastDateOfHire AS ADLoggedInDate
			,a.WorkdayUpdateStatus
			,a.WorkdayUpdateDate
			,1 AS isActive
			,a.UserId AS UserId
			,isContractorConversion
		FROM @ttWorkdayCandidate a
		LEFT JOIN Soleoreference..Employee b WITH (NOLOCK) ON a.SCEmployeeNumber = b.EmployeeNumber
		LEFT JOIN Solarworks..Offices c WITH (NOLOCK) ON REPLACE(a.OfficeName, ' ', '') = REPLACE(c.NAME, ' ', '')
			AND (
				a.OfficeId = c.SegmentID
				OR a.OfficeId = c.CommercialSegmentId
				)
		) AS SOURCE
		ON TARGET.WorkerWorkdayId = SOURCE.WorkerWorkdayId
	WHEN MATCHED
		AND (
			(
				TARGET.WorkdayEmployeeNumber <> SOURCE.WorkdayEmployeeNumber
				AND SOURCE.WorkdayEmployeeNumber IS NOT NULL
				)
			OR (
				TARGET.FirstName <> SOURCE.FirstName
				AND SOURCE.FirstName IS NOT NULL
				)
			OR (
				TARGET.LastName <> SOURCE.LastName
				AND SOURCE.LastName IS NOT NULL
				)
			OR (
				TARGET.MiddleName <> SOURCE.MiddleName
				AND SOURCE.MiddleName IS NOT NULL
				)
			OR (
				TARGET.PreferredName <> SOURCE.PreferredName
				AND SOURCE.PreferredName IS NOT NULL
				)
			OR (
				TARGET.PositionTitle <> SOURCE.PositionTitle
				AND SOURCE.PositionTitle IS NOT NULL
				)
			OR (
				TARGET.BusinessTitle <> SOURCE.BusinessTitle
				AND SOURCE.BusinessTitle IS NOT NULL
				)
			OR (
				TARGET.JobCode <> SOURCE.JobCode
				AND SOURCE.JobCode IS NOT NULL
				)
			OR (
				TARGET.EmailAddress <> SOURCE.EmailAddress
				AND SOURCE.EmailAddress IS NOT NULL
				)
			OR (
				TARGET.EmployeeType <> SOURCE.EmployeeType
				AND SOURCE.EmployeeType IS NOT NULL
				)
			OR (
				TARGET.FullOrPartTime <> SOURCE.FullOrPartTime
				AND SOURCE.FullOrPartTime IS NOT NULL
				)
			OR (
				TARGET.StartDate <> SOURCE.StartDate
				AND SOURCE.StartDate IS NOT NULL
				)
			OR (
				TARGET.DepartmentName <> SOURCE.DepartmentName
				AND SOURCE.DepartmentName IS NOT NULL
				)
			OR (
				TARGET.DepartmentID <> SOURCE.DepartmentID
				AND SOURCE.DepartmentID IS NOT NULL
				)
			OR (
				TARGET.OfficeName <> SOURCE.OfficeName
				AND SOURCE.OfficeName IS NOT NULL
				)
			OR (
				TARGET.OfficeID <> SOURCE.OfficeID
				AND SOURCE.OfficeID IS NOT NULL
				)
			OR (
				TARGET.LocationHierarchyCode <> SOURCE.LocationHierarchyCode
				AND SOURCE.LocationHierarchyCode IS NOT NULL
				)
			OR (
				TARGET.ManagerName <> SOURCE.ManagerName
				AND SOURCE.ManagerName IS NOT NULL
				)
			OR (
				TARGET.ManagerEmployeeNumber <> SOURCE.ManagerEmployeeNumber
				AND SOURCE.ManagerEmployeeNumber IS NOT NULL
				)
			OR (
				TARGET.Company <> SOURCE.Company
				AND SOURCE.Company IS NOT NULL
				)
			OR (
				TARGET.[State] <> SOURCE.[State]
				AND SOURCE.[State] IS NOT NULL
				)
			OR (
				TARGET.PhysicalDeliveryLocation <> SOURCE.PhysicalDeliveryLocation
				AND SOURCE.PhysicalDeliveryLocation IS NOT NULL
				)
			OR (
				TARGET.IsRehire <> SOURCE.IsRehire
				AND SOURCE.IsRehire IS NOT NULL
				)
			OR (
				TARGET.IsRescind <> SOURCE.IsRescind
				AND SOURCE.IsRescind IS NOT NULL
				)
			)
		THEN
			UPDATE
			SET TARGET.WorkdayEmployeeNumber = SOURCE.WorkdayEmployeeNumber
				,TARGET.FirstName = SOURCE.FirstName
				,TARGET.LastName = SOURCE.LastName
				,TARGET.MiddleName = SOURCE.MiddleName
				,TARGET.PreferredName = SOURCE.PreferredName
				,TARGET.PositionTitle = SOURCE.PositionTitle
				,TARGET.BusinessTitle = SOURCE.BusinessTitle
				,TARGET.JobCode = SOURCE.JobCode
				,TARGET.EmployeeType = SOURCE.EmployeeType
				,TARGET.FullOrPartTime = SOURCE.FullOrPartTime
				,TARGET.StartDate = SOURCE.StartDate
				,TARGET.DepartmentName = SOURCE.DepartmentName
				,TARGET.DepartmentID = SOURCE.DepartmentID
				,TARGET.OfficeName = SOURCE.OfficeName
				,TARGET.OfficeID = SOURCE.OfficeID
				,TARGET.LocationHierarchyCode = SOURCE.LocationHierarchyCode
				,TARGET.ManagerName = SOURCE.ManagerName
				,TARGET.ManagerEmployeeNumber = SOURCE.ManagerEmployeeNumber
				,TARGET.Company = SOURCE.Company
				,TARGET.[State] = SOURCE.[State]
				,TARGET.PhysicalDeliveryLocation = SOURCE.PhysicalDeliveryLocation
				,TARGET.IsRehire = SOURCE.IsRehire
				,TARGET.IsRescind = SOURCE.IsRescind
				,TARGET.ModifyDate = GETDATE()
				,TARGET.ModifyBy = SOURCE.UserId
	WHEN NOT MATCHED BY TARGET
		THEN --INSERT THE NEW RECORDS
			INSERT
			VALUES (
				SOURCE.WorkerWorkdayId
				,SOURCE.WorkdayEmployeeNumber
				,SOURCE.SCEmployeeNumber
				,SOURCE.FirstName
				,SOURCE.LastName
				,SOURCE.MiddleName
				,SOURCE.PreferredName
				,SOURCE.ADUserName
				,SOURCE.ADAccountCreateDate
				,SOURCE.PositionTitle
				,SOURCE.BusinessTitle
				,SOURCE.JobCode
				,SOURCE.EmailAddress
				,SOURCE.EmployeeType
				,SOURCE.FullOrPartTime
				,SOURCE.StartDate
				,SOURCE.DepartmentName
				,SOURCE.DepartmentID
				,SOURCE.OfficeName
				,SOURCE.OfficeID
				,SOURCE.ManagerName
				,SOURCE.ManagerEmployeeNumber
				,SOURCE.Company
				,SOURCE.[State]
				,SOURCE.PhysicalDeliveryLocation
				,SOURCE.IsRehire
				,SOURCE.IsRescind
				,SOURCE.IsADCreated
				,SOURCE.ADLoggedInDate
				,SOURCE.WorkdayUpdateStatus
				,SOURCE.ADAccountCreateDate
				,SOURCE.isActive
				,SOURCE.UserId
				,GETDATE()
				,SOURCE.UserId
				,GETDATE()
				,SOURCE.LocationHierarchyCode
				,SOURCE.isContractorConversion
				);
END