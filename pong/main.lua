-- special abilities idea: wider paddle , shrink paddle, slow or fast ball, invert controls
-- make special abilities fade in

-- push is a library that will allow us to draw our game at a virtual
-- resolution, instead of however large our window is; used to provide
-- a more retro aesthetic
--
-- https://github.com/Ulydev/push
push = require 'push'

-- the "Class" library we're using will allow us to represent anything in
-- our game as code, rather than keeping track of many disparate variables and
-- methods
--
-- https://github.com/vrld/hump/blob/master/class.lua
Class = require 'class'

-- our Paddle class, which stores position and dimensions for each Paddle
-- and the logic for rendering them
require 'Paddle'

-- our Ball class, which isn't much different than a Paddle structure-wise
-- but which will mechanically function very differently
require 'Ball'

require 'Powerup'

WINDOW_WIDTH = 1280
WINDOW_HEIGHT = 720

VIRTUAL_WIDTH = 432
VIRTUAL_HEIGHT = 243

-- speed at which we will move our paddle; multiplied by dt in update
PADDLE_SPEED = 200

--[[
    Runs when the game first starts up, only once; used to initialize the game.
]]
function love.load()
    love.graphics.setDefaultFilter('nearest', 'nearest')

    -- set the title of the window
    love.window.setTitle('Pong')

    -- "seed" the RNG so that calls to random are always random
    -- use the current time, since that will vary on startup every time
    math.randomseed(os.time())

    -- more "retro-looking" font object we can use for any text
    smallFont = love.graphics.newFont('font.ttf', 8)
    largeFont = love.graphics.newFont('font.ttf', 16)
    scoreFont = love.graphics.newFont('font.ttf', 32)

    -- set LÖVE2D's active font to the smallFont object
    love.graphics.setFont(smallFont)

    -- load sound effects into memory
    sounds = {
        ['paddle_hit'] = love.audio.newSource('sounds/paddle_hit.wav', 'static'),
        ['score'] = love.audio.newSource('sounds/score.wav', 'static'),
        ['wall_hit'] = love.audio.newSource('sounds/wall_hit.wav', 'static'),
        ['victory'] = love.audio.newSource('sounds/victory.wav', 'static'),
        ['grow'] = love.audio.newSource('sounds/grow.wav', 'static'),
        ['shrink'] = love.audio.newSource('sounds/shrink.wav', 'static'),
        ['slow'] = love.audio.newSource('sounds/slow.wav', 'static')
    }

    powerups = {}
    playerCount = 1

    -- initialize window with virtual resolution
    push:setupScreen(VIRTUAL_WIDTH, VIRTUAL_HEIGHT, WINDOW_WIDTH, WINDOW_HEIGHT, {
        fullscreen = false,
        resizable = true,
        vsync = true
    })

    -- initialize score variables
    player1Score = 0
    player2Score = 0

    -- track serving player
    servingPlayer = 1

    -- initialize player hit-tracking variable
    lastHit = 0

    -- initialize our player paddles; make them global so that they can be
    -- detected by other functions and modules
    player1 = Paddle(10, 30, 5, 20, 200)
    player2 = Paddle(VIRTUAL_WIDTH - 15, VIRTUAL_HEIGHT - 30, 5, 20, 200)

    -- place a ball in the middle of the screen
    ball = Ball(VIRTUAL_WIDTH / 2 - 2, VIRTUAL_HEIGHT / 2 - 2, 4, 4)

    -- game state variable used to transition between different parts of the game
    -- (used for beginning, menus, main game, high score list, etc.)
    -- we will use this to determine behavior during render and update
    gameState = 'start'
end

--[[
    Allow for resizing the screen
]]
function love.resize(w, h)
    push:resize(w,h)
end

--[[
    Runs every frame, with "dt" passed in, our delta in seconds 
    since the last frame, which LÖVE2D supplies us.
]]
function love.update(dt)
    if gameState == 'serve' then
        resetAbilities()
        powerups = {}
        ball.dy = math.random(-50, 50)
        if servingPlayer == 1 then
            ball.dx = math.random(140, 200) -- 140, 200
        else
            ball.dx = -math.random(140, 200)
        end
    elseif gameState == 'play' then
        -- detect collision of ball with paddles
        if ball:collides(player1) then
            ball.dx = -ball.dx * 1.03
            ball.x = player1.x + 5

            if ball.dy < 0 then
                ball.dy = -math.random(10, 150)
            else
                ball.dy = math.random(10, 150)
            end
            sounds['paddle_hit']:play()
            lastHit = 1
        end
        if ball:collides(player2) then
            ball.dx = -ball.dx * 1.03
            ball.x = player2.x - 4

            if ball.dy < 0 then
                ball.dy = -math.random(10, 150)
            else
                ball.dy = math.random(10, 150)
            end
            sounds['paddle_hit']:play()
            lastHit = 2
        end

        -- limit speed of ball
        if ball.dx > 800 then
            ball.dx = 800
        elseif ball.dx < -800 then
            ball.dx = -800
        end

        -- detect boundary collision on the top and bottom of the screen
        if ball.y <= 0 then
            ball.y = 0
            ball.dy = -ball.dy
            sounds['wall_hit']:play()
        end
        if ball.y >= VIRTUAL_HEIGHT - 4 then
            ball.y = VIRTUAL_HEIGHT - 4
            ball.dy = -ball.dy
            sounds['wall_hit']:play()
        end

        pSize=0
        for i,v in ipairs(powerups) do
            pSize=pSize+1
        end
        if math.random(1,300) < 2 and pSize < 5 then
            table.insert(powerups, Powerup(math.random(VIRTUAL_WIDTH / 2 - 80, VIRTUAL_WIDTH / 2 + 66), math.random(VIRTUAL_HEIGHT / 2 - 80, VIRTUAL_HEIGHT / 2 + 66)))
        end
    end


    -- if we reach the left or right edge,
    -- update the score, change serving player, and reset ball
    if ball.x < 0 then
        servingPlayer = 1
        player2Score = player2Score + 1

        -- check for victory
        if player2Score >= 7 then
            sounds['victory']:play()
            winningPlayer = 2
            gameState = 'done'
        else
            sounds['score']:play()
            ball:reset()
            gameState = 'serve'
        end
    end

    if ball.x > VIRTUAL_WIDTH then
        servingPlayer = 2
        player1Score = player1Score + 1

        -- check for victory
        if player1Score >= 7 then
            sounds['victory']:play()
            winningPlayer = 1
            gameState = 'done'
        else
            sounds['score']:play()
            ball:reset()
            gameState = 'serve'
        end
    end

    -- player 1 movement
    if playerCount > 0 then
        if love.keyboard.isDown('w') then
            player1.dy = -player1.speed
        elseif love.keyboard.isDown('s') then
            player1.dy = player1.speed
        else
            player1.dy = 0
        end
    else
        if ball.dx < 400 and ball.dx > -400 then
            if ball.dx < 0 then
                if ball.y < player1.y + (player1.height / 2) - 1 then
                    player1.dy = -(player1.speed * 0.85)
                elseif ball.y > player1.y + (player1.height / 2) + 1 then
                    player1.dy = player1.speed * 0.85
                else
                    player1.dy = 0
                end
            else
                if player1.y > VIRTUAL_HEIGHT / 2 - (player1.height / 2) + 2 then
                    player1.dy = -(player1.speed * 0.85)
                elseif player1.y < VIRTUAL_HEIGHT / 2 - (player1.height / 2) - 2 then
                    player1.dy = player1.speed * 0.85
                else
                    player1.dy = 0
                end
            end
        else
            if ball.y < player1.y + 2 then
                player1.dy = -(player1.speed * 0.85)
            elseif ball.y > player1.y + 6 then
                player1.dy = player1.speed * 0.85
            else
                player1.dy = 0
            end
        end
    end

    -- player 2 movement
    if playerCount > 1 then
        if love.keyboard.isDown('up') then
            player2.dy = -player2.speed
        elseif love.keyboard.isDown('down') then
            player2.dy = player2.speed
        else
            player2.dy = 0
        end
    else
        if ball.dx > 0 or ball.x > VIRTUAL_WIDTH / 3 then
            if ball.y < player2.y + (player2.height / 2) - 1 then
                player2.dy = -(player2.speed * 0.85)
            elseif ball.y > player2.y + (player2.height / 2) + 1 then
                player2.dy = player2.speed * 0.85
            else
                player2.dy = 0
            end
        end
    end

    -- update our ball based on its DX and DY only if we're in play state;
    -- scale the velocity by dt so movement is framerate-independent
    if gameState == 'play' then
        ball:update(dt)
    end

    -- check for collision with powerups
    for i,v in ipairs(powerups) do
        if v:collides(ball) then
            temp = math.random(1,4)
            if temp < 2 then
                if lastHit == 1 then
                    v:Ability(player1, 'big')
                else
                    v:Ability(player2, 'big')
                end
                sounds['grow']:play()
            elseif temp <= 3 then
                if lastHit == 1 then
                    v:Ability(player2, 'small')
                else
                    v:Ability(player1, 'small')
                end
                sounds['shrink']:play()
            elseif temp <= 4 then
                if lastHit == 1 then
                    v:Ability(player2, 'slow')
                    if player1.speed == 150 then
                        player1.speed = 200
                    end
                else
                    v:Ability(player1, 'slow')
                    if player2.speed == 150 then
                        player2.speed = 200
                    end
                end
                sounds['slow']:play()
            end
            table.remove(powerups, i)
        end
    end

    player1:update(dt)
    player2:update(dt)
end

--[[
    Keyboard handling, called by LÖVE2D each frame; 
    passes in the key we pressed so we can access.
]]
function love.keypressed(key)
    -- keys can be accessed by string name
    if key == 'escape' then
        -- function LÖVE gives us to terminate application
        love.event.quit()
    -- if we press enter during the start state of the game, we'll go into play mode
    -- during play mode, the ball will move in a random direction
    elseif key == 'enter' or key == 'return' then
        if gameState == 'start' then
            gameState = 'serve'
        elseif gameState == 'serve' then
            gameState = 'play'
        elseif gameState == 'done' then
            gameState = 'serve'
            ball:reset()
            player1Score = 0
            player2Score = 0

            if winningPlayer == 1 then
                servingPlayer = 2
            else
                servingPlayer = 1
            end
        end

    elseif gameState == 'start' then
        if key == '0' then
            playerCount = 0
            gameState = 'serve'
        elseif key == '1' then
            playerCount = 1
            gameState = 'serve'
        else
            playerCount = 2
            gameState = 'serve'
        end
    end
end

--[[
    Called after update by LÖVE2D, used to draw anything to the screen, 
    updated or otherwise.
]]
function love.draw()
    -- begin rendering at virtual resolution
    push:apply('start')

    -- clear the screen with a specific color; in this case, a color similar
    -- to some versions of the original Pong
    love.graphics.clear(40/255, 45/255, 52/255, 255/255)

    -- draw different things based on the state of the game
    if gameState == 'start' then
        love.graphics.setFont(smallFont)
        love.graphics.printf('Welcome to Pong!', 0, 10, VIRTUAL_WIDTH, 'center')
        love.graphics.printf('Press 0, 1, or 2 for the number of players.', 0, 40, VIRTUAL_WIDTH, 'center')
        displayScore()
    elseif gameState == 'serve' then
        love.graphics.setFont(smallFont)
        love.graphics.printf('Player '.. tostring(servingPlayer) .."'s serve", 0, 10, VIRTUAL_WIDTH, 'center')
        love.graphics.printf('Press Enter to serve!', 0, 20, VIRTUAL_WIDTH, 'center')
        displayScore()
    elseif gameState == 'play' then
        -- no messages to display
    elseif gameState == 'done' then
        love.graphics.setFont(largeFont)
        love.graphics.printf('Player '.. tostring(winningPlayer) ..' wins!', 0, 10, VIRTUAL_WIDTH, 'center')
        love.graphics.setFont(smallFont)
        love.graphics.printf('Press Enter to restart!', 0, 30, VIRTUAL_WIDTH, 'center')
    end

    -- render paddles, now using their class's render method
    player1:render()
    player2:render()

    -- render ball using its class's render method
    ball:render()

    -- render powerups
    for i,v in ipairs(powerups) do
        v:render()
    end

    -- render FPS
    displayFPS()

    -- end rendering at virtual resolution
    push:apply('end')
end

function displayFPS()
    -- simple FPS display
    love.graphics.setFont(smallFont)
    love.graphics.setColor(0, 255/255, 0, 125/255)
    love.graphics.print(tostring(love.timer.getFPS()), VIRTUAL_WIDTH / 2 - (smallFont:getWidth(tostring(love.timer.getFPS())) / 2), 2)
end

function displayScore()
    -- draw score to the screen
    love.graphics.setFont(scoreFont)
    love.graphics.print(tostring(player1Score), VIRTUAL_WIDTH / 2 - 50, VIRTUAL_HEIGHT / 3)
    love.graphics.print(tostring(player2Score), VIRTUAL_WIDTH / 2 + 30, VIRTUAL_HEIGHT / 3)
end

function resetAbilities()
    player1.height = 20
    player2.height = 20
    player1.speed = 200
    player2.speed = 200
end