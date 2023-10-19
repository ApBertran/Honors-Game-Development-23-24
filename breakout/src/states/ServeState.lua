ServeState = Class{__includes = BaseState}

function ServeState:enter(params)
    self.paddle = params.paddle
    self.bricks = params.bricks
    self.health = params.health
    self.score = params.score
    self.level = params.level
    self.highScores = params.highScores
    self.powerups = {}

    self.balls = {}
    table.insert(self.balls, Ball())
    self.balls[1].skin = math.random(7)
end

function ServeState:update(dt)
    self.paddle:update(dt)
    self.balls[1].x = self.paddle.x + (self.paddle.width / 2) - 4
    self.balls[1].y = self.paddle.y - 8

    if love.keyboard.wasPressed('enter') or love.keyboard.wasPressed('return') then
        gStateMachine:change('play', {
            paddle = self.paddle,
            bricks = self.bricks,
            health = self.health,
            score = self.score,
            balls = self.balls,
            level = self.level,
            highScores = self.highScores,
            powerups = self.powerups
        })
    end

    if love.keyboard.wasPressed('escape') then
        love.event.quit()
    end
end

function ServeState:render()
    self.paddle:render()
    self.balls[1]:render()

    for k, brick in pairs(self.bricks) do
        brick:render()
    end

    renderScore(self.score)
    renderHealth(self.health)


    love.graphics.setFont(gFonts['medium'])
    love.graphics.printf('Press Enter to serve!', 0, VIRTUAL_HEIGHT / 2, VIRTUAL_WIDTH, 'center')

    love.graphics.setFont(gFonts['large'])
    love.graphics.printf('Level '..tostring(self.level), 0, VIRTUAL_HEIGHT / 3, VIRTUAL_WIDTH, 'center')
end