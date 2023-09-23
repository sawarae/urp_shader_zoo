Shader "Custom/Gaming"
{
    Properties
    {
        _ColorCycle ("ColorCycle", float) = 0.5
        _BrightCycle ("BrightCycle", float) = 3.0
    }

CGINCLUDE
uniform float _ColorCycle;
uniform float _BrightCycle;

float3 color(float level)
{
    // level: 0~6 -> rgb
    float r = float(level <= 2.0) + float(level > 4.0) * 0.5;
    float g = max(1.0 - abs(level - 2.0) * 0.5, 0.0);
    float b = (1.0 - (level - 4.0) * 0.5) * float(level >= 4.0);
    return float3(r, g, b);
}

float3 smoothColor(float x)
{
    float level1 =  floor(x * 6.0);
    float level2 = min(6.0, floor(x*6.0) + 1.0);
    float3 a = color(level1);
    float3 b = color(level2);
    return lerp(a, b, frac(x * 6.0));
}

float4 paint(float2 uv) 
{
    float repeat = abs(fmod(uv.x * _ColorCycle + _Time.y, 1));
    float3 col = smoothColor(repeat);
    float timeBrightness = sin(_Time.y * _BrightCycle) + 1.5;
    return float4(col * timeBrightness, 1);
}

ENDCG
    SubShader
    {
        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 texcoord : TEXCOORD0;
            };

            struct fin
            {
                float4 vertex : SV_POSITION;
                float2 texcoord : TEXCOORD0;
            };

            fin vert(appdata v)
            {
                fin o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.texcoord = v.texcoord;
                return o;
            }

            float4 frag(fin IN) : SV_TARGET
            {
                return paint(IN.texcoord.xy);
            }
            ENDCG
        }
    }
}