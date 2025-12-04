-- URLCap - HTTP URL Capture Application
-- Registers as HTTP/HTTPS handler, captures URLs, displays them, and restores original handler on quit

property originalHttpHandler : missing value
property originalHttpsHandler : missing value
property capturedURLs : {}
property helperPath : missing value

on run
    -- Get path to our helper tool (in Resources folder of app bundle)
    set myPath to path to me
    set helperPath to (POSIX path of myPath) & "Contents/Resources/url-handler-helper"

    -- Check if helper exists
    try
        do shell script "test -x " & quoted form of helperPath
    on error
        display alert "Error" message "url-handler-helper not found in app bundle. Please ensure the app is properly built." as critical
        quit
        return
    end try

    -- Get current handlers before we change them
    try
        set originalHttpHandler to do shell script quoted form of helperPath & " get http"
    on error
        set originalHttpHandler to "com.apple.Safari"
    end try

    try
        set originalHttpsHandler to do shell script quoted form of helperPath & " get https"
    on error
        set originalHttpsHandler to "com.apple.Safari"
    end try

    -- Get our bundle identifier
    set myBundleID to id of me

    -- Register ourselves as the handler
    try
        do shell script quoted form of helperPath & " set http " & quoted form of myBundleID
        do shell script quoted form of helperPath & " set https " & quoted form of myBundleID
    on error errMsg
        display alert "Registration Error" message "Failed to register as URL handler: " & errMsg as critical
        quit
        return
    end try

    -- Show initial window
    showCaptureWindow()
end run

on open location theURL
    -- Add URL to our list
    set end of capturedURLs to theURL

    -- Update the display
    showCaptureWindow()
end open location

on showCaptureWindow()
    set urlList to ""
    if (count of capturedURLs) = 0 then
        set urlList to "(No URLs captured yet)"
    else
        repeat with i from 1 to count of capturedURLs
            set urlList to urlList & i & ". " & (item i of capturedURLs) & return
        end repeat
    end if

    set dialogText to "URLCap is active and capturing HTTP/HTTPS URLs." & return & return
    set dialogText to dialogText & "Original HTTP handler: " & originalHttpHandler & return
    set dialogText to dialogText & "Original HTTPS handler: " & originalHttpsHandler & return & return
    set dialogText to dialogText & "Captured URLs:" & return & urlList & return
    set dialogText to dialogText & "Click 'Quit' to stop capturing and restore original handlers."

    display dialog dialogText buttons {"Clear", "Quit"} default button "Quit" with title "URLCap - URL Capture" with icon note

    set theButton to button returned of result
    if theButton is "Clear" then
        set capturedURLs to {}
        showCaptureWindow()
    else if theButton is "Quit" then
        quit
    end if
end showCaptureWindow

on quit
    -- Restore original handlers
    try
        if originalHttpHandler is not missing value then
            do shell script quoted form of helperPath & " set http " & quoted form of originalHttpHandler
        end if
        if originalHttpsHandler is not missing value then
            do shell script quoted form of helperPath & " set https " & quoted form of originalHttpsHandler
        end if
    on error errMsg
        display alert "Restore Error" message "Failed to restore original URL handlers: " & errMsg as warning
    end try

    continue quit
end quit
