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

-- 原生开火：临时接管方向/散布，让 TFA 自己精确打向标记
local nativeAimDir = Vector(0, 0, 0)

local function NativeAimVector()
    return nativeAimDir
end

local function NativeZeroCone()
    return 0, 0
end

local function TFAShoot(self, ply, start, endpos, dir)
    if not self.ShootBulletInformation then return end

    local tbl = self:GetTable()
    local prevAim = tbl.GetAimVector
    local prevCone = tbl.CalculateConeRecoil

    nativeAimDir = dir
    tbl.GetAimVector = NativeAimVector
    tbl.CalculateConeRecoil = NativeZeroCone

    local ok, err = pcall(self.ShootBulletInformation, self)

    tbl.GetAimVector = prevAim
    tbl.CalculateConeRecoil = prevCone

    if not ok then
        print('[PointShoot] TFA native fire failed: ' .. tostring(err))
    end
end

pointshoot:RegisterWhiteListBase('tfa_gun_base', {
    GetDeployDuration = TFAGetDeployDuration,
    GetRPM = TFAGunGetRPM,
    PlayAttackAnim = TFAGunPlayAttackAnim,
    Shoot = TFAShoot,
    DecrClip = TFAGunDecrClip,
    GetClip = TFAGunGetClip,
})
