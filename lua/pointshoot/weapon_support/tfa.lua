local zerovec = Vector(0, 0, 0)

local function TFAGetDeployDuration(self, ply) 
    local rate = self:GetAnimationRate(ACT_VM_DRAW, nil) or 1
    if rate == 0 then 
        return 0
    end
    
    local vm = ply:GetViewModel()
    if not IsValid(vm) then 
        return 0 
    end

    local seq = vm:SelectWeightedSequence(ACT_VM_DRAW)
    if (seq == -1) then 
        return 0 
    end

    return math.Clamp(vm:SequenceDuration(seq) / rate, 0, 5)
end

local function TFAGunGetRPM(self)
    return self.Primary.RPM
end

local function TFAGunPlayAttackAnim(self, ply)
    if CLIENT then pointshoot:SetRecoil(-5 * math.abs(self.Primary.Recoil or 1), 0, 0) end

    self:MuzzleFlashCustom()
    self:MakeShell()
    self:MuzzleSmoke()
    self:EmitSound(self.Primary.Sound or '')

    local vm = ply:GetViewModel()
    if not IsValid(vm) then return end
    local seq = vm:SelectWeightedSequence(ACT_VM_PRIMARYATTACK)
    if (seq == -1) then return end

    vm:SendViewModelMatchingSequence(seq)
end

local function TFAGunDecrClip(self, ply)
    self:SetClip1(math.max(0, self:Clip1() - 1))
end

local function TFAGunGetClip(self, ply)
    return self:Clip1()
end

local function TFAGunGetBulletInfo(self, ply, start, endpos, dir)
    local isshotgun = (self.Primary.Num or 0) > 1
    local spread = self.Primary.Spread or 0
    spread = isvector(spread) and spread or Vector(spread, spread, 0)
    -- print(self.Primary.Num, spread)
    return {
        Damage = self.Primary.Damage,
        Spread = isshotgun and spread or zerovec,
        Force = self.Primary.Force,
        Num = self.Primary.Num,
        Tracer = 0
    }
end

pointshoot:RegisterWhiteListBase('tfa_gun_base', {
    GetDeployDuration = TFAGetDeployDuration,
    GetRPM = TFAGunGetRPM,
    PlayAttackAnim = TFAGunPlayAttackAnim,
    GetBulletInfo = TFAGunGetBulletInfo,
    DecrClip = TFAGunDecrClip,
    GetClip = TFAGunGetClip,
})

TFAGunGetRPM = nil
TFAGunPlayAttackAnim = nil
TFAGunGetBulletInfo = nil
TFAGunDecrClip = nil
TFAGunGetClip = nil

TFAGetDeployDuration = nil
