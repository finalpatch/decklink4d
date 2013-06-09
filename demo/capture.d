import decklink4d.all;
import std.stdio;
import core.thread;

import derelict.opengl3.gl3;
import derelict.glfw3.glfw3;

auto getFirstDevice()
{
	auto i = new SmartIterator!(IDeckLinkIterator, IDeckLink)(CreateDeckLinkIteratorInstance());
	foreach(decklink; i)
		return decklink;
	throw new Exception("no decklink device");
}

void main()
{
	DerelictGL3.load();
	DerelictGLFW3.load();

	version(Windows)
	{
	    CoInitialize(null);
	}
	// print api version
	auto info = ComPtr!IDeckLinkAPIInformation(CreateDeckLinkAPIInformationInstance());
	BMDStr str;
	info.GetString(BMDDeckLinkAPIVersion, &str);
	string ver = consume(str);
	writefln("DeckLink API version: "~ver);

	// try grab the first decklink device
	auto decklink = getFirstDevice();

	// print device name
	decklink.GetDisplayName(&str);
	string dispname = consume(str);
	writefln("Device name: %s", dispname);

	// initialize an opengl window
	if (!glfwInit()) throw new Exception("Failed to initialize GLFW");
	auto window = glfwCreateWindow(1280, 720, "DeckLink", null, null);
	if (!window) throw new Exception("Window failed to create");
	glfwMakeContextCurrent(window);

	// initialize decklink preview helper
	auto glpreview = ComPtr!IDeckLinkGLScreenPreviewHelper(CreateOpenGLScreenPreviewHelper());
	glpreview.InitializeGL();

	// hook input frame callback
	auto input = decklink.comcast!IDeckLinkInput();
	auto cb = new class IDeckLinkInputCallback
		{
			mixin NullIUnknownImpl;
		public:
    		override HRESULT VideoInputFormatChanged(in BMDVideoInputFormatChangedEvents notificationEvents, IDeckLinkDisplayMode newDisplayMode, in BMDDetectedVideoInputFormatFlags detectedSignalFlags)
    		{
    			return S_OK;
    		}
    		override HRESULT VideoInputFrameArrived(IDeckLinkVideoInputFrame videoFrame, IDeckLinkAudioInputPacket audioPacket)
    		{
				glpreview.SetFrame(videoFrame);
				return S_OK;
    		}
		};
	input.SetCallback(cb);
	
	// start capture
	input.EnableVideoInput(bmdModeHD1080i50, bmdFormat8BitYUV, 0);
	input.StartStreams();

	// run event loop
	while (!glfwWindowShouldClose(window))
	{
		glpreview.PaintGL();
		glfwSwapBuffers(window);
		glfwPollEvents();
	}
	
	glfwTerminate();
}
