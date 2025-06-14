-- Game module - handles game state, enemies, and overall game logic

local Player = require('player')
local Enemy = require('enemy')
local UI = require('ui')
local TouchControls = require('touch_controls')
local cards = require("cards")
local selectedCards = {}
local showCardSelection = false
local cardChoices = {}

function levelUp()
    showCardSelection = true
    cardChoices = cards:getRandom(3)
end

local Game = {}
Game.__index = Game

-- Game states
local GAME_STATE = {
    PLAY = 1,
    GAME_OVER = 2
}

-- Create a new game instance
function Game.new()
    local self = setmetatable({}, Game)
    
    -- Game properties
    self.state = GAME_STATE.PLAY
    self.enemies = {}
    self.enemySpawnTimer = 0
    self.enemySpawnInterval = 3 -- Spawn enemy every 3 seconds
    self.score = 0
    self.maxEnemies = 10 -- Limit maximum enemies for performance
    
    -- Touch detection
    self.isMobile = (love.system.getOS() == "Android" or love.system.getOS() == "iOS")
    
    return self
end

-- Initialize game objects
function Game:load()
    -- Create player
    self.player = Player.new(400, 300) -- Start at the center of the screen
    
    -- Create UI
    self.ui = UI.new(self.player)
    
    -- Create touch controls
    self.touchControls = TouchControls.new()
    
    -- Initial enemies
    self:spawnEnemy()
end

-- Update game state
function Game:update(dt)
    if self.state == GAME_STATE.PLAY then
        -- Update touch controls
        self.touchControls:update()
        
        -- Update player with touch controls
        self.player:update(dt, self.touchControls)
        
        -- Enemy spawning logic
        self.enemySpawnTimer = self.enemySpawnTimer + dt
        if self.enemySpawnTimer >= self.enemySpawnInterval then
            self:spawnEnemy()
            self.enemySpawnTimer = 0
            
            -- Make the game progressively harder by reducing spawn interval
            -- but not below 1 second
            self.enemySpawnInterval = math.max(1, self.enemySpawnInterval * 0.95)
        end
        
        -- Update enemies
        for i, enemy in ipairs(self.enemies) do
            enemy:update(dt, self.player)
            
            -- Check for collisions between player and enemies
            if self:checkCollision(self.player, enemy) then
                -- Player and enemy take damage
                self.player:takeDamage(enemy.damage)
                enemy:takeDamage(self.player.damage, self.player)
                
                -- Remove dead enemies
                if enemy.health <= 0 then
                    table.remove(self.enemies, i)
                    self.score = self.score + 1
                end
            end
        end
        
        -- Check if player is dead
        if self.player.health <= 0 then
            self.state = GAME_STATE.GAME_OVER
        end
    end
    
    -- Regeneração
    if self.player.regen and self.player.regen > 0 then
        self.player.health = math.min(self.player.health + self.player.regen * dt, self.player.maxHealth)
    end

    -- Aura flamejante (exemplo simples de dano em inimigos próximos)
    if self.player.hasFireAura then
        for _, enemy in ipairs(self.enemies) do
            local dx = enemy.x - self.player.x
            local dy = enemy.y - self.player.y
            local dist = math.sqrt(dx * dx + dy * dy)
            if dist < 40 then
                enemy:takeDamage(5 * dt)
            end
        end
    end
    
end

-- Draw the game
function Game:draw()
    if self.state == GAME_STATE.PLAY then
        -- Draw player
        self.player:draw()
        
        -- Draw enemies
        for _, enemy in ipairs(self.enemies) do
            enemy:draw()
        end
        
        -- Draw UI
        self.ui:draw(self.score)
        
        -- Draw touch controls (only visible on mobile)
        self.touchControls:draw()
    elseif self.state == GAME_STATE.GAME_OVER then
        -- Draw game over screen
        self:drawGameOver()
    end
    if showCardSelection then
    for i, card in ipairs(cardChoices) do
      local y = 150 + (i - 1) * 130
      love.graphics.rectangle("line", 100, i * 120, 400, 100)
        love.graphics.print(card.name, 120, i * 120 + 10)
        love.graphics.print(card.description, 120, i * 120 + 40)
    end
end

-- Draw XP info 
love.graphics.print("XP: " .. self.player.xp .. " / " .. self.player.xpToNext, 10, 10)
love.graphics.print("Nível: " .. self.player.level, 10, 30)

for i, card in ipairs(selectedCards) do
    love.graphics.print("- " .. card.name, 10, 50 + i * 20)
end

end

-- Check collision between two entities (using simple rectangle collision)
function Game:checkCollision(a, b)
    return a.x < b.x + b.width and
           a.x + a.width > b.x and
           a.y < b.y + b.height and
           a.y + a.height > b.y
end

-- Spawn new enemy at random location near the edges
function Game:spawnEnemy()
    -- Check if we're at maximum enemies for performance
    if #self.enemies >= self.maxEnemies then
        return
    end
    
    -- Determine spawn location (from one of the four edges)
    local x, y
    local side = math.random(1, 4)
    
    if side == 1 then -- Top
        x = math.random(50, 750)
        y = -20
    elseif side == 2 then -- Right
        x = 820
        y = math.random(50, 550)
    elseif side == 3 then -- Bottom
        x = math.random(50, 750)
        y = 620
    else -- Left
        x = -20
        y = math.random(50, 550)
    end
    
    -- Create enemy and add to list
    local enemy = Enemy.new(x, y)
    table.insert(self.enemies, enemy)
end

-- Draw game over screen
function Game:drawGameOver()
    love.graphics.setColor(0, 0, 0, 0.7)
    love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), love.graphics.getHeight())
    
    love.graphics.setColor(1, 0, 0)
    love.graphics.setFont(love.graphics.newFont(48))
    love.graphics.printf("GAME OVER", 0, 200, love.graphics.getWidth(), "center")
    
    love.graphics.setColor(1, 1, 1)
    love.graphics.setFont(love.graphics.newFont(24))
    love.graphics.printf("Final Score: " .. self.score, 0, 280, love.graphics.getWidth(), "center")
    love.graphics.printf("Press 'R' to restart", 0, 320, love.graphics.getWidth(), "center")
    
    -- Reset color
    love.graphics.setColor(1, 1, 1)
end

-- Handle key presses
function Game:keypressed(key)
    if self.state == GAME_STATE.GAME_OVER and key == "r" then
        -- Restart the game
        self:reset()
    end
    
    -- Pass key press to player
    if self.state == GAME_STATE.PLAY then
        self.player:keypressed(key)
    end
end

-- Handle key releases
function Game:keyreleased(key)
    if self.state == GAME_STATE.PLAY then
        self.player:keyreleased(key)
    end
end

-- Reset game to initial state
function Game:reset()
    self.state = GAME_STATE.PLAY
    self.enemies = {}
    self.enemySpawnTimer = 0
    self.enemySpawnInterval = 3
    self.score = 0
    
    -- Create new player
    self.player = Player.new(400, 300)
    
    -- Update UI reference
    self.ui = UI.new(self.player)
    
    -- Initial enemies
    self:spawnEnemy()
    self:spawnEnemy()
end

function Game:mousepressed(x, y, button)
    if showCardSelection and button == 1 then
        for i, card in ipairs(cardChoices) do
            local cardX, cardY = 100, i * 120
            local cardWidth, cardHeight = 400, 100

            if x >= cardX and x <= cardX + cardWidth and y >= cardY and y <= cardY + cardHeight then
                -- Aplica o efeito da carta no player
                card.apply(self.player)
                
                -- Armazena como carta escolhida
                table.insert(selectedCards, card)
                
                -- Fecha a seleção
                showCardSelection = false
                
                break
            end
        end
    end
end

return Game
