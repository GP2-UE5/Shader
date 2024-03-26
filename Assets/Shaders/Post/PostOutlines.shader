Shader "Post/PostOutlines"
{
	Properties
	{
		[HideInInspector] _MainTex("Texture", 2D) = "white" {}

		[Header(Outline)]
		_OutlineColor("Outline Color", Color) = (0,0,0,1)
		_NormalMult("Normal Outline Intensity", Range(0, 5)) = 1
		_NormalBias("Normal Outline Bias", Range(1, 5)) = 1
		_DepthMult("Depth Outline Intensity", Range(0,5)) = 1
		_DepthBias("Depth Outline Bias", Range(1, 5)) = 1
	}
		SubShader
		{
			Tags { "RenderType" = "Opaque" }

			Cull Off
			Zwrite Off
			ZTest Always

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
				};

				struct v2f
				{
					float2 uv : TEXCOORD0;
					float4 vertex : SV_POSITION;
				};

				sampler2D _MainTex;
				float4 _MainTex_ST;
				sampler2D _CameraDepthNormalsTexture;
				float4 _CameraDepthNormalsTexture_TexelSize;

				float4 _OutlineColor;
				float _NormalMult;
				float _NormalBias;
				float _DepthMult;
				float _DepthBias;

				void CheckNextPixel(inout float depthOutline, inout float normalOutline, float depth, float3 normal, float2 uv, float2 offset)
				{
					float4 neighbourDepthNormal =
						tex2D(_CameraDepthNormalsTexture, uv + _CameraDepthNormalsTexture_TexelSize * offset);

					float3 neighbourNormal;
					float neighbourDepth;

					DecodeDepthNormal(neighbourDepthNormal, neighbourDepth, neighbourNormal);
					neighbourDepth *= _ProjectionParams.z;

					float diff = depth - neighbourDepth;
					depthOutline += diff;


					float3 normalDiff = normal - neighbourNormal;
					normalDiff = normalDiff.r + normalDiff.g + normalDiff.b;
					normalOutline += normalDiff;

				}

				v2f vert(appdata v)
				{
					v2f o;
					o.vertex = UnityObjectToClipPos(v.vertex);
					o.uv = TRANSFORM_TEX(v.uv, _MainTex);
					return o;
				}

				fixed4 frag(v2f i) : SV_Target
				{
					fixed4 col = tex2D(_MainTex, i.uv);

				// sample the texture
				float4 depthNormal = tex2D(_CameraDepthNormalsTexture, i.uv);

				float3 normal;
				float depth;

				DecodeDepthNormal(depthNormal, depth, normal);
				depth *= _ProjectionParams.z;

				float depthDiff = 0;
				float normalDiff = 0;

				CheckNextPixel(depthDiff, normalDiff, depth, normal, i.uv, float2(1, 0));
				CheckNextPixel(depthDiff, normalDiff, depth, normal, i.uv, float2(-1, 0));
				CheckNextPixel(depthDiff, normalDiff, depth, normal, i.uv, float2(0, 1));
				CheckNextPixel(depthDiff, normalDiff, depth, normal, i.uv, float2(0, -1));

				depthDiff *= _DepthMult;
				depthDiff = saturate(depthDiff);
				depthDiff = pow(depthDiff, _DepthBias);

				normalDiff *= _NormalMult;
				normalDiff = saturate(normalDiff);
				normalDiff = pow(normalDiff, _DepthBias);

				float outline = depthDiff + normalDiff;

				float4 outputCol = lerp(col, _OutlineColor, outline);
				return outputCol;
		}
		ENDCG
	}
		}
}
