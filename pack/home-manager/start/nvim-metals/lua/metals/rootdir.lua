local Path = require("plenary.path")

--- Checks to see if the default or passed in patterns for a root file are
--- found or not for the given target level.
local has_pattern = function(patterns, target)
  for _, pattern in ipairs(patterns) do
    local what_we_are_looking_for = Path:new(target, pattern)
    if what_we_are_looking_for:exists() then
      return pattern
    end
  end
end

--- NOTE: This only searches 2 levels deep to find nested build files.
--- Given a situation like the below one where you have a root build.sbt
--- and one in your module a, you want to ensure the root is correctly set as
--- the root one, not the a one. This checks the parent dir to ensure this.
--- build.sbt  <-- this is the root
--- a/
---  - build.sbt <- this is not
---  - src/main/scala/Main.scala
local find_root_dir = function(patterns, startpath)
  local path = Path:new(startpath)
  -- TODO if we don't find it do we really want to search / probably not... add a check for this
  for _, parent in ipairs(path:parents()) do
    local pattern = has_pattern(patterns, parent)
    if pattern then
      local grandparent = Path:new(parent):parent()
      -- If the pattern is found, we don't check for all patterns anymore,
      -- instead only the one that was found. This will ensure that we don't
      -- find a buid.sc is src/build.sc and also a .git in ./ causing it to
      -- default to that instead of src for the root.
      if has_pattern({ pattern }, grandparent) then
        return grandparent.filename
      else
        return parent
      end
    end
  end
end

return {
  find_root_dir = find_root_dir,
}
