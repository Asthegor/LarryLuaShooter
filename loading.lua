-- Image des tuiles
imgTuiles = {}
local n
for n=1, 3 do
  imgTuiles[n] = love.graphics.newImage("images/tuile_"..n..".png")
end

-- Images du fond
imgBackground = {}
for n=1, 7 do
  imgBackground[n] = love.graphics.newImage("images/Background_menu_"..n..".png")
end

imgShips = {}
for n=1, 2 do
  imgShips[n] = love.graphics.newImage("images/ship"..n..".png")
end

-- Images des explosions
imgExplosion = {}
for n=1, 5 do
  imgExplosion[n] = love.graphics.newImage("images/explode_"..n..".png")
end

-- Gestion des menus
imgGameOver = love.graphics.newImage("images/gameover.jpg")
imgVictory = love.graphics.newImage("images/victory.jpg")
imgArrow = love.graphics.newImage("images/arrow.png")
imgPauseMenu = love.graphics.newImage("images/pause.png")

-- Gestion des sons
sonShoot = love.audio.newSource("sons/shoot.wav", "static")
sonExplode = love.audio.newSource("sons/explode_touch.wav", "static")
sonChangeShip = love.audio.newSource("sons/change_ship.wav", "static")

-- Gestion de la musique
musicGame = love.audio.newSource("music/Thisco-Sika_of_Etol.mp3")
