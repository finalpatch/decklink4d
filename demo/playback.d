import decklink4d.all;
import std.stdio;

void main()
{
	version(Windows)
	{
	    CoInitialize(null);
	}

	auto decklink = getDefaultDevice();
	auto output = decklink.comcast!IDeckLinkOutput();

	void scheduleSomeFrames()
	{
		static __gshared auto frameCount = 0;
		while(true)
		{
			IDeckLinkMutableVideoFrame _frame;
			HRESULT hr = output.CreateVideoFrame(1920, 1080, 1920*4, bmdFormat8BitBGRA, bmdFrameFlagDefault, &_frame);
			if (hr != S_OK)
				return;
			
			auto frame = ComPtr!IDeckLinkMutableVideoFrame(_frame);
			{
				// fill frame with data
			}
			
			hr = output.ScheduleVideoFrame(frame.ptr, frameCount, 1, 25);
			if (hr != S_OK)
				return;

			writefln("scheduled frame %s", frameCount);
			frameCount++;
		};
	}
	class FrameCompletionCallback : IDeckLinkVideoOutputCallback
	{
		mixin NullIUnknownImpl;
	public:
		override HRESULT ScheduledFrameCompleted(IDeckLinkVideoFrame completedFrame, in BMDOutputFrameCompletionResult result)
		{
			writefln("frame completed: %s", result);
			scheduleSomeFrames();
			return S_OK;
		}
		override HRESULT ScheduledPlaybackHasStopped() { return S_OK; }
	}	

	output.SetScheduledFrameCompletionCallback(new FrameCompletionCallback);
	output.EnableVideoOutput(bmdModeHD1080i50, bmdVideoOutputFlagDefault);

	// preroll
	scheduleSomeFrames();
	// start!
	output.StartScheduledPlayback(0, 25, 1.0);

	// wait user to press 'return'
	readln();
	
	output.StopScheduledPlayback(0L, null, 0L);
	output.DisableVideoOutput();
}
