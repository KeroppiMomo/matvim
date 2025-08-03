# Matvim

Matvim is a plugin that integrates [MATLAB](https://mathworks.com/products/matlab.html)
into [Neovim](https://neovim.io/) (to free you from clicking around in the desktop editor).

https://github.com/user-attachments/assets/3db1bf49-7269-4db2-bf17-116986ab166d

Major features:
- Use `:MatlabStart` to start a MATLAB instance, or to connect to an existing,
  running instance.
- Run a `.m` file with `:MatlabRunFile` or `<Leader>R`.
- Use the operator `<Leader>r` to run part of a file. Local functions are
  respected.
- Move around sections with motions `[[` and `]]`, or use text objects `aS`
  and `iS`.

# Requirements

- MATLAB

- Python 3 and MATLAB Engine

  MATLAB Engine for Python is required if:
  - you are on Windows; or
  - you would like to connect to an existing MATLAB instance.

  In this case, specify `use_custom_interpreter = true` in the configuration
  options. Set it to `false` if you would like to use the official MATLAB
  interpreter.

  The appropriate Python 3 version should be installed for the specific MATLAB
  version. Follow the installation instruction here:
  https://mathworks.com/help/matlab/matlab_external/install-the-matlab-engine-for-python.html

  You can check if the installation is successful by running `python3` and
  typing `import matlab.engine`.

- Treesitter support for MATLAB files

  Treesitter is required if you want local functions to be extracted.
  
# Installation

Use your favourite plugin manager (e.g. [lazy.nvim](https://github.com/folke/lazy.nvim))
to add this plugin to the runtime path.

Example lazy.nvim config:
```lua
{
  "KeroppiMomo/matvim",
  opts = {
    use_custom_interpreter = true,
    matlab_cmd = "matlab",
    run_temp_folder = "~/tmp/",
    keymaps = {
      matlab_start = "<leader>s",
      run_file = "<leader>R",
      run_visual = "<leader>r",
      run_normal = "<leader>r",
      run_line = "<leader>rr",
      next_section = "]]",
      prev_section = "[[",
      a_section = {"aS", "S"},
      i_section = "iS",
    },
  },
}
```

You should set `run_temp_folder` to a temporary directory, e.g.
`"C:\Users\username\AppData\Temp"` on Windows.

If `matlab` is not an executable shell command and `use_custom_interpreter` is
set to false, replace `matlab_cmd` with a path to the MATLAB binary, e.g.
`"/Applications/MATLAB_R2025a.app/bin/matlab"`.

The following shows all keys that can be passed to the `opts` table and their
default values:
```lua
{
  use_custom_interpreter = true,
  matlab_cmd = "matlab",
  window_create = "vsplit",
  run_preview_length = 50,
  run_temp_folder = "~/tmp/",
  run_temp_filename = function (_)
      local timestamp = os.date("%Y%m%d_%H%M%S")
      return string.format("matvim_%s.m", timestamp)
  end,
  keymaps = {
      matlab_start = "<leader>s",
      run_file = "<leader>R",
      run_visual = "<leader>r",
      run_normal = "<leader>r",
      run_line = "<leader>rr",
      next_section = "]]",
      prev_section = "[[",
      a_section = {"aS", "S"},
      i_section = "iS",
  },
}
```

See the help file for more detail.
