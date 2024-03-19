Shader "Roberto/Textured"
{
	Properties
	{
		_MainTex("Texture", 2D) = "white" {}
		_SecondTex("Second Texture", 2D) = "white" {}
		_ThirdTex("Third Texture", 2D) = "white" {}
		_SplatMap("Mask", 2D) = "white" {}
		_DisplaceAmount("Displace Amount", Range(0,1)) = 0.5
		_MipSampleLevel("MIP Level", Float) = 0
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
					float3 normal : NORMAL;
				};

				struct v2f
				{
					float2 uv : TEXCOORD0;
					float4 vertex : SV_POSITION;
					float3 worldPos : TEXCOORD1;
					float2 flow : TEXCOORD2;
				};

				#define DUEPI 6.28318530718

				float GetWave(float2 uv)
				{
					float wave = cos((uv - _Time.y * 0.1) * DUEPI * 5) * 0.5 + 0.5;
					wave *= uv;

					return wave;
				}

				sampler2D _MainTex;
				float4 _MainTex_ST;
				sampler2D _SecondTex;
				sampler2D _ThirdTex;
				sampler2D _SplatMap;
				float _DisplaceAmount;
				float _MipSampleLevel;

				v2f vert(appdata v)
				{
					float2 flow = tex2Dlod(_SplatMap, float4(v.uv, 0, 0)).x;
					float2 newUv = lerp(v.uv, v.uv + _Time.y * .2, flow);
					//float2 newUv = v.uv + _Time.y * flow;

					float displacement = tex2Dlod(_MainTex, float4(v.uv, 0, 0));
					v.vertex.xyz += v.normal * displacement * _DisplaceAmount;


					v2f o;
					o.worldPos = mul(UNITY_MATRIX_M, float4(v.vertex.xyz, 1));
					o.vertex = UnityObjectToClipPos(v.vertex);
					o.uv = TRANSFORM_TEX(v.uv, _MainTex);
					o.flow = newUv;
					return o;
				}

				float4 frag(v2f i) : SV_Target
				{
					float2 topDownProjection = i.worldPos.xyz;

					//float4 col = tex2D(_MainTex, i.uv);
					float4 col = tex2Dlod(_MainTex, float4(i.uv, _MipSampleLevel.xx));
					float4 secondCol = tex2D(_SecondTex, i.flow);
					float4 thirdCol = tex2D(_ThirdTex, i.worldPos.xz);
					float3 pattern = tex2D(_SplatMap, i.uv);

					float4 rCol = lerp(float4(0, 0, 0, 1), secondCol , pattern.x);
					float4 gCol = lerp(float4(0, 0, 0, 1), thirdCol, pattern.y);
					float4 bCol = lerp(float4(0, 0, 0, 1), col, pattern.b);

					return thirdCol;

				}
				ENDCG
			}
		}
}
