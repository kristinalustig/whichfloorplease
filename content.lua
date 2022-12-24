local E = require "elevator"
--getcher assets here!
C = {}

local spritesheet
local background
local elevatorLeft
local elevatorRight
local elevatorDoorAnims
local elevatorDoors = {}
local elevatorDoorFrames = {}
local elevatorDoorFloors = {}
local elevatorDoorFloorQuads = {}
local elevatorDirections = {}
local elevatorFrameAnims
local frontDoor = {}
local frontDoorAnims = {}
local residents = {}
local numberHighlights = {}
local numberSprites
local areNumbersHighlighted = {}
local people = {}
local doors = {}
local doorAnims = {}
local thoughtBubbleImg
local tbLeft = {}
local tbRight = {}
local peopleObjs = {}
local howToOne
local howToTwo
local incr

function C.init()
  
  spritesheet = lg.newImage("/assets/spritesheet.png")
  background = lg.newImage("/assets/background.png")
  elevatorLeft = lg.newQuad(0, 376, 192, 192, 512, 640)
  elevatorRight = lg.newQuad(320, 376, 192, 192, 512, 640)
  numberSprites = lg.newImage("/assets/highlights.png")
  thoughtBubbleImg = lg.newQuad(192, 448, 128, 64, 512, 640)
  howToOne = lg.newImage("/assets/howToOne.png")
  howToTwo = lg.newImage("/assets/howToTwo.png")
  
  incr = 80*GS
  
  InitDoors()
  InitElevatorDoors()
  InitNumberHighlights()
  InitPeople()
  InitFrontDoor()
  
end


function C.update(dt)
  
  GetDoorStatus()
  GetMovementQueues()
  
end


function C.draw()
  lg.draw(background, 0, 0, 0, GLOBALSCALE, GLOBALSCALE)
  lg.draw(howToOne, 0, 0, 0, GLOBALSCALE, GLOBALSCALE)
  DrawNumberHighlights()
  lg.draw(spritesheet, elevatorLeft, 40*GS, E.getPosition("left"), 0, GLOBALSCALE, GLOBALSCALE)
  lg.draw(spritesheet, elevatorRight, 400*GS, E.getPosition("right"), 0, GLOBALSCALE, GLOBALSCALE)
  DrawElevatorIndicators()
  DrawDoors()
  DrawElevatorDoors()
  DrawFrontDoor()
  DrawPeople()
end


function C.getLoc(l)
  
  if l == "out" or l == 23 then
    return frontDoor[1], frontDoor[2]
  else
    return doors[l][1], doors[l][2]
  end
  
end

function C.getAptDoorStatus(l)
  
  if l == "out" or l == 23 then
    --do main door
    local s = frontDoor[3]
    if s == 1 then
      return "closed"
    elseif s == 2 or s == 3 then
      return "notyet"
    else
      return "open"
    end
  else
    local s = doors[l][3]
    if s == 1 then
      return "closed"
    elseif s == 2 then
      return "notyet"
    else
      return "open"
    end
  end
  
end

function C.updateAptDoorStatus(l, dir)
  
  local d
  
  if l == "out" or l == 23 then
    d = frontDoor[3]
    if d == 1  and dir == "open" then
      frontDoor[3] = 2
    elseif d == 3 and dir == "open" then
      frontDoor[3] = 4
    elseif d == 3 and dir == "closed" then
      frontDoor[3] = 2
    elseif d == 2 and dir == "open" then
      frontDoor[3] = 3
    elseif d == 2 and dir == "closed" then
      frontDoor[3] = 1
    elseif d == 4 and dir == "closed" then
      frontDoor[3] = 3
    end
  else
    d = doors[l][3]
    if d == 1 and dir == "open" then
      doors[l][3] = 2
    elseif d == 3 and dir == "closed" then
      doors[l][3] = 2
    elseif d == 2 and dir == "open" then
      doors[l][3] = 3
    elseif d == 2 and dir == "closed" then
      doors[l][3] = 1
    end
  end
  
end

function C.updateElevatorIndicator(el, df, act)
  
  local tb
  if el == "left" then
    tb = tbLeft
  else
    tb = tbRight
  end
  
  for k, v in ipairs(tb) do
    if v == df then 
      if act == "remove" then
        if el == "left" then
          table.remove(tbLeft, k)
        else
          table.remove(tbRight, k)
        end
      end
      return
    end
  end
  if act == "add" then
    if el == "left" then
      table.insert(tbLeft, df)
    else
      table.insert(tbRight, df)
    end
  end
  
end

function C.updatePeople(p)
  
  peopleObjs = p
  
end

-------USED LOCALLY ONLY -----------

function InitFrontDoor()
  
  frontDoorAnims = 
  {
    lg.newQuad(0, 128, 128, 100, 512, 640),
    lg.newQuad(128, 128, 128, 100, 512, 640),
    lg.newQuad(256, 128, 128, 100, 512, 640),
    lg.newQuad(384, 128, 128, 100, 512, 640)
  }
  
  frontDoor = {228*GS, 516*GS, 1}
  
end

function DrawFrontDoor()
  
  lg.draw(spritesheet, frontDoorAnims[frontDoor[3]], frontDoor[1], frontDoor[2], 0, GLOBALSCALE, GLOBALSCALE)
  
end
  


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
  
  local highlightPosY = 504*GS
  local highlightPosX = 44*GS
  
  for i=0, 1 do
    for j = 1,7 do
      table.insert(numberHighlights, {lg.newQuad(i*160, 1120-j*160, 160, 160, 320, 1120), highlightPosX+(i*376*GS), highlightPosY-((j-1)*incr)})
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
  
  elevatorDoorFloorQuads =
  {
    lg.newQuad(320, 256, 64, 24, 512, 640),
    lg.newQuad(384, 256, 64, 24, 512, 640),
    lg.newQuad(320, 296, 64, 24, 512, 640),
    lg.newQuad(384, 296, 64, 24, 512, 640)
  }
  --id = 1, x = 2, y = 3, currAnimNum = 4 <-- doors
  --id = 1,, x = 2, y = 3, upOrDown = 4 <-- frames
  for i=1, 7 do
    table.insert(elevatorDoorFrames, {i, 104*GS, 500*GS-(incr*(i-1)), 1})
    table.insert(elevatorDoors, {i, 108*GS, 512*GS-(incr*(i-1)), 1})
    if i == 1 or i == 7 then
      table.insert(elevatorDoorFloors, {110*GS, 560*GS-(incr*(i-1)), 3})
    else
      table.insert(elevatorDoorFloors, {110*GS, 560*GS-(incr*(i-1)), 1})
    end
  end
  
  for i=8, 14 do
    table.insert(elevatorDoorFrames, {i, 388*GS, 500*GS-(incr*(i-8)), 1})
    table.insert(elevatorDoors, {i, 392*GS, 512*GS-(incr*(i-8)), 1})
    if i == 8 or i == 14 then
      table.insert(elevatorDoorFloors, {398*GS, 560*GS-(incr*(i-8)), 4})
    else
      table.insert(elevatorDoorFloors, {398*GS, 560*GS-(incr*(i-8)), 2})
    end
  end
  
end


function DrawElevatorDoors()
  for i=1, 14 do
    local d = elevatorDoors[i]
    local f = elevatorDoorFrames[i]
    local g = elevatorDoorFloors[i]
    lg.draw(spritesheet, elevatorDoorAnims[d[4]], d[2], d[3], 0, GLOBALSCALE, GLOBALSCALE) 
    lg.draw(spritesheet, elevatorFrameAnims[f[4]], f[2], f[3], 0, GLOBALSCALE, GLOBALSCALE)
    lg.draw(spritesheet, elevatorDoorFloorQuads[g[3]], g[1], g[2], 0, GLOBALSCALE, GLOBALSCALE)
  end
end

function DrawElevatorIndicators()
  
  local y1 = E.getPosition("left") + 20*GS
  local y2 = E.getPosition("right") + 20*GS
  
  lg.setFont(dreamFont)
  lg.setColor(1, 1, 1)
  
  if #tbLeft > 0 then
    lg.draw(spritesheet, thoughtBubbleImg, 52*GS, y1, 0, GLOBALSCALE, GLOBALSCALE)
    local str = ""
    for _, v in ipairs(tbLeft) do
      if str == "" then
        str = v
        str = v
      else
        str = str .. ", "..v
      end
    end
    lg.setColor(0, 0, 0)
    lg.printf(str, 52*GS, y1+2*GS, 100, "center", 0, GLOBALSCALE, GLOBALSCALE)
    lg.setColor(1, 1, 1)
  end
  
  if #tbRight > 0 then
    lg.draw(spritesheet, thoughtBubbleImg, 410*GS, y2, 0, GLOBALSCALE, GLOBALSCALE)
    local str = ""
    for _, v in ipairs(tbRight) do
      if str == "" then
        str = v
      else
        str = str .. ", "..v
      end
    end
    lg.setColor(0, 0, 0)
    lg.printf(str, 410*GS, y2+2*GS, 100, "center", 0, GLOBALSCALE, GLOBALSCALE)
    lg.setColor(1, 1, 1)
  end
  
  lg.setFont(doorFont)
  
  
end

function DrawNumberHighlights()
  
  for k, v in ipairs(areNumbersHighlighted) do
    if v then
      local n = numberHighlights[k]
      lg.draw(numberSprites, n[1], n[2], n[3], 0, GLOBALSCALE, GLOBALSCALE )
    end
  end
  
end

function InitDoors()
  
  doorAnims = 
  {
    lg.newQuad(0, 256, 128, 100, 512, 640),
    lg.newQuad(128, 256, 128, 100, 512, 640),
    lg.newQuad(256, 256, 40, 100, 512, 640)
  }
  
  for i=1, 5 do
    for j = 1, 4 do
      local doorNum = (i+1).."0"..j
      table.insert(doors, {144*GS + ((j-1)*64*GS), 436*GS-((i-1)*incr), 1, doorNum})
    end
  end
  
  table.insert(doors, {144*GS, 36*GS, 1, "pool"})
  table.insert(doors, {336*GS, 36*GS, 1, "gym"})
  
end


function DrawDoors()
  
  for i=1, 22 do
    d = doors[i]
    lg.draw(spritesheet, doorAnims[d[3]], d[1], d[2], 0, GLOBALSCALE, GLOBALSCALE)
    if d[3] == 1 then
      lg.printf(d[4], d[1], d[2]+4, 80, "center", 0, GLOBALSCALE, GLOBALSCALE)
    end
  end
  
end



function InitPeople()
  
  for i=0, 15 do
    table.insert(people, lg.newQuad(32*i, 576, 32, 64, 512, 640))
  end
  
end

function DrawPeople()
  
  for k, v in ipairs(peopleObjs) do
    if v.state ~= 1 then
      lg.draw(spritesheet, people[v.sprite], v.x, v.y, 0, GLOBALSCALE, GLOBALSCALE)
    end
  end
  
end

return C