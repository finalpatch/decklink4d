DERELICT3=/Users/fengl/code/Derelict3
dmd -m32 -gc ../demo/capture.d ../port.d ../all.d ../bmd/decklinkapi.d ../bmd/decklinkapidiscovery.d ../bmd/decklinkapideckcontrol.d ../bmd/decklinkapimodes.d ../bmd/decklinkapiconfiguration.d ../bmd/decklinkapitypes.d ../bmd/decklinkapistreaming.d -I$DERELICT3/import  -L-L. -L-L$DERELICT3/lib -L-lDeckLinkAPI -L-framework -LCoreFoundation -L-lDerelictGLFW3 -L-lDerelictGL3 -L-lDerelictUtil

dmd -m32 -gc ../demo/playback.d ../port.d ../all.d ../bmd/decklinkapi.d ../bmd/decklinkapidiscovery.d ../bmd/decklinkapideckcontrol.d ../bmd/decklinkapimodes.d ../bmd/decklinkapiconfiguration.d ../bmd/decklinkapitypes.d ../bmd/decklinkapistreaming.d  -L-L.  -L-lDeckLinkAPI -L-framework -LCoreFoundation
