local pointshoot = pointshoot
local zerovec = Vector(0, 0, 0)

local function MWBGetDeployDuration(self, ply) 
    return self:GetAnimLength('Draw')
end

local function MWBGunGetRPM(self)
    return self.Primary.RPM
end

local function MWBGunPlayAttackAnim(self, ply)
    if CLIENT then 
        pointshoot:SetRecoil(-5 * math.abs(self.Primary.Recoil or 1), 0, 0)
    end
    if not IsValid(self:GetViewModel()) then return end 
    self:GetViewModel():PlayAnimation('Fire', true) -- fuck you
    self:SetNextPrimaryFire(0)
    self:EmitSound(self.Primary.Sound or '')
end

local function MWBGunDecrClip(self, ply)
    self:SetClip1(math.max(0, self:Clip1() - 1))
end

local function MWBGunGetClip(self, ply)
    return self:Clip1()
end

local function MWBGunGetBulletInfo(self, ply, start, endpos, dir)
    if not self.Bullet then return end
    local isshotgun = (self.Bullet.NumBullets or 0) > 1
    local spread = self.Primary.Spread or 0
    spread = isvector(spread) and spread or Vector(spread, spread, 0)
    -- print(self.Bullet.NumBullets, spread)
    return {
        Damage = istable(self.Bullet.Damage) and self.Bullet.Damage[1] or nil,
        Spread = isshotgun and spread or zerovec,
        Force = self.Bullet.PhysicsMultiplier,
        Num = self.Bullet.NumBullets,
        Tracer = 0
    }
end

-- 原生开火：MWB 的 Bullets(hitpos) 传 Vector 时精确指向该点并清零散布；
-- 霰弹枪（NumBullets > 1）保留原生散布，走无参 Bullets，把眼角度遮成标记方向
local playerMeta = FindMetaTable('Player')
local mwbAimAngle = Angle(0, 0, 0)
local mwbZeroAngle = Angle(0, 0, 0)

local function MWBAimAngle()
    return mwbAimAngle
end

local function MWBZeroAngle()
    return mwbZeroAngle
end

local function MWBShoot(self, ply, start, endpos, dir)
    if not self.Bullets then
        pointshoot.DefaultShoot(self, ply, start, endpos, dir)
        return
    end

    local bullets = self.Bullet
    if self.HasFlag and self:HasFlag("UsingUnderbarrel") and self.Secondary then
        bullets = self.Secondary.Bullet
    end

    local shotgun = bullets and (bullets.NumBullets or 1) > 1
    if not shotgun then
        self:Bullets(endpos)
        return
    end

    local owner = self:GetOwner() or ply
    if not IsValid(owner) or not playerMeta then
        self:Bullets(endpos)
        return
    end

    local prevEye = playerMeta.EyeAngles
    local prevPunch = playerMeta.GetViewPunchAngles

    mwbAimAngle = dir:Angle()
    playerMeta.EyeAngles = MWBAimAngle
    playerMeta.GetViewPunchAngles = MWBZeroAngle

    local ok = pcall(self.Bullets, self)

    playerMeta.EyeAngles = prevEye
    playerMeta.GetViewPunchAngles = prevPunch

    if not ok then
        self:Bullets(endpos)
    end
end


pointshoot:RegisterWhiteListBase('mg_base', {
    GetDeployDuration = MWBGetDeployDuration,
    GetRPM = MWBGunGetRPM,
    PlayAttackAnim = MWBGunPlayAttackAnim,
    GetBulletInfo = MWBGunGetBulletInfo,
    Shoot = MWBShoot,
    DecrClip = MWBGunDecrClip,
    GetClip = MWBGunGetClip,
})
