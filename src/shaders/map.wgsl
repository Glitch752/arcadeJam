override MAP_WIDTH: i32;
override MAP_HEIGHT: i32;

// Fullscreen triangle
@vertex
fn vs_main(
  @builtin(vertex_index) VertexIndex : u32
) -> @builtin(position) vec4<f32> {
  var pos = array<vec2<f32>, 3>(
    vec2(-1, 3),
    vec2(3, -1),
    vec2(-1, -1)
  );

  return vec4<f32>(pos[VertexIndex], 0.0, 1.0);
}

@group(0) @binding(0) var<storage, read> map: array<u32>;

struct WindowSize {
  window_width: f32,
  window_height: f32,
  player_x: f32,
  player_y: f32,
  tile_width: f32
};

@group(0) @binding(1) var<uniform> window_size: WindowSize;

@fragment
fn fs_main(
  @builtin(position) frag_coord : vec4<f32>
) -> @location(0) vec4<f32> {
  var a = MAP_WIDTH * MAP_HEIGHT; // Makes sure the compiler doesn't optimize the variables out and error when the override is not present

  // return vec4(window_size.tl_corner_x, window_size.tl_corner_y, window_size.tile_width, 1.0);

  var tileSize = window_size.tile_width;
  var x = i32((frag_coord.x - window_size.window_width  / 2) / tileSize + window_size.player_x);
  var y = i32((frag_coord.y - window_size.window_height / 2) / tileSize + window_size.player_y);

  if (x >= MAP_WIDTH || y >= MAP_HEIGHT || x < 0 || y < 0) {
    return vec4(0.0, 0.0, 0.0, 1.0);
  }

  var id = map[u32(y * MAP_WIDTH + x)];

  return vec4(get_tile_color(id), 1.0);
}

fn get_tile_color(id: u32) -> vec3<f32> {
  switch(id) {
    case 0u: { // Empty
      return vec3<f32>(0.1, 0.25, 0.5);
    }
    case 1u: { // Wall
      return vec3<f32>(0.8, 0.5, 0.5);
    }
    case 2u: { // Water
      return vec3<f32>(0.2, 0.5, 1.0);
    }
    default: { // Unknown
      return vec3<f32>(1.0, 0.0, 1.0);
    }
  }
}