package pe.joedayz.helidonjsonstore;

import jakarta.enterprise.context.ApplicationScoped;
import jakarta.inject.Inject;
import jakarta.persistence.EntityManager;
import jakarta.persistence.PersistenceContext;
import jakarta.persistence.TypedQuery;
import jakarta.transaction.Transactional;

import java.util.List;
import java.util.Optional;

@ApplicationScoped
@Transactional
public class ExpenseRepository {

    @PersistenceContext
    private EntityManager entityManager;

    public Expense save(Expense expense) {
        if (expense.id() == null) {
            entityManager.persist(expense);
            return expense;
        } else {
            return entityManager.merge(expense);
        }
    }

    public Optional<Expense> findById(String id) {
        Expense expense = entityManager.find(Expense.class, id);
        return Optional.ofNullable(expense);
    }

    public List<Expense> findAll() {
        TypedQuery<Expense> query = entityManager.createQuery(
            "SELECT e FROM Expense e", Expense.class);
        return query.getResultList();
    }

    public List<Expense> findByCategory(String category) {
        TypedQuery<Expense> query = entityManager.createQuery(
            "SELECT e FROM Expense e WHERE e.category = :category", Expense.class);
        query.setParameter("category", category);
        return query.getResultList();
    }

    public List<Expense> findByMethod(String method) {
        TypedQuery<Expense> query = entityManager.createQuery(
            "SELECT e FROM Expense e WHERE e.method = :method", Expense.class);
        query.setParameter("method", method);
        return query.getResultList();
    }

    public void deleteById(String id) {
        Expense expense = entityManager.find(Expense.class, id);
        if (expense != null) {
            entityManager.remove(expense);
        }
    }

    public Expense update(Expense expense) {
        return entityManager.merge(expense);
    }

    public long count() {
        TypedQuery<Long> query = entityManager.createQuery(
            "SELECT COUNT(e) FROM Expense e", Long.class);
        return query.getSingleResult();
    }
}
