package firebase

import (
	"context"
	"log"

	firebase "firebase.google.com/go/v4"
	"cloud.google.com/go/firestore"
	"google.golang.org/api/option"
)

type Client struct {
	Firestore *firestore.Client
	ctx       context.Context
}

func NewClient(ctx context.Context, credentialsFile string) (*Client, error) {
	var opt option.ClientOption
	if credentialsFile != "" {
		opt = option.WithCredentialsFile(credentialsFile)
	}

	app, err := firebase.NewApp(ctx, nil, opt)
	if err != nil {
		return nil, err
	}

	firestoreClient, err := app.Firestore(ctx)
	if err != nil {
		return nil, err
	}

	log.Println("Firebase client initialized successfully")

	return &Client{
		Firestore: firestoreClient,
		ctx:       ctx,
	}, nil
}

func (c *Client) Close() error {
	return c.Firestore.Close()
}
