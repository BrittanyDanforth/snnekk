# Exact Code Changes (Diff Format)

## Change 1: Priority 0 - Simplified Critical Boundary Check

```diff
function AISnake:_determineAction()
    -- ... existing code ...

-   -- Priority 0: BOUNDARY AVOIDANCE (HIGHEST PRIORITY)
-   local boundaryBuffer = 80
-   local strongBuffer = 40
-   local edgeSteer = nil
-
-   -- Check X boundaries
-   if headPos.X > MAP_BOUNDS.maxX - boundaryBuffer then
-       local strength = 1 - (MAP_BOUNDS.maxX - headPos.X) / boundaryBuffer
-       edgeSteer = Vector3new(-1, 0, 0) * strength
-   elseif headPos.X < MAP_BOUNDS.minX + boundaryBuffer then
-       local strength = 1 - (headPos.X - MAP_BOUNDS.minX) / boundaryBuffer
-       edgeSteer = Vector3new(1, 0, 0) * strength
-   end
-
-   -- Check Z boundaries  
-   if headPos.Z > MAP_BOUNDS.maxZ - boundaryBuffer then
-       local strength = 1 - (MAP_BOUNDS.maxZ - headPos.Z) / boundaryBuffer
-       local zSteer = Vector3new(0, 0, -1) * strength
-       edgeSteer = edgeSteer and (edgeSteer + zSteer).Unit or zSteer
-   elseif headPos.Z < MAP_BOUNDS.minZ + boundaryBuffer then
-       local strength = 1 - (headPos.Z - MAP_BOUNDS.minZ) / boundaryBuffer
-       local zSteer = Vector3new(0, 0, 1) * strength
-       edgeSteer = edgeSteer and (edgeSteer + zSteer).Unit or zSteer
-   end
-
-   -- Strong boundary avoidance overrides everything
-   if edgeSteer and (
-       headPos.X > MAP_BOUNDS.maxX - strongBuffer or
-       headPos.X < MAP_BOUNDS.minX + strongBuffer or
-       headPos.Z > MAP_BOUNDS.maxZ - strongBuffer or
-       headPos.Z < MAP_BOUNDS.minZ + strongBuffer
-   ) then
-       -- Add some randomness to prevent getting stuck in corners
-       local randomAngle = mathRandom(-30, 30) * mathPi / 180
-       local cosA = mathCos(randomAngle)
-       local sinA = mathSin(randomAngle)
-       local rotatedSteer = Vector3new(
-           edgeSteer.X * cosA - edgeSteer.Z * sinA,
-           0,
-           edgeSteer.X * sinA + edgeSteer.Z * cosA
-       )
-
-       self.TargetSnake = nil
-       self.TargetOrb = nil
-       return "AVOID_BOUNDARY", rotatedSteer.Unit
-   end

+   -- Priority 0: CRITICAL BOUNDARY AVOIDANCE (HIGHEST PRIORITY)
+   local criticalBuffer = 30
+   local isInCriticalZone = (
+       headPos.X > MAP_BOUNDS.maxX - criticalBuffer or
+       headPos.X < MAP_BOUNDS.minX + criticalBuffer or
+       headPos.Z > MAP_BOUNDS.maxZ - criticalBuffer or
+       headPos.Z < MAP_BOUNDS.minZ + criticalBuffer
+   )
+
+   if isInCriticalZone then
+       -- Emergency boundary escape
+       local escapeDir = Vector3new(0, 0, 0)
+       
+       if headPos.X > MAP_BOUNDS.maxX - criticalBuffer then
+           escapeDir = escapeDir + Vector3new(-1, 0, 0)
+       elseif headPos.X < MAP_BOUNDS.minX + criticalBuffer then
+           escapeDir = escapeDir + Vector3new(1, 0, 0)
+       end
+       
+       if headPos.Z > MAP_BOUNDS.maxZ - criticalBuffer then
+           escapeDir = escapeDir + Vector3new(0, 0, -1)
+       elseif headPos.Z < MAP_BOUNDS.minZ + criticalBuffer then
+           escapeDir = escapeDir + Vector3new(0, 0, 1)
+       end
+       
+       if escapeDir.Magnitude > 0.1 then
+           -- Add randomness to prevent corner traps
+           local randomAngle = mathRandom(-20, 20) * mathPi / 180
+           local cosA = mathCos(randomAngle)
+           local sinA = mathSin(randomAngle)
+           escapeDir = escapeDir.Unit
+           local rotatedEscape = Vector3new(
+               escapeDir.X * cosA - escapeDir.Z * sinA,
+               0,
+               escapeDir.X * sinA + escapeDir.Z * cosA
+           )
+           
+           self.TargetSnake = nil
+           self.TargetOrb = nil
+           self.Avoiding = true
+           self.AvoidExpire = now + 2
+           return "AVOID_BOUNDARY", rotatedEscape.Unit
+       end
+   end
```

## Change 2: Priority Reordering - Collision Before Wall

```diff
-   -- Priority 1: Wall avoidance
-   local wallVec, wallStrength = getWallAvoidanceVector(headPos)
-   if wallVec and wallStrength > 0.3 then
-       self.TargetSnake = nil
-       return "AVOID_WALL", wallVec.Unit
-   end
-
-   -- Priority 2: COLLISION AVOIDANCE (NEW!)
-   -- Check for imminent collisions in our current path

+   -- Priority 1: COLLISION AVOIDANCE
    local lookAheadDist = self.Speed * 1.2
    local futurePos = headPos + self.Direction * lookAheadDist
    
-   local nearbyDanger = SpatialGrid.QueryRadius(futurePos, 15)
+   local nearbyDanger = SpatialGrid.QueryRadius(futurePos, 12)
    local collisionThreat = nil
    local minCollisionTime = math.huge
    
    for _, entity in ipairs(nearbyDanger) do
        if entity.owner ~= self and (entity.type:match("HEAD") or entity.type:match("SEGMENT")) then
-           -- Calculate time to collision
            local theirPos = entity.part.Position
-           local relPos = theirPos - headPos
-           local relVel = self.Direction * self.Speed
-
-           if entity.part.AssemblyLinearVelocity then
-               relVel = relVel - entity.part.AssemblyLinearVelocity
-           end
-
-           local timeToCollision = relPos:Dot(relVel) / relVel:Dot(relVel)
-
-           if timeToCollision > 0 and timeToCollision < 2 then
-               local collisionPos = headPos + self.Direction * self.Speed * timeToCollision
-               local theirFuturePos = theirPos
-
-               if entity.part.AssemblyLinearVelocity then
-                   theirFuturePos = theirPos + entity.part.AssemblyLinearVelocity * timeToCollision
-               end
-
-               local collisionDist = (collisionPos - theirFuturePos).Magnitude
-
-               if collisionDist < 8 and timeToCollision < minCollisionTime then
-                   minCollisionTime = timeToCollision
-                   collisionThreat = entity
-               end
+           local toThreat = (theirPos - headPos)
+           local dist = toThreat.Magnitude
+           
+           if dist < 15 then
+               local timeToCollision = dist / mathMax(self.Speed, 1)
+               
+               if timeToCollision < minCollisionTime then
+                   minCollisionTime = timeToCollision
+                   collisionThreat = entity
+               end
            end
        end
    end
    
-   if collisionThreat and minCollisionTime < 1 then
-       -- EMERGENCY AVOIDANCE!
+   if collisionThreat and minCollisionTime < 0.8 then
        local threatPos = collisionThreat.part.Position
        local avoidDir = (headPos - threatPos).Unit
-       
-       -- Try to go perpendicular to avoid head-on collision
        local perpDir = Vector3new(-avoidDir.Z, 0, avoidDir.X)
        
-       -- Choose direction based on which side is clearer
-       local leftClear = self:isPathSafe(headPos + perpDir * 20, 20)
-       local rightClear = self:isPathSafe(headPos - perpDir * 20, 20)
+       -- Quick clear check
+       local leftClear = self:isPathSafe(headPos + perpDir * 15, 15)
+       local rightClear = self:isPathSafe(headPos - perpDir * 15, 15)
        
        if leftClear and not rightClear then
            steer = perpDir
        elseif rightClear and not leftClear then
            steer = -perpDir
        else
-           -- Both or neither clear, just avoid directly
            steer = avoidDir
        end
        
-       self.TargetOrb = nil -- Cancel orb seeking
-       return "COLLISION_AVOID", steer
+       return "COLLISION_AVOID", steer
    end
+
+   -- Priority 2: Wall avoidance
+   local wallVec, wallStrength = getWallAvoidanceVector(headPos)
+   if wallVec and wallStrength > 0.4 then
+       self.TargetSnake = nil
+       return "AVOID_WALL", wallVec.Unit
+   end
```

## Change 3: Stable Orb Seeking

```diff
-   -- Priority 3.5: Smart orb seeking (HIGHER PRIORITY)
-   if p.TargetOrbs and not shouldFlee then -- Don't seek orbs when fleeing
-       -- Always look for better orbs
+   -- Priority 4: Smart orb seeking
+   if p.TargetOrbs and not shouldFlee then
+       -- Look for orbs periodically, not every frame
+       if not self.TargetOrb or not self.TargetOrb.Parent or mathRandom() < 0.1 then
            local orb, dist = self:findBestOrb()
            
-           -- More aggressive orb targeting
-           if orb and dist < p.OrbSeekRadius * 2 then -- Double radius for targeting
-               -- Switch to closer orb if significantly better
+           if orb and dist < p.OrbSeekRadius * 1.5 then
                if self.TargetOrb and self.TargetOrb.Parent then
                    local currentDist = (self.TargetOrb.Position - headPos).Magnitude
-                   if dist < currentDist * 0.7 then -- Switch if 30% closer
+                   if dist < currentDist * 0.6 then
                        self.TargetOrb = orb
-                       self.TargetOrbExpire = now + mathRandom(30, 60) / 10
+                       self.TargetOrbExpire = now + mathRandom(40, 80) / 10
                        AISnake._orbTargets[self] = orb
                    end
                else
-                   -- No current target, take this one
                    self.TargetOrb = orb
-                   self.TargetOrbExpire = now + mathRandom(30, 60) / 10
+                   self.TargetOrbExpire = now + mathRandom(40, 80) / 10
                    AISnake._orbTargets[self] = orb
                end
            end
+       end
        
        if self.TargetOrb and self.TargetOrb.Parent then
-           state = "SEEK_ORB"
            local toOrb = self.TargetOrb.Position - headPos
            local orbDist = toOrb.Magnitude
            
-           -- More direct orb approach
-           if orbDist < 50 then -- Increased from 30
+           -- Check if path to orb is safe
+           if orbDist < 40 and self:isPathSafe(self.TargetOrb.Position, orbDist) then
+               state = "SEEK_ORB"
                steer = toOrb.Unit
-               -- Boost when close to orb for faster collection
-               if orbDist < 20 and not self.Boosting and mathRandom() < 0.3 then
-                   self:startBoost(0.5) -- Short boost to grab orb
+               
+               -- Short boost when very close
+               if orbDist < 15 and not self.Boosting and mathRandom() < 0.2 then
+                   self:startBoost(0.4)
                end
-           else
-               steer = toOrb.Unit
+               
+               self.TargetSnake = nil
+               return state, steer
+           else
+               -- Path not safe or too far, cancel
+               self.TargetOrb = nil
+               AISnake._orbTargets[self] = nil
            end
-           
-           -- Clear any combat targets when seeking orbs
-           self.TargetSnake = nil
-           
-           -- Return early to prioritize orb collection
-           return state, steer
        end
    end
```

## Change 4: Movement Pattern Initialization

```diff
    -- Priority 5: Advanced Movement Patterns
    if state == "WANDER" then
-       -- Initialize movement tracking
-       if not self._lastStraightDistance then
-           self._lastStraightDistance = 0
-           self._lastTurnPosition = headPos
-       end
+       -- Initialize movement tracking with nil checks
+       self._lastStraightDistance = self._lastStraightDistance or 0
+       self._lastTurnPosition = self._lastTurnPosition or headPos
+       self._spiralAngle = self._spiralAngle or 0
+       self._spiralRadius = self._spiralRadius or 50
+       self._zigzagDirection = self._zigzagDirection or 1
+       self._gridDirection = self._gridDirection or 0
        
        -- Calculate distance traveled since last turn
        local distanceSinceTurn = (headPos - self._lastTurnPosition).Magnitude
        
        -- ... movement pattern code ...
        
        if movementPattern == "spiral" then
-           -- Spiral outward pattern for Collectors
-           if not self._spiralAngle then self._spiralAngle = 0 end
-           if not self._spiralRadius then self._spiralRadius = 50 end
-           
            if distanceSinceTurn > minStraight then
                -- ... spiral logic ...
        
        elseif movementPattern == "zigzag" then
-           -- Zigzag pattern for Explorers
-           if not self._zigzagDirection then self._zigzagDirection = 1 end
-           
            if distanceSinceTurn > minStraight then
                -- ... zigzag logic ...
        
        elseif movementPattern == "grid" then
-           -- Grid pattern for Farmers
            local gridSize = p.GridSize or 100
-           if not self._gridDirection then self._gridDirection = 0 end
-           
            if distanceSinceTurn > gridSize then
                -- ... grid logic ...
        
        elseif movementPattern == "circular" then
-           -- Circular patrol for Guardians
-           if not p.PatrolAngle then p.PatrolAngle = 0 end
-           
-           -- Circle around territory
-           p.PatrolAngle = p.PatrolAngle + 0.02 -- Slow rotation
+           p.PatrolAngle = p.PatrolAngle or 0
+           p.PatrolAngle = p.PatrolAngle + 0.02
            local radius = p.TerritoryRadius or 150
-           local center = p.TerritoryCenter
+           local center = p.TerritoryCenter or Vector3new(0, 0, 0)
            -- ... circular logic ...
```

## Change 5: Gentle Boundary Nudging

```diff
-       -- Boundary avoidance (keep from edges)
-       local edgeBuffer = 100
+       -- Gentle boundary nudging (NOT aggressive)
+       local softBuffer = 120
+       local nudgeStrength = 0.15
+       
        if headPos.X > MAP_BOUNDS.maxX - edgeBuffer then
-           steer = steer + Vector3new(-1, 0, 0)
-           steer = steer.Unit
+           steer = (steer + Vector3new(-1, 0, 0) * nudgeStrength).Unit
        elseif headPos.X < MAP_BOUNDS.minX + edgeBuffer then
-           steer = steer + Vector3new(1, 0, 0)
-           steer = steer.Unit
+           steer = (steer + Vector3new(1, 0, 0) * nudgeStrength).Unit
        end
+       
        if headPos.Z > MAP_BOUNDS.maxZ - edgeBuffer then
-           steer = steer + Vector3new(0, 0, -1)
-           steer = steer.Unit
+           steer = (steer + Vector3new(0, 0, -1) * nudgeStrength).Unit
        elseif headPos.Z < MAP_BOUNDS.minZ + edgeBuffer then
-           steer = steer + Vector3new(0, 0, 1)
-           steer = steer.Unit
+           steer = (steer + Vector3new(0, 0, 1) * nudgeStrength).Unit
        end
```

## Change 6: Simplified Turn Speed

```diff
-   -- BALANCED TURN SPEED - Good for orb collection but still fair
+   -- SIMPLER turn speed calculation
    local turnSpeed = self.TurnSpeed
    
-   -- Special case for orb seeking - need better turning to actually collect them!
-   if state == "SEEK_ORB" and self.TargetOrb then
-       -- Calculate angle to orb
-       local toOrb = (self.TargetOrb.Position - self.Position)
-       local dist = toOrb.Magnitude
-       if dist < 20 then
-           -- Close to orb - allow sharper turns to grab it
-           turnSpeed = turnSpeed * 1.5
-       end
-   elseif state == "AVOID_WALL" then
-       -- Still need to avoid walls effectively
-       turnSpeed = turnSpeed * 1.3
-   elseif state == "AVOID_BOUNDARY" then
-       -- Need sharp turns to avoid map edge
-       turnSpeed = turnSpeed * 2.5 -- Even sharper for emergencies
-   elseif state == "COLLISION_AVOID" then
-       -- Emergency collision avoidance needs instant response
-       turnSpeed = turnSpeed * 3.0
-   end
-   
-   -- When boosting, turn slightly slower like players do
-   if self.Boosting then
-       turnSpeed = turnSpeed * 0.85
+   -- Only modify turn speed for emergency situations
+   if state == "AVOID_BOUNDARY" then
+       turnSpeed = turnSpeed * 2.0
+   elseif state == "COLLISION_AVOID" then
+       turnSpeed = turnSpeed * 2.5
+   elseif state == "AVOID_WALL" then
+       turnSpeed = turnSpeed * 1.4
+   elseif self.Boosting then
+       turnSpeed = turnSpeed * 0.9
    end
```

## Change 7: Removed Duplicate Boundary Logic

```diff
-   -- Boundary force (gentler, only when not spawn protected)
-   if not isSpawnProtected then
-       local lookAheadTime = 1.0
-       local futurePos = self.Position + self.Direction * self.Speed * lookAheadTime
-       
-       local boundaryForce = Vector3new(0, 0, 0)
-       local boundaryStrength = 0
-       
-       if futurePos.X > MAP_BOUNDS.maxX - 50 then
-           local dist = MAP_BOUNDS.maxX - futurePos.X
-           boundaryStrength = mathMax(boundaryStrength, 1 - (dist / 50))
-           boundaryForce = boundaryForce + Vector3new(-1, 0, 0)
-       elseif futurePos.X < MAP_BOUNDS.minX + 50 then
-           local dist = futurePos.X - MAP_BOUNDS.minX
-           boundaryStrength = mathMax(boundaryStrength, 1 - (dist / 50))
-           boundaryForce = boundaryForce + Vector3new(1, 0, 0)
-       end
-       
-       if futurePos.Z > MAP_BOUNDS.maxZ - 50 then
-           local dist = MAP_BOUNDS.maxZ - futurePos.Z
-           boundaryStrength = mathMax(boundaryStrength, 1 - (dist / 50))
-           boundaryForce = boundaryForce + Vector3new(0, 0, -1)
-       elseif futurePos.Z < MAP_BOUNDS.minZ + 50 then
-           local dist = futurePos.Z - MAP_BOUNDS.minZ
-           boundaryStrength = mathMax(boundaryStrength, 1 - (dist / 50))
-           boundaryForce = boundaryForce + Vector3new(0, 0, 1)
-       end
-       
-       if boundaryStrength > 0.1 then
-           boundaryForce = boundaryForce.Unit
-           self.Direction = (self.Direction * (1 - boundaryStrength) + boundaryForce * boundaryStrength).Unit
-           if boundaryStrength > 0.5 then
-               self.State = "AVOID_BOUNDARY"
-               self.TargetOrb = nil
-               self.TargetSnake = nil
-           end
-       end
-   end
+   -- NO additional boundary force here - handled in _determineAction
```

## Change 8: Simplified Boost Logic

```diff
-   -- SMART boost usage - less boosting when collecting orbs
+   -- SIMPLIFIED boost logic
    if not self.Boosting and now > self.BoostCooldown then
        local shouldBoost = false
-       local boostDuration = 1.2
+       local boostDuration = 1.0
        
-       if state == "AVOID_WALL" then
-           shouldBoost = true
-           boostDuration = 0.8
-       elseif state == "SEEK_ORB" then
-           -- RARELY boost when seeking orbs - they need control, not speed
-           if mathRandom() < 0.02 then -- Only 2% chance when orb seeking
-               shouldBoost = true
-               boostDuration = 0.5 -- Very short boost
-           end
-       elseif state == "FLEE" then
-           -- Higher chance to boost when fleeing
+       if state == "FLEE" then
-           if mathRandom() < 0.3 then
+           if mathRandom() < 0.25 then
                shouldBoost = true
                boostDuration = 1.5
            end
+       elseif state == "AVOID_BOUNDARY" or state == "COLLISION_AVOID" then
+           shouldBoost = true
+           boostDuration = 0.7
-       else
-           -- Normal wandering/hunting boost chance
-           if mathRandom() < (p.BoostChance or 0) * 0.3 then -- Reduced general boost chance
+       elseif state == "WANDER" then
+           if mathRandom() < (p.BoostChance or 0.05) * 0.25 then
                shouldBoost = true
            end
        end
        
        if shouldBoost then
            self:startBoost(boostDuration)
        end
    end
```

## Change 9: Simplified Position Update

```diff
-   -- Position update (with clamping only when not spawn protected)
+   -- Position update
    local moveDistance = self.Speed * dt
    local newPosition = self.Position + self.Direction * moveDistance
    
+   -- Simple clamping (brain handles turning away from edges)
    if not isSpawnProtected then
-       local margin = 20
-       local clampedX = mathClamp(newPosition.X, MAP_BOUNDS.minX + margin, MAP_BOUNDS.maxX - margin)
-       local clampedZ = mathClamp(newPosition.Z, MAP_BOUNDS.minZ + margin, MAP_BOUNDS.maxZ - margin)
-       
-       if clampedX ~= newPosition.X or clampedZ ~= newPosition.Z then
-           local escapeAngle = mathRandom() * mathPi - mathPi/2
-           local currentAngle = mathAtan2(self.Direction.X, self.Direction.Z)
-           local newAngle = currentAngle + escapeAngle
-           
-           self.Direction = Vector3new(mathSin(newAngle), 0, mathCos(newAngle))
-           self.CurrentYaw = newAngle
-           self.TargetYaw = newAngle
-           
-           self.TargetOrb = nil
-           self.TargetSnake = nil
-           self.State = "WANDER"
-       end
-       
-       self.Position = Vector3new(clampedX, newPosition.Y, clampedZ)
-   else
-       self.Position = newPosition
+       local margin = 15
+       newPosition = Vector3new(
+           mathClamp(newPosition.X, MAP_BOUNDS.minX + margin, MAP_BOUNDS.maxX - margin),
+           newPosition.Y,
+           mathClamp(newPosition.Z, MAP_BOUNDS.minZ + margin, MAP_BOUNDS.maxZ - margin)
+       )
    end
+   
+   self.Position = newPosition
```

---

## Summary of Line Changes

- **Removed**: ~150 lines (duplicate/conflicting logic)
- **Added**: ~90 lines (simplified replacements)
- **Modified**: ~40 lines (minor tweaks)
- **Net reduction**: ~60 lines of code

## Functions Modified

1. `AISnake:_determineAction()` - Major refactor
2. `AISnake:updateMovement()` - Significant cleanup

## Functions Unchanged

- `findBestOrb()`
- `findNearestSnakeHead()`
- `findNearbyThreats()`
- `startBoost()`
- `getFleeVector()`
- `isPathSafe()`
- `getSmartFleeDirection()`
- All constructor code
- All segment/rendering code
- All update loops
