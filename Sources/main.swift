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

let characterSpeed: Float = 1.0
let characterHitboxSize: Float = 16

InitWindow(screenWidth, screenHeight, "Dungeon Sin")
SetTargetFPS(60)

let tileset = LoadTexture("Assets/dungeon_tiles.png")
let characterTileSrc = Rectangle(
    x: 194,
    y: 160,
    width: 20,
    height: 20
)

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
    var screenPos: Vector2
}

func genRoom(maxWidth: Int, maxHeight: Int) -> [[Tile]] {
    let w = Int.random(in: 3...maxWidth)
    let h = Int.random(in: 3...maxHeight)
    var room = Array(repeating: Array(repeating: Tile.floor, count: w), count: h)
    room[0] = Array(repeating: Tile.wall, count: w)
    room[room.count-1] = Array(repeating: Tile.wall, count: w)
    return room
}

var map = Map(tiles: genRoom(maxWidth: 20, maxHeight: 20), screenPos: Vector2Zero())
let tileSize = 16

var camera = Camera2D(
    offset: Vector2(x: Float(screenWidth) / 2, y: Float(screenHeight) / 2),
    target: Vector2(x: 0, y: 0),
    rotation: 0,
    zoom: 3
)

struct Character {
    var pos: Vector2
    var vel: Vector2
}

var char = Character(
    pos: Vector2(x: 2*characterHitboxSize, y: 2*characterHitboxSize),
    vel: Vector2Zero()
)

struct Animation<T> {
    var param: T
    var period: Float
    var time: Float
}

var charMoveAnim = Animation<Float>(
    param: 1,
    period: 0.2,
    time: 0
)

/*
    Callbacks
*/
func moveChar(map: Map, char: Character) -> Vector2 {
    let hb: Float = characterHitboxSize
    let np = Vector2Add(char.pos, char.vel)
    let charRec = Rectangle(x: np.x - hb/2, y: np.y - hb/2, width: hb, height: hb)
    for (y, tilerow) in map.tiles.enumerated() {
        for (x, tile) in tilerow.enumerated() {
            if tile == .floor {
                continue
            }
            let wallRec = Rectangle(
                x: map.screenPos.x + Float(x * tileSize), 
                y: map.screenPos.y + Float(y * tileSize), 
                width: Float(tileSize), 
                height: Float(tileSize)
            )
            if CheckCollisionRecs(charRec, wallRec) {
                return char.pos
            }
        }
    }
    return np
}

func update(dt: Float) {
    char.vel = Vector2Zero()
    if IsKeyDown(RL_KEY_W) { char.vel.y -= characterSpeed }
    if IsKeyDown(RL_KEY_A) { char.vel.x -= characterSpeed }
    if IsKeyDown(RL_KEY_S) { char.vel.y += characterSpeed }
    if IsKeyDown(RL_KEY_D) { char.vel.x += characterSpeed }
    char.vel = Vector2Normalize(char.vel)
    char.pos = moveChar(map: map, char: char)
    charMoveAnim.time += dt
    if charMoveAnim.time > charMoveAnim.period {
        charMoveAnim.time = 0.0
        charMoveAnim.param = -charMoveAnim.param
    }
}

func draw() {
    ClearBackground(RL_RAYWHITE)
    camera.target = char.pos
    BeginMode2D(camera)
    for (y,tilerow) in map.tiles.enumerated() {
        for (x,tile) in tilerow.enumerated() {
            let dst = Vector2(
                x: map.screenPos.x + Float(x * tileSize), 
                y: map.screenPos.y + Float(y * tileSize)
            )
            DrawTextureRec(tileset, tile.src, dst, RL_WHITE)
        }
    }
    DrawTexturePro(
        tileset, 
        characterTileSrc, 
        Rectangle(
            x: char.pos.x - characterHitboxSize/2,
            y: char.pos.y - characterHitboxSize/2 + charMoveAnim.param,
            width: characterHitboxSize,
            height: characterHitboxSize
        ),
        Vector2Zero(),
        0.0,
        RL_WHITE
    )
    EndMode2D()
}

/*
    Main
*/
while !WindowShouldClose() {
    update(dt: GetFrameTime())
    BeginDrawing()
    draw()
    EndDrawing()
}

/*
    Deinit
*/
UnloadTexture(tileset)
CloseWindow()
