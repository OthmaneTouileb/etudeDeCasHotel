package com.hotel.graphql;

import com.hotel.dto.ReservationDTO;
import com.hotel.service.ReservationService;
import lombok.RequiredArgsConstructor;
import org.springframework.graphql.data.method.annotation.Argument;
import org.springframework.graphql.data.method.annotation.MutationMapping;
import org.springframework.graphql.data.method.annotation.QueryMapping;
import org.springframework.stereotype.Controller;

import java.util.List;

@Controller
@RequiredArgsConstructor
public class ReservationGraphQLController {
    
    private final ReservationService reservationService;
    
    @QueryMapping
    public ReservationDTO reservation(@Argument Long id) {
        return reservationService.getReservationById(id);
    }
    
    @QueryMapping
    public List<ReservationDTO> reservations() {
        return reservationService.getAllReservations();
    }
    
    @MutationMapping
    public ReservationDTO createReservation(@Argument ReservationInput input) {
        ReservationDTO dto = new ReservationDTO();
        dto.setDateDebut(input.getDateDebut());
        dto.setDateFin(input.getDateFin());
        dto.setPreferences(input.getPreferences());
        
        if (input.getClient() != null) {
            dto.setClient(input.getClient());
        }
        
        if (input.getChambre() != null) {
            dto.setChambre(input.getChambre());
        }
        
        return reservationService.createReservation(dto);
    }
    
    @MutationMapping
    public ReservationDTO updateReservation(@Argument Long id, @Argument ReservationInput input) {
        ReservationDTO dto = new ReservationDTO();
        dto.setDateDebut(input.getDateDebut());
        dto.setDateFin(input.getDateFin());
        dto.setPreferences(input.getPreferences());
        
        if (input.getClient() != null) {
            dto.setClient(input.getClient());
        }
        
        if (input.getChambre() != null) {
            dto.setChambre(input.getChambre());
        }
        
        return reservationService.updateReservation(id, dto);
    }
    
    @MutationMapping
    public Boolean deleteReservation(@Argument Long id) {
        reservationService.deleteReservation(id);
        return true;
    }
}

