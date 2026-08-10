# Front-End Software Engineer — System Design Interview

## Overview

Design a high-level system for a larger domain on a virtual whiteboard. There is no coding in this session. Treat it as a collaborative conversation with a peer and create a design proposal that a teammate could implement. Expect clarifying questions throughout.

**What we're looking for**

- **Comprehensiveness:** cover the functional requirements and edge cases.
- **Feasibility:** propose something practical and realistic to implement.
- **Scalability:** account for growth in usage and requirements.
- **Resilience:** consider how the system handles failures and outages.

**Tips**

- **Ask clarifying questions** before you start.
- **Explain your tradeoffs** as you work and why you made them.

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

- **Location:** a physical place in a plant, such as a factory, production area, or storage sector. Locations can contain other locations.
- **Asset:** a piece of equipment, such as a conveyor, motor, or pump. Assets can contain other assets.
- **Component:** the leaf of the tree, an asset with a **sensor**, such as a vibration or energy sensor.

Every component has a **status** (`operating`, `warning`, `alarming`) that rolls up the tree. Status is the plant manager's first scan: "is everything fine, or where do I send someone?"

---

## Functional Requirements

1. **Visualization:** show the hierarchy as a tree, with each level clearly distinguished.
2. **CRUD:** allow people to create, read, update, and delete locations, assets, and components anywhere in the tree.
3. **Search and filters:** support search by name and filters by sensor type and status.

[Figma reference](https://www.figma.com/design/vy7so4jovGWXCAAPcT3iYw/-Careers--Frontend-Challenge?node-id=0-1&t=MOufg4LSia3ORSQe-1): one possible UI, not a pixel-perfect specification. Use it to ground the conversation.

---

## Things to Consider

- **Sensor types:** new sensor types will arrive beyond vibration and energy.
- **Asset information:** more information is coming, including the insights behind a status and historical trends.
- **Companies:** a person can belong to many companies, each with its own tree.
- **Tree size:** trees can become deep and wide.

---

## What We Expect on the Whiteboard

This is a Front-end role, so keep the focus on the Front-end experience and implementation. Still, this is a system design exercise: sketch the Back-end, storage, and any other parts needed to show how the Front-end receives and uses its data.

Design two deliverables:

1. **System diagram:** show each component, its responsibilities, the information it owns or handles, and how components communicate with each other.
2. **Data contracts and APIs:** outline the main data shapes and the APIs or routes each component uses or provides. Show how the frontend receives and handles the information it needs.
