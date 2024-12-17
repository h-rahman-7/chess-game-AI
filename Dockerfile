# Use Node.js base image
FROM node:18-alpine

# Set the working directory in the container
WORKDIR /app

# Copy package.json and package-lock.json from chessboardjs
COPY ./chess-web/chessboardjs/package*.json ./

# Install dependencies
RUN npm install

# Copy the entire chessboardjs folder
COPY ./chess-web/chessboardjs ./chessboardjs

# Copy the entire chess.js folder (if needed for app logic)
COPY ./chess.js ./chess.js

# Copy server.js and index.html from chessboardjs
COPY ./chess-web/server.js ./server.jsdo
COPY ./chess-web/index.html ./index.html

# Expose the port
EXPOSE 3002

# Start the Node.js server
CMD ["node", "server.js"]
