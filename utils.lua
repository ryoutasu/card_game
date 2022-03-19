function math.clamp(value, min, max)
    return math.max(min, math.min(max, value))
end

function math.lerp(v0, v1, t)
    return (1 - t) * v0 + t * v1;
end

function IsPointInsideRect(rect, point)
    local x = point[1] or point.x
    local y = point[2] or point.y
    return (x >= rect[1] and x <= rect[3])
        and (y >= rect[2] and y <= rect[4])
end

function CenterOf(object)
    local x, y = object.pos:unpack()
    local w, h = object.width, object.height

    return Vector(x+w/2, y+h/2)
end