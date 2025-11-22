-- Minimal stub asset used by ClientSnakeLoader so studio tests stop
-- yielding forever when the full beam package isn't present.
local BeamAsset = {}

function BeamAsset:getAttachmentConfig()
	return {
		segments = 0,
		width0 = 0,
		width1 = 0,
	}
end

return BeamAsset
