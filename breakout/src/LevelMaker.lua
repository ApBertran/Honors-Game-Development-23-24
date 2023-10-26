LevelMaker = Class{}

-- global patterns (shapes)
NONE = 1
SINGLE_PYRAMID = 2
MULTI_PYRAMID = 3

-- row patterns
SOLID = 1   -- all colors are the same
ALTERNATE = 2   -- alternating colors
SKIP = 3    -- skip every other block
NONE = 4    -- no blocks at all in this row

function LevelMaker.createMap(level)
    local bricks = {}

    local numRows = math.random(1, 5)
    local numCols = math.random(7, 13)
    numCols = numCols % 2 == 0 and (numCols + 1) or numCols

    local highestColor = math.min(3, math.floor(level / 1.5))
    local highestTier = math.min(3, level % 4 + 1)

    for y = 1, numRows do
        -- determine whether or not to skip the current row
        local skipPattern = math.random(1,2) == 1 and true or false

        -- determine whether to use alternate patterns in this row
        local alternatePattern = math.random(1,2) == 1 and true or false

        -- choose the alternating colors
        local alternateColor1 = math.random(1, highestColor)
        local alternateColor2 = math.random(1, highestColor)
        local alternateTier1 = math.random(0, highestTier)
        local alternateTier2 = math.random(0, highestTier)

        -- used only for skipping a block in the skip pattern
        local skipFlag = math.random(2) == 1 and true or false

        -- used only for alternating a block in the alternate pattern
        local alternateFlag = math.random(2) == 1 and true or false
        -- solid color to use if not alternating
        local solidColor = math.random(1, highestColor)
        local solidTier = math.random(0, highestTier)

        for x = 1, numCols do
            -- if skipping is turned on and we're on a skip iteration
            if skipPattern and skipFlag then
                -- turn off skipping for next iteration
                skipFlag = not skipFlag

                goto continue
            else
                -- flip the flag back
                skipFlag = not skipFlag
            end

            b = Brick(
                (x - 1) * 32 + 8 + (13 - numCols) * 16, y * 16
            )

            -- if in alternating pattern, figure out which one we are on
            if alternatePattern and alternateFlag then
                b.color = alternateColor1
                b.tier = alternateTier1
                alternateFlag = not alternateFlag
            else
                b.color = alternateColor2
                b.tier = alternateTier2
                alternateFlag = not alternateFlag
            end

            -- if not in alternating pattern, use the solid color and tier
            if not alternatePattern then
                b.color = solidColor
                b.tier = solidTier
            end

            table.insert(bricks, b)

            :: continue ::
        end
    end

    if #bricks == 0 then
        return self.createMap(level)
    else
        return bricks
    end
end