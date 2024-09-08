local windowWidth
local windowHeight
local bulletimg
local spaceimg
local catimg
local enemyimg
local x, y
local speed = 200
local timer = 1
local bulletTimer = 0.5
local score = 0
local killCount = 0




font = "arial"

function love.load()

        --윈도우 타이틀
        love.window.setTitle("spess")

        --사운드
        shootSound = love.audio.newSource("shoot.wav", "static")
        shootSound:setVolume(0.9)
        exploSound = love.audio.newSource("explosion.wav", "static")
        sparkSound = love.audio.newSource("spark.wav", "static")

        windowWidth = love.graphics.getWidth()
        windowHeight = love.graphics.getHeight()

        font = love.graphics.newFont(20)
        love.graphics.setFont(font)

        spaceimg = love.graphics.newImage("spaceimg.png")
        catimg = love.graphics.newImage("cat.png")
        bulletimg = love.graphics.newImage("bulletimg.png")
        enemyimg = love.graphics.newImage("enemy.png")
        deadimg = love.graphics.newImage("dead.png")
        playerVisible = true

        enemies = {}
        bullets = {}
        enemySpawn()

        --화면 중앙에 플레이어 이미지를 위치
        x = love.graphics.getWidth() / 2 - catimg:getWidth() / 2
        y = love.graphics.getHeight() / 2 - catimg:getHeight() / 2
        -- 배경
        bgx = love.graphics.getWidth() / 2 - spaceimg:getWidth() / 2
        bgy = love.graphics.getHeight() / 2 - spaceimg:getHeight() / 2

end

function love.update(dt)

        -- 화살표 키 입력으로 이미지 이동
        if playerVisible then
                if love.keyboard.isDown("up") then
                        y = y - speed * dt 
                end
                if love.keyboard.isDown("down") then
                        y = y + speed * dt 
                end
                if love.keyboard.isDown("left") then
                        x = x - speed * dt 
                end
                if love.keyboard.isDown("right") then
                        x = x + speed * dt 
                end
                --플레이어 캐릭터 위쪽에서 탄환 발사
                if love.keyboard.isDown("space") then
                        love.audio.play(shootSound)
                        local bullet = {}
                        bullet.x = x + catimg:getWidth()/2
                        bullet.y = y
                        if bulletTimer <= 0 then
                                table.insert(bullets, bullet)
                                bulletTimer = 0.4
                        end
                end
        end

        --발사 타이머
        bulletTimer = bulletTimer - 1*dt

        --탄환 생성
        for i, bullet in ipairs(bullets) do
                local bulletSpeed = 100
                bullet.y = bullet.y - bulletSpeed * dt 
        end

        -- 적 생성
        for i, enemy in ipairs(enemies) do
                local enemySpeed = 100
                enemy.y = enemy.y + enemySpeed * dt
                if enemy.y > love.graphics.getHeight() then
                        table.remove(enemies, i)
                end

        end
        -- 적 생성: 타이머
        timer = timer - dt
        if timer <= 0 then
                enemySpawn()
                timer = 1 - killCount*0.05
        end
        
        -- 플레이어가 화면 밖으로 나가지 못하게 함: 플레이어 이미지의 좌표가 창의 x, y 좌표보다 클 경우 0으로 강제
        if x < 0 then
                x = 0
        elseif x + catimg:getWidth() > windowWidth then
                x = windowWidth - catimg:getWidth()
        end

        if y < 0 then
                y = 0
        elseif y + catimg:getHeight() > windowHeight then
                y = windowHeight - catimg:getHeight()
        end

        -- 충돌 감지 함수 실행
        collisionCheck()
        end


function love.draw()
        love.graphics.draw(spaceimg, bgx, bgy)
        if playerVisible then
                love.graphics.draw(catimg, x, y)
        else
                love.graphics.draw(deadimg, x, y)
        end
        --draw enemyimg
        for i, enemy in ipairs(enemies) do
                love.graphics.draw(enemyimg, enemy.x, enemy.y)
        end
        --draw bulletimg
        for i, bullet in ipairs(bullets) do
                love.graphics.draw(bulletimg, bullet.x, bullet.y)
        end
        --점수 표시
        love.graphics.setColor(1, 1, 1)

        love.graphics.print("score:" .. score, love.graphics.getWidth() - 200, 10)

end

function enemySpawn()
        local enemy = {}
        enemy.x = math.random(0, windowWidth - enemyimg:getWidth())
        enemy.y = -enemyimg:getHeight()
        table.insert(enemies, enemy)
end

function collisionCheck()
                -- 플레이어와 적의 충돌 감지
        for i, enemy in ipairs(enemies) do
                if rectCollision(x, y, catimg:getWidth(),catimg:getHeight(),
                        enemy.x, enemy.y, enemyimg:getWidth(), enemyimg:getHeight()) then
                        -- 충돌이 감지되면 playerVisible 플래그를 비활성화
                        table.remove(enemies, i)
                        playerVisible = false
                        love.audio.play(exploSound)
                        end
                --탄환과 적의 충돌 감지
                for j, bullet in ipairs(bullets) do
                        if rectCollision(bullet.x, bullet.y, bulletimg:getWidth(),bulletimg:getHeight(), enemy.x, enemy.y, enemyimg:getWidth(), enemyimg:getHeight()) then
                                table.remove(enemies, i)
                                table.remove(bullets, j)
                                score = score + 100
                                killCount = killCount + 1
                                love.audio.play(sparkSound)
                                end
                        end
                end

        end
--충돌 감지 함수
function rectCollision(x1, y1, w1, h1, x2, y2, w2, h2)
        return x1 < x2 + w2 and
                x2 < x1 + w1 and
                y1 < y2 + h2 and
                y2 < y1 + h1
         end