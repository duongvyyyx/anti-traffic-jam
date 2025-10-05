package handlers

import (
	"encoding/json"
	"net/http"
	"strconv"

	"github.com/antitrafficjam/backend/internal/firebase"
	"github.com/antitrafficjam/backend/internal/models"
)

type EventsHandler struct {
	firebaseClient *firebase.Client
}

func NewEventsHandler(fc *firebase.Client) *EventsHandler {
	return &EventsHandler{
		firebaseClient: fc,
	}
}

func (h *EventsHandler) HandleGetEvents(w http.ResponseWriter, r *http.Request) {
	if r.Method != http.MethodGet {
		http.Error(w, "Method not allowed", http.StatusMethodNotAllowed)
		return
	}

	latStr := r.URL.Query().Get("lat")
	lonStr := r.URL.Query().Get("lon")
	radiusStr := r.URL.Query().Get("radius")

	lat, err := strconv.ParseFloat(latStr, 64)
	if err != nil {
		http.Error(w, "Invalid latitude", http.StatusBadRequest)
		return
	}

	lon, err := strconv.ParseFloat(lonStr, 64)
	if err != nil {
		http.Error(w, "Invalid longitude", http.StatusBadRequest)
		return
	}

	radius := 10.0
	if radiusStr != "" {
		r, err := strconv.ParseFloat(radiusStr, 64)
		if err == nil && r > 0 {
			radius = r
		}
	}

	query := models.EventsQuery{
		Latitude:  lat,
		Longitude: lon,
		RadiusKm:  radius,
	}

	events, err := h.firebaseClient.GetEventsNearby(query)
	if err != nil {
		http.Error(w, "Failed to fetch events", http.StatusInternalServerError)
		return
	}

	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(events)
}
