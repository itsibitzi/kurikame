keyword = "kurivowel"
adminOnly = false

function doWork(message)
	return message:gsub("a", ""):gsub("e", ""):gsub("i", ""):gsub("o", ""):gsub("u", "")
end
