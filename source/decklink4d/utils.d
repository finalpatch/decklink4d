module decklink4d.utils;
public import decklink4d.port;
public import decklink4d.bmd.decklinkapi;
import std.bitmanip;
import std.traits;
import std.stdio;

// *************************** global functions
version(Windows)
{
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
        IDeckLinkGLScreenPreviewHelper CreateOpenGLScreenPreviewHelper ();
        IDeckLinkCocoaScreenPreviewCallback CreateCocoaScreenPreview (void* /* (NSView*) */ parentView);
        IDeckLinkVideoConversion CreateVideoConversionInstance ();
    }
}

// *************************** COM helper classes
struct ComPtr(T)
{
    // takes ownership by default
    this(T o, bool addref = false)
    {
        obj = o;
        if (!isNull)
        {
			if (addref)
				obj.AddRef();
            trace("comobj %s: %s", T.stringof, cast(void*)obj);
        }
    }
    ~this()
    {
        if (!isNull)
        {
            auto count = obj.Release();
            trace("destructing %s: %s => %s", T.stringof, cast(void*)obj, count);
        }
    }
    this(this)
    {
        if (!isNull)
        {
            auto count = obj.AddRef();
            trace("postblt %s: %s => %s", T.stringof, cast(void*)obj, count);
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
    @property T* outArg()
    {
        if (!isNull)
        {
            auto count = obj.Release();
            trace("destructing %s: %s => %s", T.stringof, cast(void*)obj, count);
        }
        return &obj;
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

class SmartIterator(ITERATOR)
{
public:
    // takes ownership
    this(ITERATOR it)
    {
        m_iterator = ComPtr!ITERATOR(it);
        m_next = getNext();
    }
    this(ComPtr!ITERATOR it)
    {
        m_iterator = it;
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
    // figure out the interface type being iterated by this iterator
    alias PointerTarget!(ParameterTypeTuple!(ITERATOR.Next)[0]) INTERFACE;
    
    ComPtr!ITERATOR  m_iterator;
    ComPtr!INTERFACE m_next;
    
    ComPtr!INTERFACE getNext()
    {
        INTERFACE next;
        HRESULT hr = m_iterator.Next(&next);
        return ComPtr!INTERFACE((hr == S_OK) ? next : null);
    }
}

import core.memory;
import core.atomic;

class ComObj : IUnknown
{
    private int m_refCount = 0;

protected:
    // derived class override this
    HRESULT RealQueryInterface(const(IID)* riid, void** ppv)
    {
        if (*riid == IID_IUnknown)
        {
            *ppv = cast(void*)cast(IUnknown)this;
            AddRef();
            return S_OK;
        }
        else
        {   *ppv = null;
            return E_NOINTERFACE;
        }
    }
extern(System):
    version(Windows)
    {
        override HRESULT QueryInterface(const(IID)* riid, void** ppv)
        {
            return RealQueryInterface(riid, ppv);
        }
    }
    else
    {
        override HRESULT QueryInterface(IID riid, void** ppv)
        {
            return RealQueryInterface(&riid, ppv);
        }
    }
    override uint AddRef()
    {
        int lRef = atomicOp!"+="(*cast(shared)&m_refCount, 1);
        version(DEBUG)
        {
            scope(exit)
                writefln("addref->%s", lRef);
        }
        if (lRef == 1)
        {
            // pin this object down
            version(DEBUG)
            {
                writefln("pinned");
            }
            GC.addRoot(cast(void*)this);
            GC.setAttr(cast(void*)this, GC.BlkAttr.NO_MOVE);
        }
        return lRef;
    }
    override uint Release()
    {
        int lRef = atomicOp!"-="(*cast(shared)&m_refCount, 1);
        version(DEBUG)
        {
            scope(exit)
                writefln("release->%s", lRef);
        }
        if (lRef == 0)
        {
            // okay to collect now
            writefln("unpinned");
            GC.removeRoot(cast(void*)this);
            GC.clrAttr(cast(void*)this, GC.BlkAttr.NO_MOVE);
            return 0;
        }
        return lRef;
    }
}

auto getDefaultDevice()
{
    auto i = new SmartIterator!IDeckLinkIterator(CreateDeckLinkIteratorInstance());
    foreach(decklink; i)
        return decklink;
    throw new Exception("no decklink device");
}
