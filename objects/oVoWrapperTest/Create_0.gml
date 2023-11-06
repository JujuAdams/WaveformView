// must use full paths since stb_vorbis isn't aware of GM's path stuff
var full_path = working_directory + "sndChickenNuggets.ogg"; // sonic time twisted my beloved

if (!vo_is_available())
	throw "the dll isn't loaded, lol";

show_debug_message("decoding file " + full_path);
var samples_or_error = vo_decode(full_path);
if (samples_or_error <= vo_error_unknown)
	throw "decode error code = " + string(samples_or_error);

var sample_type = buffer_s16;
var channels = vo_get_channels();
var sample_rate = vo_get_sample_rate();
var _bytesPerSample = channels*buffer_sizeof(sample_type);

var in_bytes = samples_or_error*_bytesPerSample;

var buff = buffer_create(in_bytes, buffer_fixed, 1);
// force gm into allocating all the underlying memory all at once
buffer_fill(buff, 0, buffer_u8, 0, in_bytes);

show_debug_message("decoded!");
// returns amount of bytes written or an error code
var get_error = vo_get_data(buffer_get_address(buff), in_bytes);
if (get_error <= vo_error_unknown)
	throw "get_data error code = " + string(get_error);
vo_free();

var _measurementStrideSeconds = 0.05;
var _sampleStride = sample_rate*_measurementStrideSeconds;
var _measurementCount = (samples_or_error div _sampleStride) - 1;

waveformArray = array_create(_measurementCount);
var _t = get_timer();

buffer_seek(buff, buffer_seek_start, 0);
var _i = 0;
repeat(_measurementCount)
{
    var _value = 0;
    repeat(_sampleStride*_bytesPerSample / 2)
    {
        _value += abs(buffer_read(buff, buffer_s16));
    }
    
    _value /= 65535*channels*_sampleStride;
    show_debug_message(string(_i) + " = " + string(get_timer() - _t));
    
    waveformArray[@ _i] = _value;
    ++_i;
}

vertex_format_begin();
vertex_format_add_position_3d();
vertex_format_add_colour();
vertex_format_add_texcoord();
var _format = vertex_format_end();

vbuff = vertex_create_buffer();
vertex_begin(vbuff, _format);
draw_primitive_begin(pr_pointlist);

var _i = 0;
repeat(array_length(waveformArray))
{
    var _value = waveformArray[_i];
    
    vertex_position_3d(vbuff, _i, 0, 0);
    vertex_colour(vbuff, c_white, 1);
    vertex_texcoord(vbuff, 0, 0);
    
    vertex_position_3d(vbuff, _i, _value, 0);
    vertex_colour(vbuff, c_white, 1);
    vertex_texcoord(vbuff, 0, 0);
    
    ++_i;
}

draw_primitive_end();

vertex_end(vbuff);

//var buffsound = audio_create_buffer_sound(
//	buff,
//	sample_type,
//	sample_rate,
//	0,
//	in_bytes,
//	(channels == 2) ? audio_stereo : audio_mono
//);
//
//audio_play_sound(buffsound, 1, true);