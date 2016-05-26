local map_intro = require("map_intro")
local level_intro = map_intro.layers[1].data

local liste_sprites_intro = {}
local liste_tirs_intro = {}

local xScrolling = 0
local ind = 1
local indX = 0.0
local indY = 0.0
local timer = 0

-- Liste de la description des mouvements des vaisseaux
-- Valeur 1 : nombre de pixels à se déplacer en X (dans le scrolling)
-- /!\ ATTENTION /!\ : les valeurs sont doublées pour les X négatifs
-- Valeur 2 : nombre de pixels à se déplacer en Y (dans le scrolling)
-- Lorsque la valeur est zéro, le vaisseau suit le scrolling
local liste_mvt = { -- une sous-table par vaisseau à déplacer
  { --             Gauche/Droite            Haut/Bas
    {32, 0}, { 2,-2}, { 2,-4}, { 0,-2}, {-1,-2},
    {-2,-2}, {-2, 4}, {-1, 2}, {-2, 2}, {-1, 2},
    { 2, 2}, { 0, 6}, { 2, 2}, { 4, 2}, { 6, 2},
    { 8, 0}, { 6,-2}, { 4,-4}, { 2,-4}, {-1,-4},
    {-2,-2}, {-1,-2}, {-1,-2}, {-2,-2}, {-3, 2},
    {-1, 2}, { 0, 2}, { 2, 2}, { 4, 2}, { 6, 2},
    { 2, 2}, {-1, 2}, {-5, 2}, {-2, 0}, {-1,-2},
    { 2,-4}, { 4,-2}
  },
  { --             Gauche/Droite            Haut/Bas
    { 32,   0}, -- Droite de +320 pixels
    {- 5,  10}, -- Gauche de -100 pixels    Bas  de 100 pixels
    {  5, - 5}, -- Droite de + 50 pixels    Haut de  50 pixels
    { 15, -10}, -- Droite de +150 pixels    Haut de 100 pixels
    {-10,   0}, -- Gauche de -200 pixels
    { 10, -10}, -- Droite de +100 pixels    Haut de 100 pixels
    { 10,   0}, -- Droite de +100 pixels
    { 10,   5}, -- Droite de +100 pixels    Bas  de  50 pixels
    {-10,  10}  -- Gauche de -200 pixels    Bas  de 100 pixels
  }
}

function InitIntro()
  
  CreateSpriteIntro("ship2", -64, hauteur/2, true, 90, 1)
  CreateSpriteIntro("ship2", -84, hauteur/2 - 25, true, 90, 2)

  --ind = 1
  indX = 0
  indY = 0

end

function CreateSpriteIntro(pNomImage, pX, pY, pIsShip, pRotation, pIndMvt)
  sprite = {}
  sprite.x = pX
  sprite.y = pY
  sprite.isShip = pIsShip
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
  
  if (pIndMvt) then
    sprite.indMvt = pIndMvt
  else
    sprite.indMvt = 1
  end
  sprite.index = 1
  sprite.indX = 0
  sprite.indY = 0
  sprite.canFire = false
  sprite.timer = 0
  table.insert(liste_sprites_intro, sprite)
  return sprite
end

function CreateShootIntro(pType, pNomImage, pX, pY, pVitesseX, pVitesseY)
  local tir = CreateSpriteIntro(pNomImage, pX, pY)
  tir.vx = pVitesseX
  tir.vy = pVitesseY
  tir.type = pType
  table.insert(liste_tirs_intro, tir)
  sonShoot:play()
end

function ShowIntroduction()
  -- Déclaration des variables locales
  local n, ligne, colonne, x, y
  local nbLignes = map_intro.layers[1].height
  local nbcolonnes = map_intro.layers[1].width
  local max = ((nbcolonnes * map_intro.tilesets[1].tilewidth) + largeur) * -1
  
  -- ici, on fait la boucle sur niveau
  if xScrolling <= max then
    xScrolling = 0
  else
    xScrolling = xScrolling - 1
  end
  
  -- affichage du niveau
  x = largeur + xScrolling
  y = 0
  for ligne = 1, nbLignes do
    for colonne = 1, nbcolonnes do
      local tuile = level_intro[(ligne - 1) * nbcolonnes + colonne]
      -- Dessine la tuile
      if tuile > 0 then
        love.graphics.draw(imgTuiles[tuile], x, y, 0, 1, 1)
      end
      x = x + 32
    end
    x = largeur + xScrolling
    y = y + 32
  end

  -- boucle sur les tirs
  for n=#liste_tirs_intro, 1, -1 do
    local tir = liste_tirs_intro[n]
    tir.x = tir.x + tir.vx
    tir.y = tir.y + tir.vy
    if tir.x > largeur then
      -- ici, on efface le tir
      tir.toDelete = true
      table.remove(liste_tirs_intro, n)
    end
  end
  
  -- boucle sur les sprites
  for n=1, #liste_sprites_intro do
    local s = liste_sprites_intro[n]
    -- test si c'est un vaisseau
    if s.isShip == true then
      local nbMvt = #liste_mvt[s.indMvt]
      if s.index <= nbMvt then
        --ici, on applique le mouvement défini
        local mvtX = liste_mvt[s.indMvt][s.index][1]
        local mvtY = liste_mvt[s.indMvt][s.index][2]
        local x_fini = false
        local y_fini = false
        
        -- on teste si le vaisseau doit aller vers la droite
        if mvtX > 0 then
          if s.indX < mvtX then
            s.x = s.x + 1
            s.indX = s.indX + 0.1
          else
            x_fini = true
          end
        -- on teste si le vaisseau doit aller vers la gauche
        elseif mvtX < 0 then
          if s.indX > mvtX then
            s.x = s.x - 2
            s.indX = s.indX - 0.1
          else
            x_fini = true
          end
        else
          -- ici, le vaisseau ne va ni à droite ni à gauche
          x_fini = true
        end
        
        -- on teste si le vaisseau doit aller vers le bas
        if mvtY > 0 then
          if s.indY < mvtY then
            s.y = s.y + 1
            s.indY = s.indY + 0.1
          else
            y_fini = true
          end
        -- on teste si le vaisseau doit aller vers le haut
        elseif mvtY < 0 then
          if s.indY > mvtY then
            s.y = s.y - 1
            s.indY = s.indY - 0.1
          else
            y_fini = true
          end
        else
          -- ici, le vaisseau ne va ni en haut ni en bas
          y_fini = true
        end
        
        if x_fini == true and y_fini == true then
          -- on a fini de faire le déplacement
          -- on passe au mouvement suivant
          s.indX = 0
          s.indY = 0
          s.index = s.index + 1
          s.canFire = true
        end
      else
        -- ici, on boucle sur les mouvements du vaisseau
        s.index = 2
      end
      
      -- gestion des tirs
      if s.canFire == true then
        if s.timer == 0 then
          CreateShootIntro("heros", "laser1", s.x + s.l/2, s.y, 8, 0)
          -- on définit un délai aléatoire entre 10 et 100 pour tirer
          s.timer = math.random(10, 100)
        else
          s.timer = s.timer - 1
        end
      end
    end

    love.graphics.draw(s.image, s.x, s.y, DegreeToRadian(s.r), 1, 1, s.l/2, s.h/2)
  end
end
