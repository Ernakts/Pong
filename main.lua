local Canvas
local Shader

function love.load()
    -- Window
    VirtualWidth = 800
    VirtualHeight = 600

    -- Player
    PaddleWidth = 15
    PaddleHeight = 80
    PaddleSpeed = 600
    PlayerOne = (VirtualHeight / 2) - (PaddleHeight / 2)
    PlayerTwo = (VirtualHeight / 2) - (PaddleHeight / 2)
    
    -- Ball & Line
    BallX = VirtualWidth / 2
    BallY = VirtualHeight / 2
    BallSize = 15
    BallSpeedX = 300
    BallSpeedY = 300
    LineWidth = 15
    LineHeight = VirtualHeight
    LineX = VirtualWidth / 2
    LineY = 0

    -- Score
    ScoreOne = 0
    ScoreTwo = 0

    -- Scene
    MainMenu = true
    love.mouse.setVisible(false)

    -- UI 
    TitleUI = love.graphics.newFont("fonts/press_start_2p.ttf", 75)
    ScoreUI = love.graphics.newFont("fonts/press_start_2p.ttf", 50)
    TextUI = love.graphics.newFont("fonts/press_start_2p.ttf", 20)
    Icon = love.image.newImageData("icon.png")
    love.window.setIcon(Icon)

    -- Time 
    PauseTimer = 0
    Timer = 0

    -- Audio
    StartSound = love.audio.newSource("sounds/start.ogg", "static")
    ShootSound = love.audio.newSource("sounds/shoot.ogg", "static")
    EndSound = love.audio.newSource("sounds/end.ogg", "static")

    -- Canvas
    Canvas = love.graphics.newCanvas(VirtualWidth, VirtualHeight)

    -- Shader
    Shader = love.graphics.newShader("crt.glsl")
end

function love.update(dt)
    if PauseTimer > 0 then
        PauseTimer = PauseTimer - dt
    else
        PlayerSystem(dt)
        BallSystem(dt)
        CollisionSystem()
    end
    
    Timer = Timer + dt
    Shader:send("time", Timer)
end

function love.draw()
    love.graphics.setCanvas(Canvas)
    love.graphics.clear()

    love.graphics.rectangle("fill", 20, PlayerOne, PaddleWidth, PaddleHeight)
    love.graphics.rectangle("fill", VirtualWidth - 20 - PaddleWidth, PlayerTwo, PaddleWidth, PaddleHeight)

    if not MainMenu then
        love.graphics.rectangle("fill", LineX, LineY, LineWidth, LineHeight)
        love.graphics.rectangle("fill", BallX, BallY, BallSize, BallSize)
    end

    if MainMenu then
        love.graphics.setFont(TitleUI)
        love.graphics.print("PONG", VirtualWidth / 2 - 150, VirtualHeight / 2 - 250)
        love.graphics.setFont(TextUI)
        love.graphics.print("W", 100, VirtualHeight / 2 - 40)
        love.graphics.print("S", 100, VirtualHeight / 2 + 23)
        love.graphics.print("Up", VirtualWidth - 160, VirtualHeight / 2 - 40)
        love.graphics.print("Down", VirtualWidth - 180, VirtualHeight / 2 + 23)
        love.graphics.print('"Space" Start' , 20, VirtualHeight / 2 + 185)
        love.graphics.print('"F" Window', 20, VirtualHeight / 2 + 225)
        love.graphics.print('"Q" Quit', 20, VirtualHeight / 2 + 265)
        love.graphics.print("V1.2", VirtualWidth - 95, VirtualHeight / 2 + 265)
    elseif not MainMenu then
        love.graphics.setFont(ScoreUI)
        love.graphics.print(ScoreOne, 475, 50)
        love.graphics.print(ScoreTwo, VirtualWidth - 500, 50)
    end

    love.graphics.setCanvas()

    local VWindow = love.graphics.getWidth()
    local HWindow = love.graphics.getHeight()
    local ScaleX = VWindow / VirtualWidth
    local ScaleY = HWindow / VirtualHeight

    love.graphics.setShader(Shader)
    Shader:send("screen_res", {VWindow, HWindow})
    love.graphics.draw(Canvas, 0, 0, 0, ScaleX, ScaleY)
    love.graphics.setShader()
end

function love.keypressed(key)
    if key == "f" and MainMenu then
        local IsFullscreen = love.window.getFullscreen()
        love.window.setFullscreen(not IsFullscreen)
    elseif key == "q" and MainMenu then
        love.event.quit()
    elseif key == "space" and MainMenu then
        love.audio.play(StartSound) 
        MainMenu = false
    end
end

function PlayerSystem(dt)
    if love.keyboard.isDown("w") and not MainMenu then
        PlayerOne = PlayerOne - PaddleSpeed * dt
    elseif love.keyboard.isDown("s") and not MainMenu then 
        PlayerOne = PlayerOne + PaddleSpeed * dt
    end
    
    if love.keyboard.isDown("up") and not MainMenu then
        PlayerTwo = PlayerTwo - PaddleSpeed * dt
    elseif love.keyboard.isDown("down") and not MainMenu then 
        PlayerTwo = PlayerTwo + PaddleSpeed * dt
    end

    if PlayerOne < 0 then
        PlayerOne = 0
    elseif PlayerOne + PaddleHeight > VirtualHeight then
        PlayerOne = VirtualHeight - PaddleHeight
    end

    if PlayerTwo < 0 then
        PlayerTwo = 0
    elseif PlayerTwo + PaddleHeight > VirtualHeight then
        PlayerTwo = VirtualHeight - PaddleHeight
    end
end

function BallSystem(dt)
    if not MainMenu then
        BallX = BallX + BallSpeedX * dt
        BallY = BallY + BallSpeedY * dt
    end

    if BallX < -15 then
        love.audio.play(StartSound)
        ScoreTwo = ScoreTwo + 1
        ResetPositions()
        PauseTimer = 2
        BallSpeedX = 300
        BallSpeedY = 300
    elseif ScoreTwo == 5 then
        love.audio.play(EndSound)
        PauseTimer = 3
        MainMenu = true
        ScoreTwo = 0
        ScoreOne = 0
    elseif BallX > VirtualWidth + 15 then
        love.audio.play(StartSound)
        ScoreOne = ScoreOne + 1
        ResetPositions()
        PauseTimer = 2
        BallSpeedX = 300
        BallSpeedY = 300
    elseif ScoreOne == 5 then
        love.audio.play(EndSound)
        PauseTimer = 3
        MainMenu = true
        ScoreOne = 0
        ScoreTwo = 0
    elseif BallY < 0 then
        love.audio.play(ShootSound)
        BallY = 0
        BallSpeedY = - BallSpeedY
    elseif BallY + BallSize > VirtualHeight then
        love.audio.play(ShootSound)
        BallY = VirtualHeight - BallSize
        BallSpeedY = - BallSpeedY
    end
end

function CollisionSystem()
    if BallX < 15 + PaddleWidth and BallY + BallSize > PlayerOne and BallY < PlayerOne + PaddleHeight then
        love.audio.play(ShootSound)
        BallSpeedX = math.abs(BallSpeedX)
        BallX = 20 + PaddleWidth
        BallSpeedX = BallSpeedX * 1.1
        BallSpeedY = BallSpeedY * 1.1
    elseif BallX + BallSize > (VirtualWidth - 20 - PaddleWidth) and BallY + BallSize > PlayerTwo and BallY < PlayerTwo + PaddleHeight then
        love.audio.play(ShootSound)
        BallSpeedX = - math.abs(BallSpeedX)
        BallX = VirtualWidth - 20 - PaddleWidth - BallSize
        BallSpeedX = BallSpeedX * 1.1
        BallSpeedY = BallSpeedY * 1.1
    elseif BallSpeedX == 1200 and BallSpeedY == 1200 then
        BallSpeedX = 300
        BallSpeedY = 300
    end
end

function ResetPositions()
    BallX = VirtualWidth / 2
    BallY = VirtualHeight / 2
    PlayerOne = (VirtualHeight / 2) - (PaddleHeight / 2)
    PlayerTwo = (VirtualHeight / 2) - (PaddleHeight / 2)
    BallSpeedX = - BallSpeedX 
end