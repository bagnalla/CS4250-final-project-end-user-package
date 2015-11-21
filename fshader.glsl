/*************************************************************************************

Program:			CS 4250 Assignment 3

Author:				Alexander Bagnall
Email:				ab667712@ohio.edu

Description:		Fragment shader file.

Date:				November 9, 2015

*************************************************************************************/

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

void main()
{
	// if emissive then just do use the emission color
	if (emissive)
	{
		gl_FragColor = emissionColor;
	}
	// otherwise compute ambient, diffuse, and specular products and
	// set the color as the sum of them
	else
	{
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
