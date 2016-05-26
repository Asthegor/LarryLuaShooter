-- Returns the angle between two points.
function math.angle(x1,y1, x2,y2) return math.atan2(y2-y1, x2-x1) end

function Collide(a1, a2)
 if (a1 == a2) then return false end
 local dx = a1.x - a2.x
 local dy = a1.y - a2.y
 if (math.abs(dx) < a1.image:getWidth()/2 + a2.image:getWidth()/2) then
  if (math.abs(dy) < a1.image:getHeight()/2 + a2.image:getHeight()/2) then
   return true
  end
 end
 return false
end

function RadianToDegree(pRadian)
  return 180 * (pRadian) / math.pi
end

function DegreeToRadian(pDegree)
  return math.pi * (pDegree) / 180
end
