# Swift Network Layer (Swift 6)

A native `URLSession` network layer organized with Clean Architecture and SOLID boundaries. It includes typed requests, single-flight token refresh, Keychain storage, redacted logging, certificate pinning, bounded retries, remote-first caching, multipart file transfers, resumable downloads, and UI-only reachability.

## Architecture

```text
SwiftUI View
  -> ViewModel
    -> Use Case
      -> Repository
        -> Remote Data Source -> NetworkClient -> URLSession
        -> Local Data Source  -> DiskCacheStore

AppContainer
  -> constructs and injects every dependency once

AuthSession actor
  -> KeychainTokenStore actor
  -> RefreshTokenService -> unauthenticated NetworkClient
```

Dependencies point inward: Presentation depends on Domain protocols, Data implements those protocols, and Core contains reusable infrastructure. Repositories always try the remote source first. They read the disk cache only for connectivity, timeout, transport, or server failures—not for decoding, authentication, TLS, cancellation, or client errors.

## File structure

```text
NetworkImplementation/
├── App/
│   ├── AppContainer.swift
│   ├── AppSession.swift
│   └── NetworkImplementationApp.swift
├── Core/
│   ├── Cache/
│   ├── Configuration/
│   ├── Network/
│   │   ├── Client/
│   │   ├── Download/
│   │   ├── Logging/
│   │   ├── Models/
│   │   ├── Multipart/
│   │   ├── Request/
│   │   ├── Retry/
│   │   ├── Session/
│   │   └── Transfer/
│   ├── Reachability/
│   └── Security/
│       ├── Authentication/
│       ├── Keychain/
│       └── Pinning/
├── Data/
│   ├── Authentication/{API,DTOs,DataSources,Mappers,Repositories}/
│   ├── Media/{API,DTOs,DataSources,Mappers,Repositories}/
│   ├── Product/{API,DTOs,DataSources,Mappers,Repositories}/
│   └── User/{API,DTOs,DataSources,Mappers,Repositories}/
├── Domain/
│   ├── Authentication/{Entities,Repositories,UseCases}/
│   ├── Media/{Entities,Repositories,UseCases}/
│   ├── Product/{Entities,Repositories,UseCases}/
│   └── User/{Entities,Repositories,UseCases}/
├── Presentation/
│   ├── ViewModels/
│   └── Views/
├── Config/
├── ContentView.swift
└── Info.plist
```

## Implemented safeguards

1. `AuthSession` is an actor and coalesces simultaneous 401 refreshes into one task. Refresh uses its own unauthenticated client, so there is no interceptor cycle.
2. Request and response logs redact authorization, cookies, passwords, tokens, API secrets, card data, and SSNs. Production logging is disabled by configuration.
3. `CertificatePinningDelegate` validates normal server trust first, then compares base64 SHA-256 hashes of DER certificates. Pinning configuration fails at startup when enabled without hosts or pins.
4. Disk caching has explicit expiration and controlled fallback via `CacheFallbackPolicy`.
5. `NetworkMonitor` only drives the offline UI banner; it never blocks requests or selects repository data sources.
6. Core boundaries are `Sendable`, mutable shared state is actor-isolated, and the project uses Swift 6 complete concurrency checking.
7. Endpoints return `APIRequest<Response>` and bodies are `Encodable`; the network boundary contains no `[String: Any]` request payloads.
8. Retries are bounded, cancellation-aware, restricted by HTTP idempotency, use exponential backoff with jitter, and honor `Retry-After`.
9. Multipart bodies are streamed to protected temporary files, support binary payloads without loading the full file into memory, validate header values, report progress, and clean up after foreground or background completion. Downloads persist protected resume data and validate their destination, size, MIME type, and SHA-256 digest before becoming visible.

## File transfers

Presentation code should depend on `UploadMediaUseCaseProtocol` and `DownloadMediaUseCaseProtocol`, not directly on `FileTransferClient`. Every returned operation exposes a stable identifier, the underlying URL-session task identifier, an `AsyncStream<TransferProgress>`, explicit cancellation, and an async result.

Background upload identifiers are also used as idempotency keys. Persist the operation identifier in application state if the server supports querying an upload after an app relaunch. The sample `/media` routes and `UploadResponseDTO` are example contracts and must match the real backend before the feature is exercised against production.

## Configuration

Development and production values live in `Config/*.xcconfig`. The sample currently targets `https://dummyjson.com`.

Certificate pinning is intentionally disabled until real pins are supplied. Set these values for each environment:

```text
ENABLE_SSL_PINNING = YES
SSL_PINNED_DOMAIN = api.example.com
SSL_PIN_SHA256_PRIMARY = <base64 SHA-256 DER certificate hash>
SSL_PIN_SHA256_BACKUP = <backup pin for certificate rotation>
```

Never enable pinning with guessed pins. Keep a backup pin so certificate rotation does not lock every client out.

## Build

Open `NetworkImplementation.xcodeproj`, select the Development or Production scheme, and build. The project requires iOS 18.6 and Swift 6.
