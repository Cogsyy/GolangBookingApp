FROM golang:1.25.1-trixie AS builder

# Set the working directory inside the container
WORKDIR /app

# Copy go.mod
COPY go.mod ./

# Download Go module dependencies
RUN go mod download

COPY helper /app/

# Build the Go application
# CGO_ENABLED=0 disables Cgo, making the binary statically linked and smaller
# -o app specifies the output binary name as 'app'
RUN CGO_ENABLED=0 GOOS=linux go build -a -installsuffix cgo -o app .

# Stage 2: Runner
# Use a minimal base image like scratch or alpine for the final image
FROM alpine:latest

# Create a non-root user and group for security
RUN addgroup -S appuser && adduser -S appuser -G appuser

# Set the working directory
WORKDIR /app

# Copy the built binary from the builder stage
COPY --from=builder /app/app .

# Change ownership of the application binary to the non-root user
RUN chown appuser:appuser /app/app

# Switch to the non-root user
USER appuser

# Expose the port your application listens on (adjust as needed)
EXPOSE 8080

# Define the command to run the application
CMD ["go run main.go"]