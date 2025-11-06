-- Exponentia Game - Love2D
-- License: MIT
-- Copyright (c) 2025 Jericho Crosby (Chalwk)

local math_min = math.min
local lg = love.graphics

local Game = require("classes.Game")
local Menu = require("classes.Menu")
local BackgroundManager = require("classes.BackgroundManager")

local game, menu, backgroundManager
local screenWidth, screenHeight
local gameState = "menu"
local stateTransition = { alpha = 0, duration = 0.5, timer = 0, active = false }

local function updateScreenSize()
    screenWidth = lg.getWidth()
    screenHeight = lg.getHeight()
end

local function startStateTransition(newState)
    stateTransition = {
        alpha = 0,
        duration = 0.3,
        timer = 0,
        active = true,
        targetState = newState
    }
end

function love.load()
    lg.setDefaultFilter("nearest", "nearest")
    lg.setLineStyle("smooth")

    game = Game.new()
    menu = Menu.new()
    backgroundManager = BackgroundManager.new()

    updateScreenSize()
    menu:setScreenSize(screenWidth, screenHeight)
    game:setScreenSize(screenWidth, screenHeight)
end

function love.update(dt)
    updateScreenSize()

    -- Handle state transitions
    if stateTransition.active then
        stateTransition.timer = stateTransition.timer + dt
        stateTransition.alpha = math_min(stateTransition.timer / stateTransition.duration, 1)

        if stateTransition.timer >= stateTransition.duration then
            gameState = stateTransition.targetState
            stateTransition.active = false
            stateTransition.alpha = 0
        end
    end

    if gameState == "menu" then
        menu:update(dt, screenWidth, screenHeight)
    elseif gameState == "playing" then
        game:update(dt)
    end

    backgroundManager:update(dt)
end

function love.draw()
    local time = love.timer.getTime()
    -- Draw background based on state
    if gameState == "menu" then
        backgroundManager:drawMenuBackground(screenWidth, screenHeight, time)
    elseif gameState == "playing" then
        backgroundManager:drawGameBackground(screenWidth, screenHeight, time)
    end

    -- Draw game content
    if gameState == "menu" then
        menu:draw(screenWidth, screenHeight)
    elseif gameState == "playing" then
        game:draw()
    end

    -- Draw transition overlay
    if stateTransition.active then
        lg.setColor(0, 0, 0, stateTransition.alpha)
        lg.rectangle("fill", 0, 0, screenWidth, screenHeight)
    end
end

function love.mousepressed(x, y, button, istouch)
    if button == 1 then
        if gameState == "menu" then
            local action = menu:handleClick(x, y)
            if action == "start" then
                startStateTransition("playing")
                game:startNewGame()
            elseif action == "quit" then
                love.event.quit()
            end
        elseif gameState == "playing" then
            if game:isGameOver() then
                startStateTransition("menu")
            end
        end
    end
end

function love.keypressed(key)
    if key == "escape" then
        if gameState == "playing" then
            startStateTransition("menu")
        else
            love.event.quit()
        end
    elseif key == "f11" then
        local fullscreen = love.window.getFullscreen()
        love.window.setFullscreen(not fullscreen)
    elseif gameState == "playing" and not game:isGameOver() then
        if key == "up" or key == "w" then
            game:move("up")
        elseif key == "down" or key == "s" then
            game:move("down")
        elseif key == "left" or key == "a" then
            game:move("left")
        elseif key == "right" or key == "d" then
            game:move("right")
        elseif key == "r" then
            game:startNewGame()
        end
    end
end

function love.resize(w, h)
    updateScreenSize()
    menu:setScreenSize(screenWidth, screenHeight)
    game:setScreenSize(screenWidth, screenHeight)
end
