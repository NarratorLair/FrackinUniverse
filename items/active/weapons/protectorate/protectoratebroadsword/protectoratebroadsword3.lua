require "/scripts/util.lua"
require "/scripts/vec2.lua"
require "/items/active/weapons/weapon.lua"

function init()
	animator.setGlobalTag("paletteSwaps", config.getParameter("paletteSwaps", ""))
	animator.setGlobalTag("directives", "")
	animator.setGlobalTag("bladeDirectives", "")

	self.weapon = Weapon:new()

	self.weapon:addTransformationGroup("weapon", {0,0}, util.toRadians(config.getParameter("baseWeaponRotation", 0)))
	self.weapon:addTransformationGroup("swoosh", {0,0}, math.pi/2)

	self.primaryAbility = getPrimaryAbility()
	self.weapon:addAbility(self.primaryAbility)

	self.altAbility = getAltAbility()
	self.weapon:addAbility(self.altAbility)

	self.weapon:init()

	self.inactiveBaseDps = config.getParameter("inactiveBaseDps")
	self.activeBaseDps = config.getParameter("activeBaseDps")
	self.inactiveFireTime = config.getParameter("inactiveFireTime")
	self.activeFireTime = config.getParameter("activeFireTime")
	self.inactiveElement = config.getParameter("inactiveElement")
	self.activeElement = config.getParameter("activeElement")
	self.inactivePAbility = config.getParameter("inactivePAbility")
	self.activePAbility = config.getParameter("activePAbility")

	self.active = false
	animator.setAnimationState("sword", "inactive")
	self.primaryAbility.animKeyPrefix = "inactive"
	self.primaryAbility.baseDps = self.inactiveBaseDps
	self.primaryAbility:computeDamageAndCooldowns()
end

function update(dt, fireMode, shiftHeld)
	self.weapon:update(dt, fireMode, shiftHeld)
	setActive(self.altAbility.active)
end

function DeepPrintTable(tbl)
	sb.logInfo("%s", DeepPrintTableHelper(tbl, 0))
end

function DeepPrintTableHelper(toPrint, level)
	level = level or 0
	local str = ""
	if level >= 5 then
		return "\n"
	end
	if type(toPrint) == "table" then
		for k, v in pairs(toPrint) do
			for _ = 0, level do
				str = str.."	"
			end

			local lenFix = ""
			for _ = 1, 30 - string.len(tostring(k)) do
				lenFix = lenFix.." "
			end

			str = str..tostring(k)..lenFix.."=          ("..type(v)..") "..tostring(v)

			if type(v) == "table" then
				str = str..DeepPrintTableHelper(v, level +1).."\n"
			else
				str = str.."\n"
			end
		end

	else
		str = tostring(toPrint)
	end

	return "\n"..str
end

function uninit()
	self.weapon:uninit()
end

function setActive(active)
	if self.active ~= active then
		DeepPrintTable(self.primaryAbility)
		self.active = active
		if self.active then
			animator.setAnimationState("sword", "extend")
			self.primaryAbility.animKeyPrefix = "active"
			self.primaryAbility.baseDps = self.activeBaseDps
			self.primaryAbility.fireTime = self.activeFireTime
			self.primaryAbility:computeDamageAndCooldowns()
		else
			animator.setAnimationState("sword", "retract")
			self.primaryAbility.animKeyPrefix = "inactive"
			self.primaryAbility.baseDps = self.inactiveBaseDps
			self.primaryAbility.fireTime = self.inactiveFireTime
			self.primaryAbility:computeDamageAndCooldowns()
		end
	end
end
