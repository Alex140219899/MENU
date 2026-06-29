-- VigMenu: Medium без Vmify (Vmify падает на большом MoonLoader-скрипте).
return {
	LuaVersion = "Lua51",
	VarNamePrefix = "",
	NameGenerator = "MangledShuffled",
	PrettyPrint = false,
	Seed = 0,
	Steps = {
		{ Name = "EncryptStrings", Settings = {} },
		{
			Name = "AntiTamper",
			Settings = {
				UseDebug = false,
			},
		},
		{
			Name = "ConstantArray",
			Settings = {
				Threshold = 1,
				StringsOnly = true,
				Shuffle = true,
				Rotate = true,
				LocalWrapperThreshold = 0,
			},
		},
		{ Name = "NumbersToExpressions", Settings = {} },
		{ Name = "WrapInFunction", Settings = {} },
	},
}
