--- Heyyoo!! This was made by RiseBit, if there is Any issue feel free to contact me on Discord : risebit ( With Star PFP )


---- IMPORTANT!! Read this : To use this Templates it is fairly Easy, You just need to Require it and Call the :Shake Function,
--- And fills the parameters, Dont Forget to Choose the Right Type of Shakes.


local CAM = {}
local RunService = game:GetService("RunService")
local Noise = math.noise



local shakeState = {
	active = false,
	type = nil,
	startTime = 0,
	duration = 0,
	amplitude = 0,
	frequency = 0,
	smoothness = 0,
	fadeType = "Sustain", -- "FadeIn", "FadeOut", "Sustain"
	connection = nil,
}

--- Annotations
export type ShakeType = "Perlin" | "Rumble" | "Explosion" | "Trauma" | "Custom"

-- Initialize the update loop
local function initUpdateLoop(cam)
	
	shakeState.connection = RunService.RenderStepped:Connect(function()
		if shakeState.active then
			CAM:UpdateCam(cam)
		end
	end)
end


--- Shake Function
---@param cam Camera
---@param amplitude number
---@param frequency number
---@param smoothness number
---@param duration number
---@param fadeType string
---@param shakeType string
function CAM:Shake(cam, amplitude, frequency, smoothness, duration, fadeType, shakeType: ShakeType)
	if not CAM:ValueChecking(amplitude, frequency, smoothness, duration) then
		return
	end


	shakeState.active = true
	shakeState.type = shakeType
	shakeState.startTime = tick()
	shakeState.duration = duration
	shakeState.amplitude = amplitude
	shakeState.frequency = frequency
	shakeState.smoothness = smoothness
	shakeState.fadeType = fadeType


	initUpdateLoop(cam)

	return shakeState.connection
end

function CAM:StartFadeOut(duration)

	shakeState.fadeType = "FadeOut"
	shakeState.startTime = tick()
	shakeState.duration = duration
end

function CAM:StartFadeIn(duration)

	shakeState.fadeType = "FadeIn"
	shakeState.startTime = tick()
	shakeState.duration = duration
end

function CAM:ResetState()
	--- For Future Updates
	if shakeState.connection then
		shakeState.connection:Disconnect()
		shakeState.connection = nil
	end

	-- Reset all state values
	shakeState.active = false
	shakeState.type = nil
	shakeState.startTime = 0
	shakeState.duration = 0
	shakeState.amplitude = 0
	shakeState.frequency = 0
	shakeState.smoothness = 0
	shakeState.fadeType = "Sustain"
	shakeState.dragDirection = Vector2.new(0, 0)

	shakeState.lastCameraPosition = nil
	shakeState.lastCameraOrientation = nil
end

function CAM:ValueChecking(amplitude, frequency, smoothness, duration)
	if typeof(amplitude) ~= "number" then
		return false
	end

	if typeof(frequency) ~= "number" then
		return false
	end

	if typeof(smoothness) ~= "number" then
		return false
	end

	if typeof(duration) ~= "number" then
		return false
	end


	return true
end

function CAM:UpdateCam(cam)
	assert(cam:IsA("Camera"), "Camera is not a valid camera")

	if not shakeState.active then
		return cam
	end
	
	local elapsed = tick() - shakeState.startTime
	local finishTime = .5

	
	if elapsed > shakeState.duration + finishTime  then
		shakeState.active = false

		if shakeState.connection then
			shakeState.connection:Disconnect()
			shakeState.connection = nil
		end

		return cam
	end

	-- Calculate intensity based on fadeType
	local intensity = 1
	if shakeState.fadeType == "FadeIn" then
		intensity = elapsed / shakeState.duration -- 0 to 1
	elseif shakeState.fadeType == "FadeOut" then
		intensity = 1 - (elapsed / shakeState.duration) -- 1 to 0
	end

	
	local offset = Vector2.new(0, 0)

	if shakeState.type == "Perlin" then
		local randomNumber = math.random(1,10)/100
		offset = Vector2.new(
			Noise(randomNumber * shakeState.frequency / shakeState.smoothness) * shakeState.amplitude,
			Noise(randomNumber * shakeState.frequency / shakeState.smoothness) * shakeState.amplitude
		)
	elseif shakeState.type == "Explosion" then

		local decayFactor = math.exp(-elapsed * shakeState.frequency)
		local randomAngle = math.random() * math.pi * 2
		offset = Vector2.new(
			math.cos(randomAngle) * shakeState.amplitude * decayFactor,
			math.sin(randomAngle) * shakeState.amplitude * decayFactor
		)
	elseif shakeState.type == "Rumble" then

		offset = Vector2.new(
			math.sin(elapsed * shakeState.frequency) * shakeState.amplitude,
			math.cos(elapsed * shakeState.frequency * 1.3) * shakeState.amplitude
		)
	elseif shakeState.type == "Trauma" then
		local traumaIntensity = intensity * intensity
		local randomNumber = math.random(1,10)/100
		offset = Vector2.new(
			Noise(randomNumber * shakeState.frequency / shakeState.smoothness) * shakeState.amplitude * traumaIntensity,
			Noise(randomNumber * shakeState.frequency / shakeState.smoothness) * shakeState.amplitude * traumaIntensity
		)
	end

	offset = offset * intensity
	local finalMultiplier = 1

	if elapsed > shakeState.duration then
		local fadeOutTime = elapsed - shakeState.duration
		local fadeOutProgress = math.min(fadeOutTime / finishTime, 1)
		finalMultiplier = (1 - fadeOutProgress) ^ 2
		
		
		cam.CFrame = cam.CFrame * CFrame.new(offset.X * finalMultiplier, offset.Y * finalMultiplier, 0)
	else
		cam.CFrame = cam.CFrame * CFrame.new(offset.X, offset.Y, 0)
	end

	return cam
end



return CAM
