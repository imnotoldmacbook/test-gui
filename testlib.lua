--  MyOwnHackLib.lua  (LocalScript, StarterPlayerScripts)
local Players = game:GetService("Players")
local Tween   = game:GetService("TweenService")
local UIS     = game:GetService("UserInputService")
local player  = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

--------------------------------------------------------------------
-- 1.  ScreenGui container
--------------------------------------------------------------------
local gui = Instance.new("ScreenGui")
gui.Name = "MyHackLib"
gui.Parent = playerGui

--------------------------------------------------------------------
-- 2.  Main frame
--------------------------------------------------------------------
local frame = Instance.new("Frame")
frame.Size = UDim2.fromOffset(250, 150)
frame.Position = UDim2.fromScale(0.5, 0.5)
frame.AnchorPoint = Vector2.new(0.5, 0.5)
frame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
frame.BorderSizePixel = 0
frame.Visible = false
frame.Parent = gui

-- top bar
local top = Instance.new("Frame")
top.Size = UDim2.new(1, 0, 0, 30)
top.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
top.BorderSizePixel = 0
top.Parent = frame

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -30, 1, 0)
title.Text = "My Hack Lib  –  RightControl to toggle"
title.Font = Enum.Font.SourceSansBold
title.TextColor3 = Color3.new(1, 1, 1)
title.BackgroundTransparency = 1
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = top

local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.fromOffset(20, 20)
closeBtn.Position = UDim2.new(1, -22, 0, 5)
closeBtn.Text = "X"
closeBtn.Font = Enum.Font.SourceSansBold
closeBtn.TextColor3 = Color3.new(1, 0, 0)
closeBtn.BackgroundColor3 = Color3.fromRGB(200, 30, 30)
closeBtn.BorderSizePixel = 0
closeBtn.Parent = top
closeBtn.MouseButton1Click:Connect(function() frame.Visible = false end)

-- content holder
local content = Instance.new("Frame")
content.Size = UDim2.new(1, 0, 1, -30)
content.Position = UDim2.fromScale(0, 1)
content.AnchorPoint = Vector2.new(0, 1)
content.BackgroundTransparency = 1
content.Parent = frame

--------------------------------------------------------------------
-- 3.  DRAGGING  (top bar)
--------------------------------------------------------------------
local dragging = false
local dragInput, mousePos, framePos

top.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        mousePos = input.Position
        framePos = frame.Position
    end
end)

top.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement then
        dragInput = input
    end
end)

gui.InputChanged:Connect(function(input)
    if dragging and input == dragInput then
        local delta = input.Position - mousePos
        frame.Position = UDim2.new(
            framePos.X.Scale,
            framePos.X.Offset + delta.X,
            framePos.Y.Scale,
            framePos.Y.Offset + delta.Y
        )
    end
end)

game:GetService("UserInputService").InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = false
    end
end)

--------------------------------------------------------------------
-- 4.  QUICK TOGGLE  (example)
--------------------------------------------------------------------
local function quickToggle(parent, text, onCallback, offCallback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -10, 0, 30)
    btn.Position = UDim2.new(0, 5, 0, 5)
    btn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    btn.Text = text .. "  [OFF]"
    btn.Font = Enum.Font.SourceSans
    btn.TextColor3 = Color3.new(1, 1, 1)
    btn.BorderSizePixel = 0
    btn.Parent = parent

    local on = false
    btn.MouseButton1Click:Connect(function()
        on = not on
        btn.BackgroundColor3 = on and Color3.fromRGB(0, 170, 255) or Color3.fromRGB(40, 40, 40)
        btn.Text = text .. (on and "  [ON]" or "  [OFF]")
        if on then
            if onCallback then onCallback() end
        else
            if offCallback then offCallback() end
        end
    end)
    return btn
end

-- example: infinite jump
quickToggle(content, "Infinite Jump",
    function() _G.infJump = true end,
    function() _G.infJump = false end
)

-- example: walk-speed slider
local speedSlider = Instance.new("Slider")
speedSlider.Size = UDim2.new(1, -10, 0, 25)
speedSlider.Position = UDim2.new(0, 5, 0, 45)
speedSlider.Parent = content
-- (you would build your own slider here, or copy the Rayfield slider code)

--------------------------------------------------------------------
-- 5.  SHOW / HIDE  (RightControl)
--------------------------------------------------------------------
local function show()
    frame.Visible = true
    Tween:Create(frame, TweenInfo.new(0.3, Enum.EasingStyle.Back), { Size = UDim2.fromOffset(250, 150) }):Play()
end

local function hide()
    Tween:Create(frame, TweenInfo.new(0.2, Enum.EasingStyle.Quad), { Size = UDim2.fromOffset(0, 0) }):Completed:Wait()
    frame.Visible = false
end

game:GetService("UserInputService").InputBegan:Connect(function(input, gp)
    if gp then return end
    if input.KeyCode == Enum.KeyCode.RightControl then
        if frame.Visible then hide() else show() end
    end
end)

--------------------------------------------------------------------
-- 6.  CLEANUP  (optional)
--------------------------------------------------------------------
LocalPlayer.CharacterAdded:Connect(function()
    -- re-attach orb, re-create movers, etc.
end)
