local zerovec = Vector(0, 0, 0)

local function ARCCWGetDeployDuration(self, ply) 
    local vm = ply:GetViewModel()
    if not IsValid(vm) then return 0 end

    local seq = vm:SelectWeightedSequence(ACT_VM_DRAW)
    if (seq == -1) then return 0 end

    return math.Clamp(vm:SequenceDuration(seq), 0, 5)
end


local function ARCCWGunGetRPM(self)
    return math.Round(60 / self:GetFiringDelay())
end

local function ARCCWGunPlayAttackAnim(self, ply)
    if CLIENT then pointshoot:SetRecoil(-5 * math.abs(self.Recoil or 1), 0, 0) end

    self:DoShootSound()
    self:DoShellEject()
    self:DoEffects()

    local vm = ply:GetViewModel()
    if not IsValid(vm) then return end
    local seq = vm:SelectWeightedSequence(ACT_VM_PRIMARYATTACK)
    if (seq == -1) then return end

    vm:SendViewModelMatchingSequence(seq)
end

local function ARCCWGunDecrClip(self, ply)
    self:SetClip1(math.max(0, self:Clip1() - 1))
end

local function ARCCWGunGetClip(self, ply)
    return self:Clip1()
end

local function ARCCWGunGetBulletInfo(self, ply, start, endpos, dir)
    local isshotgun = self:GetIsShotgun()
    local spread = ArcCW.MOAToAcc * self:GetBuff("AccuracyMOA")
    -- print(isshotgun, spread)
    return {
        Damage = self.Damage,
        Spread = isshotgun and Vector(spread, spread, 0) or zerovec,
        Force = self.Force,
        Num = self.Num,
        Tracer = 0
    }
end

-- 原生开火：构建 ArcCW 自己的 bullet 表，交给 DoPrimaryFire；强制 hitscan
-- （NeverPhysBullet=true）以避开物理子弹里的 owner:GetCurrentCommand()
local arcCWWeapon, arcCWOwner, arcCWDir, arcCWData, arcCWCount, arcCWShotgun, arcCWSpread

local function ARCCWCallback(att, tr, dmg)
    ArcCW:BulletCallback(att, tr, dmg, arcCWWeapon)
end

local function ARCCWFireLoop()
    local self = arcCWWeapon
    local owner = arcCWOwner
    local dir = arcCWDir

    local num = math.max(1, (self:GetBuff("Num") or 1) + (self:GetBuff_Add("Add_Num") or 0))
    local sglove = math.ceil(num / 3)
    local dmg = self:GetBuff("Damage") or 0
    local dmgmin = self:GetBuff("DamageMin") or dmg
    local bnum = self:GetBuff("Num") or 1

    arcCWCount = num
    arcCWShotgun = num > 1
    arcCWSpread = ArcCW.MOAToAcc * (self:GetBuff("AccuracyMOA") or 0)
    arcCWData = {
        Attacker = owner,
        Dir = dir,
        Src = self:GetShootSrc(),
        Spread = zerovec,
        Damage = 0,
        Num = 1,
        Force = self:GetBuff("Force", true) or math.Clamp(((50 / sglove) / ((dmg + dmgmin) / (bnum * 2))) * sglove, 1, 3),
        Distance = self:GetBuff("Distance", true) or 33300,
        HullSize = self:GetBuff("HullSize"),
        Tracer = self:GetBuff_Override("Override_TracerNum", self.TracerNum) or 0,
        TracerName = self:GetBuff_Override("Override_Tracer", self.Tracer),
        Weapon = self,
        Callback = ARCCWCallback,
    }

    for _ = 1, num do
        if arcCWShotgun and arcCWSpread > 0 then
            local dv = Vector(arcCWDir)
            arcCWWeapon:ApplyRandomSpread(dv, arcCWSpread)
            arcCWData.Dir = dv
        else
            arcCWData.Dir = arcCWDir
        end
        arcCWWeapon:DoPrimaryFire(false, arcCWData)
    end
end

local function ARCCWShoot(self, ply, start, endpos, dir)
    if not self.DoPrimaryFire then
        pointshoot.DefaultShoot(self, ply, start, endpos, dir)
        return
    end

    local owner = self:GetOwner() or ply
    if not IsValid(owner) then
        pointshoot.DefaultShoot(self, ply, start, endpos, dir)
        return
    end

    local tbl = self:GetTable()
    local prevNever = tbl.NeverPhysBullet

    arcCWWeapon = self
    arcCWOwner = owner
    arcCWDir = dir

    tbl.NeverPhysBullet = true
    local ok, err = pcall(ARCCWFireLoop)

    tbl.NeverPhysBullet = prevNever

    if not ok then
        print('[PointShoot] ArcCW native fire failed: ' .. tostring(err))
        pointshoot.DefaultShoot(self, ply, start, endpos, dir)
    end
end

pointshoot:RegisterWhiteListBase('arccw_base', {
    GetDeployDuration = ARCCWGetDeployDuration,
    GetRPM = ARCCWGunGetRPM,
    PlayAttackAnim = ARCCWGunPlayAttackAnim,
    GetBulletInfo = ARCCWGunGetBulletInfo,
    Shoot = ARCCWShoot,
    DecrClip = ARCCWGunDecrClip,
    GetClip = ARCCWGunGetClip,
})
