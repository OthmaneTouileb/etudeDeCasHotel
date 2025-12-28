package com.hotel.repository;

import com.hotel.entity.Chambre;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface ChambreRepository extends JpaRepository<Chambre, Long> {
    List<Chambre> findByDisponibleTrue();
    List<Chambre> findByType(String type);
}

