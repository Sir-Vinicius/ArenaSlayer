-- Main entry point for the top-down arena RPG game
-- Handles core game loop and initialization

-- Load required modules
local Game = require('game')

-- Global variables
local game

-- LÖVE initialization function
function love.load()
    -- Set up the window
    love.window.setTitle("Arena RPG")
    
    -- Make the window resizable for better mobile compatibility
    love.window.setMode(800, 600, {resizable = true})
    
    -- Initialize random seed
    math.randomseed(os.time())
    
    player = require("player")
    -- call cards 
    require("cards")
    levelUp()
    
    -- Initialize game
    game = Game.new()
    game:load()
end

-- LÖVE update function - called every frame
function love.update(dt)
    -- dt is the time elapsed since the last update (delta time)
    game:update(dt)
end

-- LÖVE draw function - called after update
function love.draw()
    game:draw()
end

-- Handle keyboard input
function love.keypressed(key)
    -- Quit game with escape key
    if key == "escape" then
        love.event.quit()
    end
    
    -- Pass key presses to game
    game:keypressed(key)
end

-- Handle key releases
function love.keyreleased(key)
    game:keyreleased(key)
end

-- Handle touch press events for mobile devices
function love.touchpressed(id, x, y, dx, dy, pressure)
    -- Pass touch events to game's touch controls
    if game and game.touchControls then
        game.touchControls:touchPressed(id, x, y)
    end
end

-- Handle touch movement events
function love.touchmoved(id, x, y, dx, dy, pressure)
    -- Pass touch movement to game's touch controls
    if game and game.touchControls then
        game.touchControls:touchMoved(id, x, y)
    end
end

-- Handle touch release events
function love.touchreleased(id, x, y, dx, dy, pressure)
    -- Pass touch release to game's touch controls
    if game and game.touchControls then
        game.touchControls:touchReleased(id, x, y)
    end
end

-- Handle mouse press as touch for testing on desktop
function love.mousepressed(x, y, button)
    if button == 1 then -- Left mouse button
        -- Simulate touch for testing on desktop
        if game and game.touchControls then
            game.touchControls:touchPressed(1, x, y)
        end
    end
    if showCardSelection then
    for i, card in ipairs(cardChoices) do
        if x > 100 and x < 500 and y > i * 120 and y < i * 120 + 100 then
            card.apply(player)
            table.insert(selectedCards, card.id)
            showCardSelection = false
            break
        end
    end
    end
end

-- Handle mouse movement as touch for testing on desktop
function love.mousemoved(x, y, dx, dy)
    -- Simulate touch movement for testing on desktop
    if love.mouse.isDown(1) and game and game.touchControls then
        game.touchControls:touchMoved(1, x, y)
    end
end

-- Handle mouse release as touch for testing on desktop
function love.mousereleased(x, y, button)
    if button == 1 then -- Left mouse button
        -- Simulate touch release for testing on desktop
        if game and game.touchControls then
            game.touchControls:touchReleased(1, x, y)
        end
    end
end

function love.mousepressed(x, y, button)
    game:mousepressed(x, y, button)
end
