--[[
    GD50
    Match-3 Remake

    -- Tile Class --

    Author: Colton Ogden
    cogden@cs50.harvard.edu

    The individual tiles that make up our game board. Each Tile can have a
    color and a variety, with the varietes adding extra points to the matches.
]]

Tile = Class{}

local paletteColors = {
    -- blue
    [1] = {
        ['r'] = 99,
        ['g'] = 155,
        ['b'] = 255
    },
    -- green
    [2] = {
        ['r'] = 106,
        ['g'] = 190,
        ['b'] = 47
    },
    -- red
    [3] = {
        ['r'] = 217,
        ['g'] = 87,
        ['b'] = 99
    },
    -- purple
    [4] = {
        ['r'] = 215,
        ['g'] = 123,
        ['b'] = 186
    },
    -- gold
    [5] = {
        ['r'] = 251,
        ['g'] = 242,
        ['b'] = 52
    },
    -- white
    [6] = {
        ['r'] = 255,
        ['g'] = 255,
        ['b'] = 255
    }
}

math.randomseed(os.clock())

function Tile:init(x, y, color, variety)
    
    -- board positions
    self.gridX = x
    self.gridY = y

    -- coordinate positions
    self.x = (self.gridX - 1) * 32
    self.y = (self.gridY - 1) * 32

    self.particleX = 0
    self.particleY = 0

    -- tile appearance/points
    self.color = color
    self.variety = variety

    if self.color == 1 or self.color == 3 or self.color == 10 or self.color == 12 then
        self.Pcolor = 5
    elseif self.color == 2 or self.color == 4 or self.color == 6 or self.color == 8 then
        self.Pcolor = 3
    elseif self.color == 5 or self.color == 7 or self.color == 9 then
        self.Pcolor = 2
    elseif self.color == 11 or self.color == 13 then
        self.Pcolor = 1
    elseif self.color == 15 or self.color == 17 then
        self.Pcolor = 4
    else
        self.Pcolor = 6
    end

    self.psystem = love.graphics.newParticleSystem(gTextures['particle'], 64)

    self.psystem:setParticleLifetime(0.5, 1.5)
    self.psystem:setLinearAcceleration(-15, 0, 15, 40)
    self.psystem:setEmissionArea('borderrectangle', 5, 5)

    self.spawn = math.random(0,0.5)
end

function Tile:update(dt)
    self.psystem:update(dt)
end

function Tile:render(x, y)
    
    -- draw shadow
    love.graphics.setColor(34, 32, 52, 255)
    love.graphics.draw(gTextures['main'], gFrames['tiles'][self.color][self.variety],
        self.x + x + 2, self.y + y + 2)

    -- draw tile itself
    love.graphics.setColor(255, 255, 255, 255)
    love.graphics.draw(gTextures['main'], gFrames['tiles'][self.color][self.variety],
        self.x + x, self.y + y)
    love.graphics.draw(self.psystem, self.x + x + 16, self.y + y + 16)

    self.particleX = self.x + x + 16
    self.particleY = self.y + y + 16
end

function Tile:match()
    local nextColor = self.Pcolor - 1
    if nextColor == 0 then 
        nextColor = 6
    end
    self.psystem:setColors(
        paletteColors[self.Pcolor].r / 255,
        paletteColors[self.Pcolor].g / 255,
        paletteColors[self.Pcolor].b / 255,
        200,
        paletteColors[nextColor].r / 255,
        paletteColors[nextColor].g / 255,
        paletteColors[nextColor].b / 255,
        0
    )
    self.psystem:emit(256)
    return {self.psystem, self.particleX, self.particleY}
end