#ifdef GL_ES
precision highp float;
#endif
varying vec4 vcolor;
//varying lowp vec2 TexCoordOut;
//uniform sampler2D Texture;

void main(void)
{
    gl_FragColor = vcolor;// * texture2D(Texture, TexCoordOut);
}