if (!(get-webconfiguration -Filter "System.WebServer/handlers/*" | where {$_.Name -eq "phpFastCgi"}))
{
    add-webconfiguration /system.webServer/handlers iis:\ -value @{
        name = "phpFastCgi"
        path = "*.php"
        verb = "*"
        modules = "FastCgiModule"
        scriptProcessor = "C:\php\php-cgi.exe"
    }
}
            
