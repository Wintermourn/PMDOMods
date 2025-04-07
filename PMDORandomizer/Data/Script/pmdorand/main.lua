--[[                                                                   
 _____ _____ ____  _____ _____           _           _             
|  _  |     |    \|     | __  |___ ___ _| |___ _____|_|___ ___ ___ 
|   __| | | |  |  |  |  |    -| .'|   | . | . |     | |- _| -_|  _|
|__|  |_|_|_|____/|_____|__|__|__,|_|_|___|___|_|_|_|_|___|___|_|  
wintermourn.pmdorand         Version 0.2         Created 2025-03-07
By Wintermourn                                       Edit with care

Beware, dear viewers, for my code style is a mess. This is also my
first major project trying to mod PMDO (outside of an attempt at
level uncapping), so things are likely poorly optimized as well as
confusing and occasionally spaghetti. I've tried to split it all
into different files (see the randomizer/ folder) for readability
(and performance; nothing really loads until you press randomizer).
]]

require 'pmdorand.services.topmenuservice'