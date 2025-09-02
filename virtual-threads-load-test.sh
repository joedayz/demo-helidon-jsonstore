#!/bin/bash

# 🚀 Virtual Threads Load Testing Script
# This script demonstrates the performance benefits of Java Virtual Threads
# by testing various endpoints with different concurrency levels.

echo "🚀 Java Virtual Threads Load Testing"
echo "===================================="
echo "Testing Helidon + Virtual Threads Performance"
echo ""

# Configuration
BASE_URL="http://localhost:8081"
ENDPOINTS=(
    "/virtual-threads/concurrent?count=100"
    "/virtual-threads/concurrent?count=1000"
    "/virtual-threads/batch?count=1000&batchSize=100"
    "/virtual-threads/concurrent-queries"
    "/virtual-threads/benchmark?count=500"
)

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    local color=$1
    local message=$2
    echo -e "${color}${message}${NC}"
}

# Function to check if endpoint is accessible
check_endpoint() {
    local endpoint=$1
    local response=$(curl -s -o /dev/null -w "%{http_code}" "$BASE_URL$endpoint")
    if [ "$response" = "200" ]; then
        return 0
    else
        return 1
    fi
}

# Function to run performance test
run_performance_test() {
    local endpoint=$1
    local concurrency=$2
    local requests=$3
    
    print_status $BLUE "Testing: $endpoint"
    print_status $BLUE "Concurrency: $concurrency, Requests: $requests"
    
    # Using Apache Bench if available
    if command -v ab &> /dev/null; then
        echo "Running Apache Bench test..."
        ab -n $requests -c $concurrency "$BASE_URL$endpoint" 2>/dev/null | grep -E "(Requests per second|Time per request|Failed requests)"
    else
        echo "Apache Bench not found. Running simple curl test..."
        
        # Simple concurrent test with curl
        start_time=$(date +%s%N)
        
        # Start concurrent requests
        for i in $(seq 1 $requests); do
            curl -s "$BASE_URL$endpoint" > /dev/null &
            
            # Control concurrency
            if [ $((i % concurrency)) -eq 0 ]; then
                wait
            fi
        done
        
        # Wait for remaining requests
        wait
        
        end_time=$(date +%s%N)
        duration=$(( (end_time - start_time) / 1000000 ))
        
        echo "Completed $requests requests in ${duration}ms"
        echo "Average time per request: $((duration / requests))ms"
        echo "Requests per second: $((requests * 1000 / duration))"
    fi
    
    echo "----------------------------------------"
}

# Function to test virtual threads health
test_virtual_threads_health() {
    print_status $YELLOW "Testing Virtual Threads Health..."
    
    if check_endpoint "/virtual-threads/health"; then
        print_status $GREEN "✅ Virtual Threads service is healthy"
        
        # Get service info
        echo "Service Information:"
        curl -s "$BASE_URL/virtual-threads/info" | jq '.' 2>/dev/null || curl -s "$BASE_URL/virtual-threads/info"
        echo ""
    else
        print_status $RED "❌ Virtual Threads service is not accessible"
        return 1
    fi
}

# Function to run benchmark comparison
run_benchmark() {
    print_status $YELLOW "Running Performance Benchmark..."
    
    local counts=(100 500 1000)
    
    for count in "${counts[@]}"; do
        echo "Benchmarking with $count expenses..."
        
        if check_endpoint "/virtual-threads/benchmark?count=$count"; then
            local result=$(curl -s "$BASE_URL/virtual-threads/benchmark?count=$count")
            echo "Benchmark result:"
            echo "$result" | jq '.' 2>/dev/null || echo "$result"
            echo ""
        else
            print_status $RED "Benchmark endpoint not accessible"
        fi
        
        sleep 2
    done
}

# Function to test concurrent processing
test_concurrent_processing() {
    print_status $YELLOW "Testing Concurrent Processing..."
    
    local counts=(100 500 1000)
    local concurrency_levels=(10 50 100)
    
    for count in "${counts[@]}"; do
        for concurrency in "${concurrency_levels[@]}"; do
            echo "Testing $count expenses with concurrency $concurrency..."
            
            if check_endpoint "/virtual-threads/concurrent?count=$count"; then
                local start_time=$(date +%s%N)
                
                # Start concurrent requests
                for i in $(seq 1 $concurrency); do
                    curl -s "$BASE_URL/virtual-threads/concurrent?count=$count" > /dev/null &
                done
                
                wait
                
                local end_time=$(date +%s%N)
                local duration=$(( (end_time - start_time) / 1000000 ))
                
                echo "  Completed $concurrency concurrent requests in ${duration}ms"
                echo "  Average time per request: $((duration / concurrency))ms"
            fi
            
            sleep 1
        done
        echo ""
    done
}

# Function to test batch processing
test_batch_processing() {
    print_status $YELLOW "Testing Batch Processing..."
    
    local batch_configs=(
        "1000:100"
        "5000:500"
        "10000:1000"
    )
    
    for config in "${batch_configs[@]}"; do
        IFS=':' read -r count batch_size <<< "$config"
        echo "Testing batch processing: $count expenses in batches of $batch_size..."
        
        if check_endpoint "/virtual-threads/batch?count=$count&batchSize=$batch_size"; then
            local start_time=$(date +%s%N)
            
            curl -s "$BASE_URL/virtual-threads/batch?count=$count&batchSize=$batch_size" > /dev/null
            
            local end_time=$(date +%s%N)
            local duration=$(( (end_time - start_time) / 1000000 ))
            
            echo "  Batch processing completed in ${duration}ms"
            echo "  Throughput: $((count * 1000 / duration)) expenses/second"
        fi
        
        sleep 2
    done
    echo ""
}

# Function to test concurrent queries
test_concurrent_queries() {
    print_status $YELLOW "Testing Concurrent Database Queries..."
    
    if check_endpoint "/virtual-threads/concurrent-queries"; then
        local iterations=10
        
        echo "Running $iterations iterations of concurrent queries..."
        
        local total_time=0
        for i in $(seq 1 $iterations); do
            local start_time=$(date +%s%N)
            
            curl -s "$BASE_URL/virtual-threads/concurrent-queries" > /dev/null
            
            local end_time=$(date +%s%N)
            local duration=$(( (end_time - start_time) / 1000000 ))
            total_time=$((total_time + duration))
            
            echo "  Iteration $i: ${duration}ms"
        done
        
        local avg_time=$((total_time / iterations))
        echo "  Average query time: ${avg_time}ms"
        echo "  Total time for $iterations iterations: ${total_time}ms"
    else
        print_status $RED "Concurrent queries endpoint not accessible"
    fi
    echo ""
}

# Function to generate performance report
generate_report() {
    print_status $GREEN "📊 Performance Test Report"
    echo "================================"
    echo "Test completed at: $(date)"
    echo "Base URL: $BASE_URL"
    echo ""
    
    echo "Tested Endpoints:"
    for endpoint in "${ENDPOINTS[@]}"; do
        echo "  ✅ $endpoint"
    done
    echo ""
    
    echo "Key Benefits of Virtual Threads:"
    echo "  🚀 Massive scalability - millions of threads possible"
    echo "  💾 Lightweight - ~2KB per thread vs ~1MB for OS threads"
    echo "  ⚡ Perfect for I/O-bound operations"
    echo "  🔄 Simplified concurrent programming"
    echo "  📈 10x+ performance improvement for I/O-bound tasks"
    echo ""
    
    echo "Next Steps:"
    echo "  1. Compare results with traditional thread-based approach"
    echo "  2. Monitor memory usage during high concurrency"
    echo "  3. Scale up to test limits of virtual threads"
    echo "  4. Consider migration to Helidon Níma for maximum benefits"
}

# Main execution
main() {
    echo "Starting Virtual Threads Load Testing..."
    echo "Make sure your Helidon application is running on $BASE_URL"
    echo ""
    
    # Check if application is accessible
    if ! check_endpoint "/health"; then
        print_status $RED "❌ Application is not accessible at $BASE_URL"
        print_status $RED "Please start your Helidon application first"
        exit 1
    fi
    
    print_status $GREEN "✅ Application is accessible"
    echo ""
    
    # Run tests
    test_virtual_threads_health
    echo ""
    
    run_benchmark
    echo ""
    
    test_concurrent_processing
    echo ""
    
    test_batch_processing
    echo ""
    
    test_concurrent_queries
    echo ""
    
    # Generate final report
    generate_report
    
    print_status $GREEN "🎉 Virtual Threads Load Testing Completed!"
    echo ""
    echo "For more information about Virtual Threads and Helidon Níma,"
    echo "check the VIRTUAL-THREADS-GUIDE.md file."
}

# Check if jq is available for JSON formatting
if ! command -v jq &> /dev/null; then
    echo "Note: jq not found. Install for better JSON formatting:"
    echo "  Ubuntu/Debian: sudo apt-get install jq"
    echo "  macOS: brew install jq"
    echo "  Windows: choco install jq"
    echo ""
fi

# Check if Apache Bench is available
if ! command -v ab &> /dev/null; then
    echo "Note: Apache Bench not found. Install for detailed performance testing:"
    echo "  Ubuntu/Debian: sudo apt-get install apache2-utils"
    echo "  macOS: brew install httpd"
    echo ""
fi

# Run main function
main "$@"
