function CreateAlien(pType, pX, pY)  
  if pType == 1 then
    nomImage = "enemy1"
  elseif pType == 2 then
    nomImage = "enemy2"
  elseif pType == 3 then
    nomImage = "tourelle"
  elseif pType == 10 then
    nomImage = "enemy3"
  end
  
  local alien = CreateSprite(nomImage, pX, pY)
  
  alien.type = pType
  alien.sleeping = true
  alien.chronotir = 0
  alien.visible = 0
  
  if pType == 1 then
    alien.vy = 2
    alien.vx = 0
    alien.energy = 1
    alien.score = 1
  elseif pType == 2 then
    alien.vy = 2
    local direction = math.random(1,2)
    if direction == 1 then
      alien.vx = 1
    else
      alien.vx = -1
    end
    alien.energy = 2
    alien.score = 2
  elseif pType == 3 then
    alien.vx = 0
    alien.vy = camera.vitesse
    alien.energy = 5
    alien.score = 5
  elseif pType == 10 then
    alien.vx = 0
    alien.vy = camera.vitesse * 2
    alien.energy = 20
    alien.angle = 0
    alien.score = 20
  end

  table.insert(liste_aliens, alien)
  
end

function DrawRandomAliens()
  -- Création des aliens
  local nbLignes = #niveau
  local ligne
  for ligne = nbLignes - 2, 1, -1 do
    local posAlien = {}
    local n
    -- Le calcul de maxAlien est vraiment très empirique
    -- mais donne de plutôt bons résultats (^_^)
    local rnd = math.random(1, 100)
    local maxAlien = math.floor((rnd - 50) / 20)
    if maxAlien > 0 then
      for n = 1, maxAlien do
        local typeAlien
        -- on choisit le type au hasard (1->50 = type 1, 51->90 = type 2, 91->100 = type 3
        local rndTypeAlien = math.random(1, 100)
        if rndTypeAlien >= 91 then
          typeAlien = 3
        elseif rndTypeAlien >= 51 then
          typeAlien = 2
        else
          typeAlien = 1
        end
        
        local colonne = math.random(1,16)
        local isCoordPresent = false
        local nPos
        if #posAlien > 0 then
          for nPos = 1, #posAlien do
            if posAlien[nPos] == colonne then
              isCoordPresent = true
            end
          end
        end
        if isCoordPresent == false then
          local showAlien = true
          -- cas des tourelles qui doivent être placées sur une surface
          if typeAlien == 3 then
            if niveau[ligne][colonne] == 0 then
              showAlien = false
            end
          end
          if showAlien == true then
            table.insert(posAlien, colonne)
            CreateAlien(typeAlien, colonne * 32, -(32 / 2) - (32 * (ligne - 1)) )
          end
        end
      end
    end
    -- Purge de posAlien
    for n=#posAlien, 1, -1 do
      table.remove(posAlien, n)
    end
  end
  
  CreateAlien(10, largeur/2, -(32 / 2) - (32 * (nbLignes - 1)) )

end