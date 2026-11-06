# Architecture

This template follows a layered architecture built around two principles:

1. **Port/Adapter** — isolate every external dependency (IO, network, files, processes, third‑party libraries) behind an interface owned by this project.
2. **Usecase/Service** — separate *what the application does* (usecase) from *how it is implemented* (service).

```
cmd/$PROJECT_NAME/main.go        (composition root / dependency graph)
        │
        ├── subcommand/$SUBCOMMAND  →  Cobra commands
        │        │
        │        └── imports: usecase only
        │
        ├── service/$SERVICE        →  implementation
        │        │
        │        ├── imports: usecase (interfaces + messages), port
        │        └── never imported by anything except main.go
        │
        ├── port/$PORT              →  interfaces for external concerns
        │        ▲
        │        │ implements
        └── adapter/$ADAPTER        →  stdio, net, fs, exec, 3rd‑party libs
```

## Port / Adapter

Every call that reaches outside the program — reading stdin, writing stdout, HTTP, filesystem, spawning processes, wrapping a third‑party library — must go through a **port** interface. The concrete implementation lives in an **adapter** package.

- `port/$PORT/$PORT.go` — declares the interface (e.g. `StdioPort`).
- `adapter/$ADAPTER/$ADAPTER.go` — implements the interface (e.g. `stdio_adapter` wraps real stdout).

Rules:

- Ports are defined by the consumer (the layer that needs them), not by the adapter.
- Adapters may import the port and any external library they need; nothing imports an adapter except `cmd/main.go`.
- Services and usecases depend on port **interfaces**, never on concrete adapters. This keeps business logic testable with fake ports and keeps third‑party APIs from leaking into the codebase.

## Usecase / Service

- `usecase/$USECASE/$USECASE.go` — declares the interface and **all request/response message types** that belong to that usecase.
- `service/$SERVICE/$SERVICE.go` — provides the implementation (`GreetService` implements `greetusecase.GreetUsecase`).

Rules:

- **Import only `usecase`.** Subcommands, other services, and the composition root consume the application through the usecase package — its interface *and* its messages.
- **Never rely on `service`.** No package other than `cmd/main.go` may import a `service` package. The service type is an implementation detail assembled at startup.
- A usecase package depends only on its own messages and on port interfaces. A service package may additionally depend on port interfaces and other usecases.
- Messages are defined next to the usecase, so callers and implementers share one contract without importing the other side.

## Subcommands

Each CLI command is a Cobra subcommand in its own package:

```
subcommand/$SUBCOMMAND/$SUBCOMMAND.go
```

- The package exposes a constructor that returns `*cobra.Command`.
- It accepts its usecase dependencies as constructor arguments (interfaces).
- It imports **usecase packages only** — never `service` or `adapter`.

## Composition root — `cmd/$PROJECT_NAME/main.go`

`main.go` is the only place where concrete types meet:

1. Construct adapters (`stdio_adapter`, etc.).
2. Construct services (`greet_service`) with the adapters they need.
3. Construct subcommands with the usecase interfaces.
4. Attach subcommands to the Cobra root command.
5. `Execute()` the root command.

Nothing else wires dependencies, so the dependency graph stays visible in a single file and every other package remains free of construction logic.
