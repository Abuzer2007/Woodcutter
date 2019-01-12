local Woodcutter = {}
local KostyaUtils = require("KostyaUtils/Utils")
Woodcutter.TrigerActiv =      Menu.AddOption({"Utility","Woodcutter"}, "01) Activity script", "")
Woodcutter.Slider =           Menu.AddOption({"Utility","Woodcutter"}, "02) Mode activity", "", 0, 1, 1)
Woodcutter.Key =           Menu.AddKeyOption({"Utility","Woodcutter"}, "03) Tree felling button", Enum.ButtonCode.BUTTON_CODE_NONE)
Woodcutter.Font = Renderer.LoadFont("Tahoma", 30, Enum.FontWeight.EXTRABOLD)
Menu.SetValueName(Woodcutter.Slider, 0, 'Automatic felling trees')
Menu.SetValueName(Woodcutter.Slider, 1, 'Button only')

function Woodcutter.OnUpdate()
  if not Menu.IsEnabled(Woodcutter.TrigerActiv) then return end
  if not Heroes.GetLocal() or not Engine.IsInGame() or not Entity.IsAlive(Heroes.GetLocal()) --[[ or not GameRules.GetGameState() == 4 ]] then return end
  if Woodcutter.needCreateTable then
    Woodcutter.tabletrees = Trees.GetAll()
    Woodcutter.needCreateTable = false
  else
    if Woodcutter.TimeTriger < GameRules.GetGameTime() then
      if Menu.GetValue(Woodcutter.Slider) == 0 then
        Woodcutter.TreesFelling()
      else
        if Menu.IsKeyDown(Woodcutter.Key) then
          Woodcutter.TreesFelling()
        end
      end
    end
  end
end

function Woodcutter.TreesFelling()
  local artificialtree = Woodcutter.FindTrees()
  if artificialtree and Tree.IsActive(artificialtree) then
    for i = 0,5 do
      local item = NPC.GetItemByIndex(Heroes.GetLocal(), i)
      if item and Abilities.Contains(item) and Ability.IsItem(item) and KostyaUtils.CanUseItem(Heroes.GetLocal(), item) then
        if Ability.GetTargetType(item) & Enum.TargetType.DOTA_UNIT_TARGET_TREE ~= 0 then
          local rangetotree = Ability.GetCastRange(item)
          if Entity.GetAbsOrigin(Heroes.GetLocal()):Distance(Entity.GetAbsOrigin(artificialtree)):Length2D() <= rangetotree then
            Ability.CastTarget(item, artificialtree)
          end
        end
      end
    end
  end
  Woodcutter.TimeTriger = GameRules.GetGameTime() + 0.1
end

function Woodcutter.FindTrees()
  local treesinradius = Trees.InRadius(Entity.GetAbsOrigin(Heroes.GetLocal()), 400, true)
  for _,i in pairs(treesinradius) do
    if not Woodcutter.FindNotTableTree(i) then
      return i
    end
  end
  return nil
end

function Woodcutter.FindNotTableTree(tree)
  for _,j in pairs(Woodcutter.tabletrees) do
    if tree == j and Tree.IsActive(j) then
      return true
    end
  end
  return false
end

function Woodcutter.init()
  Woodcutter.tabletrees = {}
  Woodcutter.needCreateTable = true
  Woodcutter.TimeTriger = 0
end

function Woodcutter.OnGameStart()
  Woodcutter.init()
end
function Woodcutter.OnGameEnd()
  Woodcutter.init()
end
Woodcutter.init()

return Woodcutter