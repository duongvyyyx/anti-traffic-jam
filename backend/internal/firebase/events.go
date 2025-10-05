package firebase

import (
	"context"
	"math"
	"time"

	"github.com/antitrafficjam/backend/internal/models"
	"google.golang.org/api/iterator"
)

const eventsCollection = "events"

func (c *Client) SaveEvent(event *models.TrafficEvent) error {
	_, _, err := c.Firestore.Collection(eventsCollection).Add(c.ctx, map[string]interface{}{
		"id":        event.ID,
		"type":      string(event.Type),
		"latitude":  event.Latitude,
		"longitude": event.Longitude,
		"timestamp": event.Timestamp,
		"userId":    event.UserID,
	})
	return err
}

func (c *Client) GetEventsNearby(query models.EventsQuery) ([]*models.TrafficEvent, error) {
	ctx, cancel := context.WithTimeout(c.ctx, 10*time.Second)
	defer cancel()

	twoHoursAgo := time.Now().Add(-2 * time.Hour).UnixMilli()

	iter := c.Firestore.Collection(eventsCollection).
		Where("timestamp", ">=", twoHoursAgo).
		Documents(ctx)

	var events []*models.TrafficEvent
	for {
		doc, err := iter.Next()
		if err == iterator.Done {
			break
		}
		if err != nil {
			return nil, err
		}

		var event models.TrafficEvent
		if err := doc.DataTo(&event); err != nil {
			continue
		}

		distance := calculateDistance(
			query.Latitude,
			query.Longitude,
			event.Latitude,
			event.Longitude,
		)

		if distance <= query.RadiusKm {
			events = append(events, &event)
		}
	}

	return events, nil
}

func calculateDistance(lat1, lon1, lat2, lon2 float64) float64 {
	const earthRadius = 6371.0

	lat1Rad := lat1 * math.Pi / 180
	lat2Rad := lat2 * math.Pi / 180
	deltaLat := (lat2 - lat1) * math.Pi / 180
	deltaLon := (lon2 - lon1) * math.Pi / 180

	a := math.Sin(deltaLat/2)*math.Sin(deltaLat/2) +
		math.Cos(lat1Rad)*math.Cos(lat2Rad)*
			math.Sin(deltaLon/2)*math.Sin(deltaLon/2)

	c := 2 * math.Atan2(math.Sqrt(a), math.Sqrt(1-a))

	return earthRadius * c
}
