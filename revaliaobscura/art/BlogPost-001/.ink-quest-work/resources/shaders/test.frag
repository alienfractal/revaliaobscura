// crt_effect.frag
#version 320 es
precision highp float;

uniform sampler2D uTexture;
uniform vec2 uResolution;
uniform float uTime;

out vec4 fragColor;

float random (vec2 st) {
    return fract(sin(dot(st.xy,
                         vec2(-0.030,0.650)))*
        43758.041);
}

void main() {
    vec2 uv = gl_FragCoord.xy / uResolution.xy;

    // Chromatic aberration offsets
    float ra = random(vec2(uTime, uv.y));
    //float aberrationAmount = 0.002 * ra;
    float aberrationAmount = 0.001 ;
    vec2 redOffset = vec2(aberrationAmount, 0.0);
    vec2 greenOffset = vec2(0.0, aberrationAmount);
    vec2 blueOffset = vec2(-aberrationAmount, 0.0);

    // Sample texture with offsets
    float r = texture(uTexture, uv + redOffset).r;
    float g = texture(uTexture, uv + greenOffset).g;
    float b = texture(uTexture, uv + blueOffset).b;
      //  noise lines
 

    // Combine channels
    vec3 color = vec3(r, g, b);

    // Add scanlines

    //float scanline = sin((uv.y  * 0.5 ) * uResolution.y * 4.0) * 0.05;
    float scanline = sin((uv.y  * 0.5 ) * uResolution.y * 4.0) * 0.05;
    color -= scanline;

    fragColor = vec4(color, 1.0);
}
