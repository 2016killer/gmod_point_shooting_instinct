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


-- ============= 批量标记 =============
-- 可见性采点: 头 -> 胸 -> 骨盆, 模型没有这些骨骼(非人形)就退化成 0 号骨骼
local SAMPLE_BONES = { 'ValveBiped.Bip01_Head1', 'ValveBiped.Bip01_Spine4', 'ValveBiped.Bip01_Pelvis' }

local function BuildSamples(ent)
    local bones = {}

    for i, name in ipairs(SAMPLE_BONES) do
        local bone = ent:LookupBone(name)
        if bone then
            table.insert(bones, { bone = bone, head = i == 1 })
        end
    end

    -- 0 号骨骼(根)任何 studio 模型都有
    if #bones < 1 then
        bones = { { bone = 0, head = false } }
    end

    ent:SetupBones() -- 客户端实体的骨骼只有被渲染过才新鲜, 这里强制刷一次

    local samples = {}
    for _, entry in ipairs(bones) do
        local pos = ent:GetBonePosition(entry.bone)
        if pos then
            table.insert(samples, { bone = entry.bone, pos = pos, head = entry.head })
        end
    end

    return samples
end

-- 眼睛 -> 采样点打一条和子弹同掩码的射线, 命中目标才算可见
local function GetVisibleSample(ply, ent)
    local eye = ply:EyePos()

    for _, sample in ipairs(BuildSamples(ent)) do
        local tr = util.TraceLine({
            start = eye,
            endpos = sample.pos,
            mask = MASK_SHOT,
            filter = ply,
        })

        if tr.Entity == ent then
            return sample
        end
    end

    return nil
end

-- 一键标记范围内所有敌人, 返回 true 表示标记完没弹药了, 已请求执行
function SWEP:MarkAllEnemies(range, ang)
    local owner = self:GetOwner()
    if not IsValid(owner) or not self.Clip or self.Clip <= 0 then
        return false
    end

    -- 不开就不做任何射线检测
    local visibleCvar = GetConVar('ps_markall_visible')
    local visibleOnly = visibleCvar and visibleCvar:GetBool()

    local pos = owner:GetPos()
    local targets = {}
    for _, ent in ipairs(ents.FindInCone(pos, owner:GetAimVector(), range, math.cos(math.rad(ang)))) do
        if IsEnemy(owner, ent) then
            table.insert(targets, ent)
        end
    end

    table.sort(targets, function(a, b) return pos:DistToSqr(a:GetPos()) < pos:DistToSqr(b:GetPos()) end)

    local firstMark
    for _, ent in ipairs(targets) do
        if self.Clip <= 0 then break end

        local mark
        if visibleOnly then
            local sample = GetVisibleSample(owner, ent)
            if sample then
                mark = { sample.head, sample.bone, ent, 0 }
            end
        else
            -- 有头骨就标头, 否则标根骨骼
            local bone = ent:LookupBone('ValveBiped.Bip01_Head1')
            mark = { bone ~= nil, bone or 0, ent, 0 }
        end

        if mark then
            self:CallDoubleEnd('CTSAddMarks', mark)
            self.Clip = self.Clip - 1
            firstMark = firstMark or mark
        end
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
