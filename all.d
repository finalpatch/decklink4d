module decklink4d.all;
public import decklink4d.port;
public import decklinkapi;
import std.bitmanip;

// *************************** global functions
version(Windows)
{
      IDeckLinkAPIInformation CreateDeckLinkAPIInformationInstance ()
      {
        IDeckLinkAPIInformation p;
        HRESULT hr=CoCreateInstance(&CLSID_CDeckLinkAPIInformation, null, CLSCTX_ALL, &IID_IDeckLinkAPIInformation, &p);
        return (hr == S_OK) ? p : null;
      }
      IDeckLinkIterator CreateDeckLinkIteratorInstance ()
      {
        IDeckLinkIterator p;
        HRESULT hr=CoCreateInstance(&CLSID_CDeckLinkIterator, null, CLSCTX_ALL, &IID_IDeckLinkIterator, &p);
        return (hr == S_OK) ? p : null;
      }
      IDeckLinkGLScreenPreviewHelper CreateOpenGLScreenPreviewHelper()
      {
        IDeckLinkGLScreenPreviewHelper p;
        HRESULT hr=CoCreateInstance(&CLSID_CDeckLinkGLScreenPreviewHelper, null, CLSCTX_ALL, &IID_IDeckLinkGLScreenPreviewHelper, &p);
        return (hr == S_OK) ? p : null;
      }
}
else
{
  extern(System) {
      IDeckLinkIterator CreateDeckLinkIteratorInstance ();
      IDeckLinkAPIInformation CreateDeckLinkAPIInformationInstance ();
      IDeckLinkGLScreenPreviewHelper CreateOpenGLScreenPreviewHelper ();
      // IDeckLinkCocoaScreenPreviewCallback* CreateCocoaScreenPreview (void* /* (NSView*) */ parentView);
      // IDeckLinkVideoConversion* CreateVideoConversionInstance ();
  }
}

// *************************** COM helper classes
struct ComPtr(T)
{
	// takes ownership
	this(T o)
	{
		obj = o;
		if (!isNull)
		{
			trace("comobj %s: %s", T.stringof, &obj);
		}
	}
	~this()
	{
		if (!isNull)
		{
			auto count = obj.Release();
			trace("destructing %s: %s => %s", T.stringof, &obj, count);
		}
	}
	this(this)
	{
		if (!isNull)
		{
			auto count = obj.AddRef();
			trace("postblt %s: %s => %s", T.stringof, &obj, count);
		}
	}
	@property bool isNull()
	{
		return obj is null;
	}
	int opDispatch(string op, T...)(T args)
	{
		static assert(op != "QueryInterface" && op != "AddRef" && op != "Release");
		return mixin("obj."~op~"(args)");
	}

	ComPtr!I comcast(I)()
	{
		void* p = null;
		auto pp = &p;
        HRESULT hr = obj.QueryInterface(getGuid(I.iid), pp);
		if (hr != S_OK)
			throw new Exception("no interface");
		I target = cast(I)p;
		return ComPtr!I(target);
	}
	@property T ptr()
	{
		return obj;
	}
private:
	T obj;
    
    version(Windows)
    {
        // Windows QueryInterface needs a pointer
        auto getGuid(const ref GUID guid) { return &guid; }
    }
    else
    {
        // DeckLinkAPI Mac GUIDs are endian swapped
        auto getGuid(in GUID guid)
        {
            const GUID endianSwapped = { swapEndian(guid.Data1), swapEndian(guid.Data2), swapEndian(guid.Data3), guid.Data4 };
            return endianSwapped;
        }
    }
}

class SmartIterator(ITERATOR, T)
{
public:
	// takes ownership
	this(ITERATOR it)
	{
		m_iterator = ComPtr!IDeckLinkIterator(it);
		m_next = getNext();
	}
	bool empty()
	{
		return m_next.isNull();
	}
	auto front()
	{
		return m_next;
	}
	void popFront()
	{
		if (!(m_next.isNull))
			m_next = getNext();
	}
private:
	ComPtr!IDeckLinkIterator m_iterator;
	ComPtr!IDeckLink m_next;
	
	ComPtr!IDeckLink getNext()
	{
		T next;
		HRESULT hr = m_iterator.Next(&next);
		return ComPtr!T((hr == S_OK) ? next : null);
	}
}

mixin template NullIUnknownImpl()
{
	version(Windows)
		extern(System) public override HRESULT QueryInterface(const(IID)* riid, void** pvObject)  {return -1;}

    else
    	extern(System) public override HRESULT QueryInterface(IID riid, void** ppv) {return -1;}
    extern(System) public override uint AddRef() { return 2; }
    extern(System) public override uint Release() { return 1; }
}
