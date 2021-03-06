/*
 * Copyright 2016 CodiLime
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 *
 */
#version 330

uniform mat4 xfrm;
uniform usamplerBuffer tx;
uniform uint sz;
uniform float ort_dist;
uniform float c_pos, c_ort, c_psiz;
uniform float point_size_factor;
out float v_pos, v_factor;

vec3 apply_coord_system(vec3 vert);

void main() {
	int vid = gl_VertexID;
	v_pos = float(vid) / float(sz - 3u);
	uint x = texelFetch(tx, vid).x;
	uint y = texelFetch(tx, vid + 1).x;
	uint z = texelFetch(tx, vid + 2).x;
	vec3 v_coord = vec3(float(x)+0.5, float(y)+0.5, float(z)+0.5) / 256.0;
	v_coord.z *= (1.0 - c_pos);
	v_coord.z += c_pos * v_pos;
	gl_Position = xfrm * vec4(apply_coord_system(v_coord), 1);
	/* 4.0 here needs to match the ortho animation fudge factor in trigram.cc.  */
	float factor = c_ort * 4.0 / ort_dist + (1.0 - c_ort);
	float point_size = point_size_factor / gl_Position.w * factor;
	point_size = mix(1.0, point_size, c_psiz);
	if (point_size < 1.0) {
		gl_PointSize = 1.0;
		v_factor = point_size * point_size;
	} else {
		gl_PointSize = point_size;
		v_factor = 1.0;
	}
}
