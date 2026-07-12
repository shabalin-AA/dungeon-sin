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
let tileSize: Float = 16

enum EntityKind {
    case greenWizard
    case blueWizard
}

struct Entity { let id: Int }
var Entities: [Entity] = []

var MapPosition:  [Vector2]    = []
var TilePosition: [Vector2]    = []
var Speed:        [Float]      = []
var Hitbox:       [Float]      = []
var Kind:         [EntityKind] = []
var TileSrc:      [Rectangle]  = []
var EntityTarget: [Entity?]     = []
var MapTarget:    [Vector2?]    = []

func createEntity(
    mapPosition: Vector2,
    tilePosition: Vector2,
    speed: Float,
    hitbox: Float,
    kind: EntityKind,
    tileSrc: Rectangle,
    entityTarget: Entity?,
    mapTarget: Vector2?
) -> Entity {
    let res = Entity(id: Entities.count)
    Entities.append(res)
    MapPosition.append(mapPosition)
    TilePosition.append(tilePosition)
    Speed.append(speed)
    Hitbox.append(hitbox)
    Kind.append(kind)
    TileSrc.append(tileSrc)
    EntityTarget.append(entityTarget)
    MapTarget.append(mapTarget)
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
                    width: tileSize,
                    height: tileSize
                )
            case .wall:
                return Rectangle(
                    x: 48,
                    y: 228,
                    width: tileSize,
                    height: tileSize
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
    mapPosition: Vector2(x: 2, y: 2),
    tilePosition: Vector2Zero(),
    speed:    2.0,
    hitbox:   16,
    kind:     .greenWizard,
    tileSrc:  Rectangle( x: 194, y: 160, width: 20, height: 20 ),
    entityTarget: nil,
    mapTarget: Vector2(x: 7, y: 7)
)

var character2 = createEntity(
    mapPosition: Vector2(x: 3, y: 3),
    tilePosition: Vector2Zero(),
    speed:    2.0,
    hitbox:   16,
    kind:     .blueWizard,
    tileSrc:  Rectangle( x: 204, y: 182, width: 20, height: 20 ),
    entityTarget: character,
    mapTarget: nil
)

/*
    Callbacks
*/
func moveEntity(e: Entity) {
    let mapTarget: Vector2?
    if let entityTarget = EntityTarget[e.id] {
        mapTarget = MapPosition[entityTarget.id]
    } else {
        mapTarget = MapTarget[e.id]
    }
    guard let mapTarget else { return }
    let currentMapPos = MapPosition[e.id]
    let currentTilePos = TilePosition[e.id]
    let speed = Speed[e.id]
    let targetTile = Vector2(
        x: (mapTarget.x - currentMapPos.x) * tileSize,
        y: (mapTarget.y - currentMapPos.y) * tileSize
    )
    let diff = Vector2(
        x: targetTile.x - currentTilePos.x,
        y: targetTile.y - currentTilePos.y
    )
    let dist = sqrtf(diff.x * diff.x + diff.y * diff.y)
    guard dist > 0 else { return }
    let step = min(speed, dist)
    let dir = Vector2(x: diff.x / dist, y: diff.y / dist)
    let moved = Vector2(
        x: currentTilePos.x + dir.x * step,
        y: currentTilePos.y + dir.y * step
    )
    let deltaMapX = floorf(moved.x / tileSize)
    let deltaMapY = floorf(moved.y / tileSize)
    let newTilePos = Vector2(
        x: moved.x - deltaMapX * tileSize,
        y: moved.y - deltaMapY * tileSize
    )
    MapPosition[e.id] = Vector2(
        x: currentMapPos.x + deltaMapX,
        y: currentMapPos.y + deltaMapY
    )
    TilePosition[e.id] = newTilePos
}

func update() {
    for e in Entities {
        moveEntity(e: e)
    }
}

func draw() {
    ClearBackground(RL_RAYWHITE)
    camera.target = Vector2Add(
        Vector2Scale(MapPosition[character.id], tileSize), 
        TilePosition[character.id]
    )
    BeginMode2D(camera)
    for (y,tilerow) in map.tiles.enumerated() {
        for (x,tile) in tilerow.enumerated() {
            let dst = Vector2(
                x: Float(x) * tileSize, 
                y: Float(y) * tileSize
            )
            DrawTextureRec(tileset, tile.src, dst, RL_WHITE)
        }
    }
    for e in Entities {
        let xpos = MapPosition[e.id].x*tileSize + TilePosition[e.id].x - tileSize/2
        let ypos = MapPosition[e.id].y*tileSize + TilePosition[e.id].y - tileSize/2
        DrawTexturePro(
            tileset, 
            TileSrc[e.id], 
            Rectangle( x: xpos, y: ypos, width:  tileSize, height: tileSize),
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
