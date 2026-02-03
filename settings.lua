-- __BreedingDemolisher__/settings.lua
data:extend({
  {
    type = "string-setting",
    name = "breedingdemolisher-logger-level",
    setting_type = "runtime-global",
    default_value = "off",
    allowed_values = { "off", "error", "warn", "info", "debug" },
    order = "z[breedingdemolisher]-a[logger]-a[level]"
  },
  {
    type = "bool-setting",
    name = "breedingdemolisher-logger-to-log",
    setting_type = "runtime-global",
    default_value = true,
    order = "z[breedingdemolisher]-a[logger]-b[to-log]"
  },
  {
    type = "bool-setting",
    name = "breedingdemolisher-logger-to-print",
    setting_type = "runtime-global",
    default_value = true,
    order = "z[breedingdemolisher]-a[logger]-c[to-print]"
  },
  {
    type = "bool-setting",
    name = "breedingdemolisher-logger-to-file",
    setting_type = "runtime-global",
    default_value = false,
    order = "z[breedingdemolisher]-a[logger]-d[to-file]"
  }
})