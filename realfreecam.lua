local Players = game:GetService("Players")
local StarterGui = game:GetService("StarterGui")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local camera = workspace.CurrentCamera

local flying = false
local rotation = Vector2.new()
local moveVector = Vector3.new()
local speed = 1.8

-- disable all Roblox core UIs
StarterGui:SetCore("TopbarEnabled", false)
StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.All, false)
StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.PlayerList, false)
StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Chat, false)
StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.EmotesMenu, false)
StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Backpack, false)

-- disable any game-made GUI (like Adopt Me’s shop, buttons, etc.)
local function hideAllGuis(state)
	for _, gui in pairs(player:WaitForChild("PlayerGui"):GetChildren()) do
		if gui:IsA("ScreenGui") then
			gui.Enabled = state
		end
	end
end

-- make Freecam GUI
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "FreecamUI"
screenGui.ResetOnSpawn = false
screenGui.IgnoreGuiInset = true
screenGui.Parent = player:WaitForChild("PlayerGui")

local toggleBtn = Instance.new("TextButton")
toggleBtn.Size = UDim2.new(0, 140, 0, 50)
toggleBtn.Position = UDim2.new(0.03, 0, 0.85, 0)
toggleBtn.Text = "Freecam: OFF"
toggleBtn.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
toggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
toggleBtn.Font = Enum.Font.SourceSansBold
toggleBtn.TextSize = 20
toggleBtn.AutoButtonColor = true
toggleBtn.Parent = screenGui

-- toggle freecam
toggleBtn.MouseButton1Click:Connect(function()
	flying = not flying
	if flying then
		camera.CameraType = Enum.CameraType.Scriptable
		toggleBtn.Text = "Freecam: ON"
		hideAllGuis(false) -- hides all other UI
		screenGui.Enabled = true -- keep only this button
		UserInputService.ModalEnabled = true

		-- freeze character
		local char = player.Character or player.CharacterAdded:Wait()
		local hum = char:FindFirstChildOfClass("Humanoid")
		if hum then
			hum.WalkSpeed = 0
			hum.JumpPower = 0
		end
	else
		camera.CameraType = Enum.CameraType.Custom
		toggleBtn.Text = "Freecam: OFF"
		hideAllGuis(true) -- show game UIs again
		UserInputService.ModalEnabled = false
	end
end)

-- swipe to rotate
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
	moveVector = Vector3.new()
end)

-- simulate movement with drag
UserInputService.InputChanged:Connect(function(input)
	if flying and input.UserInputType == Enum.UserInputType.Touch and input.Delta then
		local delta = input.Delta
		moveVector = Vector3.new(delta.X / 100, 0, -delta.Y / 100)
	end
end)

-- update camera
RunService.RenderStepped:Connect(function(dt)
	if flying then
		local cf = CFrame.new(camera.CFrame.Position) *
		           CFrame.Angles(math.rad(rotation.X), math.rad(rotation.Y), 0)
		camera.CFrame = cf + (cf.LookVector * moveVector.Z + cf.RightVector * moveVector.X) * speed * dt * 60
	end
end)
