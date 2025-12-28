package com.hotel.entity;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Entity
@Table(name = "chambres")
@Data
@NoArgsConstructor
@AllArgsConstructor
public class Chambre {
    
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
    @Column(nullable = false)
    private String type; // simple, double, suite, etc.
    
    @Column(nullable = false)
    private Double prix;
    
    @Column(nullable = false)
    private Boolean disponible = true;
}

