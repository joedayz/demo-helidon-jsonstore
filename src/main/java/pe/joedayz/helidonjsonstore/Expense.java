package pe.joedayz.helidonjsonstore;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.Id;
import jakarta.persistence.Table;

import java.time.LocalDateTime;
import java.util.UUID;

@Entity
@Table(name = "expenses")
public record Expense(
        @Id String id,
        @Column(name = "amount") double amount,
        @Column(name = "method") String method,     // CARD, CASH, DEBIT, CREDIT
        @Column(name = "category") String category,   // FOOD, TRANSPORT, SHOPPING...
        @Column(name = "created_at") LocalDateTime createdAt,
        @Column(name = "description") String description
) {
    public static Expense of(double amount, String method, String category, String description) {
        return new Expense(UUID.randomUUID().toString(),
                amount,
                method,
                category,
                LocalDateTime.now(),
                description);
    }

    public Expense update(Expense other) {
        return new Expense(this.id,
                other.amount,
                other.method,
                other.category,
                this.createdAt,
                other.description);
    }
}