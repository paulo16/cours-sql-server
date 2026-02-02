-- 1. Création d'une nouvelle base de données
CREATE DATABASE MaPremiereBase;
GO

-- 2. On se place dans cette base
USE MaPremiereBase;
GO

-- 3. Création d'une table "Utilisateurs"
CREATE TABLE Utilisateurs (
    Id INT IDENTITY(1,1) PRIMARY KEY,
    Nom NVARCHAR(50),
    Email NVARCHAR(100),
    DateInscription DATETIME DEFAULT GETDATE()
);
GO

-- 4. Insertion de données
INSERT INTO Utilisateurs (Nom, Email)
VALUES 
('Alice', 'alice@example.com'),
('Bob', 'bob@example.com'),
('Charlie', 'charlie@example.com');
GO

-- 5. Lecture des données
SELECT * FROM Utilisateurs;
GO
