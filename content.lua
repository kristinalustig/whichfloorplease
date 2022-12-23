local E = require "elevator"
local P = require "person"
--getcher assets here!
C = {}

local spritesheet
local background
local elevatorLeft
local elevatorRight
local elevatorDoorAnims
local elevatorDoors = {}
local elevatorDoorFrames = {}
local elevatorDirections = {}
local elevatorFrameAnims
local residents = {}
local numberHighlights = {}
local numberSprites
local areNumbersHighlighted = {}
local people = {}
local doors = {}
local doorAnims = {}

function C.init()
  
  spritesheet = lg.newImage("/assets/spritesheet.png")
  background = lg.newImage("/assets/background.png")
  elevatorLeft = lg.newQuad(0, 376, 192, 192, 512, 640)
  elevatorRight = lg.newQuad(320, 376, 192, 192, 512, 640)
  numberSprites = lg.newImage("/assets/highlights.png")
  
  InitDoors()
  InitElevatorDoors()
  InitNumberHighlights()
  InitPeople()
  
end


function C.update(dt)
  
  GetDoorStatus()
  GetMovementQueues()
  
end


function C.draw()
  lg.draw(background, 0, 0, 0, .5, .5)
  DrawNumberHighlights()
  lg.draw(spritesheet, elevatorLeft, 40, E.getPosition("left"), 0, .5, .5)
  lg.draw(spritesheet, elevatorRight, 400, E.getPosition("right"), 0, .5, .5)
  DrawElevatorDoors()
  DrawDoors()
  
  lg.draw(spritesheet, people[1], 400, 300, 0, .5, .5)
  
end

-------USED LOCALLY ONLY -----------

function GetDoorStatus()
  
  for i=1, 14 do
    local doorStatus = E.getDoorStatus(i)
    if doorStatus >= 100 then
      if doorStatus < 110 then
        doorStatus = 2
      else
        doorStatus = 3
      end
    end
    elevatorDoors[i][4] = doorStatus
  end
  
end

function GetMovementQueues()
  
  local targetL, targetR, currentL, currentR = E.getElevatorQueues()
  
  for k=1, #areNumbersHighlighted do
    if k <= 7 then
      if targetL ~= -100 and targetL > currentL and k <= targetL and k > currentL then
        areNumbersHighlighted[k] = true
      elseif targetL ~= -100 and targetL < currentL and k >= targetL and k < currentL then
        areNumbersHighlighted[k] = true
      else
        areNumbersHighlighted[k] = false
      end
    else
      local j = k - 7
      if targetR ~= -100 and targetR > currentR and j <= targetR and j >= currentR then
        areNumbersHighlighted[k] = true
      elseif targetR ~= -100 and targetL < currentR and j >= targetR and j <= currentR then
        areNumbersHighlighted[k] = true
      else
        areNumbersHighlighted[k] = false
      end
    end
  end
  
end



function InitNumberHighlights()
  
  local highlightPosY = 504
  local highlightPosX = 44
  
  for i=0, 1 do
    for j = 1,7 do
      table.insert(numberHighlights, {lg.newQuad(i*160, 1120-j*160, 160, 160, 320, 1120), highlightPosX+(i*376), highlightPosY-((j-1)*80)})
      table.insert(areNumbersHighlighted, false)
    end
  end
  
end



function InitElevatorDoors()
  elevatorFrameAnims = 
  {
    lg.newQuad(0, 0, 64, 128, 512, 640),
    lg.newQuad(64, 0, 64, 128, 512, 640),
    lg.newQuad(128, 0, 64, 128, 512, 640)
  }
  elevatorDoorAnims = 
  {
    lg.newQuad(192, 0, 64, 128, 512, 640),
    lg.newQuad(256, 0, 64, 128, 512, 640),
    lg.newQuad(320, 0, 64, 128, 512, 640),
    lg.newQuad(384, 0, 64, 128, 512, 640)
  }
  --id = 1, x = 2, y = 3, currAnimNum = 4 <-- doors
  --id = 1,, x = 2, y = 3, upOrDown = 4 <-- frames
  for i=1, 7 do
    table.insert(elevatorDoorFrames, {i, 104, 500-(80*(i-1)), 1})
    table.insert(elevatorDoors, {i, 108, 512-(80*(i-1)), 1})
  end
  
  for i=8, 14 do
    table.insert(elevatorDoorFrames, {i, 388, 500-(80*(i-8)), 1})
    table.insert(elevatorDoors, {i, 392, 512-(80*(i-8)), 1})
  end
  
end


function DrawElevatorDoors()
  for i=1, 14 do
    local d = elevatorDoors[i]
    local f = elevatorDoorFrames[i]
    lg.draw(spritesheet, elevatorDoorAnims[d[4]], d[2], d[3], 0, .5, .5) 
    lg.draw(spritesheet, elevatorFrameAnims[f[4]], f[2], f[3], 0, .5, .5)
  end
end

function DrawNumberHighlights()
  
  for k, v in ipairs(areNumbersHighlighted) do
    if v then
      local n = numberHighlights[k]
      lg.draw(numberSprites, n[1], n[2], n[3], 0, .5, .5 )
    end
  end
  
end

function InitDoors()
  
  doorAnims = 
  {
    lg.newQuad(0, 256, 128, 100, 512, 640),
    lg.newQuad(128, 256, 128, 100, 512, 640),
    lg.newQuad(256, 256, 128, 100, 512, 640)
  }
  
  for i=1, 5 do
    for j = 1, 4 do
      local doorNum = (i+1).."0"..j
      table.insert(doors, {144 + ((j-1)*64), 436-((i-1)*80), 1, doorNum})
    end
  end
  
  table.insert(doors, {144, 36, 1, "pool"})
  table.insert(doors, {336, 36, 1, "gym"})
  
end


function DrawDoors()
  
  for i=1, 22 do
    d = doors[i]
    lg.draw(spritesheet, doorAnims[d[3]], d[1], d[2], 0, .5, .5)
    if d[3] == 1 then
      lg.printf(d[4], d[1], d[2]+4, 40, "center")
    end
  end
end



function InitPeople()
  
  for i=0, 15 do
    table.insert(people, lg.newQuad(32*i, 576, 32, 64, 512, 640))
  end
  
end


function DrawPeople()
  
  
  
end

return C