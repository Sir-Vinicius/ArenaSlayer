-- Enemy module - handles enemy behavior, combat, and stats

local Enemy = {}
Enemy.__index = Enemy

-- Shared color for all enemies to reduce memory usage
local baseEnemyColor = {0.9, 0.3, 0.3} -- Red

function Enemy.new(x, y)
    local self = setmetatable({}, Enemy)
    
    -- Position and dimensions
    self.x = x
    self.y = y
    self.width = 30
    self.height = 30
    
    -- Movement
    self.speed = 80 -- Fixed speed for better performance
    
    -- Combat stats
    self.health = 40
    self.maxHealth = 40
    self.damage = 10
    
    -- Use shared color instead of creating a new table for each enemy
    self.color = baseEnemyColor
    
    return self
end

function Enemy:update(dt, player)
    -- Simple AI: follow the player
    local dx = player.x - self.x
    local dy = player.y - self.y
    
    -- Calculate direction to player
    local length = math.sqrt(dx * dx + dy * dy)
    
    -- Prevent division by zero and only move if not too close
    if length > 2 then
        dx = dx / length
        dy = dy / length
        
        -- Move towards player
        self.x = self.x + dx * self.speed * dt
        self.y = self.y + dy * self.speed * dt
    end
end

function Enemy:draw()
    -- Only draw if on screen (optimization)
    local screenWidth = love.graphics.getWidth()
    local screenHeight = love.graphics.getHeight()
    
    if self.x < -50 or self.y < -50 or 
       self.x > screenWidth + 50 or self.y > screenHeight + 50 then
        return
    end
    
    -- Draw health bar (a thin red bar above the enemy)
    local healthPercentage = self.health / self.maxHealth
    love.graphics.setColor(0.7, 0, 0)
    love.graphics.rectangle("fill", self.x, self.y - 8, self.width * healthPercentage, 5)
    
    -- Draw enemy
    love.graphics.setColor(self.color)
    love.graphics.rectangle("fill", self.x, self.y, self.width, self.height)
    
    -- Reset color
    love.graphics.setColor(1, 1, 1)
end

function Enemy:takeDamage(amount)
    self.health = math.max(0, self.health - amount)
end

return Enemy
