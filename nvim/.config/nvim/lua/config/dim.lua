-- Dim surrounding (non-floating) windows while a floating window is open.
local api = vim.api

-- Background the surrounding windows are dimmed to while a float is open.
local dim_bg = "#000000"

-- Fraction of the surrounding text/surface colors to keep while dimmed
-- (1.0 = no dim, 0.0 = fully black). Lower = stronger dim.
local dim_keep = 0.5

local ns ---@type number|nil

local function parse_hex(hex)
  hex = hex:gsub("#", "")
  return tonumber(hex:sub(1, 2), 16), tonumber(hex:sub(3, 4), 16), tonumber(hex:sub(5, 6), 16)
end

local dim_r, dim_g, dim_b = parse_hex(dim_bg)

local function blend(color)
  local r = math.floor(color / 0x10000)
  local g = math.floor(color / 0x100) % 0x100
  local b = color % 0x100
  return string.format(
    "#%02X%02X%02X",
    math.floor(r * dim_keep + dim_r * (1 - dim_keep)),
    math.floor(g * dim_keep + dim_g * (1 - dim_keep)),
    math.floor(b * dim_keep + dim_b * (1 - dim_keep))
  )
end

-- Build a namespace with dimmed versions of every current highlight group,
-- so both the text and the surfaces of surrounding windows recede.
local function build()
  if ns then
    return ns
  end
  ns = api.nvim_create_namespace("surround_dim")

  for _, group in ipairs(vim.fn.getcompletion("", "highlight")) do
    local ok, attrs = pcall(api.nvim_get_hl, 0, { name = group, link = false })
    if ok and type(attrs) == "table" then
      local over = {}
      if attrs.fg and attrs.fg >= 0 then
        over.fg = blend(attrs.fg)
      end
      if attrs.bg and attrs.bg >= 0 then
        over.bg = blend(attrs.bg)
      end
      if next(over) then
        api.nvim_set_hl(ns, group, over)
      end
    end
  end

  -- Plain window background goes fully dark (not just blended).
  api.nvim_set_hl(ns, "Normal", { bg = dim_bg })
  api.nvim_set_hl(ns, "NormalNC", { bg = dim_bg })

  return ns
end

-- Trigger: the currently focused window is a floating window. Modals like
-- lazy/mason/picker/explorer take focus when opened; notifications, LSP
-- progress (fidget), and backdrops never do, so they can't trigger a dim.
local function has_modal_float()
  return api.nvim_win_get_config(api.nvim_get_current_win()).relative ~= ""
end

local scheduled = false

local function update()
  scheduled = false
  local active = has_modal_float()
  local dim_ns = active and build() or nil
  for _, win in ipairs(api.nvim_list_wins()) do
    local ok, cfg = pcall(api.nvim_win_get_config, win)
    if ok and cfg.relative == "" then
      pcall(api.nvim_win_set_hl_ns, win, dim_ns or 0)
    end
  end
end

-- Defer to the next event-loop tick: at WinClosed time the float is still in
-- nvim_list_wins(), so checking immediately would keep the dim stuck on.
local function schedule_update()
  if scheduled then
    return
  end
  scheduled = true
  vim.schedule(update)
end

local group = api.nvim_create_augroup("SurroundDim", { clear = true })
api.nvim_create_autocmd({ "WinEnter", "WinLeave", "WinClosed", "WinNew" }, {
  group = group,
  callback = schedule_update,
})

-- Rebuild the dim palette if the colorscheme changes.
api.nvim_create_autocmd("ColorScheme", {
  group = group,
  callback = function()
    ns = nil
  end,
})
