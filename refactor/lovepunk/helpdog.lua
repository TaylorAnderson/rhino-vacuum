---
-- Clamps a value to a certain range.
-- @param min - The minimum value.
-- @param val - The value to clamp.
-- @param max - The maximum value.
function helpdog.clamp(min, val, max)
    return math.max(min, math.min(val, max));
end

function helpdog.randomRange(minNum, maxNum)
	return (Math.floor(Math.random() * (maxNum - minNum + 1)) + minNum);
end

--Find vector from arg1 to arg2.  if revrse is true, it finds the vector pointing away from arg1.

function helpdog.findVector(from, to, power, reverse)
	v = {x=to.x - from.x, y=to.y - from.y}
	v.normalize(power);
	math.normalize(v.x, v.y)
	if (reverse) then
		v.x = v.x * -1
		v.y = v.y * -1
	end
	return v;
end

function helpdog.toRadians(degrees)
	r = degrees * (math.pi / 180);
	return r;
end

function helpdog.toDegrees(radians)
	d = radians * (180/math.pi);
	return r;
end

function helpdog.snapToGrid(num, gridsize, useFloor)
	if not useFloor then
		return math.round(num / gridsize) * gridsize;
	else return math.floor(num / gridsize) * gridsize
	end
end

function helpdog.angleToPoint(radians)
	return {x=math.cos(radians), y=math.sin(radians)};
end

function helpdog.angleXY(object, angle, length, x, y)
	length = length or 1
	x = x or 0
	y = y or 0
	RAD = math.pi / -180;
	angle = angle * RAD;
	object.x = math.cos(angle) * length + x;
	object.y = math.sin(angle) * length + y;
end

function helpdog.angleXYToPoint(object, angle, length, x, y)
	local length = length or 1
	local x = x or 0
	local y = y or 0
	RAD = math.pi / -180;
	angle = angle * RAD;
	p = {x=math.sin(angle) * length + x, y=math.cos(angle) * length + y}
	return p;
end

--returns true if val1 is close to val2, within the margin of error.
function helpdog.isCloseTo(val1, val2, marginOfError)
	if (val1 < val2 + marginOfError and val1 > val2 - marginOfError) then return true end
	return false;
end

function helpdog.isBetween(pointA, pointB, betweenPoint, error)
 	crossproduct = (betweenPoint.y - pointA.y) * (pointB.x - pointA.x) - (betweenPoint.x - pointA.x) * (pointB.y - pointA.y);
	if (math.abs(crossproduct) > error) then return false end;

 	dotproduct = (betweenPoint.x - pointA.x) * (pointB.x - pointA.x) + (betweenPoint.y - pointA.y) * (pointB.y - pointA.y);
	if (dotproduct < 0) then return false end

	squaredlengthba = (pointB.x - pointA.x) * (pointB.x - pointA.x) + (pointB.y - pointA.y) * (pointB.y - pointA.y);
	if (dotproduct > squaredlengthba) then return false end;

	return true;
end
function helpdog.map(x, fromMin, fromMax, toMin, toMax)
	return toMin + ((x - fromMin) / (fromMax - fromMin)) * (toMax - toMin);
end
