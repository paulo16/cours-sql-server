-- ============================================================
-- SGBD2 - Donnees de test (Mois 2)
-- Notions cibles : operateurs ensemblistes, variables, IF, WHILE
-- Limite respectee : max 12 lignes par table
-- ============================================================

IF NOT EXISTS (SELECT 1
FROM sys.databases
WHERE name = 'SGBD2_M2_EXOS')
BEGIN
    CREATE DATABASE SGBD2_M2_EXOS;
END
GO

USE SGBD2_M2_EXOS;
GO

-- Nettoyage (ordre des dependances)
IF OBJECT_ID('Commande', 'U') IS NOT NULL DROP TABLE Commande;
IF OBJECT_ID('Produit', 'U') IS NOT NULL DROP TABLE Produit;
IF OBJECT_ID('Employe', 'U') IS NOT NULL DROP TABLE Employe;
IF OBJECT_ID('Fournisseur', 'U') IS NOT NULL DROP TABLE Fournisseur;
IF OBJECT_ID('Client', 'U') IS NOT NULL DROP TABLE Client;
GO

CREATE TABLE Client
(
    id_client INT IDENTITY(1,1) PRIMARY KEY,
    nom NVARCHAR(80) NOT NULL,
    prenom NVARCHAR(80) NOT NULL,
    ville NVARCHAR(60) NOT NULL,
    email NVARCHAR(120) NOT NULL UNIQUE,
    actif BIT NOT NULL DEFAULT 1
);

CREATE TABLE Employe
(
    id_employe INT IDENTITY(1,1) PRIMARY KEY,
    nom NVARCHAR(80) NOT NULL,
    prenom NVARCHAR(80) NOT NULL,
    ville NVARCHAR(60) NOT NULL,
    email NVARCHAR(120) NOT NULL UNIQUE,
    departement NVARCHAR(60) NOT NULL
);

CREATE TABLE Fournisseur
(
    id_fournisseur INT IDENTITY(1,1) PRIMARY KEY,
    raison_sociale NVARCHAR(120) NOT NULL,
    ville NVARCHAR(60) NOT NULL,
    email NVARCHAR(120) NOT NULL UNIQUE
);

CREATE TABLE Produit
(
    id_produit INT IDENTITY(1,1) PRIMARY KEY,
    designation NVARCHAR(120) NOT NULL,
    prix DECIMAL(10,2) NOT NULL,
    stock INT NOT NULL CHECK (stock >= 0)
);

CREATE TABLE Commande
(
    id_commande INT IDENTITY(1,1) PRIMARY KEY,
    id_client INT NOT NULL,
    date_com DATE NOT NULL,
    montant_total DECIMAL(10,2) NOT NULL CHECK (montant_total >= 0),
    statut NVARCHAR(20) NOT NULL CHECK (statut IN ('NOUVELLE','LIVREE','ANNULEE')),
    CONSTRAINT FK_Commande_Client FOREIGN KEY (id_client) REFERENCES Client(id_client)
);
GO

-- 12 clients max
INSERT INTO Client
    (nom, prenom, ville, email, actif)
VALUES
    ('El Idrissi', 'Nora', 'Casablanca', 'nora.elidrissi@mail.ma', 1),
    ('Alaoui', 'Mehdi', 'Rabat', 'mehdi.alaoui@mail.ma', 1),
    ('Bennani', 'Salma', 'Marrakech', 'salma.bennani@mail.ma', 1),
    ('Amrani', 'Youssef', 'Fes', 'youssef.amrani@mail.ma', 1),
    ('Tazi', 'Imane', 'Agadir', 'imane.tazi@mail.ma', 1),
    ('Cherkaoui', 'Reda', 'Tangier', 'reda.cherkaoui@mail.ma', 1),
    ('Ouardi', 'Sanae', 'Meknes', 'sanae.ouardi@mail.ma', 1),
    ('Hakimi', 'Karim', 'Casablanca', 'karim.hakimi@mail.ma', 0),
    ('Mansouri', 'Aya', 'Rabat', 'aya.mansouri@mail.ma', 1),
    ('Jabri', 'Hamza', 'Oujda', 'hamza.jabri@mail.ma', 1),
    ('Naciri', 'Lina', 'Kenitra', 'lina.naciri@mail.ma', 1),
    ('Rami', 'Adil', 'Tetouan', 'adil.rami@mail.ma', 1);

-- 10 employes max
INSERT INTO Employe
    (nom, prenom, ville, email, departement)
VALUES
    ('Alaoui', 'Mehdi', 'Rabat', 'mehdi.alaoui@mail.ma', 'IT'),
    ('Saidi', 'Mouna', 'Casablanca', 'mouna.saidi@entreprise.ma', 'Finance'),
    ('Kabbaj', 'Younes', 'Fes', 'younes.kabbaj@entreprise.ma', 'IT'),
    ('Bennani', 'Salma', 'Marrakech', 'salma.bennani@mail.ma', 'Support'),
    ('El Fassi', 'Rachid', 'Rabat', 'rachid.elfassi@entreprise.ma', 'RH'),
    ('Bouzidi', 'Nabil', 'Agadir', 'nabil.bouzidi@entreprise.ma', 'Commercial'),
    ('Ait Lahcen', 'Sara', 'Tangier', 'sara.aitlahcen@entreprise.ma', 'IT'),
    ('Jamal', 'Yasmina', 'Meknes', 'yasmina.jamal@entreprise.ma', 'Logistique'),
    ('Filali', 'Omar', 'Casablanca', 'omar.filali@entreprise.ma', 'RH'),
    ('Khalfi', 'Loubna', 'Kenitra', 'loubna.khalfi@entreprise.ma', 'Support');

-- 8 fournisseurs max
INSERT INTO Fournisseur
    (raison_sociale, ville, email)
VALUES
    ('Atlas Tech', 'Casablanca', 'contact@atlast.com'),
    ('Sahara Distrib', 'Rabat', 'vente@saharadist.ma'),
    ('Nord Electro', 'Tangier', 'info@nord-electro.ma'),
    ('Fes Services', 'Fes', 'contact@fesservices.ma'),
    ('Marrakech Supply', 'Marrakech', 'sales@marrakechsupply.ma'),
    ('Agadir Market', 'Agadir', 'contact@agadirmarket.ma'),
    ('Oriental Pro', 'Oujda', 'service@orientalpro.ma'),
    ('Casa Office', 'Casablanca', 'support@casaoffice.ma');

-- 12 produits max
INSERT INTO Produit
    (designation, prix, stock)
VALUES
    ('Clavier mecanique', 399.00, 12),
    ('Souris sans fil', 179.00, 4),
    ('Ecran 24 pouces', 1299.00, 7),
    ('Webcam HD', 299.00, 2),
    ('Casque audio', 459.00, 0),
    ('Disque SSD 1To', 899.00, 5),
    ('Routeur WiFi 6', 749.00, 9),
    ('Imprimante laser', 1899.00, 1),
    ('Cable HDMI', 89.00, 20),
    ('Cle USB 64Go', 129.00, 3),
    ('Tablette graphique', 1599.00, 6),
    ('Micro USB', 149.00, 2);

-- 12 commandes max
INSERT INTO Commande
    (id_client, date_com, montant_total, statut)
VALUES
    (1, '2026-02-01', 1250.00, 'LIVREE'),
    (2, '2026-02-02', 399.00, 'LIVREE'),
    (2, '2026-02-10', 269.00, 'NOUVELLE'),
    (3, '2026-02-05', 1780.00, 'LIVREE'),
    (4, '2026-02-06', 299.00, 'ANNULEE'),
    (5, '2026-02-07', 899.00, 'LIVREE'),
    (6, '2026-02-08', 179.00, 'LIVREE'),
    (8, '2026-02-09', 459.00, 'NOUVELLE'),
    (8, '2026-02-11', 149.00, 'LIVREE'),
    (9, '2026-02-12', 749.00, 'LIVREE'),
    (11, '2026-02-13', 1299.00, 'LIVREE'),
    (11, '2026-02-14', 89.00, 'NOUVELLE');
GO

-- Verifications rapides
    SELECT 'Client' AS table_name, COUNT(*) AS nb_lignes
    FROM Client
UNION ALL
    SELECT 'Employe', COUNT(*)
    FROM Employe
UNION ALL
    SELECT 'Fournisseur', COUNT(*)
    FROM Fournisseur
UNION ALL
    SELECT 'Produit', COUNT(*)
    FROM Produit
UNION ALL
    SELECT 'Commande', COUNT(*)
    FROM Commande;
GO
