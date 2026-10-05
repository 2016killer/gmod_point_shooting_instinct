local zerovec = Vector(0, 0, 0)

local function TFAGetStat(weapon, key, default)
    if weapon.GetStatL then
        local value = weapon:GetStatL(key)
        if value ~= nil then return value end
    end
    return default
end

-- 伤害走 TFA 的管线：GetStatL(配件后) × sv_tfa_damage_multiplier × 随机浮动
local function TFAGetDamage(weapon)
    local damage = TFAGetStat(weapon, 'Primary.Damage', 0)

    local mult = GetConVar('sv_tfa_damage_multiplier')
    if mult then damage = damage * mult:GetFloat() end

    local min = GetConVar('sv_tfa_damage_mult_min')
    local max = GetConVar('sv_tfa_damage_mult_max')
    if min and max then
        damage = damage * util.SharedRandom('TFA_Bullet_RandomDamageMult' .. CurTime(), min:GetFloat(), max:GetFloat(), weapon:EntIndex())
    end

    return damage
end

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
    local num = math.max(1, TFAGetStat(self, 'Primary.NumShots', 1))
    local spread = TFAGetStat(self, 'Primary.Spread', 0)
    spread = isvector(spread) and spread or Vector(spread, spread, 0)

    local damage = TFAGetDamage(self)
    local force = TFAGetStat(self, 'Primary.Force', math.sqrt(damage / 16) * 3 / math.sqrt(num))
    local forceMul = GetConVar('sv_tfa_force_multiplier')
    if forceMul then force = force * forceMul:GetFloat() end

    return {
        Damage = damage,
        Spread = num > 1 and spread or zerovec,
        Force = force,
        Num = num,
        Tracer = 0
    }
end

-- ============= 穿透 =============
-- 抄自 TFA 的 SWEP.MainBullet:Penetrate，精简版：读武器参数（PenetrationPower /
-- PenetrationMaterials / PenetrationMultiplier / MaxSurfacePenetrationCount），
-- cvar 只做开关、上限、强度倍率。不做 ricochet / 门破坏 / 穿透贴花 / 弹道模块。

local TFA_PEN_MATERIALS = {
    [MAT_DEFAULT] = 1,
    [MAT_VENT] = 0.4,
    [MAT_METAL] = 0.6,
    [MAT_WOOD] = 0.2,
    [MAT_PLASTIC] = 0.23,
    [MAT_FLESH] = 0.48,
    [MAT_CONCRETE] = 0.87,
    [MAT_GLASS] = 0.16,
    [MAT_SAND] = 1,
    [MAT_SLOSH] = 1,
    [MAT_DIRT] = 0.95,
    [MAT_FOLIAGE] = 0.9,
}

local TFA_PEN_AMMO_MUL = {
    pistol = 0.4,
    ['357'] = 1.75,
    smg1 = 0.34,
    ar2 = 1.1,
    buckshot = 0.3,
    airboatgun = 2.25,
    sniperpenetratedround = 3,
}

local function TFAGetPenMultiplier(weapon, mat)
    local materials = (weapon.Primary and weapon.Primary.PenetrationMaterials) or TFA_PEN_MATERIALS
    local fac = materials[mat or MAT_DEFAULT] or materials[MAT_DEFAULT] or 1
    local mul = TFAGetStat(weapon, 'Primary.PenetrationMultiplier', weapon.Primary and weapon.Primary.PenetrationMultiplier or 1)
    return fac * (mul or 1)
end

local function TFAGetPenPower(weapon, force)
    local power = TFAGetStat(weapon, 'Primary.PenetrationPower', weapon.Primary and weapon.Primary.PenetrationPower)
    if power and power > 0 then return power end

    local ammo = TFAGetStat(weapon, 'Primary.Ammo', weapon.Primary and weapon.Primary.Ammo or '')
    local mul = TFA_PEN_AMMO_MUL[string.lower(ammo or '')] or 1
    return math.sqrt((force or 1) * 200 * mul)
end

local function TFAGetPenLimit(weapon)
    local hard = GetConVar('sv_tfa_penetration_hardlimit')
    local limit = hard and hard:GetInt() or 2
    local weaponLimit = TFAGetStat(weapon, 'Primary.MaxSurfacePenetrationCount', weapon.Primary and weapon.Primary.MaxSurfacePenetrationCount)
    return math.min(limit, weaponLimit or math.huge, 16)
end

local function TFAPenetrationEnabled()
    local cv = GetConVar('sv_tfa_bullet_penetration')
    return cv == nil or cv:GetBool()
end

local TFABuildBullet, TFAPenetrate

TFABuildBullet = function(ply, weapon, params)
    local bullet = {
        Attacker = ply,
        Inflictor = weapon,
        Src = params.src,
        Dir = params.dir,
        Spread = params.spread or zerovec,
        Num = params.num or 1,
        Tracer = 0,
        Force = params.force,
        Damage = params.damage,
        InitialDamage = params.initialDamage,
        InitialForce = params.initialForce,
        InitialPosition = params.initialPosition,
        InitialPenetrationPower = params.initialPower,
        PenetrationPower = params.power,
        PenetrationCount = params.count,
        HullSize = params.hullsize,
        AmmoType = params.ammo,
        HasAppliedRange = false,
    }

    bullet.Callback = function(attacker, trace, dmginfo)
        if not IsValid(weapon) then return end
        dmginfo:SetInflictor(weapon)
        if weapon.CalculateFalloff then
            dmginfo:SetDamage(dmginfo:GetDamage() * weapon:CalculateFalloff(bullet.InitialPosition, trace.HitPos))
        end

        local hitent = trace.Entity
        if SERVER and IsValid(ply) and ply:IsPlayer() and IsValid(hitent) and (hitent:IsPlayer() or hitent:IsNPC() or type(hitent) == 'NextBot') then
            net.Start('tfaHitmarker')
            net.Send(ply)
        end

        TFAPenetrate(ply, weapon, bullet, trace)
    end

    ply:FireBullets(bullet)
end

TFAPenetrate = function(ply, weapon, bullet, trace)
    if not TFAPenetrationEnabled() then return end
    if bullet.PenetrationCount >= TFAGetPenLimit(weapon) then return end

    local dir = (trace.StartPos and (trace.HitPos - trace.StartPos) or bullet.Dir)
    if dir:LengthSqr() < 0.0001 then
        dir = bullet.Dir
    else
        dir = dir:GetNormalized()
    end

    local mult = TFAGetPenMultiplier(weapon, trace.MatType)
    if mult <= 0 then return end

    local powerMul = GetConVar('sv_tfa_bullet_penetration_power_mul')
    powerMul = powerMul and powerMul:GetFloat() or 1
    local desired = math.Clamp(bullet.PenetrationPower / mult, 0, math.Clamp(powerMul * 100, 1000, 8000))

    local ent = trace.Entity
    local isEnt = IsValid(ent) and not trace.HitWorld
    local exitPos

    if isEnt then
        local far = trace.HitPos + dir * desired
        local back = util.TraceLine({
            start = far,
            endpos = trace.HitPos,
            mask = MASK_SHOT,
            ignoreworld = true,
            filter = function(e) return e == ent end,
        })
        if back.Hit and back.HitPos:Distance(far) > 0.01 then
            exitPos = back.HitPos
        end
    else
        local tr = util.TraceLine({
            start = trace.HitPos + dir * 0.5,
            endpos = trace.HitPos + dir * desired,
            mask = MASK_SHOT,
            filter = { ply, weapon },
        })
        if tr.Hit then
            exitPos = tr.HitPos
        end
    end

    if not exitPos then return end

    local thickness = exitPos:Distance(trace.HitPos)
    if thickness < 0.5 then return end

    local loss = thickness * mult
    if bullet.PenetrationPower - loss <= 0 then return end

    local newPower = bullet.PenetrationPower - loss
    local mfac = newPower / bullet.InitialPenetrationPower
    local throughMul = GetConVar('ps_damage_penetration_mul')
    throughMul = throughMul and throughMul:GetFloat() or 1

    TFABuildBullet(ply, weapon, {
        src = exitPos + dir * 4,
        dir = dir,
        spread = zerovec,
        num = 1,
        force = bullet.InitialForce * mfac,
        damage = bullet.InitialDamage * throughMul * mfac,
        initialDamage = bullet.InitialDamage,
        initialForce = bullet.InitialForce,
        initialPosition = bullet.InitialPosition,
        initialPower = bullet.InitialPenetrationPower,
        power = newPower,
        count = bullet.PenetrationCount + 1,
        hullsize = bullet.HullSize,
        ammo = bullet.AmmoType,
    })
end

local function TFAShoot(self, ply, start, endpos, dir)
    local info = self:ps_wppGetBulletInfo(ply, start, endpos, dir)
    if not info then return end

    local damage = (info.Damage or 1) * GetConVar('ps_damage_mul'):GetFloat()
    local force = info.Force or 1
    local power = TFAGetPenPower(self, force)

    TFABuildBullet(ply, self, {
        src = start,
        dir = dir,
        spread = info.Spread or zerovec,
        num = math.max(1, info.Num or 1),
        force = force,
        damage = damage,
        initialDamage = damage,
        initialForce = force,
        initialPosition = Vector(start),
        initialPower = power,
        power = power,
        count = 0,
        hullsize = TFAGetStat(self, 'Primary.HullSize', self.Primary and self.Primary.HullSize or 0),
        ammo = TFAGetStat(self, 'Primary.Ammo', self.Primary and self.Primary.Ammo or ''),
    })
end

pointshoot:RegisterWhiteListBase('tfa_gun_base', {
    GetDeployDuration = TFAGetDeployDuration,
    GetRPM = TFAGunGetRPM,
    PlayAttackAnim = TFAGunPlayAttackAnim,
    GetBulletInfo = TFAGunGetBulletInfo,
    Shoot = TFAShoot,
    DecrClip = TFAGunDecrClip,
    GetClip = TFAGunGetClip,
})

TFAGunGetRPM = nil
TFAGunPlayAttackAnim = nil
TFAGunGetBulletInfo = nil
TFAGunDecrClip = nil
TFAGunGetClip = nil

TFAGetDeployDuration = nil
