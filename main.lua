require("config/logger")
require("physics")
require("libraries/anim8")
userConfig = require("userConfig")
local menu = require("menu")
local level = require("level")
local multiplayer = require("multiplayer/multiplayer")
sti = require("libraries/sti")
cat = require("objectsCategories")
camera = require("libraries/camera")
cam = camera()

-- Глобальная переменная для состояния игры
gameState = "menu" -- Начальное состояние — меню

function love.load()
  menu.load()
    --Чтобы стартовать не с меню а с лвла
    --gameState = "level"
    --level.startLevel(1)
end

function love.update(dt)
    if gameState == "menu" then
        menu.update(dt)
    elseif gameState == "level" then
        level.update(dt)
    elseif gameState == "multiplayer" then
        multiplayer:update(dt)
    end
end

function love.draw()
    local font = love.graphics.newFont("res/fonts/Slovic_Demo_VarGX.ttf", 16)  -- название шрифта не я придумывал)
    love.graphics.setFont(font)
    if gameState == "menu" then
        menu.draw()
    elseif gameState == "level" then
        level.draw()
    elseif gameState == "multiplayer" then
        multiplayer:draw()
    end
end

function love.mousepressed(x, y, button, istouch, presses)
    if gameState == "menu" then
        menu.mousepressed(x, y, button)
    elseif gameState == "level" then
        level.mousepressed(x, y, button)
    end
end

function love.keypressed(key)
    if gameState == "level" and key == "escape" then
        gameState = "menu"
        menu.load()
    elseif gameState == "multiplayer" and key == "escape" then
        multiplayer.hub:unsubscribe()
        gameState = "menu"
        menu.load()
    elseif gameState == "level" then
        level.keypressed(key)
    elseif gameState == "multiplayer" then
        multiplayer:keypressed(key)
    elseif gameState == "menu" then
        menu.keypressed(key)
    end
end

function love.textinput(text)
    if gameState == "menu" then
        menu.textinput(text)
    end
end

function startLevel(levelNumber)
    gameState = "level"
    _log(levelNumber)
    level.startLevel(levelNumber)
end

function startMultiplayer(channel)
    gameState = "multiplayer"
    _log(gameState)
    multiplayer = Multiplayer.new({ channel = channel })
end
