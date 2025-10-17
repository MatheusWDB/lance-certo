package br.com.hematsu.lance_certo.model;

import java.io.Serializable;
import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.List;

import org.hibernate.annotations.CreationTimestamp;
import org.hibernate.annotations.UpdateTimestamp;

import jakarta.persistence.CascadeType;
import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.EnumType;
import jakarta.persistence.Enumerated;
import jakarta.persistence.FetchType;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.OneToMany;
import jakarta.persistence.OrderBy;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@Entity(name = "tb_auctions")
public class Auction implements Serializable {
  private static final long serialVersionUID = 2405172041950251807L;

  @Id
  @GeneratedValue(strategy = GenerationType.IDENTITY)
  private Long id;

  @ManyToOne(fetch = FetchType.LAZY)
  @JoinColumn(name = "product_id", nullable = false)
  private Product product;

  @ManyToOne(fetch = FetchType.LAZY)
  @JoinColumn(name = "seller_id", nullable = false)
  private User seller;

  @Column(nullable = false)
  private LocalDateTime startDateAndTime;

  @Column(nullable = false)
  private LocalDateTime endDateAndTime;

  @Column(nullable = false, precision = 19, scale = 2)
  private BigDecimal initialPrice;

  @Column(nullable = false, precision = 19, scale = 2)
  private BigDecimal minimunBidIncrement;

  @Column(nullable = false, precision = 19, scale = 2)
  private BigDecimal currentBid;

  @ManyToOne(fetch = FetchType.LAZY)
  @JoinColumn(name = "current_bidder_id")
  private User currentBidder;

  @Enumerated(EnumType.STRING)
  @Column(nullable = false)
  private AuctionStatus status;

  @ManyToOne(fetch = FetchType.LAZY)
  @JoinColumn(name = "winner_id")
  private User winner;

  @CreationTimestamp
  @Column(nullable = false)
  private LocalDateTime createdAt;

  @UpdateTimestamp
  @Column(nullable = false)
  private LocalDateTime updatedAt;

  @OneToMany(mappedBy = "auction", cascade = CascadeType.ALL, orphanRemoval = true)
  @OrderBy("amount Desc, createdAt ASC")
  private List<Bid> bids;
}
