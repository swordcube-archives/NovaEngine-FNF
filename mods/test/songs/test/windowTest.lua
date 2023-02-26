function onCreate()
    -- 1 is MSG_ERROR
    -- 2 is MSG_QUESTION
    -- 3 is MSG_WARNING
    -- Any other number is MSG_INFORMATION
    WindowUtil:showMessage("This is a native error!", "Shown via a LUA script!!!", 1)
    WindowUtil:showMessage("This is a native question!", "Shown via a LUA script!!!", 2)
    WindowUtil:showMessage("This is a native warning!", "Shown via a LUA script!!!", 3)
    WindowUtil:showMessage("This is a native info box!", "Shown via a LUA script!!!", 4)
end