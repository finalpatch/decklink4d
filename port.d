module decklink4d.port;

version(Windows)
{
    public import std.c.windows.windows;
    public import std.c.windows.com;
    alias OLECHAR* BSTR;
}

version = DEBUG;

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

  template uuid(T, const char[] g) {
    const char [] uuid =
    "immutable IID IID_"~T.stringof~"={ 0x" ~ g[6..8] ~ g[4..6] ~ g[2..4] ~ g[0..2] ~ ",0x" ~ g[11..13] ~ g[9..11] ~ ",0x" ~ g[16..18] ~ g[14..16] ~ ",[0x" ~ g[19..21] ~ ",0x" ~ g[21..23] ~ ",0x" ~ g[24..26] ~ ",0x" ~ g[26..28] ~ ",0x" ~ g[28..30] ~ ",0x" ~ g[30..32] ~ ",0x" ~ g[32..34] ~ ",0x" ~ g[34..36] ~ "] };\n";
  }

  alias int HRESULT;
  enum S_OK = 0;

  mixin(uuid!(IUnknown, "00000000-0000-0000-C000-000000000046"));
  interface IUnknown
  {
    static const GUID iid = IID_IUnknown;
  extern(C):
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
  alias CFStringRef BMDStr;

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
  extern(C)
  {
    CFIndex CFStringGetLength(CFStringRef theString);
    CFIndex CFStringGetMaximumSizeForEncoding(CFIndex length, CFStringEncoding encoding);
    Boolean CFStringGetCString(CFStringRef theString, char *buffer, CFIndex bufferSize, CFStringEncoding encoding);
    void CFRelease(CFTypeRef cf);
  }
  string consume(CFStringRef cfstr)
  {
    size_t len = 1 + CFStringGetMaximumSizeForEncoding(CFStringGetLength(cfstr), kCFStringEncodingASCII);
    char[] buf = new char[len];
    CFStringGetCString(cfstr, buf.ptr, len, kCFStringEncodingASCII);
    CFRelease(cfstr);
    return buf[0..$-1].idup;
  }
}

// *************************** COM String helper
version(Windows)
{
  alias BSTR BMDStr;
  extern(Windows) uint SysStringLen(BSTR bstr);
  extern(Windows) uint SysFreeString(BSTR bstr);
  string consume(BSTR bstr)
  {
    scope(exit)
      SysFreeString(bstr);
    return std.utf.toUTF8(bstr[0 .. SysStringLen(bstr)]);
  }
}
