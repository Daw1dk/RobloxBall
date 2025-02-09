local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Camera = workspace.CurrentCamera

local SPEED_MULTIPLIER = 50
local JUMP_POWER = 100
local JUMP_GAP = 0.6
local ACCELERATION = 1
local DECELERATION = 2

local character = game.Players.LocalPlayer.Character
local humanoid = character:WaitForChild("Humanoid")

for _, v in ipairs(character:GetDescendants()) do
	if v:IsA("BasePart") then
		v.CanCollide = false
	end
end

local ball = character.HumanoidRootPart
ball.Shape = Enum.PartType.Ball
ball.Size = Vector3.new(5, 5, 5)
ball.Material = Enum.Material.Fabric
ball.BrickColor = BrickColor.new("Lime green")

ball.CustomPhysicalProperties = PhysicalProperties.new(
	0.5,
	1.5,  
	0.8,  
	0,  
	0
)

local params = RaycastParams.new()
params.FilterType = Enum.RaycastFilterType.Blacklist
params.FilterDescendantsInstances = {character}

local spinningSpeed = 1
local velocityTarget = Vector3.new(0, 0, 0)

local function isMoving()
	return UserInputService:IsKeyDown(Enum.KeyCode.W) or 
		UserInputService:IsKeyDown(Enum.KeyCode.A) or 
		UserInputService:IsKeyDown(Enum.KeyCode.S) or 
		UserInputService:IsKeyDown(Enum.KeyCode.D)
end

local tc = RunService.RenderStepped:Connect(function(delta)
	ball.CanCollide = true
	humanoid.PlatformStand = true
	if UserInputService:GetFocusedTextBox() then return end

	local moveDirection = Vector3.new(0, 0, 0)

	if UserInputService:IsKeyDown(Enum.KeyCode.W) then
		moveDirection -= Camera.CFrame.RightVector
	end
	if UserInputService:IsKeyDown(Enum.KeyCode.A) then
		moveDirection -= Camera.CFrame.LookVector
	end
	if UserInputService:IsKeyDown(Enum.KeyCode.S) then
		moveDirection += Camera.CFrame.RightVector
	end
	if UserInputService:IsKeyDown(Enum.KeyCode.D) then
		moveDirection += Camera.CFrame.LookVector
	end

	if moveDirection.Magnitude > 0 then
		moveDirection = moveDirection.Unit * SPEED_MULTIPLIER
		velocityTarget = velocityTarget:Lerp(moveDirection, delta * ACCELERATION)
	else
		velocityTarget = velocityTarget:Lerp(Vector3.new(0, ball.RotVelocity.Y, 0), delta * DECELERATION)
	end

	ball.RotVelocity = velocityTarget

	if velocityTarget.Magnitude < 10 then
		ball.RotVelocity = Vector3.new(0, spinningSpeed, 0)
	end
end)

UserInputService.JumpRequest:Connect(function()
	local result = workspace:Raycast(
		ball.Position,
		Vector3.new(0, -((ball.Size.Y / 2) + JUMP_GAP), 0),
		params
	)
	if result then
		ball.Velocity = ball.Velocity + Vector3.new(0, JUMP_POWER * math.random(1, 2), 0)
	end
end)

Camera.CameraSubject = ball
humanoid.Died:Connect(function() tc:Disconnect() end)
