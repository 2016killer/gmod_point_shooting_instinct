local pointshoot = pointshoot

local function GetDeployDuration(self, ply) 
    local vm = ply:GetViewModel()
    if not IsValid(vm) then 
        return 0 
    end
    
    local seq = vm:SelectWeightedSequence(ACT_VM_DRAW)
    if (seq == -1) then 
        return 0 
    end
    
    return math.max(vm:SequenceDuration(seq) * 0.2, 0)
end

local function GunGetRPM(self) 
    return self.ps_wppdata.RPM 
end

local function GunPlayAttackAnim(self, ply)
    if CLIENT then pointshoot:SetRecoil(-5 * math.abs(self.ps_wppdata.Recoil or 1), 0, 0) end

    self:EmitSound(self.ps_wppdata.Sound or '')

    local vm = ply:GetViewModel()
    if not IsValid(vm) then return end
    local seq = vm:SelectWeightedSequence(ACT_VM_PRIMARYATTACK)
    if (seq == -1) then return end

    vm:SendViewModelMatchingSequence(seq)
end

local function GunGetBulletInfo(self, ply, start, endpos, dir)
    return {
        Damage = self.ps_wppdata.Damage,
        Spread = self.ps_wppdata.Spread,
        Force = self.ps_wppdata.Force,
        Num = self.ps_wppdata.Num,
        Tracer = 0,
        Dir = (endpos - start):GetNormal(),
    }
end

local function GunGetClip(self, _) return self:Clip1() end
local function GunDecrClip(self, _) self:SetClip1(math.max(0, self:Clip1() - 1)) end

pointshoot:RegisterWhiteList('weapon_pistol', {
    RPM = 800,
    Damage = 10,
    Force = 1,
    Sound = 'Weapon_Pistol.Single',
    Recoil = 0.5,

    GetDeployDuration = GetDeployDuration,
    GetRPM = GunGetRPM,
    PlayAttackAnim = GunPlayAttackAnim,
    GetBulletInfo = GunGetBulletInfo,
    DecrClip = GunDecrClip,
    GetClip = GunGetClip,
})

pointshoot:RegisterWhiteList('weapon_357', {
    RPM = 300,
    Damage = 60,
    Force = 25,
    Sound = 'Weapon_357.Single',
    Recoil = 2,

    GetDeployDuration = GetDeployDuration,
    GetRPM = GunGetRPM,
    PlayAttackAnim = GunPlayAttackAnim,
    GetBulletInfo = GunGetBulletInfo,
    DecrClip = GunDecrClip,
    GetClip = GunGetClip,
})

pointshoot:RegisterWhiteList('weapon_ar2', {
    RPM = 600,
    Damage = 20,
    Force = 1,
    Sound = 'Weapon_AR2.Single',
    Recoil = 1,

    GetDeployDuration = GetDeployDuration,
    GetRPM = GunGetRPM,
    PlayAttackAnim = GunPlayAttackAnim,
    GetBulletInfo = GunGetBulletInfo,
    DecrClip = GunDecrClip,
    GetClip = GunGetClip,
})

pointshoot:RegisterWhiteList('weapon_crossbow', {
    RPM = 180,
    Damage = 150,
    Force = 50,
    Sound = 'Weapon_Crossbow.Single',
    Recoil = 5,

    GetDeployDuration = GetDeployDuration,
    GetRPM = GunGetRPM,
    PlayAttackAnim = GunPlayAttackAnim,
    GetBulletInfo = GunGetBulletInfo,
    DecrClip = GunDecrClip,
    GetClip = GunGetClip,
})

pointshoot:RegisterWhiteList('weapon_shotgun', {
    RPM = 280,
    Damage = 45,
    Force = 50,
    Sound = 'Weapon_Shotgun.Single',
    Spread = Vector(0.05, 0.05, 0),
    Num = 8,
    Recoil = 3,

    GetDeployDuration = GetDeployDuration,
    GetRPM = GunGetRPM,
    PlayAttackAnim = GunPlayAttackAnim,
    GetBulletInfo = GunGetBulletInfo,
    DecrClip = GunDecrClip,
    GetClip = GunGetClip,
})

pointshoot:RegisterWhiteList('weapon_smg1', {
    RPM = 1000,
    Damage = 6,
    Force = 1,
    Sound = 'Weapon_SMG1.Single',
    Recoil = 0.5,

    GetDeployDuration = GetDeployDuration,
    GetRPM = GunGetRPM,
    PlayAttackAnim = GunPlayAttackAnim,
    GetBulletInfo = GunGetBulletInfo,
    DecrClip = GunDecrClip,
    GetClip = GunGetClip,
})
