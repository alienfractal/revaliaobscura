#version 320 es
precision highp float;

uniform vec2 uResolution;
 // Screen resolution
uniform float uTime;      
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
    vec3 baseColor = vec3(uv.x, uv.y, 0.5);  
    // Example color based on screen position

    // Apply chromatic aberration by offsetting the color channels
    float r = baseColor.r + redOffset.x;
    float g = baseColor.g + greenOffset.y;
    float b = baseColor.b + blueOffset.x;

    // Combine the RGB channels
    vec3 color = vec3(r, g, b);

    // Add scanlines
    float scanline = sin((uv.y + uTime * 0.5) * uResolution.y * 2.0) * 0.05;
    // Moving scanlines
    //color -= scanline; 
    // Darken the lines
    color -= scanline*0.2;
    // Final output color
    fragColor = vec4(color, 1.0);
}