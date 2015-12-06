const int NUM_LIGHT_SOURCES = 2;

varying vec3 N;
varying vec3 L;
varying vec3 E;
varying vec4 fColor;

uniform vec4 materialAmbient, materialDiffuse, materialSpecular;
uniform float materialShininess;

uniform mat4[NUM_LIGHT_SOURCES] lightSources;
varying vec3[NUM_LIGHT_SOURCES] lightDirections;

uniform bool fShade;
uniform mat4 modelView;

uniform bool emissive;
uniform vec4 emissionColor;

uniform float alphaOverride;

uniform bool hud;

varying vec2 fTextureCoord;
uniform bool useTexture;
uniform sampler2D Tex;

uniform bool useBumpMap;
uniform sampler2D BumpTex;
uniform mat4 normalRotation;

void main()
{
	vec4 color;

	if (useTexture && (hud || emissive))
	{
		gl_FragColor = texture2D(Tex, fTextureCoord);
	}
	// if emissive then just do use the emission color
	else if (emissive)
	{
		gl_FragColor = emissionColor;
	}
	else
	{
		if (fShade)
		{
			vec3 NN;
			if (useBumpMap)
			{
				vec4 temp = texture2D(BumpTex, fTextureCoord);

				temp = normalize(2.0*temp-1.0);
				//temp.xz = temp.zx;
				//temp.xy = temp.yx;

				temp = normalRotation * temp;

				NN = temp.xyz;
				//NN = normalize(normalize(temp.xyz) + N);

				//NN = normalize(vec3(temp.x, temp.y, -temp.z));
			}
			else
				NN = normalize(N);

			vec3 EE = normalize(E);

			vec3 lightColorSum = vec3(0.0, 0.0, 0.0);
			vec4 objectAmbient, objectDiffuse, objectSpecular;
			if (useTexture)
			{
				vec4 texColor = texture2D(Tex, fTextureCoord);
				objectAmbient = mix(materialAmbient, texColor, 0.5);
				objectDiffuse = mix(materialDiffuse, texColor, 0.5);
				objectSpecular = mix(materialSpecular, texColor, 0.5);
			}
			else
			{
				objectAmbient = materialAmbient;
				objectDiffuse = materialDiffuse;
				objectSpecular = materialSpecular;
			}

			for (int i = 0; i < NUM_LIGHT_SOURCES; ++i)
			{
				//if (lightSources[i][3] == vec4(0.0, 0.0, 0.0, 0.0))
				//	continue;

				//vec4 ambientProduct = materialAmbient * lightSources[i][0];
				//vec4 diffuseProduct = materialDiffuse * lightSources[i][1];
				//vec4 specularProduct = materialSpecular * lightSources[i][2];
				vec4 ambientProduct = objectAmbient * lightSources[i][0];
				vec4 diffuseProduct = objectDiffuse * lightSources[i][1];
				vec4 specularProduct = objectSpecular * lightSources[i][2];

				float distance;
				//if (lightSources[i][3].w == 0.0)
				//	distance = 1.0;
				//else
					distance = pow(max(1.0, length(lightDirections[i])), 2);

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

			color = vec4(lightColorSum, 1.0);
		}
		else
		{
			color = fColor;
		}

		/*if (useTexture)
			gl_FragColor = mix(color, texture2D(Tex, fTextureCoord), 0.5);
			//gl_FragColor = vec4(Kd * texture2D(Tex, fTextureCoord).xyz, 1.0);
		else*/
			gl_FragColor = color;
	}

	if (alphaOverride != 0.0)
	{
		if (gl_FragColor.xyz == vec3(0.0, 0.0, 0.0))
			gl_FragColor.w = 0.0;
		else
			gl_FragColor.w = alphaOverride;
	}
}
