-- FIXED AI SNAKE CODE
-- Main fixes:
-- 1. Removed conflicting boundary avoidance logic
-- 2. Fixed movement pattern initialization bugs
-- 3. Reordered action priorities (collision avoidance before walls)
-- 4. Improved orb seeking stability
-- 5. Simplified boost logic
-- 6. Fixed turn speed calculation stacking

-- === AI METHODS ===
function AISnake:findBestOrb()
	-- ENHANCED: Increase orb seek radius based on personality
	local baseRadius = self.Personality.OrbSeekRadius or 50
	local minDist = baseRadius * 1.5 -- 50% more range for better orb finding
	local nearest = nil
	local headPos = self.HeadParts and self.HeadParts.head and self.HeadParts.head.Position or self.Position

	-- First check spatial grid for regular orbs
	local nearbyEntities = SpatialGrid.QueryRadius(headPos, minDist)

	-- Prioritize untargeted orbs
	local targetedOrbs = {}
	for ai, orb in pairs(AISnake._orbTargets) do
		if ai ~= self and orb and orb.Parent then
			targetedOrbs[orb] = true
		end
	end

	-- PRIORITIZE UPGRADE ORBS (check OrbFolder directly)
	local orbFolder = Workspace:FindFirstChild("OrbFolder")
	if orbFolder then
		for _, orb in pairs(orbFolder:GetChildren()) do
			if orb:IsA("BasePart") and orb.Name == "UpgradeOrb" and not targetedOrbs[orb] then
				local dist = (orb.Position - headPos).Magnitude
				if dist < minDist then
					minDist = dist
					nearest = orb
				end
			end
		end
	end

	-- If no upgrade orbs, check regular orbs from spatial grid
	if not nearest and #nearbyEntities > 0 then
		for _, entity in ipairs(nearbyEntities) do
			if entity.type == "ORB" and not targetedOrbs[entity.part] then
				local dist = (entity.part.Position - headPos).Magnitude
				if dist < minDist then
					minDist = dist
					nearest = entity.part
				end
			end
		end

		-- If no untargeted orbs, allow targeting of any orb
		if not nearest then
			for _, entity in ipairs(nearbyEntities) do
				if entity.type == "ORB" then
					local dist = (entity.part.Position - headPos).Magnitude
					if dist < minDist then
						minDist = dist
						nearest = entity.part
					end
				end
			end
		end
	end

	return nearest, minDist
end

function AISnake:findNearestSnakeHead()
	local myHead = self.HeadParts and self.HeadParts.head
	if not myHead then return nil, math.huge end
	local myPos = myHead.Position
	local minDist = math.huge
	local nearest = nil

	local nearbyEntities = SpatialGrid.QueryRadius(myPos, self.Personality.CombatRadius or 60)

	for _, entity in ipairs(nearbyEntities) do
		if entity.owner ~= self and (entity.type == "AI_HEAD" or entity.type == "PLAYER_HEAD") then
			local dist = (entity.part.Position - myPos).Magnitude
			if dist < minDist then
				minDist = dist
				if entity.type == "AI_HEAD" then
					nearest = {part = entity.part, isPlayer = false, snake = entity.owner}
				else
					nearest = {part = entity.part, isPlayer = true, player = entity.owner}
				end
			end
		end
	end
	return nearest, minDist
end

function AISnake:findNearbyThreats()
	local myHead = self.HeadParts and self.HeadParts.head
	if not myHead then return {} end
	local myPos = myHead.Position
	local threats = {}

	local threatRadius = 80 -- INCREASED from 60
	local nearbyEntities = SpatialGrid.QueryRadius(myPos, threatRadius)

	for _, entity in ipairs(nearbyEntities) do
		if entity.owner ~= self and (entity.type == "AI_HEAD" or entity.type == "PLAYER_HEAD") then
			local dist = (entity.part.Position - myPos).Magnitude
			local enemyLength = 0

			if entity.type == "AI_HEAD" then
				enemyLength = entity.owner.CurrentLength or 0
			else
				enemyLength = getPlayerLength(entity.owner)
			end

			local lengthDiff = enemyLength - self.CurrentLength
			local isThreat = false

			-- More balanced threat detection
			if lengthDiff > 20 or (dist < 20 and lengthDiff > 5) then
				isThreat = true
			end

			if not isThreat and dist < 30 and lengthDiff > 15 then
				local enemyVel = Vector3new(0, 0, 0)
				if entity.type == "PLAYER_HEAD" then
					enemyVel = getPlayerVelocity(entity.owner)
				end
				local toUs = (myPos - entity.part.Position).Unit
				local facingUs = enemyVel.Magnitude > 0.1 and enemyVel.Unit:Dot(toUs) > 0.8
				if facingUs then
					isThreat = true
				end
			end

			if isThreat then
				local threatLevel = mathMax(lengthDiff + 10, 5) / mathMax(dist, 1)
				table.insert(threats, {
					part = entity.part,
					position = entity.part.Position,
					isPlayer = entity.type == "PLAYER_HEAD",
					owner = entity.owner,
					distance = dist,
					threatLevel = threatLevel,
					lengthDiff = lengthDiff
				})
			end
		end
	end

	table.sort(threats, function(a, b) return a.threatLevel > b.threatLevel end)
	return threats
end

function AISnake:startBoost(duration)
	local now = tick()
	duration = duration or 1.5

	if self.Boosting and self.BoostEndTime > now + duration then
		return
	end

	self.Boosting = true
	self.IsBoosting = true
	self.BoostEndTime = now + duration
	self.BoostCooldown = self.BoostEndTime + mathRandom(15, 30) / 10

	-- Enable boost particles if they exist
	if self.HeadParts and self.HeadParts.boostParticles then
		self.HeadParts.boostParticles.Enabled = true
		-- Adjust particle rate based on mobile/desktop
		local isMobile = game:GetService("UserInputService").TouchEnabled
		self.HeadParts.boostParticles.Rate = isMobile and 100 or 200

		-- Disable particles when boost ends
		task.delay(duration, function()
			if self.HeadParts and self.HeadParts.boostParticles then
				self.HeadParts.boostParticles.Enabled = false
			end
		end)
	end
end

-- FIXED: Much smoother flee logic
function AISnake:getFleeVector()
	local myHead = self.HeadParts and self.HeadParts.head
	if not myHead then return Vector3new(0, 0, 1) end

	local headPos = myHead.Position
	local threats = self:findNearbyThreats()
	local wallVec, wallStrength = getWallAvoidanceVector(headPos)

	-- REDUCED boost frequency
	if #threats > 0 and not self.Boosting and mathRandom() < 0.3 then
		local closestThreat = threats[1]
		local boostDuration = 1.0

		if closestThreat.distance < 15 and closestThreat.lengthDiff > 30 then
			boostDuration = 1.5
		end

		self:startBoost(boostDuration)
	end

	local fleeDir = nil

	if #threats > 0 then
		-- SIMPLIFIED flee direction calculation
		local totalThreatVector = Vector3new(0, 0, 0)
		local totalWeight = 0

		for _, threat in ipairs(threats) do
			local threatPos = threat.part.Position
			local awayFromThreat = (headPos - threatPos).Unit
			local weight = 1 / mathMax(threat.distance, 1)
			totalThreatVector = totalThreatVector + awayFromThreat * weight
			totalWeight = totalWeight + weight
		end

		if totalWeight > 0 then
			fleeDir = (totalThreatVector / totalWeight).Unit
		end
	end

	-- Wall avoidance
	if wallVec and wallStrength > 0.2 then
		if fleeDir then
			fleeDir = (fleeDir + wallVec.Unit * 2).Unit
		else
			fleeDir = wallVec.Unit
		end
	end

	-- Default behavior - prefer center when fleeing
	if not fleeDir then
		local mapCenter = Vector3new(0, headPos.Y, 0)
		local toCenter = (mapCenter - headPos)
		local distFromCenter = toCenter.Magnitude

		if distFromCenter > 150 then
			-- Too far - flee toward center
			fleeDir = toCenter.Unit
		else
			-- Random direction with MORE center bias
			local randomAngle = mathRandom() * 2 * mathPi
			local randomDir = Vector3new(mathSin(randomAngle), 0, mathCos(randomAngle))
			if distFromCenter > 100 then
				fleeDir = (randomDir + toCenter.Unit * 0.5).Unit
			elseif distFromCenter > 60 then
				fleeDir = (randomDir + toCenter.Unit * 0.3).Unit
			else
				fleeDir = randomDir
			end
		end
	end

	-- Only add MINIMAL center bias when VERY far from center
	local mapCenter = Vector3new(0, headPos.Y, 0)
	local distFromCenter = (mapCenter - headPos).Magnitude
	if distFromCenter > 400 and fleeDir then
		local toCenter = (mapCenter - headPos).Unit
		fleeDir = (fleeDir + toCenter * 0.1).Unit
	end

	return fleeDir
end

-- === HELPER: Check if path to target is safe ===
function AISnake:isPathSafe(targetPos, checkDistance)
	local myHead = self.HeadParts.head
	if not myHead then return false end

	local myPos = myHead.Position
	local toTarget = targetPos - myPos
	local distance = toTarget.Magnitude

	if distance < 0.1 then return true end

	local direction = toTarget.Unit
	local checkDist = mathMin(distance, checkDistance or 50)
	local stepSize = 5

	-- Check points along the path
	for d = stepSize, checkDist, stepSize do
		local checkPos = myPos + direction * d

		-- Check for other snakes at this position
		local nearbyEntities = SpatialGrid.QueryRadius(checkPos, 8)
		for _, entity in ipairs(nearbyEntities) do
			if entity.type == "AI_SEGMENT" or entity.type == "PLAYER_SEGMENT" then
				-- Check if it's not our own segment
				if entity.owner ~= self then
					-- This path crosses another snake!
					return false
				end
			elseif entity.type == "AI_HEAD" or entity.type == "PLAYER_HEAD" then
				if entity.owner ~= self then
					-- Calculate if we'd collide
					local theirVel = entity.part.AssemblyLinearVelocity or Vector3.zero
					local timeToReach = d / self.Speed
					local theirFuturePos = entity.part.Position + theirVel * timeToReach

					if (checkPos - theirFuturePos).Magnitude < 10 then
						-- Collision likely!
						return false
					end
				end
			end
		end
	end

	return true
end

-- === HELPER: Get smart flee direction ===
function AISnake:getSmartFleeDirection(threats)
	-- Safety check for head
	if not self.HeadParts or not self.HeadParts.head then
		return Vector3new(mathRandom(-1, 1), 0, mathRandom(-1, 1)).Unit
	end

	local myPos = self.HeadParts.head.Position

	-- Calculate danger zones from all threats
	local dangerVectors = {}
	for _, threat in ipairs(threats) do
		-- Safety check
		if threat.part and threat.part.Parent then
			local threatPos = threat.part.Position
			local awayFromThreat = (myPos - threatPos).Unit
			local weight = 1 / mathMax(threat.distance, 5) -- Closer = more weight

			-- Extra weight for bigger snakes
			if threat.lengthDiff > 20 then
				weight = weight * 2
			end

			table.insert(dangerVectors, {
				direction = awayFromThreat,
				weight = weight
			})
		end
	end

	-- Combine all danger vectors
	local fleeDir = Vector3.zero
	local totalWeight = 0

	for _, danger in ipairs(dangerVectors) do
		fleeDir = fleeDir + danger.direction * danger.weight
		totalWeight = totalWeight + danger.weight
	end

	-- Add bias towards center if far from it
	local toCenter = Vector3new(0, myPos.Y, 0) - myPos
	local distFromCenter = toCenter.Magnitude
	if distFromCenter > 200 then
		local centerWeight = (distFromCenter - 200) / 100
		fleeDir = fleeDir + toCenter.Unit * centerWeight
		totalWeight = totalWeight + centerWeight
	end

	if totalWeight > 0 then
		fleeDir = (fleeDir / totalWeight).Unit

		-- Check if flee direction is safe
		if not self:isPathSafe(myPos + fleeDir * 30, 30) then
			-- Try perpendicular directions
			local perpDir1 = Vector3new(-fleeDir.Z, 0, fleeDir.X)
			local perpDir2 = Vector3new(fleeDir.Z, 0, -fleeDir.X)

			if self:isPathSafe(myPos + perpDir1 * 30, 30) then
				fleeDir = perpDir1
			elseif self:isPathSafe(myPos + perpDir2 * 30, 30) then
				fleeDir = perpDir2
			end
		end

		return fleeDir
	end

	-- Default: flee towards center
	return toCenter.Unit
end

-- === MUCH SMARTER AI BRAIN (FIXED) ===
function AISnake:_determineAction()
	local headPos = self.HeadParts.head.Position
	local p = self.Personality
	local now = tick()
	local state = "WANDER"
	local steer = self.Direction

	-- Clean up expired states
	if self.Avoiding and now > self.AvoidExpire then
		self.Avoiding = false
		self.FleeReason = ""
	end
	if self.isConfident and now > self.confidenceEndTime then
		self.isConfident = false
		if self.HeadParts and self.HeadParts.headOutline then
			self.HeadParts.headOutline.Color3 = Color3.fromRGB(255, 255, 255)
			self.HeadParts.headOutline.LineThickness = 0.1
			self.HeadParts.headOutline.Transparency = 1
		end
	end
	if self.TargetOrb and (not self.TargetOrb.Parent or now > self.TargetOrbExpire) then
		self.TargetOrb = nil
		AISnake._orbTargets[self] = nil
	end
	if self.TargetSnake and (not self.TargetSnake.part or not self.TargetSnake.part.Parent) then
		self.TargetSnake = nil
		self.trapPhase = 0
		self.isAmbushing = false
	end

	-- Priority 0: CRITICAL BOUNDARY AVOIDANCE (HIGHEST PRIORITY)
	local criticalBuffer = 30
	local isInCriticalZone = (
		headPos.X > MAP_BOUNDS.maxX - criticalBuffer or
		headPos.X < MAP_BOUNDS.minX + criticalBuffer or
		headPos.Z > MAP_BOUNDS.maxZ - criticalBuffer or
		headPos.Z < MAP_BOUNDS.minZ + criticalBuffer
	)

	if isInCriticalZone then
		-- Emergency boundary escape
		local escapeDir = Vector3new(0, 0, 0)
		
		if headPos.X > MAP_BOUNDS.maxX - criticalBuffer then
			escapeDir = escapeDir + Vector3new(-1, 0, 0)
		elseif headPos.X < MAP_BOUNDS.minX + criticalBuffer then
			escapeDir = escapeDir + Vector3new(1, 0, 0)
		end
		
		if headPos.Z > MAP_BOUNDS.maxZ - criticalBuffer then
			escapeDir = escapeDir + Vector3new(0, 0, -1)
		elseif headPos.Z < MAP_BOUNDS.minZ + criticalBuffer then
			escapeDir = escapeDir + Vector3new(0, 0, 1)
		end
		
		if escapeDir.Magnitude > 0.1 then
			-- Add randomness to prevent corner traps
			local randomAngle = mathRandom(-20, 20) * mathPi / 180
			local cosA = mathCos(randomAngle)
			local sinA = mathSin(randomAngle)
			escapeDir = escapeDir.Unit
			local rotatedEscape = Vector3new(
				escapeDir.X * cosA - escapeDir.Z * sinA,
				0,
				escapeDir.X * sinA + escapeDir.Z * cosA
			)
			
			self.TargetSnake = nil
			self.TargetOrb = nil
			self.Avoiding = true
			self.AvoidExpire = now + 2
			return "AVOID_BOUNDARY", rotatedEscape.Unit
		end
	end

	-- Priority 1: COLLISION AVOIDANCE
	local lookAheadDist = self.Speed * 1.2
	local futurePos = headPos + self.Direction * lookAheadDist

	local nearbyDanger = SpatialGrid.QueryRadius(futurePos, 12)
	local collisionThreat = nil
	local minCollisionTime = math.huge

	for _, entity in ipairs(nearbyDanger) do
		if entity.owner ~= self and (entity.type:match("HEAD") or entity.type:match("SEGMENT")) then
			local theirPos = entity.part.Position
			local toThreat = (theirPos - headPos)
			local dist = toThreat.Magnitude
			
			if dist < 15 then
				local timeToCollision = dist / mathMax(self.Speed, 1)
				
				if timeToCollision < minCollisionTime then
					minCollisionTime = timeToCollision
					collisionThreat = entity
				end
			end
		end
	end

	if collisionThreat and minCollisionTime < 0.8 then
		local threatPos = collisionThreat.part.Position
		local avoidDir = (headPos - threatPos).Unit
		local perpDir = Vector3new(-avoidDir.Z, 0, avoidDir.X)

		-- Quick clear check
		local leftClear = self:isPathSafe(headPos + perpDir * 15, 15)
		local rightClear = self:isPathSafe(headPos - perpDir * 15, 15)

		if leftClear and not rightClear then
			steer = perpDir
		elseif rightClear and not leftClear then
			steer = -perpDir
		else
			steer = avoidDir
		end

		return "COLLISION_AVOID", steer
	end

	-- Priority 2: Wall avoidance
	local wallVec, wallStrength = getWallAvoidanceVector(headPos)
	if wallVec and wallStrength > 0.4 then
		self.TargetSnake = nil
		return "AVOID_WALL", wallVec.Unit
	end

	-- Priority 3: Threat assessment (SMARTER)
	local threats = self:findNearbyThreats()
	local shouldFlee = false
	local fleeReason = ""

	if #threats > 0 then
		local closestThreat = threats[1]

		-- More nuanced fleeing decisions
		if closestThreat.distance < 15 and closestThreat.lengthDiff > 5 then
			shouldFlee = true
			fleeReason = "immediate_danger"
		elseif closestThreat.distance < 25 and closestThreat.lengthDiff > 15 then
			shouldFlee = true
			fleeReason = "bigger_snake_nearby"
		elseif closestThreat.lengthDiff > 30 and closestThreat.distance < 40 then
			shouldFlee = true
			fleeReason = "giant_enemy"
		elseif #threats >= 2 and closestThreat.distance < 30 then
			shouldFlee = true
			fleeReason = "multiple_threats"
		elseif p.Type == "Coward" and closestThreat.lengthDiff > 0 and closestThreat.distance < 35 then
			shouldFlee = true
			fleeReason = "coward_instinct"
		end

		-- Even aggressive types flee from much bigger snakes
		if shouldFlee and (p.Type == "Aggressor" or p.Type == "Hunter") then
			if closestThreat.lengthDiff < 10 and closestThreat.distance > 20 then
				shouldFlee = false
			end
		end
	end

	if shouldFlee or self.Avoiding then
		self.TargetSnake = nil
		self.TargetOrb = nil

		local fleeDir = self:getSmartFleeDirection(threats)

		self.Avoiding = true
		self.AvoidDir = fleeDir
		self.AvoidExpire = now + 2.5
		if shouldFlee then self.FleeReason = fleeReason end
		return "FLEE", fleeDir
	end

	-- Priority 4: Smart orb seeking
	if p.TargetOrbs and not shouldFlee then
		-- Look for orbs periodically, not every frame
		if not self.TargetOrb or not self.TargetOrb.Parent or mathRandom() < 0.1 then
			local orb, dist = self:findBestOrb()

			if orb and dist < p.OrbSeekRadius * 1.5 then
				-- Switch to closer orb if significantly better
				if self.TargetOrb and self.TargetOrb.Parent then
					local currentDist = (self.TargetOrb.Position - headPos).Magnitude
					if dist < currentDist * 0.6 then
						self.TargetOrb = orb
						self.TargetOrbExpire = now + mathRandom(40, 80) / 10
						AISnake._orbTargets[self] = orb
					end
				else
					self.TargetOrb = orb
					self.TargetOrbExpire = now + mathRandom(40, 80) / 10
					AISnake._orbTargets[self] = orb
				end
			end
		end

		if self.TargetOrb and self.TargetOrb.Parent then
			local toOrb = self.TargetOrb.Position - headPos
			local orbDist = toOrb.Magnitude

			-- Check if path to orb is safe
			if orbDist < 40 and self:isPathSafe(self.TargetOrb.Position, orbDist) then
				state = "SEEK_ORB"
				steer = toOrb.Unit
				
				-- Short boost when very close
				if orbDist < 15 and not self.Boosting and mathRandom() < 0.2 then
					self:startBoost(0.4)
				end
				
				self.TargetSnake = nil
				return state, steer
			else
				-- Path not safe or too far, cancel
				self.TargetOrb = nil
				AISnake._orbTargets[self] = nil
			end
		end
	end

	-- Priority 5: Advanced Movement Patterns
	if state == "WANDER" then
		-- Initialize movement tracking with nil checks
		self._lastStraightDistance = self._lastStraightDistance or 0
		self._lastTurnPosition = self._lastTurnPosition or headPos
		self._spiralAngle = self._spiralAngle or 0
		self._spiralRadius = self._spiralRadius or 50
		self._zigzagDirection = self._zigzagDirection or 1
		self._gridDirection = self._gridDirection or 0

		-- Calculate distance traveled since last turn
		local distanceSinceTurn = (headPos - self._lastTurnPosition).Magnitude

		-- Check minimum straight distance requirement
		local minStraight = p.MinStraightDistance or 100

		-- Movement pattern based on personality
		local movementPattern = p.MovementPattern or "wander"

		if movementPattern == "spiral" then
			-- Spiral outward pattern for Collectors
			if distanceSinceTurn > minStraight then
				self._spiralAngle = self._spiralAngle + mathPi / 4
				self._spiralRadius = mathMin(self._spiralRadius + 20, 400)
				if self._spiralRadius >= 400 then
					self._spiralRadius = 50
				end
				local targetX = mathCos(self._spiralAngle) * self._spiralRadius
				local targetZ = mathSin(self._spiralAngle) * self._spiralRadius
				steer = (Vector3new(targetX, headPos.Y, targetZ) - headPos).Unit
				self._lastTurnPosition = headPos
			else
				steer = self.Direction
			end

		elseif movementPattern == "zigzag" then
			-- Zigzag pattern for Explorers
			if distanceSinceTurn > minStraight then
				self._zigzagDirection = -self._zigzagDirection
				local turnAngle = self.TargetYaw + (mathPi / 6) * self._zigzagDirection
				steer = Vector3new(mathSin(turnAngle), 0, mathCos(turnAngle))
				self.TargetYaw = turnAngle
				self._lastTurnPosition = headPos
			else
				steer = self.Direction
			end

		elseif movementPattern == "grid" then
			-- Grid pattern for Farmers
			local gridSize = p.GridSize or 100
			if distanceSinceTurn > gridSize then
				self._gridDirection = (self._gridDirection + 1) % 4
				local angles = {0, mathPi/2, mathPi, -mathPi/2}
				self.TargetYaw = angles[self._gridDirection + 1]
				steer = Vector3new(mathSin(self.TargetYaw), 0, mathCos(self.TargetYaw))
				self._lastTurnPosition = headPos
			else
				steer = self.Direction
			end

		elseif movementPattern == "circular" then
			-- Circular patrol for Guardians
			p.PatrolAngle = p.PatrolAngle or 0
			p.PatrolAngle = p.PatrolAngle + 0.02
			local radius = p.TerritoryRadius or 150
			local center = p.TerritoryCenter or Vector3new(0, 0, 0)
			local targetX = center.X + mathCos(p.PatrolAngle) * radius
			local targetZ = center.Z + mathSin(p.PatrolAngle) * radius
			local targetPos = Vector3new(targetX, headPos.Y, targetZ)
			steer = (targetPos - headPos).Unit

		else
			-- Default wandering with minimum straight distance
			if (now - (self.LastTurn or 0) > p.RandomTurnInterval) and distanceSinceTurn > minStraight then
				local maxTurn = 30
				local turnAmount = mathRandom(-maxTurn, maxTurn)

				-- Prevent 180 degree turns
				if mathAbs(turnAmount) > 90 then
					turnAmount = turnAmount * 0.3
				end

				self.TargetYaw = self.TargetYaw + mathRad(turnAmount)
				self.LastTurn = now
				self._lastTurnPosition = headPos

				steer = Vector3new(mathSin(self.TargetYaw), 0, mathCos(self.TargetYaw))
			else
				steer = self.Direction
			end
		end

		-- Gentle boundary nudging (NOT aggressive)
		local softBuffer = 120
		local nudgeStrength = 0.15
		
		if headPos.X > MAP_BOUNDS.maxX - softBuffer then
			steer = (steer + Vector3new(-1, 0, 0) * nudgeStrength).Unit
		elseif headPos.X < MAP_BOUNDS.minX + softBuffer then
			steer = (steer + Vector3new(1, 0, 0) * nudgeStrength).Unit
		end
		
		if headPos.Z > MAP_BOUNDS.maxZ - softBuffer then
			steer = (steer + Vector3new(0, 0, -1) * nudgeStrength).Unit
		elseif headPos.Z < MAP_BOUNDS.minZ + softBuffer then
			steer = (steer + Vector3new(0, 0, 1) * nudgeStrength).Unit
		end
	end

	return state, steer
end

function AISnake:updateBrain()
	if not self._active or not self.HeadParts or not self.HeadParts.head or not self.HeadParts.head.Parent then
		return
	end

	-- Update brain tick for debugging
	self._lastBrainUpdate = tick()

	local state, steer = self:_determineAction()
	self.State = state
	self.SteerDirection = steer
end

-- [REST OF THE CODE CONTINUES WITH AI CONSTRUCTOR AND OTHER METHODS...]
-- Note: The rest remains the same except for updateMovement fixes

-- === SMOOTHER MOVEMENT (FIXED) ===
function AISnake:updateMovement(dt)
	if self._destroyed then return end

	if not self._active or not self.HeadParts or not self.HeadParts.head or not self.HeadParts.head.Parent then
		if self._active and not self._destroyed then
			self:Destroy()
		end
		return
	end

	local now = tick()

	-- Don't move during spawn stabilization
	if self._spawnStabilizing and now < self._spawnStabilizing then
		return
	end
	
	local p = self.Personality

	-- Failsafe: Ensure we have a personality
	if not p then
		warn("AI Snake lost personality! Reassigning...")
		local pType = AISnake.PersonalityTypes[mathRandom(1, #AISnake.PersonalityTypes)]
		self.Personality = deepCopy(AISnake.PersonalityDefinitions[pType])
		p = self.Personality
	end

	local state = self.State
	local steer = self.SteerDirection

	-- Failsafe: Ensure we have a valid steer direction
	if not steer or steer.Magnitude < 0.1 then
		steer = self.Direction
	end

	-- Failsafe: Check if brain updates have stopped
	if self._lastBrainUpdate then
		local timeSinceLastBrain = now - self._lastBrainUpdate
		if timeSinceLastBrain > 2.0 then
			warn("AI Snake brain frozen for", timeSinceLastBrain, "seconds! Forcing update...")
			self:updateBrain()
			local found = false
			for _, snake in ipairs(AISnake._activeSnakes) do
				if snake == self then
					found = true
					break
				end
			end
			if not found and self._active then
				table.insert(AISnake._activeSnakes, self)
				print("🔧 Re-added frozen snake to active list")
			end
		end
	else
		self:updateBrain()
		self._lastBrainUpdate = now
	end

	-- SPAWN PROTECTION
	local isSpawnProtected = now < (self._spawnProtection or 0)

	-- Validate position (unless spawn protected)
	if not isSpawnProtected then
		if self.Position.X < MAP_BOUNDS.minX - 10 or self.Position.X > MAP_BOUNDS.maxX + 10 or
			self.Position.Z < MAP_BOUNDS.minZ - 10 or self.Position.Z > MAP_BOUNDS.maxZ + 10 then
			local safeX = mathClamp(self.Position.X, MAP_BOUNDS.minX + 50, MAP_BOUNDS.maxX - 50)
			local safeZ = mathClamp(self.Position.Z, MAP_BOUNDS.minZ + 50, MAP_BOUNDS.maxZ - 50)
			self.Position = Vector3new(safeX, self.Position.Y, safeZ)
			self.Direction = Vector3new(mathRandom() - 0.5, 0, mathRandom() - 0.5).Unit
			self.State = "WANDER"
			return
		end
	end

	-- SMOOTHER turning
	local forward = self.Direction
	local flatForward = Vector3new(forward.X, 0, forward.Z).Unit
	local flatSteer = Vector3new(steer.X, 0, steer.Z)
	local angle = 0
	if flatSteer.Magnitude > 0.01 then
		flatSteer = flatSteer.Unit
		angle = mathAtan2(flatSteer.X, flatSteer.Z) - mathAtan2(flatForward.X, flatForward.Z)
		if angle > mathPi then angle = angle - 2 * mathPi end
		if angle < -mathPi then angle = angle + 2 * mathPi end
	end
	local desiredYaw = self.CurrentYaw + angle
	self.TargetYaw = desiredYaw

	-- SIMPLER turn speed calculation
	local turnSpeed = self.TurnSpeed

	-- Only modify turn speed for emergency situations
	if state == "AVOID_BOUNDARY" then
		turnSpeed = turnSpeed * 2.0
	elseif state == "COLLISION_AVOID" then
		turnSpeed = turnSpeed * 2.5
	elseif state == "AVOID_WALL" then
		turnSpeed = turnSpeed * 1.4
	elseif self.Boosting then
		turnSpeed = turnSpeed * 0.9
	end

	-- Smooth turning
	local yawDiff = self.TargetYaw - self.CurrentYaw
	if yawDiff > mathPi then yawDiff = yawDiff - 2 * mathPi end
	if yawDiff < -mathPi then yawDiff = yawDiff + 2 * mathPi end

	local maxTurn = turnSpeed * dt
	yawDiff = mathClamp(yawDiff, -maxTurn, maxTurn)
	self.CurrentYaw = self.CurrentYaw + yawDiff

	-- Update direction from yaw
	self.Direction = Vector3new(mathSin(self.CurrentYaw), 0, mathCos(self.CurrentYaw))

	-- Movement variation
	if self.State == "WANDER" or self.State == "FLEE" then
		local wobbleTime = tick() * 2
		local wobbleAmount = 0.1
		local wobble = Vector3new(
			math.sin(wobbleTime) * wobbleAmount,
			0,
			math.cos(wobbleTime * 1.3) * wobbleAmount
		)
		self.Direction = (self.Direction + wobble).Unit
	end

	-- NO additional boundary force here - handled in _determineAction

	-- Boost management
	if self.Boosting and now > self.BoostEndTime then
		self.Boosting = false
		self.IsBoosting = false
	end

	-- SIMPLIFIED boost logic
	if not self.Boosting and now > self.BoostCooldown then
		local shouldBoost = false
		local boostDuration = 1.0

		if state == "FLEE" then
			if mathRandom() < 0.25 then
				shouldBoost = true
				boostDuration = 1.5
			end
		elseif state == "AVOID_BOUNDARY" or state == "COLLISION_AVOID" then
			shouldBoost = true
			boostDuration = 0.7
		elseif state == "WANDER" then
			if mathRandom() < (p.BoostChance or 0.05) * 0.25 then
				shouldBoost = true
			end
		end

		if shouldBoost then
			self:startBoost(boostDuration)
		end
	end

	-- Speed calculation
	local speedMultiplier = p.SpeedMultiplier or 1

	if self.Boosting then
		self.Speed = self.BoostSpeed * speedMultiplier
	else
		self.Speed = mathMax(self.NormalSpeed, self.NormalSpeed * speedMultiplier)
	end

	-- Position update
	local moveDistance = self.Speed * dt
	local newPosition = self.Position + self.Direction * moveDistance

	-- Simple clamping (brain handles turning away from edges)
	if not isSpawnProtected then
		local margin = 15
		newPosition = Vector3new(
			mathClamp(newPosition.X, MAP_BOUNDS.minX + margin, MAP_BOUNDS.maxX - margin),
			newPosition.Y,
			mathClamp(newPosition.Z, MAP_BOUNDS.minZ + margin, MAP_BOUNDS.maxZ - margin)
		)
	end
	
	self.Position = newPosition

	self.RootPart.Position = self.Position

	local headOffset = self.Direction * 1.5
	local newHeadPos = self.Position + headOffset
	self.HeadParts.head.CFrame = CFramelookAt(newHeadPos, newHeadPos + self.Direction)

	-- Update eyes position
	if self.HeadParts.leftEye and self.HeadParts.rightEye then
		local headCF = self.HeadParts.head.CFrame
		local headSize = self.HeadParts.head.Size.X
		local eyeScale = headSize / 3.5 * 0.5
		local eyeOffset = headSize * 0.3
		local eyeForward = -headSize * 0.35

		self.HeadParts.leftEye.Size = Vector3.new(eyeScale, eyeScale, eyeScale)
		self.HeadParts.rightEye.Size = Vector3.new(eyeScale, eyeScale, eyeScale)
		self.HeadParts.leftPupil.Size = Vector3.new(eyeScale * 0.5, eyeScale * 0.5, eyeScale * 0.5)
		self.HeadParts.rightPupil.Size = Vector3.new(eyeScale * 0.5, eyeScale * 0.5, eyeScale * 0.5)

		self.HeadParts.leftEye.CFrame = headCF * CFramenew(-eyeOffset, eyeOffset * 0.5, eyeForward)
		self.HeadParts.rightEye.CFrame = headCF * CFramenew(eyeOffset, eyeOffset * 0.5, eyeForward)
		self.HeadParts.leftPupil.CFrame = self.HeadParts.leftEye.CFrame * CFramenew(0, 0, -eyeScale * 0.3)
		self.HeadParts.rightPupil.CFrame = self.HeadParts.rightEye.CFrame * CFramenew(0, 0, -eyeScale * 0.3)
	end

	-- Set velocity for collision detection
	self.HeadParts.head.AssemblyLinearVelocity = self.Direction * self.Speed

	-- [ORB PICKUP CODE AND SEGMENT FOLLOWING CODE CONTINUES UNCHANGED...]
end

-- === Key Fixes Summary ===
--[[
1. ✅ Removed duplicate boundary avoidance logic from updateMovement
2. ✅ Fixed movement pattern initialization (proper nil checks)
3. ✅ Reordered priorities: Collision > Walls > Threats > Orbs
4. ✅ Made orb seeking more stable (less frequent cancellation)
5. ✅ Simplified boost logic (fewer conflicting triggers)
6. ✅ Fixed turn speed calculation (no stacking multipliers)
7. ✅ Improved boundary handling (single source of truth)
8. ✅ Better state management (clearer priorities)
]]
