local C = require "content"
local E = require "elevator"
P = {}

local people = {}
local maxSprites = 16
local numPeople = 50
local peopleWaiting = {}
local destinations = {}
local states = {}
local pSpeed = 2

function P.init()
  
  CreatePeople()
  CreateQueues()
  
  destinations = 
  {
    "home",
    "gym",
    "pool",
    "out",
    "visit"
  }
  
  states = 
  {
    hidden = 1,
    walkToElevatorL = 2,
    walkToElevatorR = 3,
    enterElevatorL = 4,
    enterElevatorR = 5,
    inElevatorL = 6,
    inElevatorR = 7,
    exitElevatorL = 8,
    exitElevatorR = 9,
    walkToDestination = 10,
    enterRoom = 11,
    exitBuilding = 12,
    enterBuilding = 13,
    exitRoom = 14,
    waitElevatorL = 15,
    waitElevatorR = 16
  }
  
end

function P.getPeople()
  return people
end


function P.update(dt)
  
  UpdatePeopleStatus(dt)
  UpdatePeopleLocation(dt)
  
end

--home #, sprite #, seed, location, destination
function CreatePeople()
  
  for i=1, numPeople do
    local sp = love.math.random(16)
    local h = love.math.random(20)
    local se = love.math.random(100)
    local fl = GetFloor(h)
    local loc
    if i % 3 == 0 then
      loc == "out"
    else
      loc == h
    end
    table.insert(people, {
        home = home, 
        sprite = sp, 
        seed = se, 
        location = loc, 
        destination = nil, 
        state = states.hidden,
        floor = fl})
    people[#people].x, people[#people].y = C.getLoc(loc)
  end
  
end

function CreateQueues()
  
  peopleWaiting = 
  {
    {left = 0, right = 0},
    {left = 0, right = 0},
    {left = 0, right = 0},
    {left = 0, right = 0},
    {left = 0, right = 0},
    {left = 0, right = 0},
    {left = 0, right = 0}
  }
  
end


function UpdatePeopleStatus(dt)
  
  local r = love.math.random(10)
  
  if r == 5 then
    for k, v in ipairs(people) do
      if dt % v.seed == 0 then
        local ran = love.math.random(5)
        v.destination = destinations[ran]
      end
    end
  end
  
end


function UpdatePeopleLocation(dt)
  
  for k, v in ipairs(people) do
    if v.destination ~= nil then
      v.x, v.y, v.destination, v.location, v.state = Move(v.x, v.y, v.destination, v.location, v.state, v.floor)
    end
  end
  
end

function Move(x, y, d, l, s, f)
  
  --if they are hidden then exit their location
  if s == states.hidden then
    --begin opening door OR finish opening and become visible
    local d = C.getDoorStatus(l)
    if d == "open" then
      if l == "out" then
        s = states.enterBuilding
      else
        s = states.exitRoom
      end
    else
      C.updateDoorStatus(l, "open")
    end
  elseif s == states.walkToElevatorL then
    --adjust person location, check if arrived
    x = x - pSpeed
    if x <= (C.getElevatorX("left") + (peopleWaiting[f].left*2) then
      peopleWaiting[f].left = peopleWaiting[f].left + 1
      s = states.waitElevatorL
    end
  elseif s == states.walkToElevatorR then
    --adjust person location, check if arrived
    x = x + pSpeed
    if x >= (C.getElevatorX("right") - (peopleWaiting[f].right*2) then
      peopleWaiting[f].right = peopleWaiting[f].right + 1
      s = states.waitElevatorL
    end
  elseif s == states.enterElevatorL then
    --remove one from the queue
    --add destination to elevator indicator if not already present
    --adjust person location
  elseif s == states.enterElevatorR then
    --remove one from the queue
    --add destination to elevator indicator if not already present
    --adjust person location
  elseif s == states.inElevatorL then
    --adjust Y based on elevator Y
    --check if elevator is at floor + door open
  elseif s == states.inElevatorR then
    --adjust Y based on elevator Y
    --check if elevator is at floor + door open
  elseif s == states.exitElevatorL then
    --remove destination from elevator indicator
    --adjust person location
  elseif s == states.exitElevatorR then
    --remove destination from elevator indicator
    --adjust person location
  elseif s == states.walkToDestination then
    --adjust X toward destination
    --check if arrived
  elseif s == states.enterRoom then
    --begin entering room or become hidden and begin closing door
  elseif s == states.exitBuilding then
    --begin entering room or become hidden and begin closing door
  elseif s == states.enterBuilding then
    --begin entering building or begin moving to elevator
    local _, doorY = C.getLoc(l)
    if y - doorY < 8 then
      y = y + 2
    else
      local el = E.whichElevatorIsCloser(1)
      if el == "left" then
        s = states.walkToElevatorL
      else
        s = states.walkToElevatorR
      end
    end
  elseif s == states.exitRoom then
    --begin exiting room or begin moving to elevator
  elseif s == states.waitElevatorL then
    --add one to the queue for that floor
    if E.hasElevatorArrived("left") then
      peopleWaiting[f].left = peopleWaiting[f].left - 1
      s = states.enterElevatorL
    end
    --maybe add anger if necessary
  elseif s == states.waitElevatorR then
    --add one to the queue for that floor
    if E.hasElevatorArrived("right") then
      peopleWaiting[f].right = peopleWaiting[f].right - 1
      s = states.enterElevatorL
    end
  end
  
  return x, y, d, l, s
  
end

function GetFloor(h)
  
  for i=4, 0, -1 do
    local x = h - (4*i)
    if x <= 4 and x >= 1 then
      return i+2
    end
  end
  
end

return P