require("loading")
require("map")
require("alien")
require("menus")
require("physics")

-- Cette ligne permet d'afficher des traces dans la console pendant l'exécution
io.stdout:setvbuf('no')

-- Empêche Love de filtrer les contours des images quand elles sont redimensionnées
-- Indispensable pour du Pixel Art
love.graphics.setDefaultFilter("nearest")

-- Cette ligne permet de déboguer pas à pas dans ZeroBraneStudio
if arg[#arg] == "-debug" then require("mobdebug").start() end

heros = {}
heros.ship = 1
--heros.score = 0

math.randomseed(love.timer.getTime())

-- Liste des éléments
liste_sprites = {}
liste_tirs = {}
liste_aliens = {}

-- Camera
camera = {}
camera.x = 0
camera.y = 0
camera.vitesse = 1

-- Ecran courant
ecran_courant = "menu"
timerMainMenu = 0
showSpaceMsg = true
pause = true

-- Initialisation de la victoire
victory = false
timerVictory = 0

function CreateShoot(pType, pNomImage, pX, pY, pVitesseX, pVitesseY)
  local tir = CreateSprite(pNomImage, pX, pY)
  tir.vx = pVitesseX
  tir.vy = pVitesseY
  tir.type = pType
  table.insert(liste_tirs, tir)
  sonShoot:play()
end


function CreateSprite(pNomImage, pX, pY, pRotation)
  sprite = {}
  sprite.x = pX
  sprite.y = pY
  if (pRotation) then
    sprite.r = pRotation
  else
    sprite.r = 0
  end  
  sprite.toDelete = false
  sprite.image = love.graphics.newImage("images/"..pNomImage..".png")
  sprite.l = sprite.image:getWidth()
  sprite.h = sprite.image:getHeight()

  sprite.frame = 1
  sprite.listeFrames = {}
  sprite.maxFrame = 1

  table.insert(liste_sprites, sprite)

  return sprite
end

function CreateExplosion(pX, pY)
  local newExplosion = CreateSprite("explode_1", pX, pY)
  newExplosion.listeFrames = imgExplosion
  newExplosion.maxFrame = 5
end
function DrawEnergie(pX, pY, pWidth)
  if (heros.energy * 100 / heros.energyMax) > 75 then
      love.graphics.setColor(0,255,0)
  elseif (heros.energy * 100 / heros.energyMax) > 50 then
      love.graphics.setColor(255,165,0)
  elseif (heros.energy * 100 / heros.energyMax) > 25 then
      love.graphics.setColor(255,69,0)
  else
      love.graphics.setColor(255,0,0)
  end
  local energyBar = (heros.energy / heros.energyMax) * pWidth
  love.graphics.rectangle("fill", pX, pY - 10, energyBar, 5)
  love.graphics.setColor(255,255,255)

end

function love.load()
  
  love.window.setMode(512, 384)
  love.window.setTitle("My Lua Shooter - GameCodeur")
  
  largeur = love.graphics.getWidth()
  hauteur = love.graphics.getHeight()
  
  InitIntro()
  StartGame()
end


function StartGame()
  
  heros = CreateSprite("ship1", largeur/2, hauteur/2)
  heros.ship = 1

  -- Position de départ du héros
  heros.x = largeur/2
  heros.y = hauteur - (heros.h * 2)
  heros.vcoeff = 3
  heros.score = 0
  heros.energy = 10
  heros.energyMax = 10
  heros.life = 3
  
  DrawRandomAliens()
  
  -- RAZ de la camera
  camera.y = 0
  
  pause = false
end

function UpdateGame()
  -- Avance camera
  camera.y = camera.y + camera.vitesse
  
  local n
  
  -- Traitement des tirs
  for n=#liste_tirs, 1, -1 do
    local tir = liste_tirs[n]
    tir.x = tir.x + tir.vx
    tir.y = tir.y + tir.vy
    
    -- Vérifie si on touche le héros
    if tir.type == "alien" then
      if Collide(heros, tir) then
        if tir.toDelete == false then
          tir.toDelete = true
          table.remove(liste_tirs, n)
        end
        heros.energy = heros.energy - 1
        if heros.energy <= 0 then
          heros.life = heros.life - 1
          heros.energy = heros.energyMax
        end
        if heros.life <= 0 then
          ecran_courant = "gameover"
        end
      end
    end
    if tir.type == "heros" then
      local nAlien
      for nAlien=#liste_aliens, 1, -1 do
        local alien = liste_aliens[nAlien]
        if alien.sleeping == false then
          if Collide(tir, alien) then
            CreateExplosion(tir.x, tir.y)
            if tir.toDelete == false then
              tir.toDelete = true
              table.remove(liste_tirs, n)
            end
            sonExplode:play()
            alien.energy = alien.energy - 1
            if alien.energy <= 0 then
              heros.score = heros.score + alien.score
              local nExplosion
              for nExplosion=1, 5 do
                CreateExplosion(alien.x + math.random(-10, 10), alien.y + math.random(-10, 10))
              end
              if alien.type == 10 then
                victory = true
                timerVictory = 200
                for nExplosion=1, 20 do
                  CreateExplosion(alien.x + math.random(-100, 100), alien.y + math.random(-100, 100))
                end
              end
              if alien.toDelete == false then
                alien.toDelete = true
                table.remove(liste_aliens, nAlien)
              end
            end
          end
        end
      end
    end
    
    -- Vérifier si le tir est sorti de l'écran
    if (tir.y < 0 or tir.y > hauteur) and tir.toDelete == false then
      tir.toDelete = true
      table.remove(liste_tirs, n)
    end
    
  end
  
  -- Traitement des aliens
  for n=#liste_aliens, 1, -1 do
    local alien = liste_aliens[n]
    
    if alien.y > -32 then
      alien.sleeping = false
    end
    
    if alien.sleeping == false then
      alien.x = alien.x + alien.vx
      if (alien.x <= 0 and alien.vx < 0) or (alien.x >= largeur and alien.vx > 0) then
        alien.vx = alien.vx * -1
      end
      alien.y = alien.y + alien.vy
      
      if alien.type == 1 or alien.type == 2 then
        alien.chronotir = alien.chronotir - 1
        if alien.chronotir <= 0 then
          alien.chronotir = math.random(70, 100)
          CreateShoot("alien", "laser2",alien.x, alien.y, 0, 5)
        end
      elseif alien.type == 3 then
        alien.chronotir = alien.chronotir - 1
        if alien.chronotir <= 0 then
          alien.chronotir = math.random(35, 55)
          local vx, vy
          local angletir
          angletir = math.angle(alien.x, alien.y, heros.x, heros.y)
          vx = 4 * math.cos(angletir)
          vy = 4 * math.sin(angletir)
          CreateShoot("alien", "laser2",alien.x, alien.y, vx, vy)
        end
      elseif alien.type == 10 then
        if alien.y > hauteur / 3 then
          alien.y = hauteur/3
        end
        alien.chronotir = alien.chronotir - 1
        if alien.chronotir <= 0 then
          alien.chronotir = 15
          local vx, vy
          alien.angle = alien.angle + 0.5
          vx = 6 * math.cos(alien.angle)
          vy = 6 * math.sin(alien.angle)
          CreateShoot("alien", "laser2",alien.x, alien.y, vx, vy)
        end
      end
      
    else
      alien.y = alien.y + camera.vitesse
    end
    
    if alien.y > hauteur and alien.toDelete == false then
      alien.toDelete = true
      table.remove(liste_aliens, n)
    end
    
  end
  
  -- Traitement et purge des sprites à supprimer
  for n=#liste_sprites, 1, -1 do
    local sprite = liste_sprites[n]
    -- Le sprite est-il animé ?
    if sprite.maxFrame > 1 then
      sprite.frame = sprite.frame + 0.2
      if math.floor(sprite.frame) > sprite.maxFrame then
        sprite.toDelete = true
      else
        sprite.image = sprite.listeFrames[math.floor(sprite.frame)]
      end
    end
    
    if sprite.toDelete == true then
      table.remove(liste_sprites, n)
    end
  end
  
  if love.keyboard.isDown("right") and heros.x < largeur then
    heros.x = heros.x + heros.vcoeff
  elseif love.keyboard.isDown("left") and heros.x > 0 then
    heros.x = heros.x - heros.vcoeff
  end
  if love.keyboard.isDown("down") and heros.y < hauteur then
    heros.y = heros.y + heros.vcoeff
  elseif love.keyboard.isDown("up") and heros.y > 0 then
    heros.y = heros.y - heros.vcoeff
  end
  
--  if victory == true and (#liste_sprites == 1 and liste_sprites[1].image == "images/heros.png") then
  if victory == true then
    timerVictory = timerVictory - 1
    if timerVictory == 0 then
      ecran_courant = "victory"
    end
  end
end


function love.update(dt)
  
  if ecran_courant == "jeu" then
    UpdateGame()
  elseif ecran_courant == "menu" then
    UpdateMenu()
  end
end

function DrawGame()
    local n
  
  -- Dessin du niveau
  local nbLignes = #niveau
  local ligne, colonne, x, y
  
  x = 0
  y = (0 - 64) + camera.y
  for ligne = nbLignes, 1, -1 do
    for colonne = 1, 16 do
      local tuile = niveau[ligne][colonne]
      -- Dessine la tuile
      if tuile > 0 then
        love.graphics.draw(imgTuiles[tuile], x, y, 0, 1, 1)
      end
      x = x + 32
    end
    x = 0
    y = y - 32
  end

  -- Dessin des personnages
  for n=1, #liste_sprites do
    local s = liste_sprites[n]
    love.graphics.draw(s.image, s.x, s.y, 0, 1, 1, s.l/2, s.h/2)
  end
  
  love.graphics.print("Score : "..heros.score, 0, 0)

  DrawHerosLife(heros.life)
  
  -- Affichage du debug
  --love.graphics.print("Nb sprites : "..#liste_sprites, largeur - 100, hauteur - 15)
end

function DrawHerosLife(pNbLife)
  local n
  local lastPos
  local widthShip = hauteur - heros.image:getHeight()
  for n=1, pNbLife do
    lastPos = (n-1) * (heros.image:getWidth() / 2) + 5
    love.graphics.draw(heros.image, lastPos, widthShip, 0, 0.5, 0.5)
  end
  DrawEnergie(lastPos, widthShip, heros.image:getWidth()/2)
end

function ClearLevel()
  local n
  for n=#liste_aliens, 1, -1 do
    table.remove(liste_aliens, n)
  end
  for n=#liste_tirs, 1, -1 do
    table.remove(liste_tirs, n)
  end
  for n=#liste_sprites, 1, -1 do
    table.remove(liste_sprites, n)
  end
  
end

function love.draw()
  if ecran_courant == "jeu" then
    DrawGame()
    if pause == true then
      DrawPauseMenu()
    end
  elseif ecran_courant == "menu" then
    DrawMenu()
  elseif ecran_courant == "choice" then
    DrawChoiceMenu()
  elseif ecran_courant == "gameover" then
    DrawGameOver()
  elseif ecran_courant == "victory" then
    DrawVictory()
  end
end

function love.keypressed(key)
  if (key) then
    if ecran_courant =="jeu" then
      if key == "space" then
        CreateShoot("heros", "laser1", heros.x, heros.y - heros.h, 0, -8)
      end
      if key == "p" then
        pause = not pause
      end
    elseif ecran_courant == "menu" and pause == false then
      if key == "space" then
        ecran_courant = "choice"
      end
    elseif ecran_courant == "choice" then
      if key == "space" then
        ecran_courant = "jeu"
        heros.image = love.graphics.newImage("images/ship"..heros.ship..".png")
      end
      if key == "left" then
        sonChangeShip:play()
        if heros.ship == 1 then
          heros.ship = 2
        elseif heros.ship == 2 then
          heros.ship = 1
        end
      end
      if key == "right" then
        sonChangeShip:play()
        if heros.ship == 1 then
          heros.ship = 2
        elseif heros.ship == 2 then
          heros.ship = 1
        end
      end
    elseif ecran_courant == "gameover" or ecran_courant == "victory" then
      if key == "space" then
        ecran_courant = "menu"
        victory = false
      end
    end
  end
end