package greetservice

import (
	greetusecase "gocli/usecase/greet_usecase"
)

type GreetService interface {
}

var _ greetusecase.GreetUsecase = (*GreetService)(nil)
