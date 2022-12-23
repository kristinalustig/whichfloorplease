local C = require "content"
local E = require "elevator"
local P = require "person"
local push = require "lib/push"

lg = love.graphics

local gameWidth, gameHeight = 800, 600 --fixed game resolution
local windowWidth, windowHeight = love.window.getDesktopDimensions()

function love.load()
  push:setupScreen(gameWidth, gameHeight, windowWidth, windowHeight, {resizable = true, pixelperfect = true, highdpi = true})
  E.init()
  C.init()
end

function love.update(dt)
  C.update(dt)
  E.update()
end

function love.draw()
  push:start()

  C.draw()

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