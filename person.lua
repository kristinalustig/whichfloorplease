local C = require "content"
local E = require "elevator"
P = {}

local people = {}
local maxSprites
local numPeople
local peopleWaiting 
local peopleInElevators
local destinations 
local states
local pSpeed 
local incr
local doorDelta
local waitingStartL
local waitingStartR
local elevatorWaitingStartL
local elevatorWaitingStartR
local tutorial
local numPeopleMoved
local queueSpacing 
local elevatorDeltaY 
local spawnRate
local doorOffsetY
local doorOffsetX 
function P.init()
  
  people = {}
  maxSprites = 16
  numPeople = 50
  peopleWaiting = {}
  peopleInElevators = {}
  destinations = {}
  states = {}
  pSpeed = 1*GS
  incr = 1
  doorDelta = 14*GS
  tutorial = true
  numPeopleMoved = 0
  queueSpacing = 2*GS
  elevatorDeltaY = 44*GS
  spawnRate = 20
  doorOffsetY = 12*GS
  doorOffsetX = 4*GS
  
  waitingStartL = 120*GS
  waitingStartR = 392*GS
  elevatorWaitingStartL = 50*GS
  elevatorWaitingStartR = 450*GS
  
  destinations = 
  {
    home = 1,
    gym = 2,
    pool = 3,
    out = 4,
    visit = 5
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
  
  CreatePeople()
  CreateQueues()
  
end


function P.update()
  
  incr = incr + 1
  
  UpdatePeopleStatus()
  UpdatePeopleLocation()
  C.updatePeople(people)
  
end


function CreatePeople()
  
  for i=1, numPeople do
    local sp = love.math.random(16)
    local h = love.math.random(20)
    local se = love.math.random(20)
    local loc
    if i % 5 == 0 then
      loc = "out"
    else
      loc = h
    end
    local fl = GetFloor(loc)
    table.insert(people, {
        home = home, 
        sprite = sp, 
        seed = se, 
        location = loc, 
        destination = nil, 
        destinationRoom = nil,
        state = states.hidden,
        floor = fl,
        timeout = 0})
    local x, y = C.getLoc(loc)
    people[#people].x, people[#people].y = x+doorOffsetX, y+doorOffsetY
    if loc == "out" then
      people[#people].x = people[#people].x + 10*GS
    end
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
  
  peopleInElevators = 
  {
    left = 0, 
    right = 0
  }
  
end


function UpdatePeopleStatus()
  
  local r = love.math.random(spawnRate)
  
  if r == 5 then --a 1 in spawnRate chance to show up each tick
    for _, v in ipairs(people) do
      if v.destination == nil then --if there is no destination, we can make one
        if incr % v.seed == 0 then
          local ran = love.math.random(4)
          if ran == 1 then
            v.destination = destinations.home
            v.destinationRoom = v.home
          elseif ran == 2 then
            local p = love.math.random(2)
            if p == 1 then
              v.destination = destinations.gym
              v.destinationRoom = 21
            else
              v.destination = destinations.pool
              v.destinationRoom = 22
            end
          elseif ran == 3 then
            v.destination = destinations.out
            v.destinationRoom = 23
          elseif ran == 4 then
            v.destination = destinations.visit
            v.destinationRoom = love.math.random(20)
          end
          --if the destination and location are the same, just bow out for a tick
          if v.destinationRoom == v.location or (v.location == "out" and v.destination == destinations.out) or (v.location == 23 and v.destination == destinations.out) or (v.location == "out" and v.destination == destinations.out) then
            v.destination = nil
            v.destinationRoom = nil
          end
        end
        return
      end
    end
  end
  
end


function UpdatePeopleLocation()
  
  for k, v in ipairs(people) do
    if v.destination ~= nil then
      if v.timeout > 0 then
        v.timeout = v.timeout - 1
      else
        v.x, v.y, v.destination, v.location, v.state, v.destinationRoom, v.floor = Move(v.x, v.y, v.destination, v.location, v.state, v.floor, v.destinationRoom)
        if v.destination == nil then
          v.timeout = 1000
        end
      end
    end
  end
  
end


--px, py, dest, loc, state, floor, destination room
function Move(x, y, d, l, s, f, dr)
  
  if f == nil then
    f = GetFloor(l)
  end
  
  if dr == nil then --ugh i don't know why this happens but here we are
    if d == destinations.out then
      dr = 23
    else
      dr = GetFloor(d)
    end
  end
  local df = GetFloor(dr)
  
  
------JUST STARTING THEIR JOURNEY - STILL HIDDEN
  if s == states.hidden then
    --begin opening door OR finish opening and become visible
    local door = C.getAptDoorStatus(l)
    if door == "open" then
      if l == "out" or l == 23 then
        s = states.enterBuilding
      else
        s = states.exitRoom
      end
    else
      C.updateAptDoorStatus(l, "open")
    end
    
    
--------EXIT ROOM / ENTER BUILDING AKA ENTER SCREEN
  elseif s == states.enterBuilding then
    --begin entering building or begin moving to elevator
    local _, doorY = C.getLoc(l)
    if y - doorY < doorDelta then
      y = y + pSpeed
    else
      local doorS = C.getAptDoorStatus(l)
      if doorS ~= "closed" then
        C.updateAptDoorStatus(l, "closed")
      else
        local el = E.whichElevatorToPick(1, df)
        if el == "left" then
          s = states.walkToElevatorL
        else
          s = states.walkToElevatorR
        end
      end
    end
  elseif s == states.exitRoom then
    --begin exiting room or begin moving to elevator
    local _, doorY = C.getLoc(l)
    if y - doorY < doorDelta then
      y = y + pSpeed
    else
      local doorS = C.getAptDoorStatus(l)
      if doorS ~= "closed" then
        C.updateAptDoorStatus(l, "closed")
      else
        local el = E.whichElevatorToPick(f, df)
        if el == "left" then
          s = states.walkToElevatorL
        elseif el == "neither" then
          s = states.walkToDestination
        else
          s = states.walkToElevatorR
        end
      end
    end
    
    
-------WALK TO ELEVATOR - DONE
  elseif s == states.walkToElevatorL then
    --adjust person location, check if arrived
    x = x - pSpeed
    if x <= (waitingStartL + (peopleWaiting[f].left*queueSpacing)) then --queue em up
      peopleWaiting[f].left = peopleWaiting[f].left + 1
      s = states.waitElevatorL
    end
  elseif s == states.walkToElevatorR then
    --adjust person location, check if arrived
    x = x + pSpeed
    if x >= (waitingStartR - (peopleWaiting[f].right*queueSpacing)) then --they arrived, queue em up
      peopleWaiting[f].right = peopleWaiting[f].right + 1
      s = states.waitElevatorR
    end
    
    
--------WAITING FOR ELEVATOR
  elseif s == states.waitElevatorL then
    --add one to the queue for that floor
    if E.hasElevatorArrived("left", f) then --they will get in the elevator now
      peopleWaiting[f].left = peopleWaiting[f].left - 1
      s = states.enterElevatorL
      --tell elevators that there is stuff going on
      E.movingInOutElevator("left", "add")
    end
    --maybe add anger if necessary
  elseif s == states.waitElevatorR then
    --add one to the queue for that floor
    if E.hasElevatorArrived("right", f) then --they will get in the elevator now
      peopleWaiting[f].right = peopleWaiting[f].right - 1
      s = states.enterElevatorR
      --tell elevators that there is stuff going on
      E.movingInOutElevator("right", "add")
    end
  
  
-------ENTER ELEVATOR
  elseif s == states.enterElevatorL then
    --add destination to elevator indicator if not already present
    C.updateElevatorIndicator("left", df, "add")
    --adjust person location
    x = x - pSpeed
    if x <= (elevatorWaitingStartL + (peopleInElevators.left*queueSpacing)) then --queue em up
      peopleInElevators.left = peopleInElevators.left + 1
      E.movingInOutElevator("left", "remove")
      s = states.inElevatorL
    end
  elseif s == states.enterElevatorR then
    --add destination to elevator indicator if not already present
    C.updateElevatorIndicator("right", df, "add")
    --adjust person location
    x = x + pSpeed
    if x >= (elevatorWaitingStartR - (peopleInElevators.right*queueSpacing)) then --queue em up
      peopleInElevators.right = peopleInElevators.right + 1
      s = states.inElevatorR
      E.movingInOutElevator("right", "remove")
    end
    
    
--------IN ELEVATOR
  elseif s == states.inElevatorL then
    --adjust Y based on elevator Y
    y = E.getPosition("left") + elevatorDeltaY
    --check if elevator is at floor + door open
    if E.hasElevatorArrived("left", df) then
      s = states.exitElevatorL
      E.movingInOutElevator("left", "add")
    end
  elseif s == states.inElevatorR then
    --adjust Y based on elevator Y
    y = E.getPosition("right") + elevatorDeltaY
    --check if elevator is at floor + door open
    if E.hasElevatorArrived("right", df) then
      s = states.exitElevatorR
      E.movingInOutElevator("right", "add")
    end
    
    
--------EXIT ELEVATOR
  elseif s == states.exitElevatorL then
    --adjust person location
    x = x + pSpeed
    if x >= waitingStartL then
      --remove destination from elevator indicator
      C.updateElevatorIndicator("left", df, "remove")
      peopleInElevators.left = peopleInElevators.left - 1
      s = states.walkToDestination
      E.movingInOutElevator("left", "remove")
    end
  elseif s == states.exitElevatorR then
    x = x - pSpeed
    --adjust person location
    if x <= waitingStartR then
      --remove destination from elevator indicator
      C.updateElevatorIndicator("right", df, "remove")
      peopleInElevators.right = peopleInElevators.right - 1
      s = states.walkToDestination
      E.movingInOutElevator("right", "remove")
    end
    
    
--------WALK FROM ELEVATOR TO DESTINATION
  elseif s == states.walkToDestination then
    --adjust X toward destination
    local doorX, _ = C.getLoc(dr)
    if dr == 23 then
      doorX = doorX + 20*GS
    else
      doorX = doorX + 10*GS
    end
    if doorX > x and math.abs(doorX - x) > 2 then
      x = x + pSpeed
    elseif doorX < x and math.abs(doorX - x) > 2 then
      x = x - pSpeed
    else
      x = doorX + pSpeed
      if d == "out" then
        s = states.exitBuilding
      else
        s = states.enterRoom
      end
    end
    
    
--------ENTER ROOM / EXIT BUILDING AKA LEAVE SCREEN
  elseif s == states.enterRoom then
    --begin entering room or become hidden and begin closing door
    local doorY = GetYFromDoor(dr)
    if y - doorY == 4 then
      local doorS = C.getAptDoorStatus(dr)
      if doorS ~= "open" then
        C.updateAptDoorStatus(dr, "open")
      elseif doorS == "open" then
        y = y - pSpeed
      end
    elseif y - doorY > 0 then
      y = y - pSpeed
    else
      local doorS = C.getAptDoorStatus(dr)
      if doorS ~= "closed" then
        C.updateAptDoorStatus(dr, "closed")
      else
        s = states.hidden
        d = nil
        l = dr
        dr = nil
        f = df
      end
    end
  elseif s == states.exitBuilding then
    --begin entering room or become hidden and begin closing door
    local doorY = GetYFromDoor(23)
    if y - doorY == 4 then
      local doorS = C.getAptDoorStatus(23)
      if doorS ~= "open" then
        C.updateAptDoorStatus(23, "open")
      elseif doorS == "open" then
        y = y - pSpeed
      end
    elseif y - doorY > 0 then
      y = y - pSpeed
    else
      local doorS = C.getAptDoorStatus(23)
      if doorS ~= "closed" then
        C.updateAptDoorStatus(23, "closed")
      else
        s = states.hidden
        d = nil
        l = dr
        dr = nil
        f = df
      end
    end
  end
  
  return x, y, d, l, s, dr, f
  
end

function GetFloor(h)
  
  if h == "out" or h == 23 then 
    return 1
  end
  
  if h == nil then
    return
  end
  
  for i=7, 0, -1 do
    local x = h - (4*i)
    if x <= 4 and x >= 1 then
      return i+2
    end
  end
  
end

function GetYFromDoor(d)
  
  local _, doorY = C.getLoc(d)
  return doorY + doorOffsetY
  
end


return P