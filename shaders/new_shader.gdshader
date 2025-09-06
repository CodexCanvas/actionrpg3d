shader_type canvas_item;

uniform float noise_amount : hint_range(0.0, 1.0) = 0.05;
uniform float pixel_scale : hint_range(1.0, 100.0) = 1.0;
uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;

// A simple pseudo-random number generator
float random(vec2 st) {
    return fract(sin(dot(st.xy, vec2(12.9898, 78.233))) * 43758.5453123);
}

void fragment() {
    // Get the color from the screen
    vec4 color = texture(SCREEN_TEXTURE, SCREEN_UV);

    // Create a blocky coordinate based on pixel_scale.
    // This makes the noise appear pixelated.
    vec2 block_coord = floor(FRAGCOORD.xy / pixel_scale);

    // Generate a random noise value that changes over time using the blocky coordinate
    float noise = (random(block_coord + TIME) - 0.5) * noise_amount;

    // Add the noise to the screen color
    color.rgb += noise;

    // Set the final color
    COLOR = color;
}