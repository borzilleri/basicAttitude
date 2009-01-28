local UPDATE_PERIOD = 0.5
local elapsed = 0.5

local string_format = string.format
local math_floor = math.floor
local math_abs = math.abs

local PITCH_ZENITH = 1.55334
local PITCH_MAX = 3.10668
local DEGREE_MAX = 180
local DEGREE_ZENITH = 90

local function round(num, places)
  local mult = 10^(places or 0)
  return math_floor(num * mult + 0.5) / mult
end

local f = CreateFrame("frame")
local dataobj = LibStub:GetLibrary("LibDataBroker-1.1"):NewDataObject('basicAttitude', {type='data source', text='+0', label='basicAttitude'})

f:SetScript("OnUpdate", function(self, elap)
	elapsed = elapsed + elap
	if elapsed < UPDATE_PERIOD then return end
	elapsed = 0
	
	local pitch = UnitInVehicle("player") == 1 and round(GetUnitPitch("playerpet"),5) or round(GetUnitPitch("player"),5)
	
	-- If the user pitches up far enough, they'll "roll over" to what is 
	-- effectively a pitch-down attitude, but the pitch numbers returned by 
	-- GetUnitPitch will remain positive, until they swing around past 360 degrees.
	--
	-- The same applies to pitching down, but the opposite, obviously.
	-- 
	-- This should correct the value returned by GetUnitPitch to return a value
	-- that does not exceed 180 degrees in either direction.
	-- After this, any negative value should be a pitch-down attitude, while any
	-- positive value should be a pitch-up attitude.
	if( pitch > PITCH_MAX ) then        -- Pitch > 180 degrees positive
		pitch = pitch - 2*PITCH_MAX
	elseif( -1*pitch > PITCH_MAX ) then -- Pitch > 180 degrees negative
		pitch = pitch + 2*PITCH_MAX
	end
	
	-- The absolute value of our pitch. Do this once here, so later on we're
	-- not calling math_abs a bunch.
	local pitch_abs = math_abs(pitch)
	
	-- This is the pitch in degrees. It should be a decimal between -180 and 180.
	-- The numbers ought to be fairly self explanitory.
	local attitude = (pitch/PITCH_MAX) * DEGREE_MAX
	
	-- This should be a decimal value between 0 and 1
	-- It represents the fraction of zenith our pitch is (either positive or negative).
	-- 0 represents horizontal flight
	-- 1 represents vertical flight (up or down)
	local fractionOfZenith = (pitch_abs > PITCH_ZENITH) and ((PITCH_MAX-pitch_abs)/PITCH_ZENITH) or (pitch_abs/PITCH_ZENITH)
	
	-- Initialize our RGB values.
	local r,g,b = 1,1,1
	
	if( pitch > 0 and pitch < PITCH_MAX ) then -- Pitch-UP, use Green text.
		-- Pitch-UP, use Green Text. Only modify R and B values.
		if( fractionOfZenith < .2 ) then
			r = .8
			b = .8
		else
			r = 1-fractionOfZenith
			b = 1-fractionOfZenith
		end		
	elseif( pitch < 0 and pitch_abs < PITCH_MAX) then
		-- Pitch-DOWN use Red Text. Only modify G and B values.
		if( fractionOfZenith < .2) then
			g = .8
			b = .8
		else
			g = 1-(fractionOfZenith)
			b = 1-(fractionOfZenith)
		end
	end
	
	dataobj.text = string_format("|cff%02x%02x%02x%.5f|r°", r*255, g*255, b*255, attitude)
end)
