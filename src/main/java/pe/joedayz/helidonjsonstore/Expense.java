package pe.joedayz.helidonjsonstore;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.Id;
import jakarta.persistence.Table;

import java.time.LocalDateTime;
import java.util.UUID;

@Entity
@Table(name = "expenses")
public class Expense {
    
    @Id
    private String id;
    
    @Column(name = "amount")
    private double amount;
    
    @Column(name = "method")
    private String method;     // CARD, CASH, DEBIT, CREDIT
    
    @Column(name = "category")
    private String category;   // FOOD, TRANSPORT, SHOPPING...
    
    @Column(name = "created_at")
    private LocalDateTime createdAt;
    
    @Column(name = "description")
    private String description;
    
    // Default constructor for JPA
    public Expense() {
    }
    
    // Constructor with all fields
    public Expense(String id, double amount, String method, String category, LocalDateTime createdAt, String description) {
        this.id = id;
        this.amount = amount;
        this.method = method;
        this.category = category;
        this.createdAt = createdAt;
        this.description = description;
    }
    
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
    
    // Getters and Setters
    public String getId() {
        return id;
    }
    
    public void setId(String id) {
        this.id = id;
    }
    
    public double getAmount() {
        return amount;
    }
    
    public void setAmount(double amount) {
        this.amount = amount;
    }
    
    public String getMethod() {
        return method;
    }
    
    public void setMethod(String method) {
        this.method = method;
    }
    
    public String getCategory() {
        return category;
    }
    
    public void setCategory(String category) {
        this.category = category;
    }
    
    public LocalDateTime getCreatedAt() {
        return createdAt;
    }
    
    public void setCreatedAt(LocalDateTime createdAt) {
        this.createdAt = createdAt;
    }
    
    public String getDescription() {
        return description;
    }
    
    public void setDescription(String description) {
        this.description = description;
    }
}