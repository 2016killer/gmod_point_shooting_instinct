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
    local data = pointshoot:WeaponParse(self)
    return data and data.RPM
end

local function GunPlayAttackAnim(self, ply)
    local data = pointshoot:WeaponParse(self)
    if not data then return end

    if CLIENT then pointshoot:SetRecoil(-5 * math.abs(data.Recoil or 1), 0, 0) end

    self:EmitSound(data.Sound or '')

    local vm = ply:GetViewModel()
    if not IsValid(vm) then return end
    local seq = vm:SelectWeightedSequence(ACT_VM_PRIMARYATTACK)
    if (seq == -1) then return end

    vm:SendViewModelMatchingSequence(seq)
end

local function GunGetBulletInfo(self, ply, start, endpos, dir)
    local data = pointshoot:WeaponParse(self)
    if not data then return end

    return {
        Damage = data.Damage,
        Spread = data.Spread,
        Force = data.Force,
        Num = data.Num,
        Tracer = 0,
        Dir = (endpos - start):GetNormal(),
    }
end

local function GunGetClip(self, _) return self:Clip1() end
local function GunDecrClip(self, _) self:SetClip1(math.max(0, self:Clip1() - 1)) end

pointshoot:RegisterWhiteList('weapon_pistol', {
    RPM = 800,
    Damage = 10,
    DamageType = DMG_BULLET,
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
    DamageType = DMG_BULLET,
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
    DamageType = DMG_BULLET,
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
    DamageType = DMG_NEVERGIB,
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
    DamageType = bit.bor(DMG_BUCKSHOT, DMG_BULLET),
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
    DamageType = DMG_BULLET,
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
