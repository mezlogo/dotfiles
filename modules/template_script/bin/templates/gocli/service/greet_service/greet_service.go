package greetservice

import (
	greetusecase "gocli/usecase/greetusecase"
)

type GreetService interface {
}

var _ greetusecase.GreetUsecase = (*GreetService)(nil)
