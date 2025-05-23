-- Touch controls module - handles smartphone touchscreen input

local TouchControls = {}
TouchControls.__index = TouchControls

-- Predefined joystick colors for reuse (optimization)
local joystickBaseColor = {0.5, 0.5, 0.5, 0.5}
local joystickKnobColor = {0.8, 0.8, 0.8, 0.8}

function TouchControls.new()
    local self = setmetatable({}, TouchControls)
    
    -- Define virtual joystick properties
    self.joystickRadius = 60  -- Smaller radius for better performance
    self.joystickX = 100
    self.joystickY = love.graphics.getHeight() - 100
    
    -- Current state of joystick
    self.active = false
    self.touchX = 0
    self.touchY = 0
    
    -- Movement directions (will be used by player)
    self.dx = 0
    self.dy = 0
    
    -- Screen dimensions for responsive layout
    self.screenWidth = love.graphics.getWidth()
    self.screenHeight = love.graphics.getHeight()
    
    -- For desktop testing, always show controls
    self.alwaysShow = true
    
    return self
end

function TouchControls:update()
    -- Update joystick position based on screen dimensions
    -- This ensures controls stay in correct position if window resizes
    self.joystickY = love.graphics.getHeight() - 100
    self.screenWidth = love.graphics.getWidth()
    self.screenHeight = love.graphics.getHeight()
end

function TouchControls:draw()
    -- Always show controls for testing on desktop
    local os = love.system.getOS()
    if not self.alwaysShow and not (os == "Android" or os == "iOS") then
        return
    end
    
    -- Draw joystick base
    love.graphics.setColor(joystickBaseColor)
    love.graphics.circle("fill", self.joystickX, self.joystickY, self.joystickRadius)
    
    -- Draw joystick knob
    if self.active then
        love.graphics.setColor(joystickKnobColor)
        
        -- Calculate joystick knob position
        local knobX, knobY = self:getConstrainedJoystickPosition()
        love.graphics.circle("fill", knobX, knobY, self.joystickRadius / 2)
    end
    
    -- Reset color
    love.graphics.setColor(1, 1, 1)
end

function TouchControls:getConstrainedJoystickPosition()
    -- Calculate distance from center
    local dx = self.touchX - self.joystickX
    local dy = self.touchY - self.joystickY
    local distance = math.sqrt(dx * dx + dy * dy)
    
    -- Constrain joystick movement to radius
    if distance > self.joystickRadius then
        local angle = math.atan2(dy, dx)
        return self.joystickX + math.cos(angle) * self.joystickRadius,
               self.joystickY + math.sin(angle) * self.joystickRadius
    else
        return self.touchX, self.touchY
    end
end

function TouchControls:touchPressed(id, x, y)
    -- Only handle touches near joystick area
    local distance = math.sqrt((x - self.joystickX)^2 + (y - self.joystickY)^2)
    if distance <= self.joystickRadius * 1.5 then
        self.active = true
        self.touchX = x
        self.touchY = y
        self:updateDirections()
    end
end

function TouchControls:touchMoved(id, x, y)
    if self.active then
        self.touchX = x
        self.touchY = y
        self:updateDirections()
    end
end

function TouchControls:touchReleased(id, x, y)
    if self.active then
        self.active = false
        self.dx = 0
        self.dy = 0
    end
end

function TouchControls:updateDirections()
    -- Calculate direction vector
    local dx = self.touchX - self.joystickX
    local dy = self.touchY - self.joystickY
    
    -- Normalize the vector
    local length = math.sqrt(dx * dx + dy * dy)
    if length > 0 then
        self.dx = dx / length
        self.dy = dy / length
    else
        self.dx = 0
        self.dy = 0
    end
end

-- Check if we're running on a mobile device
function TouchControls:isMobile()
    local os = love.system.getOS()
    return os == "Android" or os == "iOS"
end

return TouchControls