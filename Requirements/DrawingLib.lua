local coreGui = game:GetService("CoreGui")

-- UI Objects
local camera = workspace.CurrentCamera
local drawingUI = Instance.new("ScreenGui")
drawingUI.Name = "Drawing"
drawingUI.IgnoreGuiInset = true
drawingUI.DisplayOrder = 0x7fffffff
drawingUI.Parent = coreGui

-- Variables
local drawingCounter = 0
local drawingInstances = table.create(0)

local baseDrawingProperties = setmetatable({
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

local drawingFonts = {
	[0] = Font.fromEnum(Enum.Font.Roboto),
	[1] = Font.fromEnum(Enum.Font.Legacy),
	[2] = Font.fromEnum(Enum.Font.SourceSans),
	[3] = Font.fromEnum(Enum.Font.RobotoMono)
}

-- Functions
local function getFontFromIndex(index)
	return drawingFonts[index]
end

local function convertTransparency(value)
	return math.clamp(1 - value, 0, 1)
end

-- Main Drawing Library
local DrawingLib = {}
DrawingLib.Fonts = {
	["UI"] = 0,
	["System"] = 1,
	["Plex"] = 2,
	["Monospace"] = 3
}

function DrawingLib.new(drawingType)
	drawingCounter += 1

	if drawingType == "Line" then
		local lineProperties = ({
			From = Vector2.zero,
			To = Vector2.zero,
			Thickness = 1
		} + baseDrawingProperties)

		local lineFrame = Instance.new("Frame")
		lineFrame.Name = drawingCounter
		lineFrame.AnchorPoint = Vector2.one * 0.5
		lineFrame.BorderSizePixel = 0
		lineFrame.BackgroundColor3 = lineProperties.Color
		lineFrame.Visible = lineProperties.Visible
		lineFrame.ZIndex = lineProperties.ZIndex
		lineFrame.BackgroundTransparency = convertTransparency(lineProperties.Transparency)
		lineFrame.Size = UDim2.new()

		lineFrame.Parent = drawingUI

		return setmetatable(table.create(0), {
			__newindex = function(_, index, value)
				if typeof(lineProperties[index]) == "nil" then return end

				if index == "From" or index == "To" then
					local direction = index == "From" and (lineProperties.To - value) or (value - lineProperties.From)
					local center = (lineProperties.To + lineProperties.From) / 2
					local distance = direction.Magnitude
					local angle = math.deg(math.atan2(direction.Y, direction.X))

					lineFrame.Position = UDim2.fromOffset(center.X, center.Y)
					lineFrame.Rotation = angle
					lineFrame.Size = UDim2.fromOffset(distance, lineProperties.Thickness)
				elseif index == "Thickness" then
					lineFrame.Size = UDim2.fromOffset((lineProperties.To - lineProperties.From).Magnitude, value)
				elseif index == "Visible" then
					lineFrame.Visible = value
				elseif index == "ZIndex" then
					lineFrame.ZIndex = value
				elseif index == "Transparency" then
					lineFrame.BackgroundTransparency = convertTransparency(value)
				elseif index == "Color" then
					lineFrame.BackgroundColor3 = value
				end
				lineProperties[index] = value
			end,
			__index = function(self, index)
				if index == "Remove" or index == "Destroy" then
					return function()
						lineFrame:Destroy()
						lineProperties.Remove(self)
						return lineProperties:Remove()
					end
				end
				return lineProperties[index]
			end,
			__tostring = function() return "Line Drawing" end
		})

	elseif drawingType == "Text" then
		local textProperties = ({
			Text = "",
			Font = DrawingLib.Fonts.UI,
			Size = 0,
			Position = Vector2.zero,
			Center = false,
			Outline = false,
			OutlineColor = Color3.new()
		} + baseDrawingProperties)

		local textLabel = Instance.new("TextLabel")
		local uiStroke = Instance.new("UIStroke")
		textLabel.Name = drawingCounter
		textLabel.AnchorPoint = Vector2.one * .5
		textLabel.BorderSizePixel = 0
		textLabel.BackgroundTransparency = 1

		textLabel.Visible = textProperties.Visible
		textLabel.TextColor3 = textProperties.Color
		textLabel.TextTransparency = convertTransparency(textProperties.Transparency)
		textLabel.ZIndex = textProperties.ZIndex

		textLabel.FontFace = getFontFromIndex(textProperties.Font)
		textLabel.TextSize = textProperties.Size

		textLabel:GetPropertyChangedSignal("TextBounds"):Connect(function()
			local bounds = textLabel.TextBounds
			local offset = bounds / 2

			textLabel.Size = UDim2.fromOffset(bounds.X, bounds.Y)
			textLabel.Position = UDim2.fromOffset(textProperties.Position.X + (textProperties.Center and 0 or offset.X), textProperties.Position.Y + offset.Y)
		end)

		uiStroke.Thickness = 1
		uiStroke.Enabled = textProperties.Outline
		uiStroke.Color = textProperties.Color

		textLabel.Parent, uiStroke.Parent = drawingUI, textLabel

		return setmetatable(table.create(0), {
			__newindex = function(_, index, value)
				if typeof(textProperties[index]) == "nil" then return end

				if index == "Text" then
					textLabel.Text = value
				elseif index == "Font" then
					value = math.clamp(value, 0, 3)
					textLabel.FontFace = getFontFromIndex(value)
				elseif index == "Size" then
					textLabel.TextSize = value
				elseif index == "Position" then
					local offset = textLabel.TextBounds / 2
					textLabel.Position = UDim2.fromOffset(value.X + (textProperties.Center and 0 or offset.X), value.Y + offset.Y)
				elseif index == "Center" then
					local position = value and (camera.ViewportSize / 2) or textProperties.Position
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
				textProperties[index] = value
			end,
			__index = function(self, index)
				if index == "Remove" or index == "Destroy" then
					return function()
						textLabel:Destroy()
						textProperties.Remove(self)
						return textProperties:Remove()
					end
				elseif index == "TextBounds" then
					return textLabel.TextBounds
				end
				return textProperties[index]
			end,
			__tostring = function() return "Text Drawing" end
		})

	elseif drawingType == "Circle" then
		local circleProperties = ({
			Radius = 150,
			Position = Vector2.zero,
			Thickness = .7,
			Filled = false
		} + baseDrawingProperties)

		local circleFrame = Instance.new("Frame")
		local uiCorner = Instance.new("UICorner")
		local uiStroke = Instance.new("UIStroke")
		circleFrame.Name = drawingCounter
		circleFrame.AnchorPoint = Vector2.one * .5
		circleFrame.BorderSizePixel = 0

		circleFrame.BackgroundTransparency = circleProperties.Filled and convertTransparency(circleProperties.Transparency) or 1
		circleFrame.BackgroundColor3 = circleProperties.Color
		circleFrame.Visible = circleProperties.Visible
		circleFrame.ZIndex = circleProperties.ZIndex

		uiCorner.CornerRadius = UDim.new(1, 0)
		circleFrame.Size = UDim2.fromOffset(circleProperties.Radius, circleProperties.Radius)

		uiStroke.Thickness = circleProperties.Thickness
		uiStroke.Enabled = not circleProperties.Filled
		uiStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

		circleFrame.Parent, uiCorner.Parent, uiStroke.Parent = drawingUI, circleFrame, circleFrame

		return setmetatable(table.create(0), {
			__newindex = function(_, index, value)
				if typeof(circleProperties[index]) == "nil" then return end

				if index == "Radius" then
					local radius = value * 2
					circleFrame.Size = UDim2.fromOffset(radius, radius)
				elseif index == "Position" then
					circleFrame.Position = UDim2.fromOffset(value.X, value.Y)
				elseif index == "Thickness" then
					value = math.clamp(value, .6, 5)
					uiStroke.Thickness = value
				elseif index == "Filled" then
					circleFrame.BackgroundTransparency = value and convertTransparency(circleProperties.Transparency) or 1
					uiStroke.Enabled = not value
				elseif index == "Visible" then
					circleFrame.Visible = value
				elseif index == "ZIndex" then
					circleFrame.ZIndex = value
				elseif index == "Transparency" then
					circleFrame.BackgroundTransparency = convertTransparency(value)
				elseif index == "Color" then
					circleFrame.BackgroundColor3 = value
				end
				circleProperties[index] = value
			end,
			__index = function(self, index)
				if index == "Remove" or index == "Destroy" then
					return function()
						circleFrame:Destroy()
						circleProperties.Remove(self)
						return circleProperties:Remove()
					end
				end
				return circleProperties[index]
			end,
			__tostring = function() return "Circle Drawing" end
		})
	end
end

return DrawingLib
