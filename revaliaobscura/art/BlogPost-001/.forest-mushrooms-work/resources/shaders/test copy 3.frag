#version 300 es
precision mediump float;

uniform vec2 uResolution;
uniform sampler2D uTexture;




out vec4 fragColor;

void main() {
  vec2 uv = gl_FragCoord.xy / uResolution.xy;
  float aberrationAmount = 0.005; // Adjust this value to control the effect

  // Sample the texture at slightly different coordinates for each color channel
  vec4 color;
  color.r = texture(uTexture, uv + vec2(aberrationAmount, 0.0)).r;
  color.g = texture(uTexture, uv).g;
  color.b = texture(uTexture, uv - vec2(aberrationAmount, 0.0)).b;
  color.a = texture(uTexture, uv).a;

    // Example CRT effect (you can tweak this)
    //float scanline = sin(uv.y * uResolution.y *4.0) * 0.1;
    //fragColor = vec4(color.rgb + scanline, color.a);
    fragColor =color;

 
}