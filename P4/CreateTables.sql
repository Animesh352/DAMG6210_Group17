CREATE DATABASE VehicleResale_DBMS
USE VehicleResale_DBMS
GO

CREATE TABLE Address (
    AddressID INT PRIMARY KEY  IDENTITY(1,1),
    Street VARCHAR(255),
    City VARCHAR(255),
    State VARCHAR(255),
    ZipCode CHAR(5)
);

CREATE TABLE Model (
    ModelID INT PRIMARY KEY IDENTITY(1,1),
    CarMake VARCHAR(255),
    CarModel VARCHAR(255)
);

CREATE TABLE Supplier (
    SupplierID INT PRIMARY KEY IDENTITY(1,1),
    FirstName VARCHAR(255),
    LastName VARCHAR(255),
    ContactNumber CHAR(10),
    AddressID INT,
    CONSTRAINT Supplier_FK FOREIGN KEY (AddressID) REFERENCES Address(AddressID)
);

CREATE TABLE Dealer (
    DealerID INT PRIMARY KEY IDENTITY(1,1),
    DealershipName VARCHAR(255),
    AddressID INT,
    CONSTRAINT Dealer_FK FOREIGN KEY (AddressID) REFERENCES Address(AddressID)
);

CREATE TABLE Car (
    VIN VARCHAR(17) PRIMARY KEY,
    LicensePlate VARCHAR(10),
    ModelID INT,
    TransmissionType VARCHAR(50),
    Colour VARCHAR(50),
    YearOfManufacturing INT,
    EngineDisplacement VARCHAR(50),
    OriginalPrice DECIMAL(10,2),
    OdometerReading INT,
    EngineType VARCHAR(50),
    BodyType VARCHAR(50),
    CONSTRAINT Car_FK FOREIGN KEY (ModelID) REFERENCES Model(ModelID)
);

CREATE TABLE Customer (
    CustomerID INT PRIMARY KEY IDENTITY(1000,1),
    FirstName VARCHAR(255),
    LastName VARCHAR(255),
    ContactNumber NUMERIC(10,0),
    AddressID INT,
    TakesLoan VARCHAR(10) NOT NULL,
    CONSTRAINT Customer_FK FOREIGN KEY (AddressID) REFERENCES Address(AddressID),
    CONSTRAINT CHK_ContactNumber CHECK (ContactNumber >= 1000000000 AND ContactNumber <= 9999999999),
    CONSTRAINT CHK_TakesLoan CHECK (TakesLoan in ('yes', 'no'))
);

CREATE TABLE Financer (
    FinancerID INT PRIMARY KEY NOT NULL,
    FinancerName VARCHAR(255),
    AddressID INT,
    CONSTRAINT Financer_FK FOREIGN KEY (AddressID) REFERENCES Address(AddressID)
);

CREATE TABLE Loan (
    LoanID INT PRIMARY KEY NOT NULL,
    LoanAmount DECIMAL(10,2),
    CustomerID INT,
    FinancerID INT,
    CONSTRAINT Loan_FK1 FOREIGN KEY (CustomerID) REFERENCES Customer(CustomerID),
    CONSTRAINT Loan_FK2 FOREIGN KEY (FinancerID) REFERENCES Financer(FinancerID)
);


CREATE TABLE [Transaction] (
    TransactionID INT IDENTITY(1000000000,1) PRIMARY KEY ,
    TransactionDate DATE,
    TransactionTime TIME,
    TransactionAmount DECIMAL(10,2),
    SupplierID INT,
    DealerID INT,
    VIN VARCHAR(17),
    CONSTRAINT Transaction_FK1 FOREIGN KEY (SupplierID) REFERENCES Supplier(SupplierID),
    CONSTRAINT Transaction_FK2 FOREIGN KEY (DealerID) REFERENCES Dealer(DealerID),
    CONSTRAINT Transaction_FK3 FOREIGN KEY (VIN) REFERENCES Car(VIN)
);

CREATE TABLE CustomerTransaction (
    CTransactionID INT PRIMARY KEY IDENTITY(1000000000,1),
    CTransactionDate DATE,
    CTransactionTime TIME,
    CTransactionAmount DECIMAL(10,2),
    CustomerID INT,
    DealerID INT,
    VIN VARCHAR(17),
    CONSTRAINT CTransaction_FK1 FOREIGN KEY (CustomerID) REFERENCES Customer(CustomerID),
    CONSTRAINT CTransaction_FK2 FOREIGN KEY (DealerID) REFERENCES Dealer(DealerID),
    CONSTRAINT CTransaction_FK3 FOREIGN KEY (VIN) REFERENCES Car(VIN)
);

CREATE TABLE CarWithDealer (
    VIN VARCHAR(17),
    DealerID INT,
    TransactionID INT,
    LotNumber INT,
    CONSTRAINT CarWithDealer_FK1 FOREIGN KEY (VIN) REFERENCES Car(VIN),
    CONSTRAINT CarWithDealer_FK2 FOREIGN KEY (DealerID) REFERENCES Dealer(DealerID),
    CONSTRAINT CarWithDealer_FK3 FOREIGN KEY (TransactionID) REFERENCES [Transaction](TransactionID),
    CONSTRAINT CarWithDealer_PK PRIMARY KEY (VIN, DealerID)
);

CREATE TABLE SalesRepresentative (
    SalesRepID INT PRIMARY KEY NOT NULL,
    FirstName VARCHAR(50),
    LastName VARCHAR(50),
    ContactNumber NUMERIC(10,0),
    DealerID INT,
    CONSTRAINT SalesRepresentative_FK FOREIGN KEY (DealerID) REFERENCES Dealer(DealerID),
    CONSTRAINT CHK2_ContactNumber CHECK (ContactNumber >= 1000000000 AND ContactNumber <= 9999999999)
);

CREATE TABLE Request (
    RequestID INT PRIMARY KEY IDENTITY(1,1),
    DateofRequest DATE,
    ModelID INT,
    SalesRepID INT,
    CustomerID INT,
    RequestCompleted VARCHAR(10) NOT NULL CHECK (RequestCompleted in ('yes', 'no')),
    CONSTRAINT Request_FK1 FOREIGN KEY (ModelID) REFERENCES Model(ModelID),
    CONSTRAINT Request_FK2 FOREIGN KEY (SalesRepID) REFERENCES SalesRepresentative(SalesRepID),
    CONSTRAINT Request_FK3 FOREIGN KEY (CustomerID) REFERENCES Customer(CustomerID)
);

CREATE TABLE Refurbisher (
    RefurbisherID INT PRIMARY KEY NOT NULL,
    RefurbisherName VARCHAR(255),
    AddressID INT,
    CONSTRAINT Refurbisher_FK FOREIGN KEY (AddressID) REFERENCES Address(AddressID)
);

CREATE TABLE Inspection (
    InspectionNumber INT PRIMARY KEY IDENTITY(1,1),
    VIN VARCHAR(17),
    DealerID INT,
    InspectorName VARCHAR(255),
    InspectionDate DATE,
    InspectionResult VARCHAR(10) NOT NULL,
    CONSTRAINT Inspection_FK1 FOREIGN KEY (VIN) REFERENCES Car(VIN),
    CONSTRAINT Inspection_FK2 FOREIGN KEY (DealerID) REFERENCES Dealer(DealerID),
    CONSTRAINT CHK_InspectionResult CHECK (InspectionResult in ('pass', 'fail'))
);

CREATE TABLE Refurbishment (
    RefurbishmentNumber INT PRIMARY KEY IDENTITY(1,1), 
    InspectionNumber INT,
    CarCondition VARCHAR(255),
    DateReceived DATE,
    DateCompleted DATE,
    RefurbisherID INT,
    CarStatus VARCHAR(255),
    CONSTRAINT Refurbishment_FK1 FOREIGN KEY (InspectionNumber) REFERENCES Inspection(InspectionNumber),
    CONSTRAINT Refurbishment_FK2 FOREIGN KEY (RefurbisherID) REFERENCES Refurbisher(RefurbisherID)
);