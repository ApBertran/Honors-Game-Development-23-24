Powerup = Class{}

function Powerup:init(x, y)
    self.x = x
    self.y = y
    self.width = 14
    self.height = 14
    self.alive = true
end

--[[
    Expects a paddle as an argument and return true or false based on AABB collision detection
]]
function Powerup:collides(ball)
    if self.x > ball.x + ball.width or ball.x > self.x + self.width then
        return false
    end
    if self.y > ball.y + ball.height or ball.y > self.y + self.height then
        return false
    end

    return true
end

function Powerup:isAlive()
    return self.alive
end

--[[
    Applies a powerup to the given paddle object based on the given string 'ability'
]]
function Powerup:Ability(paddle, ability)
    if ability == 'big' and paddle.height < 40 then
        paddle.height = paddle.height + 4
    elseif ability == 'small' and paddle.height > 10 then
        paddle.height = paddle.height - 2
    elseif ability == 'slow' then
        paddle.speed = 150
    end
end

function Powerup:render()
    love.graphics.rectangle('fill', self.x, self.y, self.width, self.height)
end