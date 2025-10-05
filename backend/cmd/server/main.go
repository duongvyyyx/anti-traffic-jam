package main

import (
	"context"
	"log"
	"net/http"
	"os"
	"os/signal"
	"syscall"
	"time"

	"github.com/antitrafficjam/backend/internal/firebase"
	"github.com/antitrafficjam/backend/internal/handlers"
	"github.com/gorilla/mux"
	"github.com/rs/cors"
)

func main() {
	ctx := context.Background()

	credentialsFile := os.Getenv("GOOGLE_APPLICATION_CREDENTIALS")
	if credentialsFile == "" {
		credentialsFile = "config/firebase-credentials.json"
	}

	firebaseClient, err := firebase.NewClient(ctx, credentialsFile)
	if err != nil {
		log.Fatalf("Failed to initialize Firebase client: %v", err)
	}
	defer firebaseClient.Close()

	router := mux.NewRouter()

	reportHandler := handlers.NewReportHandler(firebaseClient)
	eventsHandler := handlers.NewEventsHandler(firebaseClient)

	router.HandleFunc("/report", reportHandler.HandleReport).Methods("POST", "OPTIONS")
	router.HandleFunc("/events", eventsHandler.HandleGetEvents).Methods("GET", "OPTIONS")

	router.HandleFunc("/health", func(w http.ResponseWriter, r *http.Request) {
		w.WriteHeader(http.StatusOK)
		w.Write([]byte("OK"))
	}).Methods("GET")

	c := cors.New(cors.Options{
		AllowedOrigins:   []string{"*"},
		AllowedMethods:   []string{"GET", "POST", "OPTIONS"},
		AllowedHeaders:   []string{"Content-Type", "Authorization"},
		AllowCredentials: true,
	})

	handler := c.Handler(router)

	port := os.Getenv("PORT")
	if port == "" {
		port = "8080"
	}

	server := &http.Server{
		Addr:         ":" + port,
		Handler:      handler,
		ReadTimeout:  15 * time.Second,
		WriteTimeout: 15 * time.Second,
		IdleTimeout:  60 * time.Second,
	}

	go func() {
		log.Printf("Server starting on port %s", port)
		if err := server.ListenAndServe(); err != nil && err != http.ErrServerClosed {
			log.Fatalf("Server failed to start: %v", err)
		}
	}()

	quit := make(chan os.Signal, 1)
	signal.Notify(quit, syscall.SIGINT, syscall.SIGTERM)
	<-quit

	log.Println("Server shutting down...")

	shutdownCtx, cancel := context.WithTimeout(context.Background(), 30*time.Second)
	defer cancel()

	if err := server.Shutdown(shutdownCtx); err != nil {
		log.Fatalf("Server forced to shutdown: %v", err)
	}

	log.Println("Server stopped")
}
