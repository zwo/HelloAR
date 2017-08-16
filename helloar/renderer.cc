/**
* Copyright (c) 2015-2016 VisionStar Information Technology (Shanghai) Co., Ltd. All Rights Reserved.
* EasyAR is the registered trademark or trademark of VisionStar Information Technology (Shanghai) Co., Ltd in China
* and other countries for the augmented reality technology developed by VisionStar Information Technology (Shanghai) Co., Ltd.
*/

#include "renderer.hpp"


#include <iostream>
extern "C" {
#include "ARHelperBridge.h"
}

/*
 for attribute: (1)use program (2)glGetAttribLocation save in a int var (3)glEnableVertexAttribArray
 (4) 设置VBO
 (5)glVertexAttribPointer - feed values to the shader 其实就是说明buffer的data怎么用的
 parameters 1. attribute name 2. how many values are present for each vertex 3. type 5. size of stride 6. offset of stride
 
 for VBO 有2种，one to keep track of the per-vertex data, one to keep track of the indices that make up triangles
 (1)glGenBuffers (2)glBindBuffer (3)glBufferData
 */

namespace EasyAR{
namespace samples{

void Renderer::init()
{
    program_box = glCreateProgram();
    GLuint vertShader = glCreateShader(GL_VERTEX_SHADER);
    const char *box_vert=glslSource("vert");
    glShaderSource(vertShader, 1, &box_vert, 0);
    glCompileShader(vertShader);
    
    printGLErrorMessage(vertShader);
    
    GLuint fragShader = glCreateShader(GL_FRAGMENT_SHADER);
    const char *box_frag=glslSource("frag");
    glShaderSource(fragShader, 1, &box_frag, 0);
    glCompileShader(fragShader);
    printGLErrorMessage(fragShader);
    glAttachShader(program_box, vertShader);
    glAttachShader(program_box, fragShader);
    glLinkProgram(program_box);
    glUseProgram(program_box);
    pos_coord_box = glGetAttribLocation(program_box, "coord");
    pos_color_box = glGetAttribLocation(program_box, "color");
    pos_trans_box = glGetUniformLocation(program_box, "trans");
    pos_proj_box = glGetUniformLocation(program_box, "proj");
    texture_switch = glGetUniformLocation(program_box, "TexOnIn");
    
    _texCoordSlot = glGetAttribLocation(program_box, "TexCoordIn");
    // glEnableVertexAttribArray(_texCoordSlot);
    _textureUniform = glGetUniformLocation(program_box, "Texture");
    size_t width=0,height=0;
    GLubyte *topData=imageDataWithFileName("top.jpg", &width, &height);
    GLuint topName=generateTextureID(width, height, topData);
    buildingTopTexture=topName;
    free(topData);
    GLubyte *sideData=imageDataWithFileName("side.jpg", &width, &height);
    GLuint sideName=generateTextureID(width, height, sideData);
    buildingSideTexture=sideName;
    free(sideData);

    glGenBuffers(1, &vbo_coord_box);
    glBindBuffer(GL_ARRAY_BUFFER, vbo_coord_box);
    const GLfloat cube_vertices[8][3] = {
        /* +z */{1.0f / 2, 1.0f / 2, 0.01f / 2}, {1.0f / 2, -1.0f / 2, 0.01f / 2}, {-1.0f / 2, -1.0f / 2, 0.01f / 2}, {-1.0f / 2, 1.0f / 2, 0.01f / 2},
        /* -z */{1.0f / 2, 1.0f / 2, -0.01f / 2}, {1.0f / 2, -1.0f / 2, -0.01f / 2}, {-1.0f / 2, -1.0f / 2, -0.01f / 2}, {-1.0f / 2, 1.0f / 2, -0.01f / 2}};
    glBufferData(GL_ARRAY_BUFFER, sizeof(cube_vertices), cube_vertices, GL_DYNAMIC_DRAW);

    glGenBuffers(1, &vbo_color_box);
    glBindBuffer(GL_ARRAY_BUFFER, vbo_color_box);
    const GLubyte cube_vertex_colors[8][4] = {
        {255, 0, 0, 128}, {0, 255, 0, 128}, {0, 0, 255, 128}, {0, 0, 0, 128},
        {0, 255, 255, 128}, {255, 0, 255, 128}, {255, 255, 0, 128}, {255, 255, 255, 128}};
    glBufferData(GL_ARRAY_BUFFER, sizeof(cube_vertex_colors), cube_vertex_colors, GL_STATIC_DRAW);

    glGenBuffers(1, &vbo_color_box_2);
    glBindBuffer(GL_ARRAY_BUFFER, vbo_color_box_2);
    const GLubyte cube_vertex_colors_2[8][4] = {
        {255, 0, 0, 255}, {255, 255, 0, 255}, {0, 255, 0, 255}, {255, 0, 255, 255},
        {255, 0, 255, 255}, {255, 255, 255, 255}, {0, 255, 255, 255}, {255, 0, 255, 255}};
    glBufferData(GL_ARRAY_BUFFER, sizeof(cube_vertex_colors_2), cube_vertex_colors_2, GL_STATIC_DRAW);

    glGenBuffers(1, &vbo_faces_box);
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, vbo_faces_box);
    const GLushort cube_faces[6][4] = {
        /* +z */{3, 2, 1, 0}, /* -y */{2, 3, 7, 6}, /* +y */{0, 1, 5, 4},
        /* -x */{3, 0, 4, 7}, /* +x */{1, 2, 6, 5}, /* -z */{4, 5, 6, 7}};
    glBufferData(GL_ELEMENT_ARRAY_BUFFER, sizeof(cube_faces), cube_faces, GL_STATIC_DRAW);
    
    glGenBuffers(1, &_tex_face_pos);
    glBindBuffer(GL_ARRAY_BUFFER, _tex_face_pos);
    const GLfloat top_vertices[4][3]={/* +z */{1 / 5, 1 / 5, 1.01},{1 / 5, -1 / 5, 1.01},{-1 / 5, -1 / 5, 1.01},{-1 / 4, 1 / 5, 1.01}};
    glBufferData(GL_ARRAY_BUFFER, sizeof(top_vertices), top_vertices, GL_DYNAMIC_DRAW);
    
    glGenBuffers(1, &_tex_face_index);
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, _tex_face_index);
    const GLushort top_face[4]={3, 2, 1, 0};
    glBufferData(GL_ELEMENT_ARRAY_BUFFER, sizeof(top_face), top_face, GL_STATIC_DRAW);
    
    glGenBuffers(1, &_tex_face_coord);
    glBindBuffer(GL_ARRAY_BUFFER, _tex_face_coord);
    const GLfloat top_coord[4][2]={{0,0},{0,1},{1,1},{1,0}};
    glBufferData(GL_ARRAY_BUFFER, sizeof(top_coord), top_coord, GL_STATIC_DRAW);
}
/*
    +--------------+0
   /|3            /|
  / |            / |
2*--+-----------*1 |
 |  |           |  |
 |  |           |  |
 |  |           |  |
 | 7+-----------+--+4
 | /            | /
 |/             |/
6*--------------*5
 
(0.0)  _______  (1.0)
      |       |
      |       |
      |       |
(0.1) |_______| (1.1)
 */
void Renderer::render(const Matrix44F& projectionMatrix, const Matrix44F& cameraview, Vec2F size)
{
//    std::cout << "size0: " << size[0] << std::endl;
//    std::cout << "size1: " << size[1] << std::endl; // output 1
    // 底座
    glBindBuffer(GL_ARRAY_BUFFER, vbo_coord_box);
    float height = size[0] / 1000;
    const GLfloat cube_vertices[8][3] = {
        /* +z */{size[0] / 2, size[1] / 2, height / 2}, {size[0] / 2, -size[1] / 2, height / 2}, {-size[0] / 2, -size[1] / 2, height / 2}, {-size[0] / 2, size[1] / 2, height / 2},
        /* -z */{size[0] / 2, size[1] / 2, 0}, {size[0] / 2, -size[1] / 2, 0}, {-size[0] / 2, -size[1] / 2, 0}, {-size[0] / 2, size[1] / 2, 0}};
    glBufferData(GL_ARRAY_BUFFER, sizeof(cube_vertices), cube_vertices, GL_DYNAMIC_DRAW);

    glEnable(GL_BLEND);
    glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    glEnable(GL_DEPTH_TEST);
    glUseProgram(program_box);
    glUniform1i(texture_switch, GL_FALSE);
    glEnableVertexAttribArray(pos_coord_box);
    glVertexAttribPointer(pos_coord_box, 3, GL_FLOAT, GL_FALSE, 0, 0);
    glBindBuffer(GL_ARRAY_BUFFER, vbo_color_box);
    glEnableVertexAttribArray(pos_color_box);
    glVertexAttribPointer(pos_color_box, 4, GL_UNSIGNED_BYTE, GL_TRUE, 0, 0);
    glUniformMatrix4fv(pos_trans_box, 1, 0, cameraview.data);
    glUniformMatrix4fv(pos_proj_box, 1, 0, projectionMatrix.data);
    
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, vbo_faces_box);
    
    for(int i = 0; i < 6; i++) {
        glDrawElements(GL_TRIANGLE_FAN, 4, GL_UNSIGNED_SHORT, (void*)(i * 4 * sizeof(GLushort)));
    }

    // 立方体

    
    // render one face
    glUniform1i(texture_switch, GL_TRUE);
    glBindBuffer(GL_ARRAY_BUFFER, _tex_face_pos);
    const GLfloat top_vertices[4][3]={/* +z */{size[0] / 5, size[1] / 5, size[0]+static_cast<GLfloat>(0.01)},{size[0] / 5, -size[1] / 5, size[0]+static_cast<GLfloat>(0.01)},{-size[0] / 5, -size[1] / 5, size[0]+static_cast<GLfloat>(0.01)},{-size[0] / 5, size[1] / 5, size[0]+static_cast<GLfloat>(0.01)}};
    glBufferData(GL_ARRAY_BUFFER, sizeof(top_vertices), top_vertices, GL_DYNAMIC_DRAW);
    glEnableVertexAttribArray(pos_coord_box);
    glVertexAttribPointer(pos_coord_box, 3, GL_FLOAT, GL_FALSE, 0, 0);
    glActiveTexture(GL_TEXTURE0); // unneccc in practice
    glBindTexture(GL_TEXTURE_2D, buildingTopTexture);
    glUniform1i(_textureUniform, 0); // unnecc in practice
    glBindBuffer(GL_ARRAY_BUFFER, _tex_face_coord);
    glEnableVertexAttribArray(_texCoordSlot);
    glVertexAttribPointer(_texCoordSlot, 2, GL_FLOAT, GL_FALSE, 0, 0);
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, _tex_face_index);
    glDrawElements(GL_TRIANGLE_FAN, 4, GL_UNSIGNED_SHORT, 0);
}    
    
    GLuint Renderer::generateTextureID(size_t width, size_t height, GLubyte *imageData)
    {
        GLuint texName;
        glGenTextures(1, &texName);
        glBindTexture(GL_TEXTURE_2D, texName);
        glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
        glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
        
        glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, (GLsizei)width, (GLsizei)height, 0, GL_RGBA, GL_UNSIGNED_BYTE, imageData);
        return texName;
    }

}
}
