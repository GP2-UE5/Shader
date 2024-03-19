Shader "Roberto/TestWave"
{
	Properties
	{
		_ColorA("Color A", Color) = (1,1,1,1)
		_ColorB("Color B", Color) = (1,1,1,1)

		_ColorStart("Color Start", Range(0,1)) = 0
		_ColorEnd("Color End", Range(0,1)) = 1

		_Scale("UV Scale", Float) = 1
		_Offset("UV Offset", Float) = 0
	}
		SubShader
	{
		Tags { "RenderType" = "Transparent" "Queue" = "Transparent" }
		LOD 100

		Pass
		{
			Blend One One
			//Blend DstColor Zero
			ZWrite Off
			Cull Off

			ZTest LEqual

			CGPROGRAM

			#pragma vertex vert
			#pragma fragment frag

			#include "UnityCG.cginc"

			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
				float3 normal : NORMAL;
			};

			struct v2f
			{
				float2 uv : TEXCOORD0;
				float4 vertex : SV_POSITION;
				float3 normal : TEXCOORD1;
			};

			#define DUEPI 6.28318530718

			float4 _ColorA;
			float4 _ColorB;
			float _ColorStart;
			float _ColorEnd;
			float _Scale;
			float _Offset;

			v2f vert(appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = (v.uv + _Offset) * _Scale;
				o.normal = v.normal; //UnityObjectToWorldNormal(v.normal);
				//o.normal = mul(v.normal, (float3x3)unity_WorldToObject);
				//o.normal = mul((float3x3)unity_ObjectToWorld , v.normal);

				return o;
			}

			float InverseLerp(float a, float b, float t)
			{
				return (t - a) / (b - a);
			}

			float4 frag(v2f i) : SV_Target
			{
				//float t = saturate(InverseLerp(_ColorStart, _ColorEnd, i.uv.x));

				fixed topBottomRemover = (abs(i.normal.y) < 0.999);

				float offset = cos(i.uv.x * DUEPI * 2 ) * 0.1;
				float x = (i.uv.y + offset - _Time.y * 0.5);

				float t = cos(x * DUEPI * 2);
				t *= 1 - i.uv.y;
				float t2 = cos(x * DUEPI * 4);
				t2 *= 1 - i.uv.y;

				float wave = (t + t2) * 0.5 + 0.5;
				float4 gradient = lerp(_ColorA, _ColorB, i.uv.y);

				return wave * topBottomRemover * gradient;
			}
			ENDCG
		}
	}
}
