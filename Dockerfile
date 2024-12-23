# Use Node.js base image
FROM node:18-alpine

# Set the working directory in the container
WORKDIR /app

# Copy package.json and package-lock.json from chessboardjs
COPY ./chess-web/chessboardai/package*.json ./

# Install dependencies
RUN npm install

# Copy the entire chessboardjs folder
COPY ./chess-web/chessboardai ./chessboardai

# Copy the entire chess.js folder (if needed for app logic)
COPY ./chessai.js ./chessai.js

# Copy server.js and index.html from chessboardjs
COPY ./chess-web/server.js ./server.jsdo
COPY ./chess-web/index.html ./index.html

# Expose the port
EXPOSE 3002

# Start the Node.js server
CMD ["node", "server.js"]
