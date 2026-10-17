#version 320 es
precision highp float;

uniform vec2 uResolution;
 // Screen resolution
uniform sampler2D uTexture; // The texture representing the already-rendered game world
    
// Time for animation

out vec4 fragColor;

void main() {
    vec2 uv = gl_FragCoord.xy / uResolution.xy; 
    // Normalized screen coordinates

    // Chromatic aberration offsets
    float aberrationAmount = 0.01;
    vec2 redOffset = vec2(aberrationAmount, 0.0);
    vec2 greenOffset = vec2(0.0, aberrationAmount);
    vec2 blueOffset = vec2(-aberrationAmount, 0.0);

    // Simulate some base color for the CRT effect, e.g., a gradient based on UV coordinates
    vec3 baseColor = vec3(1.0, 1.0, 1.0)*0.5;  
    // Example color based on screen position

   // Sample the existing screen texture with chromatic aberration offsets
   float r = texture(uTexture, uv + redOffset).r;
   float g = texture(uTexture, uv + greenOffset).g;
   float b = texture(uTexture, uv + blueOffset).b;

    // Combine the RGB channels
    vec3 color = vec3(r, g, b);

    // Add static scanlines
    float scanlineFrequency = 300.0; // Adjust this to control scanline density
    float scanline = step(0.5, fract(uv.y * scanlineFrequency)) * 0.1; // Static scanlines
    color -= scanline; // Darken the lines
    // Final output color
    fragColor = vec4(color, 0.2);
}