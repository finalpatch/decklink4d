module decklink4d.port;

version(Windows)
{
    public import std.c.windows.windows;
    public import std.c.windows.com;
    alias OLECHAR* BSTR;
}

version(DEBUG)
{
    import std.stdio;
	void trace (T...)(string fmt, T args)
	{
		writefln(fmt, args);
	}
}
else
{
	void trace (T...) (string fmt, T args) {}
}

// Mac COM
version(OSX)
{
    struct GUID {
        align(1):
        uint   Data1;
        ushort Data2;
        ushort Data3;
        ubyte  Data4[8];
    }
    alias const(GUID) IID;
    alias const(GUID) CLSID;
    alias const(GUID)* REFGUID, REFIID, REFCLSID, REFFMTID;

    alias int HRESULT;
	alias long LONGLONG;
	alias ulong ULONGLONG;
	alias int BOOL;
	
	enum : int
	{
        S_OK = 0,
        S_FALSE = 0x00000001,
        NOERROR = 0,
        E_NOTIMPL     = cast(int)0x80004001,
        E_NOINTERFACE = cast(int)0x80004002,
        E_POINTER     = cast(int)0x80004003,
        E_ABORT       = cast(int)0x80004004,
        E_FAIL        = cast(int)0x80004005,
        E_HANDLE      = cast(int)0x80070006,
        CLASS_E_NOAGGREGATION = cast(int)0x80040110,
        E_OUTOFMEMORY = cast(int)0x8007000E,
        E_INVALIDARG  = cast(int)0x80070057,
        E_UNEXPECTED  = cast(int)0x8000FFFF,
	}

    const GUID IID_IUnknown = IUnknown.iid;
  
    interface IUnknown
    {
        extern(System):
        static const GUID iid = { 0x00000000,0x0000,0x0000,[0xC0,0x00,0x00,0x00,0x00,0x00,0x00,0x46]};
        int QueryInterface(IID iid, void** ppvObject);
        uint AddRef();
        uint Release();
    }
}

// *************************** Core Foundation helper
version(OSX)
{
    alias void* CFStringRef;
    alias void* CFTypeRef;
    alias size_t CFIndex;
    alias uint CFStringEncoding;
    alias ubyte Boolean;
    alias CFStringRef BMDSTR;

    enum {
        kCFStringEncodingMacRoman = 0,
        kCFStringEncodingWindowsLatin1 = 0x0500, /* ANSI codepage 1252 */
        kCFStringEncodingISOLatin1 = 0x0201, /* ISO 8859-1 */
        kCFStringEncodingNextStepLatin = 0x0B01, /* NextStep encoding*/
        kCFStringEncodingASCII = 0x0600, /* 0..127 (in creating CFString, values greater than 0x7F are treated as corresponding Unicode value) */
        kCFStringEncodingUnicode = 0x0100, /* kTextEncodingUnicodeDefault  + kTextEncodingDefaultFormat (aka kUnicode16BitFormat) */
        kCFStringEncodingUTF8 = 0x08000100, /* kTextEncodingUnicodeDefault + kUnicodeUTF8Format */
        kCFStringEncodingNonLossyASCII = 0x0BFF, /* 7bit Unicode variants used by Cocoa & Java */

        kCFStringEncodingUTF16 = 0x0100, /* kTextEncodingUnicodeDefault + kUnicodeUTF16Format (alias of kCFStringEncodingUnicode) */
        kCFStringEncodingUTF16BE = 0x10000100, /* kTextEncodingUnicodeDefault + kUnicodeUTF16BEFormat */
        kCFStringEncodingUTF16LE = 0x14000100, /* kTextEncodingUnicodeDefault + kUnicodeUTF16LEFormat */

        kCFStringEncodingUTF32 = 0x0c000100, /* kTextEncodingUnicodeDefault + kUnicodeUTF32Format */
        kCFStringEncodingUTF32BE = 0x18000100, /* kTextEncodingUnicodeDefault + kUnicodeUTF32BEFormat */
        kCFStringEncodingUTF32LE = 0x1c000100 /* kTextEncodingUnicodeDefault + kUnicodeUTF32LEFormat */
    }
    extern(System)
    {
        CFIndex CFStringGetLength(CFStringRef theString);
        CFIndex CFStringGetMaximumSizeForEncoding(CFIndex length, CFStringEncoding encoding);
        Boolean CFStringGetCString(CFStringRef theString, char *buffer, CFIndex bufferSize, CFStringEncoding encoding);
		const char* CFStringGetCStringPtr (CFStringRef theString, CFStringEncoding encoding);
        void CFRelease(CFTypeRef cf);
    }
    string consume(ref CFStringRef cfstr)
    {
		if (!cfstr)
			return "";

		scope(exit)
		{
            CFRelease(cfstr);
			cfstr = null;
		}

		immutable encoding = kCFStringEncodingMacRoman;

		auto p = CFStringGetCStringPtr(cfstr, encoding);
		size_t len = CFStringGetLength(cfstr);
		
		if (p)
			return p[0..len].idup;

        char[] buf = new char[1 + CFStringGetMaximumSizeForEncoding(len, encoding)];
        CFStringGetCString(cfstr, buf.ptr, buf.length, encoding);
        return buf[0..$-1].idup;
    }
}

// *************************** COM String helper
version(Windows)
{
    alias BSTR BMDSTR;
    extern(Windows) uint SysStringLen(BSTR bstr);
    extern(Windows) uint SysFreeString(BSTR bstr);
    string consume(ref BSTR bstr)
    {
		if (!bstr)
			return "";
		
        scope(exit)
		{
            SysFreeString(bstr);
			bstr = null;
		}
        return std.utf.toUTF8(bstr[0 .. SysStringLen(bstr)]);
    }
}
