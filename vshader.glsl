attribute vec4 vPosition;
attribute vec4 vNormal;
attribute vec4 vTextureCoordinate;

varying vec3 N;
varying vec3 L;
varying vec3 E;
varying vec4 fColor;

uniform bool fShade;
uniform vec4 ambientProduct, diffuseProduct, specularProduct;
uniform float shininess;

uniform vec4 lightPosition;
uniform vec4 cameraPosition;
uniform mat4 modelView;
uniform mat4 camera;
uniform mat4 projection;
uniform bool emissive;
uniform bool hud;
uniform bool useTexture;

varying vec2 fTextureCoord;

void main()
{
	if (!emissive && !hud)
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

		if (!fShade)
		{
			vec3 NN = normalize(N);
			vec3 EE = normalize(E);
			vec3 LL = normalize(L);
			float LdotN = dot(LL, NN);

			vec4 ambient, diffuse, specular;

			// ambient
			ambient = ambientProduct;

			// diffuse
			//float Kd = max(LdotN, 0.0);
			float Kd = abs(LdotN);
			diffuse = Kd*diffuseProduct;

			// specular
			vec3 H = normalize(LL+EE);
			float Ks = pow(max(dot(NN, H), 0.0), shininess);
			if (LdotN < 0.0)
				specular = vec4(0.0, 0.0, 0.0, 1.0);
			else
				specular = Ks*specularProduct;
	
			fColor = vec4((ambient + diffuse + specular).xyz, 1.0);
		}
	}

	// compute gl_Position
	gl_Position = projection * camera * modelView * vPosition/vPosition.w;

	//fTextureCoord = vec2((vPosition.x + 0.5), (vPosition.y + 0.5));
	fTextureCoord = vec2((vTextureCoordinate.x), (vTextureCoordinate.y));

	/*if (hud)
	{
		gl_Position.z = 0.0;
	}*/
}
