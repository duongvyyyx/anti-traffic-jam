package models

import "time"

type EventType string

const (
	EventTypeTrafficJam   EventType = "traffic_jam"
	EventTypeAccident     EventType = "accident"
	EventTypeConstruction EventType = "construction"
	EventTypePolice       EventType = "police"
)

func (e EventType) IsValid() bool {
	switch e {
	case EventTypeTrafficJam, EventTypeAccident, EventTypeConstruction, EventTypePolice:
		return true
	}
	return false
}

type TrafficEvent struct {
	ID        string    `json:"id" firestore:"id"`
	Type      EventType `json:"type" firestore:"type"`
	Latitude  float64   `json:"latitude" firestore:"latitude"`
	Longitude float64   `json:"longitude" firestore:"longitude"`
	Timestamp int64     `json:"timestamp" firestore:"timestamp"`
	UserID    string    `json:"userId" firestore:"userId"`
}

type ReportRequest struct {
	Type      EventType `json:"type"`
	Latitude  float64   `json:"latitude"`
	Longitude float64   `json:"longitude"`
}

type EventsQuery struct {
	Latitude float64
	Longitude float64
	RadiusKm float64
}

func NewTrafficEvent(eventType EventType, lat, lon float64, userID string) *TrafficEvent {
	return &TrafficEvent{
		Type:      eventType,
		Latitude:  lat,
		Longitude: lon,
		Timestamp: time.Now().UnixMilli(),
		UserID:    userID,
	}
}
