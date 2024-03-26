Shader "Post/PostNormals"
{
	Properties
	{
		[HideInInspector] _MainTex("Texture", 2D) = "white" {}
		_SnowColor("Snow Color", Color) = (1,1,1,1)

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

				float4x4 _ViewToWorldMTX;
				float4 _SnowColor;

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

				normal = mul((float3x3)_ViewToWorldMTX, normal);

				float up = dot(float3(0, 1, 0), normal);
				up = 0.5 <= up;


				return lerp(col, 1, up);
			}
			ENDCG
		}
		}
}
