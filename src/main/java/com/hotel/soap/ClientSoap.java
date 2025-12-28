package com.hotel.soap;

import jakarta.xml.bind.annotation.XmlAccessType;
import jakarta.xml.bind.annotation.XmlAccessorType;
import jakarta.xml.bind.annotation.XmlElement;
import jakarta.xml.bind.annotation.XmlType;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@XmlType(name = "Client")
@XmlAccessorType(XmlAccessType.FIELD)
@Data
@NoArgsConstructor
@AllArgsConstructor
public class ClientSoap {
    @XmlElement
    private Long id;
    
    @XmlElement
    private String nom;
    
    @XmlElement
    private String prenom;
    
    @XmlElement
    private String email;
    
    @XmlElement
    private String telephone;
}

