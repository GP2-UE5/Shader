Shader "Custom/SurfaceTest"
{
	Properties
	{
		_MainTex("Texture", 2D) = "white" {}
		_BumpMap("Normal Map", 2D) = "bump" {}
		_RimColor("Rim Color", Color) = (1,1,1,1)
		_RimPower("RimPower", Range(0.2, 10.0)) = 3.0
		_Detail("Detail", 2D) = "gray" {}
		_Cutoff("Cutoff Value", Float) = 0.5
	}

		SubShader
		{
			Tags { "RenderType" = "Opaque" }

			CGPROGRAM

			#pragma surface surf Lambert

			struct Input
			{
				float2 uv_MainTex;
				float2 uv_BumpMap;
				float2 uv_Detail;
				float3 viewDir;
			};

			sampler2D _MainTex;
			sampler2D _BumpMap;
			float4 _RimColor;
			float _RimPower;
			sampler2D _Detail;
			float _Cutoff;

			void surf(Input IN, inout SurfaceOutput o)
			{
				float4 c = tex2D(_MainTex, IN.uv_MainTex);
				o.Albedo = c.rgb;
				o.Albedo *= tex2D(_Detail, IN.uv_Detail).rgb;
				o.Normal = UnpackNormal(tex2D(_BumpMap, IN.uv_BumpMap));

				float rim = 1.0 - saturate(dot(normalize(IN.viewDir), o.Normal));
				o.Emission = _RimColor.rgb * pow(rim, _RimPower);

				clip(c.a - _Cutoff);
			}
			ENDCG
		}
			FallBack "Diffuse"
}
