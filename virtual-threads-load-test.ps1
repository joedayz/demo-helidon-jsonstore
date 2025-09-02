# 🚀 Virtual Threads Load Testing Script (PowerShell)
# This script demonstrates the performance benefits of Java Virtual Threads
# by testing various endpoints with different concurrency levels.

param(
    [string]$BaseUrl = "http://localhost:8081"
)

# Colors for output
$Red = "Red"
$Green = "Green"
$Yellow = "Yellow"
$Blue = "Blue"
$White = "White"

# Function to print colored output
function Write-Status {
    param(
        [string]$Color,
        [string]$Message
    )
    Write-Host $Message -ForegroundColor $Color
}

# Function to check if endpoint is accessible
function Test-Endpoint {
    param([string]$Endpoint)
    
    try {
        $response = Invoke-WebRequest -Uri "$BaseUrl$Endpoint" -Method GET -UseBasicParsing -TimeoutSec 10
        return $response.StatusCode -eq 200
    }
    catch {
        return $false
    }
}

# Function to run performance test
function Test-Performance {
    param(
        [string]$Endpoint,
        [int]$Concurrency,
        [int]$Requests
    )
    
    Write-Status $Blue "Testing: $Endpoint"
    Write-Status $Blue "Concurrency: $Concurrency, Requests: $Requests"
    
    try {
        $stopwatch = [System.Diagnostics.Stopwatch]::StartNew()
        
        # Create jobs for concurrent requests
        $jobs = @()
        for ($i = 1; $i -le $Requests; $i++) {
            $job = Start-Job -ScriptBlock {
                param($url)
                try {
                    Invoke-WebRequest -Uri $url -Method GET -UseBasicParsing -TimeoutSec 30 | Out-Null
                    return $true
                }
                catch {
                    return $false
                }
            } -ArgumentList "$BaseUrl$Endpoint"
            
            $jobs += $job
            
            # Control concurrency
            if ($i % $Concurrency -eq 0) {
                Wait-Job -Job $jobs | Out-Null
            }
        }
        
        # Wait for remaining jobs
        Wait-Job -Job $jobs | Out-Null
        
        $stopwatch.Stop()
        $duration = $stopwatch.ElapsedMilliseconds
        
        # Get job results
        $results = Receive-Job -Job $jobs
        $successCount = ($results | Where-Object { $_ -eq $true }).Count
        
        Write-Host "Completed $Requests requests in ${duration}ms" -ForegroundColor $White
        Write-Host "Successful requests: $successCount" -ForegroundColor $White
        Write-Host "Average time per request: $([math]::Round($duration / $Requests, 2))ms" -ForegroundColor $White
        Write-Host "Requests per second: $([math]::Round($Requests * 1000 / $duration, 2))" -ForegroundColor $White
        
        # Clean up jobs
        Remove-Job -Job $jobs -Force
    }
    catch {
        Write-Status $Red "Error during performance test: $($_.Exception.Message)"
    }
    
    Write-Host "----------------------------------------" -ForegroundColor $White
}

# Function to test virtual threads health
function Test-VirtualThreadsHealth {
    Write-Status $Yellow "Testing Virtual Threads Health..."
    
    if (Test-Endpoint "/virtual-threads/health") {
        Write-Status $Green "Virtual Threads service is healthy"
        
        # Get service info
        Write-Host "Service Information:" -ForegroundColor $White
        try {
            $info = Invoke-WebRequest -Uri "$BaseUrl/virtual-threads/info" -Method GET -UseBasicParsing
            $info.Content | ConvertFrom-Json | ConvertTo-Json -Depth 10
        }
        catch {
            Write-Host "Could not retrieve service info" -ForegroundColor $Red
        }
        Write-Host ""
    }
    else {
        Write-Status $Red "Virtual Threads service is not accessible"
        return $false
    }
}

# Function to run benchmark comparison
function Test-Benchmark {
    Write-Status $Yellow "Running Performance Benchmark..."
    
    $counts = @(100, 500, 1000)
    
    foreach ($count in $counts) {
        Write-Host "Benchmarking with $count expenses..." -ForegroundColor $White
        
        if (Test-Endpoint "/virtual-threads/benchmark?count=$count") {
            try {
                $result = Invoke-WebRequest -Uri "$BaseUrl/virtual-threads/benchmark?count=$count" -Method GET -UseBasicParsing
                Write-Host "Benchmark result:" -ForegroundColor $White
                try {
                    $result.Content | ConvertFrom-Json | ConvertTo-Json -Depth 10
                }
                catch {
                    Write-Host $result.Content -ForegroundColor $White
                }
                Write-Host ""
            }
            catch {
                Write-Status $Red "Error during benchmark: $($_.Exception.Message)"
            }
        }
        else {
            Write-Status $Red "Benchmark endpoint not accessible"
        }
        
        Start-Sleep -Seconds 2
    }
}

# Function to test concurrent processing
function Test-ConcurrentProcessing {
    Write-Status $Yellow "Testing Concurrent Processing..."
    
    $counts = @(100, 500, 1000)
    $concurrencyLevels = @(10, 50, 100)
    
    foreach ($count in $counts) {
        foreach ($concurrency in $concurrencyLevels) {
            Write-Host "Testing $count expenses with concurrency $concurrency..." -ForegroundColor $White
            
            if (Test-Endpoint "/virtual-threads/concurrent?count=$count") {
                $stopwatch = [System.Diagnostics.Stopwatch]::StartNew()
                
                # Start concurrent requests
                $jobs = @()
                for ($i = 1; $i -le $concurrency; $i++) {
                    $job = Start-Job -ScriptBlock {
                        param($url)
                        try {
                            Invoke-WebRequest -Uri $url -Method GET -UseBasicParsing -TimeoutSec 30 | Out-Null
                            return $true
                        }
                        catch {
                            return $false
                        }
                    } -ArgumentList "$BaseUrl/virtual-threads/concurrent?count=$count"
                    
                    $jobs += $job
                }
                
                Wait-Job -Job $jobs | Out-Null
                $stopwatch.Stop()
                $duration = $stopwatch.ElapsedMilliseconds
                
                Write-Host "  Completed $concurrency concurrent requests in ${duration}ms" -ForegroundColor $White
                Write-Host "  Average time per request: $([math]::Round($duration / $concurrency, 2))ms" -ForegroundColor $White
                
                # Clean up jobs
                Remove-Job -Job $jobs -Force
            }
            
            Start-Sleep -Seconds 1
        }
        Write-Host ""
    }
}

# Function to test batch processing
function Test-BatchProcessing {
    Write-Status $Yellow "Testing Batch Processing..."
    
    $batchConfigs = @(
        @{Count = 1000; BatchSize = 100},
        @{Count = 5000; BatchSize = 500},
        @{Count = 10000; BatchSize = 1000}
    )
    
    foreach ($config in $batchConfigs) {
        $count = $config.Count
        $batchSize = $config.BatchSize
        
        Write-Host "Testing batch processing: $count expenses in batches of $batchSize..." -ForegroundColor $White
        
        if (Test-Endpoint "/virtual-threads/batch?count=$count&batchSize=$batchSize") {
            $stopwatch = [System.Diagnostics.Stopwatch]::StartNew()
            
            try {
                Invoke-WebRequest -Uri "$BaseUrl/virtual-threads/batch?count=$count&batchSize=$batchSize" -Method GET -UseBasicParsing | Out-Null
                
                $stopwatch.Stop()
                $duration = $stopwatch.ElapsedMilliseconds
                
                Write-Host "  Batch processing completed in ${duration}ms" -ForegroundColor $White
                Write-Host "  Throughput: $([math]::Round($count * 1000 / $duration, 2)) expenses/second" -ForegroundColor $White
            }
            catch {
                Write-Status $Red "Error during batch processing: $($_.Exception.Message)"
            }
        }
        
        Start-Sleep -Seconds 2
    }
    Write-Host ""
}

# Function to test concurrent queries
function Test-ConcurrentQueries {
    Write-Status $Yellow "Testing Concurrent Database Queries..."
    
    if (Test-Endpoint "/virtual-threads/concurrent-queries") {
        $iterations = 10
        
        Write-Host "Running $iterations iterations of concurrent queries..." -ForegroundColor $White
        
        $totalTime = 0
        for ($i = 1; $i -le $iterations; $i++) {
            $stopwatch = [System.Diagnostics.Stopwatch]::StartNew()
            
            try {
                Invoke-WebRequest -Uri "$BaseUrl/virtual-threads/concurrent-queries" -Method GET -UseBasicParsing | Out-Null
                
                $stopwatch.Stop()
                $duration = $stopwatch.ElapsedMilliseconds
                $totalTime += $duration
                
                Write-Host "  Iteration $i`: ${duration}ms" -ForegroundColor $White
            }
            catch {
                Write-Status $Red "Error in iteration $i`: $($_.Exception.Message)"
            }
        }
        
        $avgTime = [math]::Round($totalTime / $iterations, 2)
        Write-Host "  Average query time: ${avgTime}ms" -ForegroundColor $White
        Write-Host "  Total time for $iterations iterations: ${totalTime}ms" -ForegroundColor $White
    }
    else {
        Write-Status $Red "Concurrent queries endpoint not accessible"
    }
    Write-Host ""
}

# Function to generate performance report
function Write-PerformanceReport {
    Write-Status $Green "Performance Test Report"
    Write-Host "================================" -ForegroundColor $White
    Write-Host "Test completed at: $(Get-Date)" -ForegroundColor $White
    Write-Host "Base URL: $BaseUrl" -ForegroundColor $White
    Write-Host ""
    
    Write-Host "Tested Endpoints:" -ForegroundColor $White
    $endpoints = @(
        "/virtual-threads/concurrent?count=100",
        "/virtual-threads/concurrent?count=1000",
        "/virtual-threads/batch?count=1000`&batchSize=100",
        "/virtual-threads/concurrent-queries",
        "/virtual-threads/benchmark?count=500"
    )
    
    foreach ($endpoint in $endpoints) {
        Write-Host "  - $endpoint" -ForegroundColor $White
    }
    Write-Host ""
    
    Write-Host "Key Benefits of Virtual Threads:" -ForegroundColor $White
    Write-Host "  - Massive scalability - millions of threads possible" -ForegroundColor $White
    Write-Host "  - Lightweight - ~2KB per thread vs ~1MB for OS threads" -ForegroundColor $White
    Write-Host "  - Perfect for I/O-bound operations" -ForegroundColor $White
    Write-Host "  - Simplified concurrent programming" -ForegroundColor $White
    Write-Host "  - 10x+ performance improvement for I/O-bound tasks" -ForegroundColor $White
    Write-Host ""
    
    Write-Host "Next Steps:" -ForegroundColor $White
    Write-Host "  1. Compare results with traditional thread-based approach" -ForegroundColor $White
    Write-Host "  2. Monitor memory usage during high concurrency" -ForegroundColor $White
    Write-Host "  3. Scale up to test limits of virtual threads" -ForegroundColor $White
    Write-Host "  4. Consider migration to Helidon Nima for maximum benefits" -ForegroundColor $White
}

# Main execution
function Main {
    Write-Host "Java Virtual Threads Load Testing" -ForegroundColor $Green
    Write-Host "====================================" -ForegroundColor $White
    Write-Host "Testing Helidon + Virtual Threads Performance" -ForegroundColor $White
    Write-Host ""
    
    Write-Host "Starting Virtual Threads Load Testing..." -ForegroundColor $White
    Write-Host "Make sure your Helidon application is running on $BaseUrl" -ForegroundColor $White
    Write-Host ""
    
    # Check if application is accessible
    if (-not (Test-Endpoint "/health")) {
        Write-Status $Red "Application is not accessible at $BaseUrl"
        Write-Status $Red "Please start your Helidon application first"
        exit 1
    }
    
    Write-Status $Green "Application is accessible"
    Write-Host ""
    
    # Run tests
    Test-VirtualThreadsHealth
    Write-Host ""
    
    Test-Benchmark
    Write-Host ""
    
    Test-ConcurrentProcessing
    Write-Host ""
    
    Test-BatchProcessing
    Write-Host ""
    
    Test-ConcurrentQueries
    Write-Host ""
    
    # Generate final report
    Write-PerformanceReport
    
    Write-Status $Green "Virtual Threads Load Testing Completed!"
    Write-Host ""
    Write-Host "For more information about Virtual Threads and Helidon Nima," -ForegroundColor $White
    Write-Host "check the VIRTUAL-THREADS-GUIDE.md file." -ForegroundColor $White
}

# Check PowerShell version
if ($PSVersionTable.PSVersion.Major -lt 5) {
    Write-Status $Red "PowerShell 5.0 or higher is required for this script"
    exit 1
}

# Check if Invoke-WebRequest is available
try {
    $null = Get-Command Invoke-WebRequest -ErrorAction Stop
}
catch {
    Write-Status $Red "Invoke-WebRequest is not available. This script requires PowerShell 5.0+"
    exit 1
}

# Run main function
Main
