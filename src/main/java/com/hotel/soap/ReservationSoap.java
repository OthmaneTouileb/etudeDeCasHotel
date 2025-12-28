package com.hotel.soap;

import jakarta.xml.bind.annotation.XmlAccessType;
import jakarta.xml.bind.annotation.XmlAccessorType;
import jakarta.xml.bind.annotation.XmlElement;
import jakarta.xml.bind.annotation.XmlType;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDate;

@XmlType(name = "Reservation")
@XmlAccessorType(XmlAccessType.FIELD)
@Data
@NoArgsConstructor
@AllArgsConstructor
public class ReservationSoap {
    @XmlElement
    private Long id;
    
    @XmlElement
    private ClientSoap client;
    
    @XmlElement
    private ChambreSoap chambre;
    
    @XmlElement
    private LocalDate dateDebut;
    
    @XmlElement
    private LocalDate dateFin;
    
    @XmlElement
    private String preferences;
}

