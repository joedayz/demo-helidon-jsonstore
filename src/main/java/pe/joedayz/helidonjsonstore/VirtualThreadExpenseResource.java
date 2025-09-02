package pe.joedayz.helidonjsonstore;

import jakarta.inject.Inject;
import jakarta.ws.rs.*;
import jakarta.ws.rs.core.MediaType;
import jakarta.ws.rs.core.Response;
import java.util.List;
import java.util.Map;

/**
 * REST resource demonstrating Java Virtual Threads in action.
 * This resource provides endpoints to test and benchmark virtual threads
 * performance compared to traditional approaches.
 */
@Path("/virtual-threads")
@Produces(MediaType.APPLICATION_JSON)
@Consumes(MediaType.APPLICATION_JSON)
public class VirtualThreadExpenseResource {
    
    @Inject
    private VirtualThreadExpenseService virtualThreadService;
    
    /**
     * Process expenses concurrently using virtual threads.
     * This endpoint demonstrates the power of virtual threads for concurrent processing.
     */
    @GET
    @Path("/concurrent")
    public Response processExpensesConcurrently(
            @QueryParam("count") @DefaultValue("100") int count) {
        try {
            List<VirtualThreadExpenseService.ExpenseInput> inputs = 
                virtualThreadService.generateTestExpenses(count);
            
            long startTime = System.currentTimeMillis();
            List<Expense> results = virtualThreadService.processExpensesConcurrently(inputs);
            long endTime = System.currentTimeMillis();
            
            Map<String, Object> response = Map.of(
                "processedCount", results.size(),
                "processingTime", endTime - startTime,
                "threadType", "Virtual Threads",
                "message", "Successfully processed " + results.size() + " expenses using virtual threads",
                "results", results
            );
            
            return Response.ok(response).build();
            
        } catch (Exception e) {
            return Response.status(Response.Status.INTERNAL_SERVER_ERROR)
                .entity(new ErrorResponse("Error processing expenses concurrently", e.getMessage()))
                .build();
        }
    }
    
    /**
     * Process expenses in batches using virtual threads.
     * Each batch runs on its own virtual thread for optimal performance.
     */
    @GET
    @Path("/batch")
    public Response processExpensesInBatches(
            @QueryParam("count") @DefaultValue("1000") int count,
            @QueryParam("batchSize") @DefaultValue("100") int batchSize) {
        
        try {
            List<VirtualThreadExpenseService.ExpenseInput> inputs = 
                virtualThreadService.generateTestExpenses(count);
            
            long startTime = System.currentTimeMillis();
            virtualThreadService.processExpensesInBatches(inputs, batchSize);
            long endTime = System.currentTimeMillis();
            
            Map<String, Object> response = Map.of(
                "processedCount", count,
                "batchSize", batchSize,
                "processingTime", endTime - startTime,
                "threadType", "Virtual Threads (Batch Mode)",
                "message", "Successfully processed " + count + " expenses in batches of " + batchSize
            );
            
            return Response.ok(response).build();
            
        } catch (Exception e) {
            return Response.status(Response.Status.INTERNAL_SERVER_ERROR)
                .entity(new ErrorResponse("Error processing expenses in batches", e.getMessage()))
                .build();
        }
    }
    
    /**
     * Execute multiple database queries concurrently using virtual threads.
     * This demonstrates how virtual threads can improve database performance.
     */
    @GET
    @Path("/concurrent-queries")
    public Response executeConcurrentQueries() {
        try {
            long startTime = System.currentTimeMillis();
            Map<String, Object> results = virtualThreadService.executeConcurrentQueries();
            long endTime = System.currentTimeMillis();
            
            Map<String, Object> response = Map.of(
                "queryTime", endTime - startTime,
                "threadType", "Virtual Threads",
                "message", "Successfully executed concurrent database queries",
                "results", results
            );
            
            return Response.ok(response).build();
            
        } catch (Exception e) {
            return Response.status(Response.Status.INTERNAL_SERVER_ERROR)
                .entity(new ErrorResponse("Error executing concurrent queries", e.getMessage()))
                .build();
        }
    }
    
    /**
     * Performance benchmark comparing virtual threads vs traditional approach.
     * This endpoint helps developers understand the performance benefits.
     */
    @GET
    @Path("/benchmark")
    public Response benchmarkPerformance(
            @QueryParam("count") @DefaultValue("100") int count) {
        try {
            Map<String, Object> benchmarkResults = virtualThreadService.benchmarkPerformance(count);
            
            Map<String, Object> response = Map.of(
                "benchmarkType", "Virtual Threads vs Traditional",
                "expenseCount", count,
                "message", "Performance benchmark completed successfully",
                "results", benchmarkResults
            );
            
            return Response.ok(response).build();
            
        } catch (Exception e) {
            return Response.status(Response.Status.INTERNAL_SERVER_ERROR)
                .entity(new ErrorResponse("Error running performance benchmark", e.getMessage()))
                .build();
        }
    }
    
    /**
     * Health check for virtual threads functionality.
     */
    @GET
    @Path("/health")
    public Response health() {
        try {
            // Simple test to ensure virtual threads are working
            List<VirtualThreadExpenseService.ExpenseInput> testInputs = 
                virtualThreadService.generateTestExpenses(5);
            
            Map<String, Object> response = Map.of(
                "status", "HEALTHY",
                "virtualThreads", "WORKING",
                "message", "Virtual threads service is operational",
                "testExpensesGenerated", testInputs.size()
            );
            
            return Response.ok(response).build();
            
        } catch (Exception e) {
            return Response.status(Response.Status.SERVICE_UNAVAILABLE)
                .entity(new ErrorResponse("Virtual threads service is not healthy", e.getMessage()))
                .build();
        }
    }
    
    /**
     * Get information about virtual threads and their benefits.
     */
    @GET
    @Path("/info")
    public Response getInfo() {
        Map<String, Object> info = Map.of(
            "technology", "Java Virtual Threads (Project Loom)",
            "javaVersion", "21+",
            "benefits", List.of(
                "Massive scalability - millions of threads possible",
                "Lightweight - ~2KB per thread vs ~1MB for OS threads",
                "Perfect for I/O-bound operations",
                "Simplified concurrent programming",
                "Backward compatible with existing code"
            ),
            "useCases", List.of(
                "Database operations",
                "HTTP client calls",
                "File I/O operations",
                "External API integrations",
                "Batch processing"
            ),
            "performance", Map.of(
                "throughput", "10x+ improvement for I/O-bound tasks",
                "memory", "Significantly lower memory usage",
                "scalability", "Unlimited concurrent operations"
            )
        );
        
        return Response.ok(info).build();
    }
    
    /**
     * Error response DTO for consistent error handling.
     */
    public static class ErrorResponse {
        private final String error;
        private final String message;
        private final String timestamp;
        
        public ErrorResponse(String error, String message) {
            this.error = error;
            this.message = message;
            this.timestamp = java.time.Instant.now().toString();
        }
        
        // Getters
        public String getError() { return error; }
        public String getMessage() { return message; }
        public String getTimestamp() { return timestamp; }
    }
}
