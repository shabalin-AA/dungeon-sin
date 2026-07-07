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
let characterTileSrc = Rectangle(
    x: 196,
    y: 160,
    width: (213 - 196),
    height: (180 - 160)
)

var camera = Camera2D(
    offset: Vector2(x: Float(screenWidth) / 2, y: Float(screenHeight) / 2),
    target: Vector2(x: 0, y: 0),
    rotation: 0,
    zoom: 2.0
)

var charPosition = Vector2(
    x: Float(screenWidth / 2),
    y: Float(screenHeight / 2)
)

/*
    Callbacks
*/
func update(dt: Float) {
    if IsKeyDown(RL_KEY_W) { charPosition.y -= 2.0 }
    if IsKeyDown(RL_KEY_A) { charPosition.x -= 2.0 }
    if IsKeyDown(RL_KEY_S) { charPosition.y += 2.0 }
    if IsKeyDown(RL_KEY_D) { charPosition.x += 2.0 }
}

func draw() {
    ClearBackground(RL_RAYWHITE)
    camera.target = charPosition
    BeginMode2D(camera)
    DrawTexture(tileset, 0, 0, RL_WHITE)
    DrawTextureRec(tileset, characterTileSrc, charPosition, RL_WHITE)
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
