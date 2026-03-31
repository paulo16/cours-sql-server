
USE SGBD2_Tests;
GO

-- ============================================================
-- SECTION 6 : PRÉPARATION DE DONNÉES POUR LEFT/RIGHT JOIN
-- ============================================================
-- Pour mieux illustrer les jointures externes, nous ajoutons des "trous" dans les données :
-- 1. Un client qui n'a jamais passé de commande.
-- 2. Une commande qui n'est associée à aucun client.

-- Ajout d'un client sans commande
-- Utilisons MERGE pour éviter d'ajouter le client à chaque exécution du script.
MERGE INTO Client AS target
USING (SELECT 'Nouveau' AS nom, 'Client' AS prenom, 'sans.commande@test.com' AS email) AS source
ON target.email = source.email
WHEN NOT MATCHED THEN
    INSERT (nom, prenom, email, date_inscription)
    VALUES (source.nom, source.prenom, source.email, GETDATE());
GO

-- Ajout d'une commande sans client (id_client = NULL)
-- On insère une seule fois pour ne pas dupliquer
IF NOT EXISTS (SELECT 1
FROM Commande
WHERE id_client IS NULL)
BEGIN
    INSERT INTO Commande
        (date_com, id_client)
    VALUES
        ('2025-07-01', NULL);
END
GO


-- Creation table taille et couleur pour l'exemple de CROSS JOIN
CREATE TABLE Taille
(
    id_taille INT PRIMARY KEY,
    libelle VARCHAR(20)
);
GO
INSERT INTO Taille
    (id_taille, libelle)
VALUES
    (1, 'Petit'),
    (2, 'Moyen'),
    (3, 'Grand');
GO

CREATE TABLE Couleur
(
    id_couleur INT PRIMARY KEY,
    libelle VARCHAR(20)
);

INSERT INTO Couleur
    (id_couleur, libelle)
VALUES
    (1, 'Rouge'),
    (2, 'Vert'),
    (3, 'Bleu');
GO