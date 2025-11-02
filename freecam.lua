local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local camera = workspace.CurrentCamera
local flying = false
local speed = 1.5
local rotation = Vector2.new()

-- // GUI setup
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "FreecamGui"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = player:WaitForChild("PlayerGui")

local ToggleButton = Instance.new("TextButton")
ToggleButton.Size = UDim2.new(0, 120, 0, 50)
ToggleButton.Position = UDim2.new(0.02, 0, 0.85, 0)
ToggleButton.Text = "Freecam: OFF"
ToggleButton.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
ToggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleButton.Font = Enum.Font.SourceSansBold
ToggleButton.TextSize = 18
ToggleButton.Parent = ScreenGui

-- // Virtual joystick for movement
local moveVector = Vector3.new()
local thumbstick = Instance.new("ImageButton")
thumbstick.Size = UDim2.new(0, 80, 0, 80)
thumbstick.Position = UDim2.new(0.1, 0, 0.7, 0)
thumbstick.Image = "rbxassetid://4695575676"
thumbstick.BackgroundTransparency = 1
thumbstick.Visible = false
thumbstick.Parent = ScreenGui

local stickCenter = thumbstick.AbsolutePosition + thumbstick.AbsoluteSize / 2

thumbstick.InputChanged:Connect(function(input)
	if flying and input.UserInputType == Enum.UserInputType.Touch then
		local delta = (input.Position - stickCenter) / 40
		moveVector = Vector3.new(delta.X, 0, -delta.Y)
	end
end)

UserInputService.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.Touch then
		moveVector = Vector3.new()
	end
end)

-- // Swipe to rotate
local touching = false
local lastPos

UserInputService.TouchStarted:Connect(function(input)
	if flying then
		touching = true
		lastPos = input.Position
	end
end)

UserInputService.TouchMoved:Connect(function(input)
	if flying and touching then
		local delta = input.Position - lastPos
		lastPos = input.Position
		rotation = rotation + Vector2.new(-delta.Y, -delta.X) * 0.2
	end
end)

UserInputService.TouchEnded:Connect(function()
	touching = false
end)

-- // Update camera position
RunService.RenderStepped:Connect(function(dt)
	if flying then
		local move = moveVector
		local cf = CFrame.new(camera.CFrame.Position) * 
		           CFrame.Angles(math.rad(rotation.X), math.rad(rotation.Y), 0)
		camera.CFrame = cf + (cf.LookVector * move.Z + cf.RightVector * move.X) * speed * dt * 60
	end
end)

-- // Toggle button behavior
ToggleButton.MouseButton1Click:Connect(function()
	flying = not flying
	if flying then
		camera.CameraType = Enum.CameraType.Scriptable
		ToggleButton.Text = "Freecam: ON"
		thumbstick.Visible = true
	else
		camera.CameraType = Enum.CameraType.Custom
		ToggleButton.Text = "Freecam: OFF"
		thumbstick.Visible = false
	end
end)
