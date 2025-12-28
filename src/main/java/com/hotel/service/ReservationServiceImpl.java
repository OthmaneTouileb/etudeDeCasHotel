package com.hotel.service;

import com.hotel.dto.ChambreDTO;
import com.hotel.dto.ClientDTO;
import com.hotel.dto.ReservationDTO;
import com.hotel.entity.Chambre;
import com.hotel.entity.Client;
import com.hotel.entity.Reservation;
import com.hotel.mapper.ReservationMapper;
import com.hotel.repository.ChambreRepository;
import com.hotel.repository.ClientRepository;
import com.hotel.repository.ReservationRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class ReservationServiceImpl implements ReservationService {
    
    private final ReservationRepository reservationRepository;
    private final ClientRepository clientRepository;
    private final ChambreRepository chambreRepository;
    private final ReservationMapper reservationMapper;
    
    @Override
    @Transactional
    public ReservationDTO createReservation(ReservationDTO reservationDTO) {
        Reservation reservation = new Reservation();
        
        // Gérer le client
        if (reservationDTO.getClient() != null) {
            Client client;
            if (reservationDTO.getClient().getId() != null) {
                client = clientRepository.findById(reservationDTO.getClient().getId())
                        .orElseThrow(() -> new RuntimeException("Client not found with id: " + reservationDTO.getClient().getId()));
            } else {
                // Créer un nouveau client
                client = reservationMapper.toClientEntity(reservationDTO.getClient());
                client = clientRepository.save(client);
            }
            reservation.setClient(client);
        }
        
        // Gérer la chambre
        if (reservationDTO.getChambre() != null) {
            Chambre chambre;
            if (reservationDTO.getChambre().getId() != null) {
                chambre = chambreRepository.findById(reservationDTO.getChambre().getId())
                        .orElseThrow(() -> new RuntimeException("Chambre not found with id: " + reservationDTO.getChambre().getId()));
            } else {
                // Créer une nouvelle chambre
                chambre = reservationMapper.toChambreEntity(reservationDTO.getChambre());
                chambre = chambreRepository.save(chambre);
            }
            reservation.setChambre(chambre);
        }
        
        reservation.setDateDebut(reservationDTO.getDateDebut());
        reservation.setDateFin(reservationDTO.getDateFin());
        reservation.setPreferences(reservationDTO.getPreferences());
        
        Reservation saved = reservationRepository.save(reservation);
        return reservationMapper.toDTO(saved);
    }
    
    @Override
    @Transactional(readOnly = true)
    public ReservationDTO getReservationById(Long id) {
        Reservation reservation = reservationRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Reservation not found with id: " + id));
        return reservationMapper.toDTO(reservation);
    }
    
    @Override
    @Transactional(readOnly = true)
    public List<ReservationDTO> getAllReservations() {
        return reservationRepository.findAll().stream()
                .map(reservationMapper::toDTO)
                .collect(Collectors.toList());
    }
    
    @Override
    @Transactional
    public ReservationDTO updateReservation(Long id, ReservationDTO reservationDTO) {
        Reservation existing = reservationRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Reservation not found with id: " + id));
        
        // Mettre à jour le client si fourni
        if (reservationDTO.getClient() != null && reservationDTO.getClient().getId() != null) {
            Client client = clientRepository.findById(reservationDTO.getClient().getId())
                    .orElseThrow(() -> new RuntimeException("Client not found with id: " + reservationDTO.getClient().getId()));
            existing.setClient(client);
        }
        
        // Mettre à jour la chambre si fournie
        if (reservationDTO.getChambre() != null && reservationDTO.getChambre().getId() != null) {
            Chambre chambre = chambreRepository.findById(reservationDTO.getChambre().getId())
                    .orElseThrow(() -> new RuntimeException("Chambre not found with id: " + reservationDTO.getChambre().getId()));
            existing.setChambre(chambre);
        }
        
        if (reservationDTO.getDateDebut() != null) {
            existing.setDateDebut(reservationDTO.getDateDebut());
        }
        if (reservationDTO.getDateFin() != null) {
            existing.setDateFin(reservationDTO.getDateFin());
        }
        if (reservationDTO.getPreferences() != null) {
            existing.setPreferences(reservationDTO.getPreferences());
        }
        
        Reservation updated = reservationRepository.save(existing);
        return reservationMapper.toDTO(updated);
    }
    
    @Override
    @Transactional
    public void deleteReservation(Long id) {
        if (!reservationRepository.existsById(id)) {
            throw new RuntimeException("Reservation not found with id: " + id);
        }
        reservationRepository.deleteById(id);
    }
}

