matrix_set(matrix_world, matrix_build(0, room_height/2, 0,   0,0,0,   1, -room_height, 1));
vertex_submit(vbuff, pr_linelist, -1);

matrix_set(matrix_world, matrix_build(0, room_height/2, 0,   0,0,0,   1, room_height, 1));
vertex_submit(vbuff, pr_linelist, -1);

matrix_set(matrix_world, matrix_build_identity());