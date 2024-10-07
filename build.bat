@echo off

SET zip="C:\Program Files\7-Zip\7z.exe"
SET name="DiscordRivalryPing.zip"
IF EXIST %name% DEL /F %name%
%zip% a -mx9 -tzip %name% info.toml src LICENSE
