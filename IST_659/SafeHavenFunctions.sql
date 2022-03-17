DROP FUNCTION IF EXISTS dbo.fGetJobIDFromJobName
DROP FUNCTION IF EXISTS dbo.fGetShelterIDFromShelterName
DROP FUNCTION IF EXISTS dbo.fCheckShelterAvailability
DROP FUNCTION IF EXISTS dbo.fGetItemIDFromItemName
DROP FUNCTION IF EXISTS dbo.fGetPersonID

GO


/*

	Create all functions.

*/
-- Gets a JobID when the JobName is known.
CREATE  OR ALTER FUNCTION dbo.fGetJobIDFromJobName (@JobName varchar(40))
RETURNS int AS
BEGIN
	-- Declare variable to hold the result
	DECLARE @ReturnValue int
	
	-- Select the JobID from the JobName.
	SELECT @ReturnValue = JobID FROM JobList WHERE JobName = @JobName

	-- Return the JobID.
	RETURN @ReturnValue
END;
GO

-- Gets an ItemID when the ItemName is known.
CREATE  OR ALTER FUNCTION dbo.fGetItemIDFromItemName (@ItemName varchar(50))
RETURNS int AS
BEGIN
	-- Declare variable to hold the result
	DECLARE @ReturnValue int
	
	-- Select the ItemID from the ItemName.
	SELECT @ReturnValue = ItemID FROM ItemList WHERE ItemName = @ItemName

	-- Return the ItemID.
	RETURN @ReturnValue
END;
GO


-- Gets a ShelterID when the ShelterName is known.
CREATE  OR ALTER FUNCTION dbo.fGetShelterIDFromShelterName (@ShelterName varchar(40))
RETURNS int AS
BEGIN
	-- Declare variable to hold the result.
	DECLARE @ReturnValue int
	
	-- Select the ShelterID from the ShelterName.
	SELECT @ReturnValue = ShelterID FROM ShelterLocation WHERE ShelterName = @ShelterName

	-- Return the ShelterID.
	RETURN @ReturnValue
END;
GO


-- Gets a PersonID with a first and last name.
CREATE  OR ALTER FUNCTION dbo.fGetPersonID (@PersonEmail varchar(255))
RETURNS int AS
BEGIN
	-- Declare variable to hold the result.
	DECLARE @ReturnValue int
	
	-- Select the PersonID from the PersonEmail.
	SELECT @ReturnValue = PersonID FROM PersonnelList WHERE PersonEmail = @PersonEmail

	-- Return the PersonID.
	RETURN @ReturnValue
END;
GO

-- Check shelter capacity and availability before adding a cat.
CREATE  OR ALTER FUNCTION dbo.fCheckShelterAvailability (@ShelterName varchar(255))
RETURNS int AS
BEGIN
	-- Declare variable to hold the result.
	DECLARE @ReturnValue int
	-- Finds the number of cats in the shelter by ShelterLocation and subtracts that from the ShelterLocation capacity.
	SELECT @ReturnValue = (SELECT SUM(ShelterCapacity) FROM ShelterLocation WHERE ShelterName = @ShelterName) - (SELECT COUNT(ShelterID) FROM CatList WHERE ShelterID = dbo.fGetShelterIDFromShelterName(@ShelterName))
	-- Return the ShelterID.
	RETURN @ReturnValue
END;
GO