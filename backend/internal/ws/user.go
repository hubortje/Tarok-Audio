package ws

import (
	"github.com/mytja/Tarok/backend/internal/helpers"
	"github.com/mytja/Tarok/backend/internal/messages"
	"github.com/mytja/Tarok/backend/internal/sql"
	"go.uber.org/zap"
)

type userImpl struct {
	ID          string
	User        sql.User
	Clients     []Client
	Cards       []Card
	CardArchive []Card
	GameMode    int32
	Results     int
	logger      *zap.SugaredLogger
}

func NewUser(id string, user sql.User, logger *zap.SugaredLogger) User {
	return &userImpl{
		ID:          id,
		User:        user,
		Clients:     make([]Client, 0),
		Cards:       make([]Card, 0),
		CardArchive: make([]Card, 0),
		GameMode:    -2,
		Results:     0,
		logger:      logger,
	}
}

func (u *userImpl) RemoveClient(clientId string) {
	for i, v := range u.Clients {
		if v.GetClientID() != clientId {
			continue
		}
		u.Clients = helpers.Remove(u.Clients, i)
		break
	}
}

func (u *userImpl) GetClients() []Client {
	return u.Clients
}

func (u *userImpl) BroadcastToClients(message *messages.Message) {
	for _, v := range u.Clients {
		v.Send(message)
	}
}

func (u *userImpl) SendToClient(clientId string, message *messages.Message) {
	for _, v := range u.Clients {
		if v.GetClientID() != clientId {
			continue
		}
		v.Send(message)
	}
}

func (u *userImpl) ResetGameVariables() {
	u.CardArchive = make([]Card, 0)
	u.Cards = make([]Card, 0)
	u.GameMode = -2
}

func (u *userImpl) GetUser() sql.User {
	return u.User
}

func (u *userImpl) AddCard(card Card) {
	u.Cards = append(u.Cards, card)
	u.CardArchive = append(u.CardArchive, card)
}

func (u *userImpl) ResendCards() {
	for _, c := range u.Cards {
		u.logger.Debugw("resending cards", "cardId", c.id)
		u.BroadcastToClients(&messages.Message{
			PlayerId: u.ID,
			Data: &messages.Message_Card{
				Card: &messages.Card{
					Id: c.id,
					Type: &messages.Card_Receive{
						Receive: &messages.Receive{},
					},
				},
			},
		})
	}
}

func (u *userImpl) NewClient(client Client) {
	u.Clients = append(u.Clients, client)
}

func (u *userImpl) ImaKarto(karta string) bool {
	for _, v := range u.Cards {
		if karta != v.id {
			continue
		}
		return true
	}
	return false
}

func (u *userImpl) GetCards() []Card {
	return u.Cards
}

func (u *userImpl) GetArchivedCards() []Card {
	return u.CardArchive
}

func (u *userImpl) RemoveCard(card int) {
	u.Cards = helpers.Remove(u.Cards, card)
}

func (u *userImpl) RemoveCardByID(card string) {
	for i, v := range u.Cards {
		if v.id != card {
			continue
		}
		u.Cards = helpers.Remove(u.Cards, i)
		u.logger.Debug("found my card")
		return
	}
	u.logger.Warn("I haven't found the card")
}

func (u *userImpl) AssignArchive() {
	u.CardArchive = make([]Card, 0)
	u.CardArchive = append(u.CardArchive, u.Cards...)
}

func (u *userImpl) SetGameMode(mode int32) {
	u.GameMode = mode
}

func (u *userImpl) GetGameMode() int32 {
	return u.GameMode
}

func (u *userImpl) AddPoints(points int) {
	u.Results += points
}

func (u *userImpl) GetResults() int {
	return u.Results
}
