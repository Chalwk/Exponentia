-- Exponentia Game - Love2D
-- License: MIT
-- Copyright (c) 2025 Jericho Crosby (Chalwk)

local ipairs = ipairs
local math_pi = math.pi
local math_sin = math.sin
local table_insert = table.insert

local lg = love.graphics
local math_random = love.math.random

local COLORS = {
    [2] = { 0.93, 0.89, 0.85 },    -- Light beige
    [4] = { 0.93, 0.88, 0.78 },    -- Light tan
    [8] = { 0.95, 0.69, 0.47 },    -- Peach
    [16] = { 0.96, 0.58, 0.39 },   -- Orange
    [32] = { 0.96, 0.49, 0.37 },   -- Red-orange
    [64] = { 0.96, 0.37, 0.23 },   -- Red
    [128] = { 0.93, 0.81, 0.45 },  -- Gold
    [256] = { 0.93, 0.79, 0.38 },  -- Yellow-gold
    [512] = { 0.93, 0.77, 0.31 },  -- Yellow
    [1024] = { 0.93, 0.75, 0.24 }, -- Bright yellow
    [2048] = { 0.93, 0.50, 0.93 }  -- Magenta
}

local BackgroundManager = {}
BackgroundManager.__index = BackgroundManager

local function initFloatingNumbers(self)
    self.floatingNumbers = {}
    local numberCount = 30

    for _ = 1, numberCount do
        table_insert(self.floatingNumbers, {
            x = math_random() * 1000,
            y = math_random() * 1000,
            size = math_random(14, 22),
            speedX = math_random(-15, 15),
            speedY = math_random(-15, 15),
            rotation = math_random() * math_pi * 2,
            rotationSpeed = (math_random() - 0.5) * 1.5,
            bobSpeed = math_random(1, 2),
            bobAmount = math_random(3, 6),
            value = 2 ^ math_random(1, 8),
            alpha = math_random(0.2, 0.5),
            pulseSpeed = math_random(1, 2)
        })
    end
end

local function getNumberColor(value)
    return COLORS[value] or { 0.9, 0.8, 0.7 } -- Default color
end

function BackgroundManager.new()
    local instance = setmetatable({}, BackgroundManager)
    instance.floatingNumbers = {}
    instance.time = 0
    instance.pulseValue = 0

    initFloatingNumbers(instance)

    return instance
end

function BackgroundManager:update(dt)
    self.time = self.time + dt
    self.pulseValue = math_sin(self.time * 2) * 0.5 + 0.5

    -- Update floating numbers
    for _, number in ipairs(self.floatingNumbers) do
        number.x = number.x + number.speedX * dt
        number.y = number.y + number.speedY * dt

        -- Bobbing motion
        number.y = number.y + math_sin(self.time * number.bobSpeed) * number.bobAmount * dt
        number.rotation = number.rotation + number.rotationSpeed * dt

        -- Wrap around screen edges
        if number.x < -50 then number.x = 1050 end
        if number.x > 1050 then number.x = -50 end
        if number.y < -50 then number.y = 1050 end
        if number.y > 1050 then number.y = -50 end
    end
end

function BackgroundManager:drawMenuBackground(screenWidth, screenHeight, time)
    -- Gradient background with mathematical theme
    for y = 0, screenHeight, 2 do
        local progress = y / screenHeight
        local pulse = (math_sin(time * 1.5 + progress * 6) + 1) * 0.1
        local wave = math_sin(progress * 10 + time * 2) * 0.03

        local r = 0.1 + progress * 0.4 + pulse + wave
        local g = 0.2 + progress * 0.3 + pulse
        local b = 0.4 + progress * 0.5 + pulse

        lg.setColor(r, g, b, 0.8)
        lg.rectangle("fill", 0, y, screenWidth, 2)
    end

    -- Draw floating numbers
    for _, number in ipairs(self.floatingNumbers) do
        local pulse = math_sin(time * number.pulseSpeed) * 0.3 + 0.7
        local currentAlpha = number.alpha * pulse

        lg.push()
        lg.translate(number.x, number.y)
        lg.rotate(number.rotation)

        -- Color based on number value
        local value = number.value
        local r, g, b = getNumberColor(value)
        lg.setColor(r, g, b, currentAlpha)

        lg.print(tostring(value), 0, 0, 0, number.size / 20)
        lg.pop()
    end

    -- Mathematical grid pattern
    lg.setColor(0.3, 0.5, 0.8, 0.15 + self.pulseValue * 0.1)
    local gridSize = 60
    for x = 0, screenWidth, gridSize do
        for y = 0, screenHeight, gridSize do
            lg.push()
            lg.translate(x, y)

            -- Draw plus sign for addition theme
            lg.setLineWidth(2)
            lg.line(-8, 0, 8, 0)
            lg.line(0, -8, 0, 8)

            lg.pop()
        end
    end
end

function BackgroundManager:drawGameBackground(screenWidth, screenHeight, time)
    -- Dark, focused gradient
    for y = 0, screenHeight, 1.5 do
        local progress = y / screenHeight
        local wave = math_sin(progress * 15 + time * 0.5) * 0.02
        local pulse = math_sin(progress * 8 + time) * 0.01

        local r = 0.05 + wave + pulse
        local g = 0.08 + progress * 0.06 + wave
        local b = 0.15 + progress * 0.1 + pulse

        lg.setColor(r, g, b, 0.9)
        lg.rectangle("fill", 0, y, screenWidth, 1.5)
    end

    -- Subtle mathematical symbols in background
    lg.setColor(0.2, 0.3, 0.4, 0.08)
    local symbolSize = 100
    local offset = math_sin(time * 0.2) * 10

    for x = -offset, screenWidth + offset, symbolSize do
        for y = -offset, screenHeight + offset, symbolSize do
            lg.push()
            lg.translate(x, y)

            -- Draw mathematical symbols
            lg.setLineWidth(1)
            lg.print("×", -8, -8)
            lg.print("+", 8, 8)
            lg.print("=", 0, 0)

            lg.pop()
        end
    end
end

return BackgroundManager
