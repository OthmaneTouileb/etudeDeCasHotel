package com.hotel.service;

import com.hotel.dto.ReservationDTO;

import java.util.List;

public interface ReservationService {
    ReservationDTO createReservation(ReservationDTO reservationDTO);
    ReservationDTO getReservationById(Long id);
    List<ReservationDTO> getAllReservations();
    ReservationDTO updateReservation(Long id, ReservationDTO reservationDTO);
    void deleteReservation(Long id);
}

