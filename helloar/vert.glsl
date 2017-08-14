uniform mat4 trans;
uniform mat4 proj;
attribute vec4 coord;
attribute vec4 color;
varying vec4 vcolor;
//attribute vec2 TexCoordIn;
//varying vec2 TexCoordOut;

void main(void)
{
    vcolor = color;
    gl_Position = proj*trans*coord;
//    TexCoordOut = TexCoordIn;
}