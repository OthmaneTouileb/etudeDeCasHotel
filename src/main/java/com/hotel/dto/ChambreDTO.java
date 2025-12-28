package com.hotel.dto;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class ChambreDTO {
    private Long id;
    private String type;
    private Double prix;
    private Boolean disponible;
}

