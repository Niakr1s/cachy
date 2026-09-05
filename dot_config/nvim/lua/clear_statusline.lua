local M = {}

local clear_timer = nil
local timeout = 3000

function M.setup(opts)
  timeout = opts.timeout or 3000

  -- Auto-clear after command line leave
  vim.api.nvim_create_autocmd("CmdlineLeave", {
    pattern = ":",
    callback = function()
      M.start_clear_timer()
    end,
  })
end

-- Public function to start the clear timer
function M.start_clear_timer()
  if clear_timer then clear_timer:stop() end
  clear_timer = vim.defer_fn(function()
    M.clear_now()
  end, timeout)
end

-- Public function to clear messages immediately
function M.clear_now()
  if clear_timer then clear_timer:stop() end
  clear_timer = nil
  vim.api.nvim_echo({}, false, {})
  vim.cmd.redrawstatus()
end

-- Public function to cancel the timer
function M.cancel_clear()
  if clear_timer then
    clear_timer:stop()
    clear_timer = nil
  end
end

return M
