package com.hotel.soap;

import jakarta.xml.bind.annotation.XmlAccessType;
import jakarta.xml.bind.annotation.XmlAccessorType;
import jakarta.xml.bind.annotation.XmlElement;
import jakarta.xml.bind.annotation.XmlType;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@XmlType(name = "Chambre")
@XmlAccessorType(XmlAccessType.FIELD)
@Data
@NoArgsConstructor
@AllArgsConstructor
public class ChambreSoap {
    @XmlElement
    private Long id;
    
    @XmlElement
    private String type;
    
    @XmlElement
    private Double prix;
    
    @XmlElement
    private Boolean disponible;
}

