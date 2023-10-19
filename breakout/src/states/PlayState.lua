--[[
    PlayState Class

    Represents the state of the game in which we are actively playing
]]

PlayState = Class{__includes = BaseState}

function PlayState:enter(params)
    self.paddle = params.paddle
    self.bricks = params.bricks
    self.health = params.health
    self.score = params.score
    self.balls = params.balls
    self.level = params.level
    self.highScores = params.highScores
    self.powerups = params.powerups

    for k, ball in pairs(self.balls) do
        ball.dx = math.random(-200, 200)
        ball.dy = math.random(-50, -60)
    end

    self.paused = false
end

function PlayState:update(dt)
    if self.paused then
        if love.keyboard.wasPressed('space') then
            self.paused = false
            gSounds['pause']:play()
        else
            return
        end
    elseif love.keyboard.wasPressed('space') then
        self.paused = true
        gSounds['pause']:play()
        return
    end

    self.paddle:update(dt)
    for k, ball in pairs(self.balls) do
        ball:update(dt)

        if ball:collides(self.paddle) then
            ball.y = self.paddle.y - ball.height
            ball.dy = -ball.dy

            -- tweak the angle of bounce based on where it hits the paddle
            if ball.x < self.paddle.x + (self.paddle.width / 2) and self.paddle.dx < 0 then
                ball.dx = -50 + -(8 * (self.paddle.x + self.paddle.width / 2 - ball.x))
            elseif ball.x > self.paddle.x + (self.paddle.width / 2) and self.paddle.x > 0 then
                ball.dx = 50 + (8 * math.abs(self.paddle.x + self.paddle.width / 2 - ball.x))
            end


            gSounds['paddle-hit']:play()
        end
    
        for k, brick in pairs(self.bricks) do
            if brick.inPlay and ball:collides(brick) then
                brick:hit()

                self.score = self.score + (brick.tier * 200 + brick.color * 25)

                if self:checkVictory() then
                    gSounds['victory']:play()

                    gStateMachine:change('victory', {
                        level = self.level,
                        paddle = self.paddle,
                        health = self.health,
                        score = self.score,
                        balls = self.balls,
                        highScores = self.highScores
                    })
                end

                if math.random(1, 10) < 11 then
                    local power = math.random(1,5) <= 4 and 9 or 3
                    table.insert(self.powerups, Powerup(ball.x - 4, ball.y - 4, power))
                end


                -- collision code for bricks
                -- check left edge if we are moving right
                if ball.x + 2 < brick.x and ball.dx > 0 then
                    ball.dx = -ball.dx
                    ball.x = brick.x - 8
                -- check right edge if we are moving left
                elseif ball.x + 6 > brick.x + brick.width and ball.dx < 0 then
                    ball.dx = - ball.dx
                    ball.x = brick.x + 32
                -- check top edge (always check)
                elseif ball.y < brick.y then
                    ball.dy = -ball.dy
                    ball.y = brick.y - 8
                -- check bottom edge (only remaining possiblity)
                else
                    ball.dy = -ball.dy
                    ball.y = brick.y + 16
                end

                -- slowly accelerate ball
                ball.dy = ball.dy * 1.02

                -- only allow one collision per frame
                break
            end
        end
    end

    for k, powerup in pairs(self.powerups) do
        if powerup:collides(self.paddle) then
            if powerup.ability == 3 and self.health < 3 then
                self.health = self.health + 1
            elseif powerup.ability == 9 then
                table.insert(self.balls, Ball())
                self.balls[#self.balls].skin = math.random(7)
                self.balls[#self.balls].x = self.paddle.x + (self.paddle.width / 2) - 4
                self.balls[#self.balls].y = self.paddle.y - 8
                self.balls[#self.balls].dx = math.random(-200, 200)
                self.balls[#self.balls].dy = math.random(-50, -60)
            end
            table.remove(self.powerups, k)
        end
        if powerup.y > VIRTUAL_HEIGHT then
            table.remove(self.powerups, k)
        end
    end


    -- handle losing a life (i.e. ball going below the paddle)
    for k, ball in pairs(self.balls) do
        if ball.y >= VIRTUAL_HEIGHT then
            if #self.balls > 1 then
                
                table.remove(self.balls, k)
            else
                self.health = self.health - 1
                if self.health == 0 then
                    gStateMachine:change('game-over', {
                        score = self.score,
                        highScores = self.highScores
                    })
                else
                    gStateMachine:change('serve', {
                        paddle = self.paddle,
                        bricks = self.bricks,
                        health = self.health,
                        score = self.score,
                        level = self.level,
                        highScores = self.highScores,
                        powerups = self.powerups
                    })
                end
            gSounds['hurt']:stop()
            gSounds['hurt']:play()
            end
        end
    end

    for k, brick in pairs(self.bricks) do
        brick:update(dt)
    end

    if love.keyboard.wasPressed('escape') then
        love.event.quit()
    end

    for k, powerup in pairs(self.powerups) do
        powerup:update(dt)
    end
end

function PlayState:checkVictory()
    for k, brick in pairs(self.bricks) do
        if brick.inPlay then
            return false
        end
    end

    return true
end

function PlayState:render()
    self.paddle:render()
    for k, ball in pairs(self.balls) do
        ball:render()
    end

    for k, brick in pairs(self.bricks) do
        brick:render()
    end

    for k, brick in pairs(self.bricks) do
        brick:renderParticles()
    end

    for k, powerup in pairs(self.powerups) do
        powerup:render()
    end

    renderScore(self.score)
    renderHealth(self.health)


    if self.paused then
        love.graphics.setFont(gFonts['large'])
        love.graphics.printf('PAUSED', 0, VIRTUAL_HEIGHT / 2 - 16, VIRTUAL_WIDTH, 'center')
    end
end