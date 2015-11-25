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

varying vec2 textureCoord;
uniform bool useTexture;
uniform sampler2D texture;

void main()
{
	if (useTexture)
	{
		gl_FragColor = texture2D(texture, textureCoord);
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
		if (fShade)
		{
			// normalize the normal, eye, and light vectors
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
	
			gl_FragColor = vec4((ambient + diffuse + specular).xyz, 1.0);
		}
		else
		{
			gl_FragColor = fColor;
		}
	}
}
