# CameraShake
simpler, single-script implentation of a camera shake module based on sleitnick's port of EZ Camera Shake.

```luau
local CameraShake = require('@self/CameraShake`)

CameraShake:SetParameters(
  Magnitude = 0.6,
	Roughness = 4,
	
	PositionalInfluence = Vector3.new(0.15, 0.15, 0.15),
	RotationalInfluence = Vector3.new(1, 1, 1)
)
CameraShake:Impulse(5)

repeat task.wait() until not CameraShake:IsShaking()

CameraShake:StartSustain()
task.wait(5)
CameraShake:StopSustain()

```
