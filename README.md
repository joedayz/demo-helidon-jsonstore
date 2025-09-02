# 🚀 Helidon + Virtual Threads Demo

**A demonstration application showcasing the power of Java Virtual Threads with Helidon and Oracle JSON Database**

## ✨ Features

- **Virtual Threads**: Complete implementation with Java 21
- **Helidon Framework**: Modern and efficient web server
- **Oracle JSON Database**: Native JSON document storage
- **Load Testing**: Scripts to test performance and scalability
- **Docker Support**: Ready-to-use containers

## 🚀 Quick Start

### Prerequisites

- Java 21+
- Docker and Docker Compose
- PowerShell (Windows) or Bash (Linux/Mac)

### 1. Clone and run

```bash
git clone <repository-url>
cd demo-helidon-jsonstore
```

### 2. Start with Docker

```bash
# Start Oracle Database
docker-compose up -d

# Wait for database to be ready (2-3 minutes)
```

### 3. Run the application

```bash
# Windows
.\start-demo.ps1

# Linux/Mac
./start-demo.sh
```

### 4. Test endpoints

```bash
# Health check
curl http://localhost:8081/health

# Virtual Threads endpoints
curl http://localhost:8081/virtual-threads/health
curl http://localhost:8081/virtual-threads/info
```

## 📊 Load Testing

### PowerShell (Windows)
```powershell
.\virtual-threads-load-test.ps1
```

### Bash (Linux/Mac)
```bash
./virtual-threads-load-test.sh
```

## 🔧 Available Endpoints

| Endpoint | Description |
|----------|-------------|
| `/health` | General application status |
| `/virtual-threads/health` | Virtual Threads service status |
| `/virtual-threads/info` | System information |
| `/virtual-threads/benchmark?count=N` | Performance benchmark |
| `/virtual-threads/concurrent?count=N` | Concurrent processing |
| `/virtual-threads/batch?count=N&batchSize=M` | Batch processing |

## 📁 Project Structure

```
├── src/                    # Java source code
├── docker-compose.yml      # Oracle Database configuration
├── start-demo.ps1         # Startup script (Windows)
├── start-demo.sh          # Startup script (Linux/Mac)
├── virtual-threads-load-test.ps1  # Load testing (Windows)
├── virtual-threads-load-test.sh   # Load testing (Linux/Mac)
└── init.sql               # Database initialization script
```

## 🎯 Use Cases

- **High-performance microservices**
- **REST APIs with high concurrency**
- **Batch data processing**
- **Scalable I/O-bound applications**

## 📚 More Information

- **Technical Article**: [https://blog.joedayz.pe/](https://blog.joedayz.pe/java-virtual-threads-in-action-managing-expenses-with-helidon-nima-and-oracle-database-23ai-json-store) - Detailed implementation and comparisons
- **Documentation**: [docs/](docs/) - Advanced guides and examples

## 🤝 Contributing

1. Fork the project
2. Create a branch for your feature
3. Commit your changes
4. Push to the branch
5. Open a Pull Request

## 📄 License

This project is licensed under the [Apache 2.0](LICENSE) license.

---

**Need help?** Check [https://blog.joedayz.pe/](https://blog.joedayz.pe/java-virtual-threads-in-action-managing-expenses-with-helidon-nima-and-oracle-database-23ai-json-store) for technical details or open an issue on GitHub.
