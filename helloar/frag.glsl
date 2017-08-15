#ifdef GL_ES
precision highp float;
#endif
varying vec4 vcolor;
uniform bool TexOnIn;
varying lowp vec2 TexCoordOut;
uniform sampler2D Texture;

void main(void)
{
	if (TexOnIn)
		gl_FragColor = vcolor * texture2D(Texture, TexCoordOut);
	else
		gl_FragColor = vcolor;	
}