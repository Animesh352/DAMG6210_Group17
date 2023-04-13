USE VehicleResale_DBMS
GO

------VIEWS-------

CREATE VIEW CustomerTransactionCount28 AS
SELECT c.FirstName, c.LastName, c.ContactNumber, COUNT(*) AS TransactionCount
FROM Customer c
JOIN CustomerTransaction ct ON c.CustomerID = ct.CustomerID
GROUP BY c.FirstName, c.LastName, c.ContactNumber;
GO



CREATE VIEW CarDealerInfo2 AS
SELECT cd.VIN, cd.LotNumber, cd.DealerID
FROM CarWithDealer cd
JOIN CarWithDealer di ON cd.DealerID = di.DealerID;
GO


CREATE VIEW TopTenCars AS
SELECT TOP 10 Car.OriginalPrice, Car.ModelID, Model.CarMake, Model.CarModel
FROM Car JOIN Model ON Car.ModelID = Model.ModelID
ORDER BY OriginalPrice DESC;
GO



-----TRIGGER------
CREATE TRIGGER CustomerAdded
ON Customer
AFTER INSERT
AS
BEGIN
    PRINT 'A new customer has been added.'
END
GO


------STORED PROCEDURES------
--1--Procedure to Create a new inspection 
CREATE PROCEDURE InspectCar @vin VARCHAR(17), @dealerid INT, @inspectorname VARCHAR(255), @result VARCHAR(10)
AS
BEGIN
	INSERT INTO Inspection (VIN, DealerID, InspectorName, InspectionDate, InspectionResult)
    VALUES (@vin, @dealerid, @inspectorname, CONVERT(date, GETDATE()), @result)
    
END
GO

--2--Procedure to buy a new car for dealer, add the car in CarWithDealer and use the InspectCar procedure to make an inspection
CREATE PROCEDURE dbo.AutoBuy @amount DECIMAL(10,2), @supplier INT, @dealerid INT, @vin VARCHAR(17), @lotnumber INT, 
@inspectorname VARCHAR(255), @inspectresult VARCHAR(10)
AS
BEGIN
	INSERT INTO [Transaction](TransactionDate, TransactionTime, TransactionAmount, SupplierID, DealerID, VIN)
		VALUES(CONVERT(date, GETDATE()), CONVERT(time, GETDATE()), @amount, @supplier, @dealerid, @vin);
    DECLARE @transactionid INT;
    SET @transactionid = SCOPE_IDENTITY();
    INSERT INTO [CarWithDealer](VIN, DealerID, TransactionID, LotNumber)
        VALUES(@vin, @dealerid, @transactionid, @lotnumber);
    EXEC InspectCar @vin, @dealerid, @inspectorname, @inspectresult
END
GO



--3--Procedure to sell a car to customer and delete car from CarWithDealer
CREATE PROCEDURE dbo.SellCar @amount DECIMAL(10,2), @customerid INT, @dealerid INT, @vin VARCHAR(17)
AS
BEGIN
	INSERT INTO [CustomerTransaction](CTransactionDate,CTransactionTime, CTransactionAmount, CustomerID, DealerID, VIN)
		VALUES (CONVERT(date, GETDATE()),CONVERT(time, GETDATE()), @amount, @customerid, @dealerid, @vin);
    DELETE FROM  [CarWithDealer] WHERE CarWithDealer.VIN = @vin
        
END


--------INDEXES-----------
CREATE NONCLUSTERED INDEX IDX_SalesRepIDInRequest ON dbo.Request(SalesRepID);
CREATE NONCLUSTERED INDEX IDX_CustomerLoan ON dbo.Loan (CustomerID);
CREATE NONCLUSTERED INDEX IDX_CarYearReading  ON dbo.Car (YearOfManufacturing DESC, OdometerReading ASC);

--------DATA ENCRYPTION----------Encrypt Customer Phone number
CREATE MASTER KEY
ENCRYPTION BY PASSWORD='CustPhone123';


SELECT NAME KeyName,
    symmetric_key_id KeyID,
    key_length KeyLength,
    algorithm_desc KeyAlgorithm
FROM sys.symmetric_keys;


GO
CREATE CERTIFICATE CustomerPass
WITH SUBJECT = 'Customer Password'



GO
SELECT NAME CertName,
    certificate_id CertID,
    pvt_key_encryption_type_desc EncryptType,
    issuer_name Issuer
FROM sys.certificates;


CREATE SYMMETRIC KEY SymmetricKey WITH ALGORITHM = AES_256 ENCRYPTION BY CERTIFICATE CustomerPass;


SELECT NAME KeyName,
    symmetric_key_id KeyID,
    key_length KeyLength,
    algorithm_desc KeyAlgorithm
FROM sys.symmetric_keys;



ALTER TABLE Customer
ADD number_encrypt VARBINARY(MAX)


OPEN SYMMETRIC KEY SymmetricKey
DECRYPTION BY CERTIFICATE CustomerPass;

UPDATE Customer
SET number_encrypt = ENCRYPTBYKEY(KEY_GUID('SymmetricKey'), CAST(ContactNumber AS VARCHAR(10)))
FROM Customer;
GO



CLOSE SYMMETRIC KEY SymmetricKey;
GO

----VIEW FOR HIDING UNENCRYPTED DATA COLUMN-------
CREATE VIEW CustomerTable AS
SELECT c.CustomerID, c.FirstName, c.LastName, c.AddressID, c.TakesLoan, c.number_encrypt
FROM Customer c
GO




-------------UDF---------------To get the EMI Amount for given LoanID, Interest rate and Term

CREATE FUNCTION dbo.PrintLoanAndEMI (@loanid INT, @interest_rate DECIMAL(10,2), @term INT)
RETURNS TABLE
AS
RETURN
(
    SELECT L.LoanID,
        L.LoanAmount AS LoanAmount,
        (L.LoanAmount * (@interest_rate/1200) * POWER((1+(@interest_rate/1200)), @term)) / (POWER((1+(@interest_rate/1200)), @term) - 1) AS EMIAmount
    FROM Loan L
    WHERE L.LoanID = @loanid
)
GO
