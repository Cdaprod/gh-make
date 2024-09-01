# Use the official Golang image from Docker Hub
FROM golang:latest

# Set the Current Working Directory inside the container
WORKDIR /app

# Copy the local code to the container
COPY . .

# Download necessary Go modules
RUN go mod tidy

# Command to run when the container starts
CMD ["bash", ".github/environments/.py/init"]