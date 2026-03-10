-- ============================================================
--  JEUX DE DONNÉES DE TEST — SGBD 2  (SQL Server / T-SQL)
--  Couvre tous les exercices du cours Mois 1
--  Niveau : L1 DEV — ISMAGI
-- ============================================================
--  Exécuter dans l'ordre, du haut vers le bas.
--  Chaque section correspond à un exercice ou groupe d'exercices.
-- ============================================================

-- ============================================================
--  CRÉATION ET SÉLECTION DE LA BASE DE DONNÉES
-- ============================================================
IF NOT EXISTS (
    SELECT name FROM sys.databases WHERE name = 'SGBD2_Tests'
)
    CREATE DATABASE SGBD2_Tests;
GO

USE SGBD2_Tests;
GO

-- ============================================================
-- SECTION 1 — FONCTIONS SCALAIRES & COLONNES CALCULÉES
--   Exercice 1 : Calcul mathématique  (prix TTC, valeur stock)
--   Exercice 2 : Fonctions sur chaînes (UPPER, CONCAT, LEFT)
--   Exercice 3 : Fonctions de date     (YEAR, DATEDIFF)
--   Exercice 4 : Mix complet           (CASE WHEN + WHERE)
-- ============================================================

-- ---- Nettoyage ----
IF OBJECT_ID('Client',  'U') IS NOT NULL DROP TABLE Client;
IF OBJECT_ID('Produit', 'U') IS NOT NULL DROP TABLE Produit;

-- ---- Table Produit (Exercices 1, 4) ----
CREATE TABLE Produit (
    id_produit  INT             PRIMARY KEY IDENTITY(1,1),
    designation NVARCHAR(100)   NOT NULL,
    prix        DECIMAL(10,2)   NOT NULL,
    stock       INT             NOT NULL DEFAULT 0,
    id_cat      INT             NOT NULL
);
INSERT INTO Produit (designation, prix, stock, id_cat) VALUES
    ('Clavier sans fil',    45.00, 30, 1),
    ('Souris ergonomique',  89.00, 15, 1),
    ('Ecran 24 pouces',    220.00,  8, 2),
    ('Disque SSD 1To',      95.00, 20, 2),
    ('Webcam HD',           55.00,  0, 1);  -- stock=0 => RUPTURE pour CASE WHEN

-- ---- Table Client (Exercices 2, 3) ----
CREATE TABLE Client (
    id_client           INT             PRIMARY KEY IDENTITY(1,1),
    nom                 NVARCHAR(100)   NOT NULL,
    prenom              NVARCHAR(100)   NOT NULL,
    email               NVARCHAR(100),
    date_inscription    DATE
);
INSERT INTO Client (nom, prenom, email, date_inscription) VALUES
    ('benali',   'hassan',  'h.benali@gmail.com',     '2023-03-15'),
    ('tazi',     'sara',    'sara.tazi@outlook.com',   '2024-07-01'),
    ('idrissi',  'youssef', 'y.idrissi@gmail.com',     '2022-11-20'),
    ('el fassi', 'nadia',   'n.elfassi@mail.com',       '2021-05-10'),
    ('chakir',   'amine',   NULL,                       '2025-01-08'); -- email NULL

GO

-- ============================================================
-- SECTION 2 — EXERCICES CORRIGÉS SEMAINE 3
--   Exercice 1 : Requetes de base      — Boutique (Produit enrichi)
--   Exercice 2 : Filtrage avance       — Employes
--   Exercice 3 : Agregations GROUP BY  — Ventes (Commande + Ligne + Produit)
-- ============================================================

-- --- Ré-initialiser Produit avec les données de la Boutique ---
DELETE FROM Produit;
DBCC CHECKIDENT ('Produit', RESEED, 0);

INSERT INTO Produit (designation, prix, stock, id_cat) VALUES
    ('Ordinateur Portable Pro', 899.99, 15, 1),
    ('Souris Sans Fil',          25.50,120, 1),
    ('Clavier Mecanique',        89.90, 45, 1),
    ('Bureau Professionnel',    299.00,  8, 2),
    ('Chaise Ergonomique',      199.99, 12, 2),
    ('Stylos (lot 10)',           4.90,200, 3),
    ('Ramette A4 500f',           5.50, 80, 3),
    ('Ecran 27 pouces',         349.00, 20, 1),
    ('Casque Audio Pro',         79.00, 30, 1),
    ('Tablette Graphique',      249.00,  5, 1),
    ('Cable HDMI 2m',             8.90, 60, 1),
    ('Imprimante Laser',        199.00,  0, 1); -- stock=0, jamais commande

-- Resultats attendus Exercice 1 S3 :
--   Q3 (LIKE '%Pro%')  : Ordinateur Portable Pro, Bureau Professionnel, Casque Audio Pro
--   Q4 (COUNT)         : 12 produits
--   Q5 (AVG)           : ~200.72

GO

-- ---- Table Employe (Exercice 2 S3) ----
IF OBJECT_ID('Employe', 'U') IS NOT NULL DROP TABLE Employe;

CREATE TABLE Employe (
    id_employe      INT             PRIMARY KEY IDENTITY(1,1),
    nom             NVARCHAR(100)   NOT NULL,
    prenom          NVARCHAR(100)   NOT NULL,
    salaire         DECIMAL(10,2)   NOT NULL,
    departement     NVARCHAR(50),
    date_embauche   DATE,
    email           NVARCHAR(100)
);
INSERT INTO Employe (nom, prenom, salaire, departement, date_embauche, email) VALUES
    ('Alaoui',     'Mehdi',    8500.00, 'IT',           '2019-03-01', 'mehdi.alaoui@corp.ma'),
    ('Benjelloun', 'Sara',     6200.00, 'IT',           '2020-07-15', 'sara.b@corp.ma'),
    ('Chraibi',    'Youssef',  5800.00, 'IT',           '2021-01-10', NULL),
    ('Drissi',     'Fatima',   9200.00, 'IT',           '2018-05-20', 'f.drissi@corp.ma'),
    ('El Amrani',  'Karim',    4500.00, 'RH',           '2022-04-01', 'k.elamrani@corp.ma'),
    ('Filali',     'Nadia',    4800.00, 'RH',           '2021-09-01', 'n.filali@corp.ma'),
    ('Ghazi',      'Omar',     3900.00, 'RH',           '2023-02-14', NULL),
    ('Hajjami',    'Loubna',   5500.00, 'Comptabilite', '2020-06-01', 'l.hajjami@corp.ma'),
    ('Kabbouri',   'Yassine',  7800.00, 'Marketing',    '2019-08-01', 'y.kabbouri@corp.ma'),
    ('Naciri',     'Mounia',  15000.00, 'Direction',    '2015-01-01', 'mounia.n@corp.ma'),
    ('Ouali',      'Rachid',  12000.00, 'Direction',    '2017-06-01', 'rachid.o@corp.ma'),
    ('Mansouri',   'Bilal',    6000.00, 'Marketing',    '2021-07-01', 'b.mansouri@corp.ma');
-- Q1 (IN 'IT','RH')  : 7 employes
-- Q4 (email IS NULL) : Chraibi, Ghazi
-- Q5 (TOP 3 salaire) : Naciri 15000, Ouali 12000, Drissi 9200

GO

-- ---- Tables de ventes pour Exercice 3 S3 ----
IF OBJECT_ID('LigneCommande', 'U') IS NOT NULL DROP TABLE LigneCommande;
IF OBJECT_ID('Commande',      'U') IS NOT NULL DROP TABLE Commande;

CREATE TABLE Commande (
    id_commande INT     PRIMARY KEY IDENTITY(1,1),
    date_com    DATE    NOT NULL,
    id_client   INT     REFERENCES Client(id_client)
);
INSERT INTO Commande (date_com, id_client) VALUES
    ('2025-01-05', 1), ('2025-01-20', 2), ('2025-02-03', 1),
    ('2025-02-14', 3), ('2025-02-28', 4), ('2025-03-07', 2),
    ('2025-03-15', 5), ('2025-04-01', 1), ('2025-04-10', 2),
    ('2025-04-22', 3), ('2025-05-05', 4), ('2025-06-18', 1);

CREATE TABLE LigneCommande (
    id_ligne        INT             PRIMARY KEY IDENTITY(1,1),
    id_commande     INT             REFERENCES Commande(id_commande),
    id_produit      INT             REFERENCES Produit(id_produit),
    quantite        INT             NOT NULL DEFAULT 1,
    prix_unitaire   DECIMAL(10,2)   NOT NULL
);
INSERT INTO LigneCommande (id_commande, id_produit, quantite, prix_unitaire) VALUES
    (1, 1, 1, 899.99),(1, 2, 2,  25.50),(1, 6, 5,  4.90),
    (2, 4, 1, 299.00),(2, 5, 1, 199.99),
    (3, 8, 2, 349.00),(3, 9, 1,  79.00),
    (4, 2, 3,  25.50),(4, 3, 1,  89.90),(4,11, 2,  8.90),
    (5, 1, 1, 899.99),(5,10, 1, 249.00),
    (6, 3, 2,  89.90),(6, 6,10,  4.90),
    (7, 7, 3,   5.50),
    (8, 8, 1, 349.00),(8, 2, 1,  25.50),
    (9, 4, 2, 299.00),
    (10,2, 5,  25.50),(10,11,3,  8.90),
    (11,9, 2,  79.00),(11,3, 1,  89.90),
    (12,1, 1, 899.99),(12,10,1, 249.00);
-- id_produit=12 (Imprimante Laser) n'est jamais commande

GO

-- ============================================================
-- SECTION 3 — EXERCICES CORRIGÉS SEMAINE 4
--   Exercice 4 : Analyses complexes    — Bibliotheque (LEFT JOIN + DATEDIFF)
--   Exercice 5 : Mini-Projet           — Restaurant   (sous-requetes + INNER JOIN)
--   Exercice 6 : Jointures de base     — Ecole        (INNER/LEFT JOIN, HAVING)
--   Exercice 7 : Jointures multiples   — E-commerce   (5 tables)
--   Exercice 8 : Sous-requetes         — RH           (sous-requetes correlees)
--   Exercice 9 : Operateurs ensembl.   — Contacts     (UNION / INTERSECT / EXCEPT)
--   Exercice 10: Projet complet        — Hopital      (4 tables, LEFT JOIN)
-- ============================================================

-- ---- Exercice 4 : Bibliotheque ----
IF OBJECT_ID('Emprunt', 'U') IS NOT NULL DROP TABLE Emprunt;
IF OBJECT_ID('Livre',   'U') IS NOT NULL DROP TABLE Livre;
IF OBJECT_ID('Auteur',  'U') IS NOT NULL DROP TABLE Auteur;

CREATE TABLE Auteur (
    id_auteur    INT             PRIMARY KEY IDENTITY(1,1),
    nom          NVARCHAR(100)   NOT NULL,
    nationalite  NVARCHAR(50)
);
INSERT INTO Auteur (nom, nationalite) VALUES
    ('Victor Hugo',              'Francaise'),
    ('Albert Camus',             'Francaise'),
    ('Gabriel Garcia Marquez',   'Colombienne'),
    ('Tahar Ben Jelloun',        'Marocaine'),
    ('Umberto Eco',              'Italienne'),
    ('Stephen King',             'Americaine');

CREATE TABLE Livre (
    id_livre            INT             PRIMARY KEY IDENTITY(1,1),
    titre               NVARCHAR(200)   NOT NULL,
    annee_publication   INT,
    id_auteur           INT             REFERENCES Auteur(id_auteur)
);
INSERT INTO Livre (titre, annee_publication, id_auteur) VALUES
    ('Les Miserables',                1862, 1),
    ('Notre-Dame de Paris',           1831, 1),
    ('L''Etranger',                   1942, 2),
    ('La Peste',                      1947, 2),
    ('Cent ans de solitude',          1967, 3),
    ('L''Amour aux temps du cholera', 1985, 3),
    ('La Nuit sacree',                1987, 4),
    ('Le Nom de la rose',             1980, 5),
    ('Pendule de Foucault',           1988, 5),
    ('Carrie',                        1974, 6),
    ('Shining',                       1977, 6),
    ('Ca',                            1986, 6),
    ('La Boussole',                   2015, 4),  -- jamais emprunte => Q2 LEFT JOIN
    ('Baudelaire et nous',            2019, 2);  -- jamais emprunte => Q2 LEFT JOIN

CREATE TABLE Emprunt (
    id_emprunt      INT     PRIMARY KEY IDENTITY(1,1),
    id_livre        INT     REFERENCES Livre(id_livre),
    date_emprunt    DATE    NOT NULL,
    date_retour     DATE               -- NULL = livre non encore rendu
);
INSERT INTO Emprunt (id_livre, date_emprunt, date_retour) VALUES
    (1,  '2024-09-01', '2024-09-15'),
    (1,  '2024-10-10', '2024-10-24'),
    (1,  '2025-01-05', '2025-01-20'),
    (2,  '2024-11-01', '2024-11-14'),
    (3,  '2024-09-15', '2024-09-30'),
    (3,  '2025-02-01', '2025-02-14'),
    (4,  '2025-01-10', '2025-01-25'),
    (5,  '2024-08-01', '2024-08-20'),
    (5,  '2024-12-05', '2024-12-19'),
    (5,  '2025-03-01', '2025-03-17'),
    (6,  '2025-01-20', NULL),
    (7,  '2024-07-01', '2024-07-20'),
    (8,  '2024-10-01', '2024-10-22'),
    (8,  '2025-02-10', NULL),
    (9,  '2024-09-20', '2024-10-05'),
    (10, '2024-11-15', '2024-11-28'),
    (11, '2024-12-01', '2025-01-03'),
    (12, '2025-04-01', '2025-04-18');

GO

-- ---- Exercice 5 : Restaurant ----
IF OBJECT_ID('Detail_Commande',     'U') IS NOT NULL DROP TABLE Detail_Commande;
IF OBJECT_ID('Commande_Restaurant', 'U') IS NOT NULL DROP TABLE Commande_Restaurant;
IF OBJECT_ID('Plat',                'U') IS NOT NULL DROP TABLE Plat;

CREATE TABLE Plat (
    id_plat     INT             PRIMARY KEY IDENTITY(1,1),
    nom         NVARCHAR(100)   NOT NULL,
    prix        DECIMAL(8,2)    NOT NULL,
    categorie   NVARCHAR(20)    CHECK (categorie IN ('Entree','Plat','Dessert'))
);
INSERT INTO Plat (nom, prix, categorie) VALUES
    ('Salade Cesar',         45.00, 'Entree'),
    ('Soupe a l''Oignon',    38.00, 'Entree'),
    ('Briouates au Fromage', 52.00, 'Entree'),
    ('Pastilla',             55.00, 'Entree'),
    ('Tajine Poulet Olives', 95.00, 'Plat'),
    ('Couscous Royale',     110.00, 'Plat'),
    ('Steak Frites',         89.00, 'Plat'),
    ('Saumon Grille',        98.00, 'Plat'),
    ('Moussaka',             82.00, 'Plat'),
    ('Creme Brulee',         40.00, 'Dessert'),
    ('Tarte Tatin',          42.00, 'Dessert'),
    ('Coulant Chocolat',     48.00, 'Dessert'),
    ('Pastilla au Lait',     50.00, 'Dessert');

CREATE TABLE Commande_Restaurant (
    id_cmd       INT     PRIMARY KEY IDENTITY(1,1),
    date_cmd     DATE    NOT NULL,
    table_numero INT     NOT NULL
);
INSERT INTO Commande_Restaurant (date_cmd, table_numero) VALUES
    ('2025-01-10',1),('2025-01-12',2),('2025-01-15',1),
    ('2025-01-20',3),('2025-02-01',1),('2025-02-05',4),
    ('2025-02-10',2),('2025-02-14',5),('2025-02-18',2),
    ('2025-02-22',3),('2025-03-01',1),('2025-03-05',4),
    ('2025-03-10',5),('2025-03-15',2),('2025-03-20',1),
    ('2025-03-25',3),('2025-04-01',6),('2025-04-05',1),
    ('2025-04-10',2),('2025-04-15',4);

CREATE TABLE Detail_Commande (
    id_detail   INT PRIMARY KEY IDENTITY(1,1),
    id_cmd      INT REFERENCES Commande_Restaurant(id_cmd),
    id_plat     INT REFERENCES Plat(id_plat),
    quantite    INT NOT NULL DEFAULT 1
);
INSERT INTO Detail_Commande (id_cmd, id_plat, quantite) VALUES
    (1, 5,2),(1,10,2),(1, 1,2),
    (2, 6,3),(2,11,3),
    (3, 7,1),(3,12,1),(3, 2,1),
    (4, 5,2),(4,13,2),
    (5, 6,4),(5,10,4),(5, 3,4),
    (6, 8,1),(6,11,1),
    (7, 5,2),(7, 1,2),(7,12,2),
    (8, 6,2),(8,13,2),
    (9, 7,3),(9,10,3),
    (10,5,1),(10,11,1),
    (11,6,5),(11,12,5),(11,4,5),
    (12,8,2),(12,13,2),
    (13,5,3),(13,10,3),
    (14,7,2),(14,11,2),
    (15,6,4),(15,12,4),
    (16,5,2),(16,13,2),
    (17,8,1),(17,10,1),
    (18,6,3),(18,11,3),
    (19,5,2),(19,12,2),
    (20,7,1),(20,13,1);

GO

-- ---- Exercice 6 : Gestion Scolaire ----
IF OBJECT_ID('Inscription', 'U') IS NOT NULL DROP TABLE Inscription;
IF OBJECT_ID('Etudiant',    'U') IS NOT NULL DROP TABLE Etudiant;
IF OBJECT_ID('Classe',      'U') IS NOT NULL DROP TABLE Classe;

CREATE TABLE Classe (
    id_classe   INT             PRIMARY KEY IDENTITY(1,1),
    nom_classe  NVARCHAR(50)    NOT NULL,
    niveau      NVARCHAR(20)
);
INSERT INTO Classe (nom_classe, niveau) VALUES
    ('L1-DEV-A',   'Bac+1'),
    ('L1-DEV-B',   'Bac+1'),
    ('L2-INFO-A',  'Bac+2'),
    ('L2-INFO-B',  'Bac+2'),
    ('M1-GL',      'Bac+4'),
    ('Classe Vide','Bac+1');  -- aucune inscription => Q3 LEFT JOIN

CREATE TABLE Etudiant (
    id_etudiant     INT             PRIMARY KEY IDENTITY(1,1),
    nom             NVARCHAR(100)   NOT NULL,
    prenom          NVARCHAR(100)   NOT NULL,
    date_naissance  DATE
);
INSERT INTO Etudiant (nom, prenom, date_naissance) VALUES
    ('Alami',      'Youssef',  '2002-03-15'),
    ('Bensouda',   'Fatima',   '2001-07-22'),
    ('Chakir',     'Amine',    '2003-01-10'),
    ('Daoudi',     'Sara',     '2002-11-05'),
    ('El Fassi',   'Tariq',    '2001-09-18'),
    ('Filali',     'Hajar',    '2002-06-30'),
    ('Guessous',   'Mehdi',    '2003-04-12'),
    ('Hajji',      'Nadia',    '2001-12-01'),
    ('Idrissi',    'Reda',     '2002-08-25'),
    ('Jamal',      'Zahra',    '2003-02-17'),
    ('Kabbaj',     'Karim',    '2001-05-09'),
    ('Lahlou',     'Houda',    '2002-10-14'),
    ('Mekki',      'Ayoub',    '2003-07-03'),
    ('Naciri',     'Salma',    '2001-03-28'),
    ('Ouhabi',     'Hassan',   '2002-01-19'),
    ('Qadiri',     'Imane',    '2003-09-06'),
    ('Rhazali',    'Yassine',  '2001-11-23'),
    ('Sebti',      'Amal',     '2002-04-07'),
    ('Tahiri',     'Soufiane', '2003-06-11'),
    ('Usbane',     'Loubna',   '2001-08-15'),
    ('Vidal',      'Pierrick', '2002-12-20'),
    ('Wahbi',      'Samira',   '2003-03-29'),
    ('Yacoubi',    'Bilal',    '2001-10-04'),
    ('Zaki',       'Chaimae',  '2002-07-16'),
    ('Zouhairi',   'Rachid',   '2003-05-08'),
    ('Sans Classe','Etudiant', '2002-02-01'); -- pas d inscription => LEFT JOIN Q2

CREATE TABLE Inscription (
    id_inscription  INT             PRIMARY KEY IDENTITY(1,1),
    id_etudiant     INT             REFERENCES Etudiant(id_etudiant),
    id_classe       INT             REFERENCES Classe(id_classe),
    annee_scolaire  NVARCHAR(10)
);
-- 21 etudiants en L1-DEV-A => valide Q5 HAVING COUNT > 20
INSERT INTO Inscription (id_etudiant, id_classe, annee_scolaire) VALUES
    (1, 1,'2024-2025'),(2, 1,'2024-2025'),(3, 1,'2024-2025'),
    (4, 1,'2024-2025'),(5, 1,'2024-2025'),(6, 1,'2024-2025'),
    (7, 1,'2024-2025'),(8, 1,'2024-2025'),(9, 1,'2024-2025'),
    (10,1,'2024-2025'),(11,1,'2024-2025'),(12,1,'2024-2025'),
    (13,1,'2024-2025'),(14,1,'2024-2025'),(15,1,'2024-2025'),
    (16,1,'2024-2025'),(17,1,'2024-2025'),(18,1,'2024-2025'),
    (19,1,'2024-2025'),(20,1,'2024-2025'),(21,1,'2024-2025'),
    (22,2,'2024-2025'),(23,2,'2024-2025'),(24,2,'2024-2025'),
    (25,3,'2024-2025');
-- id_etudiant=26 : aucune inscription
-- id_classe 4,5,6 : sans inscriptions

GO

-- ---- Exercice 7 : E-commerce complet (jointures multiples) ----
IF OBJECT_ID('Categorie', 'U') IS NOT NULL DROP TABLE Categorie;

CREATE TABLE Categorie (
    id_cat   INT           PRIMARY KEY IDENTITY(1,1),
    libelle  NVARCHAR(50)  NOT NULL
);
INSERT INTO Categorie (libelle) VALUES
    ('Informatique'),
    ('Mobilier'),
    ('Fournitures'),
    ('Electronique'),
    ('Alimentation');

-- Note : Produit.id_cat reference ces categories (1 a 5).
-- Si vous souhaitez ajouter la contrainte FK :
-- ALTER TABLE Produit ADD CONSTRAINT FK_Produit_Cat
--     FOREIGN KEY (id_cat) REFERENCES Categorie(id_cat);

GO

-- ---- Exercice 8 : Ressources Humaines (sous-requetes correlees) ----
IF OBJECT_ID('Departement', 'U') IS NOT NULL DROP TABLE Departement;

CREATE TABLE Departement (
    id_departement  INT             PRIMARY KEY IDENTITY(1,1),
    nom_dept        NVARCHAR(50)    NOT NULL,
    budget          DECIMAL(12,2)
);
INSERT INTO Departement (nom_dept, budget) VALUES
    ('IT',           500000.00),
    ('RH',           150000.00),
    ('Comptabilite', 200000.00),
    ('Marketing',    180000.00),
    ('Direction',   1000000.00);

-- Ajouter id_departement dans Employe si absent
IF NOT EXISTS (
    SELECT 1 FROM sys.columns
    WHERE object_id = OBJECT_ID('Employe') AND name = 'id_departement'
)
    ALTER TABLE Employe ADD id_departement INT REFERENCES Departement(id_departement);

UPDATE Employe SET id_departement = 1 WHERE departement = 'IT';
UPDATE Employe SET id_departement = 2 WHERE departement = 'RH';
UPDATE Employe SET id_departement = 3 WHERE departement = 'Comptabilite';
UPDATE Employe SET id_departement = 4 WHERE departement = 'Marketing';
UPDATE Employe SET id_departement = 5 WHERE departement = 'Direction';
-- Salaire moyen entreprise = ~7266
-- Employes au-dessus de la moyenne : Alaoui, Drissi, Kabbouri, Naciri, Ouali

GO

-- ---- Exercice 9 : Contacts — Operateurs ensemblistes ----
IF OBJECT_ID('Fournisseur',    'U') IS NOT NULL DROP TABLE Fournisseur;
IF OBJECT_ID('Client_Contact', 'U') IS NOT NULL DROP TABLE Client_Contact;

CREATE TABLE Client_Contact (
    id_contact  INT             PRIMARY KEY IDENTITY(1,1),
    nom         NVARCHAR(100)   NOT NULL,
    email       NVARCHAR(100),
    telephone   NVARCHAR(20),
    ville       NVARCHAR(50)
);
INSERT INTO Client_Contact (nom, email, telephone, ville) VALUES
    ('Dupont Alice',  'alice.dupont@mail.com', '06-11-22-33-44', 'Casablanca'),
    ('Benali Karim',  'k.benali@mail.com',      '06-55-66-77-88', 'Rabat'),
    ('Martin Sophie', 'sophie.martin@mail.com','06-99-00-11-22', 'Marrakech'),
    ('Alaoui Youssef','y.alaoui@mail.com',      '06-33-44-55-66', 'Casablanca'),
    ('Tazi Omar',     'o.tazi@mail.com',         '06-77-88-99-00', 'Fes'),
    ('El Fassi Nadia','n.elfassi@mail.com',      '06-12-34-56-78', 'Rabat');

CREATE TABLE Fournisseur (
    id_fournisseur  INT             PRIMARY KEY IDENTITY(1,1),
    nom             NVARCHAR(100)   NOT NULL,
    email           NVARCHAR(100),
    telephone       NVARCHAR(20),
    ville           NVARCHAR(50)
);
INSERT INTO Fournisseur (nom, email, telephone, ville) VALUES
    ('TechMaroc SARL',       'contact@techmaroc.ma', '05-22-33-44-55', 'Casablanca'),
    ('FourniturePro',        'info@fourniturepro.ma','05-66-77-88-99', 'Rabat'),
    ('DataCenter Solutions', 'sales@dcs.ma',          '05-00-11-22-33', 'Kenitra'),
    ('Benali Karim',         'k.benali@mail.com',     '06-55-66-77-88', 'Rabat'),
    ('Dupont Alice',         'alice.dupont@mail.com', '06-11-22-33-44', 'Casablanca');
-- UNION villes       : Casablanca, Rabat, Marrakech, Fes, Kenitra
-- INTERSECT emails   : k.benali@mail.com, alice.dupont@mail.com
-- EXCEPT (CLI - FRN) : sophie.martin, y.alaoui, o.tazi, n.elfassi

GO

-- ---- Exercice 10 : Hopital ----
IF OBJECT_ID('Prescription',  'U') IS NOT NULL DROP TABLE Prescription;
IF OBJECT_ID('Consultation',  'U') IS NOT NULL DROP TABLE Consultation;
IF OBJECT_ID('Medecin',       'U') IS NOT NULL DROP TABLE Medecin;
IF OBJECT_ID('Patient',       'U') IS NOT NULL DROP TABLE Patient;

CREATE TABLE Patient (
    id_patient      INT             PRIMARY KEY IDENTITY(1,1),
    nom             NVARCHAR(100)   NOT NULL,
    prenom          NVARCHAR(100)   NOT NULL,
    date_naissance  DATE
);
INSERT INTO Patient (nom, prenom, date_naissance) VALUES
    ('Amrani',     'Sofia',   '1985-04-12'),
    ('Berrada',    'Youssef', '1972-09-23'),
    ('Cherkaoui',  'Fatima',  '1990-01-30'),
    ('Doukkali',   'Amine',   '2001-06-15'),
    ('El Haj',     'Myriam',  '1968-11-08'),
    ('Fakhouri',   'Rachid',  '1995-03-27'),
    ('Guerrouani', 'Layla',   '2005-07-04'),
    ('Hassani',    'Omar',    '1955-12-19'),
    ('Iraqui',     'Nadia',   '1980-02-14'); -- aucune consultation => Q4 LEFT JOIN

CREATE TABLE Medecin (
    id_medecin  INT             PRIMARY KEY IDENTITY(1,1),
    nom         NVARCHAR(100)   NOT NULL,
    specialite  NVARCHAR(80),
    salaire     DECIMAL(10,2)
);
INSERT INTO Medecin (nom, specialite, salaire) VALUES
    ('Dr Bennani',     'Cardiologie',       28000.00),
    ('Dr Tazi',        'Pediatrie',         22000.00),
    ('Dr El Idrissi',  'Neurologie',        30000.00),
    ('Dr Lahlou',      'Medecine Generale', 18000.00),
    ('Dr Filali',      'Cardiologie',       26000.00),
    ('Dr Ghazi',       'Dermatologie',      20000.00),
    ('Dr Ait Brahim',  'Orthopedie',        24000.00),
    ('Dr Sans Consult','Radiologie',        19000.00); -- jamais de consultation => Q4

CREATE TABLE Consultation (
    id_consultation   INT             PRIMARY KEY IDENTITY(1,1),
    id_patient        INT             REFERENCES Patient(id_patient),
    id_medecin        INT             REFERENCES Medecin(id_medecin),
    date_consultation DATE            NOT NULL,
    diagnostic        NVARCHAR(200)
);
INSERT INTO Consultation (id_patient, id_medecin, date_consultation, diagnostic) VALUES
    (1, 1, '2025-01-05', 'Hypertension arterielle'),
    (1, 1, '2025-02-10', 'Controle tension'),
    (1, 1, '2025-03-15', 'Arythmie legere'),
    (1, 4, '2025-04-01', 'Grippe'),
    (2, 3, '2025-01-08', 'Migraine chronique'),
    (2, 3, '2025-02-12', 'Migraine chronique - suivi'),
    (2, 3, '2025-03-20', 'IRM recommandee'),
    (2, 3, '2025-04-05', 'Amelioration'),
    (3, 6, '2025-01-15', 'Acne severe'),
    (3, 6, '2025-02-20', 'Traitement acne - suivi'),
    (4, 2, '2025-02-01', 'Angine'),
    (4, 4, '2025-03-10', 'Bilan de sante'),
    (5, 1, '2025-01-20', 'Insuffisance cardiaque'),
    (5, 5, '2025-02-25', 'Pose pacemaker'),
    (6, 7, '2025-01-10', 'Fracture poignet'),
    (6, 7, '2025-02-05', 'Suivi fracture'),
    (7, 2, '2025-03-01', 'Vaccins'),
    (8, 4, '2025-01-25', 'Diabete type 2'),
    (8, 4, '2025-02-28', 'Glycemie elevee'),
    (8, 4, '2025-04-10', 'Controle glycemie'),
    (8, 1, '2025-05-01', 'Bilan cardio');
-- id_patient=9 (Iraqui)        : aucune consultation
-- id_medecin=8 (Dr Sans Consult): aucune consultation

CREATE TABLE Prescription (
    id_prescription INT             PRIMARY KEY IDENTITY(1,1),
    id_consultation INT             REFERENCES Consultation(id_consultation),
    medicament      NVARCHAR(100)   NOT NULL,
    dosage          NVARCHAR(100)
);
INSERT INTO Prescription (id_consultation, medicament, dosage) VALUES
    (1,  'Amlodipine',        '5 mg - 1 cp/jour'),
    (1,  'Ramipril',          '10 mg - 1 cp/soir'),
    (2,  'Amlodipine',        '5 mg - 1 cp/jour'),
    (3,  'Bisoprolol',        '2.5 mg - 1 cp/matin'),
    (5,  'Sumatriptan',       '50 mg au besoin'),
    (5,  'Ibuprofene',        '400 mg - 3x/jour'),
    (6,  'Sumatriptan',       '50 mg au besoin'),
    (9,  'Tretinoine 0.05%', 'Application locale soir'),
    (9,  'Doxycycline',       '100 mg - 2x/jour'),
    (10, 'Tretinoine 0.05%', 'Application locale soir'),
    (11, 'Amoxicilline',      '500 mg - 3x/jour'),
    (13, 'Furosemide',        '40 mg - 1x/jour'),
    (13, 'Spironolactone',    '25 mg - 1x/jour'),
    (15, 'Ibuprofene',        '400 mg - 2x/jour'),
    (16, 'Calcium + Vit D',   '1 cp/jour'),
    (18, 'Metformine',        '500 mg - 2x/jour'),
    (19, 'Insuline Glargine', '10 unites/soir'),
    (20, 'Metformine',        '1000 mg - 2x/jour'),
    (21, 'Aspirine',          '75 mg - 1 cp/matin');
-- Consultations sans prescription : 4,7,8,12,14,17 => valides pour LEFT JOIN Q5

GO

