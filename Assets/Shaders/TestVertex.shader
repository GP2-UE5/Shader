Shader "Roberto/TestVertex"
{
	Properties
	{
		_ColorA("Color A", Color) = (1,1,1,1)
		_ColorB("Color B", Color) = (1,1,1,1)

		_ColorStart("Color Start", Range(0,1)) = 0
		_ColorEnd("Color End", Range(0,1)) = 1

		_Scale("UV Scale", Float) = 1
		_Offset("UV Offset", Float) = 0

		_WaveAmp("Wave Amplitude", Range(0, 1)) = 0.1
	}
		SubShader
	{
		Tags { "RenderType" = "Opaque" "Queue" = "Geometry" }
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
				float offsetValue : TEXCOORD2;
			};

			#define DUEPI 6.28318530718

			float4 _ColorA;
			float4 _ColorB;
			float _ColorStart;
			float _ColorEnd;
			float _Scale;
			float _Offset;
			float _WaveAmp;

			float GetWave(float2 uv)
			{
				float2 centeredUvs = uv * 2 - 1;
				float radialDistance = length(centeredUvs);

				float wave = cos((radialDistance - _Time.y * 0.1) * DUEPI * 5) * 0.5 + 0.5;
				wave *= saturate(1 - radialDistance);

				return wave;
			}

			v2f vert(appdata v)
			{
				v.vertex.y = GetWave(v.uv) * _WaveAmp;

				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = (v.uv + _Offset) * _Scale;
				o.normal = v.normal; //UnityObjectToWorldNormal(v.normal);
				//o.normal = mul(v.normal, (float3x3)unity_WorldToObject);
				//o.normal = mul((float3x3)unity_ObjectToWorld , v.normal);
				o.offsetValue = v.vertex.x;
				return o;
			}

			float InverseLerp(float a, float b, float t)
			{
				return (t - a) / (b - a);
			}

			float4 frag(v2f i) : SV_Target
			{
				/*float x = (i.uv.y - _Time.y * 0.5);
				float t = cos(x * DUEPI * 2);
				t *= 1 - i.uv.y;
				float t2 = cos(x * DUEPI * 4);
				t2 *= 1 - i.uv.y;

				float wave = (t + t2) * 0.5 + 0.5;*/


				return _ColorA * GetWave(i.uv);
			}
			ENDCG
		}
	}
}
