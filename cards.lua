-- cards.lua
local cards = {}

cards.list = {
    {
        id = "fire_aura",
        name = "Aura Flamejante",
        description = "Cria uma aura de fogo ao seu redor.",
        apply = function(player)
            player.hasFireAura = true
        end
    },
    {
        id = "speed_up",
        name = "Aceleração",
        description = "Aumenta sua velocidade em 20%.",
        apply = function(player)
            player.speed = player.speed * 1.2
        end
    },
    {
        id = "shadow_copy",
        name = "Cópia Sombria",
        description = "Cria uma sombra que copia seus ataques por 10s.",
        apply = function(player)
            player.spawnShadow = true
        end
    },
    {
        id = "life_regen",
        name = "Regeneração",
        description = "Regenera 1 de vida por segundo.",
        apply = function(player)
            player.regen = player.regen + 2
        end
    }
}

function cards:getRandom(n)
    local pool = {}
    local used = {}
    while #pool < n do
        local index = love.math.random(1, #self.list)
        if not used[index] then
            table.insert(pool, self.list[index])
            used[index] = true
        end
    end
    return pool
end

return cards