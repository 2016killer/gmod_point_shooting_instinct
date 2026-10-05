SWEP:RegisterClientToServer('CTSAddMarks')

function SWEP:CTSAddMarks(mark)
    self.Marks = self.Marks or {}
    table.insert(self.Marks, mark)
end


local function IsEnemy(ply, ent)
    if ent == ply or not IsValid(ent) then
        return false
    end

    if ent:IsPlayer() then
        -- 同队且不是 0 队(沙盒/死斗)时算友军
        return ent:Alive() and not (ent:Team() == ply:Team() and ent:Team() ~= 0)
    end

    if ent:IsNPC() or ent:IsNextBot() then
        return ent:Health() > 0 and (ent.Disposition == nil or ent:Disposition() == D_HT)
    end

    return false
end


-- 一键标记范围内所有敌人, 返回 true 表示标记完没弹药了, 已请求执行
function SWEP:MarkAllEnemies(range)
    local owner = self:GetOwner()
    if not IsValid(owner) or not self.Clip or self.Clip <= 0 then
        return false
    end

    local pos = owner:GetPos()
    local targets = {}
    for _, ent in ipairs(ents.FindInCone(pos, owner:GetAimVector(), range, math.cos(math.rad(30)))) do
        if IsEnemy(owner, ent) then
            table.insert(targets, ent)
        end
    end

    table.sort(targets, function(a, b) return pos:DistToSqr(a:GetPos()) < pos:DistToSqr(b:GetPos()) end)

    local firstMark
    for _, ent in ipairs(targets) do
        if self.Clip <= 0 then break end

        -- 有头骨就标头, 否则标根骨骼
        local bone = ent:LookupBone('ValveBiped.Bip01_Head1')
        local mark = { bone ~= nil, bone or 0, ent, 0 }

        self:CallDoubleEnd('CTSAddMarks', mark)
        self.Clip = self.Clip - 1
        firstMark = firstMark or mark
    end

    if firstMark then
        self:MarkEffect(firstMark)
    end

    if self.Clip <= 0 then
        self.LockThink = true
        self:CallDoubleEnd('CTSExecuteRequest', self.Power)
        self:ClearPowerCost()
        return true
    end

    return false
end
