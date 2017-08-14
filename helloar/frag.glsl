#ifdef GL_ES
precision highp float;
#endif
varying vec4 vcolor;
uniform int TexOnIn;
varying lowp vec2 TexCoordOut;
uniform sampler2D Texture;

void main(void)
{
	if (TexOnIn == 1)
	{
		gl_FragColor = vcolor * texture2D(Texture, TexCoordOut);
	}else{
		gl_FragColor = vcolor;
	}    
}