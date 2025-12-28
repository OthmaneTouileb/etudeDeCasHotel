package com.hotel.dto;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDate;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class ReservationDTO {
    private Long id;
    private ClientDTO client;
    private ChambreDTO chambre;
    private LocalDate dateDebut;
    private LocalDate dateFin;
    private String preferences;
}

