-- StylishLib.lua
-- Rayfield-inspired UI library (clean & extensible)

local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")

local Player = Players.LocalPlayer

--------------------------------------------------
-- LIB TABLE
--------------------------------------------------
local Lib = {}
Lib.Theme = {
    Background = Color3.fromRGB(18,18,18),
    Topbar     = Color3.fromRGB(30,30,30),
    Accent     = Color3.fromRGB(200, 50, 50),
    Text       = Color3.fromRGB(235,235,235),
    SubText    = Color3.fromRGB(170,170,170),
}

--------------------------------------------------
-- UTILS
--------------------------------------------------
local function round(obj, r)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, r)
    c.Parent = obj
end

local function tween(obj, props, time)
    TweenService:Create(
        obj,
        TweenInfo.new(time or 0.25, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
        props
    ):Play()
end

--------------------------------------------------
-- WINDOW
--------------------------------------------------
function Lib:CreateWindow(cfg)
    cfg = cfg or {}

    local gui = Instance.new("ScreenGui")
    gui.Name = "StylishLib"
    gui.ResetOnSpawn = false
    gui.Parent = CoreGui

    local main = Instance.new("Frame")
    main.Size = UDim2.fromOffset(520, 420)
    main.Position = UDim2.fromScale(0.5, 0.5)
    main.AnchorPoint = Vector2.new(0.5,0.5)
    main.BackgroundColor3 = self.Theme.Background
    main.Parent = gui
    round(main, 12)

    local top = Instance.new("Frame")
    top.Size = UDim2.new(1,0,0,44)
    top.BackgroundColor3 = self.Theme.Topbar
    top.Parent = main
    round(top, 12)

    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1,-20,1,0)
    title.Position = UDim2.fromOffset(10,0)
    title.Text = cfg.Name or "Stylish UI"
    title.Font = Enum.Font.GothamBold
    title.TextSize = 16
    title.TextColor3 = self.Theme.Text
    title.BackgroundTransparency = 1
    title.TextXAlignment = Left
    title.Parent = top

    -- drag
    do
        local dragging, startPos, startInput
        top.InputBegan:Connect(function(i)
            if i.UserInputType == Enum.UserInputType.MouseButton1 then
                dragging = true
                startInput = i.Position
                startPos = main.Position
            end
        end)
        UIS.InputChanged:Connect(function(i)
            if dragging and i.UserInputType == Enum.UserInputType.MouseMovement then
                local delta = i.Position - startInput
                main.Position = UDim2.new(
                    startPos.X.Scale, startPos.X.Offset + delta.X,
                    startPos.Y.Scale, startPos.Y.Offset + delta.Y
                )
            end
        end)
        UIS.InputEnded:Connect(function(i)
            if i.UserInputType == Enum.UserInputType.MouseButton1 then
                dragging = false
            end
        end)
    end

    -- tabs
    local tabBar = Instance.new("Frame")
    tabBar.Size = UDim2.new(0,120,1,-44)
    tabBar.Position = UDim2.fromOffset(0,44)
    tabBar.BackgroundColor3 = Color3.fromRGB(22,22,22)
    tabBar.Parent = main

    local pages = Instance.new("Frame")
    pages.Size = UDim2.new(1,-120,1,-44)
    pages.Position = UDim2.fromOffset(120,44)
    pages.BackgroundTransparency = 1
    pages.Parent = main

    local UIList = Instance.new("UIListLayout", tabBar)
    UIList.Padding = UDim.new(0,4)

    local window = {}
    local currentPage

    --------------------------------------------------
    -- TAB
    --------------------------------------------------
    function window:CreateTab(name)
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(1,-10,0,36)
        btn.Position = UDim2.fromOffset(5,0)
        btn.Text = name
        btn.Font = Enum.Font.Gotham
        btn.TextSize = 14
        btn.TextColor3 = Lib.Theme.SubText
        btn.BackgroundColor3 = Color3.fromRGB(25,25,25)
        btn.BorderSizePixel = 0
        btn.Parent = tabBar
        round(btn,8)

        local page = Instance.new("ScrollingFrame")
        page.Size = UDim2.fromScale(1,1)
        page.CanvasSize = UDim2.new(0,0,0,0)
        page.ScrollBarImageTransparency = 1
        page.Visible = false
        page.Parent = pages

        local layout = Instance.new("UIListLayout", page)
        layout.Padding = UDim.new(0,8)

        layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            page.CanvasSize = UDim2.new(0,0,0,layout.AbsoluteContentSize.Y + 10)
        end)

        btn.MouseButton1Click:Connect(function()
            if currentPage then currentPage.Visible = false end
            currentPage = page
            page.Visible = true
        end)

        if not currentPage then
            currentPage = page
            page.Visible = true
            btn.TextColor3 = Lib.Theme.Text
        end

        --------------------------------------------------
        -- ELEMENTS
        --------------------------------------------------
        local tab = {}

        function tab:AddButton(text, cb)
            local b = Instance.new("TextButton")
            b.Size = UDim2.new(1,-12,0,40)
            b.Position = UDim2.fromOffset(6,0)
            b.Text = text
            b.Font = Enum.Font.Gotham
            b.TextSize = 14
            b.TextColor3 = Lib.Theme.Text
            b.BackgroundColor3 = Color3.fromRGB(30,30,30)
            b.BorderSizePixel = 0
            b.Parent = page
            round(b,10)

            b.MouseButton1Click:Connect(function()
                if cb then task.spawn(cb) end
                tween(b, {BackgroundColor3 = Lib.Theme.Accent}, 0.1)
                task.delay(0.15, function()
                    tween(b, {BackgroundColor3 = Color3.fromRGB(30,30,30)}, 0.2)
                end)
            end)
        end

        function tab:AddToggle(text, default, cb)
            local on = default or false

            local frame = Instance.new("Frame")
            frame.Size = UDim2.new(1,-12,0,40)
            frame.Position = UDim2.fromOffset(6,0)
            frame.BackgroundColor3 = Color3.fromRGB(30,30,30)
            frame.Parent = page
            round(frame,10)

            local lbl = Instance.new("TextLabel")
            lbl.Size = UDim2.new(1,-60,1,0)
            lbl.Position = UDim2.fromOffset(10,0)
            lbl.Text = text
            lbl.Font = Enum.Font.Gotham
            lbl.TextSize = 14
            lbl.TextColor3 = Lib.Theme.Text
            lbl.BackgroundTransparency = 1
            lbl.TextXAlignment = Left
            lbl.Parent = frame

            local toggle = Instance.new("Frame")
            toggle.Size = UDim2.fromOffset(36,18)
            toggle.Position = UDim2.new(1,-46,0.5,-9)
            toggle.BackgroundColor3 = on and Lib.Theme.Accent or Color3.fromRGB(60,60,60)
            toggle.Parent = frame
            round(toggle,9)

            frame.InputBegan:Connect(function(i)
                if i.UserInputType == Enum.UserInputType.MouseButton1 then
                    on = not on
                    tween(toggle, {
                        BackgroundColor3 = on and Lib.Theme.Accent or Color3.fromRGB(60,60,60)
                    })
                    if cb then cb(on) end
                end
            end)
        end

        return tab
    end

    --------------------------------------------------
    -- KEY TOGGLE
    --------------------------------------------------
    UIS.InputBegan:Connect(function(i, gp)
        if gp then return end
        if i.KeyCode == Enum.KeyCode.RightControl then
            main.Visible = not main.Visible
        end
    end)

    return window
end

return Lib
