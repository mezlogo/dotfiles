---@return string|nil path to the eclipse-formatter.xml in recursive search from cwd
local function find_eclipse_formatter_xml()
  local target = "eclipse-formatter.xml"

  local cwd = vim.fn.getcwd()
  if not cwd or cwd == "" then
    return nil
  end

  local path = vim.fs.find(function(name, _)
    return name == target
  end, { path = cwd, type = "file" })

  if #path == 0 then
    return nil
  end

  return path[1]
end

--- Bind nvim-jdtls functions for testing
--- test class, test method, generate test, go to test, go to subject
local function set_jdtls_test_keymap()
  local opts = { noremap = true, silent = true }

  -- 1. Run entire test class
  vim.keymap.set("n", "<leader>tc", function()
    require("jdtls").test_class()
  end, opts)

  -- 2. Run current test method
  vim.keymap.set("n", "<leader>tm", function()
    require("jdtls").test_nearest_method()
  end, opts)

  -- 3. Generate test file
  vim.keymap.set("n", "<leader>tg", function()
    require("jdtls.tests").generate()
  end, opts)

  -- 4. Go to subject (implementation under test) from test file
  vim.keymap.set("n", "<leader>gs", function()
    require("jdtls").goto_super_method()
  end, opts)

  -- 5. Go to test file from subject (or vice versa)
  vim.keymap.set("n", "<leader>gt", function()
    require("jdtls.tests").goto_subjects()
  end, opts)
end

local function get_bundles()
  local java_debug_path = vim.fn.stdpath('data') .. '/mason/share/java-debug-adapter/com.microsoft.java.debug.plugin.jar'

  local bundles = {
    java_debug_path,
  }

  local java_test_path = vim.fn.stdpath('data') .. '/mason/share/java-test/*.jar'
  local java_test_bundles = vim.split(vim.fn.glob(java_test_path), "\n")
  local excluded = {
    "com.microsoft.java.test.runner-jar-with-dependencies.jar",
    "jacocoagent.jar",
  }


  for _, java_test_jar in ipairs(java_test_bundles) do
    local fname = vim.fn.fnamemodify(java_test_jar, ":t")
    if not vim.tbl_contains(excluded, fname) then
      table.insert(bundles, java_test_jar)
    end
  end

  return bundles
end

--- Find file with name
--- At this moment this file has name ~/.local/share/nvim/mason/packages/jdtls/plugins/org.eclipse.equinox.launcher_1.7.100.v20251111-0406.jar
--- But I want to write code supported both: dynamic jar version AND mason package locaction
--- That's why first I get path of mason inside 'data'
--- Then I search file using globing org.eclipse.equinox.launcher_*.jar
---@return string|nil path to the launcher jar
local function find_launcher_jar()
  local mason_path = vim.fn.stdpath('data') .. '/mason/packages/jdtls/plugins/'
  local launcher_jar = vim.fn.glob(mason_path .. 'org.eclipse.equinox.launcher_*.jar')
  if launcher_jar == '' then
    return nil
  end
  return launcher_jar
end

--- Find a directory with exact name 'config_linux', not 'config_linux_arm'
--- Right now file is located at ~/.local/share/nvim/mason/packages/jdtls/config_linux
--- By I would use direcotry search inside mason
---@return string|nil path to the config_linux directory
local function find_config_linux_dir(config_name)
  local mason_path = vim.fn.stdpath('data') .. '/mason/packages/jdtls/'
  local config_dir = vim.fn.glob(mason_path .. config_name)
  if config_dir == '' then
    return nil
  end
  return config_dir
end

--- Find lombok.jar file inside jdtls mason package
---@return string|nil path to the lombok.jar file
local function find_lombok_jar()
  local mason_path = vim.fn.stdpath('data') .. '/mason/packages/jdtls/lombok.jar'
  if vim.fn.filereadable(mason_path) == 0 then
    return nil
  end
  return mason_path
end

--- Creates a project-specific jdtls index/cache directory path in the user's cache directory.
---@param root_dir string The root directory of the Java project.
---@return string The full path to the jdtls cache directory for this project.
local function get_jdtls_cache_dir(root_dir)
  -- Use XDG_CACHE_HOME if set, otherwise default to ~/.cache
  local xdg_cache = os.getenv("XDG_CACHE_HOME")
  local cache_home = xdg_cache and xdg_cache ~= "" and xdg_cache
  or (os.getenv("HOME") and os.getenv("HOME") .. "/.cache")

  if not cache_home then
    error("Could not determine cache directory: $HOME is not set")
  end

  -- Normalize root_dir to avoid issues with trailing slashes
  root_dir = vim.fs.normalize(root_dir)

  local project_name = vim.fn.fnamemodify(root_dir, ":t")
  project_name = vim.fn.substitute(project_name, "[^a-zA-Z0-9._-]", "_", "g")

  local jdtls_dir = cache_home .. "/jdtls/" .. project_name
  return jdtls_dir
end

local root_markers = {
  -- Multi-module projects
  'mvnw', -- Maven
  'gradlew', -- Gradle
  'settings.gradle', -- Gradle
  'settings.gradle.kts', -- Gradle
  -- Single-module projects
  'build.xml', -- Ant
  'pom.xml', -- Maven
  'build.gradle', -- Gradle
  'build.gradle.kts', -- Gradle
}

local function main()
  local launch_jar = find_launcher_jar()
  local config_dir = find_config_linux_dir('config_linux')
  local project_name = vim.fn.fnamemodify(vim.fn.getcwd(), ':p:h:t')
  local data_dir = get_jdtls_cache_dir(project_name)
  local lombok_jar = find_lombok_jar()
  local formatter_path = find_eclipse_formatter_xml()

  local config = {
    name = "jdtls",

    -- `cmd` defines the executable to launch eclipse.jdt.ls.
    -- `jdtls` must be available in $PATH and you must have Python3.9 for this to work.
    --
    -- As alternative you could also avoid the `jdtls` wrapper and launch
    -- eclipse.jdt.ls via the `java` executable
    -- See: https://github.com/eclipse/eclipse.jdt.ls#running-from-the-command-line

    cmd = {
      "myjdtls",
      launch_jar,
      config_dir,
      data_dir,
      lombok_jar,
    },

    -- `root_dir` must point to the root of your project.
    -- See `:help vim.fs.root`
    root_dir = vim.fs.root(0, root_markers),


    -- Here you can configure eclipse.jdt.ls specific settings
    -- See https://github.com/eclipse/eclipse.jdt.ls/wiki/Running-the-JAVA-LS-server-from-the-command-line#initialize-request
    -- for a list of options
    settings = {
      java = {
        updateBuildConfiguration = "interactive",
        format = {
          enabled = false,
          settings = {
            url = 'file:///home/mezlogo/google-formatter-eclipse.xml',
            profile = 'GoogleStyle',
          }
        },
        jdt = {
          ls = {
            lombokSupport = { enabled = true },
            protobufSupport = { enabled = true },
            androidSupport = { enabled = true },
            appcds = { enabled = true },
            javac = { enabled = false },
          }
        }
      }
    },


    -- This sets the `initializationOptions` sent to the language server
    -- If you plan on using additional eclipse.jdt.ls plugins like java-debug
    -- you'll need to set the `bundles`
    --
    -- See https://codeberg.org/mfussenegger/nvim-jdtls#java-debug-installation
    --
    -- If you don't plan on any eclipse.jdt.ls plugins you can remove this
    init_options = {
      bundles = get_bundles()
    },
    on_attach = function()
      set_jdtls_test_keymap()
    end,
  }

  require('jdtls').start_or_attach(config)
end

local function fixIndent()
  vim.opt.tabstop = 2
  vim.opt.softtabstop = 2
  vim.opt.shiftwidth = 2
  vim.opt.expandtab = true
  vim.opt.autoindent = true
  vim.opt.smartindent = true
end

main()
fixIndent()
