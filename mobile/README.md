# Mobile Software Engineer — System Design Challenge

## Context

Industrial companies organize their operation around **locations**, **assets**, and **components**. A location can contain sub-locations and assets; an asset can contain sub-assets and components; and some components or assets may not have a parent.

A practical way to navigate this information is an asset tree:

```text
- Root
  |
  ├── Location A
  |     ├── Asset 1
  |     |     ├── Component A1
  |     |     └── Component A2
  |     └── Asset 2
  |
  ├── Location B
  |     └── Location C
  |           └── Asset 3
  |                 └── Component C1
  |
  └── Component X
```

Field technicians need to browse this hierarchy, find equipment quickly, inspect its condition, and continue working when connectivity is slow or unavailable.

## Challenge

> 📌 **Design the mobile system that lets users navigate and inspect a company's asset hierarchy.**

This is a **system-design challenge**. We want to understand how you structure a mobile product, make trade-offs, and communicate decisions. You are **not** expected to build a production-ready application.

Your proposal should be detailed enough that a mobile team could use it as the starting point for implementation. State reasonable assumptions whenever a requirement is intentionally open.

## Domain Model

### Locations and sub-locations

Locations represent where assets are installed. A location can contain any number of sub-locations.

- A location with no `parentId` is attached to the root.
- A location with a `parentId` is a child of another location.
- Locations are represented by this icon in the reference design:

![Location](../assets/location.png)

### Assets and sub-assets

Assets represent equipment such as motors, fans, and conveyor belts. Large assets may contain any number of sub-assets and components.

- An asset can belong to a location through `locationId`.
- An asset can be nested under another asset through `parentId`.
- An asset with neither relationship is attached to the root.
- Assets are represented by this icon in the reference design:

![Asset](../assets/asset.png)

### Components

Components represent sensors or other parts associated with an asset or location.

- An item with a `sensorType` is a component.
- Components commonly use `energy` or `vibration` sensors.
- Their status can be `operating` or `alert`.
- A component may belong to an asset through `parentId`, belong directly to a location through `locationId`, or remain attached to the root when both fields are absent.
- Components are represented by this icon in the reference design:

![Component](../assets/component.png)

## Product Requirements

Design the following core experience.

### 1. Company selection

The user can view the available companies and select one to access its asset hierarchy. Explain what should happen when the user changes companies and how company-specific state is isolated or restored.

### 2. Asset-tree navigation

The user can:

- Navigate a dynamic tree of locations, sub-locations, assets, sub-assets, and components.
- Expand and collapse branches.
- Select an item and inspect all metadata available for it.
- Understand the type and status of each item.
- Return to the same useful context after navigating to details or after the application is interrupted.

Your design should account for malformed or incomplete relationships, such as a missing parent, duplicate identifiers, or cycles. Explain whether these cases are handled by the client, the backend, or both.

### 3. Filters

The tree supports these filters:

- **Text search:** matches locations, assets, or components by name.
- **Energy sensors:** shows components whose `sensorType` is `energy`.
- **Critical sensor status:** shows components whose `status` is `alert`.

When a filter matches an item, its complete ancestor path must remain visible. Unrelated branches should be hidden. Define how multiple active filters interact and how expansion state behaves while filters are applied and removed.

### 4. Mobile states

Include the experience for:

- Initial and incremental loading.
- Empty companies or empty hierarchies.
- Recoverable and non-recoverable errors.
- Retry and cancellation.
- Cached or stale data.
- Intermittent connectivity and offline use.
- Application backgrounding, process termination, and restoration.

## Data Contract

The provided dataset exposes three resources.

### Company

```json
{
  "id": "662fd0ee639069143a8fc387",
  "name": "Jaguar"
}
```

### Location

```json
{
  "id": "656a07b3f2d4a1001e2144bf",
  "name": "CHARCOAL STORAGE SECTOR",
  "parentId": "65674204664c41001e91ecb4"
}
```

`parentId` is optional. When present, it references another location.

### Asset

```json
{
  "id": "656a07bbf2d4a1001e2144c2",
  "name": "CONVEYOR BELT ASSEMBLY",
  "locationId": "656a07b3f2d4a1001e2144bf",
  "parentId": null,
  "sensorType": null,
  "status": null
}
```

An item without a `sensorType` is an asset. `locationId` associates it with a location, while `parentId` associates it with another asset.

### Component

```json
{
  "id": "656a07cdc50ec9001e84167b",
  "name": "MOTOR RT COAL AF01",
  "parentId": "656a07c3f2d4a1001e2144c5",
  "sensorId": "FIJ309",
  "sensorType": "vibration",
  "status": "operating",
  "gatewayId": "FRH546",
  "locationId": null
}
```

An item with a `sensorType` is a component. Depending on the available relationship, it can appear under an asset, directly under a location, or at the root.

Together, the location and asset collections produce a hierarchy such as:

```text
- ROOT
  |
  ├── PRODUCTION AREA - RAW MATERIAL [Location]
  |     └── CHARCOAL STORAGE SECTOR [Sub-location]
  |           └── CONVEYOR BELT ASSEMBLY [Asset]
  |                 └── MOTOR TC01 COAL UNLOADING AF02 [Sub-asset]
  |                       └── MOTOR RT COAL AF01 [Component]
  |
  └── Fan - External [Component]
```

The dataset provides complete collections rather than a preassembled tree or a paginated hierarchy. Your design should work with this contract and may also propose how the contract could evolve.

## What Your Design Should Cover

### Mobile architecture

Describe the main modules or layers, their responsibilities, dependencies, and data ownership. Include the boundaries between presentation, domain logic, persistence, networking, and platform capabilities.

You may choose native or cross-platform technologies. Explain the choice only where it affects architecture, performance, delivery, testing, or platform integration. The quality of the reasoning matters more than the framework selected.

### State and navigation

Explain:

- Where company, tree, selection, filter, and expansion state live.
- How state changes flow through the application.
- How screens or features communicate without creating unnecessary coupling.
- Which state is transient, persisted, restored, or derived.

### Data access and synchronization

Show how the application:

- Fetches companies, locations, and assets.
- Maps transport models to domain and presentation models.
- Defines repository, cache, and persistence boundaries.
- Handles request retries, cancellation, deduplication, and concurrent refreshes.
- Defines cache freshness and communicates stale data to the user.
- Supports useful offline behavior and later synchronization.

The contract is read-only, so document any assumptions about future writes and conflict resolution rather than inventing them as current behavior.

### Tree construction and performance

Explain the data structures and algorithms used to:

- Build the hierarchy from flat collections.
- Detect or isolate invalid relationships.
- Find ancestors and descendants efficiently.
- Apply filters while preserving ancestor paths.
- Maintain expansion and selection state.
- Render and update very large trees without blocking the main thread or exhausting device memory.

Include expected time and space complexity for the important operations. Consider indexing, immutable versus mutable models, background processing, virtualization or flattening of visible nodes, incremental updates, and measurement on lower-end devices.

### Reliability and lifecycle

Cover network failures, partial responses, corrupted cached data, retries, timeouts, app backgrounding, process death, and recovery. Identify which operations must be idempotent and how race conditions between company changes, refreshes, and filters are prevented.

### Quality attributes

Include your approach to:

- Unit, integration, UI, and contract testing.
- Performance testing with the larger supplied dataset.
- Logs, metrics, traces, crash reporting, and useful product analytics.
- Authentication assumptions, secure local storage, transport security, and sensitive-data handling.
- Accessibility, localization, responsive layouts, and platform conventions.
- Feature flags, schema evolution, and incremental delivery.

## Expected Deliverables

Add a design document to your repository containing:

1. **Requirements and assumptions** — clarify scope, constraints, and the questions you would ask product or backend teams.
2. **Architecture diagram** — show the main components, responsibilities, dependencies, and external systems.
3. **Data model and data flow** — include sequence or flow diagrams for:
   - Initial company/tree loading.
   - Applying a filter.
   - At least one offline or failure scenario.
4. **Tree strategy** — explain construction, filtering, rendering, complexity, and how you would validate performance.
5. **Persistence and synchronization strategy** — define caching, freshness, restoration, and error behavior.
6. **Testing and observability strategy** — identify the most important tests, signals, and service-level expectations.
7. **Trade-offs and evolution** — document alternatives you rejected, important risks, and what you would validate first.

Pseudocode, interfaces, and focused prototypes or benchmarks are welcome when they make a risky decision easier to evaluate, but polished UI and a complete application are not required.

Be prepared to walk through your design, respond to changing requirements, and discuss where a different scale or product constraint would change your decisions.

## Evaluation Criteria

We will evaluate:

- Understanding of the requirements and quality of assumptions.
- Clear boundaries and separation of concerns.
- Correct domain modeling and tree behavior.
- Mobile reliability, lifecycle handling, and offline experience.
- Performance, scalability, and UI responsiveness.
- User experience and accessibility considerations.
- Testing, observability, privacy, and security.
- Clarity of communication and quality of trade-off analysis.

There is no preferred framework or diagramming tool. A simple, coherent design with explicit trade-offs is stronger than an elaborate design that does not explain why its parts exist.

## Bonus Challenges

The following challenges are **optional**. They are evaluated separately and are not required for a complete core submission.

### Bonus 1: Geolocation-ready locations and assets

Extend your proposal so locations and assets can be associated with geographic coordinates. The current API does not provide geolocation fields, so define the future contract and migration you would propose.

A possible value object could include:

```json
{
  "latitude": -23.55052,
  "longitude": -46.633308,
  "accuracyMeters": 12.5,
  "capturedAt": "2026-07-28T14:30:00Z",
  "source": "device_gps"
}
```

Your design should discuss:

- Fixed coordinates for a location versus the last known or manually captured position of a movable asset.
- How geolocation is represented, validated, versioned, cached, and synchronized.
- Device permission flows, denied or limited permissions, precision, consent, and privacy.
- Offline capture, queued updates, retry, deduplication, freshness, and conflict behavior.
- Secure storage and transmission of location data.
- Map, nearby-asset, distance, or navigation use cases and the indexes or backend capabilities they require.
- How to isolate the core domain from a specific map or geolocation provider.
- Battery, background-execution, and platform-policy implications if the product later requires repeated updates.

Include the architecture changes, one representative data flow, and the most important trade-offs. You do not need to design a continuous tracking platform.

### Bonus 2: AI-assisted asset nameplate identification

Extend your proposal so a technician can photograph an equipment nameplate and receive ranked asset matches. A match may use `modelId`, serial number, voltage, manufacturer, and other extracted specifications.

The current API does not expose these fields or an image-recognition endpoint. Propose the contracts, states, and integration boundaries needed for this future capability.

Design a human-in-the-loop flow that covers:

1. Capturing or selecting an image and validating its quality.
2. Uploading or processing the image with clear progress and cancellation behavior.
3. Extracting and normalizing text and specifications through OCR or a vision service.
4. Finding and ranking possible assets using exact, fuzzy, and specification-based matches.
5. Presenting confidence, matched fields, ambiguity, no-match, and error states.
6. Letting the user confirm, reject, or correct the result before any asset is selected or updated.

A possible asynchronous result could look like:

```json
{
  "recognitionId": "rec_01J3XYZ",
  "status": "needs_confirmation",
  "extracted": {
    "manufacturer": "Example Motors",
    "modelId": "EM-440X",
    "serialNumber": "SN-847291",
    "voltage": "440 V",
    "specifications": {
      "power": "75 kW",
      "frequency": "60 Hz"
    }
  },
  "matches": [
    {
      "assetId": "656a07c3f2d4a1001e2144c5",
      "confidence": 0.93,
      "matchedFields": ["modelId", "serialNumber", "voltage"]
    }
  ]
}
```

Your design should discuss:

- On-device, server-side, or hybrid OCR and matching, including offline behavior.
- Request, upload, asynchronous job, retry, and cancellation states.
- Image compression, latency, bandwidth, battery use, service cost, and graceful degradation.
- Confidence calibration, conflicting fields, duplicate serial numbers, unknown models, and false matches.
- Image privacy, user consent, encryption, retention, deletion, and access control.
- Model and data versioning, observability, quality metrics, and a feedback loop based on user corrections.
- How this feature integrates with the core architecture without coupling the application to one AI provider.

You are not expected to train an AI model. We are evaluating the mobile and system-integration design, the matching strategy, and how safely the experience handles uncertainty.

## References

### Product reference

[Figma — Flutter Challenge v2](https://www.figma.com/file/IP50SSLkagXsUNWiZj0PjP/%5BCareers%5D-Flutter-Challenge-v2?type=design&node-id=0%3A1&mode=design&t=puUgGuBG9v8leaSQ-1)

Use the Figma file to understand the product and main flows. You do not need to reproduce its visual design, and the architecture should not depend on Flutter unless that is part of your chosen approach.

### Dataset

The dataset is organized around three resources:

- Companies — the full list of available companies.
- Locations — all locations for a company.
- Assets — all assets and components for a company.

The dataset is available at [`assets/api-data.json`](../assets/api-data.json). Use it to inspect data shape, edge cases, and performance characteristics. Treat it as the response of a read-only backend when designing your data access and synchronization strategy.
