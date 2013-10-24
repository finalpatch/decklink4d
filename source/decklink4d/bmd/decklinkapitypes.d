// File generated by idl2d from
//   ../DeckLinkAPITypes.idl
module decklink4d.bmd.decklinkapitypes;

import decklink4d.port;

/* -LICENSE-START-
** Copyright (c) 2013 Blackmagic Design
**
** Permission is hereby granted, free of charge, to any person or organization
** obtaining a copy of the software and accompanying documentation covered by
** this license (the "Software") to use, reproduce, display, distribute,
** execute, and transmit the Software, and to prepare derivative works of the
** Software, and to permit third-parties to whom the Software is furnished to
** do so, all subject to the following:
** 
** The copyright notices in the Software and this entire statement, including
** the above license grant, this restriction and the following disclaimer,
** must be included in all copies of the Software, in whole or in part, and
** all derivative works of the Software, unless such copies or derivative
** works are solely in the form of machine-executable object code generated by
** a source language processor.
** 
** THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
** IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
** FITNESS FOR A PARTICULAR PURPOSE, TITLE AND NON-INFRINGEMENT. IN NO EVENT
** SHALL THE COPYRIGHT HOLDERS OR ANYONE DISTRIBUTING THE SOFTWARE BE LIABLE
** FOR ANY DAMAGES OR OTHER LIABILITY, WHETHER IN CONTRACT, TORT OR OTHERWISE,
** ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
** DEALINGS IN THE SOFTWARE.
** -LICENSE-END-
*/

// Type Declarations

alias LONGLONG BMDTimeValue;
alias LONGLONG BMDTimeScale;
alias uint BMDTimecodeBCD;
alias uint BMDTimecodeUserBits;

// Enumeration Mapping

alias uint BMDTimecodeFlags; 

/* Enum BMDTimecodeFlags - Timecode flags */

/+[v1_enum]+/ enum /+	_BMDTimecodeFlags+/ : int 
{
    bmdTimecodeFlagDefault                                       = 0,
    bmdTimecodeIsDropFrame                                       = 1 << 0
}
alias int	_BMDTimecodeFlags;

/* Enum BMDVideoConnection - Video connection types */

enum 
		/+[v1_enum]+/ /+	_BMDVideoConnection+/
{
    bmdVideoConnectionSDI                                        = 1 << 0,
    bmdVideoConnectionHDMI                                       = 1 << 1,
    bmdVideoConnectionOpticalSDI                                 = 1 << 2,
    bmdVideoConnectionComponent                                  = 1 << 3,
    bmdVideoConnectionComposite                                  = 1 << 4,
    bmdVideoConnectionSVideo                                     = 1 << 5
}
alias int	_BMDVideoConnection;
alias int BMDVideoConnection;

// Forward Declarations

/+ interface IDeckLinkTimecode; +/

/* Interface IDeckLinkTimecode - Used for video frame timecode representation. */

const GUID IID_IDeckLinkTimecode = IDeckLinkTimecode.iid;

interface IDeckLinkTimecode : IUnknown
{
extern(System):
    static const GUID iid = { 0xBC6CFBD3,0x8317,0x4325,[ 0xAC,0x1C,0x12,0x16,0x39,0x1E,0x93,0x40 ] };
    BMDTimecodeBCD GetBCD();
    HRESULT GetComponents(/+[out]+/ ubyte *hours, 
		/+[out]+/ ubyte *minutes, 
		/+[out]+/ ubyte *seconds, 
		/+[out]+/ ubyte *frames);
    HRESULT GetString(/+[out]+/ BMDSTR *timecode);
    BMDTimecodeFlags GetFlags();
    HRESULT GetTimecodeUserBits(/+[out]+/ BMDTimecodeUserBits *userBits);
};