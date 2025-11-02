-- LocalScript inside StarterPlayerScripts

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local camera = workspace.CurrentCamera
camera.CameraType = Enum.CameraType.Scriptable

-- starting position
local camPos = Vector3.new(0, 10, 0)
local camRotX, camRotY = 0, 0
local moveVec = Vector3.zero
local speed = 0.3

-- simple custom joystick values
local moveInput = Vector2.zero

-- move with on-screen joystick area (bottom-left)
UserInputService.TouchMoved:Connect(function(touch, processed)
	if touch.Position.X < workspace.CurrentCamera.ViewportSize.X * 0.4 then
		local center = Vector2.new(workspace.CurrentCamera.ViewportSize.X * 0.2,
			workspace.CurrentCamera.ViewportSize.Y * 0.8)
		moveInput = (touch.Position - center)/100
	end
end)

UserInputService.TouchEnded:Connect(function()
	moveInput = Vector2.zero
end)

-- swipe to look
local lastPos
UserInputService.TouchMoved:Connect(function(touch, processed)
	if touch.Position.X > workspace.CurrentCamera.ViewportSize.X * 0.4 then
		if lastPos then
			local delta = touch.Position - lastPos
			camRotY -= delta.X * 0.003
			camRotX = math.clamp(camRotX - delta.Y * 0.003, -math.pi/2, math.pi/2)
		end
		lastPos = touch.Position
	end
end)

UserInputService.TouchEnded:Connect(function(t)
	lastPos = nil
end)

-- update camera
RunService.RenderStepped:Connect(function()
	local lookVector = CFrame.fromOrientation(camRotX, camRotY, 0).LookVector
	local rightVector = CFrame.fromOrientation(0, camRotY, 0).RightVector
	local moveDir = (rightVector * moveInput.X + lookVector * moveInput.Y) * speed
	camPos += moveDir
	camera.CFrame = CFrame.new(camPos, camPos + lookVector)
end)
