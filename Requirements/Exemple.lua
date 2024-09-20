local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/MTXClient/Misc./main/Requirements/UI.lua"))()

-- Criação da janela principal
local Window = Library:CreateWindow({
    Title = "Exemple",
    SubTitle = "",
    TabWidth = 64,
    Size = UDim2.fromOffset(500, 320),
    Acrylic = false,
    Theme = "Amethyst",
    MinimizeKey = Enum.KeyCode.LeftControl,
    Folder = "ExempleCfg",
    Center = true,
})

-- Seção de opções de farm
local MainOptions = Window:AddTabSection({Title = "Main Options"})
local Main = MainOptions:New({Title = "Main", Icon = "layers"})
local MainFarm = Main:AddSection("Main | Options")

-- Notificação
Library:Notify({
    Title = "Notification",
    Content = "This is a notification",
    SubContent = "SubContent",
    Duration = 5
})

-- Adicionando um parágrafo
MainFarm:AddParagraph({
    Title = "Paragraph",
    Content = "This is a paragraph.\nSecond line!"
})

-- Adicionando um botão
MainFarm:AddButton({
    Title = "Button",
    Description = "Very important button",
    Callback = function()
        -- Ação do botão
    end
})

-- Adicionando um toggle
local Toggle = MainFarm:AddToggle("MyToggle", {Title = "Toggle", Default = false })
Toggle.Callback = function()
    print("Toggle changed")
end

-- Adicionando um slider
local Slider = MainFarm:AddSlider("Slider", {
    Title = "Slider",
    Description = "This is a slider",
    Default = 2,
    Min = 0,
    Max = 5,
    Rounding = 1,
    Callback = function(Value)
        print("Slider was changed:", Value)
    end
})
Slider:SetValue(3)

-- Adicionando um dropdown
local Dropdown = MainFarm:AddDropdown("Dropdown", {
    Title = "Dropdown",
    Values = {"one", "two", "three", "four", "five", "six", "seven", "eight", "nine", "ten", "eleven", "twelve", "thirteen", "fourteen"},
    Multi = false,
    Default = 1,
    Callback = function(Value)
        print("Dropdown changed:", Value)
    end,
})
Dropdown:SetValue("four")

-- Adicionando um multi-dropdown
local MultiDropdown = MainFarm:AddDropdown("MultiDropdown", {
    Title = "Dropdown",
    Description = "You can select multiple values.",
    Values = {"one", "two", "three", "four", "five", "six", "seven", "eight", "nine", "ten", "eleven", "twelve", "thirteen", "fourteen"},
    Multi = true,
    Default = {"seven", "twelve"},
    Callback = function(Value)
        local Values = {}
        for Value, State in next, Value do
            table.insert(Values, Value)
        end
        print("Multidropdown changed:", table.concat(Values, ", "))
    end,
})
MultiDropdown:SetValue({
    three = true,
    five = true,
    seven = false
})

-- Adicionando um colorpicker
local Colorpicker = MainFarm:AddColorpicker("Colorpicker", {
    Title = "Colorpicker",
    Default = Color3.fromRGB(96, 205, 255),
    Callback = function()
        print("Colorpicker Value!", Value)
	end,
})

-- Adicionando um colorpicker com transparência
local TColorpicker = MainFarm:AddColorpicker("TransparencyColorpicker", {
    Title = "Colorpicker",
    Description = "but you can change the transparency.",
    Transparency = 0,
    Default = Color3.fromRGB(96, 205, 255),
    Callback = function(Value)
        print("Colorpicker transparency!", Value)
    end,
})

-- Adicionando um keybind
local Keybind = MainFarm:AddKeybind("Keybind", {
    Title = "KeyBind",
    Mode = "Toggle", -- Always, Toggle, Hold
    Default = "LeftControl",
    Callback = function(Value)
        print("Keybind clicked!", Value)
    end
})

-- Adicionando um input
local Input = MainFarm:AddInput("Input", {
    Title = "Input",
    Default = "Default",
    Placeholder = "Placeholder",
    Numeric = false, -- Apenas permite números
    Finished = false, -- Apenas chama callback quando você pressiona enter
    Callback = function(Value)
        print("Input changed:", Value)
    end
})
