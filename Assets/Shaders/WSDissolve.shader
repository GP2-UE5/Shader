Shader "Custom/WSDissolve"
{
	Properties
	{
		_Color("Color", Color) = (1,1,1,1)
		_MainTex("Albedo (RGB)", 2D) = "white" {}
		_Glossiness("Smoothness", Range(0,1)) = 0.5
		_Metallic("Metallic", Range(0,1)) = 0.0
		_DissolveTexture("Dissolve Texture", 2D) = "white" {}
		_Range("Range", Float) = 5
	}
		SubShader
		{
			Tags { "RenderType" = "Opaque" }
			LOD 200

			CGPROGRAM
			// Physically based Standard lighting model, and enable shadows on all light types
			#pragma surface surf Standard fullforwardshadows

			// Use shader model 3.0 target, to get nicer looking lighting
			#pragma target 3.0

			#include "Library\PackageCache\jp.keijiro.noiseshader@2.0.0\Shader\ClassicNoise3D.hlsl"

			sampler2D _MainTex;

			struct Input
			{
				float2 uv_MainTex;
				float3 worldPos;
			};

			half _Glossiness;
			half _Metallic;
			fixed4 _Color;
			float3 _PlayerPos;
			sampler2D _DissolveTexture;
			float _Range;


			void surf(Input IN, inout SurfaceOutputStandard o)
			{
				float dist = distance(_PlayerPos, IN.worldPos);
				half dissolve_value = abs(ClassicNoise(IN.worldPos));

				float clip_value = (dist - _Range) / _Range - dissolve_value  * step(_Range, dist);

				clip(clip_value);

				// Albedo comes from a texture tinted by color
				fixed4 c = tex2D(_MainTex, IN.uv_MainTex) * _Color;
				o.Albedo = c.rgb;
				// Metallic and smoothness come from slider variables
				o.Metallic = _Metallic;
				o.Smoothness = _Glossiness;
				o.Alpha = c.a;
				//o.Emission = 1 - dist;
			}
			ENDCG
		}
			FallBack "Diffuse"
}
