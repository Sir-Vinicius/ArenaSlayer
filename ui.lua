-- UI module - handles game UI elements like health bar, score, etc.

local UI = {}
UI.__index = UI

-- Create fonts once to avoid creating new ones every frame
local healthFont = nil
local scoreFont = nil
local controlsFont = nil

function UI.new(player)
    local self = setmetatable({}, UI)
    
    -- Store reference to player for health monitoring
    self.player = player
    
    -- Create fonts only once
    if not healthFont then
        healthFont = love.graphics.newFont(14)
        scoreFont = love.graphics.newFont(18)
        controlsFont = love.graphics.newFont(12)
    end
    
    return self
end

function UI:draw(score)
    -- Draw health bar
    self:drawHealthBar()
    
    -- Draw score
    self:drawScore(score)
    
    -- Draw controls help
    self:drawControls()
end

function UI:drawHealthBar()
    -- Health bar background
    love.graphics.setColor(0.3, 0.3, 0.3)
    love.graphics.rectangle("fill", 20, 20, 200, 20)
    
    -- Health bar fill
    local healthPercentage = self.player.health / self.player.maxHealth
    love.graphics.setColor(1 - healthPercentage, healthPercentage, 0.2)
    love.graphics.rectangle("fill", 20, 20, 200 * healthPercentage, 20)
    
    -- Health text
    love.graphics.setColor(1, 1, 1)
    love.graphics.setFont(healthFont)
    love.graphics.print("HP: " .. math.floor(self.player.health) .. "/" .. self.player.maxHealth, 25, 22)
end

function UI:drawScore(score)
    -- Score display in top right
    love.graphics.setColor(1, 1, 1)
    love.graphics.setFont(scoreFont)
    love.graphics.print("Score: " .. score, love.graphics.getWidth() - 120, 20)
end

function UI:drawControls()
    -- On mobile, show touch controls info, otherwise keyboard controls
    love.graphics.setColor(0.8, 0.8, 0.8, 0.7)
    love.graphics.setFont(controlsFont)
    
    local msg = "Controls: WASD/Arrow Keys to move, Escape to quit"
    local isMobile = (love.system.getOS() == "Android" or love.system.getOS() == "iOS")
    
    if isMobile then
        msg = "Use the joystick in the bottom left to move"
    end
    
    love.graphics.printf(msg, 0, love.graphics.getHeight() - 30, love.graphics.getWidth(), "center")
end

return UI
