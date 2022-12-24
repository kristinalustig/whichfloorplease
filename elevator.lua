E = {}

local increment
local selectedElevator
local elevator1 = {}
local elevator2 = {}
local elevatorSpeed
local doorSpeed
local doorTimingMax
local doorTimingMin
local positionHighest
local positionLowest
local elevatorArrive
local elevatorMove
local elevatorClose
local elevatorOpen

function E.init()
  
  increment = 80*GS
  elevator1.position = 488*GS
  elevator2.position = 488*GS
  selectedElevator = elevator1
  elevator1.targetFloor = -100
  elevator2.targetFloor = -100
  elevator1.currentFloor = 1
  elevator2.currentFloor = 1
  elevator1.doorState = 1
  elevator2.doorState = 1
  elevator1.doorTiming = 100
  elevator2.doorTiming = 100
  elevator1.moveQueue = {}
  elevator2.moveQueue = {}
  positionHighest = 8*GS
  positionLowest = 488*GS
  elevatorSpeed = 3*GS
  doorSpeed = 1*GS
  doorTimingMax = 120
  doorTimingMin = 100
  elevator1.executingCommand = false
  elevator2.executingCommand = false
  elevator1.peopleMoving = 0
  elevator2.peopleMoving = 0
  elevatorArrive = la.newSource("/assets/elevatorArrive.wav", "static")
  elevatorArrive:setVolume(.5)
  elevatorMove = la.newSource("/assets/elevatorMove.wav", "static")
  elevatorClose = la.newSource("/assets/elevatorClose.wav", "static")
  elevatorClose:setVolume(.5)
  elevatorOpen = la.newSource("/assets/elevatorOpen.wav", "static")
  elevatorOpen:setVolume(.5)
  
end


function E.update()
  
  SetTargetFloor(elevator1)
  MoveToTargetFloor(elevator1)
  UpdateTargetFloor(elevator1)
  
  SetTargetFloor(elevator2)
  MoveToTargetFloor(elevator2)
  UpdateTargetFloor(elevator2)
  
  CheckDoorTiming(elevator1)
  CheckDoorTiming(elevator2)
  
end


function E.getElevatorQueues()
  
  local elTar1, elCur1 = GetFloorsFromQueueOrTarget(elevator1)
  local elTar2, elCur2 = GetFloorsFromQueueOrTarget(elevator2)
  
  return elTar1, elTar2, elCur1, elCur2
  
end

function E.getPosition(el)
  if el == "left" then
    return elevator1.position
  elseif el == "right" then
    return elevator2.position
  end
end


--doorStates: 1 = closed, 2 = opening, 3 = open, 4 = closing
function E.getDoorStatus(i)
  local e = elevator1
  if i > 7 then 
    e = elevator2
    i = i - 7
  end
  if e.doorState == 1 then
    return 1
  elseif i == e.currentFloor then
    if e.doorState == 2 or e.doorState == 4 then
      return e.doorTiming
    elseif e.doorState == 3 then
      return 4
    end
  end
  return 1
end


function E.doorOpen(n)
  
  if n == 1 then
    selectedElevator = elevator1
  elseif n == 2 then
    selectedElevator = elevator2
  end
  
  if selectedElevator.executingCommand or selectedElevator.peopleMoving > 0 then
    return
  end
  
  if selectedElevator.doorState == 1 then
    elevatorOpen:play()
    selectedElevator.doorState = 2
  elseif selectedElevator.doorState == 3 then
    elevatorClose:play()
    selectedElevator.doorState = 4
  end
  
end


function E.moveElevator(dir, n)
  
  if n == 1 then
    selectedElevator = elevator1
  elseif n == 2 then
    selectedElevator = elevator2
  end 
  
  if selectedElevator.doorState ~= 1 or selectedElevator.executingCommand or selectedElevator.peopleMoving > 0 then
    AddToMovementQueue(dir)
    return
  end
  
  if selectedElevator.targetFloor == -100 then selectedElevator.targetFloor = selectedElevator.currentFloor end
  
  if dir == "up" and selectedElevator.position > positionHighest and selectedElevator.targetFloor < 7 and selectedElevator.targetFloor >= 1 then
    selectedElevator.targetFloor = selectedElevator.targetFloor + 1
  elseif dir == "down" and selectedElevator.position < positionLowest and selectedElevator.targetFloor > 1  then
    selectedElevator.targetFloor = selectedElevator.targetFloor - 1
  end
  
end


--mode 1 is go left, mode 2 is go right, mode 3 is swap
function E.switchElevators(mode)
  
  if mode == 1 then 
    selectedElevator = elevator1
  elseif mode == 2 then
    selectedElevator = elevator2
  elseif mode == 3 then
    if selectedElevator == elevator1 then
      selectedElevator = elevator2
    else
      selectedElevator = elevator1
    end
  end
  
end

function E.movingInOutElevator(el, dir)
  
  local delta
  if dir == "add" then
    delta = 1
  else
    delta = -1
  end
  
  if el == "left" then
    elevator1.peopleMoving = elevator1.peopleMoving + delta
  else
    elevator2.peopleMoving = elevator2.peopleMoving + delta
  end
end


function E.whichElevatorToPick(fromFloor, toFloor)
  
  if fromFloor == toFloor then
    return "neither"
  end
  
  local goingUp = fromFloor - toFloor < 0
  local elDir1 = nil
  local elDir2 = nil
  
  if elevator1.targetFloor ~= -100 then
    elDir1 = elevator1.currentFloor - elevator1.targetFloor < 0
  end
  if elevator2.targetFloor ~= -100 then
    elDir2 = elevator2.currentFloor - elevator1.targetFloor < 0
  end
  
  if elDir1 ~= nil and elDir1 == goingUp then
    return "left"
  elseif elDir2 ~= nil and elDir2 == goingUp then
    return "right"
  else
    if math.abs(fromFloor - elevator1.currentFloor) < math.abs(fromFloor - elevator2.currentFloor) then
      return "left"
    elseif math.abs(fromFloor - elevator1.currentFloor) > math.abs(fromFloor - elevator2.currentFloor) then
      return "right"
    else
      local r = love.math.random(2)
      if r == 1 then
        return "right"
      else
        return "left"
      end
    end
  end
  
end

function E.hasElevatorArrived(el, fl)
  
  if el == "left" then 
    el = elevator1 
  else 
    el = elevator2 
  end
  
  if el.currentFloor == fl and el.doorState == 3 then
    return true
  else
    return false
  end
  
end


-------USED LOCALLY ONLY -----------


function GetFloorsFromQueueOrTarget(el)
  
  if #el.moveQueue > 0 then
    if el.moveQueue[1] == "up" then
      return el.currentFloor + #el.moveQueue, el.currentFloor
    else
      return el.currentFloor - #el.moveQueue, el.currentFloor
    end
  else
    return el.targetFloor, el.currentFloor
  end

end


function AddToMovementQueue(dir)
  
  local lastMove

  if #selectedElevator.moveQueue > 0 then
    lastMove = selectedElevator.moveQueue[#selectedElevator.moveQueue]
  else 
    lastMove = ""
  end

  if lastMove == dir or lastMove == "" then
    if dir == "up" and selectedElevator.currentFloor + #selectedElevator.moveQueue <= 7 then
      table.insert(selectedElevator.moveQueue, dir)
    elseif dir == "down" and selectedElevator.currentFloor - #selectedElevator.moveQueue >= 1 then
      table.insert(selectedElevator.moveQueue, dir)
    end
  else
    table.remove(selectedElevator.moveQueue, #selectedElevator.moveQueue)
  end
  
end


function CheckDoorTiming(el)
  
  if el.doorState == 2 then
    if math.abs(doorTimingMax - el.doorTiming) < doorSpeed then
      el.doorState = 3
      elevatorArrive:play()
      el.doorTiming = doorTimingMax
    else
      el.doorTiming = el.doorTiming + doorSpeed
    end
  elseif el.doorState == 4 then
    if math.abs(doorTimingMin - el.doorTiming) < doorSpeed then
      el.doorState = 1
      el.doorTiming = doorTimingMin
    else
      el.doorTiming = el.doorTiming - doorSpeed
    end
  end
  
end

function UpdateTargetFloor(el)
  
  if el.targetFloor ~= el.currentFloor then
    if math.abs(el.position - GetFloorY(el.targetFloor) )<= 10 then
      el.currentFloor = el.targetFloor
      el.position = GetFloorY(el.currentFloor)
      el.targetFloor = -100
      el.executingCommand = false
    else
      for i=1, 7 do
        if math.abs(el.position - GetFloorY(i)) <= 10 then
          el.currentFloor = i
          
        end
      end
    end
  end
  
end


function MoveToTargetFloor(el)
  
  if el.targetFloor == -100 then return end
  
  local t = GetFloorY(el.targetFloor)
  local c = el.position
  
  if el.doorState ~= 1 then return end
  if el.targetFloor ~= el.currentFloor then
    el.executingCommand = true
    if math.abs(t-c) < elevatorSpeed then
      el.position = t
    elseif c > t then
      el.position = el.position - elevatorSpeed
    else
      el.position = el.position + elevatorSpeed
    end
  end
  
end


function SetTargetFloor(el)
  
  if el.executingCommand or el.doorState ~= 1 then
    return
  elseif #el.moveQueue > 0 then
    if el.moveQueue[1] == "up" then
      el.targetFloor = el.currentFloor + #el.moveQueue
    elseif el.moveQueue[1] == "down" then
      el.targetFloor = el.currentFloor - #el.moveQueue
    end
  end
  
  if el.targetFloor > 7 then
    el.targetFloor = 7
  elseif el.targetFloor < 1 and el.targetFloor ~= -100 then
    el.targetFloor = 1
  end
  el.moveQueue = {}
  
end


function GetFloorY(f)
  
  return positionLowest - ((f-1)*increment)
  
end

return E
