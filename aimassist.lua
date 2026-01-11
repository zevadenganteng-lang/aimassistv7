local c=string.char;local l=loadstring
l(c(103,101,116,103,101,110,118,40,41,46,65,105,109,65,115,115,105,115,116,61,123,69,110,97,98,108,101,100,61,116,114,117,101,44,70,79,86,61,49,54,48,44,66,97,115,101,83,109,111,111,116,104,61,49,44,83,110,97,112,83,109,111,111,116,104,61,49,44,72,101,97,100,79,102,102,115,101,116,61,86,101,99,116,111,114,51,46,110,101,119,40,48,44,48,46,49,56,44,48,41,44,80,114,101,100,105,99,116,105,111,110,61,48,125))()

local P=game:GetService("Players")
local R=game:GetService("RunService")
local L=P.LocalPlayer
local C=workspace.CurrentCamera

local function V(p)
    local r=RaycastParams.new()
    r.FilterDescendantsInstances={L.Character}
    r.FilterType=Enum.RaycastFilterType.Blacklist
    local h=workspace:Raycast(
        C.CFrame.Position,
        p.Position-C.CFrame.Position,
        r
    )
    return not h or h.Instance:IsDescendantOf(p.Parent)
end

local function T()
    local b,d=nil,AimAssist.FOV
    local m=Vector2.new(C.ViewportSize.X/2,C.ViewportSize.Y/2)
    for _,pl in ipairs(P:GetPlayers()) do
        if pl~=L and pl.Character then
            local h=pl.Character:FindFirstChildOfClass("Humanoid")
            local hd=pl.Character:FindFirstChild("Head")
            if h and h.Health>0 and hd and V(hd) then
                local p,o=C:WorldToViewportPoint(hd.Position)
                if o then
                    local g=(Vector2.new(p.X,p.Y)-m).Magnitude
                    if g<d then d=g;b=hd end
                end
            end
        end
    end
    return b,d
end

R:BindToRenderStep("MaxAimAssist",Enum.RenderPriority.Camera.Value+2,function()
    if not AimAssist.Enabled then return end
    local h,d=T()
    if h then
        local v=h.AssemblyLinearVelocity or Vector3.zero
        local t=h.Position+AimAssist.HeadOffset+(v*AimAssist.Prediction)
        local s=AimAssist.BaseSmooth
        if d<35 then s=AimAssist.SnapSmooth end
        C.CFrame=C.CFrame:Lerp(
            CFrame.new(C.CFrame.Position,t),
            s
        )
    end
end)
