require("animation")

function UpdateMenu()
  if musicGame:isPlaying() == false then
    musicGame:play()
  end
end

function DrawPauseMenu()
  love.graphics.setColor(127,127,127,100)
  love.graphics.draw(imgPauseMenu, 0, 0)
end

function DrawMenu()
  love.graphics.draw(imgBackground[1], 0, 0)
  
  -- Affichage des vaisseaux héros en train de tirer sur des ennemis en scrolling horizontal
  ShowIntroduction()
  
  -- activation de la touche espace
  camera.x = 0
  --pause = true
  
  -- Affichage du texte à l'écran
  love.graphics.setColor(0, 0, 255, 255)
  love.graphics.printf("Larry Shooter", largeur/4, hauteur/4, largeur/4, "center", 0, 2, 2)
  love.graphics.setColor(255, 255, 255, 255)
  love.graphics.printf("GameCodeur", largeur/4, hauteur/2, largeur/2, "center")
  
  local couleur = { r=0, g=255, b=0 }
  ClignoterTexte("Appuyer sur 'Espace' pour commencer", 50, couleur, largeur/4, hauteur*(3/4), largeur/2, "center")
end

function DrawGameOver()
  love.graphics.draw(imgGameOver, 0, 0)
  ClearLevel()
  StartGame(false)
end

function DrawVictory()
  love.graphics.draw(imgVictory, 0, 0)
  ClearLevel()
  StartGame(false)
end

function DrawChoiceMenu()
  love.graphics.draw(imgBackground[2], 0, 0)
  
  love.graphics.setColor(0, 0, 255, 255)
  love.graphics.printf("Sélectionner votre vaisseau", largeur/4, hauteur/8, largeur/4, "center", 0, 2, 2)
  love.graphics.setColor(255, 255, 255, 255)
  love.graphics.printf("Appuyer sur 'Droite' ou 'Gauche' pour changer de vaisseau", largeur/4, hauteur/3.5, largeur/2, "center")

  love.graphics.draw(imgShips[1], largeur/3 - imgShips[1]:getWidth()/2, hauteur/2 - imgShips[1]:getHeight()*2/3, 0, 2, 2)
  love.graphics.draw(imgShips[2], largeur*2/3 - imgShips[2]:getWidth()/2, hauteur/2 - imgShips[2]:getHeight()*2/3, 0, 2, 2)
  
  local posArrow = largeur/3
  if heros.ship == 1 then
    posArrow = largeur/3
  elseif heros.ship == 2 then
    posArrow = largeur*2/3
  end
  love.graphics.draw(imgArrow, posArrow, hauteur*2/3)

  -- clignotement du texte
  local couleur = { r=0, g=255, b=0 }
  ClignoterTexte("Appuyer sur 'Espace' pour commencer", 50, couleur, largeur/4, hauteur*(3/4), largeur/2, "center")
end

function ClignoterTexte(pTexte, pDelai, pColor, pX, pY, pLimit, pAlignMode)
  if pTexte == "" or pDelai <= 0 then return false end
  if pColor.r < 0 or pColor.r > 255 then return false end
  if pColor.g < 0 or pColor.g > 255 then return false end
  if pColor.b < 0 or pColor.b > 255 then return false end
  
  timerMainMenu = timerMainMenu + 1
  if timerMainMenu % pDelai == 0 then
    if showSpaceMsg == false then
      showSpaceMsg = true
    else
      showSpaceMsg = false
    end
  end
  if showSpaceMsg == true then
    love.graphics.setColor(pColor.r, pColor.g, pColor.b, 255)
    love.graphics.printf(pTexte, pX, pY, pLimit, pAlignMode)
  end
  love.graphics.setColor(255, 255, 255, 255)
  
  return true
end

function DrawResultsMenu(pHeros)
  local n, file
  local index = 0
  local eof = false
  local scores = {}
  scores.val = 0
  scores.date = ""
  -- Lecture de la table des scores
  if not love.filesystem.exists("score.txt") then
    file = io.open("score.txt", "w")
    file:close()
  end
  
  file = io.open("score.txt", "r+")

  local temp = file:read()
  if temp == nil then
    eof = true
  end
  while eof == false do
    local date, val
    for n=1, string.len(temp) do
      local chk = string.sub(temp, n, n)
      local c1 = string.sub(temp, n+1, n+1)
      local c2 = string.sub(temp, n+2, n+2)
      
      if index % 2 == 0 then
        val = val..(string.byte(c1) - string.byte(chk))
        date = date..(string.byte(c2) - string.byte(chk))
      else
        val = val..(string.byte(c2) - string.byte(chk))
        date = date..(string.byte(c1) - string.byte(chk))
      end
      n = n + 2
    end
    print("date = "..date.."; val = "..val)
    index = index + 1
    temp = file:read()
    if temp == nil then
      eof = true
    end
  end
  
  if #scores > 0 then
    local temp = {}
    -- Comparaison du score
    for n = #scores, 1, -1 do
      if scores[n].val < val then
        scores[n+1] = scores[n]
      else
        -- Insertion du score
        local temp = {}
        temp.val = pHeros.score
        temp.date = os.date("%x")
        score[n] = temp
      end
    end
    -- Effacement du dernier score
    if #scores > 10 then
      while #score > 10 do
        table.remove(scores, #scores)
      end
    end
  else
    print("score = "..pHeros.score)
    -- Insertion du score
    temp = {}
    temp.val = pHeros.score
    temp.date = os.date("%x")
    print("val = "..temp.val.."; date = "..temp.date)
    table.insert(scores,temp)
    print("Score = "..scores[1].val.."; date = "..scores[1].date)
  end
  
  -- Enregistrement de la table des scores
  for n = 1, #scores do
    local str, i
    local sval = string.rep("0", 6 - string.len(scores[n].val))..scores[n].val
    print("sval = "..sval)
    print("score date = "..scores[n].date)
    local sdate = string.sub(scores[n].date, string.find(scores[n].date, "%d%d%d%d%d%d%d%d"))
    for i = 1, string.len(sval) do
      local cv = string.sub(sval, i, i)
      local cd = string.sub(sdate, i, i)
      if n % 2 == 0 then
        local rnd = math.random(128,240)
        -- ivdivdivdivdivdivdivdivd
        str = tostring(rnd)..tostring(rnd+string.byte(cv))..tostring(rnd+string.byte(cd))
      else
        -- idvidvidvidvidvidvidvidv
        str = tostring(rnd)..tostring(rnd+string.byte(cd))..tostring(rnd+string.byte(cv))
      end
    end
  end
end

function DrawCreditsMenu()
  
end