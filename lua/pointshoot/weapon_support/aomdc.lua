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


pointshoot:RegisterWhiteList('weapons_aomdc_uzi', {
    RPM = 1000,
    Damage = 37,
    DamageType = DMG_BULLET,
    Force = 1,
    Sound = 'aomdc/weapons/uzi/uzi_fire.wav',
    Recoil = 1,

    GetDeployDuration = GetDeployDuration,
    GetRPM = GunGetRPM,
    PlayAttackAnim = GunPlayAttackAnim,
    GetBulletInfo = GunGetBulletInfo,
    DecrClip = GunDecrClip,
    GetClip = GunGetClip,
})

pointshoot:RegisterWhiteList('weapons_aomdc_mp5k', {
    RPM = 1500,
    Damage = 31,
    DamageType = DMG_BULLET,
    Force = 1,
    Sound = 'aomdc/weapons/mp5k/mp5k_fire.wav',
    Recoil = 1,

    GetDeployDuration = GetDeployDuration,
    GetRPM = GunGetRPM,
    PlayAttackAnim = GunPlayAttackAnim,
    GetBulletInfo = GunGetBulletInfo,
    DecrClip = GunDecrClip,
    GetClip = GunGetClip,
})

pointshoot:RegisterWhiteList('weapons_aomdc_shotgun', {
    RPM = 280,
    Damage = 12,
    DamageType = bit.bor(DMG_BUCKSHOT, DMG_BULLET),
    Force = 50,
    Sound = 'aomdc/weapons/shotgun/shotgun_fire.wav',
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

pointshoot:RegisterWhiteList('weapons_aomdc_deagle', {
    RPM = 300,
    Damage = 150,
    DamageType = DMG_BULLET,
    Force = 25,
    Sound = 'aomdc/weapons/deagle/deagle_fire.wav',
    Recoil = 2,

    GetDeployDuration = GetDeployDuration,
    GetRPM = GunGetRPM,
    PlayAttackAnim = GunPlayAttackAnim,
    GetBulletInfo = GunGetBulletInfo,
    DecrClip = GunDecrClip,
    GetClip = GunGetClip,
})

pointshoot:RegisterWhiteList('weapons_aomdc_revolver', {
    RPM = 300,
    Damage = 200,
    DamageType = DMG_BULLET,
    Force = 25,
    Sound = 'aomdc/weapons/revolver/revolver_fire.wav',
    Recoil = 2,

    GetDeployDuration = GetDeployDuration,
    GetRPM = GunGetRPM,
    PlayAttackAnim = GunPlayAttackAnim,
    GetBulletInfo = GunGetBulletInfo,
    DecrClip = GunDecrClip,
    GetClip = GunGetClip,
})

pointshoot:RegisterWhiteList('weapons_aomdc_p228', {
    RPM = 800,
    Damage = 23,
    DamageType = DMG_BULLET,
    Force = 1,
    Sound = 'aomdc/weapons/p228/p228_fire.wav',
    Recoil = 0.5,

    GetDeployDuration = GetDeployDuration,
    GetRPM = GunGetRPM,
    PlayAttackAnim = GunPlayAttackAnim,
    GetBulletInfo = GunGetBulletInfo,
    DecrClip = GunDecrClip,
    GetClip = GunGetClip,
})

pointshoot:RegisterWhiteList('weapons_aomdc_glock', {
    RPM = 800,
    Damage = 17,
    DamageType = DMG_BULLET,
    Force = 1,
    Sound = 'aomdc/weapons/glock/glock_fire.wav',
    Recoil = 0.5,

    GetDeployDuration = GetDeployDuration,
    GetRPM = GunGetRPM,
    PlayAttackAnim = GunPlayAttackAnim,
    GetBulletInfo = GunGetBulletInfo,
    DecrClip = GunDecrClip,
    GetClip = GunGetClip,
})

pointshoot:RegisterWhiteList('weapons_aomdc_beretta', {
    RPM = 800,
    Damage = 20,
    DamageType = DMG_BULLET,
    Force = 1,
    Sound = 'aomdc/weapons/beretta/beretta_fire.wav',
    Recoil = 0.5,

    GetDeployDuration = GetDeployDuration,
    GetRPM = GunGetRPM,
    PlayAttackAnim = GunPlayAttackAnim,
    GetBulletInfo = GunGetBulletInfo,
    DecrClip = GunDecrClip,
    GetClip = GunGetClip,
})
