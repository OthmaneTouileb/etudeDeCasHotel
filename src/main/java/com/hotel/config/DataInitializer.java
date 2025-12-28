package com.hotel.config;

import com.hotel.entity.Chambre;
import com.hotel.entity.Client;
import com.hotel.repository.ChambreRepository;
import com.hotel.repository.ClientRepository;
import lombok.extern.slf4j.Slf4j;
import org.springframework.boot.CommandLineRunner;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.context.annotation.Profile;

@Configuration
@Slf4j
public class DataInitializer {

    @Bean
    @Profile("!test")
    public CommandLineRunner initData(ClientRepository clientRepository, ChambreRepository chambreRepository) {
        return args -> {
            // Vérifier si des données existent déjà
            if (clientRepository.count() == 0) {
                log.info("Initialisation des données de test...");
                
                // Créer des clients
                Client client1 = new Client(null, "Dupont", "Jean", "jean.dupont@example.com", "0123456789");
                Client client2 = new Client(null, "Martin", "Marie", "marie.martin@example.com", "0234567890");
                Client client3 = new Client(null, "Bernard", "Pierre", "pierre.bernard@example.com", "0345678901");
                Client client4 = new Client(null, "Dubois", "Sophie", "sophie.dubois@example.com", "0456789012");
                Client client5 = new Client(null, "Laurent", "Luc", "luc.laurent@example.com", "0567890123");
                
                clientRepository.save(client1);
                clientRepository.save(client2);
                clientRepository.save(client3);
                clientRepository.save(client4);
                clientRepository.save(client5);
                
                log.info("5 clients créés");
            }
            
            if (chambreRepository.count() == 0) {
                // Créer des chambres
                Chambre chambre1 = new Chambre(null, "simple", 80.0, true);
                Chambre chambre2 = new Chambre(null, "double", 120.0, true);
                Chambre chambre3 = new Chambre(null, "suite", 200.0, true);
                Chambre chambre4 = new Chambre(null, "simple", 85.0, true);
                Chambre chambre5 = new Chambre(null, "double", 125.0, true);
                Chambre chambre6 = new Chambre(null, "suite", 220.0, true);
                Chambre chambre7 = new Chambre(null, "simple", 90.0, true);
                Chambre chambre8 = new Chambre(null, "double", 130.0, true);
                
                chambreRepository.save(chambre1);
                chambreRepository.save(chambre2);
                chambreRepository.save(chambre3);
                chambreRepository.save(chambre4);
                chambreRepository.save(chambre5);
                chambreRepository.save(chambre6);
                chambreRepository.save(chambre7);
                chambreRepository.save(chambre8);
                
                log.info("8 chambres créées");
            }
            
            log.info("Initialisation des données terminée");
        };
    }
}

