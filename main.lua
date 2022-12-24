local C = require "content"
local E = require "elevator"
local P = require "person"
local push = require "lib/push"

lg = love.graphics
la = love.audio

local gameWidth, gameHeight = 1600, 1200 --fixed game resolution
local windowWidth, windowHeight = love.window.getDesktopDimensions()
GLOBALPLAYERS = 1
local title
local ballPos

GLOBALSCALE = 1
GS = 2


function love.load()
  gameStates = {
  titleScreen = 1,
  mainScreen = 2,
  pauseScreen = 3,
  gameOver = 4
}

--windowWidth = 800
  
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
  titleFont = lg.newFont("/assets/Chonburi-Regular.ttf", 40)
  dreamFont = lg.newFont("/assets/Chonburi-Regular.ttf", 16)
  lg.setFont(titleFont)
  lg.setColor(232/255, 193/255, 112/255)
  
  currentState = gameStates.titleScreen
  
  ballPos = 476*GS
  
  
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
    P.draw()
  elseif currentState == gameStates.titleScreen then
    lg.setFont(titleFont)
    lg.draw(title, 0, 0, 0, GLOBALSCALE, GLOBALSCALE)
    lg.setColor(232/255, 193/255, 112/255)
    lg.printf("press '1' for 1 player", 160*GS, 460*GS, 560*GS,"left", 0, GLOBALSCALE, GLOBALSCALE)
    lg.printf("press '2' for 2 player", 160*GS, 480*GS, 560*GS,"left", 0, GLOBALSCALE, GLOBALSCALE)
    lg.printf("press 'enter' to begin", 160*GS, 540*GS, 1000*GS,"left", 0, GLOBALSCALE, GLOBALSCALE)
    lg.circle("fill", 152*GS, ballPos, 6*GS)
  elseif currentState == gameStates.pauseScreen then
    C.drawPauseScreen()
  elseif currentState == gameStates.gameOver then
    P.drawGameOver()
end
  
  push:finish()
end

function love.keypressed(key, scancode, isrepeat)
  if currentState == gameStates.titleScreen then
    if key == "1" then
      GLOBALPLAYERS = 1
      ballPos = 476*GS
    elseif key == "2" then
      GLOBALPLAYERS = 2
      ballPos = 496*GS
    elseif key == "return" then
      currentState = gameStates.pauseScreen
    end
  elseif currentState == gameStates.pauseScreen then
    if key == "return" then
      currentState = gameStates.mainScreen
    end
  elseif currentState == gameStates.mainScreen then
    if GLOBALPLAYERS == 1 then
      if key == "space" then
        E.doorOpen(0)
      elseif key == "up" or key == "w" then
        E.moveElevator("up", 0)
      elseif key == "down" or key == "s" then
        E.moveElevator("down", 0)
      elseif key == "left" or key == "a" then
        E.switchElevators(1)
      elseif key == "right" or key == "d" then
        E.switchElevators(2)
      elseif key == "tab" then
        E.switchElevators(3)
      elseif key == "escape" then
        currentState = gameStates.pauseScreen
      end
    elseif GLOBALPLAYERS == 2 then
      if key == "lshift" then
        E.doorOpen(1)
      elseif key == "rshift" then
        E.doorOpen(2)
      elseif key == "up" then
        E.moveElevator("up", 2)
      elseif  key == "w" then
        E.moveElevator("up", 1)
      elseif key == "down" then 
        E.moveElevator("down", 2)
      elseif key == "s" then
        E.moveElevator("down", 1)
      elseif key == "escape" then
        currentState = gameStates.pauseScreen
      end
    end
  end
end

function love.resize(w, h)
  push:resize(w, h)
end