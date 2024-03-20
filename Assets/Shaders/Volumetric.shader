Shader "Unlit/Volumetric"
{
	Properties
	{
		_MainTex("Texture", 2D) = "white" {}
		_Centre("Centre", Vector) = (0,0,0,0)
		_Radius("Radius", Float) = 0.3

		_Power("Specular Power", Float) = 1
		_Glossiness("Glossiness", Float) = 0
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
				#include "Lighting.cginc"

				struct appdata
				{
					float4 vertex : POSITION;
					float2 uv : TEXCOORD0;
				};

				struct v2f
				{
					float2 uv : TEXCOORD0;
					float4 vertex : SV_POSITION;
					float3 worldPos : TEXCOORD1;
				};

				sampler2D _MainTex;
				float4 _MainTex_ST;
				float4 _Centre;
				float _Radius;
				float _Power;
				float _Glossiness;

				#define STEPS 64
				#define MIN_DISTANCE 0.01

				float sphereDistance(float3 pos)
				{
					return distance(pos, _Centre) - _Radius;
				}


				float3 calcNormal(float3 p) // for function f(p)
				{
					const float eps = 0.0001; // or some other value
					const float2 h = float2(eps, 0);
					return normalize(
						float3(
							sphereDistance(p + h.xyy) - sphereDistance(p - h.xyy),
							sphereDistance(p + h.yxy) - sphereDistance(p - h.yxy),
							sphereDistance(p + h.yyx) - sphereDistance(p - h.yyx)));
				}

				fixed4 testlambert(fixed3 normal, fixed3 worldPos)
				{
					fixed3 lightDir = _WorldSpaceLightPos0.xyz;
					fixed3 lightCol = _LightColor0.rgb;

					fixed NdotL = max(dot(normal, lightDir), 0);
					fixed3 viewDirection = normalize(worldPos - _WorldSpaceCameraPos);

					fixed3 dir = (lightDir - viewDirection) / 2.0;
					fixed specular = pow(max(0.0, dot(normal, dir)), _Power) * _Glossiness;

					fixed4 col;
					col.rgb = (1, 1, 1) * lightCol * NdotL + specular + fixed3(0.2, 0.2, 0.2);
					col.a = 1;
					return col;
				}



				fixed4 raymarch(float3 position, float3 direction)
				{
					for (int i = 0; i < STEPS; i++)
					{
						//Controllo se sono nella sfera
						float distance = sphereDistance(position);
						if (distance < MIN_DISTANCE)
						{
							float3 normal = calcNormal(position);
							return testlambert(normal, position);
						}

						//Se no incremento la posizione di partenza per il prossimo loop
						position += direction * distance;
					}

					return 0;
				}

				v2f vert(appdata v)
				{
					v2f o;
					o.vertex = UnityObjectToClipPos(v.vertex);
					o.uv = TRANSFORM_TEX(v.uv, _MainTex);
					o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
					return o;
				}

				fixed4 frag(v2f i) : SV_Target
				{
					float3 worldPosition = i.worldPos;
					float3 viewDirection = normalize(i.worldPos - _WorldSpaceCameraPos);


					fixed4 col = raymarch(worldPosition, viewDirection);
					clip(col.r - 0.1);
					return col;
					// sample the texture
					//fixed4 col = tex2D(_MainTex, i.uv);
					//return col;


				}
				ENDCG
			}
		}
}
