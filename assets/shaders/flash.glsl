extern number flash_factor;

vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords)
{
	return flash_factor * color * Texel(texture, texture_coords);
}
