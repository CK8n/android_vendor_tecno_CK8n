#extension GL_ARM_shader_framebuffer_fetch : require

precision highp float;
varying vec2 texCoord;
varying vec2 sucaiTexCoord;
varying float varOpacity;
uniform float varOpactity2;
uniform sampler2D inputImageTexture;
uniform sampler2D sucaiImageTexture;
uniform sampler2D sucaiImageTexture1;


uniform float intensity;
uniform int openMouth;

#ifdef USE_SEG
 varying vec2 segCoord;
 uniform sampler2D segMaskTexture;
#endif

vec3 blendMultiply(vec3 base, vec3 blend) {
    return base * blend;
}

vec3 blendMultiply(vec3 base, vec3 blend, float opacity) {
    return (blendMultiply(base, blend) * opacity + blend * (1.0 - opacity));
}

void main()
{
    // vec4 src = texture2D(inputImageTexture, texCoord);
    vec4 src = gl_LastFragColorARM;

    float valid = step(0.0, sucaiTexCoord.x) * step(0.0, sucaiTexCoord.y) * (1.0 - step(1.0, sucaiTexCoord.x)) * (1.0 - step(1.0, sucaiTexCoord.y));
    vec4 meVal = texture2D(sucaiImageTexture, sucaiTexCoord) * valid;
    vec3 colorRes = src.rgb;
    if (meVal.a >0.0)
        meVal.rgb = meVal.rgb /meVal.a;
    
    vec3 color = blendMultiply(colorRes, meVal.rgb);
#ifdef USE_SEG
    if (meVal.a < 0.001) discard;  //xinyinqingmeizhuangfaceu lipsduorenzhuangchongdiewenti
    float seg_opacity = (texture2D(segMaskTexture, segCoord)).x;
    if(clamp(segCoord, 0.0, 1.0) != segCoord) seg_opacity = 1.0;
    color = mix(src.rgb, color, seg_opacity);
#endif
    float alpha = meVal.a * intensity*varOpacity;
    color = mix(colorRes, color, alpha);

    // lips2
    {
        src.rgb = color;
        vec4 meVal = texture2D(sucaiImageTexture1, sucaiTexCoord) * valid;
        vec3 colorRes = src.rgb;
        if (meVal.a >0.0)
            meVal.rgb = meVal.rgb /meVal.a;
        
        // vec3 color = blendMultiply(colorRes, meVal.rgb);
        color = meVal.rgb;
        float alpha = meVal.a * intensity*varOpactity2;
    #ifdef USE_SEG
        color = mix(src.rgb, color, seg_opacity);
    #endif
        
        gl_FragColor = vec4(mix(colorRes, color, alpha), 1.0); 
    }
}
