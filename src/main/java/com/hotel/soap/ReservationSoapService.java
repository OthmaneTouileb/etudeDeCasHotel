package com.hotel.soap;

import com.hotel.dto.ClientDTO;
import com.hotel.dto.ChambreDTO;
import com.hotel.dto.ReservationDTO;
import com.hotel.service.ReservationService;
import lombok.RequiredArgsConstructor;
import org.springframework.ws.server.endpoint.annotation.Endpoint;
import org.springframework.ws.server.endpoint.annotation.PayloadRoot;
import org.springframework.ws.server.endpoint.annotation.RequestPayload;
import org.springframework.ws.server.endpoint.annotation.ResponsePayload;

@Endpoint
@RequiredArgsConstructor
public class ReservationSoapService {
    
    private static final String NAMESPACE_URI = "http://hotel.com/soap";
    
    private final ReservationService reservationService;
    
    @PayloadRoot(namespace = NAMESPACE_URI, localPart = "GetReservationRequest")
    @ResponsePayload
    public GetReservationResponse getReservation(@RequestPayload GetReservationRequest request) {
        ReservationDTO dto = reservationService.getReservationById(request.getId());
        ReservationSoap soap = convertToSoap(dto);
        
        GetReservationResponse response = new GetReservationResponse();
        response.setReservation(soap);
        return response;
    }
    
    @PayloadRoot(namespace = NAMESPACE_URI, localPart = "CreateReservationRequest")
    @ResponsePayload
    public CreateReservationResponse createReservation(@RequestPayload CreateReservationRequest request) {
        ReservationDTO dto = convertToDTO(request.getReservation());
        ReservationDTO created = reservationService.createReservation(dto);
        ReservationSoap soap = convertToSoap(created);
        
        CreateReservationResponse response = new CreateReservationResponse();
        response.setReservation(soap);
        return response;
    }
    
    @PayloadRoot(namespace = NAMESPACE_URI, localPart = "UpdateReservationRequest")
    @ResponsePayload
    public UpdateReservationResponse updateReservation(@RequestPayload UpdateReservationRequest request) {
        ReservationDTO dto = convertToDTO(request.getReservation());
        ReservationDTO updated = reservationService.updateReservation(request.getId(), dto);
        ReservationSoap soap = convertToSoap(updated);
        
        UpdateReservationResponse response = new UpdateReservationResponse();
        response.setReservation(soap);
        return response;
    }
    
    @PayloadRoot(namespace = NAMESPACE_URI, localPart = "DeleteReservationRequest")
    @ResponsePayload
    public DeleteReservationResponse deleteReservation(@RequestPayload DeleteReservationRequest request) {
        reservationService.deleteReservation(request.getId());
        
        DeleteReservationResponse response = new DeleteReservationResponse();
        response.setMessage("Reservation deleted successfully");
        return response;
    }
    
    private ReservationSoap convertToSoap(ReservationDTO dto) {
        ReservationSoap soap = new ReservationSoap();
        soap.setId(dto.getId());
        soap.setDateDebut(dto.getDateDebut());
        soap.setDateFin(dto.getDateFin());
        soap.setPreferences(dto.getPreferences());
        
        if (dto.getClient() != null) {
            ClientSoap clientSoap = new ClientSoap();
            clientSoap.setId(dto.getClient().getId());
            clientSoap.setNom(dto.getClient().getNom());
            clientSoap.setPrenom(dto.getClient().getPrenom());
            clientSoap.setEmail(dto.getClient().getEmail());
            clientSoap.setTelephone(dto.getClient().getTelephone());
            soap.setClient(clientSoap);
        }
        
        if (dto.getChambre() != null) {
            ChambreSoap chambreSoap = new ChambreSoap();
            chambreSoap.setId(dto.getChambre().getId());
            chambreSoap.setType(dto.getChambre().getType());
            chambreSoap.setPrix(dto.getChambre().getPrix());
            chambreSoap.setDisponible(dto.getChambre().getDisponible());
            soap.setChambre(chambreSoap);
        }
        
        return soap;
    }
    
    private ReservationDTO convertToDTO(ReservationSoap soap) {
        ReservationDTO dto = new ReservationDTO();
        dto.setId(soap.getId());
        dto.setDateDebut(soap.getDateDebut());
        dto.setDateFin(soap.getDateFin());
        dto.setPreferences(soap.getPreferences());
        
        if (soap.getClient() != null) {
            ClientDTO clientDTO = new ClientDTO();
            clientDTO.setId(soap.getClient().getId());
            clientDTO.setNom(soap.getClient().getNom());
            clientDTO.setPrenom(soap.getClient().getPrenom());
            clientDTO.setEmail(soap.getClient().getEmail());
            clientDTO.setTelephone(soap.getClient().getTelephone());
            dto.setClient(clientDTO);
        }
        
        if (soap.getChambre() != null) {
            ChambreDTO chambreDTO = new ChambreDTO();
            chambreDTO.setId(soap.getChambre().getId());
            chambreDTO.setType(soap.getChambre().getType());
            chambreDTO.setPrix(soap.getChambre().getPrix());
            chambreDTO.setDisponible(soap.getChambre().getDisponible());
            dto.setChambre(chambreDTO);
        }
        
        return dto;
    }
}

