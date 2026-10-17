#version 320 es
precision highp float;

uniform vec2 uResolution;
uniform sampler2D uTexture;

out vec4 fragColor;

void main() {
    vec2 uv = gl_FragCoord.xy / uResolution.xy;
    vec4 color = texture(uTexture, uv);
   
    fragColor = vec4(color.rgb, 0.8);
}