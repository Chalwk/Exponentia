-- Exponentia Game - Love2D
-- License: MIT
-- Copyright (c) 2025 Jericho Crosby (Chalwk)

local math_max = math.max
local math_min = math.min
local table_insert = table.insert
local table_remove = table.remove

local lg = love.graphics
local math_random = love.math.random

local COLORS = {
    [0] = { 0.78, 0.74, 0.68, 0.35 }, -- Empty cell
    [2] = { 0.93, 0.89, 0.85 },
    [4] = { 0.93, 0.88, 0.78 },
    [8] = { 0.95, 0.69, 0.47 },
    [16] = { 0.96, 0.58, 0.39 },
    [32] = { 0.96, 0.49, 0.37 },
    [64] = { 0.96, 0.37, 0.23 },
    [128] = { 0.93, 0.81, 0.45 },
    [256] = { 0.93, 0.79, 0.38 },
    [512] = { 0.93, 0.77, 0.31 },
    [1024] = { 0.93, 0.75, 0.24 },
    [2048] = { 0.93, 0.50, 0.93 }
}

local function addRandomTile(self)
    local emptyCells = {}

    -- Find all empty cells
    for i = 1, self.gridSize do
        for j = 1, self.gridSize do
            if self.grid[i][j] == 0 then
                table_insert(emptyCells, { i, j })
            end
        end
    end

    if #emptyCells > 0 then
        local cell = emptyCells[math_random(#emptyCells)]
        local value = math_random() < 0.9 and 2 or 4
        self.grid[cell[1]][cell[2]] = value

        -- Add spawn animation
        table_insert(self.animations, {
            type = "spawn",
            row = cell[1],
            col = cell[2],
            progress = 0,
            duration = 0.2
        })
    end
end

local function resetGame(self)
    self.grid = {}
    self.score = 0
    self.bestScore = self.bestScore or 0
    self.gameOver = false
    self.won = false
    self.moved = false
    self.animations = {}

    -- Initialize empty grid
    for i = 1, self.gridSize do
        self.grid[i] = {}
        for j = 1, self.gridSize do
            self.grid[i][j] = 0
        end
    end

    -- Add two initial tiles
    addRandomTile(self)
    addRandomTile(self)
end

local function checkGameOver(self)
    -- Check for empty cells
    for i = 1, self.gridSize do
        for j = 1, self.gridSize do
            if self.grid[i][j] == 0 then
                return false
            end
        end
    end

    -- Check for possible merges
    for i = 1, self.gridSize do
        for j = 1, self.gridSize do
            local current = self.grid[i][j]
            -- Check right
            if j < self.gridSize and self.grid[i][j + 1] == current then
                return false
            end
            -- Check down
            if i < self.gridSize and self.grid[i + 1][j] == current then
                return false
            end
        end
    end

    self.gameOver = true
    return true
end

local function checkWin(self)
    for i = 1, self.gridSize do
        for j = 1, self.gridSize do
            if self.grid[i][j] == 2048 then
                self.won = true
                return
            end
        end
    end
end

local function getNumberColor(value)
    return COLORS[value] or { 0.9, 0.8, 0.7 } -- Default for higher numbers
end

local function getTextColor(value)
    if value <= 4 then
        return { 0.47, 0.43, 0.37 } -- Dark brown for light backgrounds
    else
        return { 0.97, 0.96, 0.95 } -- Light color for dark backgrounds
    end
end

local function drawGameOver(self)
    if not self.gameOver then return end

    -- Semi-transparent overlay
    lg.setColor(0, 0, 0, 0.7)
    lg.rectangle("fill", 0, 0, self.screenWidth, self.screenHeight)

    local font = lg.newFont(48)
    lg.setFont(font)

    if self.won then
        lg.setColor(0.2, 0.8, 0.2)
        lg.printf("YOU WIN!", 0, self.screenHeight / 2 - 80, self.screenWidth, "center")
    else
        lg.setColor(0.8, 0.2, 0.2)
        lg.printf("GAME OVER", 0, self.screenHeight / 2 - 80, self.screenWidth, "center")
    end

    lg.setColor(1, 1, 1)
    lg.setFont(lg.newFont(24))
    lg.printf("Final Score: " .. self.score, 0, self.screenHeight / 2, self.screenWidth, "center")

    lg.setFont(lg.newFont(18))
    lg.printf("Click anywhere to continue", 0, self.screenHeight / 2 + 60, self.screenWidth, "center")
end

local function drawGrid(self)
    local startX = (self.screenWidth - (self.cellSize * self.gridSize + self.gridPadding * (self.gridSize - 1))) / 2
    local startY = 200

    -- Draw grid background
    lg.setColor(0.72, 0.67, 0.62, 0.3)
    lg.rectangle("fill", startX - 10, startY - 10,
        self.cellSize * self.gridSize + self.gridPadding * (self.gridSize - 1) + 20,
        self.cellSize * self.gridSize + self.gridPadding * (self.gridSize - 1) + 20, 10)

    for i = 1, self.gridSize do
        for j = 1, self.gridSize do
            local x = startX + (j - 1) * (self.cellSize + self.gridPadding)
            local y = startY + (i - 1) * (self.cellSize + self.gridPadding)
            local value = self.grid[i][j]

            -- Draw cell
            local color = getNumberColor(value)
            lg.setColor(color)
            lg.rectangle("fill", x, y, self.cellSize, self.cellSize, 6)

            -- Draw cell border
            lg.setColor(0.72, 0.67, 0.62, 0.5)
            lg.rectangle("line", x, y, self.cellSize, self.cellSize, 6)

            -- Draw number if not empty
            if value ~= 0 then
                local textColor = getTextColor(value)
                lg.setColor(textColor)

                local fontSize = value < 100 and 36 or value < 1000 and 30 or 24
                local font = lg.newFont(fontSize)
                lg.setFont(font)

                local text = tostring(value)
                local textWidth = font:getWidth(text)
                local textHeight = font:getHeight()

                lg.print(text, x + (self.cellSize - textWidth) / 2, y + (self.cellSize - textHeight) / 2)
            end
        end
    end
end

local function drawUI(self)
    -- Title
    lg.setColor(1, 1, 1)
    local titleFont = lg.newFont(48)
    lg.setFont(titleFont)
    lg.printf("EXPONENTIA", 0, 40, self.screenWidth, "center")

    -- Score
    lg.setColor(0.72, 0.67, 0.62)
    local scoreFont = lg.newFont(20)
    lg.setFont(scoreFont)

    lg.printf("SCORE: " .. self.score, 0, 110, self.screenWidth / 2 - 20, "right")
    lg.printf("BEST: " .. self.bestScore, self.screenWidth / 2 + 20, 110, self.screenWidth / 2 - 20, "left")

    -- Instructions
    lg.setColor(1, 1, 1, 0.7)
    local smallFont = lg.newFont(14)
    lg.setFont(smallFont)
    lg.printf("Use ARROWS or WASD to move tiles", 0, self.screenHeight - 60, self.screenWidth, "center")
    lg.printf("Press R to restart • ESC for menu", 0, self.screenHeight - 40, self.screenWidth, "center")
end

local function reverseRows(self)
    for i = 1, self.gridSize do
        local newRow = {}
        for j = self.gridSize, 1, -1 do
            table_insert(newRow, self.grid[i][j])
        end
        self.grid[i] = newRow
    end
end

local function transpose(self)
    local newGrid = {}
    for i = 1, self.gridSize do
        newGrid[i] = {}
        for j = 1, self.gridSize do
            newGrid[i][j] = self.grid[j][i]
        end
    end
    self.grid = newGrid
end

local function moveLeft(self)
    local moved = false
    for i = 1, self.gridSize do
        local row = {}
        for j = 1, self.gridSize do
            if self.grid[i][j] ~= 0 then
                table_insert(row, self.grid[i][j])
            end
        end

        -- Merge tiles
        local mergedRow = {}
        local skip = false
        for j = 1, #row do
            if not skip and j < #row and row[j] == row[j + 1] then
                local mergedValue = row[j] * 2
                table_insert(mergedRow, mergedValue)
                self.score = self.score + mergedValue
                self.bestScore = math_max(self.bestScore, self.score)
                skip = true
            elseif not skip then
                table_insert(mergedRow, row[j])
            else
                skip = false
            end
        end

        -- Fill remaining spaces with zeros
        while #mergedRow < self.gridSize do table_insert(mergedRow, 0) end

        -- Check if row changed
        for j = 1, self.gridSize do
            if self.grid[i][j] ~= mergedRow[j] then
                moved = true
            end
            self.grid[i][j] = mergedRow[j]
        end
    end
    return moved
end

local function moveRight(self)
    -- Reverse, move left, then reverse back
    reverseRows(self)
    local moved = moveLeft(self)
    reverseRows(self)
    return moved
end

local function moveUp(self)
    transpose(self)
    local moved = moveLeft(self)
    transpose(self)
    return moved
end

local function moveDown(self)
    transpose(self)
    reverseRows(self)
    local moved = moveLeft(self)
    reverseRows(self)
    transpose(self)
    return moved
end

local Game = {}
Game.__index = Game

function Game.new()
    local instance = setmetatable({}, Game)

    instance.screenWidth = 600
    instance.screenHeight = 700
    instance.gridSize = 4
    instance.cellSize = 100
    instance.gridPadding = 10
    instance.animationSpeed = 0.15
    instance.time = 0

    resetGame(instance)

    return instance
end

function Game:update(dt)
    self.time = self.time + dt

    -- Update animations
    for i = #self.animations, 1, -1 do
        local anim = self.animations[i]
        anim.progress = anim.progress + dt / anim.duration

        if anim.progress >= 1 then
            table_remove(self.animations, i)
        end
    end
end

function Game:draw()
    drawUI(self)
    drawGrid(self)
    drawGameOver(self)
end

function Game:move(direction)
    if self.gameOver then return end

    local moved = false

    if direction == "left" then
        moved = moveLeft(self)
    elseif direction == "right" then
        moved = moveRight(self)
    elseif direction == "up" then
        moved = moveUp(self)
    elseif direction == "down" then
        moved = moveDown(self)
    end

    if moved then
        addRandomTile(self)
        checkGameOver(self)
        checkWin(self)
    end
end

function Game:setScreenSize(width, height)
    self.screenWidth = width
    self.screenHeight = height

    -- Adjust cell size based on screen size
    self.cellSize = math_min(100, (width - 100) / self.gridSize)
    self.gridPadding = math_max(5, self.cellSize / 10)
end

function Game:isGameOver() return self.gameOver end

function Game:startNewGame() resetGame(self) end

return Game
