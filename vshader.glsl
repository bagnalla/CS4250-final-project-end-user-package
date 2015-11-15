attribute vec4 vPosition;
attribute vec4 vNormal;

varying vec3 N;
varying vec3 L;
varying vec3 E;

uniform vec2 windowSize;
uniform vec4 lightPosition;
uniform vec4 cameraPosition;
uniform mat4 modelView;
uniform mat4 camera;
uniform mat4 projection;
uniform bool transformNormal;
uniform bool emissive;

void main()
{
	if (!emissive)
	{
		// compute normal
		N = (modelView * vNormal).xyz;

		// compute vPosition in world coordinates
		vec4 vPositionWorld = (modelView * vPosition);

		// compute eye direction
		E = cameraPosition.xyz - vPositionWorld.xyz;

		// compute light direction
		if (lightPosition.w == 0.0)
			L = lightPosition.xyz;
		else
			L = lightPosition.xyz - vPositionWorld.xyz;
	}

	// compute gl_Position
	gl_Position = projection * camera * modelView * vPosition/vPosition.w;
}
