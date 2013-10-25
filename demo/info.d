import std.stdio;
import decklink4d.all;

void listModes(T)(ComPtr!T io)
{
	IDeckLinkDisplayModeIterator i;
	io.GetDisplayModeIterator(&i);
	auto modes = new SmartIterator!IDeckLinkDisplayModeIterator(i);
	foreach (mode; modes)
	{
		BMDSTR str;
		mode.GetName(&str);
		string name = consume(str);
		writefln("    %s", name);
	}
}

void main()
{
	auto i = ComPtr!IDeckLinkIterator(CreateDeckLinkIteratorInstance());

	auto info = i.comcast!IDeckLinkAPIInformation;
	BMDSTR str;
	info.GetString(BMDDeckLinkAPIVersion, &str);
	string ver = consume(str);
	writefln("DeckLink API version: %s\n", ver);

    auto ii = new SmartIterator!IDeckLinkIterator(i);
    foreach(decklink; ii)
	{
		decklink.GetDisplayName(&str);
		string name = consume(str);
		writefln("%s", name);
		writeln("  Input modes:");
		listModes(decklink.comcast!IDeckLinkInput);
		writeln("  Output modes:");
		listModes(decklink.comcast!IDeckLinkOutput);
	}
}
