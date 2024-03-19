Shader "Roberto/LambertShader"
{
	Properties
	{
		_DiffuseTex("Main Texture", 2D) = "white" {}
		_Color("Color", Color) = (1,0,0,1)
		_Ambient("Ambient", Range(0.0, 1.0)) = 0.2
	}
		SubShader
		{
			Tags { "RenderType" = "Opaque" "LightMode" = "ForwardBase"}
			LOD 100

			Pass
			{
				CGPROGRAM
				#pragma vertex vert
				#pragma fragment frag

				#include "UnityCG.cginc"
				#include "UnityLightingCommon.cginc"

				struct appdata
				{
					float4 vertex : POSITION;
					float3 normal : NORMAL;
					float2 uv : TEXCOORD0;
				};

				struct v2f
				{
					float4 vertex : SV_POSITION;
					float3 worldNormal : TEXCOORD0;
					float2 uv : TEXCOORD1;
				};

				sampler2D _DiffuseTex;
				float4 _DiffuseTex_ST;

				fixed4 _Color;
				float _Ambient;

				v2f vert(appdata v)
				{
					v2f o;
					o.vertex = UnityObjectToClipPos(v.vertex);
					o.worldNormal = UnityObjectToWorldNormal(v.normal);
					o.uv = TRANSFORM_TEX(v.uv, _DiffuseTex);
					return o;
				}

				fixed4 frag(v2f i) : SV_Target
				{
					float4 texCol = tex2D(_DiffuseTex, i.uv);

					fixed3 normalDirection = normalize(i.worldNormal);
					fixed angle = max(_Ambient, dot(normalDirection, _WorldSpaceLightPos0.xyz));
					fixed4 diffuse = angle * texCol * _Color * _LightColor0;

					return diffuse;
				}
				ENDCG
			}
		}
}
