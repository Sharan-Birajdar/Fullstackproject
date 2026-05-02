# Vault — Full Stack Auth App

A production-ready authentication app with React frontend, Node.js/Express backend, and MongoDB.

## Stack
- **Frontend**: React 18, CSS (no UI library)
- **Backend**: Node.js, Express, JWT, bcryptjs
- **Database**: MongoDB (Mongoose)
- **DevOps**: Docker, Docker Compose

## Project Structure
```
fullstack-auth/
├── backend/
│   ├── models/User.js
│   ├── server.js
│   ├── package.json
│   ├── .env
│   └── Dockerfile
├── frontend/
│   ├── public/index.html
│   ├── src/
│   │   ├── App.js
│   │   ├── App.css
│   │   └── index.js
│   ├── package.json
│   ├── .env
│   └── Dockerfile
└── docker-compose.yml
```

## API Endpoints
| Method | Route      | Auth     | Description        |
|--------|-----------|----------|--------------------|
| GET    | /          | No       | Health check       |
| POST   | /signup    | No       | Register new user  |
| POST   | /signin    | No       | Login, get token   |
| GET    | /profile   | Bearer   | Get user profile   |

## Run with Docker
```bash
docker-compose up --build
```
- Frontend → http://localhost:3000
- Backend  → http://localhost:8000
- MongoDB  → localhost:27017

## Run Locally (without Docker)
```bash
# Backend
cd backend && npm install && npm start

# Frontend (new terminal)
cd frontend && npm install && npm start
```

> ⚠️ For local run, change `REACT_APP_API_URL` in `frontend/.env` to `http://localhost:8000`
> and `MONGO_URI` in `backend/.env` to `mongodb://localhost:27017/authdb`
