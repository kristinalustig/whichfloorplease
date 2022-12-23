local C = require "content"
local E = require "elevator"
P = {}

local people = {}
local maxSprites = 16
local numPeople = 50
local peopleWaiting = {}
local peopleInElevators = {}
local destinations = {}
local states = {}
local pSpeed = 1
local incr = 1
local doorDelta = 14
local waitingStartL
local waitingStartR
local elevatorWaitingStartL
local elevatorWaitingStartR
local tutorial = true
local numPeopleMoved = 0
local queueSpacing = 2
local elevatorDeltaY = 40

function P.init()
  
  waitingStartL = 120
  waitingStartR = 392
  elevatorWaitingStartL = 50
  elevatorWaitingStartR = 450
  
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
        timeout = 100})
    local x, y = C.getLoc(loc)
    people[#people].x, people[#people].y = x+10, y+10
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
  
  local r = love.math.random(10)
  
  if r == 5 then --a 1 in x chance to show up each tick
    for k, v in ipairs(people) do
      if v.destination == nil then
        if incr % v.seed == 0 then
          local ran = love.math.random(5)
          if ran == 1 then
            v.destination = destinations.home
            v.destinationRoom = v.home
          elseif ran == 2 then
            v.destination = destinations.gym
            v.destinationRoom = 21
          elseif ran == 3 then
            v.destination = destinations.pool
            v.destinationRoom = 22
          elseif ran == 4 then
            v.destination = destinations.out
            v.destinationRoom = 23
          elseif ran == 5 then
            v.destination = destinations.visit
            v.destinationRoom = love.math.random(20)
          end
          if v.destinationRoom == v.location or (v.location == "out" and v.destination == v.out) then
            v.destination = nil
            v.destinationRoom = nil
          end
        end
        return
      end
    end
  end
  
end


function UpdatePeopleLocation(dt)
  
  for k, v in ipairs(people) do
    if v.destination ~= nil then
      if v.timeout > 0 then
        v.timeout = v.timeout - 1
      else
      --print("x is "..v.x..", y is "..v.y..", leaving from "..v.location..", heading to "..v.destination.." and state is "..v.state)
        v.x, v.y, v.destination, v.location, v.state = Move(v.x, v.y, v.destination, v.location, v.state, v.floor, v.destinationRoom)
        if v.destination == nil then
          v.timeout = 100
        end
      end
    end
  end
  
end


--px, py, dest, loc, state, floor, destination room
function Move(x, y, d, l, s, f, dr)
  
  if dr == nil then
    if d == destinations.out then
      dr = 1
    else
      dr = GetFloor(d)
    end
  end
  local df = GetFloor(dr)
  
------JUST STARTING THEIR JOURNEY - STILL HIDDEN - DONE
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
    
-------WALK TO ELEVATOR - DONE
  elseif s == states.walkToElevatorL then
    --adjust person location, check if arrived
    x = x - pSpeed
    if x <= (waitingStartL + (peopleWaiting[f].left*2)) then --queue em up
      peopleWaiting[f].left = peopleWaiting[f].left + queueSpacing
      s = states.waitElevatorL
    end
  elseif s == states.walkToElevatorR then
    --adjust person location, check if arrived
    x = x + pSpeed
    if x >= (waitingStartR - (peopleWaiting[f].right*2)) then --they arrived, queue em up
      peopleWaiting[f].right = peopleWaiting[f].right + queueSpacing
      s = states.waitElevatorR
    end
    
-------ENTER ELEVATOR
  elseif s == states.enterElevatorL then
    --add destination to elevator indicator if not already present
    C.updateElevatorIndicator("left", df, "add")
    --adjust person location
    x = x - pSpeed
    if x <= (elevatorWaitingStartL + (peopleInElevators.left*2)) then --queue em up
      peopleInElevators.left = peopleInElevators.left + queueSpacing
      s = states.inElevatorL
    end
  elseif s == states.enterElevatorR then
    --add destination to elevator indicator if not already present
    C.updateElevatorIndicator("right", df, "add")
    --adjust person location
    x = x + pSpeed
    if x >= (elevatorWaitingStartR + (peopleInElevators.right*2)) then --queue em up
      peopleInElevators.right = peopleInElevators.right + queueSpacing
      s = states.inElevatorR
    end
    
--------IN ELEVATOR
  elseif s == states.inElevatorL then
    --adjust Y based on elevator Y
    y = E.getPosition("left") + elevatorDeltaY
    --check if elevator is at floor + door open
    if E.hasElevatorArrived("left", df) then
      s = states.exitElevatorL
    end
  elseif s == states.inElevatorR then
    --adjust Y based on elevator Y
    y = E.getPosition("right") + elevatorDeltaY
    --check if elevator is at floor + door open
    if E.hasElevatorArrived("right", df) then
      s = states.exitElevatorR
    end
    
    
--------EXIT ELEVATOR - DONE
  elseif s == states.exitElevatorL then
    --remove destination from elevator indicator
    C.updateElevatorIndicator("left", df, "remove")
    --adjust person location
    x = x + pSpeed
    if x >= waitingStartL then
      peopleInElevators.left = peopleInElevators.left - queueSpacing
      s = states.walkToDestination
    end
  elseif s == states.exitElevatorR then
    --remove destination from elevator indicator
    C.updateElevatorIndicator("right", df, "remove")
    --adjust person location
    if x <= waitingStartR then
      peopleInElevators.right = peopleInElevators.right - queueSpacing
      s = states.walkToDestination
    end
    
--------WALK FROM ELEVATOR TO DESTINATION - DONE
  elseif s == states.walkToDestination then
    --adjust X toward destination
    local doorX, _ = C.getLoc(dr)
    if doorX > x and math.abs(doorX - x) > 2 then
      x = x + 2
    elseif doorX < x and math.abs(doorX - x) > 2 then
      x = x - 2
    else
      x = doorX + 2
      if d == "out" then
        s = states.exitBuilding
      else
        s = states.enterRoom
      end
    end
    
    
--------ENTER ROOM / EXIT BUILDING AKA LEAVE SCREEN - DONE
  elseif s == states.enterRoom then
    --begin entering room or become hidden and begin closing door
    local _, doorY = C.getLoc(dr)
    if y - doorY == doorDelta then
      local doorS = C.getAptDoorStatus(dr)
      if doorS == "closed" then
        C.updateAptDoorStatus(d, "open")
      elseif doorS == "open" then
        y = y - 2
      end
    elseif y - doorY > 0 then
      y = y - 2
    else
      local doorS = C.getAptDoorStatus(dr)
      if doorS == "closed" then
        s = states.hidden
        d = nil
        l = dr
      else
        C.updateAptDoorStatus(d, "closed")
        C.updateAptDoorStatus(d, "closed")
      end
    end
  elseif s == states.exitBuilding then
    --begin entering room or become hidden and begin closing door
    local _, doorY = C.getLoc(d)
    if y - doorY == doorDelta then
      local doorS = C.getAptDoorStatus(dr)
      if doorS == "closed" then
        C.updateAptDoorStatus(d, "open")
      elseif doorS == "open" then
        y = y - pSpeed
      end
    elseif y - doorY > 0 then
      y = y - pSpeed
    else
      local doorS = C.getAptDoorStatus(d)
      if doorS == "closed" then
        s = states.hidden
        d = nil
        l = dr
      else
        C.updateAptDoorStatus(d, "closed")
        C.updateAptDoorStatus(d, "closed")
        C.updateAptDoorStatus(d, "closed")
      end
    end
    
--------EXIT ROOM / ENTER BUILDING AKA ENTER SCREEN - DONE
  elseif s == states.enterBuilding then
    --begin entering building or begin moving to elevator
    local _, doorY = C.getLoc(l)
    if y - doorY < doorDelta then
      y = y + pSpeed
    else
      local el = E.whichElevatorToPick(1, df)
      if el == "left" then
        s = states.walkToElevatorL
      else
        s = states.walkToElevatorR
      end
      C.updateAptDoorStatus(l, "closed")
      C.updateAptDoorStatus(l, "closed")
      C.updateAptDoorStatus(l, "closed")
    end
  elseif s == states.exitRoom then
    --begin exiting room or begin moving to elevator
    local _, doorY = C.getLoc(l)
    if y - doorY < doorDelta then
      y = y + pSpeed
    else
      local el = E.whichElevatorToPick(f, df)
      if el == "left" then
        s = states.walkToElevatorL
      elseif el == "neither" then
        s = states.walkToDestination
      else
        s = states.walkToElevatorR
      end
      C.updateAptDoorStatus(l, "closed")
      C.updateAptDoorStatus(l, "closed")
    end
    
--------WAITING FOR ELEVATOR - DONE
  elseif s == states.waitElevatorL then
    --add one to the queue for that floor
    if E.hasElevatorArrived("left", f) then --they will get in the elevator now
      peopleWaiting[f].left = peopleWaiting[f].left - queueSpacing
      s = states.enterElevatorL
    end
    --maybe add anger if necessary
  elseif s == states.waitElevatorR then
    --add one to the queue for that floor
    if E.hasElevatorArrived("right", f) then --they will get in the elevator now
      peopleWaiting[f].right = peopleWaiting[f].right - queueSpacing
      s = states.enterElevatorR
    end
  end
  
  return x, y, d, l, s
  
end

function GetFloor(h)
  
  if h == "out" or h == 23 then 
    return 1
  end
  
  if h == nil then
    return
  end
  
  for i=5, 0, -1 do
    local x = h - (4*i)
    if x <= 4 and x >= 1 then
      return i+2
    end
  end
  
end

return P