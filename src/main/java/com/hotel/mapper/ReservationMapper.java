package com.hotel.mapper;

import com.hotel.dto.*;
import com.hotel.entity.*;
import org.mapstruct.Mapper;
import org.mapstruct.factory.Mappers;

@Mapper(componentModel = "spring")
public interface ReservationMapper {
    
    ReservationMapper INSTANCE = Mappers.getMapper(ReservationMapper.class);
    
    ReservationDTO toDTO(Reservation reservation);
    
    Reservation toEntity(ReservationDTO reservationDTO);
    
    ClientDTO toClientDTO(Client client);
    
    Client toClientEntity(ClientDTO clientDTO);
    
    ChambreDTO toChambreDTO(Chambre chambre);
    
    Chambre toChambreEntity(ChambreDTO chambreDTO);
}

