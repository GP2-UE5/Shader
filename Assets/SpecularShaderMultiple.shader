Shader "Roberto/SpecularShaderMultiple"
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
			Tags { "RenderType" = "Opaque" }
			LOD 100

			Pass
			{
				Tags {"LightMode" = "ForwardBase"}

				CGPROGRAM
				#pragma vertex vert
				#pragma fragment frag
				#pragma multi_compile_fwdBase

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
					float3 vertexWorld : TEXCOORD2;
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
					o.worldNormal = UnityObjectToWorldNormal(v.normal);
					o.uv = TRANSFORM_TEX(v.uv, _DiffuseTex);
					o.vertexWorld = mul(unity_ObjectToWorld, v.vertex);

					return o;
				}

				float4 frag(v2f i) : SV_Target
				{
					float4 texCol = tex2D(_DiffuseTex, i.uv);

					fixed3 normalDirection = normalize(i.worldNormal);
					fixed3 cameraDirection = normalize(UnityWorldSpaceViewDir(i.vertexWorld));
					fixed3 lightDirection = normalize(UnityWorldSpaceLightDir(i.vertexWorld));

					fixed angle = max(_Ambient, dot(normalDirection, _WorldSpaceLightPos0.xyz));
					float4 diffuse = angle * texCol * _Color * _LightColor0;


					//vettore riflesso = reflect (-lightDir, normal);
					float3 reflectionDirection = reflect(-lightDirection, normalDirection);
					//cameraSpec = dot(vettore riflesso, cameraDir)
					float3 specularDot = max(0.0, dot(cameraDirection, reflectionDirection));
					//float spec = (cameraSpec, exponent)
					float3 specular = pow(specularDot, _Shininess);

					float4 specularCol = float4(specular, 1) * _LightColor0;

					return diffuse + specularCol;
				}
				ENDCG
			}

			Pass
			{
				Tags{ "LightMode" = "ForwardAdd" }
				Blend One One

				CGPROGRAM
				#pragma vertex vert
				#pragma fragment frag
				#pragma multi_compile_fwdadd

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
					float3 vertexWorld : TEXCOORD2;
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
					o.worldNormal = UnityObjectToWorldNormal(v.normal);
					o.uv = TRANSFORM_TEX(v.uv, _DiffuseTex);
					o.vertexWorld = mul(unity_ObjectToWorld, v.vertex);

					return o;
				}

				float4 frag(v2f i) : SV_Target
				{
					float4 texCol = tex2D(_DiffuseTex, i.uv);

					fixed3 normalDirection = normalize(i.worldNormal);
					fixed3 cameraDirection = normalize(UnityWorldSpaceViewDir(i.vertexWorld));
					fixed3 lightDirection = normalize(UnityWorldSpaceLightDir(i.vertexWorld));

					fixed angle = max(0.0, dot(normalDirection, _WorldSpaceLightPos0.xyz));
					float4 diffuse = angle * texCol * _Color * _LightColor0;


					//vettore riflesso = reflect (-lightDir, normal);
					float3 reflectionDirection = reflect(-lightDirection, normalDirection);
					//cameraSpec = dot(vettore riflesso, cameraDir)
					float3 specularDot = max(0.0, dot(cameraDirection, reflectionDirection));
					//float spec = (cameraSpec, exponent)
					float3 specular = pow(specularDot, _Shininess);

					float4 specularCol = float4(specular, 1) * _LightColor0;

					return diffuse + specularCol;
				}
				ENDCG
			}

		}
}