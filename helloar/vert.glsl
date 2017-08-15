uniform mat4 trans;
uniform mat4 proj;
uniform bool TexOnIn;
// varying int TexOnOut;
attribute vec4 coord;
attribute vec4 color;
varying vec4 vcolor;
attribute vec2 TexCoordIn;
varying vec2 TexCoordOut;

void main(void)
{
    vcolor = color;
    gl_Position = proj*trans*coord;
    // TexOnOut=TexOnIn;
    if (TexOnIn)    
    	TexCoordOut = TexCoordIn;
    else
    	TexCoordOut = vec2(0);
    
}