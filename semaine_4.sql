USE MaPremiereBase;
GO
CREATE TABLE Produit (
    id_produit INT PRIMARY KEY,
    designation VARCHAR(100) NOT NULL,
    prix DECIMAL(10,2) NOT NULL,
    stock INT NOT NULL,
    id_cat INT NOT NULL,
    description VARCHAR(255) NULL
);
GO

CREATE TABLE Categorie (
    id_cat INT PRIMARY KEY,
    libelle VARCHAR(100) NOT NULL
);
GO

INSERT INTO Categorie (id_cat, libelle) VALUES
(1, 'Périphériques'),
(2, 'Écrans'),
(3, 'Câbles et accessoires');
GO

INSERT INTO Produit (id_produit, designation, prix, stock, id_cat, description) VALUES
(1, 'Clavier sans fil', 45.00, 30, 1, NULL),
(2, 'Souris ergonomique', 89.00, 15, 1, 'Confort optimal'),
(3, 'Écran 24 pouces', 220.00, 8, 2, 'Full HD'),
(4, 'Écran 27 pouces', 350.00, 3, 2, NULL),
(5, 'Câble HDMI', 12.00, 100, 3, 'Longueur 2m'),
(6, 'Webcam HD', 65.00, 0, 1, NULL),
(7, 'Disque SSD 1To', 95.00, 20, 2, 'NVMe');
GO