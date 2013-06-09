@echo off
set DERELICT3="C:\Users\fengli\code\Derelict3"
dmd -g ..\demo\capture.d ..\port.d ..\all.d ..\bmd\decklinkapi.d ..\bmd\decklinkapidiscovery.d ..\bmd\decklinkapideckcontrol.d ..\bmd\decklinkapimodes.d ..\bmd\decklinkapiconfiguration.d ..\bmd\decklinkapitypes.d ..\bmd\decklinkapistreaming.d Ole32.lib OleAut32.lib -I"%DERELICT3%\import" "%DERELICT3%\lib\DerelictGLFW3.lib" "%DERELICT3%\lib\DerelictGL3.lib" "%DERELICT3%\lib\DerelictUtil.lib"
