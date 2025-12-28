-- Script d'initialisation des données de test

-- Insertion de clients
INSERT INTO clients (nom, prenom, email, telephone) VALUES
('Dupont', 'Jean', 'jean.dupont@example.com', '0123456789'),
('Martin', 'Marie', 'marie.martin@example.com', '0234567890'),
('Bernard', 'Pierre', 'pierre.bernard@example.com', '0345678901'),
('Dubois', 'Sophie', 'sophie.dubois@example.com', '0456789012'),
('Laurent', 'Luc', 'luc.laurent@example.com', '0567890123');

-- Insertion de chambres
INSERT INTO chambres (type, prix, disponible) VALUES
('simple', 80.0, true),
('double', 120.0, true),
('suite', 200.0, true),
('simple', 85.0, true),
('double', 125.0, true),
('suite', 220.0, true),
('simple', 90.0, true),
('double', 130.0, true);

