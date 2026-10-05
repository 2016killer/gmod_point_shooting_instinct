local zerovec = Vector(0, 0, 0)

local function CW2GetDeployDuration(self, ply) 
    local vm = ply:GetViewModel()
    if not IsValid(vm) then return 0 end

    local seq = vm:SelectWeightedSequence(ACT_VM_DRAW)
    if (seq == -1) then return 0 end

    return math.Clamp(vm:SequenceDuration(seq) * 0.5, 0, 5)
end

local function CW2GunGetRPM(self)
    return 60 / (self.FireDelay or 0.1)
end

local function CW2GunPlayAttackAnim(self, ply)
    if CLIENT then pointshoot:SetRecoil(-5 * math.abs(self.Recoil or 1), 0, 0) end

    self:EmitSound(self:getFireSound() or '')
    self:sendWeaponAnim('fire', self.FireAnimSpeed)
    self:makeFireEffects()
end

local function CW2GunDecrClip(self, ply)
    self:SetClip1(math.max(0, self:Clip1() - 1))
end

local function CW2GunGetClip(self, ply)
    return self:Clip1()
end

local function CW2GunGetBulletInfo(self, ply, start, endpos, dir)
    return {
        Damage = self.Damage,
        Spread = zerovec,
        Force = 1,
        Num = 1,
        Tracer = 0
    }
end

-- 原生开火：玩家方法是挂在 Player 元表上的，实体 GetTable 遮不住，得遮元表
local playerMeta = FindMetaTable('Player')

local zeroAngle = Angle(0, 0, 0)
local cw2AimAngle = Angle(0, 0, 0)
local cw2FakeCommand = { CommandNumber = function() return 0 end }

local function CW2AimAngle()
    return cw2AimAngle
end

local function CW2ZeroAngle()
    return zeroAngle
end

local function CW2FakeCommand()
    return cw2FakeCommand
end

local function CW2Shoot(self, ply, start, endpos, dir)
    if not self.FireBullet or not playerMeta then
        pointshoot.DefaultShoot(self, ply, start, endpos, dir)
        return
    end

    local owner = self.Owner or self:GetOwner() or ply
    if not IsValid(owner) then
        pointshoot.DefaultShoot(self, ply, start, endpos, dir)
        return
    end

    local prevEye = playerMeta.EyeAngles
    local prevPunch = playerMeta.GetViewPunchAngles
    local prevCmd = playerMeta.GetCurrentCommand

    cw2AimAngle = dir:Angle()
    playerMeta.EyeAngles = CW2AimAngle
    playerMeta.GetViewPunchAngles = CW2ZeroAngle
    playerMeta.GetCurrentCommand = CW2FakeCommand

    local ok, err = pcall(self.FireBullet, self, self.Damage or 1, 0, 0, self.Shots or 1)

    playerMeta.EyeAngles = prevEye
    playerMeta.GetViewPunchAngles = prevPunch
    playerMeta.GetCurrentCommand = prevCmd

    if not ok then
        print('[PointShoot] CW2 native fire failed: ' .. tostring(err))
        pointshoot.DefaultShoot(self, ply, start, endpos, dir)
    end
end

pointshoot:RegisterWhiteListBase('cw_base', {
    GetDeployDuration = CW2GetDeployDuration,
    GetRPM = CW2GunGetRPM,
    PlayAttackAnim = CW2GunPlayAttackAnim,
    GetBulletInfo = CW2GunGetBulletInfo,
    Shoot = CW2Shoot,
    DecrClip = CW2GunDecrClip,
    GetClip = CW2GunGetClip,
})
