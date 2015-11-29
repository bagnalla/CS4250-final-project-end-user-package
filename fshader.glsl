varying vec3 N;
varying vec3 L;
varying vec3 E;
varying vec4 fColor;

uniform bool fShade;
uniform vec4 ambientProduct, diffuseProduct, specularProduct;
uniform mat4 modelView;
uniform vec4 lightPosition;
uniform float shininess;

uniform bool emissive;
uniform vec4 emissionColor;

uniform bool hud;

varying vec2 fTextureCoord;
uniform bool useTexture;
uniform sampler2D Tex;

uniform bool useBumpMap;
uniform sampler2D BumpTex;

void main()
{
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
		// if doing per-fragment lighting, compute the ambient, diffuse,
		// and specular products and set the color as the sum of them
		if (fShade || useTexture)
		{
			// normalize the normal, eye, and light vectors
			vec3 NN;
			if (useBumpMap)
			{
				vec4 temp = texture2D(BumpTex, fTextureCoord);
				//NN.x = 1 - NN.x;
				//temp.z = 1 - NN.z;
				//NN.y = 1 - NN.y;

				temp = normalize(2.0*temp-1.0);

				//temp = normalize(modelView * temp);

				//NN = normalize(2.0*NN-1.0);

				NN = temp.xyz;
			}
			else
				NN = normalize(N);

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
	
			if (useTexture)
				gl_FragColor = mix(vec4((ambient + diffuse + specular).xyz, 1.0), texture2D(Tex, fTextureCoord), 0.75);
				//gl_FragColor = mix(vec4(1.0, 0.15, 0.15, 1.0), texture2D(Tex, fTextureCoord), 0.5);
				//gl_FragColor = (ambient + diffuse + specular) * texture2D(Tex, fTextureCoord);
				//gl_FragColor = vec4(Kd * texture2D(Tex, fTextureCoord).xyz, 1.0);
			else
				gl_FragColor = vec4((ambient + diffuse + specular).xyz, 1.0);
		}
		else
		{
			gl_FragColor = fColor;
		}
	}
}
