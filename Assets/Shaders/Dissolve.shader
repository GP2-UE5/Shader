Shader "Custom/Dissolve"
{
	Properties
	{
		_Color("Color", Color) = (1,1,1,1)
		_MainTex("Albedo (RGB)", 2D) = "white" {}
		_Glossiness("Smoothness", Range(0,1)) = 0.5
		_Metallic("Metallic", Range(0,1)) = 0.0
		_DissolveTexture("Dissolve Texture", 2D) = "white" {}
		_Amount("Amount", Range(0,1)) = 0
		_DissolveEmissionColor("Dissolve Emission Color", Color) = (1,1,1,1)
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

			sampler2D _MainTex;

			struct Input
			{
				float2 uv_MainTex;
			};

			half _Glossiness;
			half _Metallic;
			fixed4 _Color;
			sampler2D _DissolveTexture;
			float _Amount;
			float4 _DissolveEmissionColor;


			void surf(Input IN, inout SurfaceOutputStandard o)
			{
				half dissolve_value = tex2D(_DissolveTexture, IN.uv_MainTex).r;
				clip(dissolve_value - _Amount);

				o.Emission = _DissolveEmissionColor * step(dissolve_value - _Amount, 0.05f);

				// Albedo comes from a texture tinted by color
				fixed4 c = tex2D(_MainTex, IN.uv_MainTex) * _Color;
				o.Albedo = c.rgb;
				// Metallic and smoothness come from slider variables
				o.Metallic = _Metallic;
				o.Smoothness = _Glossiness;
				o.Alpha = c.a;
			}
			ENDCG
		}
			FallBack "Diffuse"
}
