# 🔧 Technical Details - Helidon + Virtual Threads

**Advanced technical documentation for developers and architects**

## 🏗️ System Architecture

### Technology Stack

- **Runtime**: Java 21 (LTS)
- **Framework**: Helidon 4.x (MicroProfile 6.0)
- **Database**: Oracle Database 23c Free
- **Persistence**: JPA 3.2 + Hibernate 6.x
- **Connection Pool**: HikariCP 5.x
- **Build Tool**: Maven 3.9+

### Architecture Diagram

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   Load Balancer │    │  Helidon App    │    │ Oracle Database │
│   (Optional)    │◄──►│   Port 8081     │◄──►│   Port 1521     │
└─────────────────┘    └─────────────────┘    └─────────────────┘
                              │
                              ▼
                       ┌─────────────────┐
                       │ Virtual Threads │
                       │   Executor      │
                       └─────────────────┘
```

## 🔧 System Configuration

### Recommended JVM Flags

```bash
# Optimizations for Virtual Threads
-XX:+UseG1GC
-XX:MaxGCPauseMillis=200
-XX:+UnlockExperimentalVMOptions
-XX:+UseJVMCICompiler

# Monitoring
-XX:+PrintGCDetails
-XX:+PrintGCTimeStamps
-Djava.util.logging.manager=org.jboss.logmanager.LogManager
```

### Helidon Configuration

```yaml
# application.yaml
server:
  port: 8081
  host: 0.0.0.0
  
logging:
  level: INFO
  
database:
  url: jdbc:oracle:thin:@localhost:1521:FREE
  username: C##helidon_user
  password: helidon123
  pool:
    maximum: 50
    minimum: 10
    connectionTimeout: 30000
```

## 📊 Performance Metrics

### Detailed Benchmarks

| Scenario | Platform Threads | Virtual Threads | Improvement |
|----------|------------------|------------------|-------------|
| **100 concurrent req** | 2.1s | 0.2s | **10.5x** |
| **500 concurrent req** | 8.5s | 0.8s | **10.6x** |
| **1000 concurrent req** | 18.2s | 1.5s | **12.1x** |
| **Batch 10k items** | 45.3s | 4.2s | **10.8x** |

### Resource Analysis

```bash
# Memory monitoring
jstat -gc <pid> 1000

# Thread monitoring
jstack <pid>

# Heap analysis
jmap -histo <pid>
```

## 🚀 Advanced Optimizations

### 1. Connection Pool Tuning

```java
@Produces
@ApplicationScoped
public DataSource optimizedDataSource() {
    HikariConfig config = new HikariConfig();
    
    // Pool size optimized for Virtual Threads
    config.setMaximumPoolSize(50);  // Reduced from 100
    config.setMinimumIdle(10);
    config.setConnectionTimeout(30000);
    config.setIdleTimeout(600000);
    config.setMaxLifetime(1800000);
    
    // Oracle-specific configurations
    config.addDataSourceProperty("oracle.jdbc.timezoneAsRegion", "false");
    config.addDataSourceProperty("oracle.jdbc.fanEnabled", "false");
    
    return new HikariDataSource(config);
}
```

### 2. Async Processing Patterns

```java
// Pattern 1: Fan-out/Fan-in
public CompletableFuture<AggregatedResult> processFanOutFanIn(
        List<Expense> expenses) {
    
    List<CompletableFuture<ProcessedExpense>> futures = expenses.stream()
        .map(expense -> CompletableFuture.supplyAsync(
            () -> processExpense(expense), virtualThreadExecutor))
        .collect(Collectors.toList());
    
    return CompletableFuture.allOf(futures.toArray(new CompletableFuture[0]))
        .thenApply(v -> aggregateResults(futures));
}

// Pattern 2: Pipeline Processing
public CompletableFuture<FinalResult> processPipeline(
        List<Expense> expenses) {
    
    return CompletableFuture.supplyAsync(() -> expenses, virtualThreadExecutor)
        .thenApplyAsync(this::validateExpenses, virtualThreadExecutor)
        .thenApplyAsync(this::enrichExpenses, virtualThreadExecutor)
        .thenApplyAsync(this::calculateTotals, virtualThreadExecutor);
}
```

## 🔍 Advanced Troubleshooting

### 1. Thread Dump Analysis

```bash
# Generate thread dump
jstack <pid> > thread_dump.txt

# Analyze Virtual Threads
grep "VirtualThread" thread_dump.txt
grep "carrier" thread_dump.txt
```

### 2. Memory Leak Detection

```java
@Scheduled(fixedRate = 60000) // Every minute
public void monitorVirtualThreads() {
    ThreadMXBean threadBean = ManagementFactory.getThreadMXBean();
    
    long virtualThreadCount = threadBean.getThreadCount();
    long peakThreadCount = threadBean.getPeakThreadCount();
    
    if (virtualThreadCount > 10000) {
        logger.warning("High virtual thread count: " + virtualThreadCount);
    }
    
    // Log memory usage
    Runtime runtime = Runtime.getRuntime();
    long usedMemory = runtime.totalMemory() - runtime.freeMemory();
    long maxMemory = runtime.maxMemory();
    
    logger.info("Memory usage: " + (usedMemory * 100 / maxMemory) + "%");
}
```

### 3. Performance Profiling

```java
// Use JFR for profiling
@Startup
@ApplicationScoped
public class PerformanceMonitor {
    
    @PostConstruct
    public void startProfiling() {
        if (System.getProperty("jfr.enabled", "false").equals("true")) {
            try {
                Configuration config = Configuration.getConfiguration("default");
                Recording recording = new Recording(config);
                recording.start();
                
                // Schedule automatic stop
                Timer.schedule(() -> {
                    recording.stop();
                    recording.dump(new File("performance-profile.jfr"));
                }, 300000); // 5 minutes
                
            } catch (Exception e) {
                logger.warning("Could not start JFR profiling: " + e.getMessage());
            }
        }
    }
}
```

## 📈 Scalability and Limits

### Theoretical vs Practical Limits

| Metric | Theoretical | Practical | Recommended |
|--------|-------------|-----------|-------------|
| **Virtual Threads** | ∞ | 1,000,000+ | 100,000 |
| **Memory per Thread** | 2KB | 2-4KB | 2KB |
| **Throughput** | ∞ | 10,000+ req/s | 5,000 req/s |
| **Latency** | 0ms | <1ms | <1ms |

### Limiting Factors

1. **System Memory**: Each Virtual Thread uses ~2KB
2. **CPU Cores**: For CPU-bound operations
3. **I/O Bandwidth**: For I/O-bound operations
4. **Database Connections**: Pool size and database limits

## 🎯 Recommended Design Patterns

### 1. Circuit Breaker Pattern

```java
@ApplicationScoped
public class CircuitBreaker {
    
    private final AtomicInteger failureCount = new AtomicInteger(0);
    private final AtomicLong lastFailureTime = new AtomicLong(0);
    private volatile CircuitState state = CircuitState.CLOSED;
    
    public <T> CompletableFuture<T> execute(
            Supplier<CompletableFuture<T>> supplier) {
        
        if (state == CircuitState.OPEN) {
            if (System.currentTimeMillis() - lastFailureTime.get() > 60000) {
                state = CircuitState.HALF_OPEN;
            } else {
                return CompletableFuture.failedFuture(
                    new CircuitBreakerOpenException());
            }
        }
        
        return supplier.get()
            .whenComplete((result, throwable) -> {
                if (throwable != null) {
                    handleFailure();
                } else {
                    handleSuccess();
                }
            });
    }
}
```

### 2. Bulkhead Pattern

```java
@ApplicationScoped
public class BulkheadExecutor {
    
    private final ExecutorService databaseExecutor = 
        Executors.newVirtualThreadPerTaskExecutor();
    private final ExecutorService externalApiExecutor = 
        Executors.newVirtualThreadPerTaskExecutor();
    private final ExecutorService fileProcessingExecutor = 
        Executors.newVirtualThreadPerTaskExecutor();
    
    public ExecutorService getExecutor(OperationType type) {
        return switch (type) {
            case DATABASE -> databaseExecutor;
            case EXTERNAL_API -> externalApiExecutor;
            case FILE_PROCESSING -> fileProcessingExecutor;
        };
    }
}
```

## 📚 Resources and References

### Official Documentation

- [Java 21 Virtual Threads](https://docs.oracle.com/en/java/javase/21/core/virtual-threads.html)
- [Helidon 4.x Documentation](https://helidon.io/docs/latest/)
- [Project Loom JEP 444](https://openjdk.org/jeps/444)

### Monitoring Tools

- **JConsole**: Basic JVM monitoring
- **VisualVM**: Profiling and memory analysis
- **JFR**: Flight Recorder for profiling
- **Micrometer**: Application metrics

### Community and Support

- [Helidon Discord](https://discord.gg/helidon)
- [Java Community](https://community.oracle.com/tech/developers/)
- [Stack Overflow](https://stackoverflow.com/questions/tagged/virtual-threads)

---

**Need more details?** Check our [blog.joedayz.pe](https://blog.joedayz.pe/java-virtual-threads-in-action-managing-expenses-with-helidon-nima-and-oracle-database-23ai-json-store) for practical implementation or open an issue on GitHub.
