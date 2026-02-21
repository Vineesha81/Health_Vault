# Build Stage for React Frontend
FROM node:20-slim AS build-stage
WORKDIR /app
COPY package*.json ./
RUN npm install
COPY . .
RUN npm run build

# Production Stage
FROM node:20-slim
WORKDIR /app

# Install Python 3 (required for Priority Engine)
RUN apt-get update && \
    apt-get install -y python3 python3-pip && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Copy backend files
COPY server/package*.json ./server/
RUN cd server && npm install

# Copy built frontend from build-stage
COPY --from=build-stage /app/dist ./dist

# Copy the rest of the backend files
COPY server/ ./server/

# Move to server directory
WORKDIR /app/server

# Set environment variables
ENV NODE_ENV=production
ENV PORT=10000

# Start the server
EXPOSE 10000
CMD ["node", "index.js"]
