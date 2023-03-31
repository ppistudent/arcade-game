extern number WIDTH;
extern number HEIGHT;

#define TAU 6.28318530718
const vec2 adjustment = vec2(0.001, 0);

vec2 radial_distortion(vec2 p, float d)
{
	vec2 o = p - 0.5;
	d = dot(o, o) * d;
	return (p + o * (1.0 + d) * d);
}

vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords)
{
	vec2 r = radial_distortion(texture_coords, 0.24) + adjustment,
	     g = radial_distortion(texture_coords, 0.20),
	     b = radial_distortion(texture_coords, 0.18) - adjustment;
	return vec4(Texel(texture, r).r, Texel(texture, g).g, Texel(texture, b).b, 1)
	  - cos(g.y * WIDTH * TAU) * 0.1 - sin(g.x * HEIGHT * TAU) * 0.01;
}
