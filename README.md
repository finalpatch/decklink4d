decklink4d
==========

DeckLink SDK for the D programming language

* How to use

  Using the dub package manager, it's just a matter of adding a dependency line
  to your package.json:

	"dependencies": {
		"decklink4d" :  "~master",
	},

  On Mac, you need to tell the compiler to compile for 32-bit because right now
  64-bit does not work due to a compiler issue:
  
	"dflags": [ "-m32" ],
