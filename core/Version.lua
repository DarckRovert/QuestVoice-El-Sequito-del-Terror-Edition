setfenv(1, VoiceOver)
Version = {}

local CLIENT_VERSION, BUILD, _, INTERFACE_VERSION = GetBuildInfo()

Version.Client                  = CLIENT_VERSION
Version.Build                   = BUILD
Version.Interface               = INTERFACE_VERSION or 0
Version.IsAnyLegacy             = true
Version.IsLegacyVanilla         = true

function Version:IsBelowLegacyVersion(version, ...)
    return self.Interface < version or nil
end
function Version:IsRetailOrAboveLegacyVersion(version, ...)
    return self.Interface >= version or nil
end
