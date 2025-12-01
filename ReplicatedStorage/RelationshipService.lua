-- RelationshipService.lua
-- ═══════════════════════════════════════════════════════════════════════════════
-- SINGLE SOURCE OF TRUTH FOR ALL RELATIONSHIP OPERATIONS
-- All relationship creates/edits/deletes go through here
-- This ensures EventLibrary, EventRunner, and RelationshipsScreen all talk
-- about the SAME people
-- ═══════════════════════════════════════════════════════════════════════════════

local RelationshipService = {}

----------------------------------------------------------------------
-- NAME GENERATORS (for creating new people)
----------------------------------------------------------------------

local MaleNames = {
	"James","Michael","David","Chris","Daniel","Matt","Jake","Ryan","Tyler","Brandon",
	"Kevin","Justin","Josh","Nick","Alex","Brian","Eric","Andrew","Sean","Kyle",
	"Adam","Aaron","Ethan","Nathan","Zach","Dylan","Connor","Mason","Logan","Lucas",
	"Marcus","Darius","Jerome","DeShawn","Jamal","Carlos","Miguel","Antonio","Roberto",
	"Liam","Noah","Oliver","William","Henry","Sebastian","Jack","Aiden","Owen","Samuel"
}

local FemaleNames = {
	"Emma","Sophia","Olivia","Ava","Isabella","Mia","Emily","Abigail","Madison",
	"Elizabeth","Ella","Avery","Chloe","Sofia","Grace","Lily","Hannah","Aria","Zoe",
	"Riley","Nora","Scarlett","Stella","Luna","Hazel","Jasmine","Aaliyah","Destiny",
	"Charlotte","Amelia","Harper","Evelyn","Penelope","Camila","Eleanor","Violet"
}

local LastNames = {
	"Smith","Johnson","Williams","Brown","Jones","Garcia","Miller","Davis","Rodriguez",
	"Martinez","Anderson","Taylor","Thomas","Moore","Jackson","Martin","Lee","Thompson",
	"White","Harris","Clark","Lewis","Robinson","Walker","Young","King","Wright","Scott"
}

local function randomMaleName()
	return MaleNames[math.random(#MaleNames)] .. " " .. LastNames[math.random(#LastNames)]
end

local function randomFemaleName()
	return FemaleNames[math.random(#FemaleNames)] .. " " .. LastNames[math.random(#LastNames)]
end

local function randomName()
	return math.random(2) == 1 and randomMaleName() or randomFemaleName()
end

local function randomFirstName()
	local names = math.random(2) == 1 and MaleNames or FemaleNames
	return names[math.random(#names)]
end

----------------------------------------------------------------------
-- CORE FUNCTIONS
----------------------------------------------------------------------

local function ensureTable(state)
	state.Relationships = state.Relationships or {}
	return state.Relationships
end

-- Create a new relationship and add to state
function RelationshipService.create(state, relType, props)
	props = props or {}
	local rels = ensureTable(state)
	
	-- Generate unique ID
	state._nextRelationshipId = (state._nextRelationshipId or 0) + 1
	local newId = props.id or (relType .. "_" .. tostring(os.time()) .. "_" .. tostring(state._nextRelationshipId))
	
	-- Determine gender if not provided
	local gender = props.gender
	if not gender then
		gender = math.random(2) == 1 and "male" or "female"
	end
	
	-- Generate name if not provided
	local name = props.name
	if not name then
		name = gender == "male" and randomMaleName() or randomFemaleName()
	end
	
	-- Build the relationship entry
	local rel = {
		id = newId,
		type = relType,                                -- "friend", "romance", "family", "enemy"
		name = name,
		role = props.role or relType,                  -- Display role like "Best Friend", "Partner"
		relationship = props.relationship or 60,       -- 0-100
		age = props.age or (state.Age or 18),
		met = props.met or (state.Age or 0),           -- Age when met
		alive = props.alive ~= false,
		gender = gender,
		tags = props.tags or {},                       -- { best_friend = true, childhood = true }
		subtype = props.subtype,                       -- Original granular type
	}
	
	rels[newId] = rel
	
	-- Also set has_friend flag if creating a friend
	if relType == "friend" then
		state.Flags = state.Flags or {}
		state.Flags.has_friend = true
		if props.tags and props.tags.best_friend then
			state.Flags.has_best_friend = true
		end
	elseif relType == "romance" then
		state.Flags = state.Flags or {}
		state.Flags.in_relationship = true
		if props.tags and props.tags.dating then
			state.Flags.dating = true
		end
	end
	
	print("[RelationshipService] Created:", newId, "Type:", relType, "Name:", name)
	return rel
end

-- Get a relationship by ID
function RelationshipService.get(state, relId)
	local rels = state.Relationships
	return rels and rels[relId] or nil
end

-- Pick a random relationship matching criteria
function RelationshipService.pick(state, relType, filterFn)
	local rels = state.Relationships
	if not rels then return nil end
	
	local candidates = {}
	for _, rel in pairs(rels) do
		if rel.type == relType and rel.alive ~= false then
			if not filterFn or filterFn(rel) then
				table.insert(candidates, rel)
			end
		end
	end
	
	if #candidates == 0 then return nil end
	return candidates[math.random(#candidates)]
end

-- Pick all relationships matching criteria
function RelationshipService.pickAll(state, relType, filterFn)
	local rels = state.Relationships
	if not rels then return {} end
	
	local results = {}
	for _, rel in pairs(rels) do
		if rel.type == relType and rel.alive ~= false then
			if not filterFn or filterFn(rel) then
				table.insert(results, rel)
			end
		end
	end
	
	return results
end

-- Change relationship value (delta can be positive or negative)
function RelationshipService.delta(state, relId, delta)
	local rel = RelationshipService.get(state, relId)
	if not rel then return end
	
	local newVal = (rel.relationship or 50) + delta
	newVal = math.max(0, math.min(100, newVal))
	rel.relationship = newVal
	
	print("[RelationshipService] Updated", relId, "relationship by", delta, "to", newVal)
	return newVal
end

-- Set relationship value directly
function RelationshipService.setRelationship(state, relId, value)
	local rel = RelationshipService.get(state, relId)
	if not rel then return end
	
	rel.relationship = math.max(0, math.min(100, value))
	return rel.relationship
end

-- Kill/remove a relationship (mark as dead or gone)
function RelationshipService.kill(state, relId, reason)
	local rel = RelationshipService.get(state, relId)
	if not rel then return end
	
	rel.alive = false
	rel.deathReason = reason or "unknown"
	rel.relationship = 0
	
	print("[RelationshipService] Killed", relId, "Reason:", reason or "unknown")
end

-- Remove a relationship entirely (unfriend, breakup, etc.)
function RelationshipService.remove(state, relId)
	local rels = state.Relationships
	if not rels then return end
	
	local rel = rels[relId]
	if rel then
		print("[RelationshipService] Removed", relId, "Name:", rel.name)
		rels[relId] = nil
		
		-- Update flags if needed
		local hasFriendStill = false
		for _, r in pairs(rels) do
			if r.type == "friend" and r.alive ~= false then
				hasFriendStill = true
				break
			end
		end
		if not hasFriendStill and state.Flags then
			state.Flags.has_friend = nil
		end
	end
end

-- Update relationship properties
function RelationshipService.update(state, relId, props)
	local rel = RelationshipService.get(state, relId)
	if not rel then return end
	
	for key, value in pairs(props) do
		if key ~= "id" then -- Don't allow changing ID
			rel[key] = value
		end
	end
	
	return rel
end

-- Add a tag to a relationship
function RelationshipService.addTag(state, relId, tag)
	local rel = RelationshipService.get(state, relId)
	if not rel then return end
	
	rel.tags = rel.tags or {}
	rel.tags[tag] = true
end

-- Remove a tag from a relationship
function RelationshipService.removeTag(state, relId, tag)
	local rel = RelationshipService.get(state, relId)
	if not rel or not rel.tags then return end
	
	rel.tags[tag] = nil
end

----------------------------------------------------------------------
-- CONVENIENCE FUNCTIONS (Get or Create)
----------------------------------------------------------------------

-- Get an existing friend or create one if none exist
function RelationshipService.getOrCreateFriend(state, opts)
	opts = opts or {}
	
	-- Try to find an existing friend
	local friend = RelationshipService.pick(state, "friend", opts.filterFn)
	if friend then return friend, false end -- false = not newly created
	
	-- Create a new one
	local newFriend = RelationshipService.create(state, "friend", {
		name = opts.name or randomName(),
		role = opts.role or "Friend",
		relationship = opts.relationship or 65,
		age = opts.age or (state.Age or 18),
		tags = opts.tags or { generated = true },
	})
	
	return newFriend, true -- true = newly created
end

-- Get an existing best friend or create one
function RelationshipService.getOrCreateBestFriend(state, opts)
	opts = opts or {}
	
	-- Try existing tagged best_friend
	local friend = RelationshipService.pick(state, "friend", function(r)
		return r.tags and r.tags.best_friend
	end)
	if friend then return friend, false end
	
	-- Try any friend and upgrade them
	friend = RelationshipService.pick(state, "friend")
	if friend then
		friend.tags = friend.tags or {}
		friend.tags.best_friend = true
		friend.role = "Best Friend"
		if friend.relationship < 75 then
			friend.relationship = 75
		end
		return friend, false
	end
	
	-- Create new best friend
	local newFriend = RelationshipService.create(state, "friend", {
		name = opts.name or randomName(),
		role = "Best Friend",
		relationship = opts.relationship or 80,
		age = opts.age or (state.Age or 18),
		tags = { best_friend = true, childhood = opts.childhood ~= false },
	})
	
	state.Flags = state.Flags or {}
	state.Flags.has_best_friend = true
	
	return newFriend, true
end

-- Get an existing partner or create one
function RelationshipService.getOrCreatePartner(state, opts)
	opts = opts or {}
	
	-- Try existing romance
	local partner = RelationshipService.pick(state, "romance")
	if partner then return partner, false end
	
	-- Create new partner
	local newPartner = RelationshipService.create(state, "romance", {
		name = opts.name or randomName(),
		role = opts.role or "Partner",
		relationship = opts.relationship or 70,
		age = opts.age or (state.Age or 18),
		tags = opts.tags or { dating = true },
	})
	
	state.Flags = state.Flags or {}
	state.Flags.in_relationship = true
	state.Flags.dating = true
	
	return newPartner, true
end

----------------------------------------------------------------------
-- QUERY FUNCTIONS
----------------------------------------------------------------------

-- Check if player has any friends
function RelationshipService.hasFriend(state)
	local f = state.Flags or {}
	if f.has_best_friend or f.has_friend or f.social_butterfly or f.friendly or f.has_friend_group then
		return true
	end
	
	local rels = state.Relationships
	if rels then
		for _, rel in pairs(rels) do
			if rel.type == "friend" and rel.alive ~= false then
				return true
			end
		end
	end
	return false
end

-- Check if player has a romantic partner
function RelationshipService.hasPartner(state)
	local f = state.Flags or {}
	if f.married or f.engaged or f.in_relationship or f.dating then
		return true
	end
	
	local rels = state.Relationships
	if rels then
		for _, rel in pairs(rels) do
			if rel.type == "romance" and rel.alive ~= false then
				return true
			end
		end
	end
	return false
end

-- Count relationships by type
function RelationshipService.count(state, relType)
	local rels = state.Relationships
	if not rels then return 0 end
	
	local count = 0
	for _, rel in pairs(rels) do
		if (not relType or rel.type == relType) and rel.alive ~= false then
			count = count + 1
		end
	end
	return count
end

-- Get all relationships as a list
function RelationshipService.getAll(state, relType)
	local rels = state.Relationships
	if not rels then return {} end
	
	local results = {}
	for _, rel in pairs(rels) do
		if (not relType or rel.type == relType) then
			table.insert(results, rel)
		end
	end
	return results
end

----------------------------------------------------------------------
-- EXPORT UTILITIES
----------------------------------------------------------------------

RelationshipService.randomName = randomName
RelationshipService.randomFirstName = randomFirstName
RelationshipService.randomMaleName = randomMaleName
RelationshipService.randomFemaleName = randomFemaleName

return RelationshipService
