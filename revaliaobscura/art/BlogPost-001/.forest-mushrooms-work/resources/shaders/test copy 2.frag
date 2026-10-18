#version 320 es
precision highp float;
uniform vec2 uResolution;


out vec4 fragColor;

void main() {
    vec2 uv = gl_FragCoord.xy / uResolution.xy;
    vec3 color = vec3(uv.r,uv.g,fragColor.b);
    fragColor = vec4(color, 0.6);
}