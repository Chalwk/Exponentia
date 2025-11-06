-- Exponentia Game - Love2D
-- License: MIT
-- Copyright (c) 2025 Jericho Crosby (Chalwk)

local ipairs = ipairs
local math_sin = math.sin
local lg = love.graphics

local Menu = {}
Menu.__index = Menu

local helpText = {
    "Combine tiles with the same numbers!",
    "",
    "When two tiles with the same number touch,",
    "they merge into one with their sum!",
    "",
    "Goal: Create a tile with 2048",
    "",
    "Controls:",
    "• Arrow Keys or WASD to move tiles",
    "• R to restart game",
    "• ESC to return to menu",
    "",
    "Click anywhere to close"
}

local function updateButtonPositions(self)
    local centerX = self.screenWidth / 2
    local startY = self.screenHeight / 2 - 30

    for i, button in ipairs(self.menuButtons) do
        button.x = centerX - button.width / 2
        button.y = startY + (i - 1) * 70
    end

    -- Update help button position
    self.helpButton.x = 30
    self.helpButton.y = self.screenHeight - 80
end

local function createMenuButtons(self)
    self.menuButtons = {
        {
            text = "Start Game",
            action = "start",
            width = 200,
            height = 50,
            x = 0,
            y = 0,
            color = { 0.2, 0.7, 0.3 }
        },
        {
            text = "Quit Game",
            action = "quit",
            width = 200,
            height = 50,
            x = 0,
            y = 0,
            color = { 0.8, 0.3, 0.3 }
        }
    }

    -- Help button
    self.helpButton = {
        text = "?",
        action = "help",
        width = 40,
        height = 40,
        x = 30,
        y = self.screenHeight - 80,
        color = { 0.3, 0.6, 0.9 }
    }

    updateButtonPositions(self)
end

local function drawButton(self, button)
    local isHovered = self.buttonHover == button.action
    local pulse = math_sin(self.time * 6) * 0.1 + 0.9

    -- Button background with hover effect
    lg.setColor(button.color[1], button.color[2], button.color[3], isHovered and 0.9 or 0.7)
    lg.rectangle("fill", button.x, button.y, button.width, button.height, 8)

    -- Button border
    lg.setColor(1, 1, 1, isHovered and 1 or 0.8)
    lg.setLineWidth(isHovered and 3 or 2)
    lg.rectangle("line", button.x, button.y, button.width, button.height, 8)

    -- Button text
    lg.setColor(1, 1, 1, pulse)
    lg.setFont(self.mediumFont)
    local textWidth = self.mediumFont:getWidth(button.text)
    local textHeight = self.mediumFont:getHeight()

    lg.print(button.text,
        button.x + (button.width - textWidth) / 2,
        button.y + (button.height - textHeight) / 2)

    lg.setLineWidth(1)
end

local function drawMenuButtons(self)
    for _, button in ipairs(self.menuButtons) do
        drawButton(self, button)
    end
end

local function drawHelpButton(self)
    local button = self.helpButton
    local isHovered = self.buttonHover == "help"
    local pulse = math_sin(self.time * 5) * 0.2 + 0.8

    -- Button background with hover effect
    lg.setColor(button.color[1], button.color[2], button.color[3], isHovered and 0.9 or 0.7)
    lg.circle("fill", button.x + button.width / 2, button.y + button.height / 2, button.width / 2)

    -- Button border with glow
    lg.setColor(1, 1, 1, isHovered and 1 or 0.8)
    lg.setLineWidth(isHovered and 3 or 2)
    lg.circle("line", button.x + button.width / 2, button.y + button.height / 2, button.width / 2)

    -- Question mark with pulse
    lg.setColor(1, 1, 1, pulse)
    lg.setFont(self.mediumFont)
    local textWidth = self.mediumFont:getWidth(button.text)
    local textHeight = self.mediumFont:getHeight()
    lg.print(button.text,
        button.x + (button.width - textWidth) / 2,
        button.y + (button.height - textHeight) / 2)

    lg.setLineWidth(1)
end

local function drawHelpOverlay(self, screenWidth, screenHeight)
    -- Overlay with blur effect
    for i = 1, 3 do
        local alpha = 0.9 - (i * 0.2)
        lg.setColor(0, 0, 0, alpha)
        lg.rectangle("fill", -i, -i, screenWidth + i * 2, screenHeight + i * 2)
    end

    -- Help box
    local boxWidth = 500
    local boxHeight = 400
    local boxX = (screenWidth - boxWidth) / 2
    local boxY = (screenHeight - boxHeight) / 2

    -- Box background with gradient
    for y = boxY, boxY + boxHeight do
        local progress = (y - boxY) / boxHeight
        local r = 0.08 + progress * 0.1
        local g = 0.1 + progress * 0.1
        local b = 0.15 + progress * 0.1
        lg.setColor(r, g, b, 0.98)
        lg.line(boxX, y, boxX + boxWidth, y)
    end

    -- Box border with glow
    lg.setColor(0.3, 0.6, 0.9, 0.8)
    lg.setLineWidth(4)
    lg.rectangle("line", boxX, boxY, boxWidth, boxHeight, 12)

    -- Title
    lg.setColor(1, 1, 1)
    lg.setFont(self.largeFont)
    lg.printf("How to Play", boxX, boxY + 25, boxWidth, "center")

    -- Help text
    lg.setColor(0.9, 0.9, 0.9)
    lg.setFont(self.smallFont)

    local lineHeight = 22
    for i, line in ipairs(helpText) do
        local y = boxY + 80 + (i - 1) * lineHeight
        lg.printf(line, boxX + 40, y, boxWidth - 80, "center")
    end

    lg.setLineWidth(1)
end

local function drawTitle(self, screenWidth, screenHeight)
    local centerX = screenWidth / 2
    local centerY = screenHeight / 4

    lg.push()
    lg.translate(centerX, centerY)
    lg.scale(self.title.scale, self.title.scale)

    -- Title shadow
    lg.setColor(0, 0, 0, 0.5)
    lg.printf(self.title.text, -self.titleFont:getWidth(self.title.text) / 2 + 3,
        -self.titleFont:getHeight() / 2 + 3, screenWidth, "center")

    -- Title main with glow
    lg.setColor(0.9, 0.2, 0.2, self.title.glow)
    lg.printf(self.title.text, -self.titleFont:getWidth(self.title.text) / 2,
        -self.titleFont:getHeight() / 2, screenWidth, "center")

    -- Subtitle
    lg.setColor(1, 1, 1, 0.8)
    lg.setFont(self.mediumFont)
    lg.printf("Power of Two", -100, 40, 200, "center")

    lg.pop()
end

function Menu.new()
    local instance = setmetatable({}, Menu)

    instance.screenWidth = 600
    instance.screenHeight = 700
    instance.title = {
        text = "EXPONENTIA",
        scale = 1,
        scaleDirection = 1,
        scaleSpeed = 0.4,
        minScale = 0.95,
        maxScale = 1.05,
        glow = 0
    }
    instance.showHelp = false
    instance.time = 0
    instance.buttonHover = nil

    instance.smallFont = lg.newFont(16)
    instance.mediumFont = lg.newFont(24)
    instance.largeFont = lg.newFont(48)
    instance.titleFont = lg.newFont(64)

    createMenuButtons(instance)

    return instance
end

function Menu:update(dt, screenWidth, screenHeight)
    self.time = self.time + dt

    if screenWidth ~= self.screenWidth or screenHeight ~= self.screenHeight then
        self.screenWidth = screenWidth
        self.screenHeight = screenHeight
        updateButtonPositions(self)
    end

    -- Title animation
    self.title.scale = self.title.scale + self.title.scaleDirection * self.title.scaleSpeed * dt
    self.title.glow = math_sin(self.time * 3) * 0.3 + 0.7

    if self.title.scale > self.title.maxScale then
        self.title.scale = self.title.maxScale
        self.title.scaleDirection = -1
    elseif self.title.scale < self.title.minScale then
        self.title.scale = self.title.minScale
        self.title.scaleDirection = 1
    end

    -- Update button hover state
    self:updateButtonHover(love.mouse.getX(), love.mouse.getY())
end

function Menu:updateButtonHover(x, y)
    self.buttonHover = nil

    if self.showHelp then return end

    for _, button in ipairs(self.menuButtons) do
        if x >= button.x and x <= button.x + button.width and
            y >= button.y and y <= button.y + button.height then
            self.buttonHover = button.action
            return
        end
    end

    -- Check help button
    if self.helpButton and
        x >= self.helpButton.x and x <= self.helpButton.x + self.helpButton.width and
        y >= self.helpButton.y and y <= self.helpButton.y + self.helpButton.height then
        self.buttonHover = "help"
    end
end

function Menu:draw(screenWidth, screenHeight)
    -- Draw the title
    drawTitle(self, screenWidth, screenHeight)

    if self.showHelp then
        drawHelpOverlay(self, screenWidth, screenHeight)
    else
        drawMenuButtons(self)

        -- Instructions
        lg.setColor(0.9, 0.9, 0.9, 0.8)
        lg.setFont(self.smallFont)
        lg.printf("Combine tiles to reach 2048!", 0, screenHeight / 3 + 30, screenWidth, "center")

        -- Draw help button
        drawHelpButton(self)
    end

    -- Copyright
    lg.setColor(1, 1, 1, 0.6)
    lg.setFont(self.smallFont)
    lg.printf("© 2025 Jericho Crosby – Exponentia", 10, screenHeight - 30, screenWidth - 20, "right")
end

function Menu:handleClick(x, y)
    if self.showHelp then
        self.showHelp = false
        return "help_close"
    end

    for _, button in ipairs(self.menuButtons) do
        if x >= button.x and x <= button.x + button.width and
            y >= button.y and y <= button.y + button.height then
            return button.action
        end
    end

    -- Check help button
    if self.helpButton and x >= self.helpButton.x and x <= self.helpButton.x + self.helpButton.width and
        y >= self.helpButton.y and y <= self.helpButton.y + self.helpButton.height then
        self.showHelp = true
        return "help"
    end

    return nil
end

function Menu:setScreenSize(width, height)
    self.screenWidth = width
    self.screenHeight = height
    updateButtonPositions(self)
end

return Menu
