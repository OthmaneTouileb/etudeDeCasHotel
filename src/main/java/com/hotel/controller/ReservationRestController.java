package com.hotel.controller;

import com.hotel.dto.ReservationDTO;
import com.hotel.service.ReservationService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/rest/reservations")
@RequiredArgsConstructor
@Tag(name = "Reservation REST API", description = "API REST pour la gestion des réservations")
@CrossOrigin(origins = "*")
public class ReservationRestController {
    
    private final ReservationService reservationService;
    
    @PostMapping
    @Operation(summary = "Créer une réservation", description = "Crée une nouvelle réservation")
    public ResponseEntity<ReservationDTO> createReservation(@RequestBody ReservationDTO reservationDTO) {
        ReservationDTO created = reservationService.createReservation(reservationDTO);
        return ResponseEntity.status(HttpStatus.CREATED).body(created);
    }
    
    @GetMapping("/{id}")
    @Operation(summary = "Consulter une réservation", description = "Récupère les détails d'une réservation par son ID")
    public ResponseEntity<ReservationDTO> getReservation(@PathVariable Long id) {
        ReservationDTO reservation = reservationService.getReservationById(id);
        return ResponseEntity.ok(reservation);
    }
    
    @GetMapping
    @Operation(summary = "Liste toutes les réservations", description = "Récupère toutes les réservations")
    public ResponseEntity<List<ReservationDTO>> getAllReservations() {
        List<ReservationDTO> reservations = reservationService.getAllReservations();
        return ResponseEntity.ok(reservations);
    }
    
    @PutMapping("/{id}")
    @Operation(summary = "Modifier une réservation", description = "Met à jour une réservation existante")
    public ResponseEntity<ReservationDTO> updateReservation(
            @PathVariable Long id,
            @RequestBody ReservationDTO reservationDTO) {
        ReservationDTO updated = reservationService.updateReservation(id, reservationDTO);
        return ResponseEntity.ok(updated);
    }
    
    @DeleteMapping("/{id}")
    @Operation(summary = "Supprimer une réservation", description = "Supprime une réservation par son ID")
    public ResponseEntity<Void> deleteReservation(@PathVariable Long id) {
        reservationService.deleteReservation(id);
        return ResponseEntity.noContent().build();
    }
}

