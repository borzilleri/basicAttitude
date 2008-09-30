local UPDATE_PERIOD = 0.5
local elapsed = 0.5
local string_format = string.format
local pitchMax = 1.55334

local function ColorGradient(perc, r1, g1, b1, r2, g2, b2, r3, g3, b3)
	if perc >= 1 then return r3, g3, b3 elseif perc <= 0 then return r1, g1, b1 end

	local segment, relperc = math_modf(perc*2)
	if segment == 1 then r1, g1, b1, r2, g2, b2 = r2, g2, b2, r3, g3, b3 end
	return r1 + (r2-r1)*relperc, g1 + (g2-g1)*relperc, b1 + (b2-b1)*relperc
end


local function round(num, places)
  local mult = 10^(places or 0)
  return math.floor(num * mult + 0.5) / mult
end

local f = CreateFrame("frame")
local dataobj = LibStub:GetLibrary("LibDataBroker-1.1"):NewDataObject("basicAttitude", {text = "+0"})

f:SetScript("OnUpdate", function(self, elap)
	elapsed = elapsed + elap
	if elapsed < UPDATE_PERIOD then return end

	elapsed = 0
	local pitch = round(GetUnitPitch("player"),5)
	local attitude = pitch/pitchMax * 90
	
	--local r, g, b = ColorGradient(fps/1.5, 1,0,0, 1,1,0, 0,1,0)
	local r = 1; local g = 1; local b = 1;

	dataobj.text = string_format("|cff%02x%02x%02x%.5f|r°", r*255, g*255, b*255, attitude)
end)
