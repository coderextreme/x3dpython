#ifdef GL_ES
  precision highp float;
#endif

attribute vec3 position;
attribute vec3 normal;
attribute vec2 texcoord;

uniform mat4 modelViewProjectionMatrix;
uniform mat4 modelViewMatrix;
uniform mat4 modelViewMatrixInverse;
uniform mat4 normalMatrix;

uniform vec3 chromaticDispersion;
uniform float bias;
uniform float scale;
uniform float power;
uniform float a;
uniform float b;
uniform float c;
uniform float d;
uniform float tdelta;
uniform float pdelta;

varying vec3 t;
varying vec3 tr;
varying vec3 tg;
varying vec3 tb;
varying float rfac;

vec3 cart2sphere(vec3 p) {
     float r = sqrt(p.x*p.x + p.y*p.y + p.z*p.z);
     float theta = acos(p.y/r);
     float phi = atan(p.z, p.x);
     return vec3(r, theta, phi);
}
     
vec3 rose(vec3 p) {
     float rho = a + b * cos(c * p.y + tdelta) * cos(d * p.z + pdelta);
     float x = rho * cos(p.z) * cos(p.y);
     float z = rho * cos(p.z) * sin(p.y);
     float y = rho * sin(p.z);
     return vec3(x, y, z);
}

vec3 rose_normal(vec3 p) {
     /* convert cartesian position to spherical coordinates */
     vec3 base = cart2sphere(p);
     /* add a little to phi */
     vec3 td = base + vec3(0.0, 0.0001, 0.0);
     /* add a little to theta */
     vec3 pd = base + vec3(0.0, 0.0, 0.0001);

     /* convert back to cartesian coordinates */
     vec3 br = rose(base);
     vec3 bt = rose(td);
     vec3 bp = rose(pd);

     return normalize(cross(bt - br, bp - br));
}

vec4 rose_position(vec3 p) {
	return vec4(rose(cart2sphere(p)), 1.0);
	/*return vec4(position, 1.0);*/
}

void main()
{
    mat3 mvm3=mat3(
		modelViewMatrix[0].x,
		modelViewMatrix[0].y,
		modelViewMatrix[0].z,
		modelViewMatrix[1].x,
		modelViewMatrix[1].y,
		modelViewMatrix[1].z,
		modelViewMatrix[2].x,
		modelViewMatrix[2].y,
		modelViewMatrix[2].z
    );
    vec3 fragNormal = mvm3*rose_normal(position);
    gl_Position = modelViewProjectionMatrix*rose_position(position);
    vec3 incident = normalize((modelViewMatrix * rose_position(position)).xyz);

    t = reflect(incident, fragNormal)*mvm3;
    tr = refract(incident, fragNormal, chromaticDispersion.x)*mvm3;
    tg = refract(incident, fragNormal, chromaticDispersion.y)*mvm3;
    tb = refract(incident, fragNormal, chromaticDispersion.z)*mvm3;

    rfac = bias + scale * pow(0.5+0.5*dot(incident, fragNormal), power);
}
