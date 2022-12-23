U = {}

function U.updateScaleFactor()

  local wh, _ = love.graphics.getDimensions()
  if wh < 900 then
    return 0.5
  elseif wh < 1200 then
    return 0.75
  else
    return 1
  end

end

return U