ScoreState = Class{__includes = BaseState}

bronze = love.graphics.newImage('bronze.png')
silver = love.graphics.newImage('silver.png')
gold = love.graphics.newImage('gold.png')


function ScoreState:enter(params)
    self.score = params.score
end

function ScoreState:update(dt)
    GROUND_SCROLL_SPEED = 130
    BACKGROUND_SCROLL_SPEED = 30
    PIPE_SPEED = 130
    spawnRate = 2

    if love.keyboard.wasPressed('enter') or love.keyboard.wasPressed('return') then
        gStateMachine:change('countdown')
    end
end

function ScoreState:render()
    love.graphics.setFont(flappyFont)
    love.graphics.printf('Game Over', 0, 64, VIRTUAL_WIDTH, 'center')

    love.graphics.setFont(mediumFont)
    love.graphics.printf('Score: '.. tostring(self.score), 0, 100, VIRTUAL_WIDTH, 'center')

    love.graphics.printf('Press Enter to Play Again!', 0, 160, VIRTUAL_WIDTH, 'center')
    if self.score >= 5 and self.score < 10 then
        love.graphics.draw(bronze, 250, 130)
    elseif self.score >= 10 and self.score < 20 then
        love.graphics.draw(bronze, 225, 130)
        love.graphics.draw(silver, 275, 130)
    elseif self.score >= 20 then
        love.graphics.draw(bronze, 200, 130)
        love.graphics.draw(silver, 250, 130)
        love.graphics.draw(gold, 300, 130)
    end
end