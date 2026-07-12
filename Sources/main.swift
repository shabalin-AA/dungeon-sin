/*
    Raylib stuff
*/
import Raylib

let RL_MAROON = Color(r: 190, g: 33, b: 55, a: 255)
let RL_DARKGRAY = Color(r: 80, g: 80, b: 80, a: 255)
let RL_RAYWHITE = Color(r: 245, g: 245, b: 245, a: 255)
let RL_WHITE = Color(r: 255, g: 255, b: 255, a: 255)
let RL_BLACK = Color(r: 0, g: 0, b: 0, a: 255)

let RL_KEY_DOWN = Int32(KEY_DOWN.rawValue)
let RL_KEY_UP = Int32(KEY_UP.rawValue)
let RL_KEY_LEFT = Int32(KEY_LEFT.rawValue)
let RL_KEY_RIGHT = Int32(KEY_RIGHT.rawValue)
let RL_KEY_S = Int32(KEY_S.rawValue)
let RL_KEY_W = Int32(KEY_W.rawValue)
let RL_KEY_A = Int32(KEY_A.rawValue)
let RL_KEY_D = Int32(KEY_D.rawValue)

/*
    Init
*/
let screenWidth: Int32 = 800
let screenHeight: Int32 = 600
InitWindow(screenWidth, screenHeight, "Dungeon Sin")
SetTargetFPS(60)
let tileset = LoadTexture("Assets/dungeon_tiles.png")
let tileSize = 16

enum EntityKind {
    case greenWizard
    case blueWizard
}

struct Entity { let id: Int }
var Entities: [Entity] = []

var Position:   [Vector2]    = []
var Velocity:   [Vector2]    = []
var Speed:      [Float]      = []
var Hitbox:     [Float]      = []
var Kind:       [EntityKind] = []
var TileSrc:    [Rectangle]  = []

func createEntity(
    position: Vector2,
    velocity: Vector2,
    speed: Float,
    hitbox: Float,
    kind: EntityKind,
    tileSrc: Rectangle
) -> Entity {
    let res = Entity(id: Entities.count)
    Entities.append(res)
    Position.append(position)
    Velocity.append(velocity)
    Speed.append(speed)
    Hitbox.append(hitbox)
    Kind.append(kind)
    TileSrc.append(tileSrc)
    return res
}

enum Tile {
    case floor
    case wall

    var src: Rectangle {
        switch self {
            case .floor:
                return Rectangle(
                    x: 77,
                    y: 46,
                    width: (93 - 77),
                    height: (62 - 46)
                )
            case .wall:
                return Rectangle(
                    x: 48,
                    y: 228,
                    width: (64 - 48),
                    height: (244 - 228)
                )
        }
    }
}

struct Map {
    var tiles: [[Tile]]
}

func genRoom(maxWidth: Int, maxHeight: Int) -> [[Tile]] {
    let w = Int.random(in: 3...maxWidth)
    let h = Int.random(in: 3...maxHeight)
    var room = Array(repeating: Array(repeating: Tile.floor, count: w), count: h)
    room[0] = Array(repeating: Tile.wall, count: w)
    room[room.count-1] = Array(repeating: Tile.wall, count: w)
    return room
}

var map = Map(tiles: genRoom(maxWidth: 20, maxHeight: 20))

var camera = Camera2D(
    offset: Vector2(x: Float(screenWidth) / 2, y: Float(screenHeight) / 2),
    target: Vector2(x: 0, y: 0),
    rotation: 0,
    zoom: 3
)

var character = createEntity(
    position: Vector2(x: 40, y: 40),
    velocity: Vector2Zero(),
    speed:    2.0,
    hitbox:   16,
    kind:     .greenWizard,
    tileSrc:  Rectangle( x: 194, y: 160, width: 20, height: 20 )
)

var character2 = createEntity(
    position: Vector2(x: 80, y: 80),
    velocity: Vector2Zero(),
    speed:    2.0,
    hitbox:   16,
    kind:     .blueWizard,
    tileSrc:  Rectangle( x: 204, y: 182, width: 20, height: 20 )
)

/*
    Callbacks
*/
func moveEntity(map: Map, entity: Entity) -> Vector2 {
    let hb: Float = Hitbox[entity.id]
    let np = Vector2Add(Position[entity.id], Velocity[entity.id])
    let entityRec = Rectangle(x: np.x - hb/2, y: np.y - hb/2, width: hb, height: hb)
    for (y, tilerow) in map.tiles.enumerated() {
        for (x, tile) in tilerow.enumerated() {
            if tile == .floor {
                continue
            }
            let wallRec = Rectangle(
                x: Float(x * tileSize), 
                y: Float(y * tileSize), 
                width: Float(tileSize), 
                height: Float(tileSize)
            )
            if CheckCollisionRecs(entityRec, wallRec) {
                return Position[entity.id]
            }
        }
    }
    return np
}

func update() {
    for e in Entities {
        if e.id == character.id {
            Velocity[e.id] = Vector2Zero()
            if IsKeyDown(RL_KEY_W) { Velocity[e.id].y -= Speed[e.id] }
            if IsKeyDown(RL_KEY_A) { Velocity[e.id].x -= Speed[e.id] }
            if IsKeyDown(RL_KEY_S) { Velocity[e.id].y += Speed[e.id] }
            if IsKeyDown(RL_KEY_D) { Velocity[e.id].x += Speed[e.id] }
        }
        Velocity[e.id] = Vector2Normalize(Velocity[e.id])
        Position[e.id] = moveEntity(map: map, entity: e)
    }
}

func draw() {
    ClearBackground(RL_RAYWHITE)
    camera.target = Position[character.id]
    BeginMode2D(camera)
    for (y,tilerow) in map.tiles.enumerated() {
        for (x,tile) in tilerow.enumerated() {
            let dst = Vector2(
                x: Float(x * tileSize), 
                y: Float(y * tileSize)
            )
            DrawTextureRec(tileset, tile.src, dst, RL_WHITE)
        }
    }
    for e in Entities {
        DrawTexturePro(
            tileset, 
            TileSrc[e.id], 
            Rectangle(
                x: Position[e.id].x - Float(tileSize)/2,
                y: Position[e.id].y - Float(tileSize)/2,
                width:  Float(tileSize),
                height: Float(tileSize)
            ),
            Vector2Zero(),
            0.0,
            RL_WHITE
        )
    }
    EndMode2D()
}

/*
    Main
*/
while !WindowShouldClose() {
    update()
    BeginDrawing()
    draw()
    EndDrawing()
}

/*
    Deinit
*/
UnloadTexture(tileset)
CloseWindow()
