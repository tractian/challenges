# Front-End Software Engineer — System Design Interview

## Overview

This module will focus on your ability to architect a system. Rather than writing out code line by line, you'll be asked to create the high level design for a larger domain. This primarily takes place as a whiteboarding exercise, but expect lots of clarifying questions. What are the tradeoffs of using one implementation over another? How does this system scale under load? What's a way to improve performance for our users? What's the best way to model and store this data? You'll want to consider how various systems work together, such as the interaction between the client, server, and storage layers.

We will provide a link to a virtual whiteboard, please make good use of the design space! It's helpful to think about it as a collaborative exercise with a peer. We are working to build a design proposal which could be handed off to a teammate, so we should include whatever level of detail is needed to ensure they are successful.

**What we're looking for:**
- **Comprehensiveness** — does the approach cover all functional requirements and tackle edge cases?
- **Feasibility** — is the solution practical and realistically implementable?
- **Scalability** — does the solution scale as users grow or requirements broaden?
- **Resilience** — real world systems fail as a matter of course — how well does the design tolerate outages?

**Interview Tips:**
- **Clarifying Questions** — understand all aspects of the requirements before designing your solution.
- **Trade Offs** — share the rationale behind using one approach over another.

---

## Context

At TRACTIAN, industrial customers monitor their plants through a hierarchy of **Locations**, **Assets**, and **Components**, visualized as a tree.

- A **Location** represents a physical place in a plant (a factory, a production area, a storage sector). Locations can have **sub-locations**, so very large sites can be broken down to keep the hierarchy organized.
- An **Asset** is a piece of equipment (a conveyor belt, a motor, a pump). Assets can have **sub-assets** — a large asset like a conveyor belt assembly may be composed of several smaller assets.
- A **Component** is an asset that carries a **sensor**. It's the leaf of the tree: the point where physical equipment meets the digital signal.

```
Root
 └── Location
       └── Sub-Location
             └── Asset
                   └── Sub-Asset
                         └── Component (has a sensor)
```

### Sensors

TRACTIAN's hardware line — **Smart Trac** and **Energy Trac** — listens to machines, and the platform's AI interprets what it hears into actionable insight. For this design, consider two sensor types:

- **Vibration sensors** capture the vibration signature of an asset (frequency + amplitude) via high-frequency sampling. Signal processing (e.g. spectral analysis) lets the platform tell apart failure modes — an amplitude peak at 1x running speed reads as unbalance, a peak at 2x/3x reads as misalignment. This is what lets us catch bearing wear, misalignment, or cavitation before they cause unplanned downtime.
- **Energy sensors** monitor electrical parameters — current and power consumption — surfacing anomalies in energy draw that often precede a mechanical failure.

### Status

Every component (and, by roll-up, every asset and location above it) has a **status** — think `operating`, `warning`, `alarming`. Status is the visual shorthand for "does the platform currently have an insight open on this asset?" A `warning` or `alarming` status means our AI has flagged a deviation from the asset's healthy baseline and there's a diagnosis/insight worth a human looking at; `operating` means nothing is currently flagged. Status is what a plant manager scans first — it's the entry point from "is everything fine" to "where do I need to send someone."

---

## Data Model

Locations and Assets share a common shape:

| Field | Notes |
|---|---|
| `id` | unique identifier |
| `name` | display name |
| `parentId` / `locationId` | positions the node in the tree — parent can be another node of the same type, or (for assets) a location |
| `description` | free text |
| `users` | people associated with / responsible for this node |
| `image` | reference photo |

Each type also carries fields specific to it:
- **Locations** may carry an `address`.
- **Assets** that are Components carry `sensorId`, `sensorType` (`vibration` \| `energy`), `status`, and `gatewayId` (the device relaying sensor data to the cloud).

---

## Functional Requirements

1. **Visualization** — render the hierarchy as a tree (locations → assets → sub-assets → components), each level visually distinct.
2. **CRUD** — customers can create, read, update, and delete locations, assets, and components anywhere in the tree.
3. **Search & Filters** — search by name; filter by sensor type (`vibration` \| `energy`); filter by status (`operating` \| `warning` \| `alarming`).

[Figma Reference](https://www.figma.com/design/vy7so4jovGWXCAAPcT3iYw/-Careers--Frontend-Challenge?node-id=0-1&t=MOufg4LSia3ORSQe-1) — one possible interface, not a spec to match pixel-for-pixel. Use it to ground the conversation, not to constrain the design.

---

## Things to Consider

- **New sensor types will arrive.** The sensor catalog isn't fixed at vibration/energy — design so a new sensor type doesn't require a structural rework.
- **More asset-related information is coming.** Customers will want to see things like insights (the diagnoses driving a `warning`/`alarming` status), historical trends, and other metadata beyond what's listed above.
- **A user can belong to many companies**, and each company has its own tree, its own sensors, and its own scale — from a handful of assets to plants with thousands.
- **Trees can get deep and wide.** A single company's tree can reach 50,000–100,000+ nodes, with branches 500+ levels deep or a single node fanning out to 5,000+ children. Think about this from both angles:
  - **Processing** — building the tree, finding a node, computing a path to root, filtering (while preserving ancestor paths) all need to stay fast as the tree grows — a brute-force full-tree walk on every operation won't hold up at this scale.
  - **Rendering** — the client can't mount 100,000 DOM nodes at once. Consider what loads eagerly vs. lazily, and how the UI stays responsive while the customer expands, filters, or searches a tree this size.
- **(Bonus) Permissions** — different users may need different levels of access to a company's tree. This is a nice-to-have to raise if time allows, not a requirement.

---

## What We Expect on the Whiteboard

Work through this in two passes:

1. **High-level architecture** — the services involved (client, backend, storage, and anything else you introduce — e.g. how sensor data actually reaches the platform Front-end), and how they communicate with each other.
2. **Detail** — the data structures/schema behind each node type, the routes/APIs the application exposes and consumes, and a top-level sketch of how each part of the system you drew in (1) would actually be implemented.
