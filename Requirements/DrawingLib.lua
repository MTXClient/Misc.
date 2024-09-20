local coreGui = game:GetService("CoreGui")
local camera = workspace.CurrentCamera
local drawingUI = Instance.new("ScreenGui")
drawingUI.Name = "Drawing"
drawingUI.IgnoreGuiInset = true
drawingUI.DisplayOrder = 0x7fffffff
drawingUI.Parent = coreGui

local drawingIndex = 0
local uiStrokes = table.create(0)

local baseDrawingObj = setmetatable({
    Visible = true,
    ZIndex = 0,
    Transparency = 1,
    Color = Color3.new(),
    Remove = function(self)
        setmetatable(self, nil)
    end,
    Destroy = function(self)
        setmetatable(self, nil)
    end
}, {
    __add = function(t1, t2)
        local result = table.clone(t1)
        for index, value in t2 do
            result[index] = value
        end
        return result
    end
})

local drawingFontsEnum = {
    [0] = Font.fromEnum(Enum.Font.Roboto),
    [1] = Font.fromEnum(Enum.Font.Legacy),
    [2] = Font.fromEnum(Enum.Font.SourceSans),
    [3] = Font.fromEnum(Enum.Font.RobotoMono)
}

local function getFontFromIndex(fontIndex)
    return drawingFontsEnum[fontIndex]
end

local function convertTransparency(transparency)
    return math.clamp(1 - transparency, 0, 1)
end

local DrawingLib = {}
DrawingLib.Fonts = {
    ["UI"] = 0,
    ["System"] = 1,
    ["Plex"] = 2,
    ["Monospace"] = 3
}

function DrawingLib.new(drawingType)
    drawingIndex += 1

    if drawingType == "Line" then
        local lineObj = ({
            From = Vector2.zero,
            To = Vector2.zero,
            Thickness = 1
        } + baseDrawingObj)

        local lineFrame = Instance.new("Frame")
        lineFrame.Name = drawingIndex
        lineFrame.AnchorPoint = (Vector2.one * 0.5)
        lineFrame.BorderSizePixel = 0
        lineFrame.BackgroundColor3 = lineObj.Color
        lineFrame.Visible = lineObj.Visible
        lineFrame.ZIndex = lineObj.ZIndex
        lineFrame.BackgroundTransparency = convertTransparency(lineObj.Transparency)
        lineFrame.Size = UDim2.new()
        lineFrame.Parent = drawingUI

        return setmetatable({}, {
            __newindex = function(_, index, value)
                if typeof(lineObj[index]) == "nil" then return end

                if index == "From" then
                    local direction = (lineObj.To - value)
                    local center = (lineObj.To + value) / 2
                    local distance = direction.Magnitude
                    local theta = math.deg(math.atan2(direction.Y, direction.X))

                    lineFrame.Position = UDim2.fromOffset(center.X, center.Y)
                    lineFrame.Rotation = theta
                    lineFrame.Size = UDim2.fromOffset(distance, lineObj.Thickness)
                elseif index == "To" then
                    local direction = (value - lineObj.From)
                    local center = (value + lineObj.From) / 2
                    local distance = direction.Magnitude
                    local theta = math.deg(math.atan2(direction.Y, direction.X))

                    lineFrame.Position = UDim2.fromOffset(center.X, center.Y)
                    lineFrame.Rotation = theta
                    lineFrame.Size = UDim2.fromOffset(distance, lineObj.Thickness)
                elseif index == "Thickness" then
                    local distance = (lineObj.To - lineObj.From).Magnitude
                    lineFrame.Size = UDim2.fromOffset(distance, value)
                elseif index == "Visible" then
                    lineFrame.Visible = value
                elseif index == "ZIndex" then
                    lineFrame.ZIndex = value
                elseif index == "Transparency" then
                    lineFrame.BackgroundTransparency = convertTransparency(value)
                elseif index == "Color" then
                    lineFrame.BackgroundColor3 = value
                end
                lineObj[index] = value
            end,
            __index = function(self, index)
                if index == "Remove" or index == "Destroy" then
                    return function()
                        lineFrame:Destroy()
                        lineObj.Remove(self)
                        return lineObj:Remove()
                    end
                end
                return lineObj[index]
            end,
            __tostring = function() return "Drawing" end
        })
    elseif drawingType == "Text" then
        local textObj = ({
            Text = "",
            Font = DrawingLib.Fonts.UI,
            Size = 0,
            Position = Vector2.zero,
            Center = false,
            Outline = false,
            OutlineColor = Color3.new()
        } + baseDrawingObj)

        local textLabel = Instance.new("TextLabel")
        local uiStroke = Instance.new("UIStroke")
        textLabel.Name = drawingIndex
        textLabel.AnchorPoint = (Vector2.one * .5)
        textLabel.BorderSizePixel = 0
        textLabel.BackgroundTransparency = 1
        textLabel.Visible = textObj.Visible
        textLabel.TextColor3 = textObj.Color
        textLabel.TextTransparency = convertTransparency(textObj.Transparency)
        textLabel.ZIndex = textObj.ZIndex
        textLabel.FontFace = getFontFromIndex(textObj.Font)
        textLabel.TextSize = textObj.Size

        textLabel:GetPropertyChangedSignal("TextBounds"):Connect(function()
            local textBounds = textLabel.TextBounds
            local offset = textBounds / 2
            textLabel.Size = UDim2.fromOffset(textBounds.X, textBounds.Y)
            textLabel.Position = UDim2.fromOffset(textObj.Position.X + (if not textObj.Center then offset.X else 0), textObj.Position.Y + offset.Y)
        end)

        uiStroke.Thickness = 1
        uiStroke.Enabled = textObj.Outline
        uiStroke.Color = textObj.Color

        textLabel.Parent, uiStroke.Parent = drawingUI, textLabel

        return setmetatable({}, {
            __newindex = function(_, index, value)
                if typeof(textObj[index]) == "nil" then return end

                if index == "Text" then
                    textLabel.Text = value
                elseif index == "Font" then
                    value = math.clamp(value, 0, 3)
                    textLabel.FontFace = getFontFromIndex(value)
                elseif index == "Size" then
                    textLabel.TextSize = value
                elseif index == "Position" then
                    local offset = textLabel.TextBounds / 2
                    textLabel.Position = UDim2.fromOffset(value.X + (if not textObj.Center then offset.X else 0), value.Y + offset.Y)
                elseif index == "Center" then
                    local position = (if value then camera.ViewportSize / 2 else textObj.Position)
                    textLabel.Position = UDim2.fromOffset(position.X, position.Y)
                elseif index == "Outline" then
                    uiStroke.Enabled = value
                elseif index == "OutlineColor" then
                    uiStroke.Color = value
                elseif index == "Visible" then
                    textLabel.Visible = value
                elseif index == "ZIndex" then
                    textLabel.ZIndex = value
                elseif index == "Transparency" then
                    local transparency = convertTransparency(value)
                    textLabel.TextTransparency = transparency
                    uiStroke.Transparency = transparency
                elseif index == "Color" then
                    textLabel.TextColor3 = value
                end
                textObj[index] = value
            end,
            __index = function(self, index)
                if index == "Remove" or index == "Destroy" then
                    return function()
                        textLabel:Destroy()
                        textObj.Remove(self)
                        return textObj:Remove()
                    end
                elseif index == "TextBounds" then
                    return textLabel.TextBounds
                end
                return textObj[index]
            end,
            __tostring = function() return "Drawing" end
        })
    elseif drawingType == "Circle" then
        local circleObj = ({
            Radius = 150,
            Position = Vector2.zero,
            Thickness = .7,
            Filled = false
        } + baseDrawingObj)

        local circleFrame = Instance.new("Frame")
        local uiCorner = Instance.new("UICorner")
        local uiStroke = Instance.new("UIStroke")

        circleFrame.Name = drawingIndex
        circleFrame.AnchorPoint = (Vector2.one * 0.5)
        circleFrame.BorderSizePixel = 0
        circleFrame.BackgroundTransparency = (if circleObj.Filled then convertTransparency(circleObj.Transparency) else 1)
        circleFrame.BackgroundColor3 = circleObj.Color
        circleFrame.Visible = circleObj.Visible
        circleFrame.ZIndex = circleObj.ZIndex
        uiCorner.CornerRadius = UDim.new(1, 0)
        circleFrame.Size = UDim2.fromOffset(circleObj.Radius, circleObj.Radius)

        uiStroke.Thickness = circleObj.Thickness
        uiStroke.Enabled = not circleObj.Filled
        uiStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

        circleFrame.Parent, uiCorner.Parent, uiStroke.Parent = drawingUI, circleFrame, circleFrame

        return setmetatable({}, {
            __newindex = function(_, index, value)
                if typeof(circleObj[index]) == "nil" then return end

                if index == "Radius" then
                    local radius = value * 2
                    circleFrame.Size = UDim2.fromOffset(radius, radius)
                elseif index == "Position" then
                    circleFrame.Position = UDim2.fromOffset(value.X, value.Y)
                elseif index == "Thickness" then
                    uiStroke.Thickness = value
                elseif index == "Filled" then
                    circleFrame.BackgroundTransparency = (if value then convertTransparency(circleObj.Transparency) else 1)
                    uiStroke.Enabled = not value
                elseif index == "Visible" then
                    circleFrame.Visible = value
                elseif index == "ZIndex" then
                    circleFrame.ZIndex = value
                elseif index == "Transparency" then
                    circleFrame.BackgroundTransparency = convertTransparency(value)
                    uiStroke.Transparency = convertTransparency(value)
                elseif index == "Color" then
                    circleFrame.BackgroundColor3 = value
                end
                circleObj[index] = value
            end,
            __index = function(self, index)
                if index == "Remove" or index == "Destroy" then
                    return function()
                        circleFrame:Destroy()
                        circleObj.Remove(self)
                        return circleObj:Remove()
                    end
                end
                return circleObj[index]
            end,
            __tostring = function() return "Drawing" end
        })
    end
end

function DrawingLib.Update()
    for _, uiStroke in pairs(uiStrokes) do
        if uiStroke.Enabled then
            uiStroke:Update()
        end
    end
end

return DrawingLib
