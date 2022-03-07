#define IMPLEMENT_API
#include <cstdio>
#include "hx/CFFI.h"

extern "C" {
#include <libavcodec/avcodec.h>
#include <libavformat/avformat.h>

/*
 * Author: kemo (@kem0x on github)
 */
value GetFramecount(value path)
{
	auto pathC = val_get_string(path);
	
	AVFormatContext* pFormatCtx = avformat_alloc_context();
	int ret = avformat_open_input(&pFormatCtx, pathC, NULL, NULL);


#ifdef _DEBUG
	MessageBoxA(nullptr, pathC, "DEBUG", MB_OK);
#endif
	
	if (ret != 0)
	{
		MessageBoxA(nullptr, "Unable to open video file", "WebmHelper", MB_OK);
		return alloc_int(0);
	}

	AVCodec* video_dec = (AVCodec*)1;

	//Finding the best stream in the file
	const auto video_stream_index = av_find_best_stream(pFormatCtx, AVMEDIA_TYPE_VIDEO, -1, -1, &video_dec, 0);
	if (video_stream_index < 0)
	{
		MessageBoxA(nullptr, "Couldn't find the stream in the file", "WebmHelper", MB_OK);
		return alloc_int(0);
	}

	auto videoStream = pFormatCtx->streams[video_stream_index];

	int frameRate = (double)videoStream->r_frame_rate.num / (double)videoStream->r_frame_rate.den;

	double duration = (double)pFormatCtx->duration / 1000000;

	auto frameCount = static_cast<int>(duration * frameRate);

	return alloc_int(frameCount);
}
}

DEFINE_PRIM(GetFramecount, 1);
