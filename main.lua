local C = require "content"
local E = require "elevator"
local P = require "person"
local push = require "lib/push"

lg = love.graphics

local gameWidth, gameHeight = 1600, 1200 --fixed game resolution
local windowWidth, windowHeight = love.window.getDesktopDimensions()
GLOBALPLAYERS = 1
local title
local titleFont

GLOBALSCALE = 1
GS = 2

local gameStates = {
  
    titleScreen = 1,
    mainScreen = 2,
    pauseScreen = 3,
    gameOver = 4
  
}

local currentState

function love.load()
  
  if windowWidth < 1600 then
    GLOBALSCALE = .5
    GS = 1
    windowWidth = 800
    windowHeight = 600
    gameWidth = 800
    gameHeight = 600
  else
    windowWidth = 1600
    windowHeight = 1200
    GS = 2
  end
  
  push:setupScreen(gameWidth, gameHeight, windowWidth, windowHeight, {resizable = false, pixelperfect = true, highdpi = true})
  
  
  doorFont = lg.newImageFont("/assets/doorFont.png", "1234567890")
  titleFont = lg.newFont("/assets/Chonburi-Regular.ttf", 40*GLOBALSCALE)
  dreamFont = lg.newFont("/assets/Chonburi-Regular.ttf", 16*GLOBALSCALE)
  lg.setFont(titleFont)
  lg.setColor(232/255, 193/255, 112/255)
  
  currentState = gameStates.mainScreen
  
  
  title = lg.newImage("/assets/title.png")
  
  E.init()
  C.init()
  P.init()
end

function love.update(dt)
  if currentState == gameStates.mainScreen then
    C.update(dt)
    E.update()
    P.update()
  end
end

function love.draw()
  push:start()

  if currentState == gameStates.mainScreen then
    lg.setFont(doorFont)
    C.draw()
  elseif currentState == gameStates.titleScreen then
    lg.setFont(titleFont)
    lg.draw(title, 0, 0, 0, GLOBALSCALE, GLOBALSCALE)
    lg.setColor(232/255, 193/255, 112/255)
    lg.printf("1 player", 0, 500*GS, 500*GS,"center")
    lg.printf("1 player", 0, 500*GS, 500*GS,"center")
  elseif currentState == gameStates.pauseScreen then
  elseif currentState == gameStates.gameOver then
  end
  
  push:finish()
end

function love.keypressed(key, scancode, isrepeat)
  if key == "space" then
    E.doorOpen()
  elseif key == "up" or key == "w" then
    E.moveElevator("up")
  elseif key == "down" or key == "s" then
    E.moveElevator("down")
  elseif key == "left" or key == "a" then
    E.switchElevators(1)
  elseif key == "right" or key == "d" then
    E.switchElevators(2)
  elseif key == "tab" then
    E.switchElevators(3)
  elseif key == "esc" then
    --pause game
  end
end

function love.resize(w, h)
  push:resize(w, h)
end