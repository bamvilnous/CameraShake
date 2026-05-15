--!strict

-- @bamvilnous
-- lightweight single-script port of sleitnick's port of EZ Camera Shake
-- port of a port (port^2)
-- free for use in any project under MIT license

local RunService = game:GetService("RunService")

local Camera = workspace.CurrentCamera :: Camera

-- Typing

export type CameraShakeParams = {
	Magnitude: number,
	Roughness: number,
	PositionalInfluence: Vector3,
	RotationalInfluence: Vector3,
	
	[string]: never
}

-- Module

local CameraShake = {}
CameraShake.Params = {} :: CameraShakeParams
CameraShake.Connection = nil :: RBXScriptConnection?
CameraShake.Tick = Random.new():NextNumber(-100, 100)
CameraShake.Shaking = false
CameraShake.Timer = 0
CameraShake.ExpireTime = nil :: number?

-- Internal functions

function _stopShake()
	if CameraShake.Connection then
		CameraShake.Connection:Disconnect()
		CameraShake.Connection = nil
		CameraShake.Tick = Random.new():NextNumber(-100, 100)
		CameraShake.Timer = 0
		CameraShake.ExpireTime = nil
		CameraShake.Shaking = false
	end
end

function _update(dt: number)
	local Offset = Vector3.new(
		math.noise(CameraShake.Tick, 0) * 0.5,
		math.noise(0, CameraShake.Tick) * 0.5,
		math.noise(CameraShake.Tick, CameraShake.Tick) * 0.5
	)

	CameraShake.Tick += (dt * CameraShake.Params.Roughness)

	local Shake = Offset * CameraShake.Params.Magnitude

	local PositionAdd = CameraShake.Params.PositionalInfluence * Shake
	local RotationAdd = CameraShake.Params.RotationalInfluence * Shake

	local CFrameOffset = CFrame.new(PositionAdd) * CFrame.Angles(
		0, math.rad(RotationAdd.Y), 0
	) * CFrame.Angles(math.rad(RotationAdd.X), math.rad(RotationAdd.Z), 0)
	
	Camera.CFrame *= CFrameOffset
	
	CameraShake.Timer += dt
	if CameraShake.Timer > (CameraShake.ExpireTime or math.huge) then
		_stopShake()
	end
end

function _startShake()
	if CameraShake.Shaking then return end
	
	CameraShake.Shaking = true
	CameraShake.Connection = RunService.RenderStepped:Connect(_update)
end

-- Shake interface

function CameraShake:Impulse(Length: number)
	CameraShake.ExpireTime = Length
	return _startShake()
end

function CameraShake:StartSustain()
	return _startShake()
end

function CameraShake:StopSustain()
	return _stopShake()
end

function CameraShake:IsShaking(): boolean
	return CameraShake.Shaking
end

-- Parameters

function CameraShake:SetParams(NewParams: CameraShakeParams)
	for Property, Value in NewParams do
		CameraShake.Params[Property] = Value
	end
end

function CameraShake:GetParams()
	return CameraShake.Params
end

-- Default params

CameraShake:SetParams({
	Magnitude = 0.6,
	Roughness = 4,
	
	PositionalInfluence = Vector3.new(0.15, 0.15, 0.15),
	RotationalInfluence = Vector3.new(1, 1, 1)
})

return CameraShake
