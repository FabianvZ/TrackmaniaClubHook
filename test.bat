@echo off

SET directory="%userprofile%\OpenplanetNext\Plugins\DiscordRivalryPing"
rmdir %directory% /s /q 
mkdir %directory%
xcopy "." %directory% /i /y /s /exclude:exclude.txt