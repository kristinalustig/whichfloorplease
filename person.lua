P = {}

local people = {}
local maxSprites = 16
local numPeople = 50
local peopleWaiting = {}
local destinations = {}
local states = {}

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

function P.getPersonState(p)
  return people[p][4]
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
        state = states.hidden})
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
      v.dx, v.dy, v.destination, v.state = Move(v.state, v.location, v.destination)
    end
  end
  
end

function Move(s, l, d)
  local newS, dx, dy = nil, 0, 0
  
  --if they are hidden then exit their location
  if s == states.hidden then
    if l == "out" then
      newS = states.enterBuilding
      dy = 3
    else
      newS = states.exitRoom
      dy = 3
    end
  elseif s == states.walkToElevatorL then
    dx = -3
  elseif s == states.walkToElevatorR then
    dx = 3
  elseif s == states.enterElevatorL then
    dx = -3
  elseif s == states.enterElevatorR then
    dx = 3
  elseif s == states.inElevatorL then
    
  elseif s == states.inElevatorR then
    
  elseif s == states.exitElevatorL then
    
  elseif s == states.exitElevatorR then
    
  elseif s == states.walkToDestination then
    
  elseif s == states.enterRoom then
    
  elseif s == states.exitBuilding then
    
  elseif s == states.enterBuilding then
    
  elseif s == states.exitRoom then
    
  elseif s == states.waitElevatorL then
    
  elseif s == states.waitElevatorR then
    
  
end

return P