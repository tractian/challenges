# Front End Software Engineer
### Context

Assets are essential to the operation of the industry, it can include everything from manufacturing equipment to transportation vehicles to power generation systems. Proper management and maintenance is crucial to ensure that they continue to operate efficiently and effectively. A practical way to visualize the hierarchy of assets is through a tree structure.

### Challenge

> 📌  **Build an Tree View Application that shows companies Assets** 
*(The tree is basically composed with components, assets and locations)*

**Components**

- Components are the parts that constitute an asset.
- Components are typically associated with an asset, but the customer **may** want to add components without an asset as a parent **or** with a location as a parent
- Components typically include **vibration** or **energy** sensors, and they have a **operating** or **alert** status
- On the tree, components are represented by this icon:
![component](../assets/component.png)
    

**Assets/Sub-Assets**

- Assets have a set of components
- Some assets are very large, like a conveyor belt and they **may** contain N sub-assets.
- Assets are typically associated with a location, but the customer **may** want to add assets without specifying a location as a parent.
- You can know that an item is a **asset**, if they have another assets or components as children.
- On the tree, assets are represented by this icon:
![asset](../assets/asset.png)
    

**Locations/Sub-Locations**

- Locations represent the places where the assets are located. For very large locations, the customer may want to split them to keep their hierarchy more organized. Therefore, locations may contain N sub-locations.
- On the tree, locations are represented by this icon:
![location](../assets/location.png)
    

In summary, a tree may like look this:

```
- Root
  |
  └── Location A
  |     |
  |     ├── Asset 1
  |     |     ├── Component A1
  |     |     ├── Component A2
  |     |
  |     ├── Asset 2
  |           ├── Component B1
  |           ├── Component B2
  |
  ├── Location B
  |     ├── Location C
  |     |     |
  |     |     ├── Asset 3
  |     |     |     ├── Component C1
  |     |     |     ├── Component C2
  |     |     |
  |     |     ├── Component D1
  |
  └── Component X
```

## Features

**Asset Page**

- The Asset Tree is the core feature, offering a visual Tree representation of the company's asset hierarchy.
- **Sub-Features:**
    1. **Visualization**
        - Present a dynamic tree structure displaying components, assets, and locations.
    2. **Filters**
        
        **Text Search**
        
        - Users can search for specific components/assets/locations within the asset hierarchy.
        
        **Energy Sensors**
        
        - Implement a filter to isolate energy sensors within the tree.
        
        **Critical Sensor Status**
        
        - Integrate a filter to identify assets with critical sensor status.
    - When the filters are applied, the asset parents **can't** be hidden. The user must know the entire asset path. The items that are not related to the asset path, must be hidden

### Technical Data
You have Assets and Locations, you need to relate both of them to build the Tree.

**Locations Collection**
Contains only Locations and sub locations (Composed with name, id and a optional parentId)
```json
{
  "id": "65674204664c41001e91ecb4",
  "name": "PRODUCTION AREA - RAW MATERIAL",
  "parentId": null
}
```

If the Location has a parentId, it means it is a sub location
```json
{
  "id": "656a07b3f2d4a1001e2144bf",
  "name": "CHARCOAL STORAGE SECTOR",
  "parentId": "65674204664c41001e91ecb4"
}
```

The visual representation:
```
- PRODUCTION AREA - RAW MATERIAL
  |
  ├── CHARCOAL STORAGE SECTOR
```

    
**Assets Collection**
Contains assets, sub assets and components (Composed by name, id and a optional locationId, parentId and sensorType)

If the item has a sensorType, it means it is a component. If it does not have a location or a parentId, it means he is unliked from any asset or location in the tree.
```json
{
  "id": "656734821f4664001f296973",
  "name": "Fan - External",
  "parentId": null,
  "sensorId": "MTC052",
  "sensorType": "energy",
  "status": "operating",
  "gatewayId": "QHI640",
  "locationId": null
}
```

If the item has a location and does not have a sensorId, it means he is an asset with a location as parent, from the location collection
```json
{
  "id": "656a07bbf2d4a1001e2144c2",
  "name": "CONVEYOR BELT ASSEMBLY",
  "locationId": "656a07b3f2d4a1001e2144bf"
}
```

If the item has a parentId and does not have a sensorId, it means he is an asset with another asset as a parent
```json
{
  "id": "656a07c3f2d4a1001e2144c5",
  "name": "MOTOR TC01 COAL UNLOADING AF02",
  "parentId": "656a07bbf2d4a1001e2144c2"
}
```

If the item has a sensorType, it means it is a component. If it does have a location or a parentId, it means he has an asset or Location as parent    
```json
{
  "id": "656a07cdc50ec9001e84167b",
  "name": "MOTOR RT COAL AF01",
  "parentId": "656a07c3f2d4a1001e2144c5",
  "sensorId": "FIJ309",
  "sensorType": "vibration",
  "status": "operating",
  "gatewayId": "FRH546"
}
```
        
To summarize, this is the visual representation of this items on the Tree
```
- ROOT
  |
  ├── PRODUCTION AREA - RAW MATERIAL [Location]
  |     |
  |     ├── CHARCOAL STORAGE SECTOR [Sub-Location]
  |     |     |
  |     |     ├── CONVEYOR BELT ASSEMBLY [Asset]
  |     |     |     |
  |     |     |     ├── MOTOR TC01 COAL UNLOADING AF02 [Sub-Asset]
  |     |     |     |     |
  |     |     |     |     ├── MOTOR RT COAL AF01 [Component - Vibration]
  |
  ├── Fan - External [Component - Vibration]
```

### Design
[Figma Link](https://www.figma.com/file/F52Yv8RmGoGOYcV9CiuIZ1/%5BCareers%5D-Frontend-Challenge-v2?type=design&node-id=0-1&mode=design&t=r3n2A4W0ZFUwVjAs-0)

> 💡 You don't have to exactly match figma's design! Please, be able to abstract well the presented problem and define it yourself what you consider most important and think with the user's head!

### Demo API
The API only works for GET requests, there are 3 endpoints:

- `/companies` - Returns all companies
- `/companies/:companyId/locations` - Returns all locations of the company
- `/companies/:companyId/assets` - Returns all assets of the company

API: [fake-api.tractian.com](fake-api.tractian.com)

### Deploy
The challenge must be in a public repository on GitHub. Upon completion, a new application with the link to the challenge repository should be made on the job application page. Remember, the challenge does not guarantee your position, it is an enhancer and a differentiator for us to assess your profile more accurately.

### Extra
You may use libraries for anything you find essential, **except** for the Asset Tree and the UI.
In this challenge, performance and usability count as **bonus** points.