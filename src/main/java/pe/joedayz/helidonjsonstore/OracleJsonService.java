package pe.joedayz.helidonjsonstore;

import jakarta.enterprise.context.ApplicationScoped;
import jakarta.inject.Inject;
import jakarta.persistence.EntityManager;
import jakarta.persistence.PersistenceContext;
import jakarta.persistence.Query;
import jakarta.transaction.Transactional;

import java.util.List;
import java.util.Optional;

@ApplicationScoped
@Transactional
public class OracleJsonService {

    @PersistenceContext
    private EntityManager entityManager;

    /**
     * Save expense using Oracle JSON Store capabilities
     */
    public Expense save(Expense expense) {
        if (expense.getId() == null) {
            entityManager.persist(expense);
            return expense;
        } else {
            return entityManager.merge(expense);
        }
    }

    /**
     * Find expense by ID
     */
    public Optional<Expense> findById(String id) {
        Expense expense = entityManager.find(Expense.class, id);
        return Optional.ofNullable(expense);
    }

    /**
     * Find all expenses
     */
    public List<Expense> findAll() {
        Query query = entityManager.createQuery("SELECT e FROM Expense e ORDER BY e.createdAt DESC");
        return query.getResultList();
    }

    /**
     * Find expenses by category using Oracle JSON path expressions
     */
    public List<Expense> findByCategory(String category) {
        Query query = entityManager.createQuery(
            "SELECT e FROM Expense e WHERE e.category = :category ORDER BY e.createdAt DESC");
        query.setParameter("category", category);
        return query.getResultList();
    }

    /**
     * Find expenses by payment method
     */
    public List<Expense> findByMethod(String method) {
        Query query = entityManager.createQuery(
            "SELECT e FROM Expense e WHERE e.method = :method ORDER BY e.createdAt DESC");
        query.setParameter("method", method);
        return query.getResultList();
    }

    /**
     * Find expenses by amount range
     */
    public List<Expense> findByAmountRange(double minAmount, double maxAmount) {
        Query query = entityManager.createQuery(
            "SELECT e FROM Expense e WHERE e.amount BETWEEN :minAmount AND :maxAmount ORDER BY e.amount DESC");
        query.setParameter("minAmount", minAmount);
        query.setParameter("maxAmount", maxAmount);
        return query.getResultList();
    }

    /**
     * Find expenses by description using Oracle JSON text search
     */
    public List<Expense> findByDescriptionContaining(String description) {
        Query query = entityManager.createQuery(
            "SELECT e FROM Expense e WHERE LOWER(e.description) LIKE LOWER(:description) ORDER BY e.createdAt DESC");
        query.setParameter("description", "%" + description + "%");
        return query.getResultList();
    }

    /**
     * Get total expenses by category
     */
    public double getTotalByCategory(String category) {
        Query query = entityManager.createQuery(
            "SELECT SUM(e.amount) FROM Expense e WHERE e.category = :category");
        query.setParameter("category", category);
        Double result = (Double) query.getSingleResult();
        return result != null ? result : 0.0;
    }

    /**
     * Get total expenses by payment method
     */
    public double getTotalByMethod(String method) {
        Query query = entityManager.createQuery(
            "SELECT SUM(e.amount) FROM Expense e WHERE e.method = :method");
        query.setParameter("method", method);
        Double result = (Double) query.getSingleResult();
        return result != null ? result : 0.0;
    }

    /**
     * Get expenses statistics
     */
    public ExpenseStatistics getStatistics() {
        // Total count
        Query countQuery = entityManager.createQuery("SELECT COUNT(e) FROM Expense e");
        Long totalCount = (Long) countQuery.getSingleResult();
        
        // Total amount
        Query amountQuery = entityManager.createQuery("SELECT SUM(e.amount) FROM Expense e");
        Double totalAmount = (Double) amountQuery.getSingleResult();
        
        // Average amount
        Query avgQuery = entityManager.createQuery("SELECT AVG(e.amount) FROM Expense e");
        Double avgAmount = (Double) avgQuery.getSingleResult();
        
        return new ExpenseStatistics(
            totalCount != null ? totalCount : 0L,
            totalAmount != null ? totalAmount : 0.0,
            avgAmount != null ? avgAmount : 0.0
        );
    }

    /**
     * Delete expense by ID
     */
    public void deleteById(String id) {
        Expense expense = entityManager.find(Expense.class, id);
        if (expense != null) {
            entityManager.remove(expense);
        }
    }

    /**
     * Update expense
     */
    public Expense update(Expense expense) {
        return entityManager.merge(expense);
    }

    /**
     * Statistics class for expense data
     */
    public static class ExpenseStatistics {
        private final long totalCount;
        private final double totalAmount;
        private final double averageAmount;

        public ExpenseStatistics(long totalCount, double totalAmount, double averageAmount) {
            this.totalCount = totalCount;
            this.totalAmount = totalAmount;
            this.averageAmount = averageAmount;
        }

        public long getTotalCount() { return totalCount; }
        public double getTotalAmount() { return totalAmount; }
        public double getAverageAmount() { return averageAmount; }
    }
}
