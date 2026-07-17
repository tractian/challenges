# Front-End Software Engineer — System Design Interview

## Overview

Design a high-level system for a larger domain on a virtual whiteboard — no code. Treat it as a collaborative session with a peer: produce a design proposal a teammate could pick up and implement. Expect clarifying questions throughout.

**What we're looking for**

- **Comprehensiveness** — covers the functional requirements and edge cases
- **Feasibility** — practical and realistically implementable
- **Scalability** — holds up as usage and requirements grow
- **Resilience** — tolerates real-world failures and outages

**Tips**

- Clarify requirements before designing
- Call out tradeoffs and why you chose one approach over another

---

## Context

At TRACTIAN, industrial customers monitor plants through a hierarchy of **Locations**, **Assets**, and **Components**, visualized as a tree.

```
Root
 └── Location
       └── Sub-Location
             └── Asset
                   └── Sub-Asset
                         └── Component (has a sensor)
```

- **Location** — a physical place in a plant (factory, production area, storage sector). Can nest sub-locations.
- **Asset** — a piece of equipment (conveyor, motor, pump). Can nest sub-assets.
- **Component** — leaf of the tree: an asset that carries a **sensor** (e.g. vibration, energy).

Every component has a **status** (`operating`, `warning`, `alarming`) that rolls up the tree. Status is the plant manager's first scan: "is everything fine, or where do I send someone?"

---

## Functional Requirements

1. **Visualization** — render the hierarchy as a tree; levels should be visually distinct.
2. **CRUD** — create, read, update, and delete locations, assets, and components anywhere in the tree.
3. **Search & Filters** — search by name; filter by sensor type and by status.

[Figma reference](https://www.figma.com/design/vy7so4jovGWXCAAPcT3iYw/-Careers--Frontend-Challenge?node-id=0-1&t=MOufg4LSia3ORSQe-1) — one possible UI, not a pixel spec. Use it to ground the conversation.

---

## Things to Consider

- New sensor types will arrive beyond vibration and energy.
- More asset-related information is coming (e.g. insights behind a status, historical trends).
- A user can belong to many companies, each with its own tree.
- Trees can become deep and wide.

---

## What We Expect on the Whiteboard

This is a frontend role, so the focus is frontend design — but show enough backend/system awareness to define how the frontend consumes its data.

Design two deliverables:

1. **System diagram** — each component's responsibilities, the information it owns or handles, and the contracts/communication between components.
2. **Data contracts & APIs** — a basic model of the data contracts and the APIs/routes each component uses, consumes, and provides; explain how the frontend receives and handles the information it needs.
