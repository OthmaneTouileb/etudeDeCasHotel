package com.hotel.grpc;

import com.hotel.dto.ChambreDTO;
import com.hotel.dto.ClientDTO;
import com.hotel.dto.ReservationDTO;
import com.hotel.service.ReservationService;
import io.grpc.stub.StreamObserver;
import lombok.RequiredArgsConstructor;
import net.devh.boot.grpc.server.service.GrpcService;
import org.springframework.stereotype.Service;

import java.time.LocalDate;
import java.util.List;

// Note: Les classes suivantes sont générées automatiquement par Maven lors de la compilation
// depuis le fichier src/main/proto/reservation.proto :
// - CreateReservationRequest
// - GetReservationRequest
// - UpdateReservationRequest
// - DeleteReservationRequest
// - GetAllReservationsRequest
// - ReservationResponse
// - ReservationListResponse
// - DeleteReservationResponse
// - ClientMessage
// - ChambreMessage
// - ReservationServiceGrpc

@GrpcService
@Service
@RequiredArgsConstructor
public class ReservationGrpcService extends ReservationServiceGrpc.ReservationServiceImplBase {
    
    private final ReservationService reservationService;
    
    @Override
    public void createReservation(CreateReservationRequest request, StreamObserver<ReservationResponse> responseObserver) {
        try {
            ReservationDTO dto = convertToDTO(request);
            ReservationDTO created = reservationService.createReservation(dto);
            ReservationResponse response = convertToResponse(created);
            
            responseObserver.onNext(response);
            responseObserver.onCompleted();
        } catch (Exception e) {
            responseObserver.onError(e);
        }
    }
    
    @Override
    public void getReservation(GetReservationRequest request, StreamObserver<ReservationResponse> responseObserver) {
        try {
            ReservationDTO dto = reservationService.getReservationById(request.getId());
            ReservationResponse response = convertToResponse(dto);
            
            responseObserver.onNext(response);
            responseObserver.onCompleted();
        } catch (Exception e) {
            responseObserver.onError(e);
        }
    }
    
    @Override
    public void updateReservation(UpdateReservationRequest request, StreamObserver<ReservationResponse> responseObserver) {
        try {
            ReservationDTO dto = convertToDTO(request);
            ReservationDTO updated = reservationService.updateReservation(request.getId(), dto);
            ReservationResponse response = convertToResponse(updated);
            
            responseObserver.onNext(response);
            responseObserver.onCompleted();
        } catch (Exception e) {
            responseObserver.onError(e);
        }
    }
    
    @Override
    public void deleteReservation(DeleteReservationRequest request, StreamObserver<DeleteReservationResponse> responseObserver) {
        try {
            reservationService.deleteReservation(request.getId());
            DeleteReservationResponse response = DeleteReservationResponse.newBuilder()
                    .setMessage("Reservation deleted successfully")
                    .build();
            
            responseObserver.onNext(response);
            responseObserver.onCompleted();
        } catch (Exception e) {
            responseObserver.onError(e);
        }
    }
    
    @Override
    public void getAllReservations(GetAllReservationsRequest request, StreamObserver<ReservationListResponse> responseObserver) {
        try {
            List<ReservationDTO> reservations = reservationService.getAllReservations();
            ReservationListResponse.Builder builder = ReservationListResponse.newBuilder();
            
            for (ReservationDTO dto : reservations) {
                builder.addReservations(convertToResponse(dto));
            }
            
            responseObserver.onNext(builder.build());
            responseObserver.onCompleted();
        } catch (Exception e) {
            responseObserver.onError(e);
        }
    }
    
    private ReservationDTO convertToDTO(CreateReservationRequest request) {
        ReservationDTO dto = new ReservationDTO();
        
        if (request.getClient() != null && request.getClient().getId() != 0) {
            ClientMessage clientMsg = request.getClient();
            ClientDTO clientDTO = new ClientDTO();
            clientDTO.setId(clientMsg.getId() > 0 ? clientMsg.getId() : null);
            clientDTO.setNom(clientMsg.getNom());
            clientDTO.setPrenom(clientMsg.getPrenom());
            clientDTO.setEmail(clientMsg.getEmail());
            clientDTO.setTelephone(clientMsg.getTelephone());
            dto.setClient(clientDTO);
        }
        
        if (request.getChambre() != null && request.getChambre().getId() != 0) {
            ChambreMessage chambreMsg = request.getChambre();
            ChambreDTO chambreDTO = new ChambreDTO();
            chambreDTO.setId(chambreMsg.getId() > 0 ? chambreMsg.getId() : null);
            chambreDTO.setType(chambreMsg.getType());
            chambreDTO.setPrix(chambreMsg.getPrix());
            chambreDTO.setDisponible(chambreMsg.getDisponible());
            dto.setChambre(chambreDTO);
        }
        
        dto.setDateDebut(LocalDate.parse(request.getDateDebut()));
        dto.setDateFin(LocalDate.parse(request.getDateFin()));
        dto.setPreferences(request.getPreferences());
        
        return dto;
    }
    
    private ReservationDTO convertToDTO(UpdateReservationRequest request) {
        ReservationDTO dto = new ReservationDTO();
        
        if (request.getClient() != null && request.getClient().getId() != 0) {
            ClientMessage clientMsg = request.getClient();
            ClientDTO clientDTO = new ClientDTO();
            clientDTO.setId(clientMsg.getId() > 0 ? clientMsg.getId() : null);
            clientDTO.setNom(clientMsg.getNom());
            clientDTO.setPrenom(clientMsg.getPrenom());
            clientDTO.setEmail(clientMsg.getEmail());
            clientDTO.setTelephone(clientMsg.getTelephone());
            dto.setClient(clientDTO);
        }
        
        if (request.getChambre() != null && request.getChambre().getId() != 0) {
            ChambreMessage chambreMsg = request.getChambre();
            ChambreDTO chambreDTO = new ChambreDTO();
            chambreDTO.setId(chambreMsg.getId() > 0 ? chambreMsg.getId() : null);
            chambreDTO.setType(chambreMsg.getType());
            chambreDTO.setPrix(chambreMsg.getPrix());
            chambreDTO.setDisponible(chambreMsg.getDisponible());
            dto.setChambre(chambreDTO);
        }
        
        dto.setDateDebut(LocalDate.parse(request.getDateDebut()));
        dto.setDateFin(LocalDate.parse(request.getDateFin()));
        dto.setPreferences(request.getPreferences());
        
        return dto;
    }
    
    private ReservationResponse convertToResponse(ReservationDTO dto) {
        ReservationResponse.Builder builder = ReservationResponse.newBuilder();
        
        if (dto.getId() != null) {
            builder.setId(dto.getId());
        }
        
        if (dto.getClient() != null) {
            ClientDTO clientDTO = dto.getClient();
            ClientMessage clientMsg = ClientMessage.newBuilder()
                    .setId(clientDTO.getId() != null ? clientDTO.getId() : 0)
                    .setNom(clientDTO.getNom() != null ? clientDTO.getNom() : "")
                    .setPrenom(clientDTO.getPrenom() != null ? clientDTO.getPrenom() : "")
                    .setEmail(clientDTO.getEmail() != null ? clientDTO.getEmail() : "")
                    .setTelephone(clientDTO.getTelephone() != null ? clientDTO.getTelephone() : "")
                    .build();
            builder.setClient(clientMsg);
        }
        
        if (dto.getChambre() != null) {
            ChambreDTO chambreDTO = dto.getChambre();
            ChambreMessage chambreMsg = ChambreMessage.newBuilder()
                    .setId(chambreDTO.getId() != null ? chambreDTO.getId() : 0)
                    .setType(chambreDTO.getType() != null ? chambreDTO.getType() : "")
                    .setPrix(chambreDTO.getPrix() != null ? chambreDTO.getPrix() : 0.0)
                    .setDisponible(chambreDTO.getDisponible() != null ? chambreDTO.getDisponible() : false)
                    .build();
            builder.setChambre(chambreMsg);
        }
        
        if (dto.getDateDebut() != null) {
            builder.setDateDebut(dto.getDateDebut().toString());
        }
        
        if (dto.getDateFin() != null) {
            builder.setDateFin(dto.getDateFin().toString());
        }
        
        if (dto.getPreferences() != null) {
            builder.setPreferences(dto.getPreferences());
        }
        
        return builder.build();
    }
}

