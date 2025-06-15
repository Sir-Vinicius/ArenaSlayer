-- Player module - handles player movement, combat, and stats

local Player = {}
Player.__index = Player

function Player.new(x, y)
    local self = setmetatable({}, Player)

    -- Position and dimensions
    self.x = x
    self.y = y
    self.width = 40
    self.height = 40

    -- Movement
    self.speed = 200
    self.movingUp = false
    self.movingDown = false
    self.movingLeft = false
    self.movingRight = false

    -- Level
    self.xp = 0
    self.level = 1
    self.xpToNext = 10

    -- Touch input
    self.touchControlled = false

    -- Combat stats
    self.health = 100
    self.maxHealth = 100
    self.damage = 20
    self.invulnerabilityTimer = 0
    self.invulnerabilityDuration = 0.5 -- Invulnerable for 0.5 seconds after taking damage

    -- Inicializações necessárias para cartas
    self.regen = 0
    self.hasFireAura = false
    self.spawnShadow = false

    -- Appearance
    self.color = { 0.2, 0.6, 1 } -- Blue

    return self
end

function Player:update(dt, touchControls)
    -- Handle movement
    local dx, dy = 0, 0

    -- Handle keyboard input
    if self.movingUp then dy = dy - 1 end
    if self.movingDown then dy = dy + 1 end
    if self.movingLeft then dx = dx - 1 end
    if self.movingRight then dx = dx + 1 end

    -- Override with touch controls if active
    if touchControls and touchControls.active then
        self.touchControlled = true
        dx = touchControls.dx
        dy = touchControls.dy
    elseif self.touchControlled and touchControls then
        -- Reset touch controlled flag if no touch is active
        self.touchControlled = false
    end

    -- Normalize diagonal movement
    if dx ~= 0 and dy ~= 0 then
        local length = math.sqrt(dx * dx + dy * dy)
        dx = dx / length
        dy = dy / length
    end

    -- Apply movement
    self.x = self.x + dx * self.speed * dt
    self.y = self.y + dy * self.speed * dt

    -- Keep player within screen bounds
    self.x = math.max(0, math.min(love.graphics.getWidth() - self.width, self.x))
    self.y = math.max(0, math.min(love.graphics.getHeight() - self.height, self.y))

    -- Update invulnerability timer
    if self.invulnerabilityTimer > 0 then
        self.invulnerabilityTimer = self.invulnerabilityTimer - dt
    end
end

function Player:draw()
    -- Flash player when invulnerable
    if self.invulnerabilityTimer > 0 and math.floor(self.invulnerabilityTimer * 10) % 2 == 0 then
        love.graphics.setColor(0.8, 0.8, 0.8) -- Flash white
    else
        love.graphics.setColor(self.color)
    end

    -- Draw player as a rectangle
    love.graphics.rectangle("fill", self.x, self.y, self.width, self.height)

    -- Reset color
    love.graphics.setColor(1, 1, 1)
end

function Player:takeDamage(amount)
    -- Only take damage if not invulnerable
    if self.invulnerabilityTimer <= 0 then
        self.health = math.max(0, self.health - amount)
        self.invulnerabilityTimer = self.invulnerabilityDuration
    end
end

function Player:keypressed(key)
    -- Movement keys (supports both WASD and arrow keys)
    if key == "w" or key == "up" then
        self.movingUp = true
    end
    if key == "s" or key == "down" then
        self.movingDown = true
    end
    if key == "a" or key == "left" then
        self.movingLeft = true
    end
    if key == "d" or key == "right" then
        self.movingRight = true
    end
end

function Player:keyreleased(key)
    -- Stop movement when keys are released
    if key == "w" or key == "up" then
        self.movingUp = false
    end
    if key == "s" or key == "down" then
        self.movingDown = false
    end
    if key == "a" or key == "left" then
        self.movingLeft = false
    end
    if key == "d" or key == "right" then
        self.movingRight = false
    end
end

function Player:checkLevelUp()
    while self.xp >= self.xpToNext do
        self.xp = self.xp - self.xpToNext
        self.level = self.level + 1
        self.xpToNext = math.floor(self.xpToNext * 1.5)

        levelUp() -- call the card selection
    end
end

return Player
