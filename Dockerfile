FROM golang:1.25.1-trixie AS builder

# Set the working directory inside the container to /app
WORKDIR /app

# Copy all local files (main.go, helper/) into the working directory
COPY . .

# Download required Go modules and update go.mod/go.sum 
RUN go mod tidy

# Build the Go app, producing a binary named "myapp"
RUN go build -o myapp main.go

# Use the minimal Alpine Linux image for runtime to keep the image small
FROM alpine:latest

# Set the working directory for the app
WORKDIR /app

# Copy the built binary from the builder stage
COPY --from=builder /app/myapp .

# Optional: expose port 8080 if the app runs a web server
EXPOSE 8080

# Set the default command to run your Go app
CMD ["./myapp"]