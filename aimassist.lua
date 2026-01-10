--// MAX AIM ASSIST (CLIENT-SIDE LIMIT)
getgenv().AimAssist = {
    Enabled = true,

    FOV = 160,

    BaseSmooth = 1,
    SnapSmooth = 1,

    HeadOffset = Vector3.new(0, 0.18, 0),

    Prediction = 0, -- gerakan musuh
}

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

--// Visibility
local function Visible(part)
    local params = RaycastParams.new()
    params.FilterDescendantsInstances = {LocalPlayer.Character}
    params.FilterType = Enum.RaycastFilterType.Blacklist

    local r = workspace:Raycast(
        Camera.CFrame.Position,
        part.Position - Camera.CFrame.Position,
        params
    )
    return not r or r.Instance:IsDescendantOf(part.Parent)
end

--// Get best head target
local function GetTarget()
    local best, distOut = nil, AimAssist.FOV
    local center = Vector2.new(
        Camera.ViewportSize.X/2,
        Camera.ViewportSize.Y/2
    )

    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr.Character then
            local hum = plr.Character:FindFirstChildOfClass("Humanoid")
            local head = plr.Character:FindFirstChild("Head")

            if hum and hum.Health > 0 and head and Visible(head) then
                local pos, onScreen = Camera:WorldToViewportPoint(head.Position)
                if onScreen then
                    local mag = (Vector2.new(pos.X,pos.Y) - center).Magnitude
                    if mag < distOut then
                        distOut = mag
                        best = head
                    end
                end
            end
        end
    end
    return best, distOut
end

--// MAIN LOOP
RunService:BindToRenderStep(
    "MaxAimAssist",
    Enum.RenderPriority.Camera.Value + 2,
    function()
        if not AimAssist.Enabled then return end

        local head, dist = GetTarget()
        if head then
            -- prediction
            local vel = head.AssemblyLinearVelocity or Vector3.zero
            local predictedPos =
                head.Position
                + AimAssist.HeadOffset
                + (vel * AimAssist.Prediction)

            -- adaptive smooth
            local smooth = AimAssist.BaseSmooth
            if dist < 35 then
                smooth = AimAssist.SnapSmooth
            end

            Camera.CFrame = Camera.CFrame:Lerp(
                CFrame.new(Camera.CFrame.Position, predictedPos),
                smooth
            )
        end
    end
)
