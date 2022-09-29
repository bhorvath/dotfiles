if application "iTerm" is not running then
  activate application "iTerm"
else
  tell application "iTerm"
    create window with default profile
  end tell
end if
