Shader "Roberto/TestNormal"
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
		Tags { "RenderType" = "Opaque" }
		LOD 100

		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag

			#include "UnityCG.cginc"

			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
				//float3 normal : NORMAL;
			};

			struct v2f
			{
				float2 uv : TEXCOORD0;
				float4 vertex : SV_POSITION;
				//float3 normal : TEXCOORD1;
			};

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
				//o.normal = UnityObjectToWorldNormal(v.normal);
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
				float t = saturate(InverseLerp(_ColorStart, _ColorEnd, i.uv.x));
				float4 outputCol = lerp(_ColorA, _ColorB, t);
				
				return outputCol;
			}
			ENDCG
		}
	}
}
