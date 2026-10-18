#version 320 es
precision highp float;

uniform vec2 uResolution;
uniform sampler2D uTexture;

out vec4 fragColor;

void main() {
    // Get normalized screen coordinates (0.0 to 1.0)
    vec2 uv = gl_FragCoord.xy / uResolution.xy;
    float aberrationAmount = 0.002;
    vec4 color;
    color.r = texture(uTexture, uv + vec2(aberrationAmount, 0.0)).r;
    color.g = texture(uTexture, uv).g;
    color.b = texture(uTexture, uv - vec2(aberrationAmount, 0.0)).b;
    color.a = texture(uTexture, uv).a;
    // Add scanlines effect
    float scanline = sin(uv.y * 1200.0) * 0.1; // Adjust the frequency and (Amplitude) intensity of scanlines
    color.rgb -= scanline;
    fragColor = color;
}
