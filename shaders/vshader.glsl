const int NUM_LIGHT_SOURCES = 3;

attribute vec4 vPosition;
attribute vec4 vNormal;
attribute vec4 vTextureCoordinate;

varying vec3 rawN;
varying vec3 N;
varying vec3 L;
varying vec3 E;
varying vec4 fColor;

uniform bool fShade;

uniform vec4 materialAmbient, materialDiffuse, materialSpecular;
uniform float materialShininess;

uniform mat4[NUM_LIGHT_SOURCES] lightSources;
varying vec3[NUM_LIGHT_SOURCES] lightDirections;

uniform vec4 cameraPosition;
uniform mat4 model;
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
		N = (model * vNormal).xyz;
		rawN = normalize(vNormal.xyz);

		// compute vPosition in world coordinates
		vec4 vPositionWorld = (model * vPosition);

		// compute eye direction
		E = cameraPosition.xyz - vPositionWorld.xyz;

		// compute light directions
		for (int i = 0; i < NUM_LIGHT_SOURCES; ++i)
		{
			if (lightSources[i][3] == vec4(0.0, 0.0, 0.0, 0.0))
			{
				lightDirections[i] = vec3(0.0, 0.0, -1.0);
				continue;
			}

			if (lightSources[i][3].w == 0.0)
				lightDirections[i] = normalize(lightSources[i][3].xyz);
			else
				lightDirections[i] = (lightSources[i][3] - vPositionWorld).xyz;
		}

		if (!fShade)
		{
			vec3 NN = normalize(N);
			vec3 EE = normalize(E);

			vec3 lightColorSum = vec3(0.0, 0.0, 0.0);

			for (int i = 0; i < NUM_LIGHT_SOURCES; ++i)
			{
				if (lightSources[i][3] == vec4(0.0, 0.0, 0.0, 0.0))
					continue;

				vec4 ambientProduct = materialAmbient * lightSources[i][0];
				vec4 diffuseProduct = materialDiffuse * lightSources[i][1];
				vec4 specularProduct = materialSpecular * lightSources[i][2];

				float distance;
				if (lightSources[i][3].w == 0.0)
					distance = 1.0;
				else
					distance = pow(length(lightDirections[i]), 2);

				vec3 LL = normalize(lightDirections[i]);
				float LdotN = dot(LL, NN);

				vec4 ambient, diffuse, specular;

				// ambient
				ambient = ambientProduct / distance;

				// diffuse
				float Kd = max(LdotN, 0.0);
				//float Kd = abs(LdotN);
				diffuse = Kd * diffuseProduct / distance;

				// specular
				vec3 H = normalize(LL+EE);
				float Ks = pow(max(dot(NN, H), 0.0), materialShininess) / distance;
				if (LdotN < 0.0)
					specular = vec4(0.0, 0.0, 0.0, 1.0);
				else
					specular = Ks*specularProduct;

				lightColorSum += (ambient + diffuse + specular).xyz;
			}

			fColor = vec4(lightColorSum, 1.0);

		}
	}

	// compute gl_Position
	gl_Position = projection * camera * model * vPosition/vPosition.w;

	//fTextureCoord = vec2((vPosition.x + 0.5), (vPosition.y + 0.5));
	fTextureCoord = vec2((vTextureCoordinate.x), (vTextureCoordinate.y));

	/*if (hud)
	{
		gl_Position.z = 0.0;
	}*/
}
