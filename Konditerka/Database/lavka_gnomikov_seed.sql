/*
  База данных для программы "Лавка гномиков"
  Создаёт БД, 16 таблиц и заполняет тестовыми данными.
*/
IF DB_ID(N'LavkaGnomikov') IS NULL
BEGIN
    CREATE DATABASE LavkaGnomikov;
END
GO

USE LavkaGnomikov;
GO

-- Удаление таблиц при повторном запуске
IF OBJECT_ID(N'dbo.Payments', N'U') IS NOT NULL DROP TABLE dbo.Payments;
IF OBJECT_ID(N'dbo.Shipments', N'U') IS NOT NULL DROP TABLE dbo.Shipments;
IF OBJECT_ID(N'dbo.Reviews', N'U') IS NOT NULL DROP TABLE dbo.Reviews;
IF OBJECT_ID(N'dbo.GnomeCollections', N'U') IS NOT NULL DROP TABLE dbo.GnomeCollections;
IF OBJECT_ID(N'dbo.Materials', N'U') IS NOT NULL DROP TABLE dbo.Materials;
IF OBJECT_ID(N'dbo.Suppliers', N'U') IS NOT NULL DROP TABLE dbo.Suppliers;
IF OBJECT_ID(N'dbo.OrdersCatalogs', N'U') IS NOT NULL DROP TABLE dbo.OrdersCatalogs;
IF OBJECT_ID(N'dbo.Orders', N'U') IS NOT NULL DROP TABLE dbo.Orders;
IF OBJECT_ID(N'dbo.StatusOrders', N'U') IS NOT NULL DROP TABLE dbo.StatusOrders;
IF OBJECT_ID(N'dbo.BasketsCatalogs', N'U') IS NOT NULL DROP TABLE dbo.BasketsCatalogs;
IF OBJECT_ID(N'dbo.Baskets', N'U') IS NOT NULL DROP TABLE dbo.Baskets;
IF OBJECT_ID(N'dbo.Catalogs', N'U') IS NOT NULL DROP TABLE dbo.Catalogs;
IF OBJECT_ID(N'dbo.Categories', N'U') IS NOT NULL DROP TABLE dbo.Categories;
IF OBJECT_ID(N'dbo.Users', N'U') IS NOT NULL DROP TABLE dbo.Users;
IF OBJECT_ID(N'dbo.Cities', N'U') IS NOT NULL DROP TABLE dbo.Cities;
IF OBJECT_ID(N'dbo.Roles', N'U') IS NOT NULL DROP TABLE dbo.Roles;
GO

CREATE TABLE Roles (
    IdRole INT IDENTITY(1,1) PRIMARY KEY,
    NameRole NVARCHAR(100) NOT NULL
);

CREATE TABLE Cities (
    IdCity INT IDENTITY(1,1) PRIMARY KEY,
    NameCity NVARCHAR(120) NOT NULL
);

CREATE TABLE Users (
    IdUser INT IDENTITY(1,1) PRIMARY KEY,
    NameUser NVARCHAR(120) NOT NULL,
    Password NVARCHAR(255) NOT NULL,
    Email NVARCHAR(200) NOT NULL,
    IdRole INT NOT NULL,
    IdCity INT NOT NULL,
    CONSTRAINT FK_Users_Roles FOREIGN KEY (IdRole) REFERENCES Roles(IdRole),
    CONSTRAINT FK_Users_Cities FOREIGN KEY (IdCity) REFERENCES Cities(IdCity)
);

CREATE TABLE Categories (
    IdCategory INT IDENTITY(1,1) PRIMARY KEY,
    NameCategory NVARCHAR(120) NOT NULL
);

CREATE TABLE Catalogs (
    IdCatalog INT IDENTITY(1,1) PRIMARY KEY,
    Product NVARCHAR(200) NOT NULL,
    Descripton NVARCHAR(1000) NOT NULL,
    Price DECIMAL(10,2) NOT NULL,
    PhotoPath NVARCHAR(260) NULL,
    IdCategory INT NOT NULL,
    CONSTRAINT FK_Catalogs_Categories FOREIGN KEY (IdCategory) REFERENCES Categories(IdCategory)
);

CREATE TABLE Baskets (
    IdBasket INT IDENTITY(1,1) PRIMARY KEY,
    IdUser INT NOT NULL,
    CreatedAt DATETIME NOT NULL DEFAULT(GETDATE()),
    IsOrdered BIT NOT NULL DEFAULT(0),
    TotalPrice DECIMAL(10,2) NULL,
    CONSTRAINT FK_Baskets_Users FOREIGN KEY (IdUser) REFERENCES Users(IdUser)
);

CREATE TABLE BasketsCatalogs (
    IdBasketCatalog INT IDENTITY(1,1) PRIMARY KEY,
    IdBasket INT NOT NULL,
    IdCatalog INT NOT NULL,
    Quantity INT NOT NULL DEFAULT(1),
    CONSTRAINT FK_BasketsCatalogs_Baskets FOREIGN KEY (IdBasket) REFERENCES Baskets(IdBasket),
    CONSTRAINT FK_BasketsCatalogs_Catalogs FOREIGN KEY (IdCatalog) REFERENCES Catalogs(IdCatalog)
);

CREATE TABLE StatusOrders (
    IdStatusOrder INT IDENTITY(1,1) PRIMARY KEY,
    NameStatusOrder NVARCHAR(100) NOT NULL
);

CREATE TABLE Orders (
    IdOrder INT IDENTITY(1,1) PRIMARY KEY,
    IdUser INT NOT NULL,
    Data DATETIME NOT NULL,
    Price DECIMAL(10,2) NOT NULL,
    IdStatusOrder INT NOT NULL,
    CONSTRAINT FK_Orders_Users FOREIGN KEY (IdUser) REFERENCES Users(IdUser),
    CONSTRAINT FK_Orders_StatusOrders FOREIGN KEY (IdStatusOrder) REFERENCES StatusOrders(IdStatusOrder)
);

CREATE TABLE OrdersCatalogs (
    IdOrderCatalog INT IDENTITY(1,1) PRIMARY KEY,
    IdOrder INT NOT NULL,
    IdCatalog INT NOT NULL,
    Quantity INT NOT NULL,
    CONSTRAINT FK_OrdersCatalogs_Orders FOREIGN KEY (IdOrder) REFERENCES Orders(IdOrder),
    CONSTRAINT FK_OrdersCatalogs_Catalogs FOREIGN KEY (IdCatalog) REFERENCES Catalogs(IdCatalog)
);

-- Дополнительные таблицы
CREATE TABLE Suppliers (
    IdSupplier INT IDENTITY(1,1) PRIMARY KEY,
    SupplierName NVARCHAR(200) NOT NULL,
    ContactPhone NVARCHAR(30) NULL,
    ContactEmail NVARCHAR(200) NULL
);

CREATE TABLE Materials (
    IdMaterial INT IDENTITY(1,1) PRIMARY KEY,
    MaterialName NVARCHAR(120) NOT NULL,
    Unit NVARCHAR(20) NOT NULL,
    InStock DECIMAL(10,2) NOT NULL DEFAULT(0)
);

CREATE TABLE GnomeCollections (
    IdCollection INT IDENTITY(1,1) PRIMARY KEY,
    CollectionName NVARCHAR(120) NOT NULL,
    SeasonYear NVARCHAR(20) NOT NULL
);

CREATE TABLE Reviews (
    IdReview INT IDENTITY(1,1) PRIMARY KEY,
    IdUser INT NOT NULL,
    IdCatalog INT NOT NULL,
    Rating INT NOT NULL CHECK (Rating BETWEEN 1 AND 5),
    ReviewText NVARCHAR(1000) NULL,
    CreatedAt DATETIME NOT NULL DEFAULT(GETDATE()),
    CONSTRAINT FK_Reviews_Users FOREIGN KEY (IdUser) REFERENCES Users(IdUser),
    CONSTRAINT FK_Reviews_Catalogs FOREIGN KEY (IdCatalog) REFERENCES Catalogs(IdCatalog)
);

CREATE TABLE Shipments (
    IdShipment INT IDENTITY(1,1) PRIMARY KEY,
    IdOrder INT NOT NULL,
    ShipmentAddress NVARCHAR(300) NOT NULL,
    ShipmentDate DATETIME NULL,
    DeliveryStatus NVARCHAR(100) NOT NULL,
    CONSTRAINT FK_Shipments_Orders FOREIGN KEY (IdOrder) REFERENCES Orders(IdOrder)
);

CREATE TABLE Payments (
    IdPayment INT IDENTITY(1,1) PRIMARY KEY,
    IdOrder INT NOT NULL,
    PaymentDate DATETIME NOT NULL DEFAULT(GETDATE()),
    Amount DECIMAL(10,2) NOT NULL,
    PaymentMethod NVARCHAR(50) NOT NULL,
    IsPaid BIT NOT NULL DEFAULT(0),
    CONSTRAINT FK_Payments_Orders FOREIGN KEY (IdOrder) REFERENCES Orders(IdOrder)
);
GO

INSERT INTO Roles (NameRole) VALUES
(N'Администратор'),(N'Менеджер'),(N'Покупатель');

INSERT INTO Cities (NameCity) VALUES
(N'Москва'),(N'Санкт-Петербург'),(N'Казань'),(N'Екатеринбург'),(N'Новосибирск');

INSERT INTO Users (NameUser, Password, Email, IdRole, IdCity) VALUES
(N'admin', N'admin123', N'admin@gnomiki.ru', 1, 1),
(N'gnomefan', N'123456', N'fan@gnomiki.ru', 3, 2),
(N'manager1', N'manager123', N'manager@gnomiki.ru', 2, 3);

INSERT INTO Categories (NameCategory) VALUES
(N'Садовые гномики'),(N'Интерьерные гномики'),(N'Праздничные гномики'),(N'Коллекционные гномики');

INSERT INTO Catalogs (Product, Descripton, Price, PhotoPath, IdCategory) VALUES
(N'Гном-рыбак', N'Гномик с удочкой для декора сада.', 3490.00, N'gnom-fisher.png', 1),
(N'Гном с фонарем', N'Вечерний гномик с фонариком.', 4290.00, N'gnom-lamp.png', 1),
(N'Сканди-гном', N'Мягкий интерьерный гном в сканди-стиле.', 2190.00, N'scandi-gnom.png', 2),
(N'Новогодний гном', N'Праздничный гном в красном колпаке.', 1990.00, N'ny-gnom.png', 3),
(N'Гном-алхимик', N'Коллекционная фигурка ручной росписи.', 7990.00, N'alchemist-gnom.png', 4);

INSERT INTO Baskets (IdUser, IsOrdered, TotalPrice) VALUES
(2, 0, 0),
(3, 1, 5680.00);

INSERT INTO BasketsCatalogs (IdBasket, IdCatalog, Quantity) VALUES
(1, 1, 1),
(1, 4, 2),
(2, 3, 1),
(2, 4, 1);

INSERT INTO StatusOrders (NameStatusOrder) VALUES
(N'Новый'),(N'Подтвержден'),(N'Передан в доставку'),(N'Доставлен'),(N'Отменен');

INSERT INTO Orders (IdUser, Data, Price, IdStatusOrder) VALUES
(2, GETDATE(), 5680.00, 2),
(3, DATEADD(day, -1, GETDATE()), 2190.00, 4);

INSERT INTO OrdersCatalogs (IdOrder, IdCatalog, Quantity) VALUES
(1, 3, 1),
(1, 4, 1),
(2, 3, 1);

INSERT INTO Suppliers (SupplierName, ContactPhone, ContactEmail) VALUES
(N'Мастерская Север', N'+7-999-111-22-33', N'info@sever-gnom.ru'),
(N'Гном-Декор', N'+7-999-444-55-66', N'hello@gnomdecor.ru');

INSERT INTO Materials (MaterialName, Unit, InStock) VALUES
(N'Полистоун', N'кг', 120.5),
(N'Краска акриловая', N'л', 45.0),
(N'Лак защитный', N'л', 30.0);

INSERT INTO GnomeCollections (CollectionName, SeasonYear) VALUES
(N'Лесная серия', N'2026'),
(N'Рождественская серия', N'2026');

INSERT INTO Reviews (IdUser, IdCatalog, Rating, ReviewText) VALUES
(2, 1, 5, N'Очень качественная фигурка, отлично смотрится в саду.'),
(2, 4, 4, N'Красивый гномик, но коробка была чуть помята.');

INSERT INTO Shipments (IdOrder, ShipmentAddress, ShipmentDate, DeliveryStatus) VALUES
(1, N'Москва, ул. Гномья, д. 7', DATEADD(day, 1, GETDATE()), N'Запланирована'),
(2, N'Казань, пр-т Сказочный, д. 12', DATEADD(day, -1, GETDATE()), N'Доставлена');

INSERT INTO Payments (IdOrder, Amount, PaymentMethod, IsPaid) VALUES
(1, 5680.00, N'Банковская карта', 1),
(2, 2190.00, N'СБП', 1);
GO
