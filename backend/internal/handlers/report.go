package handlers

import (
	"encoding/json"
	"net/http"

	"github.com/antitrafficjam/backend/internal/firebase"
	"github.com/antitrafficjam/backend/internal/models"
	"github.com/google/uuid"
)

type ReportHandler struct {
	firebaseClient *firebase.Client
}

func NewReportHandler(fc *firebase.Client) *ReportHandler {
	return &ReportHandler{
		firebaseClient: fc,
	}
}

func (h *ReportHandler) HandleReport(w http.ResponseWriter, r *http.Request) {
	if r.Method != http.MethodPost {
		http.Error(w, "Method not allowed", http.StatusMethodNotAllowed)
		return
	}

	var req models.TrafficEvent
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		http.Error(w, "Invalid request body", http.StatusBadRequest)
		return
	}

	if !req.Type.IsValid() {
		http.Error(w, "Invalid event type", http.StatusBadRequest)
		return
	}

	if req.Latitude < -90 || req.Latitude > 90 {
		http.Error(w, "Invalid latitude", http.StatusBadRequest)
		return
	}

	if req.Longitude < -180 || req.Longitude > 180 {
		http.Error(w, "Invalid longitude", http.StatusBadRequest)
		return
	}

	if req.ID == "" {
		req.ID = uuid.New().String()
	}

	if req.UserID == "" {
		req.UserID = "anonymous"
	}

	if err := h.firebaseClient.SaveEvent(&req); err != nil {
		http.Error(w, "Failed to save event", http.StatusInternalServerError)
		return
	}

	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(http.StatusCreated)
	json.NewEncoder(w).Encode(map[string]string{
		"status": "success",
		"id":     req.ID,
	})
}
