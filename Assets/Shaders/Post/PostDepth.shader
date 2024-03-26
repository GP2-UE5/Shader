Shader "Post/PostDepth"
{
	Properties
	{
		[HideInInspector] _MainTex("Texture", 2D) = "white" {}
		_ScanTex("Texture", 2D) = "white" {}

		[Header(Scanner)]
		_ScanDistance("Distance from camera", Float) = 10
		_ScanThickness("Scan Thickness", Range(0, 10)) = 1
		_ScanColor("Color", Color) = (0,0,1,1)
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
				sampler2D _CameraDepthTexture;

				float _ScanDistance;
				float _ScanThickness;
				float4 _ScanColor;

				sampler2D _ScanTex;

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
				float dist = tex2D(_CameraDepthTexture, i.uv).r;
				dist = Linear01Depth(dist);

				dist *= _ProjectionParams.z;

				if (dist >= _ProjectionParams.z)
					return col;

				float scanFront = _ScanDistance >= dist;
				float scanTrail = smoothstep(_ScanDistance - _ScanThickness, _ScanDistance, dist);

				float scan = scanFront * scanTrail;

				fixed4 scanCol = tex2D(_ScanTex, i.uv) * _ScanColor;
				fixed scanAlpha = scanCol.w;

				scanCol *= scanAlpha;

				return lerp(col, col + scanCol, scan);
			}
			ENDCG
		}
		}
}
