# LPI Abata Web Application

A modern web application for LPI Abata built with React, Node.js, and PostgreSQL.

## 🚀 Tech Stack

- **Frontend**: React + Vite + Tailwind CSS
- **Backend**: Node.js + Express
- **Database**: PostgreSQL
- **Deployment**: Docker + Docker Compose
- **Proxy**: Nginx Proxy Manager

## 📁 Project Structure
lpi-abata-webapp/
├── frontend/ # React application
├── backend/ # Node.js API server
├── database/ # PostgreSQL init scripts
├── nginx/ # Nginx configuration
├── docker-compose.yml # Docker orchestration
└── README.md
## 🛠️ Quick Start

### Prerequisites
- Docker
- Docker Compose

### Development
```bash
# Clone repository
git clone https://github.com/khidir-jkt48/lpi-abata-webapp.git
cd lpi-abata-webapp

# Copy environment file
cp .env.example .env

# Start services
docker-compose up -d

# Access application
# Frontend: http://localhost
# Backend API: http://localhost:5001
# NPM Admin: http://localhost:81

