package pe.joedayz.helidonjsonstore;

import jakarta.enterprise.context.ApplicationScoped;
import jakarta.inject.Inject;
import jakarta.persistence.EntityManager;
import jakarta.persistence.PersistenceContext;
import jakarta.transaction.Transactional;
import jakarta.annotation.PreDestroy;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.List;
import java.util.Map;
import java.util.concurrent.CompletableFuture;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;
import java.util.stream.Collectors;
import java.util.stream.IntStream;
import java.util.ArrayList;

/**
 * Service demonstrating Java Virtual Threads in action with expense management.
 * This service shows how virtual threads can dramatically improve performance
 * for I/O-bound operations like database queries and external API calls.
 */
@ApplicationScoped
@Transactional
public class VirtualThreadExpenseService {
    
    @PersistenceContext
    private EntityManager entityManager;
    
    @Inject
    private ExpenseRepository expenseRepository;
    
    // Virtual thread executor for concurrent operations
    private final ExecutorService virtualExecutor = Executors.newVirtualThreadPerTaskExecutor();
    
    // Constants for expense categories and payment methods
    private static final String[] EXPENSE_CATEGORIES = {"FOOD", "TRANSPORT", "SHOPPING", "ENTERTAINMENT", "HEALTH", "EDUCATION"};
    private static final String[] PAYMENT_METHODS = {"CARD", "CASH", "DEBIT", "CREDIT"};
    
    /**
     * Process multiple expenses concurrently using virtual threads.
     * This demonstrates the power of virtual threads for I/O operations.
     */
    public List<Expense> processExpensesConcurrently(List<ExpenseInput> inputs) {
        try {
            List<CompletableFuture<Expense>> futures = inputs.stream()
                .map(input -> CompletableFuture.supplyAsync(
                    () -> processExpense(input), 
                    virtualExecutor
                ))
                .collect(Collectors.toList());
            
            return futures.stream()
                .map(CompletableFuture::join)
                .collect(Collectors.toList());
                
        } catch (Exception e) {
            throw new RuntimeException("Error processing expenses concurrently", e);
        }
    }
    
    /**
     * Process expenses in batches using virtual threads.
     * Each batch runs on its own virtual thread for optimal performance.
     */
    public void processExpensesInBatches(List<ExpenseInput> inputs, int batchSize) {
        List<List<ExpenseInput>> batches = partition(inputs, batchSize);
        
        List<CompletableFuture<Void>> futures = batches.stream()
            .map(batch -> CompletableFuture.runAsync(
                () -> processBatch(batch), 
                virtualExecutor
            ))
            .collect(Collectors.toList());
        
        // Wait for all batches to complete
        CompletableFuture.allOf(
            futures.toArray(new CompletableFuture[0])
        ).join();
    }
    
    /**
     * Execute multiple database queries concurrently using virtual threads.
     * This is perfect for virtual threads as database operations are I/O-bound.
     */
    public Map<String, Object> executeConcurrentQueries() {
        try {
            CompletableFuture<List<Expense>> foodExpenses = CompletableFuture.supplyAsync(
                () -> findByCategory("FOOD"), 
                virtualExecutor
            );
            
            CompletableFuture<List<Expense>> transportExpenses = CompletableFuture.supplyAsync(
                () -> findByCategory("TRANSPORT"), 
                virtualExecutor
            );
            
            CompletableFuture<Double> totalAmount = CompletableFuture.supplyAsync(
                this::calculateTotalAmount, 
                virtualExecutor
            );
            
            CompletableFuture<Long> totalCount = CompletableFuture.supplyAsync(
                this::calculateTotalCount, 
                virtualExecutor
            );
            
            // Wait for all queries to complete
            CompletableFuture.allOf(foodExpenses, transportExpenses, totalAmount, totalCount).join();
            
            return Map.of(
                "foodExpenses", foodExpenses.join(),
                "transportExpenses", transportExpenses.join(),
                "totalAmount", totalAmount.join(),
                "totalCount", totalCount.join()
            );
            
        } catch (Exception e) {
            throw new RuntimeException("Error executing concurrent queries", e);
        }
    }
    
    /**
     * Batch insert with virtual threads for optimal database performance.
     */
    public void batchInsertWithVirtualThreads(List<Expense> expenses, int batchSize) {
        List<List<Expense>> batches = partitionExpenses(expenses, batchSize);
        
        List<CompletableFuture<Void>> futures = batches.stream()
            .map(batch -> CompletableFuture.runAsync(
                () -> insertBatch(batch), 
                virtualExecutor
            ))
            .collect(Collectors.toList());
        
        CompletableFuture.allOf(
            futures.toArray(new CompletableFuture[0])
        ).join();
    }
    
    /**
     * Generate test expenses for performance testing.
     */
    public List<ExpenseInput> generateTestExpenses(int count) {
        return IntStream.range(0, count)
            .mapToObj(i -> new ExpenseInput(
                Math.random() * 1000,
                PAYMENT_METHODS[i % PAYMENT_METHODS.length],
                EXPENSE_CATEGORIES[i % EXPENSE_CATEGORIES.length],
                "Test expense " + i
            ))
            .collect(Collectors.toList());
    }
    
    /**
     * Performance benchmark comparing virtual threads vs traditional approach.
     */
    public Map<String, Object> benchmarkPerformance(int expenseCount) {
        List<ExpenseInput> inputs = generateTestExpenses(expenseCount);
        
        // Benchmark virtual threads
        long virtualStart = System.currentTimeMillis();
        List<Expense> virtualResults = processExpensesConcurrently(inputs);
        long virtualTime = System.currentTimeMillis() - virtualStart;
        
        // Benchmark traditional approach (sequential)
        long traditionalStart = System.currentTimeMillis();
        List<Expense> traditionalResults = inputs.stream()
            .map(this::processExpense)
            .collect(Collectors.toList());
        long traditionalTime = System.currentTimeMillis() - traditionalStart;
        
        return Map.of(
            "virtualThreads", Map.of(
                "time", virtualTime,
                "count", virtualResults.size(),
                "throughput", (double) expenseCount / virtualTime * 1000
            ),
            "traditional", Map.of(
                "time", traditionalTime,
                "count", traditionalResults.size(),
                "throughput", (double) expenseCount / traditionalTime * 1000
            ),
            "improvement", Map.of(
                "timeReduction", ((double) (traditionalTime - virtualTime) / traditionalTime) * 100,
                "throughputIncrease", ((double) (expenseCount / virtualTime) / (expenseCount / traditionalTime) - 1) * 100
            )
        );
    }
    
    // Private helper methods
    
    private Expense processExpense(ExpenseInput input) {
        // Simulate I/O operations (database, external APIs)
        try {
            Thread.sleep(50); // Simulate database call
            Expense expense = Expense.of(input.amount(), input.method(), input.category(), input.description());
            
            // Save to database
            entityManager.persist(expense);
            return expense;
            
        } catch (InterruptedException e) {
            Thread.currentThread().interrupt();
            throw new RuntimeException(e);
        }
    }
    
    private void processBatch(List<ExpenseInput> batch) {
        // Process batch of expenses
        batch.forEach(this::processExpense);
    }
    
    private List<Expense> findByCategory(String category) {
        return entityManager.createQuery(
            "SELECT e FROM Expense e WHERE e.category = :category", 
            Expense.class
        )
        .setParameter("category", category)
        .getResultList();
    }
    
    private Double calculateTotalAmount() {
        try {
            return entityManager.createQuery(
                "SELECT COALESCE(SUM(e.amount), 0) FROM Expense e", 
                Double.class
            ).getSingleResult();
        } catch (Exception e) {
            return 0.0;
        }
    }
    
    private Long calculateTotalCount() {
        try {
            return entityManager.createQuery(
                "SELECT COUNT(e) FROM Expense e", 
                Long.class
            ).getSingleResult();
        } catch (Exception e) {
            return 0L;
        }
    }
    
    private void insertBatch(List<Expense> batch) {
        try {
            batch.forEach(entityManager::persist);
            entityManager.flush();
        } catch (Exception e) {
            throw new RuntimeException("Error inserting batch", e);
        }
    }
    
    private List<List<ExpenseInput>> partition(List<ExpenseInput> list, int size) {
        List<List<ExpenseInput>> partitions = new ArrayList<>();
        for (int i = 0; i < list.size(); i += size) {
            partitions.add(list.subList(i, Math.min(i + size, list.size())));
        }
        return partitions;
    }
    
    private List<List<Expense>> partitionExpenses(List<Expense> list, int size) {
        List<List<Expense>> partitions = new ArrayList<>();
        for (int i = 0; i < list.size(); i += size) {
            partitions.add(list.subList(i, Math.min(i + size, list.size())));
        }
        return partitions;
    }
    
    @PreDestroy
    public void cleanup() {
        if (virtualExecutor != null) {
            virtualExecutor.close();
        }
    }
    
    // Input DTO for expense creation
    public record ExpenseInput(
        double amount,
        String method,
        String category,
        String description
    ) {}
}
