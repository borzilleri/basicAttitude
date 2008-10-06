local UPDATE_PERIOD = 0.5
local elapsed = 0.5
local string_format = string.format
local pitchMax = 1.55334

local function round(num, places)
  local mult = 10^(places or 0)
  return math.floor(num * mult + 0.5) / mult
end

local f = CreateFrame("frame")
local dataobj = LibStub:GetLibrary("LibDataBroker-1.1"):NewDataObject('basicAttitude', {text='+0', label='basicAttitude'})

f:SetScript("OnUpdate", function(self, elap)
	elapsed = elapsed + elap
	if elapsed < UPDATE_PERIOD then return end

	elapsed = 0
	local pitch = round(GetUnitPitch("player"),5)
	local fraction = pitch/pitchMax
	local attitude = fraction * 90
	
	local r = 1; local g = 1; local b = 1;
		
	if( attitude > 0 ) then
		if( fraction < .50 ) then
			r = .50
			b = .50
		else
			r = 1-fraction
			b = 1-fraction
		end
	elseif( attitude < 0 ) then
		if( fraction > -.50 ) then
			g = .50
			b = .50
		else
			g = 1-(fraction*-1)
			b = 1-(fraction*-1)
		end
	end
	
	dataobj.text = string_format("|cff%02x%02x%02x%.5f|r°", r*255, g*255, b*255, attitude)
end)
