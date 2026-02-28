---
title: "Multiplayer with Bevy and Renet"
date: 2024-03-07
description: "A comprehensive guide to building multiplayer games in Rust using the Bevy game engine and Renet networking library. Learn about Entity-Component-System architecture, client-server synchronization, input handling strategies, and practical implementation of real-time multiplayer features. Perfect for developers wanting to explore game development beyond traditional web technologies."
tags: ["rust", "bevy", "multiplayer", "game"]
---

Here at Renuo, we specialize in web technologies such as Ruby on Rails, React, Angular, and Spring. One of our core company values is continuous learning: we love exploring new technologies even beyond our usual scope of expertise.

Inspired by Michael's Unity Powerday, I decided to delve into how multiplayer games operate. As a team, we held a competition to implement FPS (First-Person Shooter) games using C# boilerplate. Initially, the sheer amount of boilerplate required felt overwhelming. Beyond that, I wanted to understand client/server data synchronization at a lower level of abstraction.

My recent experiences with [Rust](https://rustlang.org/) and [Bevy](https://bevyengine.org/) convinced me to write this blog article to share my newfound learnings of game development.

## Why Choose Rust

### Advantages

Rust is a statically typed, memory-safe, multi-paradigm programming language that matches the performance of C. Due to its safety, concurrency features, and modern syntax, it has gained popularity among developers in recent years.

Some notable software written in Rust includes:

- **Rapier3d**: A performant physics engine often used with ThreeJS.
- **Ripgrep**: A performant command line search tool.
- **Alacritty**: A performant, minimalistic cross-platform terminal emulator.
- **Warp**: A performant, modern terminal IDE.
- **Tauri**: A performant and lightweight alternative to ElectronJS.
- **Amethyst**: A performant tiling window manager for MacOS.
- **Condorium Blockchain**: A performant and secure blockchain technology.

> "I mean, there is no such thing as a perfect programming language.
> Rust is merely a statically type low-level multi-paradigm perfect programming language."
>
> [YouTube interview](https://www.youtube.com/watch?v=TGfQu0bQTKc&t=95s) by [Programmers Are Also Human](https://www.youtube.com/@programmersarealsohuman5909),

![Ferris the Rustacean](/assets/blog/ferris-rustacean.webp)
_Ferris, the unofficial Rust mascot_

## Picking a game engine

> "There are currently 5 games written in Rust. And 50 game engines."
>
> Interview with a Senior Rust Developer - [2:52](https://www.youtube.com/watch?v=TGfQu0bQTKc&t=168s)

There are too many game engines available for Rust. An excellent resource is [Are We Game Yet](https://arewegameyet.rs/ecosystem/engines/). I also recommend [this article by GeeksforGeeks](https://www.geeksforgeeks.org/rust-game-engines/), which makes picking the optimal engine easier.

### The Difference Between Bevy and Other Engines

While big game engines like Godot, Unity, and Unreal Engine come with graphical editors, Bevy focuses on providing a simple yet powerful, multithreaded system to manage game state with minimal code.

## Understanding ECS

The [ECS](https://en.wikipedia.org/wiki/Entity_component_system) (Entity Component System) is a software pattern that emphasizes a modular design. It is commonly utilized in game and game engine development. This approach separates the data and behaviour of game entities into components, making it easier to manage and organize complex systems.

### Components of ECS

1. **Entities:** Unique identifiers of a group of components (A u32 wrapper in bevy).
2. **Components:** Modular data pieces that represent specific Entity attributes. (A struct that derives the Component macro in bevy)
3. **System:** Logic that operates on entities and their components. (A struct that derives the Resource macro in bevy)

### Systems in Bevy

Systems in Bevy are functions that take various parameters such as queries, EventReaders, assets, and resources and apply logic to them.

One powerful feature of Bevy systems is the Query interface. It allows you to fetch specific data for entities in your project. For instance, if no entity is found, the `single_mut()` function will raise an error. Multiple queries are possible as long as entities do not overlap.

Below is an example where the `MyPlayer` component doesn't contain any data but is used to denote that the entity belongs to the client player.

```rust
pub fn update_player_movement_system(
    mut keyboard_events: EventReader<KeyboardInput>,
    mut query: Query<(&mut Transform, &MyPlayer)>,
) {
    let (mut transform, _) = query.single_mut();

    for event in keyboard_events.read() {
        let mut delta_position = Vec3::new(0.0, 0.0, 0.0);

        match event.key_code {
            KeyCode::KeyW => delta_position.z += 0.1,
            KeyCode::KeyS => delta_position.z -= 0.1,
            KeyCode::KeyA => delta_position.x -= 0.1,
            KeyCode::KeyD => delta_position.x += 0.1,
            _ => {}
        }

        let new_position = transform.translation + delta_position;
        transform.translation = new_position;
    }
}
```

The example above has a flaw: the player position update has a fixed step. Instead of using a fixed-step update, consider using the time passed since the last step. This will ensure a consistent movement speed regardless of the frame rate.

## Picking Networking Libraries

We need to decide on networking libraries after choosing Bevy as our game engine. Here are a few options:

- Matchbox
- Naia
- Renet
- Bootleg_networking
- Spicy_networking

I chose **Renet** because of its popularity and my good experiences with its boilerplate. Additionally, I included **Serde** for efficient binary message encoding.

## Sketching the scene

Before coding, let's sketch a simple scene:

- **Camera:** Renders the scene.
- **Plane:** Represents the floor.
- **Green Cube:** Represents the player.
- **Red Cubes:** Represent other players.

Attributes to synchronize:

- **Position:** `Vec3`

Input method:

- **Keyboard (WASD):** Used to translate the player.

### Handling Player inputs

There are three main ways to handle player inputs:

1. **Client-side:** The client handles inputs, moves the player, and sends the position to the server.
2. **Server-side:** The client sends input data to the server, and the server responds with the position.
3. **Hybrid:** The client handles inputs and shares them with the server, which then responds with position synchronization.

The client-side approach can reduce latency, but is less secure. The server-side approach is more secure but adds server load. The hybrid approach offers a balance, but is more complex.

## Planning

### Client

| Type      | Name                                                | Description                                                                                                                 |
| --------- | --------------------------------------------------- | --------------------------------------------------------------------------------------------------------------------------- |
| Component | PlayerEntity(ClientId)                              | Represents an enemy player entity.                                                                                          |
| Component | MyPlayer                                            | Marks the current player entity.                                                                                            |
| Event     | PlayerSpawnEvent(ClientId)                          | Emitted when a player joins. Adds a player object to the scene.                                                             |
| Event     | PlayerDespawnEvent(ClientId)                        | Emitted when a player leaves. Removes a player object from the scene.                                                       |
| Event     | PlayerMoveEvent(ClientId, Vec3)                     | Emitted by the player controller when a player moves.                                                                       |
| Event     | LobbySyncEvent(HashMap<ClientId, PlayerAttributes>) | Emitted when the client receives sync messages from the server. Updates other player positions using their ID and position. |
| System    | send_message_system                                 | Shares MyPlayer position data with the server.                                                                              |
| System    | receive_message_system                              | Processes messages received from the server.                                                                                |
| System    | update_player_movement_system                       | Updates player position from keyboard input.                                                                                |
| System    | setup_system                                        | Sets up the scene with a camera, a ground plane, and a mesh for the current player.                                         |
| System    | handle_player_spawn_event_system                    | Adds enemy players to the scene once they join in.                                                                          |
| System    | handle_lobby_sync_event_system                      | Updates enemy player positions and potentially spawns missed players into the scene.                                        |

### Server

| Type     | Name                                             | Description                                                                                                   |
| -------- | ------------------------------------------------ | ------------------------------------------------------------------------------------------------------------- |
| Resource | PlayerLobby(HashMap<ClientId, PlayerAttributes>) | Holds attributes of all players currently in the game. Used to synchronize these attributes with the clients. |
| System   | send_message_system                              | Broadcasts player positions to keep enemy player positions in clients up-to-date.                             |
| System   | receive_message_system                           | Updates player lobby position based on messages received from the RenetClient.                                |
| System   | handle_events_system                             | Handles events such as ClientConnected and ClientDisconnected from the Bevy Renet plugin.                     |

## Deciding on a project structure

I separated the ECS components into specific modules to structure the Bevy project and used two entry points: one for the client and one for the server. Shared code, such as structures for Client-Server communication, can be placed in a global `lib` module.

```
src
├── client
│   ├── components.rs
│   ├── events.rs
│   ├── main.rs
│   ├── resources.rs
│   └── systems.rs
├── lib.rs
└── server
    ├── main.rs
    ├── resources.rs
    └── systems.rs
```

Defining various entry points is as simple as adding this to the `Cargo.toml` file:

```
[[bin]]
name = "server"
path = "src/server/main.rs"

[[bin]]
name = "client"
path = "src/client/main.rs"
```

Afterwards, the binaries can be run with the `--bin` argument:

```
cargo run --bin server
cargo run --bin client
```

## Setting up Boilerplate

To integrate `bevy_renet` into the bevy project, I followed the [Bevy Renet documentation](https://github.com/lucaspoffo/renet/blob/master/bevy_renet/README.md). In my setup, I used these two default channels:

- **Unreliable:** Used for sending and receiving messages for player attribute synchronization. (We don't care about every state change, we can pick the last one)
- **ReliableOrdered:** Used for sending and receiving messages for player actions such as joining and leaving.

## Synchronising player positions

Here's an example of sending player attributes from the client to the server:

```rust
pub fn send_message_system(mut client: ResMut<RenetClient>, query: Query<(&MyPlayer, &Transform)>) {
    let (_, transform) = query.single();
    let player_sync = PlayerAttributes {
        position: transform.translation.into(),
    };
    let message = bincode::serialize(&player_sync).unwrap();
    client.send_message(DefaultChannel::Unreliable, message);
}
```

Handling messages from the client on the server:

```rust
pub fn receive_message_system(mut server: ResMut<RenetServer>, mut player_lobby: ResMut<PlayerLobby>) {
    for client_id in server.clients_id() {
        let message = server.receive_message(client_id, DefaultChannel::Unreliable);
        if let Some(message) = message {
            let player: PlayerAttributes = bincode::deserialize(&message).unwrap();
            player_lobby.0.insert(client_id, player);
        }
    }
}
```

Sending attributes of all players back to the client:

```rust
pub fn send_message_system(mut server: ResMut<RenetServer>, player_lobby: Res<PlayerLobby>) {
    let chanel = DefaultChannel::Unreliable;
    let lobby = player_lobby.0.clone();
    let event = multiplayer_demo::ServerMessage::LobbySync(lobby);
    let message = bincode::serialize(&event).unwrap();
    print_lobby(&player_lobby);
    server.broadcast_message(chanel, message);
}
```

Synchronizing the client scene with the player attributes from the server:

```rust
pub fn handle_lobby_sync_event_system(
    mut spawn_events: EventWriter<PlayerSpawnEvent>,
    mut sync_events: EventReader<LobbySyncEvent>,
    mut query: Query<(&PlayerEntity, &mut Transform)>,
    my_clinet_id: Res<MyClientId>,
) {
    let event_option = sync_events.read().last();
    if event_option.is_none() {
        return;
    }
    let event = event_option.unwrap();

    for (client_id, player_sync) in event.0.iter() {
        if *client_id == my_clinet_id.0 {
            continue;
        }

        let mut found = false;
        for (player_entity, mut transform) in query.iter_mut() {
            if *client_id == player_entity.0 {
                let new_position = player_sync.position;
                transform.translation = new_position.into();
                found = true;
            }
        }

        if !found {
            info!("Spawning player {}: {:?}", client_id, player_sync.position);
            spawn_events.send(PlayerSpawnEvent(*client_id));
        }
    }
}
```

## Conclusion

The multiplayer demo project demonstrates the intricate planning and attention to detail needed to synchronize player attributes between the client and server. This showcases the complexity of creating a seamless multiplayer experience at a lower level.

For more detailed code, visit the MIT-Licensed [GitHub repository](https://github.com/cb341/bevy-multiplayer).
