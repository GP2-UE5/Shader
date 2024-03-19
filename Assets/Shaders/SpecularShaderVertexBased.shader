Shader "Roberto/SpecularShaderVertexBased"
{
	Properties
	{
		_DiffuseTex("Main Texture", 2D) = "white" {}
		_Color("Color", Color) = (1,0,0,1)
		_Ambient("Ambient", Range(0.0, 1.0)) = 0.2
		_SpecCol("Specular Color", Color) = (1,1,1,1)
		_Shininess("Shininess", Float) = 10
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
					float2 uv : TEXCOORD1;
					float4 specularCol : TEXCOORD0;
					float angle : TEXCOORD2;
				};

				sampler2D _DiffuseTex;
				float4 _DiffuseTex_ST;

				fixed4 _Color;
				float _Ambient;
				fixed4 _SpecCol;
				float _Shininess;

				v2f vert(appdata v)
				{
					v2f o;
					o.vertex = UnityObjectToClipPos(v.vertex);
					float3 worldNormal = UnityObjectToWorldNormal(v.normal);
					o.uv = TRANSFORM_TEX(v.uv, _DiffuseTex);
					float4 vertexWorld = mul(unity_ObjectToWorld, v.vertex);

					fixed3 normalDirection = normalize(worldNormal);
					fixed3 cameraDirection = normalize(UnityWorldSpaceViewDir(vertexWorld));
					fixed3 lightDirection = normalize(UnityWorldSpaceLightDir(vertexWorld));

					float3 reflectionDirection = reflect(-lightDirection, normalDirection);
					float3 specularDot = max(0.0, dot(cameraDirection, reflectionDirection));
					float3 specular = pow(specularDot, _Shininess);

					o.specularCol = float4(specular, 1) * _LightColor0;
					o.angle = max(_Ambient, dot(normalDirection, _WorldSpaceLightPos0.xyz));
					return o;
				}

				float4 frag(v2f i) : SV_Target
				{
					float4 texCol = tex2D(_DiffuseTex, i.uv);
					float4 diffuse = i.angle * texCol * _Color * _LightColor0;

					return diffuse + i.specularCol;
				}
				ENDCG
			}
		}
}
