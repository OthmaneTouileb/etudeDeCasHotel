package com.hotel.graphql;

import com.hotel.dto.ChambreDTO;
import com.hotel.dto.ClientDTO;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDate;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class ReservationInput {
    private ClientDTO client;
    private ChambreDTO chambre;
    private LocalDate dateDebut;
    private LocalDate dateFin;
    private String preferences;
}

