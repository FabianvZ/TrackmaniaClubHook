@echo off

SET directory="%userprofile%\OpenplanetNext\Plugins\DiscordRivalryPing"
mkdir %directory%
xcopy "." %directory% /i /y /s /exclude:exclude.txt